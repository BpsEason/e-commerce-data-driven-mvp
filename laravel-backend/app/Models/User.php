<?php
// e-commerce-data-driven-mvp/laravel-backend/app/Models/User.php
namespace App\Models;

use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * 允許批量賦值的屬性。
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
    ];

    /**
     * 應隱藏的屬性。
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * 應轉換為不同數據類型的屬性。
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    /**
     * 獲取與用戶相關聯的訂單。
     */
    public function orders()
    {
        return $this->hasMany(Order::class);
    }

    /**
     * 獲取與用戶相關聯的商品交互記錄。
     */
    public function interactions()
    {
        return $this->hasMany(UserProductInteraction::class);
    }
}
