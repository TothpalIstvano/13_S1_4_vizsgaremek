<?php

namespace Database\Seeders;

use App\Models\Szinek;
use Illuminate\Database\Seeder;

class SzinekSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Szinek::factory()->count(100)->create();
        $this->command->info('Szinek table seeded successfully!');
    }
}
