import asyncio
import uuid
import time
from typing import Dict, List, Any
from app.schemas.match_schema import LobbySchema, MatchPlayer

# In-memory queue pools
queue_pools: Dict[str, List[Dict[str, Any]]] = {
    "ranked": []
}

# Live lobbies
active_lobbies: Dict[str, LobbySchema] = {}

# User connection tracking
# user_id -> websocket
user_connections: Dict[str, Any] = {}

# Keep track of when a user started queueing
queue_start_times: Dict[str, float] = {}

class MatchmakingService:
    def __init__(self):
        self.is_running = False

    async def add_to_queue(self, user_id: str, game_mode: str, player_data: MatchPlayer):
        if user_id in [u["user_id"] for u in queue_pools[game_mode]]:
            return # Already in queue

        queue_pools[game_mode].append({
            "user_id": user_id,
            "player": player_data
        })
        queue_start_times[user_id] = time.time()
        await self._notify_queue_status(user_id, game_mode)

    async def remove_from_queue(self, user_id: str):
        for mode in queue_pools:
            queue_pools[mode] = [u for u in queue_pools[mode] if u["user_id"] != user_id]
        if user_id in queue_start_times:
            del queue_start_times[user_id]

    async def _notify_queue_status(self, user_id: str, game_mode: str):
        ws = user_connections.get(user_id)
        if ws:
            elapsed = int(time.time() - queue_start_times.get(user_id, time.time()))
            await ws.send_json({
                "event": "queue_update",
                "data": {
                    "elapsed": elapsed,
                    "estimated_wait": 15, # Mock 15s wait
                    "players_in_queue": len(queue_pools[game_mode])
                }
            })

    async def _matchmaking_loop(self):
        while self.is_running:
            await asyncio.sleep(2) # Process every 2 seconds
            
            for mode, pool in queue_pools.items():
                if len(pool) >= 2: # Match found! Let's trigger it for 2+ players for demo, usually 15
                    # Pop players
                    matched_players = pool[:15]
                    queue_pools[mode] = pool[15:]
                    
                    lobby_id = str(uuid.uuid4())
                    players_list = [m["player"] for m in matched_players]
                    
                    lobby = LobbySchema(
                        lobby_id=lobby_id,
                        game_mode=mode,
                        status="match_found",
                        players=players_list
                    )
                    active_lobbies[lobby_id] = lobby

                    # Notify players "Match Found!"
                    for mp in matched_players:
                        uid = mp["user_id"]
                        if uid in queue_start_times:
                            del queue_start_times[uid]
                            
                        ws = user_connections.get(uid)
                        if ws:
                            # Send realistic delay "Connecting..." -> "Balancing..." -> "Match Found!"
                            asyncio.create_task(self._send_match_found_sequence(ws, lobby_id))

    async def _send_match_found_sequence(self, ws, lobby_id: str):
        # Psychological immersion delays
        await ws.send_json({"event": "queue_status", "message": "Connecting to server..."})
        await asyncio.sleep(1.5)
        await ws.send_json({"event": "queue_status", "message": "Balancing teams..."})
        await asyncio.sleep(1.5)
        await ws.send_json({
            "event": "match_found",
            "data": {
                "lobby_id": lobby_id,
                "timeout": 10
            }
        })

    def start(self):
        if not self.is_running:
            self.is_running = True
            asyncio.create_task(self._matchmaking_loop())

    def stop(self):
        self.is_running = False

matchmaking_service = MatchmakingService()
