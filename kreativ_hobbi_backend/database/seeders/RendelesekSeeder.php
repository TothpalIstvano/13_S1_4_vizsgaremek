<?php

namespace Database\Seeders;

use App\Models\Rendelesek;
use Illuminate\Database\Seeder;

class RendelesekSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Rendelesek::factory()->count(30)->create();
        $this->command->info('Rendelesek table seeded successfully!');
    }
}
