import asyncio
import logging
import uuid
from typing import Dict, List, Any, Optional
from app.core.websocket_manager import manager as ws_manager

logger = logging.getLogger(__name__)

class CustomRoom:
    def __init__(self, room_id: str, creator_id: str, mode: str = "Standard"):
        self.room_id = room_id
        self.creator_id = creator_id
        self.mode = mode
        self.players: List[str] = [creator_id]
        self.invited_ids: List[str] = []
        self.max_players = 15
        self.is_started = False

    def to_dict(self):
        return {
            "room_id": self.room_id,
            "creator_id": self.creator_id,
            "mode": self.mode,
            "players": self.players,
            "max_players": self.max_players,
            "is_started": self.is_started
        }

class CustomRoomManager:
    def __init__(self):
        self.active_rooms: Dict[str, CustomRoom] = {}
        self.user_to_room: Dict[str, str] = {}

    def create_room(self, creator_id: str, mode: str = "Custom") -> CustomRoom:
        # If user is in a room, leave it
        if creator_id in self.user_to_room:
            self.leave_room(creator_id)

        room_id = f"custom_{uuid.uuid4().hex[:8]}"
        room = CustomRoom(room_id, creator_id, mode)
        self.active_rooms[room_id] = room
        self.user_to_room[creator_id] = room_id
        return room

    def join_room(self, user_id: str, room_id: str) -> Optional[CustomRoom]:
        if room_id not in self.active_rooms:
            return None
            
        room = self.active_rooms[room_id]
        if len(room.players) >= room.max_players or room.is_started:
            return None

        if user_id not in room.players:
            room.players.append(user_id)
            self.user_to_room[user_id] = room_id
            
        return room

    def leave_room(self, user_id: str):
        if user_id not in self.user_to_room:
            return
            
        room_id = self.user_to_room[user_id]
        if room_id in self.active_rooms:
            room = self.active_rooms[room_id]
            room.players = [p for p in room.players if p != user_id]
            
            if not room.players:
                del self.active_rooms[room_id]
            elif user_id == room.creator_id:
                room.creator_id = room.players[0]
                
        del self.user_to_room[user_id]

    async def start_match(self, user_id: str, room_id: str):
        if room_id not in self.active_rooms:
            return
            
        room = self.active_rooms[room_id]
        if user_id != room.creator_id:
            return
            
        if len(room.players) < 5:
            # Maybe allow start with bots? For now just check min players
            pass
            
        room.is_started = True
        
        # Transition to game engine
        from app.core.game_engine import game_engine
        await game_engine.create_room(room_id, room.players, room_type="Custom")
        
        # Broadcast to all players
        await ws_manager.broadcast_to_group({
            "event": "room_joined",
            "room_id": room_id
        }, room.players)
        
        # Cleanup custom room entry
        for p in room.players:
            if p in self.user_to_room:
                del self.user_to_room[p]
        del self.active_rooms[room_id]

    async def get_room_payload(self, room_id: str) -> Optional[dict]:
        if room_id not in self.active_rooms:
            return None
        room = self.active_rooms[room_id]
        
        from app.config.database import get_database
        db = get_database()
        
        users = await db["users"].find({"_id": {"$in": room.players}}).to_list(length=room.max_players)
        user_dict = {str(u["_id"]): u for u in users}
        
        players_data = []
        for pid in room.players:
            u = user_dict.get(pid, {})
            players_data.append({
                "id": pid,
                "name": u.get("username", f"Player {pid[:4]}"),
                "avatarUrl": u.get("profile_picture", ""),
                "equippedCosmetics": u.get("equipped_cosmetics", {}),
                "rankTier": u.get("rankTier", 1) # Fallback if missing
            })
            
        return {
            "room_id": room.room_id,
            "creator_id": room.creator_id,
            "mode": room.mode,
            "players": players_data,
            "max_players": room.max_players,
            "is_started": room.is_started
        }

custom_room_manager = CustomRoomManager()
