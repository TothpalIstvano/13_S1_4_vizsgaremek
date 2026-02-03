<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use App\Models\Szinek;
use App\Models\Termekek;

/*
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\termekSzinek>
 */
class TermekSzinekFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            "termek_id"=> Termekek::pluck('id')->random(),
            'szin_id'=> Szinek::pluck('id')->random(),
        ];
    }
}
