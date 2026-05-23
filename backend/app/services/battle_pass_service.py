from fastapi import HTTPException, status
from app.config.database import get_database

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
        
    # Mark as claimed
    if is_premium:
        update_op = {"$push": {"claimed_premium_tiers": tier}}
    else:
        update_op = {"$push": {"claimed_free_tiers": tier}}
        
    result = await users_collection.update_one({"_id": user_id}, update_op)
    
    if result.modified_count == 0:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to claim reward")
        
    return {"message": "Reward claimed successfully"}

async def buy_premium_pass(user_id: str) -> dict:
    db = get_database()
    users_collection = db["users"]
    
    user = await users_collection.find_one({"_id": user_id})
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
        
    if user.get("has_premium_pass", False):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Already own premium pass")
        
    # Cost is 1000 Syndicate Coins
    if user.get("syndicate_coins", 0) < 1000:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Not enough Syndicate Coins")
        
    result = await users_collection.update_one(
        {"_id": user_id},
        {
            "$set": {"has_premium_pass": True},
            "$inc": {"syndicate_coins": -1000}
        }
    )
    
    return {"message": "Premium pass purchased successfully"}

async def purchase_tier(user_id: str) -> dict:
    db = get_database()
    users_collection = db["users"]
    
    user = await users_collection.find_one({"_id": user_id})
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
        
    # Cost is 200 influence to unlock a tier early
    if user.get("influence", 0) < 200:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Not enough Influence")
        
    result = await users_collection.update_one(
        {"_id": user_id},
        {
            "$inc": {
                "battle_pass_tier": 1,
                "influence": -200
            }
        }
    )
    
    return {"message": "Tier purchased successfully"}
