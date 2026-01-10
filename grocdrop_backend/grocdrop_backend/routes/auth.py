from fastapi import APIRouter, HTTPException
from database import user_collection
from models.user_model import User
from utils.password import hash_password, verify_password

router = APIRouter(prefix="/auth", tags=["Auth"])

@router.post("/register")
def register(user: User):
    if user_collection.find_one({"email": user.email}):
        raise HTTPException(status_code=400, detail="Email already exists")

    user_collection.insert_one({
        "name": user.name,
        "email": user.email,
        "password": hash_password(user.password)
    })

    return {"message": "User registered successfully"}

@router.post("/login")
def login(data: dict):
    user = user_collection.find_one({"email": data["email"]})
    if not user or not verify_password(data["password"], user["password"]):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    user["_id"] = str(user["_id"])
    return user
