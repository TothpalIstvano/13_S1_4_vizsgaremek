<?php

namespace Database\Seeders;

use App\Models\PosztCimkek;
use App\Models\Posztok;
use App\Models\Cimkek;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB; // Fontos a DB importálása a truncate-hoz

class PosztCimkekSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $posztokIds = Posztok::pluck('id');
        $cimkekIds = Cimkek::pluck('id');

        if ($posztokIds->isEmpty() || $cimkekIds->isEmpty()) {
            $this->command->error('Először futtasd a PosztokSeeder-t és a CimkeSeeder-t!');
            return;
        }

        // 3. Hozzunk létre véletlenszerű kapcsolatokat
        // Például: minden poszthoz rendeljünk 1-5 címkét
        foreach ($posztokIds as $posztId) {
            $randomCimkekIds = $cimkekIds->random(rand(1, 5));
            
            // A syncWithoutDetaching megakadályozza a duplikációkat
            // egyetlen futáson belül is, ha a random() véletlenül ugyanazt adná
            PosztCimkek::insert(
                $randomCimkekIds->map(function($cimkeId) use ($posztId) {
                    return [
                        'poszt_id' => $posztId,
                        'cimke_id' => $cimkeId,
                        'created_at' => now(),
                        'updated_at' => now(),
                    ];
                })->toArray()
            );
        }
    }
}