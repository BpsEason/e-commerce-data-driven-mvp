@extends('layouts.app')

@section('title', '歡迎')

@section('content')
    <div class="text-center py-12 bg-white rounded-lg shadow-md">
        <h1 class="text-5xl font-extrabold text-gray-900 mb-4">
            智能數據驅動電商平台 MVP
        </h1>
        <p class="text-xl text-gray-600 mb-8">
            透過 Laravel、FastAPI、Pandas 和 NumPy 的整合，展示數據的力量。
        </p>
        <div class="space-x-4">
            <a href="{{ route('products.index') }}" class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg shadow-lg transition-colors duration-300">
                瀏覽所有商品
            </a>
            @auth
                <a href="{{ route('dashboard') }}" class="bg-gray-200 hover:bg-gray-300 text-gray-800 font-bold py-3 px-6 rounded-lg shadow-lg transition-colors duration-300">
                    前往儀表板
                </a>
            @else
                <a href="{{ route('login') }}" class="bg-gray-200 hover:bg-gray-300 text-gray-800 font-bold py-3 px-6 rounded-lg shadow-lg transition-colors duration-300">
                    登錄
                </a>
                <a href="{{ route('register') }}" class="bg-gray-200 hover:bg-gray-300 text-gray-800 font-bold py-3 px-6 rounded-lg shadow-lg transition-colors duration-300">
                    註冊
                </a>
            @endauth
        </div>
    </div>

    <div class="mt-12">
        <h2 class="text-3xl font-bold text-gray-800 mb-6 text-center">探索數據智能</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
            <div class="bg-white rounded-lg shadow-md p-6">
                <h3 class="text-2xl font-semibold text-blue-600 mb-3">商品推薦</h3>
                <p class="text-gray-700 mb-4">
                    基於用戶行為和商品數據，我們的智能推薦引擎（由 FastAPI 提供支持）能夠為您提供個性化的商品建議。
                </p>
                <a href="{{ route('products.recommendations') }}" class="text-blue-600 hover:underline font-semibold">查看推薦商品 &rarr;</a>
            </div>
            <div class="bg-white rounded-lg shadow-md p-6">
                <h3 class="text-2xl font-semibold text-blue-600 mb-3">熱門商品洞察</h3>
                <p class="text-gray-700 mb-4">
                    了解目前最受歡迎的商品。這些趨勢分析由 FastAPI 實時處理，為您提供市場熱點。
                </p>
                <a href="{{ route('products.popular') }}" class="text-blue-600 hover:underline font-semibold">查看熱門商品 &rarr;</a>
            </div>
        </div>
    </div>
@endsection
