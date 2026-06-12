from pymongo import MongoClient

client = MongoClient("mongodb+srv://admin:admin321@MAFIA AT CITY.imqgrnk.mongodb.net/?appName=MAFIA AT CITY")
db = client["city_of_lies"]
res = db.users.update_many({}, {"$set": {"influence": 3000, "syndicate_coins": 3000}})
print(f"Modified {res.modified_count} users")
