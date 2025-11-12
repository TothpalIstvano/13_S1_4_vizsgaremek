<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Kep>
 */
class KepFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        // Get a base URL from Faker
        $baseUrl = fake()->imageUrl(400, 400, 'people');

        return [
            // Append a unique random number to the URL to guarantee uniqueness
            'url_Link' => $baseUrl . '?v=' . fake()->unique()->randomNumber(5),
        ];
    }
}
