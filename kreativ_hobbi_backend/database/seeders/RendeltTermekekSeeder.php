<?php

namespace Database\Seeders;

use App\Models\RendeltTermekek;
use Illuminate\Database\Seeder;

class RendeltTermekekSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        RendeltTermekek::factory()->count(30)->create();
        $this->command->info('RendeltTermekek table seeded successfully!');
    }
}
