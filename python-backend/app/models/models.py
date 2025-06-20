from pydantic import BaseModel
from typing import List, Optional
import datetime

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: Optional[str] = None

class User(BaseModel):
    id: int
    username: str
    email: Optional[str] = None
    full_name: Optional[str] = None
    disabled: Optional[bool] = None

class UserInDB(User):
    hashed_password: str

class Product(BaseModel):
    id: int
    name: str
    description: str
    price: float
    category: str
    stock: Optional[int] = None # Added stock

class Order(BaseModel):
    id: int
    user_id: int
    # Simplified for MVP, could be list of OrderItems in a real app
    # product_id: int
    # quantity: int
    total_amount: float
    created_at: datetime.datetime
    # Add other fields as per your Laravel Order model

class RecommendedProduct(BaseModel):
    id: int
    name: str
    description: str
    price: float
    category: str
    score: float # Similarity score or relevance score

class SalesTrend(BaseModel):
    date: str
    daily_sales: float
