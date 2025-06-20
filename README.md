# 智能數據驅動電商平台 MVP (Laravel + FastAPI + React + Docker)

## 專案概覽

這是一個最小可行產品 (MVP) 範例，旨在展示如何整合 Laravel (PHP)、FastAPI (Python) 和 React (JavaScript) 來構建一個具有數據智能功能的電商平台。

-   **Laravel Backend**: 處理核心電商業務邏輯 (用戶、商品、訂單管理) 和 RESTful API。
-   **FastAPI Data Service**: 提供高性能的數據分析和機器學習服務 (如商品推薦、銷售趨勢分析)。
-   **React Frontend**: 提供現代化的用戶界面，消費 Laravel 和 FastAPI 的 API。
-   **Docker & Docker Compose**: 實現環境隔離和簡化部署。

## 啟動步驟

### 前提條件

確保您的系統已安裝：

-   [Docker Desktop](https://www.docker.com/products/docker-desktop)
-   [Git](https://git-scm.com/downloads)

### 快速啟動

1.  **克隆或下載本專案並進入目錄:**
    ```bash
    git clone [https://github.com/YourUsername/e-commerce-data-driven-mvp.git](https://github.com/YourUsername/e-commerce-data-driven-mvp.git) # 替換為您的實際倉庫地址
    cd e-commerce-data-driven-mvp
    ```

2.  **執行設定腳本:**
    這個腳本將創建所有必要的目錄和檔案，並填充基礎內容。
    ```bash
    chmod +x create_project.sh
    ./create_project.sh
    ```

3.  **啟動所有服務:**
    ```bash
    docker-compose up --build -d
    ```
    這會構建 Docker 映像並在後台啟動 `laravel_app` (PHP-FPM)、`python_app` (FastAPI)、`react_app` (Node.js 開發伺服器)、`mysql` 和 `redis` 服務，並通過 `nginx` 進行統一代理。

4.  **初始化 Laravel 應用:**
    在 `laravel_app` 容器中執行 Laravel 命令以生成 `APP_KEY` 和運行數據庫遷移。
    ```bash
    docker-compose exec laravel_app php artisan key:generate
    docker-compose exec laravel_app php artisan migrate --seed
    ```
    (注意：如果 `composer install` 在 Dockerfile 中沒有自動運行，或者您想在本地開發環境運行，請在 `laravel-backend` 目錄執行 `composer install` 和 `npm install`.)

5.  **訪問應用:**
    -   **React Frontend**: `http://localhost` (經由 Nginx 代理到 React Dev Server)
    -   **FastAPI 文檔 (Swagger UI)**: `http://localhost/api-python/docs` (經由 Nginx 代理)
    -   **Laravel Backend (如果直接訪問 Laravel 的話，但通常由 Nginx 代理)**: `http://localhost/api`

### 測試帳戶

您可以使用以下帳戶登錄電商平台 (假設您運行了 `php artisan migrate --seed`):

-   **電子郵件**: `test@example.com`
-   **密碼**: `password`

## 專案結構

```
e-commerce-data-driven-mvp/
├── laravel-backend/       # Laravel 後端應用
│   ├── app/
│   ├── bootstrap/
│   ├── config/
│   ├── database/
│   ├── public/
│   ├── resources/
│   ├── routes/
│   ├── storage/
│   ├── tests/
│   ├── .env.example
│   ├── artisan
│   ├── composer.json
│   ├── package.json
│   ├── phpunit.xml
│   ├── README.md
│   └── Dockerfile
├── python-backend/        # FastAPI 數據服務
│   ├── app/
│   ├── data/
│   ├── .env.example
│   ├── Dockerfile
│   ├── requirements.txt
│   └── start.sh
├── react-frontend/        # React 前端應用
│   ├── public/
│   ├── src/
│   ├── .env.development
│   ├── .env.production
│   ├── package.json
│   ├── README.md
│   └── Dockerfile
├── nginx/                 # Nginx 配置
│   └── conf.d/
│       ├── laravel.conf
│       └── react.conf
│   └── nginx.conf
├── docker-compose.yml     # Docker Compose 配置
├── README.md              # 本檔案
└── .gitignore
```

## 進階考量

-   **性能優化**:
    -   利用 Laravel 的 Cache 層 (已配置 Redis)。
    -   FastAPI 的異步數據存取和任務排程。
-   **推薦系統升級**:
    -   實作更複雜的協同過濾或基於內容的推薦演算法。
    -   整合向量資料庫。
-   **CI/CD**: 自動化測試、建置和部署流程。
-   **監控與日誌**: 建立集中式日誌和監控系統。
