from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config.database import connect_to_mongo, close_mongo_connection
from app.routes import auth_routes, user_routes, social_routes, family_routes, store_routes, battle_pass_routes

app = FastAPI(
    title="City of Lies Backend",
    description="Backend API for City of Lies / Mafia Wars game",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Database lifecycle events
app.add_event_handler("startup", connect_to_mongo)
app.add_event_handler("shutdown", close_mongo_connection)

# Include routers
app.include_router(auth_routes.router, prefix="/auth", tags=["Authentication"])
app.include_router(user_routes.router, prefix="/user", tags=["User Profile"])
app.include_router(social_routes.router)
app.include_router(family_routes.router)
app.include_router(store_routes.router, prefix="/store", tags=["Store"])
app.include_router(battle_pass_routes.router, prefix="/battlepass", tags=["Battle Pass"])

from app.routes import voice_routes
app.include_router(voice_routes.router)

# WebSockets
from app.websocket import lobby_ws, game_ws
from app.core.matchmaking_manager import matchmaker

app.include_router(lobby_ws.router)
app.include_router(game_ws.router)

@app.on_event("startup")
async def start_matchmaker():
    matchmaker.start()

@app.on_event("shutdown")
async def stop_matchmaker():
    matchmaker.stop()

@app.get("/")
async def root():
    return {"message": "Welcome to City of Lies API"}
