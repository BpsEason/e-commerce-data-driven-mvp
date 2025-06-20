# e-commerce-data-driven-mvp/fastapi-data-service/app/main.py
# FastAPI 數據服務主文件，包含所有 API 端點和數據處理邏輯

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import pandas as pd
import numpy as np
import requests
import os
from datetime import datetime, timedelta

app = FastAPI(
    title="電商數據智能服務",
    description="提供熱門商品、個性化推薦和銷售趨勢分析的數據服務。",
    version="1.0.0",
)

# Pydantic 數據模型，用於定義 API 請求和響應的數據結構
class ProductBase(BaseModel):
    product_id: int
    name: str
    category: str = "未知" # 添加默認值以防數據缺失
    price: float
    stock: int = 0 # 新增庫存字段

class Recommendation(BaseModel):
    product_id: int
    name: str
    category: str = "未知"
    price: float
    score: float # 推薦分數

class SalesTrend(BaseModel):
    date: str
    daily_sales: float

# 模擬數據加載和準備
# 實際應用中，這些數據會從數據庫或數據湖中動態加載
# 這裡使用全局變數來模擬數據庫的數據框，方便演示
products_df = None
user_product_interactions_df = None
orders_df = None
order_items_df = None

# 初始化數據的函數
def load_mock_data():
    global products_df, user_product_interactions_df, orders_df, order_items_df

    # 模擬商品數據
    products_data = {
        'product_id': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
        'name': [f'智能手機 {i}' for i in range(1, 7)] + [f'時尚襯衫 {i}' for i in range(1, 4)] + [f'智能手錶 {i}' for i in range(1, 3)] + ['藍牙耳機'],
        'description': [f'一款高性能的智能手機 {i}' for i in range(1, 7)] + [f'舒適時尚的襯衫 {i}' for i in range(1, 4)] + [f'多功能智能手錶 {i}' for i in range(1, 3)] + ['音質卓越的藍牙耳機'],
        'price': [1000.0, 800.0, 1200.0, 950.0, 700.0, 1100.0, 150.0, 120.0, 180.0, 300.0, 250.0, 200.0],
        'category': ['電子產品', '電子產品', '電子產品', '電子產品', '電子產品', '電子產品', '服飾', '服飾', '服飾', '電子產品', '電子產品', '電子產品'],
        'stock': [100, 80, 50, 120, 90, 70, 200, 180, 150, 60, 40, 110],
    }
    products_df = pd.DataFrame(products_data)

    # 模擬用戶與商品交互數據
    # 交互類型: 'view', 'add_to_cart', 'purchase'
    # 這裡加入了一些銷售量數據到 interactions_data 以便計算熱門商品
    interactions_data = []
    current_time = datetime.now()
    for user_id in range(1, 11): # 10 個用戶
        for _ in range(np.random.randint(5, 20)): # 每個用戶 5-20 次交互
            product_id = np.random.choice(products_df['product_id'])
            action = np.random.choice(['view', 'add_to_cart', 'purchase'], p=[0.6, 0.2, 0.2])
            time_offset = timedelta(days=np.random.randint(0, 60), hours=np.random.randint(0, 24))
            interactions_data.append({
                'user_id': user_id,
                'product_id': product_id,
                'interaction_type': action,
                'timestamp': current_time - time_offset
            })
    user_product_interactions_df = pd.DataFrame(interactions_data)

    # 模擬訂單數據 (用於銷售趨勢)
    # 從 purchase 交互中生成訂單數據
    purchases = user_product_interactions_df[user_product_interactions_df['interaction_type'] == 'purchase'].copy()
    if not purchases.empty:
        # 將 purchase 記錄與 products_df 合併以獲取價格信息
        purchases = purchases.merge(products_df[['product_id', 'price']], on='product_id', how='left')
        
        # 簡單地為每次購買創建一個訂單和訂單項
        orders_list = []
        order_items_list = []
        order_id_counter = 1
        for index, row in purchases.iterrows():
            order_total = row['price'] * 1 # 簡化為每次購買一件商品
            orders_list.append({
                'order_id': order_id_counter,
                'user_id': row['user_id'],
                'total_amount': order_total,
                'status': 'completed',
                'created_at': row['timestamp']
            })
            order_items_list.append({
                'order_id': order_id_counter,
                'product_id': row['product_id'],
                'quantity': 1,
                'price': row['price']
            })
            order_id_counter += 1
        
        orders_df = pd.DataFrame(orders_list)
        order_items_df = pd.DataFrame(order_items_list)
    else:
        orders_df = pd.DataFrame(columns=['order_id', 'user_id', 'total_amount', 'status', 'created_at'])
        order_items_df = pd.DataFrame(columns=['order_id', 'product_id', 'quantity', 'price'])

    # 確保數據框已正確加載
    if products_df is None or user_product_interactions_df is None:
        raise RuntimeError("無法加載模擬數據。")

# 在應用程式啟動時加載數據
@app.on_event("startup")
async def startup_event():
    load_mock_data()
    print("FastAPI 服務已啟動並加載模擬數據。")

# 根路徑
@app.get("/")
async def root():
    return {"message": "FastAPI 數據服務正在運行！"}

# 數據分析和推薦邏輯

@app.get("/products/popular", response_model=list[ProductBase])
async def get_popular_products():
    """
    獲取最受歡迎的商品列表。
    基於商品在用戶交互中出現的頻次（尤其是 'purchase' 和 'add_to_cart'）來衡量受歡迎程度。
    """
    if user_product_interactions_df.empty:
        return []

    # 計算每個商品的交互次數，優先考慮購買和加入購物車
    # 這裡我們將 'purchase' 和 'add_to_cart' 賦予更高的權重
    interaction_weights = {
        'view': 1,
        'add_to_cart': 5,
        'purchase': 10
    }
    
    # 應用權重並計算加權交互分數
    weighted_interactions = user_product_interactions_df.copy()
    weighted_interactions['score'] = weighted_interactions['interaction_type'].map(interaction_weights)
    
    product_popularity = weighted_interactions.groupby('product_id')['score'].sum().reset_index()
    
    # 合併商品詳細信息並排序
    popular_products = product_popularity.merge(products_df, on='product_id', how='left')
    popular_products = popular_products.sort_values(by='score', ascending=False)
    
    # 返回前 5 個熱門商品
    top_popular_products = popular_products.head(5).to_dict(orient='records')
    
    return top_popular_products


@app.get("/recommendations/user/{user_id}", response_model=list[Recommendation])
async def get_user_recommendations(user_id: int):
    """
    根據用戶 ID 獲取個性化商品推薦。
    這個實現使用簡化的基於內容和協同過濾的混合方法：
    1. 找出用戶過去交互過（特別是購買或加入購物車）的商品類別。
    2. 從這些類別中，推薦用戶尚未購買/交互過的其他熱門商品。
    """
    if user_product_interactions_df.empty:
        return []

    user_interactions = user_product_interactions_df[user_product_interactions_df['user_id'] == user_id]

    if user_interactions.empty:
        # 如果用戶沒有交互記錄，推薦熱門商品
        return await get_popular_products() # 調用熱門商品 API

    # 獲取用戶交互過的商品 ID
    interacted_product_ids = user_interactions['product_id'].unique()

    # 獲取這些商品的類別
    interacted_categories = products_df[products_df['product_id'].isin(interacted_product_ids)]['category'].unique()

    if len(interacted_categories) == 0:
        return await get_popular_products()

    # 找出與這些類別相關的所有商品
    candidate_products = products_df[products_df['category'].isin(interacted_categories)].copy()

    # 排除用戶已經交互過的商品
    candidate_products = candidate_products[~candidate_products['product_id'].isin(interacted_product_ids)]

    if candidate_products.empty:
        # 如果排除了所有交互過的商品後沒有候選商品，則返回熱門商品
        return await get_popular_products()

    # 為候選商品計算一個推薦分數（這裡簡化為銷售量或某種綜合熱度）
    # 為了演示，我們使用一個簡化的“熱度”分數，例如基於其在所有交互中的出現頻率
    if not user_product_interactions_df.empty:
        product_interaction_counts = user_product_interactions_df.groupby('product_id')['interaction_type'].count().reset_index()
        product_interaction_counts.rename(columns={'interaction_type': 'interaction_count'}, inplace=True)
        candidate_products = candidate_products.merge(product_interaction_counts, on='product_id', how='left')
        candidate_products['interaction_count'].fillna(0, inplace=True)
        candidate_products['score'] = candidate_products['interaction_count'] # 使用交互次數作為分數
    else:
        candidate_products['score'] = 0 # 如果沒有交互數據，則分數為0

    # 排序並返回前 N 個推薦
    recommended_products = candidate_products.sort_values(by='score', ascending=False).head(5)

    return recommended_products.to_dict(orient='records')


@app.get("/recommendations/related/{product_id}", response_model=list[Recommendation])
async def get_related_product_recommendations(product_id: int):
    """
    根據給定商品 ID 獲取相關商品推薦。
    這裡採用簡單的基於類別的推薦：推薦與此商品相同類別的其他熱門商品。
    """
    target_product = products_df[products_df['product_id'] == product_id]

    if target_product.empty:
        raise HTTPException(status_code=404, detail="商品未找到。")

    target_category = target_product['category'].iloc[0]

    # 找出同一類別的所有商品
    related_products = products_df[products_df['category'] == target_category].copy()

    # 排除當前商品本身
    related_products = related_products[related_products['product_id'] != product_id]

    if related_products.empty:
        return []

    # 再次使用簡化的熱度分數（交互次數）來排序相關商品
    if not user_product_interactions_df.empty:
        product_interaction_counts = user_product_interactions_df.groupby('product_id')['interaction_type'].count().reset_index()
        product_interaction_counts.rename(columns={'interaction_type': 'interaction_count'}, inplace=True)
        related_products = related_products.merge(product_interaction_counts, on='product_id', how='left')
        related_products['interaction_count'].fillna(0, inplace=True)
        related_products['score'] = related_products['interaction_count']
    else:
        related_products['score'] = 0

    # 排序並返回前 N 個相關商品
    top_related_products = related_products.sort_values(by='score', ascending=False).head(3)

    return top_related_products.to_dict(orient='records')


@app.get("/sales/trends", response_model=list[SalesTrend])
async def get_sales_trends():
    """
    分析銷售趨勢，返回每日銷售總額。
    """
    if orders_df.empty:
        return []

    # 確保 'created_at' 是 datetime 類型
    orders_df['created_at'] = pd.to_datetime(orders_df['created_at'])
    orders_df['date'] = orders_df['created_at'].dt.date

    # 按日期匯總銷售額
    daily_sales_summary = orders_df.groupby('date')['total_amount'].sum().reset_index()
    daily_sales_summary.rename(columns={'total_amount': 'daily_sales'}, inplace=True)

    # 將日期轉換為字符串格式，以便 JSON 序列化
    daily_sales_summary['date'] = daily_sales_summary['date'].astype(str)

    return daily_sales_summary.to_dict(orient='records')
