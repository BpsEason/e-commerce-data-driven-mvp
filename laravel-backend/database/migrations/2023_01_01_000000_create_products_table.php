<?php
// e-commerce-data-driven-mvp/laravel-backend/database/migrations/2023_01_01_000000_create_products_table.php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * 運行數據庫遷移。
     * 創建 'products' 表。
     */
    public function up(): void
    {
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('description')->nullable();
            $table->decimal('price', 8, 2);
            $table->string('category')->nullable();
            $table->integer('stock')->default(0);
            $table->timestamps();
        });
    }

    /**
     * 回滾數據庫遷移。
     * 刪除 'products' 表。
     */
    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};
