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
                        
                elif action == "party_invite":
                    target_id = payload.get("targetId")
                    if target_id:
                        from app.config.database import get_database
                        db = get_database()
                        sender = await db["users"].find_one({"_id": user_id})
                        sender_name = sender.get("username", "A friend") if sender else "A friend"
                        
                        await manager.send_personal_message({
                            "event": "party_invite",
                            "data": {
                                "senderId": user_id,
                                "senderName": sender_name
                            }
                        }, target_id)

                elif action == "family_invite":
                    target_id = payload.get("targetId")
                    family_id = payload.get("familyId")
                    family_name = payload.get("familyName")
                    if target_id and family_id:
                        from app.config.database import get_database
                        db = get_database()
                        sender = await db["users"].find_one({"_id": user_id})
                        sender_name = sender.get("username", "A friend") if sender else "A friend"
                        
                        await manager.send_personal_message({
                            "event": "family_invite",
                            "data": {
                                "senderId": user_id,
                                "senderName": sender_name,
                                "familyId": family_id,
                                "familyName": family_name or "their family"
                            }
                        }, target_id)

                elif action == "voice_mute_request":
                    target_id = payload.get("targetId")
                    if target_id:
                        from app.config.database import get_database
                        db = get_database()
                        user = await db["users"].find_one({"_id": user_id})
                        family_id = user.get("family_id")
                        if family_id:
                            family = await db["families"].find_one({"_id": family_id})
                            if family:
                                # Check if sender is boss or underboss
                                members = family.get("members", [])
                                sender_member = next((m for m in members if m["user_id"] == user_id), None)
                                target_member = next((m for m in members if m["user_id"] == target_id), None)
                                
                                if sender_member and target_member and sender_member["role"] in ["boss", "underboss"]:
                                    await manager.send_personal_message({
                                        "event": "voice_muted",
                                        "data": {"mutedBy": sender_member["username"]}
                                    }, target_id)

                    
            except json.JSONDecodeError:
                logger.warning("Invalid JSON received")
                
    except WebSocketDisconnect:
        manager.disconnect(user_id)
        matchmaker.leave_queue(user_id)
