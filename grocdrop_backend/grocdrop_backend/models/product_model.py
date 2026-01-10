from pydantic import BaseModel

class Product(BaseModel):
    name: str
    price: float
    image: str
    category: str
