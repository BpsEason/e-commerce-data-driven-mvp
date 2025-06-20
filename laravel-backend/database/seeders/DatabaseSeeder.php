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
