<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use App\Models\Felhasznalok;
use App\Models\Termekek;
/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Kedvencek>
 */
class KedvencekFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'felhasznalo_id' => Felhasznalok::pluck('id')->random(),
            'termek_id' => Termekek::pluck('id')->random(),
        ];
    }
}
