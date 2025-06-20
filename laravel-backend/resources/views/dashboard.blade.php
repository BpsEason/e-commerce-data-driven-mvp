@extends('layouts.app')

@section('title', '儀表板')

@section('content')
    <h1 class="text-4xl font-bold text-gray-900 mb-6 text-center">歡迎, {{ Auth::user()->name }}!</h1>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div class="bg-white p-6 rounded-lg shadow-md flex flex-col items-center justify-center text-center transition-transform transform hover:scale-105 duration-300">
            <h2 class="text-2xl font-semibold text-gray-800 mb-3">瀏覽商品</h2>
            <p class="text-gray-600 mb-4">發現我們目錄中的所有商品。</p>
            <a href="{{ route('products.index') }}" class="bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-4 rounded-md shadow-md">前往商品頁</a>
        </div>

        <div class="bg-white p-6 rounded-lg shadow-md flex flex-col items-center justify-center text-center transition-transform transform hover:scale-105 duration-300">
            <h2 class="text-2xl font-semibold text-gray-800 mb-3">查看我的訂單</h2>
            <p class="text-gray-600 mb-4">管理您的歷史訂單和訂單狀態。</p>
            <a href="{{ route('orders.index') }}" class="bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-4 rounded-md shadow-md">我的訂單</a>
        </div>

        <div class="bg-white p-6 rounded-lg shadow-md flex flex-col items-center justify-center text-center transition-transform transform hover:scale-105 duration-300">
            <h2 class="text-2xl font-semibold text-gray-800 mb-3">熱門商品</h2>
            <p class="text-gray-600 mb-4">看看大家都在買什麼。</p>
            <a href="{{ route('products.popular') }}" class="bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-4 rounded-md shadow-md">查看熱門</a>
        </div>

        <div class="bg-white p-6 rounded-lg shadow-md flex flex-col items-center justify-center text-center transition-transform transform hover:scale-105 duration-300">
            <h2 class="text-2xl font-semibold text-gray-800 mb-3">為您推薦</h2>
            <p class="text-gray-600 mb-4">探索為您個性化推薦的商品。</p>
            <a href="{{ route('products.recommendations') }}" class="bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-4 rounded-md shadow-md">獲取推薦</a>
        </div>
    </div>
@endsection
