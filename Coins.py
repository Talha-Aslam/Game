from pymongo import MongoClient

# Use the existing connection string from set_coins.py
client = MongoClient("mongodb+srv://admin:admin321@cityoflies.imqgrnk.mongodb.net/?appName=CityofLies")
db = client["city_of_lies"]

# Increment the syndicate_coins field by 3000 for all users
res = db.users.update_many({}, {"$inc": {"syndicate_coins": 20000}})
print(f"Successfully added 3000 syndicate_coins to {res.modified_count} users")
