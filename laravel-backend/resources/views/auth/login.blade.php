@extends('layouts.app')

@section('title', '登錄')

@section('content')
    <div class="flex items-center justify-center min-h-screen -mt-16">
        <div class="w-full max-w-md bg-white p-8 rounded-lg shadow-lg">
            <h2 class="text-3xl font-bold text-gray-900 text-center mb-6">登錄您的帳戶</h2>

            @if ($errors->any())
                <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded-md relative mb-4">
                    <ul>
                        @foreach ($errors->all() as $error)
                            <li>{{ $error }}</li>
                        @endforeach
                    </ul>
                </div>
            @endif

            <form method="POST" action="{{ route('login') }}">
                @csrf

                <div class="mb-4">
                    <label for="email" class="block text-gray-700 text-sm font-bold mb-2">電子郵件地址</label>
                    <input type="email" name="email" id="email" value="{{ old('email') }}" required autofocus autocomplete="username"
                           class="shadow appearance-none border rounded-md w-full py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-400 focus:border-transparent transition-all duration-200">
                </div>

                <div class="mb-6">
                    <label for="password" class="block text-gray-700 text-sm font-bold mb-2">密碼</label>
                    <input type="password" name="password" id="password" required autocomplete="current-password"
                           class="shadow appearance-none border rounded-md w-full py-2 px-3 text-gray-700 mb-3 leading-tight focus:outline-none focus:ring-2 focus:ring-blue-400 focus:border-transparent transition-all duration-200">
                </div>

                <div class="flex items-center justify-between mb-6">
                    <label for="remember_me" class="flex items-center">
                        <input type="checkbox" name="remember" id="remember_me" class="rounded-md border-gray-300 text-blue-600 shadow-sm focus:ring-blue-500">
                        <span class="ml-2 text-sm text-gray-600">記住我</span>
                    </label>
                </div>

                <div class="flex items-center justify-end">
                    <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded-md shadow-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50 transition-colors duration-200">
                        登錄
                    </button>
                </div>
            </form>

            <p class="text-center text-gray-600 text-sm mt-6">
                還沒有帳戶？ <a href="{{ route('register') }}" class="text-blue-600 hover:underline font-semibold">註冊一個</a>
            </p>
        </div>
    </div>
@endsection
