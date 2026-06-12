from pymongo import MongoClient

# Use the existing connection string from set_coins.py
client = MongoClient("mongodb+srv://admin:admin321@MAFIA AT CITY.imqgrnk.mongodb.net/?appName=MAFIA AT CITY")
db = client["city_of_lies"]

# Increment the syndicate_coins field by 3000 for all users
res = db.users.update_many({}, {"$inc": {"syndicate_coins": 10000}})
print(f"Successfully added 3000 syndicate_coins to {res.modified_count} users")
