<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Kepek>
 */
class KepekFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        // Get a base URL from Faker
        $baseUrl = 'http://localhost:8000/storage/';
        return [
            // Append a unique random number to the URL to guarantee uniqueness
            'url_Link' => $baseUrl.fake()->unique()->word().'_'.fake()->randomNumber(2).'.jpg',
            'alt_Szoveg' => fake()->sentence(),
            'leiras' => fake()->sentence(),
        ];
    }
}
