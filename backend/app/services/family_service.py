from fastapi import HTTPException, status
from app.config.database import get_database
from app.models.family_model import (
    FamilyDB, FamilyMemberDB, FamilyAuditEntryDB,
    FamilyChatMessageDB, FamilyApplicationDB, TreasuryDonationDB
)
from datetime import datetime
import uuid


async def create_family(user_id: str, name: str, tag: str, description: str = "",
                        slogan: str = "", privacy: str = "approvalRequired"):
    db = get_database()

    # Check user doesn't already have a family
    user = await db["users"].find_one({"_id": user_id})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    if user.get("family_id"):
        raise HTTPException(status_code=400, detail="Already in a family")
    
    if user.get("syndicate_coins", 0) < 500:
        raise HTTPException(status_code=400, detail="Insufficient Syndicate Coins. You need 500.")

    # Check tag uniqueness
    existing = await db["families"].find_one({"tag": f"[{tag.upper()}]"})
    if existing:
        raise HTTPException(status_code=400, detail="Family tag already taken")

    family_id = str(uuid.uuid4())
    member = FamilyMemberDB(
        user_id=user_id,
        username=user.get("username", ""),
        role="boss",
        rank_tier=_rank_to_tier(user.get("rank", "Bronze")),
        rank_points=user.get("mmr", 0),
        total_games=user.get("games_played", 0),
    )

    family = FamilyDB(
        _id=family_id, name=name, tag=f"[{tag.upper()}]",
        description=description, slogan=slogan, privacy=privacy,
        members=[member], created_by=user_id,
    )

    audit = FamilyAuditEntryDB(
        action="familyCreated", actor_id=user_id,
        actor_name=user.get("username", ""),
    )
    family_dict = family.model_dump(by_alias=True)
    family_dict["audit_log"] = [audit.model_dump()]

    await db["families"].insert_one(family_dict)
    await db["users"].update_one(
        {"_id": user_id}, 
        {
            "$set": {"family_id": family_id},
            "$inc": {"syndicate_coins": -500}
        }
    )

    return family_dict


async def get_family(user_id: str):
    db = get_database()
    user = await db["users"].find_one({"_id": user_id})
    if not user or not user.get("family_id"):
        return None

    family = await db["families"].find_one({"_id": user["family_id"]})
    if family:
        family["id"] = family.pop("_id", family.get("id"))
        from app.core.websocket_manager import manager
        for member in family.get("members", []):
            if member["user_id"] in manager.active_connections:
                member["activity"] = "online"
            else:
                member["activity"] = "offline"
    return family


async def search_families(query: str):
    db = get_database()
    if not query.strip():
        results = []
        async for f in db["families"].find().limit(20):
            f["id"] = f.pop("_id", f.get("id"))
            results.append(f)
        return results

    results = []
    async for f in db["families"].find({
        "$or": [
            {"name": {"$regex": query, "$options": "i"}},
            {"tag": {"$regex": query, "$options": "i"}},
        ]
    }).limit(20):
        f["id"] = f.pop("_id", f.get("id"))
        results.append(f)
    return results


async def leave_family(user_id: str):
    db = get_database()
    user = await db["users"].find_one({"_id": user_id})
    if not user or not user.get("family_id"):
        raise HTTPException(status_code=400, detail="Not in a family")

    family_id = user["family_id"]
    family = await db["families"].find_one({"_id": family_id})
    if not family:
        raise HTTPException(status_code=404, detail="Family not found")

    # Remove member
    await db["families"].update_one(
        {"_id": family_id},
        {
            "$pull": {"members": {"user_id": user_id}},
            "$push": {"audit_log": {
                "id": str(uuid.uuid4()), "action": "memberLeft",
                "actor_id": user_id, "actor_name": user.get("username", ""),
                "timestamp": datetime.utcnow().isoformat(),
            }}
        }
    )
    await db["users"].update_one({"_id": user_id}, {"$set": {"family_id": None}})

    # If boss left and members remain, transfer to first underboss/capo
    members = [m for m in family.get("members", []) if m["user_id"] != user_id]
    if members:
        boss_check = [m for m in members if m.get("role") == "boss"]
        if not boss_check:
            new_boss = members[0]
            await db["families"].update_one(
                {"_id": family_id, "members.user_id": new_boss["user_id"]},
                {"$set": {"members.$.role": "boss"}}
            )
    elif not members:
        # Delete empty family
        await db["families"].delete_one({"_id": family_id})

    return {"message": "Left family"}


async def delete_family(user_id: str):
    db = get_database()
    user = await db["users"].find_one({"_id": user_id})
    if not user or not user.get("family_id"):
        raise HTTPException(status_code=400, detail="Not in a family")

    family_id = user["family_id"]
    family = await db["families"].find_one({"_id": family_id})
    if not family:
        raise HTTPException(status_code=404, detail="Family not found")
        
    # verify user is boss
    boss = next((m for m in family.get("members", []) if m["user_id"] == user_id and m.get("role", "").lower() == "boss"), None)
    if not boss:
        raise HTTPException(status_code=403, detail="Only the Boss can delete the family")
        
    # Delete the family
    await db["families"].delete_one({"_id": family_id})
    
    # Remove family_id from all members
    member_ids = [m["user_id"] for m in family.get("members", [])]
    await db["users"].update_many(
        {"_id": {"$in": member_ids}},
        {"$set": {"family_id": None}}
    )
    
    return {"message": "Family deleted successfully"}


async def update_family_settings(user_id: str, updates: dict):
    db = get_database()
    user = await db["users"].find_one({"_id": user_id})
    if not user or not user.get("family_id"):
        raise HTTPException(status_code=400, detail="Not in a family")

    family_id = user["family_id"]

    set_dict = {}
    for key in ["name", "tag", "description", "slogan", "motd", "privacy"]:
        if key in updates and updates[key] is not None:
            set_dict[key] = updates[key]

    if "motd" in set_dict:
        set_dict["motd_updated_at"] = datetime.utcnow().isoformat()

    if set_dict:
        await db["families"].update_one({"_id": family_id}, {"$set": set_dict})
        await db["families"].update_one({"_id": family_id}, {"$push": {"audit_log": {
            "id": str(uuid.uuid4()), "action": "settingsChanged",
            "actor_id": user_id, "actor_name": user.get("username", ""),
            "timestamp": datetime.utcnow().isoformat(),
        }}})

    family = await db["families"].find_one({"_id": family_id})
    family["id"] = family.pop("_id", family.get("id"))
    return family


async def kick_member(user_id: str, target_user_id: str):
    db = get_database()
    user = await db["users"].find_one({"_id": user_id})
    family_id = user.get("family_id") if user else None
    if not family_id:
        raise HTTPException(status_code=400, detail="Not in a family")

    target = await db["users"].find_one({"_id": target_user_id})
    await db["families"].update_one(
        {"_id": family_id},
        {
            "$pull": {"members": {"user_id": target_user_id}},
            "$push": {"audit_log": {
                "id": str(uuid.uuid4()), "action": "memberKicked",
                "actor_id": user_id, "actor_name": user.get("username", ""),
                "target_name": target.get("username", "") if target else "",
                "timestamp": datetime.utcnow().isoformat(),
            }}
        }
    )
    await db["users"].update_one({"_id": target_user_id}, {"$set": {"family_id": None}})
    return {"message": "Member kicked"}


async def promote_member(user_id: str, target_user_id: str):
    db = get_database()
    user = await db["users"].find_one({"_id": user_id})
    family_id = user.get("family_id") if user else None
    if not family_id:
        raise HTTPException(status_code=400, detail="Not in a family")

    family = await db["families"].find_one({"_id": family_id})
    target_member = next((m for m in family.get("members", []) if m["user_id"] == target_user_id), None)
    if not target_member:
        raise HTTPException(status_code=404, detail="Member not found")

    promotion_map = {"associate": "capo", "capo": "underboss"}
    new_role = promotion_map.get(target_member.get("role", "associate"), target_member.get("role"))

    await db["families"].update_one(
        {"_id": family_id, "members.user_id": target_user_id},
        {"$set": {"members.$.role": new_role}}
    )
    await db["families"].update_one({"_id": family_id}, {"$push": {"audit_log": {
        "id": str(uuid.uuid4()), "action": "memberPromoted",
        "actor_id": user_id, "actor_name": user.get("username", ""),
        "target_name": target_member.get("username", ""),
        "timestamp": datetime.utcnow().isoformat(),
    }}})
    
    from app.core.websocket_manager import manager
    member_ids = [m["user_id"] for m in family.get("members", [])]
    ws_msg = {
        "event": "family_member_updated",
        "data": {
            "target_user_id": target_user_id,
            "target_name": target_member.get("username", ""),
            "new_role": new_role,
            "action": "promoted"
        }
    }
    await manager.broadcast_to_users(ws_msg, member_ids)

    return {"message": f"Member promoted to {new_role}"}


async def demote_member(user_id: str, target_user_id: str):
    db = get_database()
    user = await db["users"].find_one({"_id": user_id})
    family_id = user.get("family_id") if user else None
    if not family_id:
        raise HTTPException(status_code=400, detail="Not in a family")

    family = await db["families"].find_one({"_id": family_id})
    target_member = next((m for m in family.get("members", []) if m["user_id"] == target_user_id), None)
    if not target_member:
        raise HTTPException(status_code=404, detail="Member not found")

    demotion_map = {"underboss": "capo", "capo": "associate"}
    new_role = demotion_map.get(target_member.get("role", "associate"), target_member.get("role"))

    await db["families"].update_one(
        {"_id": family_id, "members.user_id": target_user_id},
        {"$set": {"members.$.role": new_role}}
    )
    await db["families"].update_one({"_id": family_id}, {"$push": {"audit_log": {
        "id": str(uuid.uuid4()), "action": "memberDemoted",
        "actor_id": user_id, "actor_name": user.get("username", ""),
        "target_name": target_member.get("username", ""),
        "timestamp": datetime.utcnow().isoformat(),
    }}})
    
    from app.core.websocket_manager import manager
    member_ids = [m["user_id"] for m in family.get("members", [])]
    ws_msg = {
        "event": "family_member_updated",
        "data": {
            "target_user_id": target_user_id,
            "target_name": target_member.get("username", ""),
            "new_role": new_role,
            "action": "demoted"
        }
    }
    await manager.broadcast_to_users(ws_msg, member_ids)
    
    return {"message": f"Member demoted to {new_role}"}

async def mute_member(user_id: str, target_user_id: str):
    db = get_database()
    user = await db["users"].find_one({"_id": user_id})
    family_id = user.get("family_id") if user else None
    if not family_id:
        raise HTTPException(status_code=400, detail="Not in a family")

    family = await db["families"].find_one({"_id": family_id})
    target_member = next((m for m in family.get("members", []) if m["user_id"] == target_user_id), None)
    if not target_member:
        raise HTTPException(status_code=404, detail="Member not found")

    is_muted = target_member.get("is_muted", False)
    
    await db["families"].update_one(
        {"_id": family_id, "members.user_id": target_user_id},
        {"$set": {"members.$.is_muted": not is_muted}}
    )
    
    action = "memberMuted" if not is_muted else "memberUnmuted"
    await db["families"].update_one({"_id": family_id}, {"$push": {"audit_log": {
        "id": str(uuid.uuid4()), "action": action,
        "actor_id": user_id, "actor_name": user.get("username", ""),
        "target_name": target_member.get("username", ""),
        "timestamp": datetime.utcnow().isoformat(),
    }}})
    return {"message": f"Member {'muted' if not is_muted else 'unmuted'}"}



async def donate_to_treasury(user_id: str, amount: int):
    db = get_database()
    user = await db["users"].find_one({"_id": user_id})
    family_id = user.get("family_id") if user else None
    if not family_id:
        raise HTTPException(status_code=400, detail="Not in a family")

    if user.get("influence", 0) < amount:
        raise HTTPException(status_code=400, detail="Not enough influence")

    donation = {
        "id": str(uuid.uuid4()),
        "user_id": user_id,
        "username": user.get("username", ""),
        "amount": amount,
        "timestamp": datetime.utcnow().isoformat(),
    }

    await db["families"].update_one(
        {"_id": family_id},
        {
            "$inc": {"treasury.balance": amount},
            "$push": {"treasury.recent_donations": {"$each": [donation], "$position": 0, "$slice": 50}},
        }
    )
    await db["users"].update_one({"_id": user_id}, {"$inc": {"influence": -amount}})
    await db["families"].update_one({"_id": family_id}, {"$push": {"audit_log": {
        "id": str(uuid.uuid4()), "action": "treasuryDonation",
        "actor_id": user_id, "actor_name": user.get("username", ""),
        "details": str(amount),
        "timestamp": datetime.utcnow().isoformat(),
    }}})

    # Broadcast update
    family = await db["families"].find_one({"_id": family_id})
    if family:
        from app.core.websocket_manager import manager
        member_ids = [m["user_id"] for m in family.get("members", [])]
        ws_msg = {
            "event": "family_treasury_update",
            "data": {
                "treasury": family.get("treasury", {})
            }
        }
        await manager.broadcast_to_users(ws_msg, member_ids)

    return {"message": f"Donated {amount} to treasury"}


async def send_chat_message(user_id: str, content: str):
    db = get_database()
    user = await db["users"].find_one({"_id": user_id})
    family_id = user.get("family_id") if user else None
    if not family_id:
        raise HTTPException(status_code=400, detail="Not in a family")

    msg = {
        "id": str(uuid.uuid4()),
        "sender_id": user_id,
        "sender_name": user.get("username", ""),
        "content": content,
        "type": "user",
        "timestamp": datetime.utcnow().isoformat(),
        "is_pinned": False,
        "mentions": [],
    }
    await db["families"].update_one(
        {"_id": family_id},
        {"$push": {"chat_messages": msg}}
    )

    family = await db["families"].find_one({"_id": family_id})
    if family:
        from app.core.websocket_manager import manager
        member_ids = [m["user_id"] for m in family.get("members", [])]
        ws_msg = {
            "event": "family_chat",
            "data": {
                "message": msg
            }
        }
        await manager.broadcast_to_users(ws_msg, member_ids)

    return msg


async def get_chat_messages(user_id: str):
    db = get_database()
    user = await db["users"].find_one({"_id": user_id})
    family_id = user.get("family_id") if user else None
    if not family_id:
        return []
    family = await db["families"].find_one({"_id": family_id})
    return family.get("chat_messages", []) if family else []

async def clear_chat_history(user_id: str):
    db = get_database()
    user = await db["users"].find_one({"_id": user_id})
    family_id = user.get("family_id") if user else None
    if not family_id:
        raise HTTPException(status_code=400, detail="Not in a family")

    family = await db["families"].find_one({"_id": family_id})
    if not family:
        raise HTTPException(status_code=404, detail="Family not found")
        
    # verify user is boss
    boss = next((m for m in family.get("members", []) if m["user_id"] == user_id and m.get("role", "").lower() == "boss"), None)
    if not boss:
        raise HTTPException(status_code=403, detail="Only the Boss can clear chat history")
        
    # Clear chat messages
    await db["families"].update_one(
        {"_id": family_id},
        {"$set": {"chat_messages": []}}
    )
    
    # Broadcast clear event to clients
    from app.core.websocket_manager import manager
    member_ids = [m["user_id"] for m in family.get("members", [])]
    ws_msg = {
        "event": "family_chat_cleared",
        "data": {}
    }
    await manager.broadcast_to_users(ws_msg, member_ids)

    return {"message": "Chat history cleared successfully"}


async def apply_to_family(user_id: str, family_id: str, message: str = "", is_invite: bool = False):
    db = get_database()
    user = await db["users"].find_one({"_id": user_id})
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    if user.get("family_id"):
        raise HTTPException(status_code=400, detail="Already in a family")

    family = await db["families"].find_one({"_id": family_id})
    if not family:
        raise HTTPException(status_code=404, detail="Family not found")

    # Check for existing pending application
    existing_apps = family.get("applications", [])
    for app in existing_apps:
        if app["applicant_id"] == user_id and app["status"] == "pending":
            if is_invite:
                # remove the application because they are now auto joining
                await db["families"].update_one(
                    {"_id": family_id},
                    {"$pull": {"applications": {"applicant_id": user_id, "status": "pending"}}}
                )
            else:
                raise HTTPException(status_code=400, detail="Application already pending")

    app = {
        "id": str(uuid.uuid4()),
        "applicant_id": user_id,
        "applicant_name": user.get("username", ""),
        "family_id": family_id,
        "rank_tier": _rank_to_tier(user.get("rank", "Bronze")),
        "rank_points": user.get("mmr", 0),
        "win_rate": 0.0,
        "total_games": user.get("games_played", 0),
        "trust_rating": user.get("trust_rating", 0),
        "popularity_score": user.get("popularity", 0),
        "message": message,
        "status": "pending",
        "submitted_at": datetime.utcnow().isoformat(),
    }

    # If family is public, or it's an invite, auto-join
    if family.get("privacy") == "public" or is_invite:
        member = {
            "user_id": user_id,
            "username": user.get("username", ""),
            "role": "associate",
            "rank_tier": _rank_to_tier(user.get("rank", "Bronze")),
            "rank_points": user.get("mmr", 0),
            "total_games": user.get("games_played", 0),
            "joined_at": datetime.utcnow().isoformat(),
        }
        await db["families"].update_one(
            {"_id": family_id},
            {"$push": {"members": member, "audit_log": {
                "id": str(uuid.uuid4()), "action": "memberJoined",
                "actor_id": user_id, "actor_name": user.get("username", ""),
                "timestamp": datetime.utcnow().isoformat(),
            }}}
        )
        await db["users"].update_one({"_id": user_id}, {"$set": {"family_id": family_id}})
        return {"message": "Joined family"}

    await db["families"].update_one(
        {"_id": family_id},
        {"$push": {"applications": app}}
    )
    
    from app.core.websocket_manager import manager
    for m in family.get("members", []):
        await manager.send_personal_message(m["user_id"], {
            "event": "family_application",
            "app": app
        })

    return {"message": "Application submitted"}


async def handle_application(user_id: str, app_id: str, accept: bool):
    db = get_database()
    user = await db["users"].find_one({"_id": user_id})
    family_id = user.get("family_id") if user else None
    if not family_id:
        raise HTTPException(status_code=400, detail="Not in a family")

    family = await db["families"].find_one({"_id": family_id})
    if not family:
        raise HTTPException(status_code=404, detail="Family not found")

    app = next((a for a in family.get("applications", []) if a["id"] == app_id), None)
    if not app:
        raise HTTPException(status_code=404, detail="Application not found")

    new_status = "accepted" if accept else "rejected"

    # Update application status
    await db["families"].update_one(
        {"_id": family_id, "applications.id": app_id},
        {"$set": {
            "applications.$.status": new_status,
            "applications.$.reviewed_by": user_id,
            "applications.$.reviewed_at": datetime.utcnow().isoformat(),
        }}
    )

    if accept:
        member = {
            "user_id": app["applicant_id"],
            "username": app["applicant_name"],
            "role": "associate",
            "rank_tier": app.get("rank_tier", 0),
            "rank_points": app.get("rank_points", 0),
            "total_games": app.get("total_games", 0),
            "joined_at": datetime.utcnow().isoformat(),
        }
        await db["families"].update_one(
            {"_id": family_id},
            {"$push": {"members": member, "audit_log": {
                "id": str(uuid.uuid4()), "action": "memberJoined",
                "actor_id": app["applicant_id"],
                "actor_name": app["applicant_name"],
                "timestamp": datetime.utcnow().isoformat(),
            }}}
        )
        await db["users"].update_one(
            {"_id": app["applicant_id"]},
            {"$set": {"family_id": family_id}}
        )

    return {"message": f"Application {new_status}"}


async def activate_boost(user_id: str, boost_type: str):
    db = get_database()
    user = await db["users"].find_one({"_id": user_id})
    family_id = user.get("family_id") if user else None
    if not family_id:
        raise HTTPException(status_code=400, detail="Not in a family")
        
    family = await db["families"].find_one({"_id": family_id})
    if not family:
        raise HTTPException(status_code=404, detail="Family not found")
        
    # Boost costs matching frontend
    boost_costs = {
        "influenceBonus": 500,
        "battlePassXP": 750,
        "matchmakingSpeed": 300,
        "familyXPDouble": 1000
    }
    
    cost = boost_costs.get(boost_type, 1000)
    
    treasury = family.get("treasury", {})
    balance = treasury.get("balance", 0)
    
    if balance < cost:
        raise HTTPException(status_code=400, detail=f"Not enough treasury balance. Need {cost}.")
        
    # Check if boost is already active
    active_boosts = treasury.get("active_boosts", [])
    now = datetime.utcnow()
    
    # Filter out expired boosts first (optional but good for cleanup)
    active_boosts = [b for b in active_boosts if datetime.fromisoformat(b["expires_at"]) > now]
    
    if any(b["type"] == boost_type for b in active_boosts):
        raise HTTPException(status_code=400, detail="Boost is already active")
        
    # Create new boost
    from datetime import timedelta
    expires_at = (now + timedelta(hours=24)).isoformat()
    
    new_boost = {
        "id": str(uuid.uuid4()),
        "type": boost_type,
        "activated_at": now.isoformat(),
        "expires_at": expires_at,
        "activated_by": user.get("username", "")
    }
    
    await db["families"].update_one(
        {"_id": family_id},
        {
            "$inc": {"treasury.balance": -cost},
            "$set": {"treasury.active_boosts": active_boosts + [new_boost]},
            "$push": {"audit_log": {
                "id": str(uuid.uuid4()), "action": "boostActivated",
                "actor_id": user_id, "actor_name": user.get("username", ""),
                "details": boost_type,
                "timestamp": now.isoformat(),
            }}
        }
    )
    
    # Broadcast update
    family = await db["families"].find_one({"_id": family_id})
    if family:
        from app.core.websocket_manager import manager
        member_ids = [m["user_id"] for m in family.get("members", [])]
        ws_msg = {
            "event": "family_treasury_update",
            "data": {
                "treasury": family.get("treasury", {})
            }
        }
        await manager.broadcast_to_users(ws_msg, member_ids)
        
    return {"message": "Boost activated successfully"}


async def get_rivalries(user_id: str):
    db = get_database()
    user = await db["users"].find_one({"_id": user_id})
    family_id = user.get("family_id") if user else None
    if not family_id:
        return []
        
    family = await db["families"].find_one({"_id": family_id})
    if not family:
        return []
        
    return family.get("rivalries", [])


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

async def transfer_boss(user_id: str, target_user_id: str) -> dict:
    db = get_database()
    family = await db["families"].find_one({
        "members": {
            "$elemMatch": {
                "user_id": user_id,
                "role": {"$regex": "^boss$", "$options": "i"}
            }
        }
    })
    if not family:
        raise HTTPException(status_code=403, detail="Not the boss of any family")
        
    # Check if target is in family
    target_in_family = any(m["user_id"] == target_user_id for m in family.get("members", []))
    if not target_in_family:
        raise HTTPException(status_code=400, detail="Target user not in family")
        
    # Demote current boss to underboss, promote target to boss
    await db["families"].update_one(
        {"_id": family["_id"], "members.user_id": user_id},
        {"$set": {"members.$.role": "underboss"}}
    )
    await db["families"].update_one(
        {"_id": family["_id"], "members.user_id": target_user_id},
        {"$set": {"members.$.role": "boss"}}
    )
    return {"status": "success", "message": "Ownership transferred"}

async def pin_message(user_id: str, msg_id: str) -> dict:
    db = get_database()
    # verify user is boss/underboss
    family = await db["families"].find_one({"members.user_id": user_id, "members.role": {"$in": ["Boss", "Underboss"]}})
    if not family:
        raise HTTPException(status_code=403, detail="Not authorized to pin messages")
        
    from bson.objectid import ObjectId
    try:
        obj_id = ObjectId(msg_id)
    except:
        raise HTTPException(status_code=400, detail="Invalid message ID")
        
    await db["family_chats"].update_one(
        {"_id": obj_id, "family_id": str(family["_id"])},
        {"$set": {"is_pinned": True}}
    )
    return {"status": "success", "message": "Message pinned"}

async def get_achievements(user_id: str):
    db = get_database()
    user = await db["users"].find_one({"_id": user_id})
    family_id = user.get("family_id") if user else None
    if not family_id:
        return []
        
    family = await db["families"].find_one({"_id": family_id})
    if not family:
        return []
        
    return family.get("achievements", [])
