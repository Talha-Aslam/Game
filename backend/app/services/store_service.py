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
