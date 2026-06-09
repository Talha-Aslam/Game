import asyncio
import logging
import uuid
from typing import Dict, List, Any, Optional

logger = logging.getLogger(__name__)

class FamilyWarRoom:
    def __init__(self, room_id: str, creator_id: str, challenger_family_id: str, defender_family_id: Optional[str] = None):
        self.room_id = room_id
        self.creator_id = creator_id
        self.challenger_family_id = challenger_family_id
        self.defender_family_id = defender_family_id
        
        self.challenger_roster: List[str] = [creator_id]
        self.defender_roster: List[str] = []
        self.max_team_size = 7
        self.is_started = False

    def get_all_players(self) -> List[str]:
        return self.challenger_roster + self.defender_roster

class FamilyWarManager:
    def __init__(self):
        self.active_wars: Dict[str, FamilyWarRoom] = {}
        self.user_to_war: Dict[str, str] = {}

    async def create_war_lobby(self, creator_id: str, challenger_family_id: str, defender_family_id: Optional[str] = None) -> FamilyWarRoom:
        if creator_id in self.user_to_war:
            self.leave_war_lobby(creator_id)

        room_id = f"war_{uuid.uuid4().hex[:8]}"
        room = FamilyWarRoom(room_id, creator_id, challenger_family_id, defender_family_id)
        self.active_wars[room_id] = room
        self.user_to_war[creator_id] = room_id
        return room

    def join_war_lobby(self, user_id: str, room_id: str, is_defender: bool = False) -> Optional[FamilyWarRoom]:
        if room_id not in self.active_wars:
            return None
            
        room = self.active_wars[room_id]
        if room.is_started:
            return None

        if user_id in room.get_all_players():
            return room

        target_roster = room.defender_roster if is_defender else room.challenger_roster
        if len(target_roster) >= room.max_team_size:
            return None

        target_roster.append(user_id)
        self.user_to_war[user_id] = room_id
        return room

    def leave_war_lobby(self, user_id: str):
        if user_id not in self.user_to_war:
            return
            
        room_id = self.user_to_war[user_id]
        if room_id in self.active_wars:
            room = self.active_wars[room_id]
            
            if user_id in room.challenger_roster:
                room.challenger_roster.remove(user_id)
            if user_id in room.defender_roster:
                room.defender_roster.remove(user_id)
            
            if not room.challenger_roster and not room.defender_roster:
                del self.active_wars[room_id]
            elif user_id == room.creator_id and room.challenger_roster:
                room.creator_id = room.challenger_roster[0]
                
        del self.user_to_war[user_id]

    async def get_war_payload(self, room_id: str) -> Optional[dict]:
        if room_id not in self.active_wars:
            return None
        room = self.active_wars[room_id]
        
        from app.config.database import get_database
        db = get_database()
        
        all_players = room.get_all_players()
        users = await db["users"].find({"_id": {"$in": all_players}}).to_list(length=14)
        user_dict = {str(u["_id"]): u for u in users}
        
        def format_roster(roster_ids):
            data = []
            for pid in roster_ids:
                u = user_dict.get(pid, {})
                data.append({
                    "id": pid,
                    "name": u.get("username", f"Player {pid[:4]}"),
                    "avatarUrl": u.get("profile_picture", ""),
                    "equippedCosmetics": u.get("equipped_cosmetics", {}),
                    "rankTier": u.get("rankTier", 1)
                })
            return data
            
        return {
            "room_id": room.room_id,
            "creator_id": room.creator_id,
            "challenger_family_id": room.challenger_family_id,
            "defender_family_id": room.defender_family_id,
            "challenger_roster": format_roster(room.challenger_roster),
            "defender_roster": format_roster(room.defender_roster),
            "max_team_size": room.max_team_size,
            "is_started": room.is_started
        }

    async def start_war(self, user_id: str, room_id: str):
        if room_id not in self.active_wars:
            return
            
        room = self.active_wars[room_id]
        if user_id != room.creator_id:
            return
            
        room.is_started = True
        
        from app.core.game_engine import game_engine
        from app.core.websocket_manager import manager as ws_manager
        
        # Combine rosters and start game
        all_players = room.get_all_players()
        await game_engine.create_room(room_id, all_players, room_type="FamilyWar")
        
        await ws_manager.broadcast_to_group({
            "event": "room_joined",
            "room_id": room_id
        }, all_players)
        
        for p in all_players:
            if p in self.user_to_war:
                del self.user_to_war[p]
        del self.active_wars[room_id]

family_war_manager = FamilyWarManager()
