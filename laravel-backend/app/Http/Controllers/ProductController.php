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
