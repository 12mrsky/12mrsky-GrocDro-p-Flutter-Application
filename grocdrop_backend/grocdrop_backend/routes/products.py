from fastapi import APIRouter
from database import product_collection

router = APIRouter(prefix="/products", tags=["Products"])

@router.get("/")
def get_products():
    products = []
    for p in product_collection.find():
        p["_id"] = str(p["_id"])
        products.append(p)
    return products

@router.post("/")
def add_product(product: dict):
    product_collection.insert_one(product)
    return {"message": "Product added"}
