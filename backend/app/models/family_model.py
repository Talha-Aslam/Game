from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime
import uuid


class FamilyMemberDB(BaseModel):
    user_id: str
    username: str
    avatar_url: str = ""
    role: str = "associate"  # boss, underboss, capo, associate
    contributed_points: int = 0
    rank_tier: int = 0
    rank_points: int = 0
    win_rate: float = 0.0
    total_games: int = 0
    trust_rating: float = 5.0
    popularity_score: int = 0
    most_played_role: Optional[str] = None
    joined_at: str = Field(default_factory=lambda: datetime.utcnow().isoformat())
    is_muted: bool = False


class FamilyRequirementsDB(BaseModel):
    min_rank_tier: int = 0
    min_rank_points: int = 0
    min_games_played: int = 0
    language: str = "Any"
    region: str = "Any"


class TreasuryDonationDB(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    user_id: str
    username: str
    amount: int
    timestamp: str = Field(default_factory=lambda: datetime.utcnow().isoformat())


class FamilyBoostDB(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    type: str  # influenceBonus, battlePassXP, matchmakingSpeed, familyXPDouble
    activated_at: str = Field(default_factory=lambda: datetime.utcnow().isoformat())
    expires_at: str
    activated_by: str


class FamilyTreasuryDB(BaseModel):
    balance: int = 0
    active_boosts: List[FamilyBoostDB] = []
    recent_donations: List[TreasuryDonationDB] = []


class FamilyWarDB(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    challenger_family_id: str
    challenger_family_name: str
    challenger_family_tag: str
    defender_family_id: str
    defender_family_name: str
    defender_family_tag: str
    challenger_score: int = 0
    defender_score: int = 0
    status: str = "pending"  # pending, accepted, active, completed, cancelled
    trophies_at_stake: int = 100
    xp_reward: int = 500
    created_at: str = Field(default_factory=lambda: datetime.utcnow().isoformat())
    started_at: Optional[str] = None
    completed_at: Optional[str] = None


class FamilyAuditEntryDB(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    action: str
    actor_id: str
    actor_name: str
    target_name: Optional[str] = None
    details: Optional[str] = None
    timestamp: str = Field(default_factory=lambda: datetime.utcnow().isoformat())


class FamilyChatMessageDB(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    sender_id: str
    sender_name: str
    content: str
    type: str = "user"  # user, system
    timestamp: str = Field(default_factory=lambda: datetime.utcnow().isoformat())
    is_pinned: bool = False
    mentions: List[str] = []


class FamilyApplicationDB(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    applicant_id: str
    applicant_name: str
    family_id: str
    rank_tier: int = 0
    rank_points: int = 0
    win_rate: float = 0.0
    total_games: int = 0
    trust_rating: float = 5.0
    popularity_score: int = 0
    most_played_role: Optional[str] = None
    message: str = ""
    status: str = "pending"  # pending, accepted, rejected
    submitted_at: str = Field(default_factory=lambda: datetime.utcnow().isoformat())
    reviewed_by: Optional[str] = None
    reviewed_at: Optional[str] = None


class FamilyDB(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()), alias="_id")
    name: str
    tag: str
    description: str = ""
    slogan: str = ""
    privacy: str = "approvalRequired"  # public, approvalRequired, inviteOnly
    requirements: FamilyRequirementsDB = Field(default_factory=FamilyRequirementsDB)
    members: List[FamilyMemberDB] = []
    max_members: int = 25
    level: int = 1
    current_xp: int = 0
    xp_to_next_level: int = 1000
    total_wins: int = 0
    total_losses: int = 0
    season_points: int = 0
    global_rank: int = 0
    treasury: FamilyTreasuryDB = Field(default_factory=FamilyTreasuryDB)
    motd: str = ""
    motd_updated_at: Optional[str] = None
    war_wins: int = 0
    war_losses: int = 0
    wars: List[FamilyWarDB] = []
    audit_log: List[FamilyAuditEntryDB] = []
    chat_messages: List[FamilyChatMessageDB] = []
    applications: List[FamilyApplicationDB] = []
    created_at: str = Field(default_factory=lambda: datetime.utcnow().isoformat())
    created_by: str = ""

    class Config:
        populate_by_name = True
