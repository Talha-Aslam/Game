import asyncio
import logging
import random
import uuid
from typing import Dict, List, Optional
from pydantic import BaseModel
from app.core.websocket_manager import manager as ws_manager
from app.config.database import get_database

logger = logging.getLogger(__name__)

# Names to use for bots
BOT_NAMES = ['ShadowKing', 'NightViper', 'IronFist', 'GhostWalker', 'RedPhantom', 'DarkOracle', 'SilverBlade', 'CrimsonEye', 'SilentWolf', 'BloodRaven']

class Player(BaseModel):
    user_id: str
    is_bot: bool = False
    name: str = ""
    role: Optional[str] = None
    rankTier: int = 1
    familyTag: Optional[str] = None
    avatarIndex: int = 0
    
    # State flags
    status: str = "alive" # alive, eliminated
    is_alive: bool = True
    is_eliminating: bool = False
    voice_state: str = "idle" # idle, speaking, muted
    
    def to_dict(self):
        return {
            "id": self.user_id,
            "name": self.name,
            "role": self.role,
            "rankTier": self.rankTier,
            "familyTag": self.familyTag,
            "avatarIndex": self.avatarIndex,
            "status": self.status,
            "isEliminating": self.is_eliminating,
            "voiceState": self.voice_state
        }

class Room:
    def __init__(self, room_id: str, player_ids: List[str]):
        self.room_id = room_id
        self.players: Dict[str, Player] = {}
        # Will be populated with Player objects after fetching from DB
        
        self.state = "lobby"
        self.day_number = 0
        self.task: Optional[asyncio.Task] = None
        
        # Night actions
        self.night_actions = {
            "mafia_target": None,
            "doctor_target": None,
            "detective_target": None,
            "detective_result": None
        }
        
        # Votes
        self.votes: Dict[str, str] = {} # voter_id -> target_id
        self.tied_players: List[str] = []
        
    def get_alive_players(self) -> List[Player]:
        return [p for p in self.players.values() if p.is_alive]
        
    def get_role_players(self, role: str) -> List[Player]:
        return [p for p in self.players.values() if p.is_alive and p.role == role]
        
    async def broadcast(self, message: dict):
        alive_ids = [p.user_id for p in self.players.values() if not p.is_bot]
        if alive_ids:
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
        
        # 1. Fetch real player data from DB and setup bots
        db = get_database()
        real_player_ids = [pid for pid in player_ids if not pid.startswith("bot_")]
        real_users = []
        if real_player_ids and db is not None:
            real_users = await db.users.find({"_id": {"$in": real_player_ids}}).to_list(length=None)
            
        user_dict = {str(u["_id"]): u for u in real_users}
        
        bot_idx = 0
        for pid in player_ids:
            if pid.startswith("bot_"):
                # Inject mock data for bot
                bot_name = BOT_NAMES[bot_idx % len(BOT_NAMES)]
                bot_idx += 1
                room.players[pid] = Player(
                    user_id=pid,
                    is_bot=True,
                    name=f"{bot_name} (Bot)",
                    rankTier=random.randint(1, 5),
                    familyTag=random.choice(["[BOTS]", "[AI]", None]),
                    avatarIndex=random.randint(0, 9)
                )
            else:
                user_data = user_dict.get(pid, {})
                room.players[pid] = Player(
                    user_id=pid,
                    is_bot=False,
                    name=user_data.get("username", f"Player_{pid[:4]}"),
                    rankTier=1, # Could map from MMR
                    familyTag=None, # Could fetch from family DB
                    avatarIndex=random.randint(0, 9) # Could map from premium_avatar
                )

        # Start autonomous game loop
        room.task = asyncio.create_task(self._game_loop(room))
        logger.info(f"Room {room_id} loop started with {len(room.players)} players")

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
        target = action.get("targetId")
        
        if room.state == "night_mafia" and action_type == "mafia_action" and player.role == "mafia":
            room.night_actions["mafia_target"] = target
        elif room.state == "night_doctor" and action_type == "doctor_action" and player.role == "doctor":
            room.night_actions["doctor_target"] = target
        elif room.state == "night_detective" and action_type == "detective_action" and player.role == "detective":
            room.night_actions["detective_target"] = target
            
            target_p = room.players.get(target)
            if target_p:
                is_mafia = target_p.role == "mafia"
                room.night_actions["detective_result"] = is_mafia
                # Private result to detective immediately
                asyncio.create_task(
                    ws_manager.send_personal_message({
                        "event": "investigation_result",
                        "data": {
                            "targetId": target,
                            "targetName": target_p.name,
                            "isMafia": is_mafia
                        }
                    }, user_id)
                )
                
        elif room.state in ["voting", "runoff"] and action_type == "submit_vote":
            room.votes[user_id] = target
            
        elif action_type == "leave_lobby":
            # For now just disconnect them from voice? Or ignore, let ws handle disconnect
            pass

    async def _send_voice_channel(self, room: Room, players: List[Player], channel_name: str, event: str = "join_main_voice"):
        from app.services.agora_service import generate_rtc_token_with_account
        for p in players:
            if not p.is_bot:
                try:
                    token = generate_rtc_token_with_account(channel_name=channel_name, account=p.user_id)
                    await ws_manager.send_personal_message({
                        "event": event,
                        "data": {
                            "channel": channel_name,
                            "token": token
                        }
                    }, p.user_id)
                except Exception as e:
                    logger.error(f"Failed to generate voice token for {p.user_id}: {e}")

    async def _broadcast_state(self, room: Room, event: str, extra_data: dict = None):
        players_list = [p.to_dict() for p in room.players.values()]
        
        # Send customized personal state
        for pid, p in room.players.items():
            if not p.is_bot:
                payload = {
                    "players": players_list,
                    "localPlayerId": pid
                }
                if extra_data:
                    payload.update(extra_data)
                    
                asyncio.create_task(
                    ws_manager.send_personal_message({
                        "event": event,
                        "data": payload
                    }, pid)
                )

    # --- AUTONOMOUS GAME LOOP ---
    async def _game_loop(self, room: Room):
        try:
            # 1. LOBBY PHASE
            room.state = "lobby"
            await self._broadcast_state(room, "lobby_update", {"status": "connected"})
            
            # 10s countdown
            for remaining in range(10, 0, -1):
                await room.broadcast({
                    "event": "lobby_countdown",
                    "data": {
                        "remaining": remaining,
                        "tickingActive": remaining <= 5
                    }
                })
                await asyncio.sleep(1)
            
            # Show Begins Cinematic
            await room.broadcast({"event": "show_begins", "data": {}})
            await asyncio.sleep(2)
            
            # Assign Roles
            self._assign_roles(room)
            room.state = "roleAssignment"
            
            for pid, p in room.players.items():
                if not p.is_bot:
                    await ws_manager.send_personal_message({
                        "event": "role_assigned",
                        "data": {
                            "role": p.role,
                            "players": [p2.to_dict() for p2 in room.players.values()],
                            "localPlayerId": pid
                        }
                    }, pid)
            
            # 10s role reveal countdown
            for remaining in range(10, 0, -1):
                await room.broadcast({"event": "timer_tick", "data": {"remaining": remaining}})
                await asyncio.sleep(1)
            
            while True:
                room.day_number += 1
                
                # 2. NIGHT PHASE (Sequential)
                room.state = "night"
                room.night_actions = {"mafia_target": None, "doctor_target": None, "detective_target": None, "detective_result": None}
                
                await room.broadcast({
                    "event": "phase_change", 
                    "data": {
                        "phase": "night",
                        "duration": 40 # 20 + 10 + 10
                    }
                })
                
                # 2a. Mafia (20s)
                room.state = "night_mafia"
                await room.broadcast({
                    "event": "night_sub_phase",
                    "data": {
                        "subPhase": "mafiaActing",
                        "duration": 20,
                        "activeRole": "mafia"
                    }
                })
                await room.broadcast({"event": "mafia_channel", "data": {"open": True}})
                
                for remaining in range(20, 0, -1):
                    await room.broadcast({"event": "timer_tick", "data": {"remaining": remaining}})
                    await asyncio.sleep(1)
                
                await room.broadcast({"event": "mafia_channel", "data": {"open": False}})
                
                # Bot fallback
                if not room.night_actions["mafia_target"]:
                    self._process_bot_night_action(room, "mafia")

                # 2b. Doctor (10s)
                room.state = "night_doctor"
                await room.broadcast({
                    "event": "night_sub_phase",
                    "data": {
                        "subPhase": "doctorActing",
                        "duration": 10,
                        "activeRole": "doctor"
                    }
                })
                for remaining in range(10, 0, -1):
                    await room.broadcast({"event": "timer_tick", "data": {"remaining": remaining}})
                    await asyncio.sleep(1)
                
                if not room.night_actions["doctor_target"]:
                    self._process_bot_night_action(room, "doctor")

                # 2c. Detective (10s)
                room.state = "night_detective"
                await room.broadcast({
                    "event": "night_sub_phase",
                    "data": {
                        "subPhase": "detectiveActing",
                        "duration": 10,
                        "activeRole": "detective"
                    }
                })
                for remaining in range(10, 0, -1):
                    await room.broadcast({"event": "timer_tick", "data": {"remaining": remaining}})
                    await asyncio.sleep(1)
                
                if not room.night_actions["detective_target"]:
                    self._process_bot_night_action(room, "detective")
                
                # 3. DAWN PHASE
                room.state = "morningReveal"
                killed_player, saved = self._resolve_night(room)
                
                victim_name = None
                if killed_player and killed_player in room.players:
                    victim_name = room.players[killed_player].name
                    
                msg = 'The Syndicate attempted a hit, but no one died last night.' if saved else f'The city wakes up to a tragedy. {victim_name} was eliminated.'
                if not killed_player and not saved:
                     msg = 'The city was eerily quiet. No one was eliminated.'
                
                await room.broadcast({
                    "event": "dawn_announce",
                    "data": {
                        "message": msg,
                        "saved": saved,
                        "victimName": victim_name
                    }
                })
                
                await room.broadcast({
                    "event": "phase_change",
                    "data": {
                        "phase": "morningReveal",
                        "duration": 5,
                        "morningMessage": msg
                    }
                })
                
                await asyncio.sleep(2)
                
                if killed_player and not saved:
                    # Elimination animation
                    room.players[killed_player].status = "eliminated"
                    room.players[killed_player].is_alive = False
                    room.players[killed_player].voice_state = "muted"
                    
                    await room.broadcast({
                        "event": "player_eliminated",
                        "data": {
                            "playerId": killed_player,
                            "playerName": victim_name
                        }
                    })
                    
                await asyncio.sleep(3) # Rest of dawn
                
                if await self._check_win_condition(room):
                    break
                    
                # 4. DAY DISCUSSION
                room.state = "day"
                await room.broadcast({
                    "event": "phase_change", 
                    "data": {
                        "phase": "day",
                        "duration": 60
                    }
                })
                
                for remaining in range(60, 0, -1):
                    await room.broadcast({"event": "timer_tick", "data": {"remaining": remaining}})
                    await asyncio.sleep(1)
                
                # 5. VOTING PHASE
                room.state = "voting"
                room.votes.clear()
                await room.broadcast({
                    "event": "phase_change", 
                    "data": {
                        "phase": "voting",
                        "duration": 10
                    }
                })
                
                for remaining in range(10, 0, -1):
                    await room.broadcast({"event": "timer_tick", "data": {"remaining": remaining}})
                    await asyncio.sleep(1)
                
                self._process_bot_votes(room)
                exiled_player, is_tie = self._resolve_votes(room)
                
                if is_tie:
                    # TIE RUNOFF VOTE
                    room.state = "runoff"
                    room.votes.clear()
                    await room.broadcast({
                        "event": "runoff_triggered",
                        "data": {
                            "tiedPlayers": room.tied_players
                        }
                    })
                    await room.broadcast({
                        "event": "phase_change", 
                        "data": {
                            "phase": "runoff",
                            "duration": 10
                        }
                    })
                    
                    for remaining in range(10, 0, -1):
                        await room.broadcast({"event": "timer_tick", "data": {"remaining": remaining}})
                        await asyncio.sleep(1)
                        
                    self._process_bot_votes(room, only_from_tied=True)
                    exiled_player, _ = self._resolve_votes(room)
                    
                # 6. RESOLVE VOTING
                if exiled_player:
                    room.players[exiled_player].status = "eliminated"
                    room.players[exiled_player].is_alive = False
                    room.players[exiled_player].voice_state = "muted"
                    
                    p_name = room.players[exiled_player].name
                    p_role = room.players[exiled_player].role
                    await room.broadcast({
                        "event": "player_eliminated",
                        "data": {
                            "playerId": exiled_player,
                            "playerName": p_name,
                            "role": p_role
                        }
                    })
                
                # We need an elimination phase duration to let the animation play
                room.state = "elimination"
                await room.broadcast({
                    "event": "phase_change", 
                    "data": {
                        "phase": "elimination",
                        "duration": 3
                    }
                })
                await asyncio.sleep(3)
                
                if await self._check_win_condition(room):
                    break

        except asyncio.CancelledError:
            logger.info(f"Game loop for {room.room_id} cancelled")
        except Exception as e:
            logger.error(f"Error in game loop {room.room_id}: {e}", exc_info=True)
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

    def _process_bot_night_action(self, room: Room, role: str):
        alive_civs = [p.user_id for p in room.get_alive_players() if p.role != "mafia"]
        alive_ids = [p.user_id for p in room.get_alive_players()]
        if not alive_ids:
            return
            
        bots_of_role = [p for p in room.get_role_players(role) if p.is_bot]
        if not bots_of_role:
            return
            
        if role == "mafia" and not room.night_actions["mafia_target"]:
            # Mafia bot attacks a random civilian
            if alive_civs:
                room.night_actions["mafia_target"] = random.choice(alive_civs)
        elif role == "doctor" and not room.night_actions["doctor_target"]:
            # Doctor heals a random alive player
            room.night_actions["doctor_target"] = random.choice(alive_ids)
        elif role == "detective" and not room.night_actions["detective_target"]:
            # Detective investigates a random alive non-detective
            targets = [pid for pid in alive_ids if room.players[pid].role != "detective"]
            if targets:
                room.night_actions["detective_target"] = random.choice(targets)

    def _process_bot_votes(self, room: Room, only_from_tied=False):
        alive_players = room.get_alive_players()
        alive_ids = [p.user_id for p in alive_players]
        
        possible_targets = room.tied_players if (only_from_tied and room.tied_players) else alive_ids
        
        for p in alive_players:
            if p.is_bot and p.user_id not in room.votes:
                if random.random() > 0.3 and possible_targets:
                    # Don't vote for self
                    others = [t for t in possible_targets if t != p.user_id]
                    if others:
                        room.votes[p.user_id] = random.choice(others)
                    else:
                        room.votes[p.user_id] = "skip"
                else:
                    room.votes[p.user_id] = "skip"

    def _resolve_night(self, room: Room) -> tuple[Optional[str], bool]:
        target = room.night_actions["mafia_target"]
        save = room.night_actions["doctor_target"]
        
        if not target:
            return None, False
            
        if target == save:
            return None, True # Saved
            
        return target, False # Killed

    def _resolve_votes(self, room: Room) -> tuple[Optional[str], bool]:
        # Broadcast votes revealed before resolving
        asyncio.create_task(room.broadcast({
            "event": "votes_revealed",
            "data": {
                "votes": room.votes
            }
        }))
        
        counts = {}
        for target in room.votes.values():
            if target != "skip":
                counts[target] = counts.get(target, 0) + 1
                
        if not counts:
            return None, False
            
        max_votes = max(counts.values())
        leaders = [t for t, c in counts.items() if c == max_votes]
        
        if len(leaders) > 1:
            room.tied_players = leaders
            return None, True # Tie
            
        return leaders[0], False

    async def _check_win_condition(self, room: Room) -> bool:
        alive_mafia = len(room.get_role_players("mafia"))
        alive_civs = len([p for p in room.get_alive_players() if p.role != "mafia"])
        
        winner = None
        if alive_mafia == 0:
            winner = "civilians"
        elif alive_mafia >= alive_civs:
            winner = "mafia"
            
        if winner:
            # Send game result
            alive = room.get_alive_players()
            mvp_id = alive[0].user_id if alive else room.players.keys()[0]
            
            await room.broadcast({
                "event": "game_result",
                "data": {
                    "winner": winner,
                    "xpGained": 150,
                    "rankDelta": 15 if winner == "civilians" else -10,
                    "bpXpGained": 80,
                    "influenceGained": 25,
                    "popularityGained": 5,
                    "mvpPlayerId": mvp_id,
                    "players": [p.to_dict() for p in room.players.values()]
                }
            })
            # Also call resolve_match_results to update DB later
            from app.services.match_service import resolve_match_results
            await resolve_match_results(list(room.players.values()), winner)
            return True
            
        return False

game_engine = GameEngine()
