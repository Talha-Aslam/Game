import json
import logging
from typing import Dict
from fastapi import WebSocket

logger = logging.getLogger(__name__)

class ConnectionManager:
    def __init__(self):
        # Maps user_id -> WebSocket
        self.active_connections: Dict[str, WebSocket] = {}

    async def connect(self, user_id: str, websocket: WebSocket):
        await websocket.accept()
        # If user is already connected from another device, we could close the old one
        if user_id in self.active_connections:
            old_ws = self.active_connections[user_id]
            try:
                await old_ws.close(code=1008, reason="Connected from another location")
            except Exception:
                pass
                
        self.active_connections[user_id] = websocket
        logger.info(f"User {user_id} connected. Total: {len(self.active_connections)}")
        
        # Broadcast presence change to friends could go here

    def disconnect(self, user_id: str, websocket: WebSocket = None):
        if user_id in self.active_connections:
            # Only remove if the disconnecting websocket is the current one
            if websocket is None or self.active_connections[user_id] == websocket:
                del self.active_connections[user_id]
                logger.info(f"User {user_id} disconnected. Total: {len(self.active_connections)}")

    async def send_personal_message(self, message: dict, user_id: str):
        if user_id in self.active_connections:
            ws = self.active_connections[user_id]
            try:
                await ws.send_json(message)
            except Exception as e:
                logger.error(f"Error sending message to {user_id}: {e}")
                self.disconnect(user_id)

    async def broadcast(self, message: dict):
        dead_connections = []
        for user_id, connection in self.active_connections.items():
            try:
                await connection.send_json(message)
            except Exception:
                dead_connections.append(user_id)
                
        for user_id in dead_connections:
            self.disconnect(user_id)

    async def broadcast_to_users(self, message: dict, user_ids: list):
        for uid in user_ids:
            await self.send_personal_message(message, uid)

    async def broadcast_to_group(self, message: dict, user_ids: list[str]):
        for user_id in user_ids:
            await self.send_personal_message(message, user_id)

# Global connection manager singleton
manager = ConnectionManager()
