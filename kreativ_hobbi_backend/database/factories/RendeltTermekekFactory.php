<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use App\Models\Rendelesek;
use App\Models\Termekek;
use App\Models\TermekSzinek;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\RendeltTermekek>
 */
class RendeltTermekekFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            "rendeles_id"=> Rendelesek::pluck('id')->random(),
            'termek_id'=> Termekek::pluck('id')->random(),
            'szin_id'=> TermekSzinek::pluck('szin_id')->random(),
            'mennyiseg'=> $this->faker->numberBetween(1,5),
            'egysegar'=> $this->faker->numberBetween(1200,1500),
        ];
    }
}
