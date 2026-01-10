from fastapi import APIRouter
from database import order_collection
from models.order_model import Order

router = APIRouter(prefix="/orders", tags=["Orders"])

@router.post("/")
def place_order(order: Order):
    order_collection.insert_one(order.dict())
    return {"message": "Order placed successfully"}

@router.get("/{user_id}")
def get_orders(user_id: str):
    orders = []
    for o in order_collection.find({"user_id": user_id}):
        o["_id"] = str(o["_id"])
        orders.append(o)
    return orders
