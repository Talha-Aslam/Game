from fastapi import HTTPException, status
from app.config.database import get_database
from app.models.user_model import UserDB
from app.schemas.auth_schema import UserRegister, UserLogin
from app.utils.password_handler import get_password_hash, verify_password
from app.utils.jwt_handler import create_access_token
import uuid

async def register_user(user_data: UserRegister):
    db = get_database()
    users_collection = db["users"]

    # Check if email exists
    if await users_collection.find_one({"email": user_data.email}):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already registered")

    # Check if username exists
    if await users_collection.find_one({"username": user_data.username}):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Username already taken")

    # Create user
    user_dict = user_data.model_dump()
    user_dict["password"] = get_password_hash(user_dict["password"])
    
    new_user = UserDB(**user_dict)
    new_user_dict = new_user.model_dump(by_alias=True)
    
    await users_collection.insert_one(new_user_dict)
    
    # Generate token
    token = create_access_token({"sub": new_user.id})
    return {"access_token": token, "token_type": "bearer"}

async def login_user(user_data: UserLogin):
    db = get_database()
    users_collection = db["users"]

    user = await users_collection.find_one({"email": user_data.email})
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")

    if not verify_password(user_data.password, user["password"]):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")

    token = create_access_token({"sub": str(user["_id"])})
    return {"access_token": token, "token_type": "bearer"}
