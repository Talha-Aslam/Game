from fastapi import HTTPException, status
from app.config.database import get_database
from datetime import datetime, timedelta
import math

# Shared Battle Pass config
SEASON_NAME = "Season 1: City of Lies"
# Let's say season ends 30 days from now for this live-service instance
SEASON_END_DATE = (datetime.utcnow() + timedelta(days=30)).isoformat()
MAX_TIER = 50

# Map of specific rewards for the first 10 tiers (as an example of AAA economy).
# After 10, it loops. This mirrors the frontend.
REWARD_TABLE = [
    {"tier": 1, "free": {"type": "influence_points", "amount": 200}, "premium": {"type": "animated_border", "id": "neon_cyan_border"}},
    {"tier": 2, "free": {"type": "influence_points", "amount": 150}, "premium": {"type": "voice_pack", "id": "shadow_voice"}},
    {"tier": 3, "free": {"type": "nameplate", "id": "basic_nameplate"}, "premium": {"type": "syndicate_coins", "amount": 200}},
    {"tier": 4, "free": {"type": "influence_points", "amount": 200}, "premium": {"type": "card_style", "id": "midnight_style"}},
    {"tier": 5, "free": {"type": "card_style", "id": "dawn_style"}, "premium": {"type": "elimination_fx", "id": "shatter_fx"}},
    {"tier": 6, "free": {"type": "influence_points", "amount": 250}, "premium": {"type": "xp_boost_token", "id": "2x_xp_1h"}},
    {"tier": 7, "free": {"type": "popularity_gift", "id": "rose"}, "premium": {"type": "avatar", "id": "phantom_avatar"}},
    {"tier": 8, "free": {"type": "influence_points", "amount": 300}, "premium": {"type": "nameplate", "id": "enforcer_nameplate"}},
    {"tier": 9, "free": {"type": "syndicate_coins", "amount": 150}, "premium": {"type": "family_crest_fx", "id": "glow_crest"}},
    {"tier": 10, "free": {"type": "card_style", "id": "blaze_style"}, "premium": {"type": "elimination_fx", "id": "inferno_fx"}},
]

def _get_reward_for_tier(tier: int, is_premium: bool) -> dict:
    idx = (tier - 1) % 10
    base_reward = REWARD_TABLE[idx]
    if is_premium:
        reward = base_reward.get("premium", {})
    else:
        reward = base_reward.get("free", {})
        
    # Scale currency for repeating tiers
    multiplier = math.ceil(tier / 10)
    final_reward = dict(reward)
    if "amount" in final_reward:
        final_reward["amount"] = final_reward["amount"] * multiplier
    return final_reward

async def get_season_info() -> dict:
    return {
        "season_name": SEASON_NAME,
        "season_end_date": SEASON_END_DATE,
        "max_tier": MAX_TIER
    }

async def claim_tier(user_id: str, tier: int, is_premium: bool) -> dict:
    db = get_database()
    users_collection = db["users"]
    
    user = await users_collection.find_one({"_id": user_id})
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
        
    current_tier = user.get("battle_pass_tier", 1)
    if tier > current_tier:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Tier not unlocked yet")
        
    if is_premium and not user.get("has_premium_pass", False):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Premium pass required")
        
    claimed_free = user.get("claimed_free_tiers", [])
    claimed_premium = user.get("claimed_premium_tiers", [])
    
    if not is_premium and tier in claimed_free:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Free reward already claimed")
        
    if is_premium and tier in claimed_premium:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Premium reward already claimed")
        
    # Apply Reward Logic
    reward = _get_reward_for_tier(tier, is_premium)
    r_type = reward.get("type")
    
    update_ops = {"$push": {}}
    if is_premium:
        update_ops["$push"]["claimed_premium_tiers"] = tier
    else:
        update_ops["$push"]["claimed_free_tiers"] = tier

    # Apply specific reward
    if r_type == "influence_points":
        update_ops.setdefault("$inc", {})["influence"] = reward.get("amount", 0)
    elif r_type == "syndicate_coins":
        update_ops.setdefault("$inc", {})["syndicate_coins"] = reward.get("amount", 0)
    elif r_type in ["animated_border", "nameplate", "voice_pack", "card_style", "elimination_fx", "avatar", "family_crest_fx"]:
        inv_key = ""
        if r_type == "animated_border": inv_key = "borders"
        elif r_type == "nameplate": inv_key = "nameplates"
        elif r_type == "voice_pack": inv_key = "voice_packs"
        elif r_type == "card_style": inv_key = "card_styles"
        elif r_type == "elimination_fx": inv_key = "elimination_fx"
        elif r_type == "avatar": inv_key = "premium_avatars"
        elif r_type == "family_crest_fx": inv_key = "family_crests"
        
        if inv_key:
            update_ops["$push"][f"inventory.{inv_key}"] = reward.get("id")
    # For unsupported types, we just mark as claimed without crash
    
    result = await users_collection.update_one({"_id": user_id}, update_ops)
    
    if result.modified_count == 0:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to claim reward")
        
    return {"message": "Reward claimed successfully", "reward": reward}

async def buy_premium_pass(user_id: str, is_premium_plus: bool = False) -> dict:
    db = get_database()
    users_collection = db["users"]
    
    user = await users_collection.find_one({"_id": user_id})
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
        
    if user.get("has_premium_pass", False):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Already own premium pass")
        
    cost = 2500 if is_premium_plus else 1000
    
    if user.get("syndicate_coins", 0) < cost:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Not enough Syndicate Coins")
        
    update_ops = {
        "$set": {"has_premium_pass": True},
        "$inc": {"syndicate_coins": -cost}
    }
    
    if is_premium_plus:
        update_ops["$inc"]["battle_pass_tier"] = 20
        
    result = await users_collection.update_one(
        {"_id": user_id},
        update_ops
    )
    
    return {"message": f"Premium{' Plus' if is_premium_plus else ''} pass purchased successfully"}

async def purchase_tiers(user_id: str, count: int) -> dict:
    if count <= 0:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid count")
        
    db = get_database()
    users_collection = db["users"]
    
    user = await users_collection.find_one({"_id": user_id})
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
        
    cost = count * 200
    if user.get("influence", 0) < cost:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Not enough Influence")
        
    current_tier = user.get("battle_pass_tier", 1)
    new_tier = min(current_tier + count, MAX_TIER)
    actual_purchased = new_tier - current_tier
    actual_cost = actual_purchased * 200
    
    if actual_purchased <= 0:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Already at Max Tier")
        
    result = await users_collection.update_one(
        {"_id": user_id},
        {
            "$set": {
                "battle_pass_tier": new_tier, # Use $set to be perfectly deterministic
            },
            "$inc": {
                "influence": -actual_cost
            }
        }
    )
    
    return {"message": f"Purchased {actual_purchased} tiers successfully"}

async def add_bp_xp(user_id: str, xp_amount: int) -> dict:
    """Adds BP XP, calculates overflows, and updates the DB."""
    if xp_amount <= 0:
        return {}
        
    db = get_database()
    users_collection = db["users"]
    
    user = await users_collection.find_one({"_id": user_id})
    if not user:
        return {}
        
    tier = user.get("battle_pass_tier", 1)
    current_xp = user.get("battle_pass_xp", 0)
    
    new_xp = current_xp + xp_amount
    threshold = 1000 + (tier * 50)
    
    # Calculate level ups
    while new_xp >= threshold and tier < MAX_TIER:
        new_xp -= threshold
        tier += 1
        threshold = 1000 + (tier * 50)
        
    if tier >= MAX_TIER:
        new_xp = 0 # Cap XP if max tier reached
        
    await users_collection.update_one(
        {"_id": user_id},
        {
            "$set": {
                "battle_pass_tier": tier,
                "battle_pass_xp": new_xp
            }
        }
    )
    
    return {"tier": tier, "xp": new_xp}
