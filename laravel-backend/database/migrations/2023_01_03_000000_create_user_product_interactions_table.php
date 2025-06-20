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
