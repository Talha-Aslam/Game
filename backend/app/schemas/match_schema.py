from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

class MatchPlayer(BaseModel):
    user_id: str
    username: str
    profile_picture: str
    rank: str
    mmr: int

class LobbySchema(BaseModel):
    lobby_id: str
    game_mode: str
    status: str = "waiting" # waiting, starting, playing
    players: List[MatchPlayer] = []
    max_players: int = 15
    created_at: datetime = Field(default_factory=datetime.utcnow)

class MatchCompleteRequest(BaseModel):
    game_mode: str
    winner_team: str # "town", "mafia", "neutral"
    players_data: List[dict] # Contains specific stats for each player in the match (e.g., survived, role, voted_correctly)
