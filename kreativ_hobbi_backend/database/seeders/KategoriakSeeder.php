<?php

namespace Database\Seeders;

use App\Models\Kategoriak;
use Illuminate\Database\Seeder;

class KategoriakSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {

        $parentCategories = Kategoriak::factory(10)->create(['fo_kategoria_id' => null]);

        // Step 2: Create child categories for each parent
        // We loop through the parents we just created
        foreach ($parentCategories as $parent) {
            // For each parent, create a few child categories.
            // We use the parent's ID for the fo_kategoria_id.
            Kategoriak::factory(rand(0, 4))->create(['fo_kategoria_id' => $parent->id]);
        }

        $this->command->info('Kategóriák sikeresen seedelve!');
    }
}