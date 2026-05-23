from fastapi import APIRouter
from app.schemas.auth_schema import UserRegister, UserLogin, TokenResponse
from app.services import auth_service

router = APIRouter()

@router.post("/register", response_model=TokenResponse)
async def register(user_data: UserRegister):
    return await auth_service.register_user(user_data)

@router.post("/login", response_model=TokenResponse)
async def login(user_data: UserLogin):
    return await auth_service.login_user(user_data)

from pydantic import BaseModel
class FirebaseToken(BaseModel):
    token: str

@router.post("/google", response_model=TokenResponse)
async def google_login(data: FirebaseToken):
    return await auth_service.google_login(data.token)
