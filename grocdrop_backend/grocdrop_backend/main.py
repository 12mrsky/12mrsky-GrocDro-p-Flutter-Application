from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pymongo import MongoClient
from datetime import datetime
from pydantic import BaseModel
from typing import List
from dotenv import load_dotenv
from pathlib import Path
import os

# ---------------- ENV ----------------

load_dotenv()

# ---------------- APP ----------------

app = FastAPI(title="GrocDrop API")
from fastapi.staticfiles import StaticFiles

app.mount("/images", StaticFiles(directory="images"), name="images")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------- BASE DIR ----------------
# Points to: grocdrop_backend/grocdrop_backend/

BASE_DIR = Path(__file__).resolve().parent

# ---------------- STATIC IMAGES ----------------
# Folder: grocdrop_backend/grocdrop_backend/images/

IMAGES_DIR = BASE_DIR / "images"
IMAGES_DIR.mkdir(exist_ok=True)

app.mount(
    "/images",
    StaticFiles(directory=str(IMAGES_DIR)),
    name="images",
)

# ---------------- DATABASE ----------------

client = MongoClient(os.getenv("MONGO_URI"))
db = client[os.getenv("DB_NAME")]

db.carts.create_index("user_id", unique=True)
db.orders.create_index("user_id")

# ---------------- ROOT ----------------

@app.get("/")
def root():
    return {"message": "GrocDrop backend running 🚀"}

# ---------------- PRODUCTS ----------------

@app.get("/products")
def get_products(request: Request):
    """
    MongoDB stores:
      image: "apple.png"

    API returns:
      image: "http://IP:PORT/images/apple.png"

    IMPORTANT:
    - DO NOT remove _id
    - Convert _id (ObjectId) to string
    """
    products = list(db.products.find())  # KEEP _id

    base_url = str(request.base_url).rstrip("/")

    for product in products:
        # convert ObjectId -> string (CRITICAL)
        product["_id"] = str(product["_id"])

        # build full image URL
        if product.get("image"):
            product["image"] = f"{base_url}/images/{product['image']}"

    return products

# ---------------- MODELS ----------------

class CartItem(BaseModel):
    product_id: str
    name: str
    price: int
    quantity: int

class Cart(BaseModel):
    user_id: str
    items: List[CartItem]

class Order(BaseModel):
    user_id: str
    items: List[CartItem]
    total_amount: int

# ---------------- CART ----------------

@app.post("/cart/save")
def save_cart(cart: Cart):
    db.carts.update_one(
        {"user_id": cart.user_id},
        {"$set": cart.dict()},
        upsert=True
    )
    return {"success": True}

@app.get("/cart/{user_id}")
def get_cart(user_id: str):
    return db.carts.find_one(
        {"user_id": user_id},
        {"_id": 0}
    ) or {"user_id": user_id, "items": []}

# ---------------- ORDERS ----------------

@app.post("/orders/place")
def place_order(order: Order):
    db.orders.insert_one({
        "user_id": order.user_id,
        "items": [i.dict() for i in order.items],
        "total_amount": order.total_amount,
        "status": "PLACED",
        "created_at": datetime.utcnow().isoformat()
    })

    # clear cart after order
    db.carts.delete_one({"user_id": order.user_id})

    return {"success": True}

@app.get("/orders/{user_id}")
def get_orders(user_id: str):
    orders = list(
        db.orders.find({"user_id": user_id}, {"_id": 0})
    )
    return {
        "success": True,
        "data": orders
    }
