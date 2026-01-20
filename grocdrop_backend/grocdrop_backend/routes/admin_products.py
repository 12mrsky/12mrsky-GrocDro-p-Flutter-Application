from fastapi import APIRouter
from grocdrop_backend.database import product_collection
from grocdrop_backend.models.product_model import Product

router = APIRouter(prefix="/admin", tags=["Admin"])

@router.post("/add-product")
def add_product(product: Product):
    product_collection.insert_one(product.dict())
    return {"success": True, "message": "Product added"}
