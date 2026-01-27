<?php

namespace Database\Seeders;

use App\Models\PosztKepek;
use App\Models\Posztok;
use App\Models\Kepek;
use Illuminate\Database\Seeder;


class PosztKepekSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // 2. Szerezzük be a szükséges ID-ket
        $posztIds = Posztok::pluck('id');
        $kepIds = Kepek::get('id')->whereBetween('id', [4, 13])->pluck('id');

        if ($posztIds->isEmpty() || $kepIds->isEmpty()) {
            $this->command->error('A poszt-kép kapcsolatok seederhez először futtasd a PosztokSeeder-t és a KepekSeeder-t!');
            return;
        }

        // 3. Hozzuk létre az egyedi párosításokat
        $numberOfConnections = 30;
        $maxPossibleConnections = $posztIds->count() * $kepIds->count();

        if ($numberOfConnections > $maxPossibleConnections) {
            $this->command->warn("A kért {$numberOfConnections} kapcsolat helyett csak {$maxPossibleConnections} egyedi párosítás lehetséges. Ekkorát hozunk létre.");
            $numberOfConnections = $maxPossibleConnections;
        }

        // A crossJoin() létrehozza az összes lehetséges (poszt_id, kep_id) párt.
        // A random() kiválaszt belőle a kívánt mennyiséget.
        $uniquePairs = $posztIds->crossJoin($kepIds)->random($numberOfConnections);

        // 4. Hozzuk létre a kapcsolatokat az egyedi párokkal
        foreach ($uniquePairs as $pair) {
            PosztKepek::create([
                'poszt_id' => $pair[0], // A crossJoin tömböt ad vissza: [poszt_id, kep_id]
                'kep_id' => $pair[1],
            ]);
        }

        $this->command->info('PosztKepek tábla sikeresen feltöltve!');
    }
}