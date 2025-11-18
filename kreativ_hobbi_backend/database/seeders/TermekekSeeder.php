<?php

namespace Database\Seeders;

use App\Models\Termekek;
use Illuminate\Database\Seeder;

class TermekekSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Termekek::factory()->count(31)->create();
        $this->command->info('Termekek table seeded successfully!');
    }
}
