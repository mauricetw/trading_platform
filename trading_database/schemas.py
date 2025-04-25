from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class UserCreate(BaseModel):
    username: str
    password: str

class UserLogin(BaseModel):
    username: str
    password: str

class ProductCreate(BaseModel):
    name: str
    price: float
    description: Optional[str] = None
    seller_id: int

class ProductOut(BaseModel):
    id: int
    name: str
    price: float
    description: Optional[str]

    class Config:
        orm_mode = True

class OrderCreate(BaseModel):
    product_id: int
    buyer_id: int

class OrderOut(BaseModel):
    id: int
    product_id: int
    buyer_id: int
    order_time: datetime

    class Config:
        orm_mode = True
