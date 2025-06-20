@extends('layouts.app')

@section('title', '所有商品')

@section('content')
    <h1 class="text-4xl font-bold text-gray-900 mb-8 text-center">所有商品</h1>

    @if ($products->isEmpty())
        <p class="text-center text-gray-600 text-xl">目前沒有任何商品。</p>
    @else
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            @foreach ($products as $product)
                <div class="bg-white rounded-lg shadow-md overflow-hidden transition-transform transform hover:scale-105 duration-300">
                    <a href="{{ route('products.show', $product->id) }}">
                        <img src="https://placehold.co/400x300/e0f2fe/0369a1?text={{ urlencode($product->name) }}"
                             alt="{{ $product->name }}"
                             class="w-full h-48 object-cover rounded-t-lg">
                    </a>
                    <div class="p-5">
                        <h2 class="text-xl font-semibold text-gray-800 mb-2 truncate">
                            <a href="{{ route('products.show', $product->id) }}" class="hover:text-blue-600">{{ $product->name }}</a>
                        </h2>
                        <p class="text-gray-600 text-sm mb-3">{{ Str::limit($product->description, 70) }}</p>
                        <div class="flex justify-between items-center mb-4">
                            <span class="text-2xl font-bold text-blue-700">${{ number_format($product->price, 2) }}</span>
                            <span class="text-sm text-gray-500">庫存: {{ $product->stock }}</span>
                        </div>
                        <form action="{{ route('products.addToCart', $product->id) }}" method="POST">
                            @csrf
                            <button type="submit" class="w-full bg-green-500 hover:bg-green-600 text-white font-bold py-2 px-4 rounded-md shadow-md transition-colors duration-200">
                                加入購物車
                            </button>
                        </form>
                    </div>
                </div>
            @endforeach
        </div>
    @endif
@endsection
