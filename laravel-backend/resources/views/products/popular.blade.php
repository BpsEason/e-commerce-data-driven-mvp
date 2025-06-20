@extends('layouts.app')

@section('title', '熱門商品')

@section('content')
    <h1 class="text-4xl font-bold text-gray-900 mb-8 text-center">熱門商品</h1>

    @if (empty($popularProducts))
        <p class="text-center text-gray-600 text-xl">目前無法獲取熱門商品數據。請稍後再試。</p>
    @else
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            @foreach ($popularProducts as $product)
                <div class="bg-white rounded-lg shadow-md overflow-hidden transition-transform transform hover:scale-105 duration-300">
                    <a href="{{ route('products.show', $product['product_id']) }}">
                        <img src="https://placehold.co/400x300/ffe4e6/c23450?text={{ urlencode($product['name']) }}"
                             alt="{{ $product['name'] }}"
                             class="w-full h-48 object-cover rounded-t-lg">
                    </a>
                    <div class="p-5">
                        <h2 class="text-xl font-semibold text-gray-800 mb-2 truncate">
                            <a href="{{ route('products.show', $product['product_id']) }}" class="hover:text-blue-600">{{ $product['name'] }}</a>
                        </h2>
                        <p class="text-gray-600 text-sm mb-3">分類: {{ $product['category'] ?? '未知' }}</p>
                        <div class="flex justify-between items-center">
                            <span class="text-2xl font-bold text-red-700">${{ number_format($product['price'], 2) }}</span>
                            <span class="text-sm text-gray-500">銷量: {{ $product['sales_volume'] ?? 'N/A' }}</span>
                        </div>
                        <p class="text-gray-500 text-sm mt-2">（數據來自 FastAPI）</p>
                    </div>
                </div>
            @endforeach
        </div>
    @endif
@endsection
