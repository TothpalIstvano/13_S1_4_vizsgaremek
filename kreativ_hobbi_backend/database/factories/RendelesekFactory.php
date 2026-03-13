<?php

namespace Database\Factories;

use App\Models\Varosok;
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
        $varos = Varosok::inRandomOrder()->first();

        return [
            "felhasznalo_id"=> Felhasznalok::pluck("id")->random(),
            "statusz"=>$this->faker->randomElement(["függőben","szállítás alatt","teljesítve","törölve"]),
            "osszeg"=>rand(1000, 5000),
            "rendeles_datuma"=>$this->faker->dateTime(),
            'szallitasi_nev'=>$this->faker->name(),
            'szallitasi_email'=>$this->faker->email(),
            'szallitasi_telefon'=>$this->faker->phoneNumber(),
            'szallitasi_utca'=>$this->faker->streetName(),
            'szallitasi_hazszam'=>$this->faker->buildingNumber(),
            'szallitasi_emeletAjto'=>$this->faker->bothify('##??'),
            'szallitasi_varos_id'=>$varos->id,
            'szallitasi_varos_nev'=>$varos->varos_nev
        ];
    }
}
