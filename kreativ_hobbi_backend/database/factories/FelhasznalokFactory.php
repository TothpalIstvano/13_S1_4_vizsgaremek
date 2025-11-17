<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Felhasznalok>
 */
class FelhasznalokFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            // Use the exact column names from the migration
            'felhasz_nev' => fake()->name(),
            'email' => fake()->unique()->safeEmail(),
            'jelszo' => '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', // password
            // Get a random ID from the existing 'kepek' table
            'profilKep_id' => \App\Models\Kepek::inRandomOrder()->first()->id,
            // Randomly pick from the enum values
            'statusz' => fake()->randomElement(['aktív', 'inaktív']),
            // Set a creation date within the last year
            'letrehozas_Datuma' => fake()->dateTimeThisYear(),
        ];
    }
}
