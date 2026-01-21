from fastapi import APIRouter
from database import order_collection

router = APIRouter()

@router.get("/orders")
async def get_orders():
    orders = list(orders_collection.find({}, {"_id": 0}))
    return {
        "success": True,
        "data": orders
    }
