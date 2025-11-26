<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('teszt');
});

require __DIR__.'/auth.php';
