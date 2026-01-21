import os
from pymongo import MongoClient
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# MongoDB connection
MONGO_URI = os.getenv("MONGO_URI")

if not MONGO_URI:
    raise ValueError("MONGO_URI is not set in environment variables")

client = MongoClient(MONGO_URI)

# Database
db = client["grocdrop_db"]

# Collections
product_collection = db["products"]
cart_collection = db["carts"]
order_collection = db["orders"]
user_collection = db["users"]
