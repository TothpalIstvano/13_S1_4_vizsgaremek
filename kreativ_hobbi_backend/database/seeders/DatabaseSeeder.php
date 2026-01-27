<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->call([
            // 1. Képek seedelése mivel a felhasználók függnek tőle
            KepekSeeder::class,

            // 2. Felhasználók seedelése.
            FelhasznalokSeeder::class,

            // 3. Városok seedelése.
            VarosokSeeder::class,

            // 4. Felhasználói adatok seedelése.
            FelhasznaloAdatokSeeder::class,
            
            // 5. Kategóriák seedelése.
            KategoriakSeeder::class,
            
            // 6. Címkék seedelése.
            CimkekSeeder::class,

            // 7. Szinek seedelése.
            SzinekSeeder::class,

            // 8. Posztok seedelése.
            PosztokSeeder::class,

            // 9. PosztKépek seedelése.
            PosztKepekSeeder::class,

            // 10. PosztCímkék seedelése.
            PosztCimkekSeeder::class,

            // 11. Kommentek seedelése.
            KommentekSeeder::class,

            // 12. Posztok rendelések seedelése.
            PosztReakciokSeeder::class,

            // 13. Termékek adatok seedelése.
            TermekekSeeder::class,

            // 14. Termék címkék adatok seedelése.
            TermekCimkekSeeder::class,

            // 15. Termék színek adatok seedelése.
            TermekSzinekSeeder::class,

            // 16. Termék képek adatok seedelése.
            TermekKepekSeeder::class,

            // 17. Kedvencek seedelése.
            KedvencekSeeder::class,

            // 18. TermekSzinek seedelése.
            RendelesekSeeder::class,

            // 19. RendeltTermekek seedelése.
            RendeltTermekekSeeder::class,
        ]);
    }
}
