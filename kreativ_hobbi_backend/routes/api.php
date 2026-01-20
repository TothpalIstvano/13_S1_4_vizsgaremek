<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BlogController;
use App\Http\Controllers\KommentController;
use App\Models\Felhasznalok;
use App\Models\Posztok;


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

Route::get('/user/posts', function () {
    if (Auth::check()) {
        $user = auth()->user();
        $posts = Posztok::with('cimkek:id,nev', 'foKep:id,url_Link,alt_szoveg')
            ->where('szerzo_id', $user->id)
            ->get();
        return response()->json(data: $posts);
    } else {
        return response()->json(['error' => 'Unauthorized'], 401);
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

// Címkék az új poszthoz
Route::get('/cimkek', function () {
    $cimkek = \App\Models\Cimkek::select('id', 'nev')->get();
    return response()->json($cimkek);
});