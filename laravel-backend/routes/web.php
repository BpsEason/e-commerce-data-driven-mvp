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
