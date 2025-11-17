<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class FelhasznaloAdatokSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        \App\Models\FelhasznaloAdatok::factory()->count(50)->create();
    }
}
