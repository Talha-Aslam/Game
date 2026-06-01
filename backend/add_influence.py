from pymongo import MongoClient

client = MongoClient("mongodb+srv://admin:admin321@cityoflies.imqgrnk.mongodb.net/?appName=CityofLies")
db = client["city_of_lies"]
res = db.users.update_many({}, {"$set": {"influence": 10000}})
print(f"Modified {res.modified_count} users")
