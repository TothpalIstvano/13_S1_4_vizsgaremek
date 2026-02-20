<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\FelhasznaloAdatok;

class FelhasznaloAdatokSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        FelhasznaloAdatok::factory()->create(
            [
                'felhasznalo_id' => 1,
                'szerepkor' => 'admin',
                'vezeteknev' => 'Test',
                'keresztnev' => 'Felhasznalo',
                'varos' => 1,
                'utca' => 'Admin Street',
                'hazszam' => 1,
                'emeletAjto' => '1/A',
                'telefonszam' => '1234567890',
                'kartyaszam' => '1111222233334444',
            ]
        );
        FelhasznaloAdatok::factory()->create(
            [
                'felhasznalo_id' => 2,
                'szerepkor' => 'admin',
                'vezeteknev' => 'Tóthpál',
                'keresztnev' => 'István',
                'varos' => 2,
                'utca' => 'Idk Street',
                'hazszam' => 5,
                'emeletAjto' => '1/A',
                'telefonszam' => '9876543210',
                'kartyaszam' => '1111222253334444',
            ]
        );

        FelhasznaloAdatok::factory()->count(30)->create();
        $this->command->info('FelhasznaloAdatok table seeded successfully!');
    }
}
