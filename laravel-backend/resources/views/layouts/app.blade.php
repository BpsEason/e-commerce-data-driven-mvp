<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>電商 MVP - @yield('title', '首頁')</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #f3f4f6;
        }
        .container {
            max-width: 1200px;
        }
    </style>
</head>
<body class="bg-gray-100 antialiased">
    <div class="min-h-screen bg-gray-100">
        <nav class="bg-white shadow-md">
            <div class="container mx-auto px-4 py-3 flex justify-between items-center">
                <a href="{{ url('/') }}" class="text-2xl font-bold text-gray-800 rounded-md p-2 hover:bg-gray-100">電商 MVP</a>
                <div class="flex items-center space-x-4">
                    <a href="{{ route('products.index') }}" class="text-gray-700 hover:text-blue-600 font-medium p-2 rounded-md hover:bg-blue-50 transition-colors duration-200">所有商品</a>
                    <a href="{{ route('products.popular') }}" class="text-gray-700 hover:text-blue-600 font-medium p-2 rounded-md hover:bg-blue-50 transition-colors duration-200">熱門商品</a>
                    @auth
                        <a href="{{ route('products.recommendations') }}" class="text-gray-700 hover:text-blue-600 font-medium p-2 rounded-md hover:bg-blue-50 transition-colors duration-200">為您推薦</a>
                        <a href="{{ route('orders.index') }}" class="text-gray-700 hover:text-blue-600 font-medium p-2 rounded-md hover:bg-blue-50 transition-colors duration-200">我的訂單</a>
                        <form method="POST" action="{{ route('logout') }}">
                            @csrf
                            <button type="submit" class="bg-red-500 hover:bg-red-600 text-white font-bold py-2 px-4 rounded-md shadow-md transition-colors duration-200">
                                登出 ({{ Auth::user()->name }})
                            </button>
                        </form>
                    @else
                        <a href="{{ route('login') }}" class="text-blue-600 hover:text-white hover:bg-blue-600 font-bold py-2 px-4 rounded-md border border-blue-600 transition-colors duration-200">登錄</a>
                        <a href="{{ route('register') }}" class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-md shadow-md transition-colors duration-200">註冊</a>
                    @endauth
                </div>
            </div>
        </nav>

        <main class="container mx-auto px-4 py-8">
            @if (session('success'))
                <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded-md relative mb-4" role="alert">
                    <strong class="font-bold">成功!</strong>
                    <span class="block sm:inline">{{ session('success') }}</span>
                </div>
            @endif
            @if (session('error'))
                <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded-md relative mb-4" role="alert">
                    <strong class="font-bold">錯誤!</strong>
                    <span class="block sm:inline">{{ session('error') }}</span>
                </div>
            @endif

            @yield('content')
        </main>
    </div>
</body>
</html>
