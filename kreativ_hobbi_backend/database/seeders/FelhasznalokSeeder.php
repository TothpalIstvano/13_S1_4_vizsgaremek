<?php

namespace Database\Seeders;

// ADD THESE LINES: Import the necessary models
use App\Models\Felhasznalok;
use App\Models\Kepek;

use Illuminate\Database\Seeder;

class FelhasznalokSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Ensure there is at least one profile picture to assign
        if (Kepek::count() === 0) {
            $this->command->error('Kep table is empty! Please run KepekSeeder first.');
            return;
        }

        // Create a specific, active user for easy login
        // Email: test@example.com
        // Password: password
        Felhasznalok::factory()->create([
            'felhasz_nev' => 'Teszt Felhasználó',
            'email' => 'test@example.com',
            'jelszo'=> 'Alma12345678.',
            'profilKep_id'=> 2,
            'statusz' => 'aktív',
            'letrehozas_Datuma' => '2023-01-01',
            'utolso_Belepes' => now(),
        ]);

        Felhasznalok::factory()->create([
            'felhasz_nev' => 'Tóthpál István',
            'email' => 'tothpal.istvan@diak.szbi-pg.hu',
            'jelszo'=> 'Alma12345678.',
            'profilKep_id'=> 2,
            'statusz' => 'aktív',
            'letrehozas_Datuma' => '2026-02-20',
            'utolso_Belepes' => now(),
        ]);

        // Create 20 random users
        Felhasznalok::factory()->count(30)->create();
        

        $this->command->info('Felhasznalok table seeded successfully!');
    }
}