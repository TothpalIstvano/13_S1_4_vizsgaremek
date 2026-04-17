<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class <?php

namespace Database\Seeders;

use App\Models\Jelentes;
use Illuminate\Database\Seeder;

class JelentesekSeeder extends Seeder
{
    public function run(): void
    {
        // 20 db függőben lévő vegyes bejelentés
        Jelentes::factory(20)->create();

        // 10 db poszt-bejelentés (csak posztokhoz)
        Jelentes::factory(10)
            ->poszt()
            ->create();

        // 10 db komment-bejelentés (csak kommentekhez)
        Jelentes::factory(10)
            ->komment()
            ->create();

        // 8 db már megoldott eset
        Jelentes::factory(8)
            ->megoldva()
            ->create();

        // 5 db megnézett, de még nem döntött
        Jelentes::factory(5)
            ->atnezte()
            ->create();

        // 4 db elvetett
        Jelentes::factory(4)
            ->elvetve()
            ->create();

        $this->command->info('JelentesekSeeder: ' . Jelentes::count() . ' bejelentés létrehozva.');
    }
} extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        //
    }
}
