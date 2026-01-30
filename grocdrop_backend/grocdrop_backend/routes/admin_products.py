from fastapi import APIRouter
from bson import ObjectId
from database import db

router = APIRouter(prefix="/admin", tags=["Admin"])


# ================= ADD PRODUCT (already used by you) =================
@router.post("/add-product")
def add_product(data: dict):
    data["in_stock"] = True
    db.products.insert_one(data)
    return {"success": True}


# ================= GET ALL PRODUCTS (ADMIN) =================
@router.get("/products")
def admin_products():
    products = list(db.products.find())
    for p in products:
        p["_id"] = str(p["_id"])
    return products


# ================= UPDATE PRODUCT =================
@router.put("/update-product/{pid}")
def update_product(pid: str, data: dict):
    db.products.update_one(
        {"_id": ObjectId(pid)},
        {"$set": data},
    )
    return {"success": True}


# ================= DELETE PRODUCT =================
@router.delete("/delete-product/{pid}")
def delete_product(pid: str):
    db.products.delete_one({"_id": ObjectId(pid)})
    return {"success": True}


# ================= STOCK TOGGLE =================
@router.patch("/toggle-stock/{pid}")
def toggle_stock(pid: str):
    product = db.products.find_one({"_id": ObjectId(pid)})
    new_status = not product.get("in_stock", True)

    db.products.update_one(
        {"_id": ObjectId(pid)},
        {"$set": {"in_stock": new_status}},
    )

    return {"success": True, "in_stock": new_status}