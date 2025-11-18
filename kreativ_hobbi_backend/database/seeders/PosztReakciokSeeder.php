<?php

namespace Database\Seeders;

use App\Models\PosztReakciok;
use App\Models\Posztok;
use App\Models\Felhasznalok;
use Illuminate\Database\Seeder;


class PosztReakciokSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {

        // 2. Szerezzük be a szükséges ID-ket
        $posztIds = Posztok::pluck('id');
        $felhasznaloIds = Felhasznalok::pluck('id');

        if ($posztIds->isEmpty() || $felhasznaloIds->isEmpty()) {
            $this->command->error('A reakciók seederhez először futtasd a PosztokSeeder-t és a FelhasznalokSeeder-t!');
            return;
        }

        $numberOfReactions = 40;
        $maxPossibleReactions = $posztIds->count() * $felhasznaloIds->count();

        // Ha több reakciót akarunk, mint amennyi egyedi párosítás lehetséges,
        // akkor csak a lehetséges maximumot hozzuk létre.
        if ($numberOfReactions > $maxPossibleReactions) {
            $this->command->warn("A kért {$numberOfReactions} reakció helyett csak {$maxPossibleReactions} egyedi párosítás lehetséges. Ekkorát hozunk létre.");
            $numberOfReactions = $maxPossibleReactions;
        }

        // A crossJoin() létrehozza az összes lehetséges (poszt_id, felhasznalo_id) párt.
        // A random() kiválaszt belőle a kívánt mennyiséget.
        $uniquePairs = $posztIds->crossJoin($felhasznaloIds)->random($numberOfReactions);

        // 4. Hozzuk létre a reakciókat az egyedi párokkal
        foreach ($uniquePairs as $pair) {
            PosztReakciok::factory()->create([
                'poszt_id' => $pair[0], // A crossJoin tömböt ad vissza: [poszt_id, felhasznalo_id]
                'felhasznalo_id' => $pair[1],
            ]);
        }

        $this->command->info('PosztReakciok tábla sikeresen feltöltve!');
    }
}