from pymongo import MongoClient
import os

MONGO_URI = os.getenv("MONGO_URI")

client = MongoClient(MONGO_URI)

# ✅ MUST MATCH ATLAS DB NAME
db = client["surajyadu9_db_user"]

user_collection = db["users"]
product_collection = db["products"]
order_collection = db["orders"]
