<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Schedule::command('rendelesek:cleanup --days=30')
    ->daily()
    ->at('02:34')
    ->withoutOverlapping();

Schedule::command('felhasznalok:inaktival')->daily();