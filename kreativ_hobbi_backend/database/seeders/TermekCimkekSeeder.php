<?php

namespace Database\Seeders;

use App\Models\TermekCimkek;
use App\Models\Termekek; // Feltételezett modellnév
use App\Models\Cimkek;    // Feltételezett modellnév
use Illuminate\Database\Seeder;


class TermekCimkekSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        
        // 2. Szerezzük be a szükséges ID-ket
        $termekIds = Termekek::pluck('id');
        $cimkeIds = Cimkek::pluck('id');

        if ($termekIds->isEmpty() || $cimkeIds->isEmpty()) {
            $this->command->error('A termék-kép kapcsolatok seederhez először futtasd a TermekekSeeder-t és a KepekSeeder-t!');
            return;
        }

        // 3. Hozzuk létre az egyedi párosításokat
        $numberOfConnections = 30; // Vagy amennyit szeretnél
        $maxPossibleConnections = $termekIds->count() * $cimkeIds->count();

        if ($numberOfConnections > $maxPossibleConnections) {
            $this->command->warn("A kért {$numberOfConnections} kapcsolat helyett csak {$maxPossibleConnections} egyedi párosítás lehetséges. Ekkorát hozunk létre.");
            $numberOfConnections = $maxPossibleConnections;
        }

        // A crossJoin() létrehozza az összes lehetséges (termek_id, kep_id) párt.
        // A random() kiválaszt belőle a kívánt mennyiséget.
        $uniquePairs = $termekIds->crossJoin($cimkeIds)->random($numberOfConnections);

        // 4. Hozzuk létre a kapcsolatokat az egyedi párokkal
        foreach ($uniquePairs as $pair) {
            TermekCimkek::create([
                'termek_id' => $pair[0], // A crossJoin tömböt ad vissza: [termek_id, kep_id]
                'cimke_id' => $pair[1],
            ]);
        }

        $this->command->info('TermekekKepek tábla sikeresen feltöltve!');
    }
}