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
