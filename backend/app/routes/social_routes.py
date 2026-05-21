from fastapi import APIRouter, Depends
from app.middleware.auth_middleware import get_current_user
from app.services.social_service import (
    get_friends_list, get_friend_requests, send_friend_request,
    accept_friend_request, reject_friend_request, remove_friend,
    search_users, get_leaderboard,
)
from pydantic import BaseModel
from typing import Optional


router = APIRouter(prefix="/social", tags=["Social"])


@router.get("/friends")
async def list_friends(user: dict = Depends(get_current_user)):
    return await get_friends_list(user["_id"])


@router.get("/requests")
async def list_friend_requests(user: dict = Depends(get_current_user)):
    return await get_friend_requests(user["_id"])


@router.post("/request/{target_user_id}")
async def send_request(target_user_id: str, user: dict = Depends(get_current_user)):
    return await send_friend_request(user["_id"], target_user_id)


@router.post("/accept/{request_id}")
async def accept_request(request_id: str, user: dict = Depends(get_current_user)):
    return await accept_friend_request(user["_id"], request_id)


@router.post("/reject/{request_id}")
async def reject_request(request_id: str, user: dict = Depends(get_current_user)):
    return await reject_friend_request(user["_id"], request_id)


@router.delete("/friend/{friend_id}")
async def delete_friend(friend_id: str, user: dict = Depends(get_current_user)):
    return await remove_friend(user["_id"], friend_id)


@router.get("/search")
async def search(query: str = "", user: dict = Depends(get_current_user)):
    return await search_users(query, user["_id"])


@router.get("/leaderboard")
async def leaderboard(limit: int = 50):
    return await get_leaderboard(limit)
