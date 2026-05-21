from fastapi import APIRouter, Depends
from app.schemas.user_schema import UserResponse, UserUpdate
from app.services import user_service
from app.middleware.auth_middleware import get_current_user_id

router = APIRouter()

@router.get("/me", response_model=UserResponse)
async def get_current_user(user_id: str = Depends(get_current_user_id)):
    return await user_service.get_user_by_id(user_id)

@router.put("/update", response_model=UserResponse)
async def update_profile(update_data: UserUpdate, user_id: str = Depends(get_current_user_id)):
    return await user_service.update_user_profile(user_id, update_data)

@router.post("/gift-popularity/{target_id}")
async def gift_popularity(target_id: str, user_id: str = Depends(get_current_user_id)):
    return await user_service.gift_popularity(user_id, target_id)

