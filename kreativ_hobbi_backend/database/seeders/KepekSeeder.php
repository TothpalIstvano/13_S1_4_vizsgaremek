<?php

namespace Database\Seeders;

// ADD THIS LINE: Import the Kepek model
use App\Models\Kepek;

use Illuminate\Database\Seeder;

class KepekSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create a pool of 50 profile pictures to be used by users.
        Kepek::factory(50)->create();

        $this->command->info('Kep table seeded with 50 images!');
    }
}