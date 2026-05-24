from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Query
from app.core.websocket_manager import manager
from app.core.game_engine import game_engine
import logging
import json

router = APIRouter(prefix="/ws", tags=["WebSocket"])
logger = logging.getLogger(__name__)

async def get_user_from_token(token: str) -> str:
    return token

@router.websocket("/game/{room_id}")
async def websocket_game(websocket: WebSocket, room_id: str, token: str = Query(...)):
    user_id = await get_user_from_token(token)
    
    # In a real game, you would verify the user is actually part of this room_id
    if room_id not in game_engine.active_rooms:
        await websocket.close(code=4004, reason="Room not found")
        return
        
    await manager.connect(user_id, websocket)
    
    # Send the current state immediately so the player doesn't miss it while connecting
    room = game_engine.active_rooms[room_id]
    await game_engine._broadcast_state(room, "lobby_update", {"status": "connected"})
    
    try:
        while True:
            data = await websocket.receive_text()
            try:
                payload = json.loads(data)
                
                # Pass the action to the game engine
                game_engine.handle_action(room_id, user_id, payload)
                    
            except json.JSONDecodeError:
                logger.warning("Invalid JSON received")
                
    except WebSocketDisconnect:
        manager.disconnect(user_id)
        # Note: Disconnecting does not kill the player in the game engine. 
        # They can reconnect. If they never reconnect, they might just miss votes.
