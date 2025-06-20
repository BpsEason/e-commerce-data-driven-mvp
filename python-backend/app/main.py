from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel
from typing import List, Dict, Any, Optional
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import linear_kernel
import datetime
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = FastAPI(
    title="E-commerce Data Analysis API",
    description="API for data-driven insights including product recommendations and sales trends.",
    version="1.0.0",
)

# --- Dummy Data Storage (for MVP without persistent DB) ---
# In a real application, this would connect to a database.
# Using relative path to data folder
data_dir = os.path.join(os.path.dirname(__file__), '..', 'data')
products_csv_path = os.path.join(data_dir, 'products.csv')
orders_csv_path = os.path.join(data_dir, 'orders.csv')
interactions_csv_path = os.path.join(data_dir, 'interactions.csv')


products_df = pd.DataFrame()
orders_df = pd.DataFrame()
interactions_df = pd.DataFrame() # New: for user interactions


def load_mock_data():
    global products_df, orders_df, interactions_df

    try:
        products_df = pd.read_csv(products_csv_path)
        products_df.set_index('id', inplace=True) # Set product ID as index for easy lookup

        orders_df = pd.read_csv(orders_csv_path)
        orders_df['created_at'] = pd.to_datetime(orders_df['created_at'])

        interactions_df = pd.read_csv(interactions_csv_path)
        interactions_df['timestamp'] = pd.to_datetime(interactions_df['timestamp'])

        print(f"Loaded {len(products_df)} products from {products_csv_path}")
        print(f"Loaded {len(orders_df)} orders from {orders_csv_path}")
        print(f"Loaded {len(interactions_df)} interactions from {interactions_csv_path}")

    except FileNotFoundError as e:
        print(f"Error loading mock data: {e}. Ensure data/*.csv files exist.")
        # Fallback to empty DataFrames if files are not found
        products_df = pd.DataFrame(columns=['id', 'name', 'description', 'price', 'category', 'stock']).set_index('id')
        orders_df = pd.DataFrame(columns=['order_id', 'user_id', 'product_id', 'quantity', 'total_amount', 'created_at'])
        interactions_df = pd.DataFrame(columns=['user_id', 'product_id', 'interaction_type', 'timestamp'])
    except Exception as e:
        print(f"An unexpected error occurred while loading data: {e}")
        products_df = pd.DataFrame(columns=['id', 'name', 'description', 'price', 'category', 'stock']).set_index('id')
        orders_df = pd.DataFrame(columns=['order_id', 'user_id', 'product_id', 'quantity', 'total_amount', 'created_at'])
        interactions_df = pd.DataFrame(columns=['user_id', 'product_id', 'interaction_type', 'timestamp'])


# Application startup event
@app.on_event("startup")
async def startup_event():
    load_mock_data()
    print("FastAPI 數據服務已啟動並載入模擬數據。")

# --- Security (Placeholder for JWT/OAuth2) ---
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

# Dummy user for authentication
fake_users_db = {
    "john.doe@example.com": {
        "username": "john.doe@example.com",
        "hashed_password": "hashed_password", # In real app, hash and store securely
    }
}

async def get_current_username(token: str = Depends(oauth2_scheme)):
    # This is a dummy implementation. In a real app, decode JWT.
    if token != "fake-super-secret-token": # A simple hardcoded token for MVP
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return "authorized_user" # Return some identifier

# --- Pydantic Models ---
class Product(BaseModel):
    id: int
    name: str
    description: str
    price: float
    category: str
    stock: Optional[int] = None # Added stock for completeness

class Order(BaseModel):
    id: int
    user_id: int
    product_id: int
    quantity: int
    total_amount: float
    created_at: datetime.datetime

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

# --- Helper for Product Popularity (Reusing logic from previous discussion) ---
def calculate_product_popularity(interactions_df: pd.DataFrame, products_df: pd.DataFrame) -> pd.DataFrame:
    if interactions_df.empty:
        return products_df.copy().assign(score=0.0)

    # Define weights for different interaction types
    weights = {'view': 1, 'add_to_cart': 5, 'purchase': 10}

    # Calculate count for each interaction type per product
    interaction_counts = interactions_df.groupby(['product_id', 'interaction_type']).size().unstack(fill_value=0)

    # Calculate weighted score
    weighted_scores = interaction_counts.apply(
        lambda row: sum(row[col] * weights.get(col, 0) for col in row.index if col in weights), axis=1
    )

    # Merge into product DataFrame
    product_scores = products_df.copy()
    # Using .reindex with fill_value=0 to ensure all products are present, even if no interactions
    product_scores['score'] = weighted_scores.reindex(product_scores.index, fill_value=0)
    return product_scores.sort_values(by='score', ascending=False)


# --- Data Analysis Endpoints ---

@app.get("/")
async def root():
    return {"message": "Welcome to the E-commerce Data Analysis API"}

@app.get("/products", response_model=List[Product])
async def get_products():
    return products_df.reset_index().to_dict(orient='records') # Include 'id' from index

@app.get("/orders", response_model=List[Order])
async def get_orders():
    # Convert datetime objects to string for JSON serialization
    temp_df = orders_df.copy()
    temp_df['created_at'] = temp_df['created_at'].astype(str)
    return temp_df.to_dict(orient='records')

@app.get("/recommendations/product/{product_id}", response_model=List[RecommendedProduct])
async def get_product_recommendations(product_id: int):
    """
    基於商品描述的相似性推薦相關商品。
    """
    if products_df.empty:
        return []

    if product_id not in products_df.index:
        raise HTTPException(status_code=404, detail="Product not found")

    # Ensure all relevant product descriptions are string
    # Combining name, description, and category for richer content
    products_df['description_full'] = products_df['name'] + " " + \
                                      products_df['description'].fillna('') + " " + \
                                      products_df['category'].fillna('')

    # Use TF-IDF vectorizer
    tfidf_vectorizer = TfidfVectorizer(stop_words='english')
    tfidf_matrix = tfidf_vectorizer.fit_transform(products_df['description_full'])

    # Compute cosine similarity
    cosine_sim = linear_kernel(tfidf_matrix, tfidf_matrix)

    # Get the index of the target product
    idx = products_df.index.get_loc(product_id)

    # Get similarity scores for this product with all other products
    sim_scores = list(enumerate(cosine_sim[idx]))
    sim_scores = sorted(sim_scores, key=lambda x: x[1], reverse=True)

    # Get the top N similar products (excluding itself)
    # Check if there are enough similar products after excluding itself
    num_recommendations = min(len(sim_scores) - 1, 3) # Recommend up to 3, excluding self
    if num_recommendations <= 0:
        return []

    sim_scores = sim_scores[1:1 + num_recommendations] # Get the next N

    recommended_indices = [i[0] for i in sim_scores]
    recommended_scores = [i[1] for i in sim_scores]

    recommended_products_data = products_df.iloc[recommended_indices].copy()
    recommended_products_data['score'] = recommended_scores

    return recommended_products_data.reset_index().to_dict(orient='records')


@app.get("/recommendations/user/{user_id}", response_model=List[RecommendedProduct])
async def get_user_recommendations(user_id: int):
    """
    根據用戶歷史互動記錄，提供個性化商品推薦。
    這個是簡化版，真實的協同過濾會更複雜。
    此處假設：如果用戶購買或瀏覽了某類商品，就推薦該類的其他熱門商品。
    """
    if interactions_df.empty or products_df.empty:
        return []

    user_interactions_df = interactions_df[interactions_df['user_id'] == user_id]

    if user_interactions_df.empty:
        # If user has no interactions, recommend overall popular products
        return await get_popular_products() # Call popular products endpoint

    # Find categories of products the user has interacted with
    interacted_product_ids = user_interactions_df['product_id'].unique()
    interacted_categories = products_df[products_df.index.isin(interacted_product_ids)]['category'].unique()

    # Filter for products not yet interacted with by the user, but in their preferred categories
    candidate_products = products_df[
        (~products_df.index.isin(interacted_product_ids)) &
        (products_df['category'].isin(interacted_categories))
    ].copy()

    if candidate_products.empty:
        # If no new candidates, fall back to popular products
        return await get_popular_products()

    # Calculate popularity score for these candidate products based on all interactions
    # (could be optimized for specific user's interaction influence)
    candidate_products_with_score = calculate_product_popularity(interactions_df, candidate_products)

    # Return top N recommendations (e.g., top 5)
    top_recommendations = candidate_products_with_score[candidate_products_with_score['score'] > 0].head(5)

    return top_recommendations.reset_index().to_dict(orient='records')


@app.get("/products/popular", response_model=List[RecommendedProduct])
async def get_popular_products():
    """
    獲取熱門商品推薦。
    基於用戶互動數據（瀏覽、加入購物車、購買）計算加權熱度分數。
    """
    if products_df.empty:
        return []

    popular_products_df = calculate_product_popularity(interactions_df, products_df)
    # Return top N popular products, only those with a score > 0
    top_n_popular = popular_products_df[popular_products_df['score'] > 0].head(5)
    return top_n_popular.reset_index().to_dict(orient='records')


@app.get("/sales/trends", response_model=List[SalesTrend])
async def get_sales_trends():
    """
    分析銷售趨勢，返回每日銷售總額。
    """
    if orders_df.empty:
        return []

    # Ensure 'created_at' is datetime type
    orders_df['created_at'] = pd.to_datetime(orders_df['created_at'])
    orders_df['date'] = orders_df['created_at'].dt.date

    # Group by date and sum total_amount
    daily_sales_summary = orders_df.groupby('date')['total_amount'].sum().reset_index()
    daily_sales_summary.rename(columns={'total_amount': 'daily_sales'}, inplace=True)

    # Convert date to string format for JSON serialization
    daily_sales_summary['date'] = daily_sales_summary['date'].astype(str)

    return daily_sales_summary.to_dict(orient='records')
