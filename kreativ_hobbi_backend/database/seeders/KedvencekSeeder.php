<?php

namespace Database\Seeders;

use App\Models\Kedvencek;
use App\Models\Felhasznalok;
use App\Models\Termekek;
use Illuminate\Database\Seeder;

class KedvencekSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {

        // 2. Szerezzük be a szükséges ID-ket
        $felhasznaloIds = Felhasznalok::pluck('id');
        $termekIds = Termekek::pluck('id');

        if ($felhasznaloIds->isEmpty() || $termekIds->isEmpty()) {
            $this->command->error('A kedvencek seederhez először futtasd a FelhasznalokSeeder-t és a TermekekSeeder-t!');
            return;
        }

        // 3. Hozzuk létre az egyedi párosításokat
        // Tegyük fel, hogy átlagosan minden felhasználónak 10 kedvence van
        $numberOfFavorites = $felhasznaloIds->count() * 10;
        $maxPossibleFavorites = $felhasznaloIds->count() * $termekIds->count();

        if ($numberOfFavorites > $maxPossibleFavorites) {
            $this->command->warn("A kért {$numberOfFavorites} kedvenc helyett csak {$maxPossibleFavorites} egyedi párosítás lehetséges. Ekkorát hozunk létre.");
            $numberOfFavorites = $maxPossibleFavorites;
        }

        // A crossJoin() létrehozza az összes lehetséges (felhasznalo_id, termek_id) párt.
        // A random() kiválaszt belőle a kívánt mennyiséget.
        $uniquePairs = $felhasznaloIds->crossJoin($termekIds)->random($numberOfFavorites);

        // 4. Hozzuk létre a kapcsolatokat az egyedi párokkal
        foreach ($uniquePairs as $pair) {
            Kedvencek::create([
                'felhasznalo_id' => $pair[0], // A crossJoin tömböt ad vissza: [felhasznalo_id, termek_id]
                'termek_id' => $pair[1],
            ]);
        }

        $this->command->info('Kedvencek tábla sikeresen feltöltve!');
    }
}