from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config.database import connect_to_mongo, close_mongo_connection
from app.routes import auth_routes, user_routes, social_routes, family_routes, store_routes, battle_pass_routes

app = FastAPI(
    title="City of Lies Backend",
    description="Backend API for City of Lies / Mafia Wars game",
    version="1.0.0"
)

from fastapi.staticfiles import StaticFiles
import os

# Create uploads directory if it doesn't exist
os.makedirs("uploads/avatars", exist_ok=True)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount static files for media storage
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# Database lifecycle events
app.add_event_handler("startup", connect_to_mongo)
app.add_event_handler("shutdown", close_mongo_connection)

import firebase_admin
from firebase_admin import credentials
import logging

@app.on_event("startup")
async def init_firebase():
    try:
        cred_path = "firebase-adminsdk.json"
        if os.path.exists(cred_path):
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
            logging.info("Firebase Admin initialized.")
        else:
            logging.warning("Firebase Admin credentials not found. Social login will fail.")
    except Exception as e:
        logging.error(f"Failed to initialize Firebase Admin: {e}")

# Include routers
app.include_router(auth_routes.router, prefix="/auth", tags=["Authentication"])
app.include_router(user_routes.router, prefix="/user", tags=["User Profile"])
app.include_router(social_routes.router)
app.include_router(family_routes.router)
app.include_router(store_routes.router, prefix="/store", tags=["Store"])
app.include_router(battle_pass_routes.router, prefix="/battlepass", tags=["Battle Pass"])

from app.routes import voice_routes, bounty_routes
app.include_router(voice_routes.router)
app.include_router(bounty_routes.router, prefix="/bounties")

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
