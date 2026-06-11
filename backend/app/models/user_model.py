from pydantic import BaseModel, Field, EmailStr
from typing import Optional, List, Dict, Any
from datetime import datetime
import uuid

class Commendations(BaseModel):
    strategist: int = 0
    friendly: int = 0
    leader: int = 0

class EquippedCosmetics(BaseModel):
    card_border: str = ""
    nameplate: str = ""
    background: str = ""
    voice_pack: str = ""

class Inventory(BaseModel):
    premium_avatars: List[str] = []
    card_styles: List[str] = []
    borders: List[str] = []
    elimination_fx: List[str] = []
    voice_packs: List[str] = []
    bundles: List[str] = []

    class Config:
        extra = "allow"

class RoleStats(BaseModel):
    mafia_wins: int = 0
    civilian_wins: int = 0
    detective_wins: int = 0
    doctor_saves: int = 0
    perfect_mafia_sweeps: int = 0

class UserDB(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()), alias="_id")
    email: str
    username: str
    password: str

    profile_picture: str = ""
    premium_avatar: str = ""
    using_premium_avatar: bool = False

    bio: str = ""
    title: str = "Rookie"
    trust_rating: int = 0

    mmr: int = 1500
    rank: str = "Bronze"
    influence: int = 3000
    syndicate_coins: int = 3000

    battle_pass_tier: int = 1
    battle_pass_xp: int = 0
    has_premium_pass: bool = False
    has_premium_plus: bool = False
    claimed_free_tiers: List[int] = []
    claimed_premium_tiers: List[int] = []

    wins: int = 0
    losses: int = 0
    games_played: int = 0

    role_stats: RoleStats = Field(default_factory=RoleStats)

    friends: List[str] = []
    friend_requests: List[str] = []
    family_id: Optional[str] = None

    popularity: int = 0
    commendations: Commendations = Field(default_factory=Commendations)

    equipped_cosmetics: EquippedCosmetics = Field(default_factory=EquippedCosmetics)
    inventory: Inventory = Field(default_factory=Inventory)
    match_history: List[str] = []

    created_at: str = Field(default_factory=lambda: datetime.utcnow().isoformat())
    updated_at: str = Field(default_factory=lambda: datetime.utcnow().isoformat())
    daily_bounties: List[dict] = []
    bounties_reset_at: Optional[str] = None

    class Config:
        populate_by_name = True
