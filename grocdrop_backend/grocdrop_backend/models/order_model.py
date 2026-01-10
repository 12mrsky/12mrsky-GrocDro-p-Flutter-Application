from pydantic import BaseModel
from typing import List

class Order(BaseModel):
    user_id: str
    items: List[dict]
    total_amount: float
