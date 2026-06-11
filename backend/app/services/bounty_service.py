import random
import uuid
from datetime import datetime, timedelta
from fastapi import HTTPException, status
from app.config.database import get_database
from app.schemas.bounty_schema import BountySchema
from app.services.user_service import get_user_by_id

# Hardcoded pool of daily bounties for generation
BOUNTY_POOL = [
    {"action_type": "win_match", "description": "Win 1 Match", "total": 1, "xp": 100, "icon": "trophy"},
    {"action_type": "survive_night", "description": "Survive 2 Nights", "total": 2, "xp": 80, "icon": "shield"},
    {"action_type": "vote_mafia", "description": "Vote out Mafia", "total": 1, "xp": 120, "icon": "target"},
    {"action_type": "doctor_save", "description": "Successfully save someone as Doctor", "total": 1, "xp": 150, "icon": "medical_services"}
]

async def get_or_create_daily_bounties(user_id: str):
    db = get_database()
    users_collection = db["users"]
    user = await users_collection.find_one({"_id": user_id})
    
    now = datetime.utcnow()
    bounties_reset_at = user.get("bounties_reset_at")
    
    # If no bounties or reset time has passed, generate new ones
    if not user.get("daily_bounties") or not bounties_reset_at or now.isoformat() > bounties_reset_at:
        new_bounties = random.sample(BOUNTY_POOL, 3)
        bounties_data = []
        for b in new_bounties:
            b_data = b.copy()
            b_data["id"] = str(uuid.uuid4())
            b_data["current"] = 0
            b_data["status"] = "pending"
            bounties_data.append(b_data)
        
        # Reset at midnight UTC
        tomorrow = now + timedelta(days=1)
        reset_time = datetime(tomorrow.year, tomorrow.month, tomorrow.day, 0, 0, 0).isoformat()
        
        await users_collection.update_one(
            {"_id": user_id},
            {"$set": {"daily_bounties": bounties_data, "bounties_reset_at": reset_time}}
        )
        return {"bounties": bounties_data, "reset_at": reset_time}
    
    return {"bounties": user.get("daily_bounties"), "reset_at": bounties_reset_at}

async def update_bounty_progress(user_id: str, actions: dict):
    # actions is a dict like {"win_match": 1, "survive_night": 2}
    db = get_database()
    users_collection = db["users"]
    user = await users_collection.find_one({"_id": user_id})
    
    bounties = user.get("daily_bounties", [])
    if not bounties:
        return
        
    updated = False
    for bounty in bounties:
        action_type = bounty.get("action_type")
        if action_type in actions and bounty.get("status") == "pending":
            bounty["current"] += actions[action_type]
            if bounty["current"] >= bounty["total"]:
                bounty["current"] = bounty["total"]
                bounty["status"] = "completed"
            updated = True
            
    if updated:
        await users_collection.update_one(
            {"_id": user_id},
            {"$set": {"daily_bounties": bounties}}
        )

async def claim_bounty_reward(user_id: str, bounty_id: str):
    db = get_database()
    users_collection = db["users"]
    user = await users_collection.find_one({"_id": user_id})
    
    bounties = user.get("daily_bounties", [])
    bounty_found = None
    
    for bounty in bounties:
        if bounty.get("id") == bounty_id:
            bounty_found = bounty
            break
            
    if not bounty_found:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Bounty not found")
        
    if bounty_found["status"] != "completed":
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Bounty is not completed or already claimed")
        
    bounty_found["status"] = "claimed"
    xp_reward = bounty_found.get("xp", 100)
    
    await users_collection.update_one(
        {"_id": user_id},
        {"$set": {"daily_bounties": bounties}}
    )
    
    # Give Battle Pass XP using safe leveling
    from app.services.battle_pass_service import add_bp_xp
    await add_bp_xp(user_id, xp_reward)
    
    return await get_user_by_id(user_id)
