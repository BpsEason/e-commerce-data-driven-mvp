<?php
// e-commerce-data-driven-mvp/laravel-backend/database/migrations/2014_10_12_000000_create_users_table.php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * 運行數據庫遷移。
     * 創建 'users' 表。
     */
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password');
            $table->rememberToken();
            $table->timestamps();
        });
    }

    /**
     * 回滾數據庫遷移。
     * 刪除 'users' 表。
     */
    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
