from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends
from typing import Dict, Any
from app.services.matchmaking_service import matchmaking_service, user_connections
from app.services.user_service import get_user_by_id
from app.schemas.match_schema import MatchPlayer
import json

router = APIRouter(tags=["Matchmaking"])

@router.websocket("/ws/matchmaking/{user_id}")
async def websocket_matchmaking(websocket: WebSocket, user_id: str):
    await websocket.accept()
    user_connections[user_id] = websocket
    
    try:
        user_data = await get_user_by_id(user_id)
        player = MatchPlayer(
            user_id=user_data.id,
            username=user_data.username,
            profile_picture=user_data.profile_picture,
            rank=user_data.rank,
            mmr=user_data.mmr
        )
        
        while True:
            data = await websocket.receive_text()
            payload = json.loads(data)
            event = payload.get("event")
            
            if event == "join_queue":
                game_mode = payload.get("game_mode", "ranked")
                await matchmaking_service.add_to_queue(user_id, game_mode, player)
            
            elif event == "leave_queue":
                await matchmaking_service.remove_from_queue(user_id)
                await websocket.send_json({"event": "queue_left"})
                
            elif event == "accept_match":
                # Mark player as accepted in lobby
                pass
                
            elif event == "decline_match":
                # Remove from lobby, return others to queue
                pass

    except WebSocketDisconnect:
        if user_id in user_connections:
            del user_connections[user_id]
        await matchmaking_service.remove_from_queue(user_id)
    except Exception as e:
        if user_id in user_connections:
            del user_connections[user_id]
        await matchmaking_service.remove_from_queue(user_id)
