from fastapi import HTTPException, status
from app.config.database import get_database
from pymongo import ReturnDocument

async def purchase_item(user_id: str, item_id: str, currency: str, price: int, category: str) -> dict:
    db = get_database()
    users_collection = db["users"]
    
    # 1. Determine field name based on currency
    balance_field = "syndicate_coins" if currency == "syndicate" else "influence"
    
    # 2. Atomic find and update:
    # - Ensure user exists
    # - Ensure balance is >= price (Database-level check prevents race conditions)
    # - Ensure user doesn't already own the item in that category
    try:
        query = {
            "_id": user_id,
            balance_field: {"$gte": price},
            f"inventory.{category}": {"$ne": item_id}
        }
        
        update = {
            "$inc": {balance_field: -price},
            "$push": {f"inventory.{category}": item_id}
        }
        
        updated_user = await users_collection.find_one_and_update(
            query,
            update,
            return_document=ReturnDocument.AFTER
        )
        
        if not updated_user:
            # Check why it failed
            user = await users_collection.find_one({"_id": user_id})
            if not user:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
            
            # Check if owned
            inventory = user.get("inventory", {})
            if item_id in inventory.get(category, []):
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Item already owned")
                
            # Must be insufficient funds
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Insufficient funds")
            
        return {
            "message": "Purchase successful",
            "item_id": item_id,
            "new_balance": updated_user.get(balance_field, 0),
            "currency": currency
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"Transaction failed: {str(e)}")

async def equip_item(user_id: str, item_id: str, category: str) -> dict:
    db = get_database()
    users_collection = db["users"]
    
    # 1. Fetch user to verify ownership
    user = await users_collection.find_one({"_id": user_id})
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
        
    inventory = user.get("inventory", {})
    
    # 2. Verify ownership in the specific category
    owned_list = inventory.get(category, [])
    # Support 'default' or checking the actual list
    if item_id != "default" and item_id not in owned_list:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Item not owned")
        
    # 3. Map Store Category to Equipped Cosmetic field
    field_map = {
        "cardStyles": "equipped_cosmetics.background",
        "borders": "equipped_cosmetics.card_border",
        "voicePacks": "equipped_cosmetics.voice_pack",
        "eliminationEffects": "equipped_cosmetics.nameplate"
    }
    
    target_field = field_map.get(category)
    update_op = {}
    
    if target_field:
        update_op = {"$set": {target_field: item_id}}
    elif category == "avatars":
        # Avatars are special fields in UserDB
        update_op = {"$set": {"premium_avatar": item_id, "using_premium_avatar": True}}
        
    if not update_op:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid equip category")
        
    # 4. Atomic update
    updated_user = await users_collection.find_one_and_update(
        {"_id": user_id},
        update_op,
        return_document=ReturnDocument.AFTER
    )
    
    return {
        "message": "Equipped successfully",
        "equipped_cosmetics": updated_user.get("equipped_cosmetics", {}),
        "premium_avatar": updated_user.get("premium_avatar", ""),
        "using_premium_avatar": updated_user.get("using_premium_avatar", False)
    }
