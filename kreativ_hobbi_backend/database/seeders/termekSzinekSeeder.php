<?php

namespace Database\Seeders;

use App\Models\termekSzinek; 
use App\Models\Termekek;
use App\Models\Szinek;
use Illuminate\Database\Seeder;


class TermekSzinekSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // 2. Szerezzük be a szükséges ID-ket
        $termekIds = Termekek::pluck('id');
        $szinIds = Szinek::pluck('id');

        if ($termekIds->isEmpty() || $szinIds->isEmpty()) {
            $this->command->error('A termék-szín kapcsolatok seederhez először futtasd a TermekekSeeder-t és a SzinekSeeder-t!');
            return;
        }

        // 3. Hozzuk létre az egyedi párosításokat
        $numberOfConnections = 30; // Vagy amennyit szeretnél
        $maxPossibleConnections = $termekIds->count() * $szinIds->count();

        if ($numberOfConnections > $maxPossibleConnections) {
            $this->command->warn("A kért {$numberOfConnections} kapcsolat helyett csak {$maxPossibleConnections} egyedi párosítás lehetséges. Ekkorát hozunk létre.");
            $numberOfConnections = $maxPossibleConnections;
        }

        // A crossJoin() létrehozza az összes lehetséges (termek_id, szin_id) párt.
        // A random() kiválaszt belőle a kívánt mennyiséget.
        $uniquePairs = $termekIds->crossJoin($szinIds)->random($numberOfConnections);

        // 4. Hozzuk létre a kapcsolatokat az egyedi párokkal
        foreach ($uniquePairs as $pair) {
            termekSzinek::create([
                'termek_id' => $pair[0], // A crossJoin tömböt ad vissza: [termek_id, szin_id]
                'szin_id' => $pair[1],
            ]);
        }

        $this->command->info('TermekSzinek tábla sikeresen feltöltve!');
    }
}