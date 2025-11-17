<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // User::factory(10)->create();

        User::factory()->create([
            'name' => 'Test User',
            'email' => 'test@example.com',
        ]);

        $this->call([
            // 1. Képek seedelése mivel a felhasználók függnek tőle
            KepekSeeder::class,

            // 2. Felhasználók seedelése.
            FelhasznalokSeeder::class,

            // 3. Városok seedelése.
            VarosokSeeder::class,

            // 4. Felhasználói adatok seedelése.
            FelhasznaloAdatokSeeder::class,
        ]);
    }
}
