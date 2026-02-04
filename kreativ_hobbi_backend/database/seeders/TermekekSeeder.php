<?php

namespace Database\Seeders;

use App\Models\Termekek;
use App\Models\Kategoriak;
use Illuminate\Database\Seeder;

class TermekekSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Get the fonal subcategories
        $fonalakCategory = Kategoriak::where('nev', 'Fonalak')->first();
        $fonalSubcategories = Kategoriak::where('fo_kategoria_id', $fonalakCategory->id)->get();

        // Ensure at least 5 products are in fonal categories (one in each subcategory)
        foreach ($fonalSubcategories as $index => $subcategory) {
            Termekek::factory()->create([
                'nev' => match ($index) {
                    0 => 'Prémium A fonal - Piros',
                    1 => 'Prémium B fonal - Kék',
                    2 => 'Prémium C fonal - Zöld',
                    3 => 'Prémium D fonal - Sárga',
                    4 => 'Prémium E fonal - Fehér',
                    default => 'Prémium fonal',
                },
                'leiras' => 'Kiváló minőségű ' . $subcategory->nev . ' kézzel készítéshez.',
                'ar' => rand(2000, 4500),
                'darab' => rand(100, 250),
                'meter' => rand(90, 200),
                'kategoria_id' => $subcategory->id,
            ]);
        }

        // Create remaining random products
        $remainingCount = 31 - $fonalSubcategories->count();
        Termekek::factory()->count($remainingCount)->create();

        $this->command->info('Termekek table seeded successfully!');
        $this->command->info($fonalSubcategories->count() . ' termék létrehozva a fonal kategóriákban.');
    }
}
