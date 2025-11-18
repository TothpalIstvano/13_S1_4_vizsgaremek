<?php

namespace Database\Seeders;

use App\Models\TermekKepek;
use App\Models\Termekek; // Feltételezett modellnév
use App\Models\Kepek;    // Feltételezett modellnév
use Illuminate\Database\Seeder;


class TermekKepekSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        
        // 2. Szerezzük be a szükséges ID-ket
        $termekIds = Termekek::pluck('id');
        $kepIds = Kepek::pluck('id');

        if ($termekIds->isEmpty() || $kepIds->isEmpty()) {
            $this->command->error('A termék-kép kapcsolatok seederhez először futtasd a TermekekSeeder-t és a KepekSeeder-t!');
            return;
        }

        // 3. Hozzuk létre az egyedi párosításokat
        $numberOfConnections = 30; // Vagy amennyit szeretnél
        $maxPossibleConnections = $termekIds->count() * $kepIds->count();

        if ($numberOfConnections > $maxPossibleConnections) {
            $this->command->warn("A kért {$numberOfConnections} kapcsolat helyett csak {$maxPossibleConnections} egyedi párosítás lehetséges. Ekkorát hozunk létre.");
            $numberOfConnections = $maxPossibleConnections;
        }

        // A crossJoin() létrehozza az összes lehetséges (termek_id, kep_id) párt.
        // A random() kiválaszt belőle a kívánt mennyiséget.
        $uniquePairs = $termekIds->crossJoin($kepIds)->random($numberOfConnections);

        // 4. Hozzuk létre a kapcsolatokat az egyedi párokkal
        foreach ($uniquePairs as $index => $pair) {
            TermekKepek::create([
                'termek_id' => $pair[0], // A crossJoin tömböt ad vissza: [termek_id, kep_id]
                'kep_id' => $pair[1],
                'rendezes' => $index + 1, // Egy egyszerű rendezés, 1-től kezdve
            ]);
        }

        $this->command->info('TermekekKepek tábla sikeresen feltöltve!');
    }
}