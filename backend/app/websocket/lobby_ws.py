from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Query
from app.core.websocket_manager import manager
from app.core.matchmaking_manager import matchmaker
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

@router.websocket("/lobby")
async def websocket_lobby(websocket: WebSocket, token: str = Query(...)):
    try:
        user_id = await get_user_from_token(token)
    except ValueError:
        await websocket.close(code=4001, reason="Invalid token")
        return

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
                    
                elif action == "private_message":
                    target_id = payload.get("targetId")
                    content = payload.get("content")
                    if target_id and content:
                        from app.services.social_service import save_private_message
                        msg = await save_private_message(user_id, target_id, content)
                        # Send to target
                        await manager.send_personal_message({
                            "event": "private_message",
                            "data": msg
                        }, target_id)
                        # Echo back to sender
                        await manager.send_personal_message({
                            "event": "private_message",
                            "data": msg
                        }, user_id)
                    
            except json.JSONDecodeError:
                logger.warning("Invalid JSON received")
                
    except WebSocketDisconnect:
        manager.disconnect(user_id)
        matchmaker.leave_queue(user_id)
