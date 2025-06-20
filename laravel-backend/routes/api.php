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
