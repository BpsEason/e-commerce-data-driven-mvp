<?php
// e-commerce-data-driven-mvp/laravel-backend/app/Models/UserProductInteraction.php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UserProductInteraction extends Model
{
    use HasFactory;

    /**
     * 允許批量賦值的屬性。
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'user_id',
        'product_id',
        'interaction_type', # 'view', 'add_to_cart', 'purchase'
    ];

    /**
     * 獲取交互所屬的用戶。
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * 獲取交互所屬的商品。
     */
    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}
