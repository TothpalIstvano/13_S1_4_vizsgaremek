<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use App\Models\Kategoriak;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Termekek>
 */
class TermekekFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            "nev" => $this->faker->words(rand(1, 3), true),
            "leiras" => $this->faker->sentence(rand(50, 80)),
            "ar" => rand(1000, 5000),
            "darab" => $this->faker->numberBetween(201, 300),
            "meter" => rand(min: 1000, max: 5000),
            "kategoria_id" => Kategoriak::pluck('id')->random(),
            'fo_kep_id' => $this->faker->numberBetween(14, 30),
        ];
    }
}
