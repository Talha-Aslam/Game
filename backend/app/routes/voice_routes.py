from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from app.middleware.auth_middleware import get_current_user
from app.services.agora_service import generate_rtc_token_with_account

router = APIRouter(prefix="/voice", tags=["Voice"])

class TokenRequest(BaseModel):
    channel_name: str
    role: int = 1 # 1 = Publisher, 2 = Subscriber

@router.post("/token")
async def get_voice_token(req: TokenRequest, user: dict = Depends(get_current_user)):
    try:
        token = generate_rtc_token_with_account(
            channel_name=req.channel_name,
            account=user["_id"],
            role=req.role
        )
        return {"token": token, "channel_name": req.channel_name}
    except ValueError as e:
        raise HTTPException(status_code=500, detail=str(e))
