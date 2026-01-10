from pymongo import MongoClient
import os

MONGO_URI = os.getenv("MONGO_URI")

client = MongoClient(MONGO_URI)
db = client["grocdrop_db"]

user_collection = db["users"]
product_collection = db["products"]
order_collection = db["orders"]
