<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use App\Models\Posztok;
use App\Models\Kepek;
/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\PosztKepek>
 */
class PosztKepekFactory extends Factory
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
            'kep_id' => $this->faker->unique()->numberBetween(30, 61),
        ];
    }
}
