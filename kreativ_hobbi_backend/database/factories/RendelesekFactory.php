<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use App\Models\Felhasznalok;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Rendelesek>
 */
class RendelesekFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            "felhasznalo_id"=> Felhasznalok::pluck("id")->random(),
            "statusz"=>$this->faker->randomElement(["függőben","szállítás alatt","teljesítve","törölve"]),
            "osszeg"=>rand(1000, 5000),
            "rendeles_datuma"=>$this->faker->dateTime(),
        ];
    }
}
