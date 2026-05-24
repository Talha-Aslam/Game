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
from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
import os
import uuid
from app.config.database import get_database

@router.post("/me/avatar", response_model=UserResponse)
async def upload_avatar(file: UploadFile = File(...), user_id: str = Depends(get_current_user_id)):
    ext = ".jpg"
    if file.filename and "." in file.filename:
        parsed_ext = "." + file.filename.split(".")[-1].lower()
        if len(parsed_ext) <= 5: # basic sanity check that it's actually an extension
            ext = parsed_ext
    
    # Generate unique filename
    filename = f"{user_id}_{uuid.uuid4().hex}{ext}"
    filepath = os.path.join("uploads", "avatars", filename)
    
    # Ensure directory exists
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    
    # Save the file
    with open(filepath, "wb") as buffer:
        content = await file.read()
        buffer.write(content)
        
    # Construct public URL (this will be relative, the frontend should prepend the apiBaseUrl if needed, or Nginx will serve it)
    avatar_url = f"/uploads/avatars/{filename}"
    
    # Update user in DB
    db = get_database()
    await db["users"].update_one(
        {"_id": user_id},
        {"$set": {"profile_picture": avatar_url}}
    )
    
    return await user_service.get_user_by_id(user_id)
