<?php

namespace Database\Seeders;

// ADD THESE LINES: Import the necessary models
use App\Models\Felhasznalo;
use App\Models\Kep;

use Illuminate\Database\Seeder;

class FelhasznaloSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Ensure there is at least one profile picture to assign
        if (Kep::count() === 0) {
            $this->command->error('Kep table is empty! Please run KepSeeder first.');
            return;
        }

        // Create a specific, active user for easy login
        // Email: test@example.com
        // Password: password
        Felhasznalo::factory()->create([
            'felhasz_nev' => 'Teszt Felhasználó',
            'email' => 'test@example.com',
            'statusz' => 'aktív',
        ]);

        // Create 20 random users
        Felhasznalo::factory(20)->create();

        $this->command->info('Felhasznalok table seeded successfully!');
    }
}