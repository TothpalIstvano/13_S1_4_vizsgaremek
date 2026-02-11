<?php

use App\Models\Felhasznalok;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return ['Laravel' => app()->version()];
});

// Source - https://stackoverflow.com/a/58936108
// Posted by Chetam Okafor, modified by community. See post 'Timeline' for change history
// Retrieved 2026-02-11, License - CC BY-SA 4.0

Route::get('/linkstorage', function () {
    Artisan::call('storage:link');
});


require __DIR__ . '/auth.php';