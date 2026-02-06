<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use App\Models\Termekek;
use App\Models\Kategoriak;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\TermekKategoriak>
 */
class TermekKategoriakFactory extends Factory
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
            'kategoria_id'=> Kategoriak::pluck('id')->random(),
        ];
    }
}
