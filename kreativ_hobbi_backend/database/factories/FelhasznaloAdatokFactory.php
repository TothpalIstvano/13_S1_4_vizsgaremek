<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\FelhasznaloAdatok>
 */
class FelhasznaloAdatokFactory extends Factory
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
            'felhasznalo_id' => \App\Models\Felhasznalok::factory(),
            'vezeteknev' => $this->faker->lastName(),
            'keresztnev' => $this->faker->firstName(),
            'varos' => \App\Models\Varosok::factory(),
            'utca' => $this->faker->streetName(),
            'hazszam' => $this->faker->buildingNumber(),
            'emeletAjto' => $this->faker->bothify('##??'),
            'telefonszam' => $this->faker->phoneNumber(),
            'kartyaszam' => str_replace([' ', '-'], '', $this->faker->creditCardNumber()),
        ];
    }
}

