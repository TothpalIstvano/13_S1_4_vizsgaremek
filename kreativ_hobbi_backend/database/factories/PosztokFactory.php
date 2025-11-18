<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use App\Models\Felhasznalok;
use App\Models\Kepek;


/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Posztok>
 */
class PosztokFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'cim' => $this->faker->sentence(),
            'kivonat' => $this->faker->sentence(),
            'tartalom' => $this->faker->text(),
            'szerzo_id' => Felhasznalok::pluck('id')->random(),
            'fo_kep_id' => Kepek::pluck('id')->unique()->random(),
            'letrehozas_datuma' => $this->faker->dateTime(),
            'statusz' => $this->faker->randomElement(['piszkozat','közzétett','archivált']),
        ];
    }
}
