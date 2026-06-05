from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Query
from app.core.websocket_manager import manager
from app.core.game_engine import game_engine
import logging
import json

router = APIRouter(prefix="/ws", tags=["WebSocket"])
logger = logging.getLogger(__name__)

from app.utils.jwt_handler import verify_access_token

async def get_user_from_token(token: str) -> str:
    payload = verify_access_token(token)
    if not payload or "sub" not in payload:
        raise ValueError("Invalid token")
    return payload["sub"]

@router.websocket("/game/{room_id}")
async def websocket_game(websocket: WebSocket, room_id: str, token: str = Query(...)):
    try:
        user_id = await get_user_from_token(token)
    except ValueError:
        await websocket.close(code=4001, reason="Invalid token")
        return
    
    # In a real game, you would verify the user is actually part of this room_id
    if room_id not in game_engine.active_rooms:
        await websocket.close(code=4004, reason="Room not found")
        return
        
    await manager.connect(user_id, websocket)
    
    # Send the current state immediately so the player doesn't miss it while connecting
    room = game_engine.active_rooms[room_id]
    
    # Convert backend room.state to frontend GamePhase enum names if necessary, 
    # but for now we can just send the players list and then trigger a phase update
    await game_engine._broadcast_state(room, "lobby_update", {
        "status": "connected",
        "phase": room.state
    })
    
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
        manager.disconnect(user_id, websocket)
        # Note: Disconnecting does not kill the player in the game engine. 
        # They can reconnect. If they never reconnect, they might just miss votes.
