from fastapi import APIRouter
from database import orders_collection # type: ignore

router = APIRouter()

@router.get("/orders")
async def get_orders():
    orders = list(orders_collection.find({}, {"_id": 0}))
    return {
        "success": True,
        "data": orders
    }
