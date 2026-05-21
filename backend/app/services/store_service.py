from fastapi import HTTPException, status
from app.config.database import get_database

async def purchase_item(user_id: str, item_id: str, currency: str, price: int, category: str) -> dict:
    db = get_database()
    users_collection = db["users"]
    
    user = await users_collection.find_one({"_id": user_id})
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
        
    # Check if user already owns the item
    inventory = user.get("inventory", {})
    category_items = inventory.get(category, [])
    if item_id in category_items:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="You already own this item")
        
    # Check currency balance
    if currency == "syndicate":
        balance = user.get("syndicate_coins", 0)
        if balance < price:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Not enough Syndicate Coins")
        update_op = {"$inc": {"syndicate_coins": -price}}
    elif currency == "influence":
        balance = user.get("influence", 0)
        if balance < price:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Not enough Influence Points")
        update_op = {"$inc": {"influence": -price}}
    else:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid currency type")
        
    # Add item to inventory
    update_op.setdefault("$push", {})[f"inventory.{category}"] = item_id
    
    result = await users_collection.update_one(
        {"_id": user_id},
        update_op
    )
    
    if result.modified_count == 0:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to process purchase")
        
    return {"message": "Purchase successful", "item_id": item_id}
