from fastapi import HTTPException, status
from app.config.database import get_database
from datetime import datetime
import uuid
from app.core.websocket_manager import manager


# ══════════════════════════════════════════════════════
#  FRIENDS / SOCIAL
# ══════════════════════════════════════════════════════

async def get_friends_list(user_id: str):
    db = get_database()
    user = await db["users"].find_one({"_id": user_id})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    friend_ids = user.get("friends", [])
    if not friend_ids:
        return []

    friends = []
    async for f in db["users"].find({"_id": {"$in": friend_ids}}):
        friends.append({
            "id": f["_id"],
            "username": f.get("username", ""),
            "avatarUrl": f.get("profile_picture", ""),
            "rankTier": _rank_to_tier(f.get("rank", "Bronze")),
            "familyTag": None,  # resolved later if needed
            "popularityScore": f.get("popularity", 0),
            "onlineStatus": "online" if f["_id"] in manager.active_connections else "offline",
            "currentActivity": "idle",
            "mutualFriendCount": 0,
            "unreadCount": await db["private_messages"].count_documents({
                "from_user_id": f["_id"],
                "to_user_id": user_id,
                "is_read": False
            }),
        })

    # Resolve family tags
    for friend in friends:
        fuser = await db["users"].find_one({"_id": friend["id"]})
        if fuser and fuser.get("family_id"):
            fam = await db["families"].find_one({"_id": fuser["family_id"]})
            if fam:
                friend["familyTag"] = fam.get("tag", "")

    return friends


async def get_friend_requests(user_id: str):
    db = get_database()
    requests = []
    async for req in db["friend_requests"].find({
        "$or": [{"to_user_id": user_id}, {"from_user_id": user_id}],
        "status": "pending"
    }):
        from_user = await db["users"].find_one({"_id": req["from_user_id"]})
        requests.append({
            "id": str(req["_id"]),
            "fromUser": {
                "id": req["from_user_id"],
                "username": from_user.get("username", "") if from_user else "Unknown",
                "rankTier": _rank_to_tier(from_user.get("rank", "Bronze")) if from_user else 0,
                "popularityScore": from_user.get("popularity", 0) if from_user else 0,
            },
            "toUserId": req["to_user_id"],
            "timestamp": req.get("created_at", ""),
            "isIncoming": req["to_user_id"] == user_id,
            "mutualFriendCount": 0,
            "status": req["status"],
        })
    return requests


async def send_friend_request(from_user_id: str, to_user_id: str):
    db = get_database()

    # Check target exists
    target = await db["users"].find_one({"_id": to_user_id})
    if not target:
        raise HTTPException(status_code=404, detail="User not found")

    # Check not already friends
    sender = await db["users"].find_one({"_id": from_user_id})
    if to_user_id in sender.get("friends", []):
        raise HTTPException(status_code=400, detail="Already friends")

    # Check no duplicate pending request
    existing = await db["friend_requests"].find_one({
        "from_user_id": from_user_id,
        "to_user_id": to_user_id,
        "status": "pending"
    })
    if existing:
        raise HTTPException(status_code=400, detail="Request already sent")

    await db["friend_requests"].insert_one({
        "_id": str(uuid.uuid4()),
        "from_user_id": from_user_id,
        "to_user_id": to_user_id,
        "status": "pending",
        "created_at": datetime.utcnow().isoformat(),
    })
    return {"message": "Friend request sent"}


async def accept_friend_request(user_id: str, request_id: str):
    db = get_database()
    req = await db["friend_requests"].find_one({"_id": request_id, "to_user_id": user_id})
    if not req:
        raise HTTPException(status_code=404, detail="Request not found")

    # Update request status
    await db["friend_requests"].update_one(
        {"_id": request_id},
        {"$set": {"status": "accepted"}}
    )

    # Add each user to the other's friends list
    await db["users"].update_one(
        {"_id": user_id},
        {"$addToSet": {"friends": req["from_user_id"]}}
    )
    await db["users"].update_one(
        {"_id": req["from_user_id"]},
        {"$addToSet": {"friends": user_id}}
    )
    
    # Notify both users via WebSocket
    event = {
        "type": "friend_request_accepted",
        "message": "Friend request accepted!"
    }
    await manager.send_personal_message(event, user_id)
    await manager.send_personal_message(event, req["from_user_id"])
    
    return {"message": "Friend request accepted"}

async def reject_friend_request(user_id: str, request_id: str):
    db = get_database()
    req = await db["friend_requests"].find_one({"_id": request_id, "to_user_id": user_id})
    if not req:
        raise HTTPException(status_code=404, detail="Request not found")

    await db["friend_requests"].update_one(
        {"_id": request_id},
        {"$set": {"status": "rejected"}}
    )
    return {"message": "Friend request rejected"}


async def remove_friend(user_id: str, friend_id: str):
    db = get_database()
    await db["users"].update_one({"_id": user_id}, {"$pull": {"friends": friend_id}})
    await db["users"].update_one({"_id": friend_id}, {"$pull": {"friends": user_id}})
    return {"message": "Friend removed"}


async def search_users(query: str, current_user_id: str):
    db = get_database()
    if not query.strip():
        return []

    results = []
    async for u in db["users"].find({
        "$or": [
            {"username": {"$regex": query, "$options": "i"}},
            {"_id": {"$regex": f"^{query}", "$options": "i"}}
        ]
    }).limit(20):
        if u["_id"] == current_user_id:
            continue
        results.append({
            "id": u["_id"],
            "username": u.get("username", ""),
            "avatarUrl": u.get("profile_picture", ""),
            "rankTier": _rank_to_tier(u.get("rank", "Bronze")),
            "popularityScore": u.get("popularity", 0),
            "onlineStatus": "offline",
        })
    return results


# ══════════════════════════════════════════════════════
#  PRIVATE CHAT
# ══════════════════════════════════════════════════════

async def get_private_chat_history(user_id: str, friend_id: str, limit: int = 50):
    db = get_database()
    messages = []
    
    # Sort by timestamp descending
    cursor = db["private_messages"].find({
        "$or": [
            {"from_user_id": user_id, "to_user_id": friend_id},
            {"from_user_id": friend_id, "to_user_id": user_id}
        ]
    }).sort("timestamp", -1).limit(limit)
    
    async for msg in cursor:
        messages.append({
            "id": str(msg["_id"]),
            "senderId": msg["from_user_id"],
            "content": msg["content"],
            "timestamp": msg["timestamp"].isoformat() if isinstance(msg["timestamp"], datetime) else msg["timestamp"]
        })
    
    # Return ascending order for UI (index 0 is bottom in reverse ListView)
    return messages

async def save_private_message(from_user_id: str, to_user_id: str, content: str):
    db = get_database()
    msg = {
        "from_user_id": from_user_id,
        "to_user_id": to_user_id,
        "content": content,
        "timestamp": datetime.utcnow(),
        "is_read": False
    }
    result = await db["private_messages"].insert_one(msg)
    return {
        "id": str(result.inserted_id),
        "senderId": from_user_id,
        "content": content,
        "timestamp": msg["timestamp"].isoformat()
    }

async def mark_messages_read(user_id: str, friend_id: str):
    db = get_database()
    await db["private_messages"].update_many(
        {"from_user_id": friend_id, "to_user_id": user_id, "is_read": False},
        {"$set": {"is_read": True}}
    )
    return {"message": "Messages marked as read"}

# ══════════════════════════════════════════════════════
#  LEADERBOARD
# ══════════════════════════════════════════════════════

async def get_leaderboard(limit: int = 50):
    db = get_database()
    entries = []
    position = 1
    async for u in db["users"].find().sort("mmr", -1).limit(limit):
        fam_tag = None
        if u.get("family_id"):
            fam = await db["families"].find_one({"_id": u["family_id"]})
            if fam:
                fam_tag = fam.get("tag")
        entries.append({
            "position": position,
            "id": u["_id"],
            "username": u.get("username", ""),
            "avatarUrl": u.get("profile_picture", ""),
            "rankTier": _rank_to_tier(u.get("rank", "Bronze")),
            "points": u.get("mmr", 0),
            "familyTag": fam_tag,
            "wins": u.get("wins", 0),
            "losses": u.get("losses", 0),
        })
        position += 1
    return entries


# ══════════════════════════════════════════════════════
#  HELPERS
# ══════════════════════════════════════════════════════

def _rank_to_tier(rank_val) -> int:
    if isinstance(rank_val, int):
        return rank_val
    if isinstance(rank_val, str):
        r = rank_val.lower()
        if "silver" in r:
            return 1
        if "gold" in r:
            return 2
        if "diamond" in r:
            return 3
        if "boss" in r or "syndicate" in r:
            return 4
    return 0
