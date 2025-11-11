<?php

use App\Http\Controllers\FelhasznalokController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});
Route::get('/teszt', [FelhasznalokController::class, 'felhasznalok']);
Route::get('/teszt/create/{felhasznalo}', [FelhasznalokController::class, 'felhasznalokCreate']);
