<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class InaktivalRegiFehasznalok extends Command
{
    protected $signature = 'felhasznalok:inaktival';
    protected $description = 'Inaktiválja azokat a felhasználókat, akik 365+ napja nem jelentkeztek be';

    public function handle(): int
    {
        $hatar = Carbon::now()->subDays(365);

        $count = DB::table('felhasznalok')
            ->where('statusz', 1)
            ->where(function ($q) use ($hatar) {
                $q->where('utolso_Belepes', '<', $hatar)
                    ->orWhereNull('utolso_Belepes');
            })
            ->whereNotIn('id', function ($q) {
                $q->select('felhasznalo_id')
                    ->from('felhasznaloAdatok')
                    ->whereIn('szerepkor', ['admin', 'moderator']);
            })
            ->update(['statusz' => 0]);

        $this->info("$count felhasználó inaktiválva.");
        return 0;
    }
}