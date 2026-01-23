<?php

namespace Database\Seeders;

use App\Models\TermekCimkek;
use App\Models\Termekek;
use App\Models\Cimkek;
use Illuminate\Database\Seeder;

class TermekCimkekSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $termekekIds = Termekek::pluck('id');
        $cimkekIds = Cimkek::pluck('id');

        if ($termekekIds->isEmpty() || $cimkekIds->isEmpty()) {
            $this->command->error('Először futtasd a PosztokSeeder-t és a CimkeSeeder-t!');
            return;
        }

        // 3. Hozzunk létre véletlenszerű kapcsolatokat
        // Például: minden poszthoz rendeljünk 1-5 címkét
        foreach ($termekekIds as $termekId) {
            $randomCimkekIds = $cimkekIds->random(rand(1, 5));
            
            // A syncWithoutDetaching megakadályozza a duplikációkat
            // egyetlen futáson belül is, ha a random() véletlenül ugyanazt adná
            TermekCimkek::insert(
                $randomCimkekIds->map(function($cimkeId) use ($termekId) {
                    return [
                        'termek_id' => $termekId,
                        'cimke_id' => $cimkeId,
                    ];
                })->toArray()
            );
        }
        $this->command->info('PosztCimkek table seeded successfully!');
    }
}