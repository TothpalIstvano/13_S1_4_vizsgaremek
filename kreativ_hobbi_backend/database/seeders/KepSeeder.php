<?php

namespace Database\Seeders;

// ADD THIS LINE: Import the Kep model
use App\Models\Kep;

use Illuminate\Database\Seeder;

class KepSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create a pool of 50 profile pictures to be used by users.
        Kep::factory(50)->create();

        $this->command->info('Kep table seeded with 50 images!');
    }
}