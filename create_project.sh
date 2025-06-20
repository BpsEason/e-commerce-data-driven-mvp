#!/bin/bash

# 腳本說明：自動建立智能數據驅動電商平台 MVP 的所有檔案和目錄結構。
# 本腳本旨在創建一個包含 Laravel 後端、Python FastAPI 數據分析後端和 React 前端
# 的完整初始專案結構，並填充基礎程式碼。
# 同時包含了基礎設施的優化配置 (Nginx Gzip/Cache, Redis)。
#
# 請在一個空的資料夾中運行此腳本。
# 執行方式：
# 1. 將此內容保存為 create_project.sh (例如)
# 2. 給予執行權限：chmod +x create_project.sh
# 3. 執行腳本：./create_project.sh
#
# 安全提示：請務必檢查腳本內容，理解其作用後再執行。

echo "正在建立專案目錄結構和填充基礎程式碼..."

# 建立主目錄
mkdir -p e-commerce-data-driven-mvp
cd e-commerce-data-driven-mvp

# 建立 Laravel 後端目錄
echo "建立 Laravel 後端目錄..."
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
mkdir -p laravel-backend/tests/{Feature,Unit}

# 建立 Python FastAPI 後端目錄
echo "建立 Python FastAPI 後端目錄..."
mkdir -p python-backend/app/{core,crud,models,routers,services}
mkdir -p python-backend/data
mkdir -p python-backend/notebooks
mkdir -p python-backend/tests

# 建立 React 前端目錄
echo "建立 React 前端目錄..."
mkdir -p react-frontend/public
mkdir -p react-frontend/src/{assets,components,pages/{Auth,Dashboard,Orders,Products},services,utils}

# 建立 Nginx 配置目錄
echo "建立 Nginx 配置目錄..."
mkdir -p nginx/conf.d

# -----------------------------------------------------------------------------
# 填充 Laravel 後端檔案
echo "填充 Laravel 後端基礎檔案..."

# laravel-backend/.env.example
cat << 'EOF' > laravel-backend/.env.example
APP_NAME="Laravel"
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost:8000

LOG_CHANNEL=stack
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=ecommerce_db
DB_USERNAME=root
DB_PASSWORD=password # Change this in production!

BROADCAST_DRIVER=log
CACHE_DRIVER=redis # Changed to redis
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

MEMCACHED_HOST=127.0.0.1

REDIS_HOST=redis # Redis service name in docker-compose
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
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
PUSHER_APP_CLUSTER=mt1

VITE_APP_NAME="${APP_NAME}"
VITE_PUSHER_APP_KEY="${PUSHER_APP_KEY}"
VITE_PUSHER_APP_CLUSTER="${PUSHER_APP_CLUSTER}"
EOF

# laravel-backend/artisan
cat << 'EOF' > laravel-backend/artisan
#!/usr/bin/env php
<?php

define('LARAVEL_START', microtime(true));

// Determine if the application is in maintenance mode...
if (file_exists($maintenance = __DIR__.'/storage/framework/maintenance.php')) {
    require $maintenance;
}

// Register the Composer autoloader...
require __DIR__.'/vendor/autoload.php';

// Bootstrap Laravel and handle the request...
(require_once __DIR__.'/bootstrap/app.php')
    ->make(Illuminate\Contracts\Http\Kernel::class)
    ->handle(
        Illuminate\Http\Request::capture()
    );
EOF
chmod +x laravel-backend/artisan # Make executable

# laravel-backend/composer.json
cat << 'EOF' > laravel-backend/composer.json
{
    "name": "laravel/laravel",
    "type": "project",
    "description": "A Laravel e-commerce backend.",
    "keywords": ["framework", "laravel"],
    "license": "MIT",
    "require": {
        "php": "^8.2",
        "guzzlehttp/guzzle": "^7.2",
        "laravel/framework": "^11.0",
        "laravel/sanctum": "^4.0",
        "laravel/tinker": "^2.8",
        "predis/predis": "^2.2" # Added predis for Redis support
    },
    "require-dev": {
        "fakerphp/faker": "^1.9.1",
        "laravel/pint": "^1.0",
        "laravel/sail": "^1.18",
        "mockery/mockery": "^1.4.4",
        "nunomaduro/collision": "^8.0",
        "phpunit/phpunit": "^11.0",
        "spatie/laravel-ignition": "^2.0"
    },
    "autoload": {
        "psr-4": {
            "App\\": "app/",
            "Database\\Factories\\": "database/factories/",
            "Database\\Seeders\\": "database/seeders/"
        }
    },
    "autoload-dev": {
        "psr-4": {
            "Tests\\": "tests/"
        }
    },
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
    },
    "extra": {
        "laravel": {
            "dont-discover": []
        }
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
    "minimum-stability": "stable",
    "prefer-stable": true
}
EOF

# laravel-backend/package.json (Frontend assets for Laravel, if any)
cat << 'EOF' > laravel-backend/package.json
{
    "private": true,
    "type": "module",
    "scripts": {
        "dev": "vite",
        "build": "vite build"
    },
    "devDependencies": {
        "axios": "^1.6.4",
        "laravel-vite-plugin": "^1.0",
        "vite": "^5.0"
    }
}
EOF

# laravel-backend/phpunit.xml (Basic phpunit config)
cat << 'EOF' > laravel-backend/phpunit.xml
<?xml version="1.0" encoding="UTF-8"?>
<phpunit xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:noNamespaceSchemaLocation="./vendor/phpunit/phpunit/phpunit.xsd"
         bootstrap="vendor/autoload.php"
         colors="true"
>
    <testsuites>
        <testsuite name="Unit">
            <directory suffix="Test.php">./tests/Unit</directory>
        </testsuite>
        <testsuite name="Feature">
            <directory suffix="Test.php">./tests/Feature</directory>
        </testsuite>
    </testsuites>
    <php>
        <env name="APP_ENV" value="testing"/>
        <env name="BCRYPT_ROUNDS" value="4"/>
        <env name="CACHE_DRIVER" value="array"/>
        <env name="DB_CONNECTION" value="sqlite"/>
        <env name="DB_DATABASE" value=":memory:"/>
        <env name="MAIL_MAILER" value="array"/>
        <env name="QUEUE_CONNECTION" value="sync"/>
        <env name="SESSION_DRIVER" value="array"/>
        <env name="TELESCOPE_ENABLED" value="false"/>
    </php>
</phpunit>
EOF

# laravel-backend/README.md
cat << 'EOF' > laravel-backend/README.md
# Laravel Backend for E-commerce Platform

This is the Laravel backend for the smart data-driven e-commerce platform MVP. It handles user authentication, product management, order processing, and API endpoints for the frontend.

## Installation

1.  **Clone the repository:**
    ```bash
    git clone <your-repo-url> e-commerce-data-driven-mvp
    cd e-commerce-data-driven-mvp/laravel-backend
    ```
2.  **Install Composer dependencies:**
    ```bash
    composer install
    ```
3.  **Copy .env file:**
    ```bash
    cp .env.example .env
    ```
    (Remember to configure your database connection in `.env`)
4.  **Generate application key:**
    ```bash
    php artisan key:generate
    ```
5.  **Run migrations:**
    ```bash
    php artisan migrate
    ```
6.  **Start the development server:**
    ```bash
    php artisan serve
    ```

## API Endpoints

Refer to `routes/api.php` for defined API endpoints.

## Database

Uses MySQL. See `database/migrations` for schema.
EOF

# laravel-backend/routes/api.php
cat << 'EOF' > laravel-backend/routes/api.php
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\AuthController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // Product routes
    Route::apiResource('products', ProductController::class);

    // Order routes
    Route::apiResource('orders', OrderController::class);

    // Placeholder for data analysis integration (e.g., calling Python backend)
    // This route would typically be a proxy from React to Python via Laravel, or direct from React
    Route::get('/data-insights', function () {
        // This route could call the Python backend's data analysis endpoint
        // using GuzzleHttp or similar.
        return response()->json(['message' => 'Fetching data insights...']);
    });
});
EOF

# laravel-backend/routes/web.php
cat << 'EOF' > laravel-backend/routes/web.php
<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

// Example dashboard route (can be protected by auth middleware)
Route::get('/dashboard', function () {
    return view('dashboard.index');
})->middleware(['auth'])->name('dashboard');

// Example product listing page (frontend will consume API)
Route::get('/products', function () {
    return view('products.index');
});

// Example order listing page (frontend will consume API)
Route::get('/orders', function () {
    return view('orders.index');
});

// Authentication routes (Laravel Breeze/Jetstream typically handles these,
// but for a minimal setup, you might define basic ones or use Sanctum for API only)
// For API-only authentication, these web routes might not be strictly needed,
// but included for completeness of a typical Laravel setup.
require __DIR__.'/auth.php';
EOF

# laravel-backend/routes/auth.php (Basic authentication routes placeholder)
cat << 'EOF' > laravel-backend/routes/auth.php
<?php

use App\Http\Controllers\Auth\AuthenticatedSessionController;
use App\Http\Controllers\Auth\RegisteredUserController;
use Illuminate\Support\Facades\Route;

// For web-based authentication (if needed, otherwise API auth via Sanctum)
Route::get('/register', [RegisteredUserController::class, 'create'])
    ->middleware('guest')
    ->name('register');

Route::post('/register', [RegisteredUserController::class, 'store'])
    ->middleware('guest');

Route::get('/login', [AuthenticatedSessionController::class, 'create'])
    ->middleware('guest')
    ->name('login');

Route::post('/login', [AuthenticatedSessionController::class, 'store'])
    ->middleware('guest');

Route::post('/logout', [AuthenticatedSessionController::class, 'destroy'])
    ->middleware('auth')
    ->name('logout');
EOF

# laravel-backend/app/Models/User.php
cat << 'EOF' > laravel-backend/app/Models/User.php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];

    public function orders()
    {
        return $this->hasMany(Order::class);
    }
}
EOF

# laravel-backend/app/Models/Product.php
cat << 'EOF' > laravel-backend/app/Models/Product.php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'price',
        'stock',
        'category',
        'image_url',
    ];

    protected $casts = [
        'price' => 'float',
        'stock' => 'integer',
    ];

    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }
}
EOF

# laravel-backend/app/Models/Order.php
cat << 'EOF' > laravel-backend/app/Models/Order.php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'total_amount',
        'status',
        'shipping_address',
    ];

    protected $casts = [
        'total_amount' => 'float',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }
}
EOF

# laravel-backend/app/Models/OrderItem.php (New Model for order items)
cat << 'EOF' > laravel-backend/app/Models/OrderItem.php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_id',
        'product_id',
        'quantity',
        'price', # Price at the time of order
    ];

    protected $casts = [
        'quantity' => 'integer',
        'price' => 'float',
    ];

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}
EOF

# laravel-backend/database/migrations/2014_10_12_000000_create_users_table.php
cat << 'EOF' > laravel-backend/database/migrations/2014_10_12_000000_create_users_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
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
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
EOF

# laravel-backend/database/migrations/2023_01_01_000000_create_products_table.php
cat << 'EOF' > laravel-backend/database/migrations/2023_01_01_000000_create_products_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description')->nullable();
            $table->decimal('price', 8, 2);
            $table->integer('stock')->default(0);
            $table->string('category')->nullable();
            $table->string('image_url')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};
EOF

# laravel-backend/database/migrations/2023_01_02_000000_create_orders_table.php
cat << 'EOF' > laravel-backend/database/migrations/2023_01_02_000000_create_orders_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->decimal('total_amount', 10, 2);
            $table->string('status')->default('pending'); # e.g., pending, processing, shipped, completed, cancelled
            $table->text('shipping_address')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
EOF

# laravel-backend/database/migrations/2023_01_03_000000_create_order_items_table.php
cat << 'EOF' > laravel-backend/database/migrations/2023_01_03_000000_create_order_items_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('order_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained()->onDelete('cascade');
            $table->foreignId('product_id')->constrained()->onDelete('cascade');
            $table->integer('quantity');
            $table->decimal('price', 8, 2); # Price at the time of order
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('order_items');
    }
};
EOF

# Laravel Controllers (minimal content, just the class structure)

# laravel-backend/app/Http/Controllers/Api/AuthController.php
cat << 'EOF' > laravel-backend/app/Http/Controllers/Api/AuthController.php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json(['message' => 'Registration successful', 'user' => $user, 'access_token' => $token, 'token_type' => 'Bearer'], 201);
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|string|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json(['message' => 'Login successful', 'user' => $user, 'access_token' => $token, 'token_type' => 'Bearer']);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Successfully logged out']);
    }
}
EOF


# laravel-backend/app/Http/Controllers/Api/ProductController.php
cat << 'EOF' > laravel-backend/app/Http/Controllers/Api/ProductController.php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ProductController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $products = Product::all();
        return response()->json($products);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'stock' => 'required|integer|min:0',
            'category' => 'nullable|string|max:255',
            'image_url' => 'nullable|url|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $product = Product::create($request->all());
        return response()->json($product, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Product $product)
    {
        return response()->json($product);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Product $product)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'string|max:255',
            'description' => 'nullable|string',
            'price' => 'numeric|min:0',
            'stock' => 'integer|min:0',
            'category' => 'nullable|string|max:255',
            'image_url' => 'nullable|url|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $product->update($request->all());
        return response()->json($product);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Product $product)
    {
        $product->delete();
        return response()->json(null, 204);
    }
}
EOF

# laravel-backend/app/Http/Controllers/Api/OrderController.php
cat << 'EOF' > laravel-backend/app/Http/Controllers/Api/OrderController.php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class OrderController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $orders = $request->user()->orders()->with('items.product')->get();
        return response()->json($orders);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|exists:products,id',
            'items.*.quantity' => 'required|integer|min:1',
            'shipping_address' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        DB::beginTransaction();
        try {
            $totalAmount = 0;
            $orderItemsData = [];

            foreach ($request->items as $item) {
                $product = Product::find($item['product_id']);

                if (!$product || $product->stock < $item['quantity']) {
                    DB::rollBack();
                    return response()->json(['message' => 'Product out of stock or not found: ' . ($product ? $product->name : 'N/A')], 400);
                }

                $itemPrice = $product->price * $item['quantity'];
                $totalAmount += $itemPrice;

                $orderItemsData[] = [
                    'product_id' => $product->id,
                    'quantity' => $item['quantity'],
                    'price' => $product->price, # Store price at the time of order
                ];

                # Deduct stock
                $product->stock -= $item['quantity'];
                $product->save();
            }

            $order = $request->user()->orders()->create([
                'total_amount' => $totalAmount,
                'status' => 'pending',
                'shipping_address' => $request->shipping_address,
            ]);

            foreach ($orderItemsData as $itemData) {
                $order->items()->create($itemData);
            }

            DB::commit();
            return response()->json($order->load('items.product'), 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Order creation failed', 'error' => $e->getMessage()], 500);
        }
    }

    /**
     * Display the specified resource.
     */
    public function show(Order $order)
    {
        # Ensure user can only view their own orders
        if ($order->user_id !== auth()->id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }
        return response()->json($order->load('items.product'));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Order $order)
    {
        # Only allow status updates for specific roles, or if it's the user cancelling
        # For MVP, simple status update:
        if ($order->user_id !== auth()->id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $validator = Validator::make($request->all(), [
            'status' => 'required|string|in:pending,processing,shipped,completed,cancelled',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $order->update($request->only('status'));
        return response()->json($order);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Order $order)
    {
        if ($order->user_id !== auth()->id()) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        # Revert stock if order is cancelled and not yet shipped (logic can be more complex)
        if ($order->status == 'pending' || $order->status == 'processing') {
            foreach ($order->items as $item) {
                $product = $item->product;
                if ($product) {
                    $product->stock += $item->quantity;
                    $product->save();
                }
            }
        }
        $order->delete();
        return response()->json(null, 204);
    }
}
EOF

# laravel-backend/app/Http/Controllers/Api/UserController.php (Will likely be for admin purposes or user profile updates)
cat << 'EOF' > laravel-backend/app/Http/Controllers/Api/UserController.php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class UserController extends Controller
{
    /**
     * Display a listing of the resource (Admin only usually).
     */
    public function index()
    {
        # Implement authorization check here for admin users
        # if (!auth()->user()->isAdmin()) { ... }
        $users = User::all();
        return response()->json($users);
    }

    /**
     * Display the specified resource.
     */
    public function show(User $user)
    {
        # Allow user to view their own profile, or admin to view any profile
        # if (auth()->id() !== $user->id && !auth()->user()->isAdmin()) { ... }
        return response()->json($user);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, User $user)
    {
        # Allow user to update their own profile, or admin to update any profile
        # if (auth()->id() !== $user->id && !auth()->user()->isAdmin()) { ... }

        $validator = Validator::make($request->all(), [
            'name' => 'string|max:255',
            'email' => 'string|email|max:255|unique:users,email,' . $user->id,
            'password' => 'nullable|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $data = $request->only('name', 'email');
        if ($request->filled('password')) {
            $data['password'] = bcrypt($request->password);
        }

        $user->update($data);
        return response()->json($user);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(User $user)
    {
        # Admin only
        # if (!auth()->user()->isAdmin()) { ... }
        $user->delete();
        return response()->json(null, 204);
    }
}
EOF

# laravel-backend/Dockerfile (Added for completeness and Redis extension)
cat << 'EOF' > laravel-backend/Dockerfile
FROM php:8.2-fpm-alpine

WORKDIR /var/www/html

# Install system dependencies and PHP extensions
RUN apk add --no-cache \
    nginx \
    mysql-client \
    git \
    curl \
    libzip-dev \
    libpng-dev \
    jpeg-dev \
    oniguruma-dev \
    libxml2-dev \
    # Added redis-dev for Redis extension
    redis-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd opcache zip \
    # Install Redis PHP extension
    && pecl install -o -f redis \
    && rm -rf /tmp/pear \
    && docker-php-ext-enable redis

# Install Composer
COPY --from=composer/composer:latest-bin /composer /usr/local/bin/composer

# Copy existing application dependencies (composer.json and composer.lock)
# It's good practice to copy these first to leverage Docker cache
COPY composer.json composer.lock ./

# Install Composer dependencies
# Use --no-dev and --optimize-autoloader for production builds
# For development, you might remove --no-dev
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Copy the rest of the application
COPY . .

# Run Laravel specific commands (e.g., storage link, permissions)
RUN php artisan storage:link && \
    chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache && \
    chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Command to run PHP-FPM
CMD ["php-fpm"]
EOF


# -----------------------------------------------------------------------------
# 填充 Python FastAPI 後端檔案
echo "填充 Python FastAPI 後端基礎檔案..."

# python-backend/.env.example
cat << 'EOF' > python-backend/.env.example
DATABASE_URL=sqlite:///./data/sql_app.db
SECRET_KEY=YOUR_SUPER_SECRET_KEY_FASTAPI # IMPORTANT: Change this!
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
EOF

# python-backend/Dockerfile
cat << 'EOF' > python-backend/Dockerfile
# Use a base image with Python
FROM python:3.9-slim-buster

# Set the working directory
WORKDIR /app

# Copy requirements file and install dependencies
COPY ./requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy the rest of the application code
COPY ./app /app/app
COPY ./data /app/data

# Expose the port FastAPI runs on
EXPOSE 8001

# Command to run the application using uvicorn
# Make sure to run with --host 0.0.0.0 to be accessible from outside the container
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8001"]
EOF

# python-backend/requirements.txt
cat << 'EOF' > python-backend/requirements.txt
fastapi[all]
uvicorn
pandas
scikit-learn
SQLAlchemy
databases[sqlite]
python-dotenv
EOF

# python-backend/start.sh (Simple start script for development)
cat << 'EOF' > python-backend/start.sh
#!/bin/bash
# Start the FastAPI application
uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload
EOF
chmod +x python-backend/start.sh # Make executable

# python-backend/app/main.py
cat << 'EOF' > python-backend/app/main.py
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
EOF

# python-backend/app/models/models.py (Pydantic models)
cat << 'EOF' > python-backend/app/models/models.py
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
EOF

# python-backend/app/routers/auth.py (Basic auth placeholder, main.py handles it for MVP)
cat << 'EOF' > python-backend/app/routers/auth.py
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from datetime import timedelta
# from ..core.security import create_access_token, authenticate_user
# from ..core.config import ACCESS_TOKEN_EXPIRE_MINUTES
# from ..models.models import Token # assuming Token model

router = APIRouter()

# @router.post("/token", response_model=Token)
# async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends()):
#     user = authenticate_user(form_data.username, form_data.password)
#     if not user:
#         raise HTTPException(
#             status_code=status.HTTP_401_UNAUTHORIZED,
#             detail="Incorrect username or password",
#             headers={"WWW-Authenticate": "Bearer"},
#         )
#     access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
#     access_token = create_access_token(
#         data={"sub": user.username}, expires_delta=access_token_expires
#     )
#     return {"access_token": access_token, "token_type": "bearer"}

# For MVP, auth handled in main.py, so this file is mostly a placeholder
EOF

# python-backend/app/routers/data_analysis.py (Moved into main.py for MVP simplicity)
cat << 'EOF' > python-backend/app/routers/data_analysis.py
from fastapi import APIRouter, Depends, HTTPException
from typing import List
# from ..models.models import RecommendedProduct, SalesTrend
# from ..services.data_analysis_service import (
#     get_product_recommendations_logic,
#     get_user_recommendations_logic,
#     get_sales_trends_logic
# )

router = APIRouter(
    prefix="/data-analysis",
    tags=["Data Analysis"],
    # dependencies=[Depends(get_current_active_user)], # Example for security
)

# @router.get("/recommendations/product/{product_id}", response_model=List[RecommendedProduct])
# async def product_recommendations(product_id: int):
#     # Call service layer logic
#     pass

# @router.get("/sales/trends", response_model=List[SalesTrend])
# async def sales_trends():
#     # Call service layer logic
#     pass

# For MVP, data analysis endpoints are directly in main.py.
# This file serves as a placeholder for larger projects where routers are separated.
EOF

# python-backend/app/routers/products.py (Moved into main.py for MVP simplicity)
cat << 'EOF' > python-backend/app/routers/products.py
from fastapi import APIRouter, HTTPException
from typing import List
# from ..models.models import Product
# from ..crud import products_crud # Assuming a CRUD module

router = APIRouter(
    prefix="/products",
    tags=["Products"],
)

# @router.get("/", response_model=List[Product])
# async def read_products():
#     # Fetch products from data source (e.g., database)
#     pass

# @router.get("/{product_id}", response_model=Product)
# async def read_product(product_id: int):
#     # Fetch single product
#     pass

# For MVP, product endpoints are directly in main.py.
# This file serves as a placeholder for larger projects.
EOF

# python-backend/app/routers/orders.py (Moved into main.py for MVP simplicity)
cat << 'EOF' > python-backend/app/routers/orders.py
from fastapi import APIRouter, HTTPException
from typing import List
# from ..models.models import Order
# from ..crud import orders_crud # Assuming a CRUD module

router = APIRouter(
    prefix="/orders",
    tags=["Orders"],
)

# @router.get("/", response_model=List[Order])
# async def read_orders():
#     # Fetch orders from data source
#     pass

# @router.post("/", response_model=Order)
# async def create_order(order: Order):
#     # Create a new order
#     pass

# For MVP, order endpoints are directly in main.py.
# This file serves as a placeholder for larger projects.
EOF

# python-backend/data/products.csv (Mock data)
cat << 'EOF' > python-backend/data/products.csv
id,name,description,price,category,stock
1,Laptop Pro,High performance laptop with 16GB RAM,1200.00,Electronics,50
2,Mechanical Keyboard,Gaming keyboard with RGB backlighting,80.00,Electronics,100
3,Wireless Mouse,Ergonomic mouse with long battery life,30.00,Electronics,150
4,Designer T-Shirt,100% cotton casual wear,25.00,Apparel,200
5,Running Shoes,Comfortable shoes for daily runs,100.00,Apparel,75
6,Smartwatch X,Latest generation smartwatch with health tracking,250.00,Electronics,40
7,Bluetooth Speaker,Portable speaker with rich bass,60.00,Electronics,120
8,Denim Jeans,Classic fit denim jeans,75.00,Apparel,90
9,Yoga Mat,Non-slip yoga mat for fitness,40.00,Sports,80
10,Blender Max,High power blender for smoothies,150.00,Home Appliances,30
EOF

# python-backend/data/orders.csv (Mock data)
cat << 'EOF' > python-backend/data/orders.csv
order_id,user_id,product_id,quantity,total_amount,created_at
101,1,1,1,1200.00,2024-05-10T10:00:00Z
102,1,2,1,80.00,2024-05-10T11:00:00Z
103,2,4,2,50.00,2024-05-11T12:00:00Z
104,1,3,1,30.00,2024-05-12T09:00:00Z
105,3,5,1,100.00,2024-05-12T14:00:00Z
106,2,1,1,1200.00,2024-05-13T10:00:00Z
107,1,6,1,250.00,2024-05-13T15:00:00Z
108,3,7,2,120.00,2024-05-14T11:00:00Z
109,1,8,1,75.00,2024-05-14T16:00:00Z
110,2,9,1,40.00,2024-05-15T09:00:00Z
EOF

# python-backend/data/interactions.csv (Mock data for interactions)
cat << 'EOF' > python-backend/data/interactions.csv
user_id,product_id,interaction_type,timestamp
1,1,view,2024-05-09T09:00:00Z
1,2,add_to_cart,2024-05-09T09:15:00Z
1,1,purchase,2024-05-10T10:00:00Z
2,4,view,2024-05-10T11:30:00Z
2,4,add_to_cart,2024-05-10T11:45:00Z
2,4,purchase,2024-05-11T12:00:00Z
1,3,view,2024-05-11T10:00:00Z
3,5,view,2024-05-11T13:00:00Z
3,5,purchase,2024-05-12T14:00:00Z
1,6,view,2024-05-12T15:00:00Z
1,6,purchase,2024-05-13T15:00:00Z
2,1,purchase,2024-05-13T10:00:00Z
3,7,view,2024-05-14T10:30:00Z
3,7,add_to_cart,2024-05-14T10:45:00Z
3,7,purchase,2024-05-14T11:00:00Z
EOF


# -----------------------------------------------------------------------------
# 填充 React 前端檔案
echo "填充 React 前端基礎檔案..."

# react-frontend/.env.development
cat << 'EOF' > react-frontend/.env.development
VITE_API_BASE_URL_LARAVEL=http://localhost:8000/api
VITE_API_BASE_URL_PYTHON=http://localhost:8001
EOF

# react-frontend/.env.production
cat << 'EOF' > react-frontend/.env.production
VITE_API_BASE_URL_LARAVEL=/api-laravel # Proxy path via Nginx
VITE_API_BASE_URL_PYTHON=/api-python   # Proxy path via Nginx
EOF

# react-frontend/package.json
cat << 'EOF' > react-frontend/package.json
{
    "name": "react-frontend",
    "version": "0.1.0",
    "private": true,
    "dependencies": {
        "@testing-library/jest-dom": "^5.17.0",
        "@testing-library/react": "^13.4.0",
        "@testing-library/user-event": "^13.5.0",
        "axios": "^1.6.8",
        "react": "^18.2.0",
        "react-dom": "^18.2.0",
        "react-router-dom": "^6.23.0",
        "react-scripts": "5.0.1",
        "web-vitals": "^2.1.4"
    },
    "scripts": {
        "start": "react-scripts start",
        "build": "react-scripts build",
        "test": "react-scripts test",
        "eject": "react-scripts eject"
    },
    "eslintConfig": {
        "extends": [
            "react-app",
            "react-app/jest"
        ]
    },
    "browserslist": {
        "production": [
            ">0.2%",
            "not dead",
            "not op_mini all"
        ],
        "development": [
            "last 1 chrome version",
            "last 1 firefox version",
            "last 1 safari version"
        ]
    }
}
EOF

# react-frontend/README.md
cat << 'EOF' > react-frontend/README.md
# React Frontend for E-commerce Platform

This is the React frontend application for the smart data-driven e-commerce platform MVP. It consumes APIs from both the Laravel backend (for core e-commerce functionalities) and the Python FastAPI backend (for data analysis and recommendations).

## Installation

1.  **Navigate to the frontend directory:**
    ```bash
    cd react-frontend
    ```
2.  **Install Node.js dependencies:**
    ```bash
    npm install
    ```
3.  **Create .env files:**
    Copy `.env.development` to `.env.local` for local development.
    ```bash
    cp .env.development .env.local
    ```
    Adjust API URLs if your backends are running on different hosts/ports.

## Running the Application

```bash
npm start
```
This will start the development server and open the application in your browser.

## Project Structure

-   `src/components`: Reusable UI components.
-   `src/pages`: Main application pages.
-   `src/services`: Functions for API interactions.
-   `src/assets`: Static assets like images and global CSS.
-   `src/utils`: Utility functions.
EOF

# react-frontend/src/App.js
cat << 'EOF' > react-frontend/src/App.js
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom';
import Header from './components/Header';
import Login from './pages/Auth/Login';
import Register from './pages/Auth/Register';
import Dashboard from './pages/Dashboard/Dashboard';
import ProductList from './pages/Products/ProductList';
import ProductDetail from './pages/Products/ProductDetail';
import OrderList from './pages/Orders/OrderList';
import './App.css'; // You might want to create this file

function App() {
  return (
    <Router>
      <div className="App">
        <Header />
        <nav>
          <ul>
            <li><Link to="/">Home</Link></li>
            <li><Link to="/products">Products</Link></li>
            <li><Link to="/orders">Orders</Link></li>
            <li><Link to="/dashboard">Dashboard</Link></li>
            <li><Link to="/login">Login</Link></li>
            <li><Link to="/register">Register</Link></li>
          </ul>
        </nav>

        <div className="main-content">
          <Routes>
            <Route path="/" element={<h1>Welcome to E-commerce MVP!</h1>} />
            <Route path="/login" element={<Login />} />
            <Route path="/register" element={<Register />} />
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="/products" element={<ProductList />} />
            <Route path="/products/:id" element={<ProductDetail />} />
            <Route path="/orders" element={<OrderList />} />
            {/* Add other routes as needed */}
          </Routes>
        </div>
      </div>
    </Router>
  );
}

export default App;
EOF

# react-frontend/src/index.js
cat << 'EOF' > react-frontend/src/index.js
import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css'; // Optional: for global styles
import App from './App';
import reportWebVitals from './reportWebVitals';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
EOF

# react-frontend/src/components/Header.js
cat << 'EOF' > react-frontend/src/components/Header.js
import React from 'react';
import { Link } from 'react-router-dom';

function Header() {
  return (
    <header className="app-header">
      <Link to="/">
        <h1>Data-Driven E-commerce MVP</h1>
      </Link>
      {/* Add navigation, user info, cart icon etc. */}
    </header>
  );
}

export default Header;
EOF

# react-frontend/src/components/Sidebar.js (Placeholder)
cat << 'EOF' > react-frontend/src/components/Sidebar.js
import React from 'react';
import { Link } from 'react-router-dom';

function Sidebar() {
  return (
    <aside className="app-sidebar">
      <nav>
        <ul>
          <li><Link to="/dashboard">Dashboard Overview</Link></li>
          <li><Link to="/products">Manage Products</Link></li>
          <li><Link to="/orders">Manage Orders</Link></li>
          {/* Add more links for admin/user functionality */}
        </ul>
      </nav>
    </aside>
  );
}

export default Sidebar;
EOF

# react-frontend/src/components/ProductCard.js
cat << 'EOF' > react-frontend/src/components/ProductCard.js
import React from 'react';
import { Link } from 'react-router-dom';

function ProductCard({ product }) {
  if (!product) return null;

  return (
    <div className="product-card">
      <img src={product.image_url || 'https://via.placeholder.com/150'} alt={product.name} />
      <h3><Link to={`/products/${product.id}`}>{product.name}</Link></h3>
      <p>{product.description}</p>
      <p>Price: ${product.price.toFixed(2)}</p>
      <p>Stock: {product.stock}</p>
      {/* Add "Add to Cart" button */}
    </div>
  );
}

export default ProductCard;
EOF

# react-frontend/src/pages/Auth/Login.js
cat << 'EOF' > react-frontend/src/pages/Auth/Login.js
import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { loginUser } from '../../services/authService'; # Assuming you create this service

function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    try {
      const response = await loginUser({ email, password });
      # Store token (e.g., in localStorage) and redirect
      localStorage.setItem('authToken', response.access_token);
      localStorage.setItem('user', JSON.stringify(response.user));
      navigate('/dashboard'); # Redirect to dashboard on successful login
    } catch (err) {
      console.error('Login error:', err);
      setError(err.response?.data?.message || 'Login failed. Please check your credentials.');
    }
  };

  return (
    <div className="auth-container">
      <h2>Login</h2>
      <form onSubmit={handleSubmit}>
        {error && <p className="error-message">{error}</p>}
        <div>
          <label htmlFor="email">Email:</label>
          <input
            type="email"
            id="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />
        </div>
        <div>
          <label htmlFor="password">Password:</label>
          <input
            type="password"
            id="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
        </div>
        <button type="submit">Login</button>
      </form>
      <p>Don't have an account? <Link to="/register">Register here</Link></p>
    </div>
  );
}

export default Login;
EOF

# react-frontend/src/pages/Auth/Register.js
cat << 'EOF' > react-frontend/src/pages/Auth/Register.js
import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { registerUser } from '../../services/authService'; # Assuming you create this service

function Register() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [passwordConfirmation, setPasswordConfirmation] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    if (password !== passwordConfirmation) {
      setError('Passwords do not match.');
      return;
    }
    try {
      const response = await registerUser({ name, email, password, password_confirmation: passwordConfirmation });
      # Store token and redirect
      localStorage.setItem('authToken', response.access_token);
      localStorage.setItem('user', JSON.stringify(response.user));
      navigate('/dashboard'); # Redirect on successful registration
    } catch (err) {
      console.error('Registration error:', err);
      setError(err.response?.data?.message || 'Registration failed. Please try again.');
    }
  };

  return (
    <div className="auth-container">
      <h2>Register</h2>
      <form onSubmit={handleSubmit}>
        {error && <p className="error-message">{error}</p>}
        <div>
          <label htmlFor="name">Name:</label>
          <input
            type="text"
            id="name"
            value={name}
            onChange={(e) => setName(e.target.value)}
            required
          />
        </div>
        <div>
          <label htmlFor="email">Email:</label>
          <input
            type="email"
            id="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />
        </div>
        <div>
          <label htmlFor="password">Password:</label>
          <input
            type="password"
            id="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
        </div>
        <div>
          <label htmlFor="password_confirmation">Confirm Password:</label>
          <input
            type="password"
            id="password_confirmation"
            value={passwordConfirmation}
            onChange={(e) => setPasswordConfirmation(e.target.value)}
            required
          />
        </div>
        <button type="submit">Register</button>
      </form>
      <p>Already have an account? <Link to="/login">Login here</Link></p>
    </div>
  );
}

export default Register;
EOF

# react-frontend/src/pages/Dashboard/Dashboard.js
cat << 'EOF' > react-frontend/src/pages/Dashboard/Dashboard.js
import React, { useState, useEffect } from 'react';
import { getSalesTrends, getUserRecommendations } from '../../services/dataAnalysisService'; # Create this service
import Sidebar from '../../components/Sidebar';

function Dashboard() {
  const [salesTrends, setSalesTrends] = useState([]);
  const [userRecommendations, setUserRecommendations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const currentUser = JSON.parse(localStorage.getItem('user')); # Get current user info

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      setError('');
      try {
        # Fetch sales trends from Python backend
        const trends = await getSalesTrends();
        setSalesTrends(trends);

        # Fetch user recommendations from Python backend (if user is logged in)
        if (currentUser && currentUser.id) {
          const recommendations = await getUserRecommendations(currentUser.id);
          setUserRecommendations(recommendations);
        }

      } catch (err) {
        console.error('Dashboard data fetch error:', err);
        setError('Failed to load dashboard data. Please try again.');
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, [currentUser]);

  if (loading) return <div>Loading dashboard...</div>;
  if (error) return <div className="error-message">{error}</div>;

  return (
    <div className="dashboard-container">
      <Sidebar />
      <div className="dashboard-content">
        <h2>Welcome to Your Dashboard, {currentUser ? currentUser.name : 'Guest'}!</h2>

        <section className="sales-trends">
          <h3>Sales Trends (from Python Backend)</h3>
          {salesTrends.length > 0 ? (
            <ul>
              {salesTrends.map((trend, index) => (
                <li key={index}>Date: {trend.date}, Sales: ${trend.daily_sales.toFixed(2)}</li>
              ))}
            </ul>
          ) : (
            <p>No sales trend data available.</p>
          )}
        </section>

        <section className="user-recommendations">
          <h3>Recommended Products for You (from Python Backend)</h3>
          {userRecommendations.length > 0 ? (
            <div className="product-recommendations-grid">
              {userRecommendations.map((product) => (
                <div key={product.id} className="recommendation-card">
                  <h4>{product.name}</h4>
                  <p>{product.description}</p>
                  <p>Price: ${product.price.toFixed(2)}</p>
                  <p>Relevance Score: {product.score.toFixed(2)}</p>
                </div>
              ))}
            </div>
          ) : (
            <p>No personalized recommendations available at the moment. Explore more products!</p>
          )}
        </section>

        {/* Add more dashboard widgets here (e.g., recent orders, popular products from Laravel) */}
      </div>
    </div>
  );
}

export default Dashboard;
EOF

# react-frontend/src/pages/Orders/OrderList.js
cat << 'EOF' > react-frontend/src/pages/Orders/OrderList.js
import React, { useState, useEffect } from 'react';
import { getOrders } from '../../services/orderService'; # Create this service

function OrderList() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchOrders = async () => {
      setLoading(true);
      setError('');
      try {
        const data = await getOrders();
        setOrders(data);
      } catch (err) {
        console.error('Error fetching orders:', err);
        setError('Failed to load orders. Please log in or try again.');
      } finally {
        setLoading(false);
      }
    };
    fetchOrders();
  }, []);

  if (loading) return <div>Loading orders...</div>;
  if (error) return <div className="error-message">{error}</div>;

  return (
    <div className="orders-container">
      <h2>Your Orders</h2>
      {orders.length === 0 ? (
        <p>You haven't placed any orders yet.</p>
      ) : (
        <div className="order-list">
          {orders.map((order) => (
            <div key={order.id} className="order-card">
              <h3>Order #{order.id}</h3>
              <p>Total: ${order.total_amount.toFixed(2)}</p>
              <p>Status: {order.status}</p>
              <p>Ordered On: {new Date(order.created_at).toLocaleString()}</p>
              <h4>Items:</h4>
              <ul>
                {order.items && order.items.map(item => (
                  <li key={item.id}>
                    {item.product ? item.product.name : 'Unknown Product'} (x{item.quantity}) - ${item.price.toFixed(2)} each
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default OrderList;
EOF

# react-frontend/src/pages/Products/ProductDetail.js
cat << 'EOF' > react-frontend/src/pages/Products/ProductDetail.js
import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom'; # Added Link
import { getProductById } from '../../services/productService'; # Create this service
import { getProductRecommendations } from '../../services/dataAnalysisService';

function ProductDetail() {
  const { id } = useParams();
  const [product, setProduct] = useState(null);
  const [recommendations, setRecommendations] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchProductAndRecommendations = async () => {
      setLoading(true);
      setError('');
      try {
        const productData = await getProductById(id);
        setProduct(productData);

        # Fetch product recommendations from Python backend
        const recs = await getProductRecommendations(id);
        setRecommendations(recs);

      } catch (err) {
        console.error('Error fetching product or recommendations:', err);
        setError('Failed to load product details or recommendations.');
      } finally {
        setLoading(false);
      }
    };
    fetchProductAndRecommendations();
  }, [id]);

  if (loading) return <div>Loading product details...</div>;
  if (error) return <div className="error-message">{error}</div>;
  if (!product) return <div>Product not found.</div>;

  return (
    <div className="product-detail-container">
      <div className="product-info">
        <img src={product.image_url || 'https://via.placeholder.com/300'} alt={product.name} />
        <h2>{product.name}</h2>
        <p>{product.description}</p>
        <p><strong>Price: ${product.price.toFixed(2)}</strong></p>
        <p>Stock: {product.stock}</p>
        <p>Category: {product.category}</p>
        {/* Add "Add to Cart" button or quantity selector */}
      </div>

      <section className="related-products">
        <h3>Related Products (from Python Backend)</h3>
        {recommendations.length > 0 ? (
          <div className="product-recommendations-grid">
            {recommendations.map((rec) => (
              <div key={rec.id} className="recommendation-card">
                <h4>{rec.name}</h4>
                <p>Price: ${rec.price.toFixed(2)}</p>
                <p>Similarity: {rec.score.toFixed(2)}</p>
                <Link to={`/products/${rec.id}`}>View Details</Link>
              </div>
            ))}
          </div>
        ) : (
          <p>No related products found.</p>
        )}
      </section>
    </div>
  );
}

export default ProductDetail;
EOF

# react-frontend/src/pages/Products/ProductList.js
cat << 'EOF' > react-frontend/src/pages/Products/ProductList.js
import React, { useState, useEffect } from 'react';
import ProductCard from '../../components/ProductCard';
import { getProducts } from '../../services/productService'; # Create this service

function ProductList() {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchProducts = async () => {
      setLoading(true);
      setError('');
      try {
        const data = await getProducts();
        setProducts(data);
      } catch (err) {
        console.error('Error fetching products:', err);
        setError('Failed to load products. Please try again later.');
      } finally {
        setLoading(false);
      }
    };
    fetchProducts();
  }, []);

  if (loading) return <div>Loading products...</div>;
  if (error) return <div className="error-message">{error}</div>;

  return (
    <div className="product-list-container">
      <h2>All Products</h2>
      {products.length === 0 ? (
        <p>No products available.</p>
      ) : (
        <div className="product-grid">
          {products.map((product) => (
            <ProductCard key={product.id} product={product} />
          ))}
        </div>
      )}
    </div>
  );
}

export default ProductList;
EOF

# react-frontend/src/services/api.js (Base Axios instance)
cat << 'EOF' > react-frontend/src/services/api.js
import axios from 'axios';

# Using import.meta.env for Vite compatibility
const LARAVEL_API_BASE_URL = import.meta.env.VITE_API_BASE_URL_LARAVEL || 'http://localhost:8000/api';
const PYTHON_API_BASE_URL = import.meta.env.VITE_API_BASE_URL_PYTHON || 'http://localhost:8001';

const laravelApiClient = axios.create({
  baseURL: LARAVEL_API_BASE_URL,
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  },
});

const pythonApiClient = axios.create({
  baseURL: PYTHON_API_BASE_URL,
  headers: {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  },
});

# Interceptor to add auth token for Laravel API
laravelApiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('authToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

# Interceptor to add auth token for Python API (if applicable)
pythonApiClient.interceptors.request.use(
    (config) => {
      # Python API in this MVP uses simple token. Adjust as needed.
      # const token = localStorage.getItem('authToken');
      # if (token) {
      #   config.headers.Authorization = `Bearer ${token}`;
      # }
      return config;
    },
    (error) => {
      return Promise.reject(error);
    }
  );


export { laravelApiClient, pythonApiClient };
EOF

# react-frontend/src/services/authService.js
cat << 'EOF' > react-frontend/src/services/authService.js
import { laravelApiClient } from './api';

export const loginUser = async (credentials) => {
  try {
    const response = await laravelApiClient.post('/login', credentials);
    return response.data;
  } catch (error) {
    console.error('Login error:', error.response?.data || error.message);
    throw error;
  }
};

export const registerUser = async (userData) => {
  try {
    const response = await laravelApiClient.post('/register', userData);
    return response.data;
  } catch (error) {
    console.error('Register error:', error.response?.data || error.message);
    throw error;
  }
};

export const logoutUser = async () => {
  try {
    await laravelApiClient.post('/logout');
    localStorage.removeItem('authToken');
    localStorage.removeItem('user');
  } catch (error) {
    console.error('Logout error:', error.response?.data || error.message);
    # Even if logout fails on server, clear local storage
    localStorage.removeItem('authToken');
    localStorage.removeItem('user');
    throw error;
  }
};

export const getCurrentUser = async () => {
  try {
    const response = await laravelApiClient.get('/user');
    return response.data;
  } catch (error) {
    console.error('Fetch current user error:', error.response?.data || error.message);
    throw error;
  }
};
EOF

# react-frontend/src/services/productService.js
cat << 'EOF' > react-frontend/src/services/productService.js
import { laravelApiClient } from './api';

export const getProducts = async () => {
  try {
    const response = await laravelApiClient.get('/products');
    return response.data;
  } catch (error) {
    console.error('Error fetching products:', error.response?.data || error.message);
    throw error;
  }
};

export const getProductById = async (id) => {
  try {
    const response = await laravelApiClient.get(`/products/${id}`);
    return response.data;
  } catch (error) {
    console.error(`Error fetching product ${id}:`, error.response?.data || error.message);
    throw error;
  }
};

# Add create, update, delete product functions if needed for admin panel
EOF

# react-frontend/src/services/orderService.js
cat << 'EOF' > react-frontend/src/services/orderService.js
import { laravelApiClient } from './api';

export const getOrders = async () => {
  try {
    const response = await laravelApiClient.get('/orders');
    return response.data;
  } catch (error) {
    console.error('Error fetching orders:', error.response?.data || error.message);
    throw error;
  }
};

export const createOrder = async (orderData) => {
  try {
    const response = await laravelApiClient.post('/orders', orderData);
    return response.data;
  } catch (error) {
    console.error('Error creating order:', error.response?.data || error.message);
    throw error;
  }
};

export const getOrderById = async (id) => {
  try {
    const response = await laravelApiClient.get(`/orders/${id}`);
    return response.data;
  } catch (error) {
    console.error(`Error fetching order ${id}:`, error.response?.data || error.message);
    throw error;
  }
};

# Add update, delete order functions if needed (e.g., for admin)
EOF

# react-frontend/src/services/dataAnalysisService.js
cat << 'EOF' > react-frontend/src/services/dataAnalysisService.js
import { pythonApiClient } from './api';

export const getSalesTrends = async () => {
  try {
    const response = await pythonApiClient.get('/sales/trends');
    return response.data;
  } catch (error) {
    console.error('Error fetching sales trends:', error.response?.data || error.message);
    throw error;
  }
};

export const getProductRecommendations = async (productId) => {
  try {
    const response = await pythonApiClient.get(`/recommendations/product/${productId}`);
    return response.data;
  } catch (error) {
    console.error(`Error fetching product recommendations for ${productId}:`, error.response?.data || error.message);
    throw error;
  }
};

export const getUserRecommendations = async (userId) => {
  try {
    const response = await pythonApiClient.get(`/recommendations/user/${userId}`);
    return response.data;
  } catch (error) {
    console.error(`Error fetching user recommendations for ${userId}:`, error.response?.data || error.message);
    throw error;
  }
};

# Add other data analysis calls as needed
EOF

# react-frontend/Dockerfile (Development version)
cat << 'EOF' > react-frontend/Dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
EOF

# -----------------------------------------------------------------------------
# 填充根目錄檔案
echo "填充根目錄檔案..."

# docker-compose.yml
cat << 'EOF' > docker-compose.yml
version: '3.8'

services:
  # Laravel Backend Service
  laravel_app:
    build:
      context: ./laravel-backend
      dockerfile: Dockerfile
    image: laravel_app_image
    container_name: laravel_backend
    restart: unless-stopped
    # Laravel's Nginx is now proxied by the main Nginx service, not directly exposed to host
    # ports:
    #   - "8000:80"
    volumes:
      - ./laravel-backend:/var/www/html # Mount source code
      # If Laravel is serving static assets or handling Nginx itself, you might need a Laravel-specific Nginx config here
      # However, for this setup, the main Nginx handles routing to it.
    depends_on:
      - mysql
      - redis # Add dependency on Redis
    environment:
      # Laravel .env variables
      DB_HOST: mysql
      DB_DATABASE: ecommerce_db
      DB_USERNAME: root
      DB_PASSWORD: password
      APP_URL: http://localhost # This will be set by the host, actual request will come via Nginx
      CACHE_DRIVER: redis
      REDIS_HOST: redis
      REDIS_PORT: 6379
      FASTAPI_URL: http://python_app:8001 # Laravel calling FastAPI internally
    networks:
      - ecommerce_network

  # Python FastAPI Backend Service
  python_app:
    build:
      context: ./python-backend
      dockerfile: Dockerfile
    image: python_app_image
    container_name: python_backend
    restart: unless-stopped
    # FastAPI is now proxied by the main Nginx service, not directly exposed to host
    # ports:
    #   - "8001:8001"
    volumes:
      - ./python-backend:/app # Mount source code
      - ./python-backend/data:/app/data # Mount data directory for persistent mock data
    environment:
      # Pass environment variables to Python app if needed
      DATABASE_URL: sqlite:///./data/sql_app.db # Example for SQLite
      SECRET_KEY: your-fastapi-secret-key # Change this!
    networks:
      - ecommerce_network

  # React Frontend Service (for development - will be built by npm start)
  react_app:
    build:
      context: ./react-frontend
      dockerfile: Dockerfile
    image: react_app_image
    container_name: react_frontend
    restart: unless-stopped
    # React app runs its own dev server on 3000 inside the container, proxied by Nginx
    # No direct host port mapping here as Nginx will proxy
    # ports:
    #   - "3000:3000" # If you want to access React dev server directly
    volumes:
      - ./react-frontend:/app # Mount source code for development
      - /app/node_modules # Avoid overwriting node_modules during development
    depends_on:
      - laravel_app # React depends on Laravel for its APIs
      - python_app # React depends on Python for its APIs
    networks:
      - ecommerce_network

  # MySQL Database Service
  mysql:
    image: mysql:8.0
    container_name: mysql_db
    restart: unless-stopped
    ports:
      - "3306:3306" # Expose for host access and debugging
    environment:
      MYSQL_DATABASE: ecommerce_db
      MYSQL_ROOT_PASSWORD: password # Use a strong password in production!
      MYSQL_ALLOW_EMPTY_PASSWORD: "no" # Set to "no" for stronger security
    volumes:
      - mysql_data:/var/lib/mysql # Persistent data volume
    networks:
      - ecommerce_network

  # Redis Cache Service
  redis:
    image: redis:alpine
    container_name: redis_cache
    restart: unless-stopped
    ports:
      - "6379:6379" # Expose for host access and debugging
    volumes:
      - redis_data:/data # Persistent data for Redis
    networks:
      - ecommerce_network

  # Nginx Proxy (Unified entry point, Gzip, Caching, API Proxying)
  nginx:
    image: nginx:stable-alpine
    container_name: nginx_proxy
    ports:
      - "80:80" # Expose Nginx on host port 80
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro # Main Nginx config
      - ./nginx/conf.d:/etc/nginx/conf.d:ro       # Include site-specific configs
    depends_on:
      - laravel_app
      - python_app
      - react_app # Nginx needs React app running to proxy its dev server
    networks:
      - ecommerce_network

# Docker Networks
networks:
  ecommerce_network:
    driver: bridge

# Docker Volumes for persistent data
volumes:
  mysql_data:
  redis_data:
EOF

# nginx/nginx.conf (Main Nginx config to include others and enable gzip)
cat << 'EOF' > nginx/nginx.conf
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    tcp_nopush     on;
    keepalive_timeout  65;

    # Global Gzip compression settings
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_buffers 16 8k;
    gzip_http_version 1.1;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml+rss text/javascript;

    include /etc/nginx/conf.d/*.conf; # Include individual site configs from conf.d
}
EOF

# nginx/conf.d/laravel.conf (Nginx config for Laravel backend)
cat << 'EOF' > nginx/conf.d/laravel.conf
upstream laravel_backend_upstream {
    server laravel_app:9000; # Points to PHP-FPM service in docker-compose
}

server {
    listen 80;
    server_name _; # Listen on all hostnames, or specify your domain (e.g., laravel.local)
    root /var/www/html/public; # Laravel's public directory inside the container

    # API proxy for Laravel backend
    location /api {
        # Pass the request to the Laravel backend (PHP-FPM)
        fastcgi_pass laravel_backend_upstream;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root/index.php; # Point to Laravel's entry point
        include fastcgi_params; # Include FastCGI parameters
        fastcgi_param PATH_INFO $uri; # Pass the original URI
        # Additional headers for CORS if needed, or handle in Laravel
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
        if ($request_method = 'OPTIONS') {
            return 204;
        }
    }
}
EOF

# nginx/conf.d/react.conf (Nginx config for React frontend, acting as a reverse proxy for React dev server)
cat << 'EOF' > nginx/conf.d/react.conf
server {
    listen 80 default_server; # Listen on port 80, default server for unmatched hostnames
    server_name _; # Catch-all server name, or specify your domain (e.g., react.local)

    # Serve static files from React build directory if in production, or proxy to dev server
    # For development, we proxy to React's dev server running on port 3000 in its container
    location / {
        proxy_pass http://react_app:3000; # Proxy to React's development server
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_pragma $http_authorization;
        proxy_no_cache $http_pragma $http_authorization;
        proxy_redirect off;
    }

    # Proxy Python FastAPI API calls
    location /api-python/ {
        rewrite ^/api-python/(.*)$ /$1 break; # Remove /api-python/ prefix
        proxy_pass http://python_app:8001; # Proxy to Python FastAPI service
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF


# -----------------------------------------------------------------------------
# 雜項檔案和權限
echo "設定雜項檔案和權限..."

# .gitignore
cat << 'EOF' > .gitignore
# Laravel specific
/laravel-backend/vendor/
/laravel-backend/node_modules/
/laravel-backend/.env
/laravel-backend/public/storage
/laravel-backend/storage/*.key
/laravel-backend/bootstrap/cache/*.php

# Python specific
/python-backend/__pycache__/
/python-backend/.venv/
/python-backend/.env
/python-backend/data/*.db # SQLite database file if used

# React specific
/react-frontend/node_modules/
/react-frontend/build/
/react-frontend/.env.local

# Docker
docker-compose.override.yml

# IDE-specific files
.idea/
.vscode/

# Logs
*.log

# OS generated files
.DS_Store
Thumbs.db
EOF

# README.md (Root project README)
cat << 'EOF' > README.md
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
EOF

echo "所有檔案內容已寫入完成！"

echo "下一步："
echo "1. 進入 'e-commerce-data-driven-mvp' 目錄。"
echo "2. 執行 'docker-compose up --build -d' 啟動所有服務。"
echo "3. 等待服務啟動後，執行 'docker-compose exec laravel_app php artisan key:generate' 生成 APP_KEY。"
echo "4. 執行 'docker-compose exec laravel_app php artisan migrate --seed' 初始化數據庫和填充數據。"
echo "5. 訪問 http://localhost 查看 React 前端應用，訪問 http://localhost/api-python/docs 查看 FastAPI 文檔。"
echo "注意：Laravel Cache 預設配置為 Redis，確保 Redis 服務已正常運行。"
