<?php

namespace Database\Seeders;

//use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

use App\Models\Varosok;

class VarosokSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Varosok::factory()->count(20)->create();
        $this->command->info('Varosok table seeded successfully!');
    }
}
