<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use App\Models\Cimkek;
use App\Models\Posztok;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\PosztCimkek>
 */
class PosztCimkekFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'poszt_id' => Posztok::pluck('id')->unique()->random(),
            'cimke_id' => Cimkek::pluck('id')->unique()->random(),
        ];
    }
}
