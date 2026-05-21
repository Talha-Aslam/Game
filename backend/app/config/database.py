import os
import logging
from motor.motor_asyncio import AsyncIOMotorClient
from dotenv import load_dotenv

load_dotenv()

MONGODB_URI = os.getenv("MONGODB_URI", "mongodb://localhost:27017")
DB_NAME = "city_of_lies"

class Database:
    client: AsyncIOMotorClient = None
    db = None

db_instance = Database()

async def connect_to_mongo():
    logging.info("Connecting to MongoDB...")
    db_instance.client = AsyncIOMotorClient(MONGODB_URI)
    db_instance.db = db_instance.client[DB_NAME]
    logging.info("Connected to MongoDB.")

async def close_mongo_connection():
    logging.info("Closing MongoDB connection...")
    if db_instance.client:
        db_instance.client.close()
    logging.info("MongoDB connection closed.")

def get_database():
    return db_instance.db
