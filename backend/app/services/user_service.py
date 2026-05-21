from fastapi import HTTPException, status
from app.config.database import get_database
from app.schemas.user_schema import UserResponse, UserUpdate
from datetime import datetime

async def get_user_by_id(user_id: str) -> UserResponse:
    db = get_database()
    users_collection = db["users"]
    
    user = await users_collection.find_one({"_id": user_id})
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
        
    user["id"] = user.pop("_id")
    return UserResponse(**user)

async def update_user_profile(user_id: str, update_data: UserUpdate) -> UserResponse:
    db = get_database()
    users_collection = db["users"]
    
    update_dict = {k: v for k, v in update_data.model_dump().items() if v is not None}
    
    if not update_dict:
        return await get_user_by_id(user_id)
        
    update_dict["updated_at"] = datetime.utcnow().isoformat()
    
    if "equipped_cosmetics" in update_dict:
        # nested update for cosmetics
        cosmetics = update_dict.pop("equipped_cosmetics")
        for k, v in cosmetics.items():
            update_dict[f"equipped_cosmetics.{k}"] = v
    
    result = await users_collection.update_one(
        {"_id": user_id},
        {"$set": update_dict}
    )
    
    if result.matched_count == 0:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
        
    return await get_user_by_id(user_id)


async def gift_popularity(sender_id: str, target_id: str, amount: int = 10) -> dict:
    if sender_id == target_id:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Cannot gift popularity to yourself")

    db = get_database()
    users_collection = db["users"]
    
    sender = await users_collection.find_one({"_id": sender_id})
    if not sender:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Sender not found")
        
    if sender.get("influence", 0) < amount:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Not enough influence to gift popularity")
        
    target = await users_collection.find_one({"_id": target_id})
    if not target:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Target user not found")
        
    # Deduct from sender and add to target
    await users_collection.update_one({"_id": sender_id}, {"$inc": {"influence": -amount}})
    await users_collection.update_one({"_id": target_id}, {"$inc": {"popularity": amount}})
    
    return {"message": f"Successfully gifted {amount} popularity points", "target_id": target_id}
