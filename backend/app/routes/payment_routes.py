from fastapi import APIRouter, Depends
from pydantic import BaseModel
from typing import List, Dict, Any
from app.middleware.auth_middleware import get_current_user_id
from app.services import payment_service

router = APIRouter()

class PaymentRequest(BaseModel):
    package_id: str
    price: float
    transaction_id: str
    status_code: str # "SUCCESS", "FAILED_INSUFFICIENT_FUNDS", "FAILED_CANCELLED"

@router.get("/packages")
async def get_packages():
    """Return the static list of available premium packages."""
    return payment_service.PACKAGES

@router.post("/process")
async def process_payment(request: PaymentRequest, user_id: str = Depends(get_current_user_id)):
    return await payment_service.process_payment(
        user_id,
        request.package_id,
        request.price,
        request.transaction_id,
        request.status_code
    )

@router.get("/history")
async def get_transaction_history(user_id: str = Depends(get_current_user_id)):
    return await payment_service.get_transaction_history(user_id)
