<?php

namespace Database\Seeders;

use App\Models\Posztok;
use Illuminate\Database\Seeder;

class PosztokSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Posztok::factory(30)->create();
        $this->command->info('Posztok table seeded successfully!');
    }
}
