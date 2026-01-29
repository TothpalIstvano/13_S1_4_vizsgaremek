<?php

namespace Database\Seeders;

use App\Models\TermekSzinek;
use App\Models\Termekek;
use App\Models\Szinek;
use Illuminate\Database\Seeder;


class TermekSzinekSeeder extends Seeder
{
    /*
     * Run the database seeds.
     */
    public function run(): void
    {
        // 2. Szerezzük be a szükséges ID-ket
        $termekIds = Termekek::pluck('id')->toArray();
        $szinIds = Szinek::pluck('id')->toArray();

        if (empty($termekIds) || empty($szinIds)) {
            $this->command->error('A termék-szín kapcsolatok seederhez először futtasd a TermekekSeeder-t és a SzinekSeeder-t!');
            return;
        }

        // 3. Biztosítsd, hogy minden termék legalább egy színnel rendelkezik
        foreach ($termekIds as $termekId) {
            $randomSzinId = $szinIds[array_rand($szinIds)];
            TermekSzinek::create([
                'termek_id' => $termekId,
                'szin_id' => $randomSzinId,
            ]);
        }

        // 4. Opcionálisan további véletlen párosítások hozzáadása
        $additionalConnections = 20; // Még ennyi további véletlen párosítás
        for ($i = 0; $i < $additionalConnections; $i++) {
            $randomTermekId = $termekIds[array_rand($termekIds)];
            $randomSzinId = $szinIds[array_rand($szinIds)];
            
            // Ellenőrzés: ha már létezik, ne adjunk hozzá duplikátumot
            if (!TermekSzinek::where('termek_id', $randomTermekId)
                                ->where('szin_id', $randomSzinId)
                                ->exists()) {
                TermekSzinek::create([
                    'termek_id' => $randomTermekId,
                    'szin_id' => $randomSzinId,
                ]);
            }
        }

        $this->command->info('TermekSzinek tábla sikeresen feltöltve! Minden termék legalább egy szinnel rendelkezik.');
    }
}
