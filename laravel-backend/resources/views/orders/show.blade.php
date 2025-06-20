@extends('layouts.app')

@section('title', '訂單 #' . $order->id . ' 詳情')

@section('content')
    <h1 class="text-4xl font-bold text-gray-900 mb-8 text-center">訂單詳情 #{{ $order->id }}</h1>

    <div class="bg-white rounded-lg shadow-lg p-8 mb-8">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
            <div>
                <p class="text-gray-700 text-lg mb-2"><span class="font-semibold">訂單狀態:</span>
                    <span class="ml-2 text-xl font-bold {{ $order->status === 'completed' ? 'text-green-600' : 'text-orange-500' }}">
                        {{ ucfirst($order->status) }}
                    </span>
                </p>
                <p class="text-gray-700 text-lg"><span class="font-semibold">訂單日期:</span> {{ $order->created_at->format('Y-m-d H:i:s') }}</p>
            </div>
            <div class="text-right">
                <p class="text-gray-700 text-lg"><span class="font-semibold">總金額:</span>
                    <span class="ml-2 text-3xl font-extrabold text-blue-700">${{ number_format($order->total_amount, 2) }}</span>
                </p>
            </div>
        </div>

        <h2 class="text-2xl font-bold text-gray-800 mb-4 pb-2 border-b border-gray-200">訂單商品</h2>
        <ul class="space-y-4">
            @foreach ($order->orderItems as $item)
                <li class="flex items-center space-x-6 bg-gray-50 p-4 rounded-md shadow-sm border border-gray-100">
                    <img src="https://placehold.co/100x80/f0f9ff/0c4a6e?text={{ urlencode(Str::limit($item->product->name, 10)) }}"
                         alt="{{ $item->product->name }}"
                         class="w-24 h-20 object-cover rounded-md">
                    <div class="flex-grow">
                        <a href="{{ route('products.show', $item->product->id) }}" class="text-xl font-medium text-gray-800 hover:text-blue-600">{{ $item->product->name }}</a>
                        <p class="text-gray-600">單價: ${{ number_format($item->price, 2) }}</p>
                        <p class="text-gray-600">數量: {{ $item->quantity }}</p>
                    </div>
                    <div class="text-right">
                        <p class="text-2xl font-bold text-gray-900">${{ number_format($item->quantity * $item->price, 2) }}</p>
                    </div>
                </li>
            @endforeach
        </ul>
    </div>

    <div class="text-center mt-6">
        <a href="{{ route('orders.index') }}" class="bg-gray-300 hover:bg-gray-400 text-gray-800 font-bold py-2 px-4 rounded-md shadow-md transition-colors duration-200">
            返回我的訂單
        </a>
    </div>
@endsection
