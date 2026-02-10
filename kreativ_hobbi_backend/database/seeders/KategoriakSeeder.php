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

    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Step 1: Create fixed "Fonalak" main category
        $fonalakCategory = Kategoriak::firstOrCreate(
            ['nev' => 'Fonalak'],
            ['fo_kategoria_id' => null]
        );

        // Step 2: Create fixed subcategories under "Fonalak"
        $fonalSubcategories = [
            'A fonal',
            'B fonal',
            'C fonal',
            'D fonal',
            'E fonal'
        ];

        $createdSubcategories = [];
        foreach ($fonalSubcategories as $subcategoryName) {
            $subcategory = Kategoriak::firstOrCreate(
                ['nev' => $subcategoryName],
                ['fo_kategoria_id' => $fonalakCategory->id]
            );
            $createdSubcategories[] = $subcategory;
        }

        // Step 3: Create other random parent categories (9 instead of 10 since we already have "Fonalak")
        $parentCategories = Kategoriak::factory(18)->create(['fo_kategoria_id' => null]);

        // Step 4: Create child categories for each parent (including "Fonalak")
        $allParents = $parentCategories->push($fonalakCategory);

        foreach ($allParents as $parent) {
            // Don't create random children for "Fonalak" since we already have fixed ones
            if ($parent->id !== $fonalakCategory->id) {
                Kategoriak::factory(rand(1, 5))->create(['fo_kategoria_id' => $parent->id]);
            }
        }

        // Step 5: Ensure at least one product is created in one of the fixed fonal categories
        if (Termekek::whereIn('kategoria_id', array_column($createdSubcategories, 'id'))->count() === 0) {
            // Create at least one product in "A fonal" category
            $aFonalCategory = Kategoriak::where('nev', 'A fonal')->first();

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
        $this->command->info('Fix "Fonalak" kategória és alkategóriái létrehozva.');
        $this->command->info('Legalább egy termék létrehozva az "A fonal" kategóriában.');
    }
}