from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

class BountySchema(BaseModel):
    id: str
    action_type: str # e.g., 'win_match', 'survive_night', 'vote_mafia'
    description: str
    icon: str
    current: int = 0
    total: int
    xp: int
    status: str = "pending" # pending, completed, claimed

class UserBountiesSchema(BaseModel):
    bounties: List[BountySchema] = []
    reset_at: datetime
