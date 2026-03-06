<?php

namespace Database\Seeders;

use App\Models\Kategoriak;
use App\Models\Termekek;
use Illuminate\Database\Seeder;
use Faker\Factory;

class KategoriakSeeder extends Seeder
{
    protected $faker;

    public function __construct()
    {
        $this->faker = Factory::create();
    }

    public function run(): void
    {
        $manualCategories = [
            'Fonalak' => [
                'A fonal',
                'B fonal',
                'C fonal',
                'D fonal',
                'E fonal',
            ],

            'Kötőtűk' => [
                'Egyenes kötőtűk',
                'Körkötőtűk',
            ],

            'Horgolótűk' => [],
            'Hímzőcérna' => [],

            'Kiegészítők' => [
                'Mérőszalagok',
                'Ollók',
                'Bontó olló'
            ],
            'Barkácsolás' => [
                'Kalapács',
                'Csavarhúzó',
                'Fűrész',
                'Fúró'
            ],
            'Kertészkedés' => [
                'Ásó',
                'Lapát',
                'Virágcserép',
                'Metszőolló'
            ]
        ];

        foreach ($manualCategories as $mainCategoryName => $subCategories) {
            $mainCategory = Kategoriak::firstOrCreate(
                ['nev' => $mainCategoryName],
                ['fo_kategoria_id' => null]
            );

            foreach ($subCategories as $subCategoryName) {
                Kategoriak::firstOrCreate(
                    ['nev' => $subCategoryName],
                    ['fo_kategoria_id' => $mainCategory->id]
                );
            }
        }

        $aFonalCategory = Kategoriak::where('nev', 'A fonal')->first();
        if ($aFonalCategory && Termekek::where('kategoria_id', $aFonalCategory->id)->count() === 0) {
            Termekek::factory()->create([
                'nev' => 'Prémium gyapjú fonal',
                'leiras' => 'Kiváló minőségű prémium gyapjú fonal kézzel készítéshez.',
                'ar' => 2500,
                'darab' => 150,
                'kategoria_id' => $aFonalCategory->id,
                'fo_kep_id' => $this->faker->numberBetween(14, 30),
            ]);
        }

        $this->command->info('Kategóriák sikeresen seedelve!');
    }
}