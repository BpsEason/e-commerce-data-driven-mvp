#!/bin/bash

# 腳本說明：自動建立智能數據驅動電商平台 MVP 的所有檔案和目錄結構。
# 請在一個空的資料夾中運行此腳本。
# 執行方式：
# 1. 將此內容保存為 create_project.sh (例如)
# 2. 給予執行權限：chmod +x create_project.sh
# 3. 執行腳本：./create_project.sh
#
# 安全提示：請務必檢查腳本內容，理解其作用後再執行。

echo "正在建立專案目錄結構..."

# 建立主目錄
mkdir -p e-commerce-data-driven-mvp
cd e-commerce-data-driven-mvp

# 建立 Laravel 後端目錄
mkdir -p laravel-backend/app/{Http/{Controllers/{Auth,Api},Middleware},Models,Providers}
mkdir -p laravel-backend/bootstrap
mkdir -p laravel-backend/config
mkdir -p laravel-backend/database/{factories,migrations,seeders}
mkdir -p laravel-backend/lang
mkdir -p laravel-backend/public
mkdir -p laravel-backend/resources/views/{auth,dashboard,layouts,orders,products,welcome}
mkdir -p laravel-backend/routes
mkdir -p laravel-backend/storage/app/public
mkdir -p laravel-backend/storage/framework/{cache,sessions,testing,views}
mkdir -p laravel-backend/storage/logs
mkdir -p laravel-backend/tests

# 建立 FastAPI 數據服務目錄
mkdir -p fastapi-data-service/app

# 建立 Nginx 配置目錄
mkdir -p nginx

echo "目錄結構建立完成，正在寫入檔案內容..."

# --- 根目錄檔案 ---
cat > .gitignore << 'EOF'
/vendor
/node_modules
/.env
/public/hot
/public/storage
/storage/*.key
/vendor
.idea
.vscode
.DS_Store
Homestead.json
Homestead.yaml
npm-debug.log
yarn-error.log
.env.backup
.env.production
.phpunit.result.cache
EOF

cat > docker-compose.yml << 'EOF'
# e-commerce-data-driven-mvp/docker-compose.yml
# Docker Compose 文件，用於定義和運行多容器 Docker 應用程式。

version: '3.8'

services:
  # Nginx 服務，作為反向代理，將外部請求路由到 Laravel 應用程式
  nginx:
    image: nginx:stable-alpine # 使用 Nginx 的穩定版 Alpine 映像，體積小
    ports:
      - "80:80" # 將主機的 80 端口映射到容器的 80 端口
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/conf.d/default.conf:ro # 掛載 Nginx 配置文件
      - ./laravel-backend:/var/www/html # 掛載 Laravel 應用程式目錄
    depends_on:
      - php # 確保 php 服務在 nginx 啟動前運行
      - fastapi # 確保 fastapi 服務在 nginx 啟動前運行

  # PHP 服務，運行 Laravel 應用程式的 PHP-FPM 進程
  php:
    build:
      context: ./laravel-backend # Dockerfile 的上下文路徑
      dockerfile: Dockerfile.php # 指定 Laravel 的 Dockerfile
    volumes:
      - ./laravel-backend:/var/www/html # 掛載 Laravel 應用程式目錄
    environment:
      # Laravel 環境變數，從 .env 文件中讀取，這裡提供默認值
      - DB_CONNECTION=mysql
      - DB_HOST=db # 數據庫服務的名稱，由 Docker Compose 管理
      - DB_PORT=3306
      - DB_DATABASE=laravel
      - DB_USERNAME=user
      - DB_PASSWORD=password
      - FASTAPI_URL=http://fastapi:8000 # FastAPI 服務的 URL，由 Docker Compose 管理
      # Laravel 的 APP_KEY 會在啟動後通過 `php artisan key:generate` 生成
    depends_on:
      - db # 確保數據庫服務在 php 服務啟動前運行

  # FastAPI 數據服務，用於數據分析和推薦
  fastapi:
    build:
      context: ./fastapi-data-service # Dockerfile 的上下文路徑
      dockerfile: Dockerfile # 指定 FastAPI 的 Dockerfile
    volumes:
      - ./fastapi-data-service:/app # 掛載 FastAPI 應用程式目錄
    ports:
      - "8000:8000" # 將主機的 8000 端口映射到容器的 8000 端口
    environment:
      # FastAPI 可以通過這個 URL 調用 Laravel 的 API，如果需要獲取原始數據
      # 但在此 MVP 中，FastAPI 主要處理內部模擬數據或直接讀取數據庫
      - LARAVEL_API_URL=http://php:9000/api # Laravel PHP-FPM 服務在容器內部的地址
    command: uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload # FastAPI 啟動命令

  # MySQL 數據庫服務
  db:
    image: mysql:8.0 # 使用 MySQL 8.0 映像
    environment:
      # MySQL 環境變數，用於初始化數據庫
      MYSQL_ROOT_PASSWORD: root_password
      MYSQL_DATABASE: laravel
      MYSQL_USER: user
      MYSQL_PASSWORD: password
    volumes:
      - db_data:/var/lib/mysql # 將數據庫數據持久化到 Docker volume

# Docker volumes，用於持久化數據，即使容器被刪除數據也不會丟失
volumes:
  db_data:
EOF

# --- Nginx 配置檔案 ---
cat > nginx/nginx.conf << 'EOF'
# e-commerce-data-driven-mvp/nginx/nginx.conf
# Nginx 服務器塊配置，用於處理來自 80 端口的請求

server {
    listen 80; # 監聽 80 端口
    server_name localhost; # 服務器名稱

    # 定義根目錄和索引文件
    root /var/www/html/public;
    index index.php index.html index.htm;

    charset utf-8;

    # 處理所有非文件請求，將其重寫到 index.php
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    # 處理 .php 文件請求，將其轉發給 php-fpm
    location ~ \.php$ {
        fastcgi_pass php:9000; # 將請求轉發到 php 服務的 9000 端口
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params; # 包含 FastCGI 參數
    }

    # 禁止訪問 .env 文件
    location ~ /\.env {
        deny all;
    }
}
EOF

# --- Laravel 後端檔案 ---
cat > laravel-backend/Dockerfile.php << 'EOF'
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
EOF

cat > laravel-backend/composer.json << 'EOF'
// e-commerce-data-driven-mvp/laravel-backend/composer.json
{
    "name": "laravel/laravel",
    "type": "project",
    "autoload": {
        "psr-4": {
            "App\\": "app/",
            "Database\\Factories\\": "database/factories/",
            "Database\\Seeders\\": "database/seeders/"
        }
    },
    "require": {
        "php": "^8.2",
        "guzzlehttp/guzzle": "^7.8",
        "laravel/framework": "^11.0",
        "laravel/sanctum": "^4.0",
        "laravel/tinker": "^2.9"
    },
    "require-dev": {
        "fakerphp/faker": "^1.23",
        "laravel/pint": "^1.13",
        "laravel/sail": "^1.26",
        "mockery/mockery": "^1.6",
        "nunomaduro/collision": "^8.1",
        "phpunit/phpunit": "^11.0.1",
        "spatie/laravel-ignition": "^2.4"
    },
    "config": {
        "optimize-autoloader": true,
        "preferred-install": "dist",
        "sort-packages": true,
        "allow-plugins": {
            "pestphp/pest-plugin": true,
            "php-http/discovery": true
        }
    },
    "extra": {
        "laravel": {
            "dont-discover": []
        }
    },
    "minimum-stability": "stable",
    "prefer-stable": true,
    "scripts": {
        "post-autoload-dump": [
            "Illuminate\\Foundation\\ComposerScripts::postAutoloadDump",
            "@php artisan package:discover --ansi"
        ],
        "post-update-cmd": [
            "@php artisan vendor:publish --tag=laravel-assets --ansi --force"
        ],
        "post-root-package-install": [
            "@php -r \"file_exists('.env') || copy('.env.example', '.env');\""
        ],
        "post-create-project-cmd": [
            "@php artisan key:generate --ansi"
        ]
    }
}
EOF

cat > laravel-backend/.env.example << 'EOF'
# e-commerce-data-driven-mvp/laravel-backend/.env.example
# Laravel 環境變數示例文件

APP_NAME="E-commerce Data Driven MVP"
APP_ENV=local
APP_KEY= # 在執行 `php artisan key:generate` 後會自動填充
APP_DEBUG=true
APP_URL=http://localhost

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=db # Docker Compose 服務名
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=user
DB_PASSWORD=password

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

MEMCACHED_HOST=127.0.0.1

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=log
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false

PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_HOST=
PUSHER_PORT=443
PUSHER_SCHEME=https
PUSHER_APP_CLUSTER=mt1

VITE_APP_NAME="${APP_NAME}"
VITE_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
VITE_PUSHER_HOST="${PUSHER_HOST}"
VITE_PUSHER_PORT="${PUSHER_PORT}"
VITE_PUSHER_SCHEME="${PUSHER_SCHEME}"
VITE_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"

# FastAPI 數據服務的 URL
FASTAPI_URL=http://fastapi:8000 # Docker Compose 服務名和端口
EOF

# --- Laravel 遷移檔案 ---
cat > laravel-backend/database/migrations/2014_10_12_000000_create_users_table.php << 'EOF'
<?php
// e-commerce-data-driven-mvp/laravel-backend/database/migrations/2014_10_12_000000_create_users_table.php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * 運行數據庫遷移。
     * 創建 'users' 表。
     */
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password');
            $table->rememberToken();
            $table->timestamps();
        });
    }

    /**
     * 回滾數據庫遷移。
     * 刪除 'users' 表。
     */
    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
EOF

cat > laravel-backend/database/migrations/2023_01_01_000000_create_products_table.php << 'EOF'
<?php
// e-commerce-data-driven-mvp/laravel-backend/database/migrations/2023_01_01_000000_create_products_table.php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * 運行數據庫遷移。
     * 創建 'products' 表。
     */
    public function up(): void
    {
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('description')->nullable();
            $table->decimal('price', 8, 2);
            $table->string('category')->nullable();
            $table->integer('stock')->default(0);
            $table->timestamps();
        });
    }

    /**
     * 回滾數據庫遷移。
     * 刪除 'products' 表。
     */
    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};
EOF

cat > laravel-backend/database/migrations/2023_01_02_000000_create_orders_table.php << 'EOF'
<?php
// e-commerce-data-driven-mvp/laravel-backend/database/migrations/2023_01_02_000000_create_orders_table.php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * 運行數據庫遷移。
     * 創建 'orders' 表。
     */
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade'); // 關聯用戶表
            $table->decimal('total_amount', 10, 2);
            $table->string('status')->default('pending'); // 例如：pending, completed, cancelled
            $table->timestamps();
        });

        // 創建 'order_items' 表來存儲訂單中的商品
        Schema::create('order_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained()->onDelete('cascade'); // 關聯訂單表
            $table->foreignId('product_id')->constrained()->onDelete('cascade'); // 關聯商品表
            $table->integer('quantity');
            $table->decimal('price', 8, 2); // 訂單時的商品價格
            $table->timestamps();
        });
    }

    /**
     * 回滾數據庫遷移。
     * 刪除 'order_items' 和 'orders' 表。
     */
    public function down(): void
    {
        Schema::dropIfExists('order_items');
        Schema::dropIfExists('orders');
    }
};
EOF

cat > laravel-backend/database/migrations/2023_01_03_000000_create_user_product_interactions_table.php << 'EOF'
<?php
// e-commerce-data-driven-mvp/laravel-backend/database/migrations/2023_01_03_000000_create_user_product_interactions_table.php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * 運行數據庫遷移。
     * 創建 'user_product_interactions' 表，記錄用戶與商品的交互。
     */
    public function up(): void
    {
        Schema::create('user_product_interactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade'); // 用戶ID
            $table->foreignId('product_id')->constrained()->onDelete('cascade'); // 商品ID
            $table->string('interaction_type'); // 交互類型，例如 'view', 'add_to_cart', 'purchase'
            $table->timestamps();

            # 為用戶和商品添加聯合唯一索引，確保同一時間同一用戶對同一商品只有一種交互類型記錄 (可根據需求調整)
            # 這裡不加唯一索引，允許同一個用戶對同一個商品有多個交互記錄
            $table->index(['user_id', 'product_id', 'interaction_type']);
        });
    }

    /**
     * 回滾數據庫遷移。
     * 刪除 'user_product_interactions' 表。
     */
    public function down(): void
    {
        Schema::dropIfExists('user_product_interactions');
    }
};
EOF

# --- Laravel Model 檔案 ---
cat > laravel-backend/app/Models/User.php << 'EOF'
<?php
// e-commerce-data-driven-mvp/laravel-backend/app/Models/User.php
namespace App\Models;

use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * 允許批量賦值的屬性。
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
    ];

    /**
     * 應隱藏的屬性。
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * 應轉換為不同數據類型的屬性。
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    /**
     * 獲取與用戶相關聯的訂單。
     */
    public function orders()
    {
        return $this->hasMany(Order::class);
    }

    /**
     * 獲取與用戶相關聯的商品交互記錄。
     */
    public function interactions()
    {
        return $this->hasMany(UserProductInteraction::class);
    }
}
EOF

cat > laravel-backend/app/Models/Product.php << 'EOF'
<?php
// e-commerce-data-driven-mvp/laravel-backend/app/Models/Product.php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    /**
     * 允許批量賦值的屬性。
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'description',
        'price',
        'category',
        'stock',
    ];

    /**
     * 獲取與商品相關聯的訂單項。
     */
    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }

    /**
     * 獲取與商品相關聯的用戶交互記錄。
     */
    public function interactions()
    {
        return $this->hasMany(UserProductInteraction::class);
    }
}
EOF

cat > laravel-backend/app/Models/Order.php << 'EOF'
<?php
// e-commerce-data-driven-mvp/laravel-backend/app/Models/Order.php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    /**
     * 允許批量賦值的屬性。
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'user_id',
        'total_amount',
        'status',
    ];

    /**
     * 獲取擁有此訂單的用戶。
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * 獲取與訂單相關聯的訂單項。
     */
    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }
}
EOF

cat > laravel-backend/app/Models/OrderItem.php << 'EOF'
<?php
// e-commerce-data-driven-mvp/laravel-backend/app/Models/OrderItem.php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderItem extends Model
{
    use HasFactory;

    /**
     * 允許批量賦值的屬性。
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'order_id',
        'product_id',
        'quantity',
        'price',
    ];

    /**
     * 獲取擁有此訂單項的訂單。
     */
    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    /**
     * 獲取訂單項所屬的商品。
     */
    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}
EOF

cat > laravel-backend/app/Models/UserProductInteraction.php << 'EOF'
<?php
// e-commerce-data-driven-mvp/laravel-backend/app/Models/UserProductInteraction.php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UserProductInteraction extends Model
{
    use HasFactory;

    /**
     * 允許批量賦值的屬性。
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'user_id',
        'product_id',
        'interaction_type', # 'view', 'add_to_cart', 'purchase'
    ];

    /**
     * 獲取交互所屬的用戶。
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * 獲取交互所屬的商品。
     */
    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}
EOF

# --- Laravel Controller 檔案 ---
cat > laravel-backend/app/Http/Controllers/Auth/RegisteredUserController.php << 'EOF'
<?php
// e-commerce-data-driven-mvp/laravel-backend/app/Http/Controllers/Auth/RegisteredUserController.php
// 簡化註冊控制器，基於 Laravel 11 默認實現

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Auth\Events\Registered;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules;
use Illuminate\View\View;

class RegisteredUserController extends Controller
{
    /**
     * 顯示註冊視圖。
     */
    public function create(): View
    {
        return view('auth.register');
    }

    /**
     * 處理傳入的註冊請求。
     *
     * @throws \Illuminate\Validation\ValidationException
     */
    public function store(Request $request): RedirectResponse
    {
        $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:'.User::class],
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);

        event(new Registered($user));

        Auth::login($user);

        return redirect(route('dashboard', absolute: false)); # 重定向到儀表板
    }
}
EOF

cat > laravel-backend/app/Http/Controllers/Auth/AuthenticatedSessionController.php << 'EOF'
<?php
// e-commerce-data-driven-mvp/laravel-backend/app/Http/Controllers/Auth/AuthenticatedSessionController.php
// 簡化登錄控制器，基於 Laravel 11 默認實現

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class AuthenticatedSessionController extends Controller
{
    /**
     * 顯示登錄視圖。
     */
    public function create(): View
    {
        return view('auth.login');
    }

    /**
     * 處理傳入的認證請求。
     */
    public function store(Request $request): RedirectResponse
    {
        $request->validate([
            'email' => ['required', 'string', 'email'],
            'password' => ['required', 'string'],
        ]);

        $credentials = $request->only('email', 'password');

        if (Auth::attempt($credentials, $request->remember)) {
            $request->session()->regenerate();

            return redirect()->intended(route('dashboard', absolute: false));
        }

        return back()->withErrors([
            'email' => '提供的憑據與我們的記錄不符。',
        ])->onlyInput('email');
    }

    /**
     * 銷毀一個認證會話。
     */
    public function destroy(Request $request): RedirectResponse
    {
        Auth::guard('web')->logout();

        $request->session()->invalidate();

        $request->session()->regenerateToken();

        return redirect('/');
    }
}
EOF

cat > laravel-backend/app/Http/Controllers/ProductController.php << 'EOF'
<?php
// e-commerce-data-driven-mvp/laravel-backend/app/Http/Controllers/ProductController.php
namespace App\Http\Controllers;

use App\Models\Product;
use App\Models\UserProductInteraction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Auth;

class ProductController extends Controller
{
    /**
     * 顯示所有商品的列表。
     */
    public function index()
    {
        $products = Product::all();
        return view('products.index', compact('products'));
    }

    /**
     * 顯示特定商品的詳情。
     */
    public function show(Product $product)
    {
        // 記錄用戶查看商品行為
        if (Auth::check()) {
            UserProductInteraction::create([
                'user_id' => Auth::id(),
                'product_id' => $product->id,
                'interaction_type' => 'view',
            ]);
        }

        // 調用 FastAPI 獲取相關商品推薦 (簡單的示例)
        $relatedProducts = [];
        try {
            $response = Http::get(env('FASTAPI_URL') . '/recommendations/related/' . $product->id);
            if ($response->successful()) {
                $relatedProducts = $response->json();
            } else {
                \Log::error('FastAPI 相關商品推薦失敗: ' . $response->body());
            }
        } catch (\Exception $e) {
            \Log::error('FastAPI 相關商品推薦連接失敗: ' . $e->getMessage());
        }

        return view('products.show', compact('product', 'relatedProducts'));
    }

    /**
     * 獲取並顯示熱門商品。
     */
    public function popular()
    {
        $popularProducts = [];
        try {
            $response = Http::get(env('FASTAPI_URL') . '/products/popular');
            if ($response->successful()) {
                $popularProducts = $response->json();
            } else {
                \Log::error('FastAPI 熱門商品獲取失敗: ' . $response->body());
            }
        } catch (\Exception $e) {
            \Log::error('FastAPI 熱門商品連接失敗: ' . $e->getMessage());
        }

        return view('products.popular', compact('popularProducts'));
    }

    /**
     * 獲取並顯示針對當前登錄用戶的推薦商品。
     */
    public function recommendations()
    {
        $recommendedProducts = [];
        if (Auth::check()) {
            try {
                $response = Http::get(env('FASTAPI_URL') . '/recommendations/user/' . Auth::id());
                if ($response->successful()) {
                    $recommendedProducts = $response->json();
                } else {
                    \Log::error('FastAPI 用戶推薦獲取失敗: ' . $response->body());
                }
            } catch (\Exception $e) {
                \Log::error('FastAPI 用戶推薦連接失敗: ' . $e->getMessage());
            }
        } else {
            // 如果用戶未登錄，可以顯示熱門商品作為默認推薦
            return redirect()->route('products.popular');
        }

        return view('products.recommendations', compact('recommendedProducts'));
    }

    /**
     * 處理添加到購物車的請求 (簡化版，無實際購物車邏輯，僅記錄交互)。
     */
    public function addToCart(Request $request, Product $product)
    {
        if (Auth::check()) {
            UserProductInteraction::create([
                'user_id' => Auth::id(),
                'product_id' => $product->id,
                'interaction_type' => 'add_to_cart',
            ]);
            return back()->with('success', '商品已添加到購物車 (交互已記錄)。');
        }
        return back()->with('error', '請登錄後再將商品添加到購物車。');
    }
}
EOF

cat > laravel-backend/app/Http/Controllers/OrderController.php << 'EOF'
<?php
// e-commerce-data-driven-mvp/laravel-backend/app/Http/Controllers/OrderController.php
namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use App\Models\UserProductInteraction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class OrderController extends Controller
{
    /**
     * 顯示當前登錄用戶的所有訂單。
     */
    public function index()
    {
        $orders = Auth::user()->orders()->with('orderItems.product')->latest()->get();
        return view('orders.index', compact('orders'));
    }

    /**
     * 顯示特定訂單的詳情。
     */
    public function show(Order $order)
    {
        // 確保用戶只能查看自己的訂單
        if ($order->user_id !== Auth::id()) {
            abort(403, '未經授權。');
        }
        $order->load('orderItems.product');
        return view('orders.show', compact('order'));
    }

    /**
     * 處理創建新訂單的請求 (簡化版，直接從單個商品創建訂單)。
     */
    public function store(Request $request)
    {
        $request->validate([
            'product_id' => 'required|exists:products,id',
            'quantity' => 'required|integer|min:1',
        ]);

        $product = Product::find($request->product_id);

        if (!$product || $product->stock < $request->quantity) {
            return back()->with('error', '商品庫存不足或不存在。');
        }

        DB::transaction(function () use ($request, $product) {
            $user = Auth::user();
            $quantity = $request->quantity;
            $totalAmount = $product->price * $quantity;

            // 創建訂單
            $order = Order::create([
                'user_id' => $user->id,
                'total_amount' => $totalAmount,
                'status' => 'completed', # 簡化為直接完成
            ]);

            // 創建訂單項
            OrderItem::create([
                'order_id' => $order->id,
                'product_id' => $product->id,
                'quantity' => $quantity,
                'price' => $product->price,
            ]);

            // 更新商品庫存
            $product->decrement('stock', $quantity);

            // 記錄用戶購買交互
            UserProductInteraction::create([
                'user_id' => $user->id,
                'product_id' => $product->id,
                'interaction_type' => 'purchase',
            ]);
        });

        return redirect()->route('orders.index')->with('success', '訂單已成功創建！');
    }
}
EOF

# --- Laravel Database Seeder 檔案 ---
cat > laravel-backend/database/seeders/DatabaseSeeder.php << 'EOF'
<?php
// e-commerce-data-driven-mvp/laravel-backend/database/seeders/DatabaseSeeder.php
namespace Database\Seeders;

use App\Models\User;
use App\Models\Product;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\UserProductInteraction;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * 運行數據庫種子。
     * 填充測試數據。
     */
    public function run(): void
    {
        // 創建一個測試用戶
        $user = User::factory()->create([
            'name' => 'Test User',
            'email' => 'test@example.com',
            'password' => Hash::make('password'),
        ]);

        // 創建一些商品
        $products = Product::factory()->count(10)->create();

        // 為測試用戶創建一些訂單和訂單項
        $order1 = Order::create([
            'user_id' => $user->id,
            'total_amount' => 0, # 稍後更新
            'status' => 'completed',
        ]);
        $totalAmount1 = 0;
        foreach ($products->random(3) as $product) {
            $quantity = rand(1, 3);
            OrderItem::create([
                'order_id' => $order1->id,
                'product_id' => $product->id,
                'quantity' => $quantity,
                'price' => $product->price,
            ]);
            $totalAmount1 += $product->price * $quantity;
            $product->decrement('stock', $quantity); # 更新庫存
        }
        $order1->update(['total_amount' => $totalAmount1]);


        $order2 = Order::create([
            'user_id' => $user->id,
            'total_amount' => 0,
            'status' => 'completed',
        ]);
        $totalAmount2 = 0;
        foreach ($products->random(2) as $product) {
            $quantity = rand(1, 2);
            OrderItem::create([
                'order_id' => $order2->id,
                'product_id' => $product->id,
                'quantity' => $quantity,
                'price' => $product->price,
            ]);
            $totalAmount2 += $product->price * $quantity;
            $product->decrement('stock', $quantity); # 更新庫存
        }
        $order2->update(['total_amount' => $totalAmount2]);

        // 記錄一些用戶與商品的交互行為 (例如：瀏覽、加入購物車、購買)
        // 購買行為在 OrderController 中會自動記錄，這裡添加一些瀏覽和加入購物車
        foreach ($products->random(5) as $product) {
            UserProductInteraction::create([
                'user_id' => $user->id,
                'product_id' => $product->id,
                'interaction_type' => 'view',
            ]);
        }

        foreach ($products->random(2) as $product) {
            UserProductInteraction::create([
                'user_id' => $user->id,
                'product_id' => $product->id,
                'interaction_type' => 'add_to_cart',
            ]);
        }

        // 創建更多隨機用戶和他們的交互
        User::factory()->count(5)->create()->each(function ($u) use ($products) {
            // 為每個用戶創建一些隨機交互
            foreach ($products->random(rand(2, 5)) as $product) {
                UserProductInteraction::create([
                    'user_id' => $u->id,
                    'product_id' => $product->id,
                    'interaction_type' => ['view', 'add_to_cart', 'purchase'][array_rand(['view', 'add_to_cart', 'purchase'])],
                    'created_at' => now()->subDays(rand(0, 30)), # 過去30天內的隨機時間
                ]);

                # 如果是購買行為，則創建一個簡單的訂單
                if (UserProductInteraction::where('user_id', $u->id)
                                          ->where('product_id', $product->id)
                                          ->where('interaction_type', 'purchase')
                                          ->exists()) {
                    $quantity = rand(1, 2);
                    $totalAmount = $product->price * $quantity;
                    $order = Order::create([
                        'user_id' => $u->id,
                        'total_amount' => $totalAmount,
                        'status' => 'completed',
                        'created_at' => now()->subDays(rand(0, 30)),
                    ]);
                    OrderItem::create([
                        'order_id' => $order->id,
                        'product_id' => $product->id,
                        'quantity' => $quantity,
                        'price' => $product->price,
                    ]);
                    $product->decrement('stock', $quantity);
                }
            }
        });
    }
}
EOF

# --- Laravel Route 檔案 ---
cat > laravel-backend/routes/web.php << 'EOF'
<?php
// e-commerce-data-driven-mvp/laravel-backend/routes/web.php
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\OrderController;
use Illuminate\Support\Facades\Route;

// 主頁路由
Route::get('/', function () {
    return view('welcome');
});

// 儀表板 (需要認證)
Route::get('/dashboard', function () {
    return view('dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');

// 認證路由 (Laravel Breeze 或類似工具會自動生成)
// 為了簡化，這裡手動添加最基本的 auth 路由
require __DIR__.'/auth.php';

// 商品相關路由
Route::middleware('auth')->group(function () {
    Route::get('/products', [ProductController::class, 'index'])->name('products.index');
    Route::get('/products/{product}', [ProductController::class, 'show'])->name('products.show');
    Route::post('/products/{product}/add-to-cart', [ProductController::class, 'addToCart'])->name('products.addToCart');

    // 數據驅動相關路由
    Route::get('/products/popular', [ProductController::class, 'popular'])->name('products.popular');
    Route::get('/products/recommendations', [ProductController::class, 'recommendations'])->name('products.recommendations');

    // 訂單相關路由
    Route::get('/orders', [OrderController::class, 'index'])->name('orders.index');
    Route::get('/orders/{order}', [OrderController::class, 'show'])->name('orders.show');
    Route::post('/orders', [OrderController::class, 'store'])->name('orders.store');
});
EOF

cat > laravel-backend/routes/auth.php << 'EOF'
<?php
// e-commerce-data-driven-mvp/laravel-backend/routes/auth.php
// 簡化認證路由，為了 MVP 最小化
// 在實際 Laravel 項目中，通常會使用 `php artisan install:auth` 或 `breeze:install` 來生成

use App\Http\Controllers\Auth\AuthenticatedSessionController;
use App\Http\Controllers\Auth\RegisteredUserController;
use Illuminate\Support\Facades\Route;

Route::middleware('guest')->group(function () {
    Route::get('register', [RegisteredUserController::class, 'create'])
                ->name('register');

    Route::post('register', [RegisteredUserController::class, 'store']);

    Route::get('login', [AuthenticatedSessionController::class, 'create'])
                ->name('login');

    Route::post('login', [AuthenticatedSessionController::class, 'store']);
});

Route::middleware('auth')->group(function () {
    Route::post('logout', [AuthenticatedSessionController::class, 'destroy'])
                ->name('logout');
});
EOF

cat > laravel-backend/routes/api.php << 'EOF'
<?php
// e-commerce-data-driven-mvp/laravel-backend/routes/api.php
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Models\Product;
use App\Models\UserProductInteraction;
use App\Models\Order;
use App\Models\OrderItem;


/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| 這裡註冊了您的應用程式的 API 路由。這些路由由 RouteServiceProvider 加載
| 並分配給 "api" 中間件組。盡情構建您的 API 吧！
|
*/

// 提供給 FastAPI 或其他外部服務調用的 API
Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// 商品數據 API (供 FastAPI 獲取原始數據，如果需要的話)
Route::get('/products', function () {
    return response()->json(Product::all());
});

// 用戶交互數據 API (供 FastAPI 獲取原始數據)
Route::get('/user-interactions', function () {
    return response()->json(UserProductInteraction::all());
});

// 訂單數據 API (供 FastAPI 獲取原始數據)
Route::get('/orders', function () {
    return response()->json(Order::with('orderItems.product')->get());
});

// 可以在這裡添加更多 API 端點
EOF

# --- Laravel View 檔案 ---
cat > laravel-backend/resources/views/layouts/app.blade.php << 'EOF'
<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>電商 MVP - @yield('title', '首頁')</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #f3f4f6;
        }
        .container {
            max-width: 1200px;
        }
    </style>
</head>
<body class="bg-gray-100 antialiased">
    <div class="min-h-screen bg-gray-100">
        <nav class="bg-white shadow-md">
            <div class="container mx-auto px-4 py-3 flex justify-between items-center">
                <a href="{{ url('/') }}" class="text-2xl font-bold text-gray-800 rounded-md p-2 hover:bg-gray-100">電商 MVP</a>
                <div class="flex items-center space-x-4">
                    <a href="{{ route('products.index') }}" class="text-gray-700 hover:text-blue-600 font-medium p-2 rounded-md hover:bg-blue-50 transition-colors duration-200">所有商品</a>
                    <a href="{{ route('products.popular') }}" class="text-gray-700 hover:text-blue-600 font-medium p-2 rounded-md hover:bg-blue-50 transition-colors duration-200">熱門商品</a>
                    @auth
                        <a href="{{ route('products.recommendations') }}" class="text-gray-700 hover:text-blue-600 font-medium p-2 rounded-md hover:bg-blue-50 transition-colors duration-200">為您推薦</a>
                        <a href="{{ route('orders.index') }}" class="text-gray-700 hover:text-blue-600 font-medium p-2 rounded-md hover:bg-blue-50 transition-colors duration-200">我的訂單</a>
                        <form method="POST" action="{{ route('logout') }}">
                            @csrf
                            <button type="submit" class="bg-red-500 hover:bg-red-600 text-white font-bold py-2 px-4 rounded-md shadow-md transition-colors duration-200">
                                登出 ({{ Auth::user()->name }})
                            </button>
                        </form>
                    @else
                        <a href="{{ route('login') }}" class="text-blue-600 hover:text-white hover:bg-blue-600 font-bold py-2 px-4 rounded-md border border-blue-600 transition-colors duration-200">登錄</a>
                        <a href="{{ route('register') }}" class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-md shadow-md transition-colors duration-200">註冊</a>
                    @endauth
                </div>
            </div>
        </nav>

        <main class="container mx-auto px-4 py-8">
            @if (session('success'))
                <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded-md relative mb-4" role="alert">
                    <strong class="font-bold">成功!</strong>
                    <span class="block sm:inline">{{ session('success') }}</span>
                </div>
            @endif
            @if (session('error'))
                <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded-md relative mb-4" role="alert">
                    <strong class="font-bold">錯誤!</strong>
                    <span class="block sm:inline">{{ session('error') }}</span>
                </div>
            @endif

            @yield('content')
        </main>
    </div>
</body>
</html>
EOF

cat > laravel-backend/resources/views/welcome.blade.php << 'EOF'
@extends('layouts.app')

@section('title', '歡迎')

@section('content')
    <div class="text-center py-12 bg-white rounded-lg shadow-md">
        <h1 class="text-5xl font-extrabold text-gray-900 mb-4">
            智能數據驅動電商平台 MVP
        </h1>
        <p class="text-xl text-gray-600 mb-8">
            透過 Laravel、FastAPI、Pandas 和 NumPy 的整合，展示數據的力量。
        </p>
        <div class="space-x-4">
            <a href="{{ route('products.index') }}" class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg shadow-lg transition-colors duration-300">
                瀏覽所有商品
            </a>
            @auth
                <a href="{{ route('dashboard') }}" class="bg-gray-200 hover:bg-gray-300 text-gray-800 font-bold py-3 px-6 rounded-lg shadow-lg transition-colors duration-300">
                    前往儀表板
                </a>
            @else
                <a href="{{ route('login') }}" class="bg-gray-200 hover:bg-gray-300 text-gray-800 font-bold py-3 px-6 rounded-lg shadow-lg transition-colors duration-300">
                    登錄
                </a>
                <a href="{{ route('register') }}" class="bg-gray-200 hover:bg-gray-300 text-gray-800 font-bold py-3 px-6 rounded-lg shadow-lg transition-colors duration-300">
                    註冊
                </a>
            @endauth
        </div>
    </div>

    <div class="mt-12">
        <h2 class="text-3xl font-bold text-gray-800 mb-6 text-center">探索數據智能</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
            <div class="bg-white rounded-lg shadow-md p-6">
                <h3 class="text-2xl font-semibold text-blue-600 mb-3">商品推薦</h3>
                <p class="text-gray-700 mb-4">
                    基於用戶行為和商品數據，我們的智能推薦引擎（由 FastAPI 提供支持）能夠為您提供個性化的商品建議。
                </p>
                <a href="{{ route('products.recommendations') }}" class="text-blue-600 hover:underline font-semibold">查看推薦商品 &rarr;</a>
            </div>
            <div class="bg-white rounded-lg shadow-md p-6">
                <h3 class="text-2xl font-semibold text-blue-600 mb-3">熱門商品洞察</h3>
                <p class="text-gray-700 mb-4">
                    了解目前最受歡迎的商品。這些趨勢分析由 FastAPI 實時處理，為您提供市場熱點。
                </p>
                <a href="{{ route('products.popular') }}" class="text-blue-600 hover:underline font-semibold">查看熱門商品 &rarr;</a>
            </div>
        </div>
    </div>
@endsection
EOF

cat > laravel-backend/resources/views/dashboard.blade.php << 'EOF'
@extends('layouts.app')

@section('title', '儀表板')

@section('content')
    <h1 class="text-4xl font-bold text-gray-900 mb-6 text-center">歡迎, {{ Auth::user()->name }}!</h1>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div class="bg-white p-6 rounded-lg shadow-md flex flex-col items-center justify-center text-center transition-transform transform hover:scale-105 duration-300">
            <h2 class="text-2xl font-semibold text-gray-800 mb-3">瀏覽商品</h2>
            <p class="text-gray-600 mb-4">發現我們目錄中的所有商品。</p>
            <a href="{{ route('products.index') }}" class="bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-4 rounded-md shadow-md">前往商品頁</a>
        </div>

        <div class="bg-white p-6 rounded-lg shadow-md flex flex-col items-center justify-center text-center transition-transform transform hover:scale-105 duration-300">
            <h2 class="text-2xl font-semibold text-gray-800 mb-3">查看我的訂單</h2>
            <p class="text-gray-600 mb-4">管理您的歷史訂單和訂單狀態。</p>
            <a href="{{ route('orders.index') }}" class="bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-4 rounded-md shadow-md">我的訂單</a>
        </div>

        <div class="bg-white p-6 rounded-lg shadow-md flex flex-col items-center justify-center text-center transition-transform transform hover:scale-105 duration-300">
            <h2 class="text-2xl font-semibold text-gray-800 mb-3">熱門商品</h2>
            <p class="text-gray-600 mb-4">看看大家都在買什麼。</p>
            <a href="{{ route('products.popular') }}" class="bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-4 rounded-md shadow-md">查看熱門</a>
        </div>

        <div class="bg-white p-6 rounded-lg shadow-md flex flex-col items-center justify-center text-center transition-transform transform hover:scale-105 duration-300">
            <h2 class="text-2xl font-semibold text-gray-800 mb-3">為您推薦</h2>
            <p class="text-gray-600 mb-4">探索為您個性化推薦的商品。</p>
            <a href="{{ route('products.recommendations') }}" class="bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-4 rounded-md shadow-md">獲取推薦</a>
        </div>
    </div>
@endsection
EOF

cat > laravel-backend/resources/views/auth/login.blade.php << 'EOF'
@extends('layouts.app')

@section('title', '登錄')

@section('content')
    <div class="flex items-center justify-center min-h-screen -mt-16">
        <div class="w-full max-w-md bg-white p-8 rounded-lg shadow-lg">
            <h2 class="text-3xl font-bold text-gray-900 text-center mb-6">登錄您的帳戶</h2>

            @if ($errors->any())
                <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded-md relative mb-4">
                    <ul>
                        @foreach ($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif

            <form method="POST" action="{{ route('login') }}">
                @csrf

                <div class="mb-4">
                    <label for="email" class="block text-gray-700 text-sm font-bold mb-2">電子郵件地址</label>
                    <input type="email" name="email" id="email" value="{{ old('email') }}" required autofocus autocomplete="username"
                           class="shadow appearance-none border rounded-md w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-400 focus:border-transparent transition-all duration-200">
                </div>

                <div class="mb-6">
                    <label for="password" class="block text-gray-700 text-sm font-bold mb-2">密碼</label>
                    <input type="password" name="password" id="password" required autocomplete="current-password"
                           class="shadow appearance-none border rounded-md w-full py-2 px-3 text-gray-700 mb-3 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-400 focus:border-transparent transition-all duration-200">
                </div>

                <div class="flex items-center justify-between mb-6">
                    <label for="remember_me" class="flex items-center">
                        <input type="checkbox" name="remember" id="remember_me" class="rounded-md border-gray-300 text-blue-600 shadow-sm focus:ring-blue-500">
                        <span class="ml-2 text-sm text-gray-600">記住我</span>
                    </label>
                </div>

                <div class="flex items-center justify-end">
                    <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-md shadow-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50 transition-colors duration-200">
                        登錄
                    </button>
                </div>
            </form>

            <p class="text-center text-gray-600 text-sm mt-6">
                還沒有帳戶？ <a href="{{ route('register') }}" class="text-blue-600 hover:underline font-semibold">註冊一個</a>
            </p>
        </div>
    </div>
@endsection
EOF

cat > laravel-backend/resources/views/auth/register.blade.php << 'EOF'
@extends('layouts.app')

@section('title', '註冊')

@section('content')
    <div class="flex items-center justify-center min-h-screen -mt-16">
        <div class="w-full max-w-md bg-white p-8 rounded-lg shadow-lg">
            <h2 class="text-3xl font-bold text-gray-900 text-center mb-6">創建您的帳戶</h2>

            @if ($errors->any())
                <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded-md relative mb-4">
                    <ul>
                        @foreach ($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif

            <form method="POST" action="{{ route('register') }}">
                @csrf

                <div class="mb-4">
                    <label for="name" class="block text-gray-700 text-sm font-bold mb-2">名稱</label>
                    <input type="text" name="name" id="name" value="{{ old('name') }}" required autofocus autocomplete="name"
                           class="shadow appearance-none border rounded-md w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-400 focus:border-transparent transition-all duration-200">
                </div>

                <div class="mb-4">
                    <label for="email" class="block text-gray-700 text-sm font-bold mb-2">電子郵件地址</label>
                    <input type="email" name="email" id="email" value="{{ old('email') }}" required autocomplete="username"
                           class="shadow appearance-none border rounded-md w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-400 focus:border-transparent transition-all duration-200">
                </div>

                <div class="mb-4">
                    <label for="password" class="block text-gray-700 text-sm font-bold mb-2">密碼</label>
                    <input type="password" name="password" id="password" required autocomplete="new-password"
                           class="shadow appearance-none border rounded-md w-full py-2 px-3 text-gray-700 mb-3 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-400 focus:border-transparent transition-all duration-200">
                </div>

                <div class="mb-6">
                    <label for="password_confirmation" class="block text-gray-700 text-sm font-bold mb-2">確認密碼</label>
                    <input type="password" name="password_confirmation" id="password_confirmation" required autocomplete="new-password"
                           class="shadow appearance-none border rounded-md w-full py-2 px-3 text-gray-700 mb-3 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-400 focus:border-transparent transition-all duration-200">
                </div>

                <div class="flex items-center justify-end">
                    <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-md shadow-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50 transition-colors duration-200">
                        註冊
                    </button>
                </div>
            </form>

            <p class="text-center text-gray-600 text-sm mt-6">
                已經有帳戶？ <a href="{{ route('login') }}" class="text-blue-600 hover:underline font-semibold">登錄</a>
            </p>
        </div>
    </div>
@endsection
EOF

cat > laravel-backend/resources/views/products/index.blade.php << 'EOF'
@extends('layouts.app')

@section('title', '所有商品')

@section('content')
    <h1 class="text-4xl font-bold text-gray-900 mb-8 text-center">所有商品</h1>

    @if ($products->isEmpty())
        <p class="text-center text-gray-600 text-xl">目前沒有任何商品。</p>
    @else
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            @foreach ($products as $product)
                <div class="bg-white rounded-lg shadow-md overflow-hidden transition-transform transform hover:scale-105 duration-300">
                    <a href="{{ route('products.show', $product->id) }}">
                        <img src="https://placehold.co/400x300/e0f2fe/0369a1?text={{ urlencode($product->name) }}"
                             alt="{{ $product->name }}"
                             class="w-full h-48 object-cover rounded-t-lg">
                    </a>
                    <div class="p-5">
                        <h2 class="text-xl font-semibold text-gray-800 mb-2 truncate">
                            <a href="{{ route('products.show', $product->id) }}" class="hover:text-blue-600">{{ $product->name }}</a>
                        </h2>
                        <p class="text-gray-600 text-sm mb-3">{{ Str::limit($product->description, 70) }}</p>
                        <div class="flex justify-between items-center mb-4">
                            <span class="text-2xl font-bold text-blue-700">${{ number_format($product->price, 2) }}</span>
                            <span class="text-sm text-gray-500">庫存: {{ $product->stock }}</span>
                        </div>
                        <form action="{{ route('products.addToCart', $product->id) }}" method="POST">
                            @csrf
                            <button type="submit" class="w-full bg-green-500 hover:bg-green-600 text-white font-bold py-2 px-4 rounded-md shadow-md transition-colors duration-200">
                                加入購物車
                            </button>
                        </form>
                    </div>
                </div>
            @endforeach
        </div>
    @endif
@endsection
EOF

cat > laravel-backend/resources/views/products/show.blade.php << 'EOF'
@extends('layouts.app')

@section('title', $product->name)

@section('content')
    <div class="bg-white rounded-lg shadow-lg p-8 flex flex-col md:flex-row gap-8 mb-10">
        <div class="md:w-1/2 flex justify-center items-center">
            <img src="https://placehold.co/600x450/e0f2fe/0369a1?text={{ urlencode($product->name) }}"
                 alt="{{ $product->name }}"
                 class="w-full h-auto max-h-96 object-contain rounded-lg shadow-md">
        </div>

        <div class="md:w-1/2">
            <h1 class="text-4xl font-bold text-gray-900 mb-4">{{ $product->name }}</h1>
            <p class="text-gray-600 text-lg mb-6">{{ $product->description }}</p>

            <div class="flex items-baseline mb-4">
                <span class="text-5xl font-extrabold text-blue-700">${{ number_format($product->price, 2) }}</span>
                <span class="ml-4 text-gray-500">分類: <span class="font-semibold">{{ $product->category }}</span></span>
            </div>

            <div class="mb-6">
                <span class="text-gray-700 font-semibold text-lg">庫存: </span>
                @if ($product->stock > 0)
                    <span class="text-green-600 text-lg">{{ $product->stock }} 件有貨</span>
                @else
                    <span class="text-red-600 text-lg">缺貨</span>
                @endif
            </div>

            <div class="flex space-x-4 mb-8">
                <form action="{{ route('products.addToCart', $product->id) }}" method="POST">
                    @csrf
                    <button type="submit"
                            @if ($product->stock === 0) disabled @endif
                            class="bg-green-600 hover:bg-green-700 text-white font-bold py-3 px-6 rounded-md shadow-lg transition-colors duration-200
                                   @if ($product->stock === 0) opacity-50 cursor-not-allowed @endif">
                        加入購物車
                    </button>
                </form>

                <form action="{{ route('orders.store') }}" method="POST">
                    @csrf
                    <input type="hidden" name="product_id" value="{{ $product->id }}">
                    <input type="hidden" name="quantity" value="1"> {{-- 默認購買 1 件 --}}
                    <button type="submit"
                            @if ($product->stock === 0) disabled @endif
                            class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-md shadow-lg transition-colors duration-200
                                   @if ($product->stock === 0) opacity-50 cursor-not-allowed @endif">
                        立即購買
                    </button>
                </form>
            </div>
        </div>
    </div>

    @if (!empty($relatedProducts))
        <div class="mt-12 bg-white rounded-lg shadow-md p-6">
            <h2 class="text-3xl font-bold text-gray-800 mb-6 text-center">相關商品推薦</h2>
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                @foreach ($relatedProducts as $relatedProduct)
                    <div class="bg-gray-50 rounded-lg shadow-sm overflow-hidden border border-gray-200">
                        <a href="{{ route('products.show', $relatedProduct['product_id']) }}">
                            <img src="https://placehold.co/400x250/e0f2fe/0369a1?text={{ urlencode($relatedProduct['name']) }}"
                                 alt="{{ $relatedProduct['name'] }}"
                                 class="w-full h-40 object-cover rounded-t-lg">
                        </a>
                        <div class="p-4">
                            <h3 class="text-lg font-semibold text-gray-800 mb-1 truncate">
                                <a href="{{ route('products.show', $relatedProduct['product_id']) }}" class="hover:text-blue-600">{{ $relatedProduct['name'] }}</a>
                            </h3>
                            <p class="text-blue-700 font-bold">${{ number_format($relatedProduct['price'], 2) }}</p>
                            <p class="text-gray-500 text-sm">推薦分數: {{ round($relatedProduct['score'], 2) }}</p>
                        </div>
                    </div>
                @endforeach
            </div>
        </div>
    @else
        <div class="mt-12 bg-white rounded-lg shadow-md p-6 text-center">
            <p class="text-gray-600 text-lg">目前沒有相關商品推薦。</p>
        </div>
    @endif
@endsection
EOF

cat > laravel-backend/resources/views/products/popular.blade.php << 'EOF'
@extends('layouts.app')

@section('title', '熱門商品')

@section('content')
    <h1 class="text-4xl font-bold text-gray-900 mb-8 text-center">熱門商品</h1>

    @if (empty($popularProducts))
        <p class="text-center text-gray-600 text-xl">目前無法獲取熱門商品數據。請稍後再試。</p>
    @else
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            @foreach ($popularProducts as $product)
                <div class="bg-white rounded-lg shadow-md overflow-hidden transition-transform transform hover:scale-105 duration-300">
                    <a href="{{ route('products.show', $product['product_id']) }}">
                        <img src="https://placehold.co/400x300/ffe4e6/c23450?text={{ urlencode($product['name']) }}"
                             alt="{{ $product['name'] }}"
                             class="w-full h-48 object-cover rounded-t-lg">
                    </a>
                    <div class="p-5">
                        <h2 class="text-xl font-semibold text-gray-800 mb-2 truncate">
                            <a href="{{ route('products.show', $product['product_id']) }}" class="hover:text-blue-600">{{ $product['name'] }}</a>
                        </h2>
                        <p class="text-gray-600 text-sm mb-3">分類: {{ $product['category'] ?? '未知' }}</p>
                        <div class="flex justify-between items-center">
                            <span class="text-2xl font-bold text-red-700">${{ number_format($product['price'], 2) }}</span>
                            <span class="text-sm text-gray-500">銷量: {{ $product['sales_volume'] ?? 'N/A' }}</span>
                        </div>
                        <p class="text-gray-500 text-sm mt-2">（數據來自 FastAPI）</p>
                    </div>
                </div>
            @endforeach
        </div>
    @endif
@endsection
EOF

cat > laravel-backend/resources/views/products/recommendations.blade.php << 'EOF'
@extends('layouts.app')

@section('title', '為您推薦的商品')

@section('content')
    <h1 class="text-4xl font-bold text-gray-900 mb-8 text-center">為您推薦的商品</h1>

    @if (empty($recommendedProducts))
        <p class="text-center text-gray-600 text-xl">目前沒有推薦商品。請嘗試瀏覽更多商品，以便我們為您生成更精準的推薦。</p>
        <div class="text-center mt-6">
            <a href="{{ route('products.index') }}" class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg shadow-lg transition-colors duration-300">
                開始探索商品
            </a>
        </div>
    @else
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            @foreach ($recommendedProducts as $product)
                <div class="bg-white rounded-lg shadow-md overflow-hidden border-2 border-blue-200 transition-transform transform hover:scale-105 duration-300">
                    <a href="{{ route('products.show', $product['product_id']) }}">
                        <img src="https://placehold.co/400x300/e0f2fe/0369a1?text={{ urlencode($product['name']) }}"
                             alt="{{ $product['name'] }}"
                             class="w-full h-48 object-cover rounded-t-lg">
                        </a>
                    <div class="p-5">
                        <h2 class="text-xl font-semibold text-gray-800 mb-2 truncate">
                            <a href="{{ route('products.show', $product['product_id']) }}" class="hover:text-blue-600">{{ $product['name'] }}</a>
                        </h2>
                        <p class="text-gray-600 text-sm mb-3">分類: {{ $product['category'] ?? '未知' }}</p>
                        <div class="flex justify-between items-center">
                            <span class="text-2xl font-bold text-blue-700">${{ number_format($product['price'], 2) }}</span>
                            <span class="text-sm text-gray-500">推薦分數: {{ round($product['score'], 2) }}</span>
                        </div>
                        <p class="text-gray-500 text-sm mt-2">（數據來自 FastAPI）</p>
                    </div>
                </div>
            @endforeach
        </div>
    @endif
@endsection
EOF

cat > laravel-backend/resources/views/orders/index.blade.php << 'EOF'
@extends('layouts.app')

@section('title', '我的訂單')

@section('content')
    <h1 class="text-4xl font-bold text-gray-900 mb-8 text-center">我的訂單</h1>

    @if ($orders->isEmpty())
        <p class="text-center text-gray-600 text-xl">您目前還沒有任何訂單。</p>
        <div class="text-center mt-6">
            <a href="{{ route('products.index') }}" class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg shadow-lg transition-colors duration-300">
                開始購物
            </a>
        </div>
    @else
        <div class="grid grid-cols-1 gap-6">
            @foreach ($orders as $order)
                <div class="bg-white rounded-lg shadow-md p-6 border border-gray-200">
                    <div class="flex justify-between items-center mb-4 pb-4 border-b border-gray-200">
                        <div>
                            <h2 class="text-2xl font-bold text-gray-800">訂單 #{{ $order->id }}</h2>
                            <p class="text-gray-600 text-sm">訂單日期: {{ $order->created_at->format('Y-m-d H:i') }}</p>
                        </div>
                        <span class="text-xl font-semibold {{ $order->status === 'completed' ? 'text-green-600' : 'text-orange-500' }}">
                            {{ ucfirst($order->status) }}
                        </span>
                    </div>

                    <div class="mb-4">
                        <p class="text-lg font-semibold text-gray-800 mb-2">訂單總額: <span class="text-blue-700 text-2xl">${{ number_format($order->total_amount, 2) }}</span></p>
                    </div>

                    <h3 class="text-xl font-semibold text-gray-700 mb-3">商品列表:</h3>
                    <ul class="space-y-3">
                        @foreach ($order->orderItems as $item)
                            <li class="flex items-center space-x-4 bg-gray-50 p-3 rounded-md border border-gray-100">
                                <img src="https://placehold.co/80x60/f0f9ff/0c4a6e?text={{ urlencode(Str::limit($item->product->name, 10)) }}"
                                     alt="{{ $item->product->name }}"
                                     class="w-16 h-12 object-cover rounded-md">
                                <div>
                                    <a href="{{ route('products.show', $item->product->id) }}" class="text-lg font-medium text-gray-800 hover:text-blue-600">{{ $item->product->name }}</a>
                                    <p class="text-gray-600 text-sm">數量: {{ $item->quantity }} x ${{ number_format($item->price, 2) }}</p>
                                </div>
                                <div class="ml-auto text-lg font-bold text-gray-900">${{ number_format($item->quantity * $item->price, 2) }}</div>
                            </li>
                        @endforeach
                    </ul>

                    <div class="mt-6 text-right">
                        <a href="{{ route('orders.show', $order->id) }}" class="bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-4 rounded-md shadow-md transition-colors duration-200">
                            查看訂單詳情
                        </a>
                    </div>
                </div>
            @endforeach
        </div>
    @endif
@endsection
EOF

cat > laravel-backend/resources/views/orders/show.blade.php << 'EOF'
@extends('layouts.app')

@section('title', '訂單 #' . $order->id . ' 詳情')

@section('content')
    <h1 class="text-4xl font-bold text-gray-900 mb-8 text-center">訂單詳情 #{{ $order->id }}</h1>

    <div class="bg-white rounded-lg shadow-lg p-8 mb-8">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
            <div>
                <p class="text-gray-700 text-lg mb-2"><span class="font-semibold">訂單狀態:</span>
                    <span class="ml-2 text-xl font-bold {{ $order->status === 'completed' ? 'text-green-600' : 'text-orange-500' }}">
                        {{ ucfirst($order->status) }}
                    </span>
                </p>
                <p class="text-gray-700 text-lg"><span class="font-semibold">訂單日期:</span> {{ $order->created_at->format('Y-m-d H:i:s') }}</p>
            </div>
            <div class="text-right">
                <p class="text-gray-700 text-lg"><span class="font-semibold">總金額:</span>
                    <span class="ml-2 text-3xl font-extrabold text-blue-700">${{ number_format($order->total_amount, 2) }}</span>
                </p>
            </div>
        </div>

        <h2 class="text-2xl font-bold text-gray-800 mb-4 pb-2 border-b border-gray-200">訂單商品</h2>
        <ul class="space-y-4">
            @foreach ($order->orderItems as $item)
                <li class="flex items-center space-x-6 bg-gray-50 p-4 rounded-md shadow-sm border border-gray-100">
                    <img src="https://placehold.co/100x80/f0f9ff/0c4a6e?text={{ urlencode(Str::limit($item->product->name, 10)) }}"
                         alt="{{ $item->product->name }}"
                         class="w-24 h-20 object-cover rounded-md">
                    <div class="flex-grow">
                        <a href="{{ route('products.show', $item->product->id) }}" class="text-xl font-medium text-gray-800 hover:text-blue-600">{{ $item->product->name }}</a>
                        <p class="text-gray-600">單價: ${{ number_format($item->price, 2) }}</p>
                        <p class="text-gray-600">數量: {{ $item->quantity }}</p>
                    </div>
                    <div class="text-right">
                        <p class="text-2xl font-bold text-gray-900">${{ number_format($item->quantity * $item->price, 2) }}</p>
                    </div>
                </li>
            @endforeach
        </ul>
    </div>

    <div class="text-center mt-6">
        <a href="{{ route('orders.index') }}" class="bg-gray-300 hover:bg-gray-400 text-gray-800 font-bold py-2 px-4 rounded-md shadow-md transition-colors duration-200">
            返回我的訂單
        </a>
    </div>
@endsection
EOF

# --- FastAPI 數據服務檔案 ---
cat > fastapi-data-service/requirements.txt << 'EOF'
# e-commerce-data-driven-mvp/fastapi-data-service/requirements.txt
# FastAPI 應用程式所需的 Python 包列表

fastapi==0.111.0 # FastAPI 框架
uvicorn==0.30.1 # ASGI 服務器，用於運行 FastAPI 應用
pandas==2.2.2 # 數據分析和操作庫
numpy==1.26.4 # 科學計算庫，提供高性能數組操作
scikit-learn==1.5.0 # 如果需要更複雜的機器學習模型，例如協同過濾
requests==2.32.3 # 用於在 FastAPI 中發送 HTTP 請求 (如果需要調用外部 API，例如 Laravel)
EOF

cat > fastapi-data-service/Dockerfile << 'EOF'
# e-commerce-data-driven-mvp/fastapi-data-service/Dockerfile
# FastAPI 應用程式的 Dockerfile

# 使用 Python 3.10 的 slim-buster 映像作為基礎映像，體積較小
FROM python:3.10-slim-buster

# 設定工作目錄
WORKDIR /app

# 將 requirements.txt 文件複製到工作目錄
COPY requirements.txt .

# 安裝所有 Python 依賴
# --no-cache-dir: 不緩存 pip 下載的包，減少映像大小
RUN pip install --no-cache-dir -r requirements.txt

# 將應用程式代碼複製到容器的工作目錄
COPY . .

# 暴露 FastAPI 應用程式將監聽的端口
EXPOSE 8000

# 啟動 FastAPI 應用程式的命令
# uvicorn app.main:app: 運行 app/main.py 文件中的 app 實例
# --host 0.0.0.0: 讓應用程式監聽所有網絡接口
# --port 8000: 應用程式監聽的端口
# --reload: 開啟熱重載 (僅在開發環境中建議使用)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

cat > fastapi-data-service/app/main.py << 'EOF'
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
EOF

echo "所有檔案內容已寫入完成！"
echo "您現在可以回到 'e-commerce-data-driven-mvp' 目錄並依照 README.md 中的指示進行下一步操作了。"

echo "=== 接下來的步驟 ==="
echo "1. 確保您在 'e-commerce-data-driven-mvp' 目錄下執行。"
echo "2. 執行 Docker Compose 構建並啟動服務："
echo "   docker-compose up --build -d"
echo "3. 等待服務啟動後，執行 Laravel 數據庫遷移和填充種子數據："
echo "   docker-compose exec php php artisan migrate --seed"
echo "4. 訪問應用程式："
echo "   Laravel 電商平台: http://localhost"
echo "   FastAPI 文檔: http://localhost:8000/docs"
echo "祝您使用愉快！"