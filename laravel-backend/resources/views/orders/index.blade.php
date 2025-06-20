@extends('layouts.app')

@section('title', '我的訂單')

@section('content')
    <h1 class="text-4xl font-bold text-gray-900 mb-8 text-center">我的訂單</h1>

    @if ($orders->isEmpty())
        <p class="text-center text-gray-600 text-xl">您目前還沒有任何訂單。</p>
        <div class="text-center mt-6">
            <a href="{{ route('products.index') }}" class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg shadow-lg transition-colors duration-300">
                開始購物
            </a>
        </div>
    @else
        <div class="grid grid-cols-1 gap-6">
            @foreach ($orders as $order)
                <div class="bg-white rounded-lg shadow-md p-6 border border-gray-200">
                    <div class="flex justify-between items-center mb-4 pb-4 border-b border-gray-200">
                        <div>
                            <h2 class="text-2xl font-bold text-gray-800">訂單 #{{ $order->id }}</h2>
                            <p class="text-gray-600 text-sm">訂單日期: {{ $order->created_at->format('Y-m-d H:i') }}</p>
                        </div>
                        <span class="text-xl font-semibold {{ $order->status === 'completed' ? 'text-green-600' : 'text-orange-500' }}">
                            {{ ucfirst($order->status) }}
                        </span>
                    </div>

                    <div class="mb-4">
                        <p class="text-lg font-semibold text-gray-800 mb-2">訂單總額: <span class="text-blue-700 text-2xl">${{ number_format($order->total_amount, 2) }}</span></p>
                    </div>

                    <h3 class="text-xl font-semibold text-gray-700 mb-3">商品列表:</h3>
                    <ul class="space-y-3">
                        @foreach ($order->orderItems as $item)
                            <li class="flex items-center space-x-4 bg-gray-50 p-3 rounded-md border border-gray-100">
                                <img src="https://placehold.co/80x60/f0f9ff/0c4a6e?text={{ urlencode(Str::limit($item->product->name, 10)) }}"
                                     alt="{{ $item->product->name }}"
                                     class="w-16 h-12 object-cover rounded-md">
                                <div>
                                    <a href="{{ route('products.show', $item->product->id) }}" class="text-lg font-medium text-gray-800 hover:text-blue-600">{{ $item->product->name }}</a>
                                    <p class="text-gray-600 text-sm">數量: {{ $item->quantity }} x ${{ number_format($item->price, 2) }}</p>
                                </div>
                                <div class="ml-auto text-lg font-bold text-gray-900">${{ number_format($item->quantity * $item->price, 2) }}</div>
                            </li>
                        @endforeach
                    </ul>

                    <div class="mt-6 text-right">
                        <a href="{{ route('orders.show', $order->id) }}" class="bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-4 rounded-md shadow-md transition-colors duration-200">
                            查看訂單詳情
                        </a>
                    </div>
                </div>
            @endforeach
        </div>
    @endif
@endsection
