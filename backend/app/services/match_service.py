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

        # Base rewards
        mmr_change = 25 if is_winner else -15
        coins_reward = 100 if is_winner else 25
        
        # Build MongoDB update query
        update_query = {
            "$inc": {
                "games_played": 1,
                "wins": 1 if is_winner else 0,
                "losses": 0 if is_winner else 1,
                "mmr": mmr_change,
                "syndicate_coins": coins_reward,
                "battle_pass_xp": 50 if is_winner else 10 # Basic BP XP
            }
        }
        
        # Prevent MMR from dropping below 0
        try:
            user_doc = await users_collection.find_one({"_id": p.user_id}, {"mmr": 1})
            if user_doc and user_doc.get("mmr", 0) + mmr_change < 0:
                update_query["$inc"]["mmr"] = -user_doc.get("mmr", 0) # Only deduct what they have
                
            history_entry = {
                "game_mode": "casual", # default for now
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
            actions["play_casual"] = 1
            
            await update_bounty_progress(p.user_id, actions)
            
        except Exception as e:
            logger.error(f"Failed to update match results for user {p.user_id}: {e}")
