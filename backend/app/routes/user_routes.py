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


@router.get("/rankings")
async def get_rankings(user_id: str = Depends(get_current_user_id)):
    db = get_database()
    # Ensure we use an aggregate to sort by the maximum of possible mmr fields if needed
    # But usually, it's stored as 'mmr'. We will sort by 'mmr' natively, but handle fallback in python.
    cursor = db["users"].find().sort("mmr", -1).limit(100)
    top_players = await cursor.to_list(length=100)
    
    rankings = []
    for i, p in enumerate(top_players):
        # Resilient MMR fetch
        points = p.get("mmr") or p.get("MMR") or p.get("rank_points") or 0
        
        # Derive level from BP
        level = p.get("battle_pass_tier", 1)
        if level == 0: level = 1
        
        rankings.append({
            "rank": i + 1,
            "username": p.get("username", "Unknown"),
            "avatarUrl": p.get("profile_picture", ""),
            "level": level,
            "mmr": points,
            "is_me": str(p.get("_id")) == user_id
        })
        
    # Python-side re-sort just in case the db field wasn't purely "mmr"
    rankings.sort(key=lambda x: x["mmr"], reverse=True)
    for i, r in enumerate(rankings):
        r["rank"] = i + 1
        
    return rankings

@router.get("/recent-matches")
async def get_recent_matches(user_id: str = Depends(get_current_user_id)):
    db = get_database()
    user = await db["users"].find_one({"_id": user_id})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    match_ids = user.get("match_history", [])
    # In a real app, we'd fetch match details from a 'matches' collection.
    # For now, we'll return mock data based on the history size to fulfill the UI requirement.
    import random
    results = []
    for mid in match_ids[-10:]: # last 10
        won = random.choice([True, False])
        results.append({
            "id": mid,
            "won": won,
            "mode": "Ranked",
            "role": random.choice(["Mafia", "Doctor", "Detective", "Civilian"]),
            "timestamp": "2026-06-06T12:00:00Z",
            "xp_gained": 150 if won else 50
        })
    return results

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
    bp_tier = user.get("battle_pass_tier", 1)
    
    threshold = 1000 + (bp_tier * 50)

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
        current_xp=bp_xp,
        next_level_xp=threshold,
        equipped_title=user.get("title", "Shadow Boss") or "Shadow Boss",
        battle_pass_tier=bp_tier,
    )

