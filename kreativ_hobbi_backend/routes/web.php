<?php

use App\Models\Felhasznalok;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return ['Laravel' => app()->version()];
});
Route::get('api/teszt', function () {
    return Felhasznalok::all(); });

require __DIR__ . '/auth.php';