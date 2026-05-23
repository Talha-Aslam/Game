import asyncio
import logging
import random
from typing import Dict, List, Optional
from pydantic import BaseModel
from app.core.websocket_manager import manager as ws_manager

logger = logging.getLogger(__name__)

class Player(BaseModel):
    user_id: str
    is_bot: bool = False
    role: Optional[str] = None
    is_alive: bool = True
    
class Room:
    def __init__(self, room_id: str, player_ids: List[str]):
        self.room_id = room_id
        self.players: Dict[str, Player] = {
            pid: Player(user_id=pid, is_bot=pid.startswith("bot_")) 
            for pid in player_ids
        }
        self.state = "lobby"
        self.day_number = 0
        self.task: Optional[asyncio.Task] = None
        
        # State tracking for the current night
        self.night_actions = {
            "mafia_target": None,
            "doctor_target": None,
            "detective_target": None
        }
        
        # State tracking for voting
        self.votes: Dict[str, str] = {} # voter_id -> target_id
        
    def get_alive_players(self) -> List[Player]:
        return [p for p in self.players.values() if p.is_alive]
        
    def get_role_players(self, role: str) -> List[Player]:
        return [p for p in self.players.values() if p.is_alive and p.role == role]
        
    async def broadcast(self, message: dict):
        alive_ids = [p.user_id for p in self.players.values() if not p.is_bot]
        await ws_manager.broadcast_to_group(message, alive_ids)
        
    async def send_to_role(self, role: str, message: dict):
        role_ids = [p.user_id for p in self.get_role_players(role) if not p.is_bot]
        if role_ids:
            await ws_manager.broadcast_to_group(message, role_ids)

class GameEngine:
    def __init__(self):
        self.active_rooms: Dict[str, Room] = {}

    async def create_room(self, room_id: str, player_ids: List[str]):
        room = Room(room_id, player_ids)
        self.active_rooms[room_id] = room
        # Start the autonomous game loop
        room.task = asyncio.create_task(self._game_loop(room))
        logger.info(f"Room {room_id} loop started")

    def end_room(self, room_id: str):
        if room_id in self.active_rooms:
            room = self.active_rooms[room_id]
            if room.task:
                room.task.cancel()
            del self.active_rooms[room_id]
            logger.info(f"Room {room_id} ended and cleaned up")

    def handle_action(self, room_id: str, user_id: str, action: dict):
        if room_id not in self.active_rooms:
            return
            
        room = self.active_rooms[room_id]
        player = room.players.get(user_id)
        if not player or not player.is_alive:
            return
            
        action_type = action.get("action")
        target = action.get("target")
        
        if room.state == "night":
            if action_type == "mafia_kill" and player.role == "mafia":
                room.night_actions["mafia_target"] = target
            elif action_type == "doctor_save" and player.role == "doctor":
                room.night_actions["doctor_target"] = target
            elif action_type == "detective_scan" and player.role == "detective":
                room.night_actions["detective_target"] = target
                # Instantly reply to detective privately
                target_p = room.players.get(target)
                is_mafia = target_p is not None and target_p.role == "mafia"
                asyncio.create_task(
                    ws_manager.send_personal_message({
                        "event": "scan_result",
                        "target": target,
                        "is_mafia": is_mafia
                    }, user_id)
                )
                
        elif "vote" in room.state:
            if action_type == "vote":
                room.votes[user_id] = target

    async def _send_voice_channel(self, room: Room, players: List[Player], channel_name: str, event: str = "join_main_voice"):
        from app.services.agora_service import generate_rtc_token_with_account
        for p in players:
            if not p.is_bot:
                try:
                    token = generate_rtc_token_with_account(channel_name=channel_name, account=p.user_id)
                    await ws_manager.send_personal_message({
                        "event": event,
                        "channel": channel_name,
                        "token": token
                    }, p.user_id)
                except Exception as e:
                    logger.error(f"Failed to generate voice token for {p.user_id}: {e}")

    # --- AUTONOMOUS GAME LOOP ---
    async def _game_loop(self, room: Room):
        try:
            # 1. LOBBY PHASE
            room.state = "lobby"
            await room.broadcast({"event": "phase_change", "phase": "lobby", "duration": 10})
            
            # Put everyone in the main lobby voice channel
            await self._send_voice_channel(room, list(room.players.values()), room.room_id)
            
            await asyncio.sleep(10)
            
            await room.broadcast({"event": "system_message", "message": "The Show Begins"})
            self._assign_roles(room)
            
            # Send roles to players
            for user_id, p in room.players.items():
                if not p.is_bot:
                    await ws_manager.send_personal_message({
                        "event": "role_assigned",
                        "role": p.role
                    }, user_id)
            
            while True:
                room.day_number += 1
                
                # 2. NIGHT PHASE
                room.state = "night"
                room.night_actions = {"mafia_target": None, "doctor_target": None, "detective_target": None}
                
                mafia_count = len(room.get_role_players("mafia"))
                night_duration = 20 if mafia_count > 1 else 10
                
                # Mute everyone, then move Mafia to secret channel
                await room.broadcast({
                    "event": "phase_change", 
                    "phase": "night", 
                    "duration": night_duration,
                    "day_number": room.day_number,
                    "audio": "ambient_night"
                })
                await self._send_voice_channel(room, room.get_role_players("mafia"), f"{room.room_id}_mafia", "join_mafia_voice")
                
                await asyncio.sleep(night_duration)
                
                # Process Bots
                self._process_bot_night_actions(room)
                
                # 3. DAWN PHASE
                room.state = "dawn"
                killed_player = self._resolve_night(room)
                
                await room.broadcast({"event": "phase_change", "phase": "dawn", "duration": 5})
                
                if killed_player:
                    await room.broadcast({
                        "event": "player_killed",
                        "target": killed_player,
                        "message": f"Player {killed_player} was eliminated."
                    })
                    # Move dead player to graveyard voice channel
                    dead_p = room.players.get(killed_player)
                    if dead_p and not dead_p.is_bot:
                        await self._send_voice_channel(room, [dead_p], f"{room.room_id}_graveyard", "join_graveyard_voice")
                else:
                    await room.broadcast({"event": "system_message", "message": "No one was eliminated tonight."})
                    
                await asyncio.sleep(5)
                
                if await self._check_win_condition(room):
                    break
                    
                # 4. DAY DISCUSSION
                room.state = "day"
                await room.broadcast({
                    "event": "phase_change", 
                    "phase": "day", 
                    "duration": 60,
                    "audio": "unmute_all_alive"
                })
                # Move alive players back to main voice (mafia was in private)
                await self._send_voice_channel(room, room.get_alive_players(), room.room_id)
                
                await asyncio.sleep(60)
                
                # 5. VOTING PHASE
                room.state = "voting"
                room.votes.clear()
                await room.broadcast({"event": "phase_change", "phase": "voting", "duration": 10})
                
                await asyncio.sleep(10)
                
                self._process_bot_votes(room)
                exiled_player, is_tie = self._resolve_votes(room)
                
                if is_tie:
                    # TIE RUNOFF VOTE
                    room.state = "runoff_voting"
                    room.votes.clear()
                    await room.broadcast({
                        "event": "phase_change", 
                        "phase": "runoff_voting", 
                        "duration": 10,
                        "message": "Tie detected. 10 second runoff vote."
                    })
                    await asyncio.sleep(10)
                    self._process_bot_votes(room)
                    exiled_player, _ = self._resolve_votes(room)
                    
                # 6. RESOLVE VOTING
                if exiled_player:
                    room.players[exiled_player].is_alive = False
                    await room.broadcast({
                        "event": "player_exiled",
                        "target": exiled_player,
                        "message": f"Player {exiled_player} was exiled by the town."
                    })
                    # Move exiled player to graveyard voice channel
                    dead_p = room.players.get(exiled_player)
                    if dead_p and not dead_p.is_bot:
                        await self._send_voice_channel(room, [dead_p], f"{room.room_id}_graveyard", "join_graveyard_voice")
                else:
                    await room.broadcast({"event": "system_message", "message": "The town skipped voting. No one was exiled."})
                    
                await asyncio.sleep(5)
                
                if await self._check_win_condition(room):
                    break

        except asyncio.CancelledError:
            logger.info(f"Game loop for {room.room_id} cancelled")
        except Exception as e:
            logger.error(f"Error in game loop {room.room_id}: {e}")
        finally:
            self.end_room(room.room_id)

    # --- HELPERS ---

    def _assign_roles(self, room: Room):
        players = list(room.players.values())
        random.shuffle(players)
        
        # 8 player setup: 2 Mafia, 1 Doctor, 1 Detective, 4 Civilians
        roles = ["mafia", "mafia", "doctor", "detective", "civilian", "civilian", "civilian", "civilian"]
        
        for i, p in enumerate(players):
            if i < len(roles):
                p.role = roles[i]
            else:
                p.role = "civilian"

    def _process_bot_night_actions(self, room: Room):
        # Bots make random decisions
        alive_ids = [p.user_id for p in room.get_alive_players()]
        if not alive_ids:
            return
            
        mafia_bots = [p for p in room.get_role_players("mafia") if p.is_bot]
        if mafia_bots and not room.night_actions["mafia_target"]:
            room.night_actions["mafia_target"] = random.choice(alive_ids)
            
        doctor_bots = [p for p in room.get_role_players("doctor") if p.is_bot]
        if doctor_bots and not room.night_actions["doctor_target"]:
            room.night_actions["doctor_target"] = random.choice(alive_ids)

    def _process_bot_votes(self, room: Room):
        alive_players = room.get_alive_players()
        alive_ids = [p.user_id for p in alive_players]
        
        for p in alive_players:
            if p.is_bot and p.user_id not in room.votes:
                # 50% chance to skip
                if random.random() > 0.5 and alive_ids:
                    room.votes[p.user_id] = random.choice(alive_ids)
                else:
                    room.votes[p.user_id] = "skip"

    def _resolve_night(self, room: Room) -> Optional[str]:
        target = room.night_actions["mafia_target"]
        save = room.night_actions["doctor_target"]
        
        if target and target != save:
            if target in room.players:
                room.players[target].is_alive = False
                return target
        return None

    def _resolve_votes(self, room: Room) -> tuple[Optional[str], bool]:
        if not room.votes:
            return None, False
            
        counts = {}
        for target in room.votes.values():
            if target != "skip":
                counts[target] = counts.get(target, 0) + 1
                
        if not counts:
            return None, False
            
        max_votes = max(counts.values())
        leaders = [t for t, c in counts.items() if c == max_votes]
        
        if len(leaders) > 1:
            return None, True # Tie
            
        return leaders[0], False

    async def _check_win_condition(self, room: Room) -> bool:
        from app.services.match_service import resolve_match_results
        alive_mafia = len(room.get_role_players("mafia"))
        alive_civs = len([p for p in room.get_alive_players() if p.role != "mafia"])
        
        if alive_mafia == 0:
            await room.broadcast({"event": "game_over", "winner": "civilians"})
            await resolve_match_results(list(room.players.values()), "civilians")
            return True
            
        if alive_mafia >= alive_civs:
            await room.broadcast({"event": "game_over", "winner": "mafia"})
            await resolve_match_results(list(room.players.values()), "mafia")
            return True
            
        return False

game_engine = GameEngine()
