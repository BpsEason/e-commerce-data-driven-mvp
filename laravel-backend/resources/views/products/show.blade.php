@extends('layouts.app')

@section('title', $product->name)

@section('content')
    <div class="bg-white rounded-lg shadow-lg p-8 flex flex-col md:flex-row gap-8 mb-10">
        <div class="md:w-1/2 flex justify-center items-center">
            <img src="https://placehold.co/600x450/e0f2fe/0369a1?text={{ urlencode($product->name) }}"
                 alt="{{ $product->name }}"
                 class="w-full h-auto max-h-96 object-contain rounded-lg shadow-md">
        </div>

        <div class="md:w-1/2">
            <h1 class="text-4xl font-bold text-gray-900 mb-4">{{ $product->name }}</h1>
            <p class="text-gray-600 text-lg mb-6">{{ $product->description }}</p>

            <div class="flex items-baseline mb-4">
                <span class="text-5xl font-extrabold text-blue-700">${{ number_format($product->price, 2) }}</span>
                <span class="ml-4 text-gray-500">分類: <span class="font-semibold">{{ $product->category }}</span></span>
            </div>

            <div class="mb-6">
                <span class="text-gray-700 font-semibold text-lg">庫存: </span>
                @if ($product->stock > 0)
                    <span class="text-green-600 text-lg">{{ $product->stock }} 件有貨</span>
                @else
                    <span class="text-red-600 text-lg">缺貨</span>
                @endif
            </div>

            <div class="flex space-x-4 mb-8">
                <form action="{{ route('products.addToCart', $product->id) }}" method="POST">
                    @csrf
                    <button type="submit"
                            @if ($product->stock === 0) disabled @endif
                            class="bg-green-600 hover:bg-green-700 text-white font-bold py-3 px-6 rounded-md shadow-lg transition-colors duration-200
                                   @if ($product->stock === 0) opacity-50 cursor-not-allowed @endif">
                        加入購物車
                    </button>
                </form>

                <form action="{{ route('orders.store') }}" method="POST">
                    @csrf
                    <input type="hidden" name="product_id" value="{{ $product->id }}">
                    <input type="hidden" name="quantity" value="1"> {{-- 默認購買 1 件 --}}
                    <button type="submit"
                            @if ($product->stock === 0) disabled @endif
                            class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-md shadow-lg transition-colors duration-200
                                   @if ($product->stock === 0) opacity-50 cursor-not-allowed @endif">
                        立即購買
                    </button>
                </form>
            </div>
        </div>
    </div>

    @if (!empty($relatedProducts))
        <div class="mt-12 bg-white rounded-lg shadow-md p-6">
            <h2 class="text-3xl font-bold text-gray-800 mb-6 text-center">相關商品推薦</h2>
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                @foreach ($relatedProducts as $relatedProduct)
                    <div class="bg-gray-50 rounded-lg shadow-sm overflow-hidden border border-gray-200">
                        <a href="{{ route('products.show', $relatedProduct['product_id']) }}">
                            <img src="https://placehold.co/400x250/e0f2fe/0369a1?text={{ urlencode($relatedProduct['name']) }}"
                                 alt="{{ $relatedProduct['name'] }}"
                                 class="w-full h-40 object-cover rounded-t-lg">
                        </a>
                        <div class="p-4">
                            <h3 class="text-lg font-semibold text-gray-800 mb-1 truncate">
                                <a href="{{ route('products.show', $relatedProduct['product_id']) }}" class="hover:text-blue-600">{{ $relatedProduct['name'] }}</a>
                            </h3>
                            <p class="text-blue-700 font-bold">${{ number_format($relatedProduct['price'], 2) }}</p>
                            <p class="text-gray-500 text-sm">推薦分數: {{ round($relatedProduct['score'], 2) }}</p>
                        </div>
                    </div>
                @endforeach
            </div>
        </div>
    @else
        <div class="mt-12 bg-white rounded-lg shadow-md p-6 text-center">
            <p class="text-gray-600 text-lg">目前沒有相關商品推薦。</p>
        </div>
    @endif
@endsection
