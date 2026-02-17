<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use App\Models\Felhasznalok;
use App\Models\Varosok;

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
            /*Ha minden felhasználóhoz szeretnénk adatokat létrehozni egyszer:
                foreach (Felhasznalok::pluck('id') as $userId) {
                    if (!FelhasznaloAdatok::where('felhasznalo_id', $userId)->exists()) {
                        FelhasznaloAdatok::factory()->create([
                            'felhasznalo_id' => $userId,
                            // The factory will fill the other fields; override here if needed.
                        ]);
                    }
                }
            */
            // Use the exact column names from the migration
            'felhasznalo_id' => Felhasznalok::factory(),
            'vezeteknev' => $this->faker->lastName(),
            'keresztnev' => $this->faker->firstName(),
            'varos' => Varosok::pluck('id')->random(),
            'utca' => $this->faker->streetName(),
            'hazszam' => $this->faker->buildingNumber(),
            'emeletAjto' => $this->faker->bothify('##??'),
            'telefonszam' => str_replace([' ', '-', '(', ')', '+', '.', '', ','], '', $this->faker->phoneNumber()),
            'kartyaszam' => str_replace([' ', '-'], '', $this->faker->creditCardNumber()),
        ];
    }
}

