# e-commerce-data-driven-mvp/laravel-backend/Dockerfile.php
# Laravel 應用程式的 Dockerfile

# 使用 PHP 8.2 的 FPM 版本作為基礎映像，基於 Alpine Linux，體積小
FROM php:8.2-fpm-alpine

# 設定工作目錄
WORKDIR /var/www/html

# 安裝系統依賴和 PHP 擴展
# --no-cache: 不緩存包列表
# libzip-dev: 用於 zip 擴展
# postgresql-dev: 如果使用 PostgreSQL
# mysql-client: MySQL 客戶端，用於連接 MySQL 數據庫
# git: 用於版本控制 (雖然在生產環境中可能不需要)
# npm: Node.js 包管理器，用於前端資產 (如果 Laravel 應用需要編譯前端)
RUN apk add --no-cache \
    curl \
    libzip-dev \
    mysql-client \
    git \
    nodejs \
    npm

# 安裝 PHP 擴展
# pdo_mysql: PHP 數據對象擴展，用於 MySQL 數據庫連接
# zip: 用於處理 zip 文件，Laravel 需要
# opcache: 用於 PHP 代碼緩存，提高性能
RUN docker-php-ext-install pdo_mysql zip opcache

# 從 Composer 官方映像複製 Composer 可執行文件到 /usr/local/bin
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# 將應用程式代碼複製到容器的工作目錄
COPY . .

# 安裝 Composer 依賴
# --no-dev: 不安裝開發依賴
# --optimize-autoloader: 優化自動加載器
RUN composer install --no-dev --optimize-autoloader

# 賦予存儲和緩存目錄寫權限
# 這是 Laravel 運行所必需的
RUN chown -R www-data:www-data storage bootstrap/cache
RUN chmod -R 775 storage bootstrap/cache

# 暴露 PHP-FPM 的默認端口
EXPOSE 9000

# 啟動 PHP-FPM 服務
CMD ["php-fpm"]
