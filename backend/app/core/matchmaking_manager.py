import asyncio
import logging
import uuid
import time
from typing import List, Dict, Any

from app.core.websocket_manager import manager as ws_manager

logger = logging.getLogger(__name__)

class PendingMatch:
    def __init__(self, match_id: str, mode: str, real_players: List[str], bots_needed: int):
        self.match_id = match_id
        self.mode = mode
        self.real_players = real_players
        self.bots_needed = bots_needed
        self.accepted_players = set()
        self.created_at = time.time()
        self.timeout = 10
        self.status = "waiting" # waiting, creating, completed

class MatchmakingManager:
    def __init__(self):
        # Queue format: list of dicts {"user_id": str, "join_time": float, "mode": str}
        self.queues: Dict[str, List[Dict[str, Any]]] = {
            "casual": [],
            "ranked": []
        }
        self.pending_matches: Dict[str, PendingMatch] = {}
        self.is_running = False
        self._loop_task = None
        self.PLAYERS_PER_ROOM = 8
        self.MAX_WAIT_TIME_SECONDS = 45

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
            
        # Check if user is already in a pending match. If so, don't re-queue.
        for match in self.pending_matches.values():
            if user_id in match.real_players:
                return

        self.queues[mode].append({
            "user_id": user_id,
            "join_time": time.time(),
            "mode": mode
        })
        logger.info(f"User {user_id} joined {mode} queue. Queue size: {len(self.queues[mode])}")
        
        # Broadcast initial queue update to everyone so they instantly see the new count
        self._broadcast_queue_update(mode)

    def leave_queue(self, user_id: str):
        # First check if user is in a pending match. If they leave now, the match is declined.
        for match_id in list(self.pending_matches.keys()):
            match = self.pending_matches[match_id]
            if user_id in match.real_players:
                asyncio.create_task(self.decline_match(user_id, match_id))
                return

        for mode in self.queues:
            original_size = len(self.queues[mode])
            self.queues[mode] = [p for p in self.queues[mode] if p["user_id"] != user_id]
            if len(self.queues[mode]) < original_size:
                self._broadcast_queue_update(mode)

    async def decline_match(self, user_id: str, match_id: str = None):
        if not match_id:
            for m_id, m in self.pending_matches.items():
                if user_id in m.real_players:
                    match_id = m_id
                    break
        
        if match_id in self.pending_matches:
            match = self.pending_matches[match_id]
            logger.info(f"Match {match_id} declined by user {user_id}. Cancelling match for everyone.")
            self._handle_failed_match(match)

    def _broadcast_queue_update(self, mode: str):
        queue = self.queues[mode]
        if not queue:
            return
            
        current_time = time.time()
        # Ensure all players see the SAME elapsed time and SAME players_in_queue count
        longest_waiting = max((current_time - p["join_time"]) for p in queue)
        elapsed_for_all = int(longest_waiting)
        queue_size = len(queue)
        
        update_event = {
            "event": "queue_update",
            "elapsed": elapsed_for_all,
            "estimated_wait": self.MAX_WAIT_TIME_SECONDS,
            "players_in_queue": queue_size
        }
        user_ids = [p["user_id"] for p in queue]
        asyncio.create_task(ws_manager.broadcast_to_group(update_event, user_ids))

    async def _matchmaking_loop(self):
        while self.is_running:
            try:
                await self._process_queues()
                await self._process_pending_matches()
            except Exception as e:
                logger.error(f"Error in matchmaking loop: {e}")
            await asyncio.sleep(2) # Run every 2 seconds

    async def _process_queues(self):
        for mode, queue in self.queues.items():
            if not queue:
                continue
                
            current_time = time.time()
            longest_waiting = max((current_time - p["join_time"]) for p in queue)
            
            # Broadcast queue sync
            self._broadcast_queue_update(mode)
            
            # If we have enough players, OR someone has waited too long and we have at least 1 player
            if len(queue) >= self.PLAYERS_PER_ROOM or longest_waiting > self.MAX_WAIT_TIME_SECONDS:
                self._create_pending_match(mode)

    def _create_pending_match(self, mode: str):
        queue = self.queues[mode]
        players_to_match = queue[:self.PLAYERS_PER_ROOM]
        
        # Remove from queue
        self.queues[mode] = queue[self.PLAYERS_PER_ROOM:]
        
        matched_users = [p["user_id"] for p in players_to_match]
        bots_needed = self.PLAYERS_PER_ROOM - len(matched_users)
        
        match_id = f"match_{uuid.uuid4().hex[:8]}"
        match = PendingMatch(match_id, mode, matched_users, bots_needed)
        self.pending_matches[match_id] = match
        
        logger.info(f"Created pending {mode} match {match_id} with players: {matched_users}")
        
        # We start the match creation sequence in a background task so it doesn't block the matchmaking loop
        asyncio.create_task(self._match_creation_sequence(match))

    async def _match_creation_sequence(self, match: PendingMatch):
        try:
            # Psychological immersion delays
            await ws_manager.broadcast_to_group({"event": "queue_status", "message": "Connecting to server..."}, match.real_players)
            await asyncio.sleep(1.5)
            await ws_manager.broadcast_to_group({"event": "queue_status", "message": "Balancing teams..."}, match.real_players)
            await asyncio.sleep(1.5)
            
            # Broadcast match found to real players - requires Acceptance
            match_event = {
                "event": "match_found",
                "match_id": match.match_id,
                "lobby_id": match.match_id, # Frontend expects lobby_id
                "mode": match.mode,
                "timeout": match.timeout
            }
            await ws_manager.broadcast_to_group(match_event, match.real_players)
            
            # Also send initial match_status
            status_event = {
                "event": "match_status",
                "match_id": match.match_id,
                "accepted": 0,
                "total": len(match.real_players)
            }
            await ws_manager.broadcast_to_group(status_event, match.real_players)
            
        except Exception as e:
            logger.error(f"Error in match creation sequence for {match.match_id}: {e}")
            
    async def accept_match(self, user_id: str, match_id: str):
        # Allow fallback to checking pending matches if match_id is not passed
        if not match_id:
            for m_id, m in self.pending_matches.items():
                if user_id in m.real_players:
                    match_id = m_id
                    break
                    
        if match_id in self.pending_matches:
            match = self.pending_matches[match_id]
            if user_id in match.real_players:
                match.accepted_players.add(user_id)
                logger.info(f"User {user_id} accepted match {match_id}")
                
                # Broadcast updated status
                status_event = {
                    "event": "match_status",
                    "match_id": match.match_id,
                    "accepted": len(match.accepted_players),
                    "total": len(match.real_players),
                    "accepted_players": list(match.accepted_players)
                }
                await ws_manager.broadcast_to_group(status_event, match.real_players)

    async def _process_pending_matches(self):
        current_time = time.time()
        completed_matches = []
        failed_matches = []
        
        for match_id, match in self.pending_matches.items():
            if match.status != "waiting":
                continue
                
            all_accepted = len(match.accepted_players) == len(match.real_players)
            timed_out = (current_time - match.created_at) > match.timeout + 3 # 3 sec buffer for intro delays
            
            if all_accepted:
                match.status = "creating"
                completed_matches.append(match)
            elif timed_out:
                match.status = "failed"
                failed_matches.append(match)
                
        for match in completed_matches:
            asyncio.create_task(self._start_match(match))
            
        for match in failed_matches:
            self._handle_failed_match(match)

    async def _start_match(self, match: PendingMatch):
        try:
            bot_ids = [f"bot_{uuid.uuid4().hex[:6]}" for _ in range(match.bots_needed)]
            all_players = match.real_players + bot_ids
            lobby_id = match.match_id
            
            from app.core.game_engine import game_engine
            await game_engine.create_room(lobby_id, all_players)
            
            # Tell clients to enter the room
            await ws_manager.broadcast_to_group({"event": "room_joined", "room_id": lobby_id}, match.real_players)
        except Exception as e:
            logger.error(f"Error starting match {match.match_id}: {e}")
        finally:
            if match.match_id in self.pending_matches:
                del self.pending_matches[match.match_id]

    def _handle_failed_match(self, match: PendingMatch):
        # Re-queue players who accepted
        for user_id in match.accepted_players:
            self.join_queue(user_id, match.mode)
            
        # Inform players who didn't accept
        declined_players = [u for u in match.real_players if u not in match.accepted_players]
        if declined_players:
            asyncio.create_task(ws_manager.broadcast_to_group({"event": "match_declined"}, declined_players))
            
        if match.match_id in self.pending_matches:
            del self.pending_matches[match.match_id]

    def get_user_state(self, user_id: str) -> Dict[str, Any]:
        # Check if in a pending match
        for match_id, match in self.pending_matches.items():
            if user_id in match.real_players:
                return {
                    "event": "match_found",
                    "match_id": match.match_id,
                    "lobby_id": match.match_id,
                    "mode": match.mode,
                    "status": match.status,
                    "accepted": len(match.accepted_players),
                    "total": len(match.real_players),
                    "is_accepted": user_id in match.accepted_players
                }
        
        # Check if in queue
        for mode, queue in self.queues.items():
            for p in queue:
                if p["user_id"] == user_id:
                    current_time = time.time()
                    elapsed = int(current_time - p["join_time"])
                    return {
                        "event": "queue_update",
                        "mode": mode,
                        "elapsed": elapsed,
                        "estimated_wait": self.MAX_WAIT_TIME_SECONDS,
                        "players_in_queue": len(queue)
                    }
                    
        return {"event": "idle"}

matchmaker = MatchmakingManager()
