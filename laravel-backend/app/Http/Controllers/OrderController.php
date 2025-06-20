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
