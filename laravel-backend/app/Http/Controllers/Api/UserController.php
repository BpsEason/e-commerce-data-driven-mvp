<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class UserController extends Controller
{
    /**
     * Display a listing of the resource (Admin only usually).
     */
    public function index()
    {
        # Implement authorization check here for admin users
        # if (!auth()->user()->isAdmin()) { ... }
        $users = User::all();
        return response()->json($users);
    }

    /**
     * Display the specified resource.
     */
    public function show(User $user)
    {
        # Allow user to view their own profile, or admin to view any profile
        # if (auth()->id() !== $user->id && !auth()->user()->isAdmin()) { ... }
        return response()->json($user);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, User $user)
    {
        # Allow user to update their own profile, or admin to update any profile
        # if (auth()->id() !== $user->id && !auth()->user()->isAdmin()) { ... }

        $validator = Validator::make($request->all(), [
            'name' => 'string|max:255',
            'email' => 'string|email|max:255|unique:users,email,' . $user->id,
            'password' => 'nullable|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $data = $request->only('name', 'email');
        if ($request->filled('password')) {
            $data['password'] = bcrypt($request->password);
        }

        $user->update($data);
        return response()->json($user);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(User $user)
    {
        # Admin only
        # if (!auth()->user()->isAdmin()) { ... }
        $user->delete();
        return response()->json(null, 204);
    }
}
