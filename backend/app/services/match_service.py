import logging
from typing import List, Dict, Any
from app.config.database import get_database

logger = logging.getLogger(__name__)

async def resolve_match_results(players: List[Any], winner_faction: str) -> None:
    """
    Updates the database with match results for all players in the room.
    players: List of Player objects from game_engine.
    winner_faction: 'civilians' or 'mafia'
    """
    db = get_database()
    users_collection = db["users"]
    
    logger.info(f"Resolving match results. Winner faction: {winner_faction}")

    for p in players:
        # Ignore bots, they don't have database records
        if p.is_bot:
            continue
            
        is_winner = False
        if winner_faction == "mafia" and p.role == "mafia":
            is_winner = True
        elif winner_faction == "civilians" and p.role != "mafia":
            is_winner = True

        # Check for family boosts
        user_doc = await users_collection.find_one({"_id": p.user_id})
        family_id = user_doc.get("family_id") if user_doc else None
        
        influence_bonus = 1.0
        bp_xp_bonus = 1.0
        family_xp_mult = 1.0
        
        if family_id:
            from datetime import datetime
            family = await db["families"].find_one({"_id": family_id})
            if family:
                active_boosts = family.get("treasury", {}).get("active_boosts", [])
                now = datetime.utcnow()
                for b in active_boosts:
                    if datetime.fromisoformat(b["expires_at"]) > now:
                        if b["type"] == "influenceBonus":
                            influence_bonus = 1.1
                        elif b["type"] == "battlePassXP":
                            bp_xp_bonus = 1.15
                        elif b["type"] == "familyXPDouble":
                            family_xp_mult = 2.0
                
                # Grant Family XP
                base_fxp = 50 if is_winner else 10
                fxp = int(base_fxp * family_xp_mult)
                
                new_xp = family.get("current_xp", 0) + fxp
                xp_to_next = family.get("xp_to_next_level", 1000)
                
                if new_xp >= xp_to_next:
                    # Level up!
                    await db["families"].update_one(
                        {"_id": family_id},
                        {
                            "$inc": {"level": 1, "xp_to_next_level": 500},
                            "$set": {"current_xp": new_xp - xp_to_next},
                            "$push": {"audit_log": {
                                "id": str(uuid.uuid4()),
                                "action": "familyLevelUp",
                                "actor_id": "system",
                                "actor_name": "System",
                                "details": str(family.get("level", 1) + 1),
                                "timestamp": datetime.utcnow().isoformat(),
                            }}
                        }
                    )
                else:
                    await db["families"].update_one({"_id": family_id}, {"$inc": {"current_xp": fxp}})

        # Base rewards
        mmr_change = 25 if is_winner else -15
        coins_reward = 100 if is_winner else 25
        influence_reward = int(25 * influence_bonus)
        bp_xp_reward = int((50 if is_winner else 10) * bp_xp_bonus)
        
        # Build MongoDB update query
        update_query = {
            "$inc": {
                "games_played": 1,
                "wins": 1 if is_winner else 0,
                "losses": 0 if is_winner else 1,
                "mmr": mmr_change,
                "syndicate_coins": coins_reward,
                "influence": influence_reward,
                "battle_pass_xp": bp_xp_reward
            }
        }
        
        # Prevent MMR from dropping below 0
        try:
            user_doc = await users_collection.find_one({"_id": p.user_id}, {"mmr": 1})
            if user_doc and user_doc.get("mmr", 0) + mmr_change < 0:
                update_query["$inc"]["mmr"] = -user_doc.get("mmr", 0) # Only deduct what they have
                
            history_entry = {
                "game_mode": "ranked",
                "role": p.role,
                "won": is_winner,
                "mmr_change": mmr_change
            }
            update_query["$push"] = {"match_history": {"$each": [str(history_entry)], "$slice": -50}}
                
            await users_collection.update_one(
                {"_id": p.user_id},
                update_query
            )
            logger.info(f"Updated match stats for user {p.user_id}: Winner={is_winner}")
            
            # Update bounties
            from app.services.bounty_service import update_bounty_progress
            actions = {}
            if is_winner:
                actions["win_match"] = 1
            if p.is_alive:
                actions["survive_night"] = 1
            
            await update_bounty_progress(p.user_id, actions)
            
        except Exception as e:
            logger.error(f"Failed to update match results for user {p.user_id}: {e}")
