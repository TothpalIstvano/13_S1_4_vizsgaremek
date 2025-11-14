<?php

use App\Http\Controllers\FelhasznaloController;
use App\Http\Controllers\KepController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/teszt', [FelhasznaloController::class, 'felhasznalo']);
Route::get('/teszt/create/{felhasznalo}', [FelhasznaloController::class, 'felhasznaloCreate']);
