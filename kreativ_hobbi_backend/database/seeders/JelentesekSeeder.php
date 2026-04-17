<?php

namespace Database\Seeders;

use App\Models\Jelentesek;
use Illuminate\Database\Seeder;

class JelentesekSeeder extends Seeder
{
    public function run(): void
    {
        Jelentesek::factory(20)->create();

        Jelentesek::factory(10)
            ->poszt()
            ->create();

        Jelentesek::factory(10)
            ->komment()
            ->create();

        Jelentesek::factory(8)
            ->megoldva()
            ->create();

        Jelentesek::factory(5)
            ->atnezte()
            ->create();

        Jelentesek::factory(4)
            ->elvetve()
            ->create();

        $this->command->info('JelentesekekSeeder: ' . Jelentesek::count() . ' bejelentés létrehozva.');
    }
}