<?php
// e-commerce-data-driven-mvp/laravel-backend/app/Http/Controllers/Auth/AuthenticatedSessionController.php
// 簡化登錄控制器，基於 Laravel 11 默認實現

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class AuthenticatedSessionController extends Controller
{
    /**
     * 顯示登錄視圖。
     */
    public function create(): View
    {
        return view('auth.login');
    }

    /**
     * 處理傳入的認證請求。
     */
    public function store(Request $request): RedirectResponse
    {
        $request->validate([
            'email' => ['required', 'string', 'email'],
            'password' => ['required', 'string'],
        ]);

        $credentials = $request->only('email', 'password');

        if (Auth::attempt($credentials, $request->remember)) {
            $request->session()->regenerate();

            return redirect()->intended(route('dashboard', absolute: false));
        }

        return back()->withErrors([
            'email' => '提供的憑據與我們的記錄不符。',
        ])->onlyInput('email');
    }

    /**
     * 銷毀一個認證會話。
     */
    public function destroy(Request $request): RedirectResponse
    {
        Auth::guard('web')->logout();

        $request->session()->invalidate();

        $request->session()->regenerateToken();

        return redirect('/');
    }
}
