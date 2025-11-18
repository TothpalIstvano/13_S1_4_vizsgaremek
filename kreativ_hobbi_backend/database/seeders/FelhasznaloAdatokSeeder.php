<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\FelhasznaloAdatok;

class FelhasznaloAdatokSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
       FelhasznaloAdatok::factory()->count(100)->create();
        $this->command->info('FelhasznaloAdatok table seeded successfully!');
    }
}
