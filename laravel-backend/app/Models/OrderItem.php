<?php
// e-commerce-data-driven-mvp/laravel-backend/app/Models/OrderItem.php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderItem extends Model
{
    use HasFactory;

    /**
     * 允許批量賦值的屬性。
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'order_id',
        'product_id',
        'quantity',
        'price',
    ];

    /**
     * 獲取擁有此訂單項的訂單。
     */
    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    /**
     * 獲取訂單項所屬的商品。
     */
    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}
