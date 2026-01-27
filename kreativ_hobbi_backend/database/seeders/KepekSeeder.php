<?php

namespace Database\Seeders;

// ADD THIS LINE: Import the Kepek model
use App\Models\Kepek;

use Illuminate\Database\Seeder;
use Psy\Readline\Hoa\Console;

class KepekSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {

        $mappak = ['profilKepek','blog','termekKepek']; //kepek mappa nevei
        $elnevezesek = ['kep','post','item']; //kepek mappa elnevezései
        $maphosszok = [3,10,17]; //kepek mappa hosszai az adatbazisban induláskor
        $baseUrl = 'https://localhost:8000/storage/'; // Laravel storage URL

        for ($index = 0; $index < count($mappak); $index++) {
            for ($i = 1; $i <= $maphosszok[$index]; $i++) {
                if ($i == 1) {
                    $image = [
                        'url_Link' => $baseUrl . $mappak[$index] . '/' . 'default' . '.jpg',
                        'alt_Szoveg' => 'Image ' . $i . ' in ' . $mappak[$index],
                        'leiras' => 'Description of image ' . $i . ' in ' . $mappak[$index]
                    ];
                }
                else{
                    $image = [
                        'url_Link' => $baseUrl . $mappak[$index] . '/' . $elnevezesek[$index].'_'. $i . '.jpg',
                        'alt_Szoveg' => 'Image ' . $i . ' in ' . $mappak[$index],
                        'leiras' => 'Description of image ' . $i . ' in ' . $mappak[$index]
                    ];
                    
                }
                Kepek::create($image);
            }

        }

        Kepek::factory(100)->create();

        $this->command->info('Kep table seeded with 20 images!');
    }
}