<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Cimkek;
class CimkekSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        Cimkek::factory(20)->create();
        $this->command->info('Cimkek table seeded successfully!');
    }
}
