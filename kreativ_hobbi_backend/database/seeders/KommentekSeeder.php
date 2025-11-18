<?php

namespace Database\Seeders;

use App\Models\Kommentek;
use App\Models\Posztok;
use App\Models\Felhasznalok;
use Illuminate\Database\Seeder;

class KommentekSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $szuloKommentek = Kommentek::factory(10)->create();
        foreach ($szuloKommentek as $szuloKomment) {
            Kommentek::factory(rand(0, 3))->create([
                'poszt_id' => $szuloKomment->poszt_id,
                'elozetes_komment_id' => $szuloKomment->id,
                'kommentelo' => Felhasznalok::pluck('id')->random(),
            ]);
        }
        $this->command->info('Kommentek table seeded successfully!');
    }
}