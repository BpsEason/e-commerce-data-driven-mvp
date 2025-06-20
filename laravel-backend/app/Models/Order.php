<?php
// e-commerce-data-driven-mvp/laravel-backend/app/Models/Order.php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    /**
     * 允許批量賦值的屬性。
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'user_id',
        'total_amount',
        'status',
    ];

    /**
     * 獲取擁有此訂單的用戶。
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * 獲取與訂單相關聯的訂單項。
     */
    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }
}
