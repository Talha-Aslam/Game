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
        from app.config.database import get_database
        db = get_database()
        user = await db["users"].find_one({"_id": user_id})
        if user and user.get("family_id"):
            family = await db["families"].find_one({"_id": user.get("family_id")})
            if family:
                member_ids = [m["user_id"] for m in family.get("members", []) if m["user_id"] != user_id]
                if member_ids:
                    await manager.broadcast_to_users({
                        "event": "family_member_status",
                        "data": {
                            "user_id": user_id,
                            "status": "online"
                        }
                    }, member_ids)
    except Exception as e:
        logger.error(f"Error broadcasting family member status: {e}")

    try:
        while True:
            data = await websocket.receive_text()
            try:
                payload = json.loads(data)
                action = payload.get("action")
                
                if action == "ping":
                    await websocket.send_json({"event": "pong"})
                    
                elif action == "sync_state":
                    state = matchmaker.get_user_state(user_id)
                    await manager.send_personal_message(state, user_id)
                    
                # --- CUSTOM ROOMS ---
                elif action == "create_custom":
                    from app.core.custom_room_manager import custom_room_manager
                    room = custom_room_manager.create_room(user_id)
                    payload = await custom_room_manager.get_room_payload(room.room_id)
                    await manager.send_personal_message({
                        "event": "custom_room_update",
                        "data": payload
                    }, user_id)
                    
                elif action == "join_custom":
                    from app.core.custom_room_manager import custom_room_manager
                    room_id = payload.get("room_id")
                    room = custom_room_manager.join_room(user_id, room_id)
                    if room:
                        payload = await custom_room_manager.get_room_payload(room.room_id)
                        await manager.broadcast_to_users({
                            "event": "custom_room_update",
                            "data": payload
                        }, room.players)
                    else:
                        await manager.send_personal_message({"event": "error", "message": "Failed to join room"}, user_id)
                        
                elif action == "start_custom":
                    from app.core.custom_room_manager import custom_room_manager
                    room_id = payload.get("room_id")
                    await custom_room_manager.start_match(user_id, room_id)

                elif action == "invite_custom":
                    target_id = payload.get("target_id")
                    room_id = payload.get("room_id")
                    # Fetch real sender name
                    from app.config.database import get_database
                    db = get_database()
                    sender = await db["users"].find_one({"_id": user_id})
                    sender_name = sender.get("username", "A player") if sender else "A player"
                    
                    # Send invite event to target
                    await manager.send_personal_message({
                        "event": "custom_room_invite",
                        "data": {
                            "sender_name": sender_name,
                            "room_id": room_id
                        }
                    }, target_id)
                    
                elif action == "leave_custom":
                    from app.core.custom_room_manager import custom_room_manager
                    room_id = custom_room_manager.user_to_room.get(user_id)
                    if room_id:
                        custom_room_manager.leave_room(user_id)
                        room = custom_room_manager.active_rooms.get(room_id)
                        if room:
                            payload_data = await custom_room_manager.get_room_payload(room_id)
                            if payload_data:
                                await manager.broadcast_to_users({
                                    "event": "custom_room_update",
                                    "data": payload_data
                                }, room.players)
                                
                elif action == "kick_custom":
                    target_id = payload.get("target_id")
                    from app.core.custom_room_manager import custom_room_manager
                    room_id = custom_room_manager.user_to_room.get(user_id)
                    room = custom_room_manager.active_rooms.get(room_id) if room_id else None
                    if room and room.creator_id == user_id and target_id in room.players:
                        custom_room_manager.leave_room(target_id)
                        await manager.send_personal_message({"event": "kicked_from_custom"}, target_id)
                        # Broadcast update
                        payload_data = await custom_room_manager.get_room_payload(room_id)
                        if payload_data:
                            await manager.broadcast_to_users({
                                "event": "custom_room_update",
                                "data": payload_data
                            }, room.players)
                            
                # --- FAMILY WAR ---
                elif action == "start_family_war":
                    # Broadcast to all online family members
                    from app.services.family_service import get_family
                    family = await get_family(user_id)
                    if family:
                        member_ids = [m["user_id"] for m in family.get("members", []) if m["user_id"] != user_id]
                        await manager.broadcast_to_users({
                            "event": "family_war_invite",
                            "data": {
                                "sender_name": user_id,
                                "family_name": family.get("name")
                            }
                        }, member_ids)

                elif action == "join_queue":
                    mode = payload.get("mode", "casual")
                    matchmaker.join_queue(user_id, mode)
                    await manager.send_personal_message({"event": "queued", "mode": mode}, user_id)
                    
                elif action == "leave_queue":
                    matchmaker.leave_queue(user_id)
                    await manager.send_personal_message({"event": "dequeued"}, user_id)
                    
                elif action == "decline_match":
                    match_id = payload.get("match_id")
                    await matchmaker.decline_match(user_id, match_id)

                elif action == "accept_match":
                    match_id = payload.get("match_id")
                    await matchmaker.accept_match(user_id, match_id)
                    
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
        if manager.disconnect(user_id, websocket):
            matchmaker.leave_queue(user_id)
            
            # Handle leaving custom room on disconnect
            from app.core.custom_room_manager import custom_room_manager
            room_id = custom_room_manager.user_to_room.get(user_id)
            if room_id:
                custom_room_manager.leave_room(user_id)
                room = custom_room_manager.active_rooms.get(room_id)
                if room:
                    import asyncio
                    async def _broadcast_room_leave():
                        payload_data = await custom_room_manager.get_room_payload(room_id)
                        if payload_data:
                            await manager.broadcast_to_users({
                                "event": "custom_room_update",
                                "data": payload_data
                            }, room.players)
                    asyncio.create_task(_broadcast_room_leave())
            
            try:
                from app.config.database import get_database
                db = get_database()
                user = await db["users"].find_one({"_id": user_id})
                if user and user.get("family_id"):
                    family = await db["families"].find_one({"_id": user.get("family_id")})
                    if family:
                        member_ids = [m["user_id"] for m in family.get("members", []) if m["user_id"] != user_id]
                        if member_ids:
                            await manager.broadcast_to_users({
                                "event": "family_member_status",
                                "data": {
                                    "user_id": user_id,
                                    "status": "offline"
                                }
                            }, member_ids)
            except Exception:
                pass
