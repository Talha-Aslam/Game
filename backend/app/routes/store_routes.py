from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from app.middleware.auth_middleware import get_current_user_id
from app.services import store_service

router = APIRouter()

class PurchaseRequest(BaseModel):
    item_id: str
    currency: str # "syndicate" or "influence"
    price: int
    category: str

class EquipRequest(BaseModel):
    item_id: str
    category: str # store category name

@router.post("/buy")
async def buy_item(request: PurchaseRequest, user_id: str = Depends(get_current_user_id)):
    return await store_service.purchase_item(
        user_id, 
        request.item_id, 
        request.currency, 
        request.price,
        request.category
    )

@router.post("/equip")
async def equip_item(request: EquipRequest, user_id: str = Depends(get_current_user_id)):
    return await store_service.equip_item(user_id, request.item_id, request.category)
