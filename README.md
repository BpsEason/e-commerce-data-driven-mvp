# 智能數據驅動電商平台 MVP

[![Laravel](https://img.shields.io/badge/Laravel-11.x-FF2D20?style=flat-square&logo=laravel)](https://laravel.com/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.111.0-009688?style=flat-square&logo=fastapi)](https://fastapi.tiangolo.com/)
[![Pandas](https://img.shields.io/badge/Pandas-2.x-150458?style=flat-square&logo=pandas)](https://pandas.pydata.org/)
[![NumPy](https://img.shields.io/badge/NumPy-1.x-013243?style=flat-square&logo=numpy)](https://numpy.org/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker)](https://www.docker.com/)

這是一個智能數據驅動電商平台的最小可行性產品 (MVP)，展示如何整合 Laravel、FastAPI 和數據分析技術，構建高效、可擴展的電商應用。

## 專案目標

- 展示多語言技術整合：PHP (Laravel) 與 Python (FastAPI, Pandas, NumPy)。
- 實現模塊化系統設計：Laravel 處理業務邏輯，FastAPI 提供數據分析。
- 提供數據驅動功能：智能推薦與銷售洞察。

## 技術棧

- **後端框架**：Laravel 11.x (PHP) - 用戶認證、商品與訂單管理。
- **數據服務**：
  - FastAPI 0.111.0 (Python) - 高性能數據分析與推薦 API。
  - Pandas 2.x - 數據處理與分析。
  - NumPy 1.x - 高效數值運算。
- **數據庫**：MySQL 8.0 (或 PostgreSQL)。
- **Web 服務器**：Nginx。
- **容器化**：Docker & Docker Compose。

## 核心功能

1. **用戶管理**：註冊、登錄、個人資料。
2. **商品管理**：商品列表與詳情。
3. **訂單管理**：簡化購物車與下單。
4. **智能推薦**（FastAPI）：
   - 熱門商品：基於銷量排序。
   - 個性化推薦：基於用戶交互的簡單協同過濾。
5. **數據洞察**（FastAPI）：每日銷售趨勢。

## 架構概覽

```mermaid
graph TD
    A[前端 (Laravel Blade)] -->|HTTP| B(Laravel API)
    B -->|DB 操作| C[(MySQL/PostgreSQL)]
    B -->|HTTP| D(FastAPI 數據服務)
    D -->|Pandas/NumPy| E[數據分析]
    E --> C
    D -->|結果| B
```

## 專案結構

```
e-commerce-data-driven-mvp/
├── laravel-backend/           # Laravel 應用
│   ├── app/
│   ├── config/
│   ├── database/
│   ├── routes/
│   ├── .env.example
│   └── Dockerfile.php
├── fastapi-data-service/      # FastAPI 數據服務
│   ├── app/
│   │   └── main.py
│   ├── requirements.txt
│   └── Dockerfile
├── nginx/                     # Nginx 配置
│   └── nginx.conf
├── docker-compose.yml
├── .gitignore
└── README.md
```

## 快速開始

### 前提條件

- Docker Desktop（含 Docker Compose）。
- Git。

### 安裝步驟

1. **克隆倉庫**：
   ```bash
   git clone https://github.com/BpsEason/e-commerce-data-driven-mvp.git
   cd e-commerce-data-driven-mvp
   ```

2. **配置 Laravel 環境**：
   ```bash
   cd laravel-backend
   cp .env.example .env
   ```
   編輯 `laravel-backend/.env`：
   ```dotenv
   DB_CONNECTION=mysql
   DB_HOST=db
   DB_PORT=3306
   DB_DATABASE=laravel
   DB_USERNAME=user
   DB_PASSWORD=password
   FASTAPI_URL=http://fastapi:8000
   ```

3. **啟動服務**：
   ```bash
   cd ..
   docker-compose up --build -d
   ```

4. **初始化數據庫**：
   ```bash
   docker-compose exec php php artisan key:generate
   docker-compose exec php php artisan migrate --seed
   ```

5. **訪問應用**：
   - 電商平台：`http://localhost`
   - FastAPI 文檔：`http://localhost:8000/docs`

### 測試賬戶

- **郵箱**：`test@example.com`
- **密碼**：`password`

## 技術細節

### Laravel 後端
- **認證**：Laravel Breeze。
- **數據模型**：`users`、`products`、`orders`、`user_product_interactions`。
- **前端**：Laravel Blade 展示商品與推薦。

### FastAPI 數據服務
- **數據處理**：Pandas 和 NumPy。
- **API 端點**：
  - `/recommend/popular`：熱門商品。
  - `/recommend/personalized/{user_id}`：個性化推薦。
  - `/analytics/sales`：銷售趨勢。

### Docker Compose
- **服務**：`nginx`（反向代理）、`php`（Laravel）、`fastapi`（數據服務）、`db`（MySQL）。

## 常見問題

- **服務無法啟動？** 檢查 Docker 運行狀態，確認 `.env` 配置，查看日誌：`docker-compose logs`。
- **FastAPI 無法連接？** 確認 `FASTAPI_URL=http://fastapi:8000`。
- **數據庫遷移失敗？** 確保 MySQL 服務已啟動：`docker-compose ps`。

## 貢獻

歡迎提交 Issue 或 Pull Request，遵循 [Contributor Covenant](https://www.contributor-covenant.org/)。

## 許可證

[MIT 許可證](LICENSE)