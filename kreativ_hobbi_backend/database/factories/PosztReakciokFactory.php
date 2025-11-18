<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use App\Models\Posztok;
use App\Models\Felhasznalok;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\PosztReakciok>
 */
class PosztReakciokFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            "poszt_id" => Posztok::pluck('id')->random(),
            "felhasznalo_id" => Felhasznalok::pluck('id')->random(),
            "reakcio" => $this->faker->randomElement(['like', 'dislike']),
        ];
    }
}
