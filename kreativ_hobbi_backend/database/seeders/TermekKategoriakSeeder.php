<?php

namespace Database\Seeders;

use App\Models\Kategoriak;
use App\Models\TermekKategoriak;
use App\Models\Termekek; // Feltételezett modellnév
use Illuminate\Database\Seeder;


class TermekKategoriakSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        
        // 2. Szerezzük be a szükséges ID-ket
        $termekIds = Termekek::pluck('id');
        $kategoriaIds = Kategoriak::pluck('id');

        if ($termekIds->isEmpty() || $kategoriaIds->isEmpty()) {
            $this->command->error('A termék-kategória kapcsolatok seederhez először futtasd a TermekekSeeder-t és a KategoriakSeeder-t!');
            return;
        }

        // 3. Hozzuk létre az egyedi párosításokat
        $numberOfConnections = 30; // Vagy amennyit szeretnél
        $maxPossibleConnections = $termekIds->count() * $kategoriaIds->count();

        if ($numberOfConnections > $maxPossibleConnections) {
            $this->command->warn("A kért {$numberOfConnections} kapcsolat helyett csak {$maxPossibleConnections} egyedi párosítás lehetséges. Ekkorát hozunk létre.");
            $numberOfConnections = $maxPossibleConnections;
        }

        // A crossJoin() létrehozza az összes lehetséges (termek_id, kategoria_id) párt.
        // A random() kiválaszt belőle a kívánt mennyiséget.
        $uniquePairs = $termekIds->crossJoin($kategoriaIds)->random($numberOfConnections);

        // 4. Hozzuk létre a kapcsolatokat az egyedi párokkal
        foreach ($uniquePairs as $pair) {
            TermekKategoriak::create([
                'termek_id' => $pair[0], // A crossJoin tömböt ad vissza: [termek_id, kategoria_id]
                'kategoria_id' => $pair[1],
            ]);
        }

        $this->command->info('TermekekKategoriak tábla sikeresen feltöltve!');
    }
}