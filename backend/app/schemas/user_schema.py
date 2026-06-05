from pydantic import BaseModel
from typing import Optional, List
from app.models.user_model import RoleStats, Commendations, EquippedCosmetics, Inventory

class UserResponse(BaseModel):
    id: str
    email: str
    username: str
    profile_picture: str
    premium_avatar: str
    using_premium_avatar: bool
    bio: str
    title: str
    trust_rating: int
    mmr: int
    rank: str
    influence: int
    syndicate_coins: int
    battle_pass_tier: int
    battle_pass_xp: int
    has_premium_pass: bool
    claimed_free_tiers: List[int]
    claimed_premium_tiers: List[int]
    wins: int
    losses: int
    games_played: int
    role_stats: RoleStats
    friends: List[str]
    friend_requests: List[str]
    family_id: Optional[str]
    popularity: int
    commendations: Commendations
    equipped_cosmetics: EquippedCosmetics
    inventory: Inventory
    match_history: List[str]
    created_at: str
    updated_at: str
    daily_bounties: List[dict] = []
    bounties_reset_at: Optional[str] = None

    class Config:
        from_attributes = True

class UserUpdate(BaseModel):
    username: Optional[str] = None
    bio: Optional[str] = None
    profile_picture: Optional[str] = None
    premium_avatar: Optional[str] = None
    using_premium_avatar: Optional[bool] = None
    title: Optional[str] = None
    equipped_cosmetics: Optional[EquippedCosmetics] = None


# ── Lobby Profile ──────────────────────────────────────────────────────────

class LobbyProfileResponse(BaseModel):
    """
    Lightweight contract used by the Flutter AvatarShowcaseWidget.
    Returned by GET /user/lobby-profile.
    """
    username: str
    avatar_url: str             # resolved URL (may be relative path)
    equipped_frame_id: str      # e.g. "bronze_ring", "gold_hex", "syndicate_boss"
    equipped_banner_url: str    # URL for calling-card background art (empty = gradient)
    current_rank_title: str     # e.g. "Bronze", "Gold", "Syndicate Boss"
    rank_tier: int              # 0-4 integer so Flutter doesn't need to re-parse string
    current_xp: int             # battle_pass_xp mod xp_per_tier
    next_level_xp: int          # always 1000 per tier (or dynamic later)
    equipped_title: str         # e.g. "Shadow Boss"
    battle_pass_tier: int

    class Config:
        from_attributes = True

