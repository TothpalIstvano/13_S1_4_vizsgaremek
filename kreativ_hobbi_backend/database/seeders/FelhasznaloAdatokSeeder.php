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
                'telefonszam' => '+36304627699',
                'kartyaszam' => encrypt('1111222233334444'),
                'kartya_nev' => 'Test Felhasznalo',
                'kartya_honap' => 1,
                'kartya_ev' => 2024,
            ]
        );
        FelhasznaloAdatok::factory()->create(
            [
                'felhasznalo_id' => 2,
                'szerepkor' => 'moderator',
                'vezeteknev' => 'Kovács',
                'keresztnev' => 'Edit',
                'varos' => 2,
                'utca' => 'Idk Street',
                'hazszam' => 5,
                'emeletAjto' => '1/A',
                'telefonszam' => '+36201578456',
                'kartyaszam' => encrypt('1111222253334444'),
            ]
        );
        FelhasznaloAdatok::factory()->create(
            [
                'felhasznalo_id' => 3,
                'szerepkor' => 'moderator',
                'vezeteknev' => 'Tóthpal',
                'keresztnev' => 'István',
                'varos' => 2,
                'utca' => 'Idk Street',
                'hazszam' => 5,
                'emeletAjto' => '1/A',
                'telefonszam' => '+36709512357',
                'kartyaszam' => encrypt('1111222253334444'),
            ]
        );

        FelhasznaloAdatok::factory()->count(30)->create();
        $this->command->info('FelhasznaloAdatok table seeded successfully!');
    }
}
