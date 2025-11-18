<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\PosztKepek;

class PosztKepekSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        PosztKepek::factory(40)->create();
        $this->command->info('PosztKepek table seeded successfully!');
    }
}
