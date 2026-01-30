from fastapi import APIRouter
from pymongo import MongoClient
from bson import ObjectId
import os

router = APIRouter(prefix="/admin/categories", tags=["Admin Categories"])

# -------- DATABASE --------
MONGO_URI = os.getenv("MONGO_URI")
client = MongoClient(MONGO_URI)
db = client["grocdrop_db"]

# ================= ADD CATEGORY =================
@router.post("")
def add_category(data: dict):
    db.categories.insert_one({
        "name": data["name"]
    })
    return {"success": True}


# ================= GET CATEGORIES =================
@router.get("")
def get_categories():
    cats = list(db.categories.find())

    for c in cats:
        c["_id"] = str(c["_id"])

    return cats


# ================= DELETE CATEGORY =================
@router.delete("/{cat_id}")
def delete_category(cat_id: str):
    db.categories.delete_one({"_id": ObjectId(cat_id)})
    return {"success": True}