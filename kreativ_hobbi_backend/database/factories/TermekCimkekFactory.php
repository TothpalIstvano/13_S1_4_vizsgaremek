<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use App\Models\Termekek;
use App\Models\Cimkek;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\TermekKepek>
 */
class TermekCimkekFactory extends Factory
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
            'cimke_id'=> Cimkek::pluck('id')->random(),
        ];
    }
}
