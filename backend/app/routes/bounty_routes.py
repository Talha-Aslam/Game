from fastapi import APIRouter, Depends
from app.schemas.bounty_schema import UserBountiesSchema
from app.schemas.user_schema import UserResponse
from app.services import bounty_service
from app.middleware.auth_middleware import get_current_user_id

router = APIRouter(tags=["Bounties"])

@router.get("/daily", response_model=UserBountiesSchema)
async def get_daily_bounties(user_id: str = Depends(get_current_user_id)):
    return await bounty_service.get_or_create_daily_bounties(user_id)

@router.post("/{bounty_id}/claim", response_model=UserResponse)
async def claim_bounty(bounty_id: str, user_id: str = Depends(get_current_user_id)):
    return await bounty_service.claim_bounty_reward(user_id, bounty_id)
