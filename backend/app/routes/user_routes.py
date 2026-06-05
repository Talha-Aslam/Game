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
async def gift_popularity(target_id: str, amount: int = 100, user_id: str = Depends(get_current_user_id)):
    return await user_service.gift_popularity(user_id, target_id, amount)
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


# ── Lobby Profile (lightweight endpoint for AvatarShowcaseWidget) ──────────

_RANK_TIERS = {
    "bronze": 0,
    "silver": 1,
    "gold": 2,
    "diamond": 3,
    "syndicate": 4,
    "boss": 4,
}

_FRAME_IDS = [
    "bronze_ring",
    "silver_ring",
    "gold_hex",
    "diamond_sharp",
    "syndicate_royal",
]

_RANK_NAMES = ["Bronze", "Silver", "Gold", "Diamond", "Syndicate Boss"]

_XP_PER_TIER = 1000


@router.get("/lobby-profile")
async def get_lobby_profile(user_id: str = Depends(get_current_user_id)):
    from app.schemas.user_schema import LobbyProfileResponse
    db = get_database()
    user = await db["users"].find_one({"_id": user_id})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Parse rank tier from string rank field
    rank_str = str(user.get("rank", "Bronze")).lower()
    rank_tier = 0
    for key, val in _RANK_TIERS.items():
        if key in rank_str:
            rank_tier = val
            break

    bp_xp = user.get("battle_pass_xp", 0)
    bp_tier = user.get("battle_pass_tier", 0)
    current_xp = bp_xp % _XP_PER_TIER

    # Equipped cosmetics sub-doc (may be empty)
    cosmetics = user.get("equipped_cosmetics", {}) or {}
    banner_url = cosmetics.get("lobby_banner_url", "") or ""

    return LobbyProfileResponse(
        username=user.get("username", "Agent"),
        avatar_url=user.get("profile_picture", ""),
        equipped_frame_id=_FRAME_IDS[rank_tier],
        equipped_banner_url=banner_url,
        current_rank_title=_RANK_NAMES[rank_tier],
        rank_tier=rank_tier,
        current_xp=current_xp,
        next_level_xp=_XP_PER_TIER,
        equipped_title=user.get("title", "Shadow Boss") or "Shadow Boss",
        battle_pass_tier=bp_tier,
    )

