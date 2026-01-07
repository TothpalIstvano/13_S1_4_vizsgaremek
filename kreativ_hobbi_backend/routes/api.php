<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BlogController;
use App\Http\Controllers\KommentController;
use App\Models\Felhasznalok;

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

Route::get('/user/check', function () {
    if (Auth::check()) {
        return response()->json(['loggedIn' => true, 'user' => auth()->user()], 200);
    } else {
        return response()->json(['loggedIn' => false], 200);
    }
});

Route::get('/teszt', function () {
    return Felhasznalok::all();
});

// Blog routes
Route::get('/blog', [BlogController::class, 'index']);
Route::get('/blog/{id}', [BlogController::class, 'show']);

// Comment routes
Route::get('/blog/{id}/comments', [KommentController::class, 'index']);
Route::post('/blog/{id}/comments', [KommentController::class, 'store']);
Route::delete('/comments/{id}', [KommentController::class, 'destroy']);