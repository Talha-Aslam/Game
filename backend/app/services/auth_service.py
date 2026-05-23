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

from firebase_admin import auth as firebase_auth
import logging

async def google_login(firebase_token: str):
    db = get_database()
    users_collection = db["users"]
    
    try:
        # Verify the Firebase token
        decoded_token = firebase_auth.verify_id_token(firebase_token)
        uid = decoded_token.get('uid')
        email = decoded_token.get('email')
        name = decoded_token.get('name', 'User')
        picture = decoded_token.get('picture', '')
        
        if not email:
            raise HTTPException(status_code=400, detail="No email provided by Google")
            
        # Check if user exists
        user = await users_collection.find_one({"email": email})
        
        if not user:
            # Create new user for social login
            # Give a random generic password since they login with Google
            random_pw = get_password_hash(str(uuid.uuid4()))
            
            # Ensure unique username
            base_username = name.replace(" ", "").lower()
            username = base_username
            counter = 1
            while await users_collection.find_one({"username": username}):
                username = f"{base_username}{counter}"
                counter += 1
                
            new_user = UserDB(
                email=email,
                username=username,
                password=random_pw,
                profile_picture=picture
            )
            user_dict = new_user.model_dump(by_alias=True)
            await users_collection.insert_one(user_dict)
            user_id = str(new_user.id)
        else:
            user_id = str(user["_id"])
            # Update profile picture if it's empty
            if not user.get("profile_picture") and picture:
                await users_collection.update_one({"_id": user["_id"]}, {"$set": {"profile_picture": picture}})
                
        token = create_access_token({"sub": user_id})
        return {"access_token": token, "token_type": "bearer"}
        
    except Exception as e:
        logging.error(f"Google login failed: {e}")
        raise HTTPException(status_code=401, detail="Invalid Firebase token")
