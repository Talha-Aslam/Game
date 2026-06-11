from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from typing import Optional
from app.middleware.auth_middleware import get_current_user_id
from app.services import battle_pass_service

router = APIRouter()

class ClaimRequest(BaseModel):
    tier: int
    is_premium: bool

class PurchaseTiersRequest(BaseModel):
    count: int

class BuyPremiumRequest(BaseModel):
    is_premium_plus: bool = False

@router.get("/season")
async def get_season_info():
    return await battle_pass_service.get_season_info()

@router.post("/claim")
async def claim_tier(request: ClaimRequest, user_id: str = Depends(get_current_user_id)):
    return await battle_pass_service.claim_tier(user_id, request.tier, request.is_premium)

@router.post("/buy-premium")
async def buy_premium(request: BuyPremiumRequest, user_id: str = Depends(get_current_user_id)):
    return await battle_pass_service.buy_premium_pass(user_id, request.is_premium_plus)

@router.post("/purchase-tiers")
async def purchase_tiers(request: PurchaseTiersRequest, user_id: str = Depends(get_current_user_id)):
    return await battle_pass_service.purchase_tiers(user_id, request.count)
