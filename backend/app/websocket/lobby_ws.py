from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Query
from app.core.websocket_manager import manager
from app.core.matchmaking_manager import matchmaker
import logging
import json

router = APIRouter(prefix="/ws", tags=["WebSocket"])
logger = logging.getLogger(__name__)

# Very basic auth extraction from query params
# In a real system, you'd decode the JWT token here
async def get_user_from_token(token: str) -> str:
    # Assuming token is passed as user_id for simplicity during this phase
    # Replace with JWT decoding
    return token

@router.websocket("/lobby")
async def websocket_lobby(websocket: WebSocket, token: str = Query(...)):
    user_id = await get_user_from_token(token)
    await manager.connect(user_id, websocket)
    
    try:
        while True:
            data = await websocket.receive_text()
            try:
                payload = json.loads(data)
                action = payload.get("action")
                
                if action == "join_queue":
                    mode = payload.get("mode", "casual")
                    matchmaker.join_queue(user_id, mode)
                    await manager.send_personal_message({"event": "queued", "mode": mode}, user_id)
                    
                elif action == "leave_queue":
                    matchmaker.leave_queue(user_id)
                    await manager.send_personal_message({"event": "dequeued"}, user_id)
                    
            except json.JSONDecodeError:
                logger.warning("Invalid JSON received")
                
    except WebSocketDisconnect:
        manager.disconnect(user_id)
        matchmaker.leave_queue(user_id)
