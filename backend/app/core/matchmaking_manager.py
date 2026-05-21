import asyncio
import logging
import uuid
import time
from typing import List, Dict, Any

from app.core.websocket_manager import manager as ws_manager
# We will import GameEngine later when we build it
# from app.core.game_engine import game_engine

logger = logging.getLogger(__name__)

class MatchmakingManager:
    def __init__(self):
        # Queue format: list of dicts {"user_id": str, "join_time": float, "mode": str}
        self.queues: Dict[str, List[Dict[str, Any]]] = {
            "casual": [],
            "ranked": []
        }
        self.is_running = False
        self._loop_task = None
        self.PLAYERS_PER_ROOM = 8
        self.MAX_WAIT_TIME_SECONDS = 15

    def start(self):
        if not self.is_running:
            self.is_running = True
            self._loop_task = asyncio.create_task(self._matchmaking_loop())
            logger.info("Matchmaking engine started")

    def stop(self):
        self.is_running = False
        if self._loop_task:
            self._loop_task.cancel()
            logger.info("Matchmaking engine stopped")

    def join_queue(self, user_id: str, mode: str = "casual"):
        if mode not in self.queues:
            mode = "casual"
            
        # Check if already in queue
        if any(p["user_id"] == user_id for p in self.queues[mode]):
            return
            
        self.queues[mode].append({
            "user_id": user_id,
            "join_time": time.time(),
            "mode": mode
        })
        logger.info(f"User {user_id} joined {mode} queue. Queue size: {len(self.queues[mode])}")

    def leave_queue(self, user_id: str):
        for mode in self.queues:
            self.queues[mode] = [p for p in self.queues[mode] if p["user_id"] != user_id]

    async def _matchmaking_loop(self):
        while self.is_running:
            try:
                await self._process_queues()
            except Exception as e:
                logger.error(f"Error in matchmaking loop: {e}")
            await asyncio.sleep(2) # Run every 2 seconds

    async def _process_queues(self):
        for mode, queue in self.queues.items():
            if not queue:
                continue
                
            current_time = time.time()
            
            # Find players waiting too long
            longest_waiting = max((current_time - p["join_time"]) for p in queue)
            
            # If we have 8 players, OR someone has waited too long and we have at least 1 player
            if len(queue) >= self.PLAYERS_PER_ROOM or longest_waiting > self.MAX_WAIT_TIME_SECONDS:
                await self._create_match(mode)

    async def _create_match(self, mode: str):
        queue = self.queues[mode]
        # Take up to 8 players
        players_to_match = queue[:self.PLAYERS_PER_ROOM]
        
        # Remove from queue
        self.queues[mode] = queue[self.PLAYERS_PER_ROOM:]
        
        matched_users = [p["user_id"] for p in players_to_match]
        
        # Fill with bots if needed
        bots_needed = self.PLAYERS_PER_ROOM - len(matched_users)
        bot_ids = [f"bot_{uuid.uuid4().hex[:6]}" for _ in range(bots_needed)]
        
        all_players = matched_users + bot_ids
        room_id = f"room_{uuid.uuid4().hex[:8]}"
        
        logger.info(f"Created {mode} match {room_id} with players: {matched_users} and {bots_needed} bots")
        
        # TODO: Initialize game state in GameEngine
        from app.core.game_engine import game_engine
        await game_engine.create_room(room_id, all_players)
        
        # Broadcast match found to real players
        match_event = {
            "event": "match_found",
            "room_id": room_id,
            "mode": mode,
            "players": all_players
        }
        await ws_manager.broadcast_to_group(match_event, matched_users)

matchmaker = MatchmakingManager()
