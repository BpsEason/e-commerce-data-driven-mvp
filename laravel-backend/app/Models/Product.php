<?php
// e-commerce-data-driven-mvp/laravel-backend/app/Models/Product.php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    /**
     * 允許批量賦值的屬性。
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'description',
        'price',
        'category',
        'stock',
    ];

    /**
     * 獲取與商品相關聯的訂單項。
     */
    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }

    /**
     * 獲取與商品相關聯的用戶交互記錄。
     */
    public function interactions()
    {
        return $this->hasMany(UserProductInteraction::class);
    }
}
