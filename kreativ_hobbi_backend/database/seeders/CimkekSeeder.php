<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Cimkek;
class CimkekSeeder extends Seeder
{
    public function run(): void
    {
        $cimkek = [
            ['nev' => 'Horgolás'],
            ['nev' => 'Kötés'],
            ['nev' => 'Hímzés'],
            ['nev' => 'Barkácsolás'],
            ['nev' => 'DIY'],
            ['nev' => 'Lakás'],
            ['nev' => 'Kertészet'],
            ['nev' => 'Virágok']
        ];

        foreach ($cimkek as $cimke) {
            Cimkek::create($cimke);
        }

        Cimkek::factory(10)->create();
        $this->command->info('Cimkek table seeded successfully!');
    }
}
