<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BlogController;
use App\Models\Felhasznalok;

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

Route::get('api/teszt', function () {
    return Felhasznalok::all();
});

// Test route
Route::get('/teszt', function () {
    return response()->json(['message' => 'API működik!']);
});

// Blog routes
Route::get('/blog', [BlogController::class, 'index']);
Route::get('/blog/{id}', [BlogController::class, 'show']);

