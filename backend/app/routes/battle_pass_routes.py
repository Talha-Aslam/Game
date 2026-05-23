from fastapi import APIRouter, Depends
from pydantic import BaseModel
from app.middleware.auth_middleware import get_current_user_id
from app.services import battle_pass_service

router = APIRouter()

class ClaimRequest(BaseModel):
    tier: int
    is_premium: bool

@router.post("/claim")
async def claim_tier(request: ClaimRequest, user_id: str = Depends(get_current_user_id)):
    return await battle_pass_service.claim_tier(user_id, request.tier, request.is_premium)

@router.post("/buy-premium")
async def buy_premium(user_id: str = Depends(get_current_user_id)):
    return await battle_pass_service.buy_premium_pass(user_id)

@router.post("/purchase-tier")
async def purchase_tier_route(user_id: str = Depends(get_current_user_id)):
    return await battle_pass_service.purchase_tier(user_id)
