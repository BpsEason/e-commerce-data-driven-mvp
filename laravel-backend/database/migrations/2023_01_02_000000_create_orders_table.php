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
