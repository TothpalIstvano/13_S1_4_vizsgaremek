<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use App\Models\Posztok;
use App\Models\Felhasznalok;
use App\Models\Kommentek;


/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Kommentek>
 */
class KommentekFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            "komment"=> $this->faker->sentence(2),
            "poszt_id"=> Posztok::pluck('id')->random(),
            "kommentelo"=> Felhasznalok::pluck('id')->random(),
            "elozetes_komment_id"=> null,
        ];
    }
}
