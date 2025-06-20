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
