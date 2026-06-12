from fastapi import HTTPException, status
from app.config.database import get_database
from datetime import datetime
import uuid

PACKAGES = {
    # Influence Points (Gold Coins)
    "pack_ip_small": {"currency": "influence", "amount": 500, "price": 0.99, "bonus": 0},
    "pack_ip_medium": {"currency": "influence", "amount": 1000, "price": 1.99, "bonus": 200},
    "pack_ip_large": {"currency": "influence", "amount": 2500, "price": 4.99, "bonus": 500},
    "pack_ip_mega": {"currency": "influence", "amount": 6000, "price": 9.99, "bonus": 1000},
    
    # Syndicate Coins (Premium Currency)
    "pack_sc_small": {"currency": "syndicate_coins", "amount": 100, "price": 0.99, "bonus": 0},
    "pack_sc_medium": {"currency": "syndicate_coins", "amount": 500, "price": 4.99, "bonus": 50},
    "pack_sc_large": {"currency": "syndicate_coins", "amount": 1000, "price": 9.99, "bonus": 200},
    "pack_sc_mega": {"currency": "syndicate_coins", "amount": 2000, "price": 19.99, "bonus": 500},
    
    # Special Bundles
    "starter_pack": {"currency": "syndicate_coins", "amount": 1000, "price": 4.99, "bonus": 500, "limit": 1},
}

async def process_payment(user_id: str, package_id: str, price: float, transaction_id: str, status_code: str) -> dict:
    db = get_database()
    users_collection = db["users"]
    tx_collection = db["transactions"]
    
    # 1. Validate Transaction Duplication
    existing_tx = await tx_collection.find_one({"transaction_id": transaction_id})
    if existing_tx:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Duplicate transaction detected")
        
    # 2. Validate Package
    package = PACKAGES.get(package_id)
    if not package:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid package ID")
        
    # 3. Validate Price (Anti-Tampering)
    if abs(package["price"] - price) > 0.01:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Price mismatch detected")
        
    # 4. Handle Failed Payments safely
    if status_code != "SUCCESS":
        # Record failed transaction
        failed_tx = {
            "_id": str(uuid.uuid4()),
            "user_id": user_id,
            "transaction_id": transaction_id,
            "package_id": package_id,
            "price": price,
            "status": "FAILED",
            "timestamp": datetime.utcnow().isoformat(),
            "reason": status_code
        }
        await tx_collection.insert_one(failed_tx)
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Payment failed: {status_code}")
        
    # 5. Check Package Limits (e.g., Starter Pack)
    if "limit" in package:
        user = await users_collection.find_one({"_id": user_id})
        purchase_history = user.get("purchase_history", [])
        times_bought = sum(1 for p in purchase_history if p.get("package_id") == package_id)
        if times_bought >= package["limit"]:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Package purchase limit reached")

    total_amount = package["amount"] + package["bonus"]
    currency_field = package["currency"]

    # 6. Record Successful Transaction
    success_tx = {
        "_id": str(uuid.uuid4()),
        "user_id": user_id,
        "transaction_id": transaction_id,
        "package_id": package_id,
        "price": price,
        "status": "SUCCESS",
        "timestamp": datetime.utcnow().isoformat(),
        "reward_granted": {
            "currency": currency_field,
            "total_amount": total_amount
        }
    }
    await tx_collection.insert_one(success_tx)
    
    # 7. Grant Rewards Atomically
    purchase_record = {
        "package_id": package_id,
        "transaction_id": transaction_id,
        "timestamp": datetime.utcnow().isoformat()
    }
    
    result = await users_collection.update_one(
        {"_id": user_id},
        {
            "$inc": {currency_field: total_amount},
            "$push": {"purchase_history": purchase_record}
        }
    )
    
    if result.modified_count == 0:
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to grant rewards")
        
    return {
        "message": "Payment successful",
        "transaction_id": transaction_id,
        "currency": currency_field,
        "amount_granted": total_amount
    }

async def get_transaction_history(user_id: str) -> list:
    db = get_database()
    tx_collection = db["transactions"]
    
    cursor = tx_collection.find({"user_id": user_id}).sort("timestamp", -1)
    transactions = await cursor.to_list(length=100)
    
    for tx in transactions:
        tx["id"] = tx.pop("_id")
        
    return transactions
