<?php

namespace Database\Seeders;

// ADD THIS LINE: Import the Kepek model
use App\Models\Kepek;

use Illuminate\Database\Seeder;
use Psy\Readline\Hoa\Console;
use Illuminate\Support\Facades\Storage;

class KepekSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $mappak = ['profilKepek', 'blog', 'termekKepek', 'hatterKepek']; //kepek mappa nevei
        $elnevezesek = ['kep', 'placeholder', 'item', 'hatter']; //kepek mappa elnevezései
        $maphosszok = [3, 10, 17, 4]; //kepek mappa hosszai az adatbazisban induláskor
        $baseUrl = 'http://127.0.0.1:8000/storage/'; // Laravel storage URL

        for ($index = 0; $index < count($mappak); $index++) {
            $folder = $mappak[$index];
            $folderPath = 'public/' . $folder; // Storage disk path

            // Get all files in the current folder and build a map of base name => extension
            $files = Storage::disk('public')->files($folder);
            $extensionMap = [];

            foreach ($files as $file) {
                $filename = pathinfo($file, PATHINFO_FILENAME); // e.g. 'default', 'kep_2'
                $extension = pathinfo($file, PATHINFO_EXTENSION); // e.g. 'jpg', 'png'
                $extensionMap[$filename] = $extension; // last occurrence wins if duplicate base names exist
            }

            for ($i = 1; $i <= $maphosszok[$index]; $i++) {
                // Determine the base filename (without extension)
                if ($i == 1) {
                    $baseName = 'default';
                } else {
                    $baseName = $elnevezesek[$index] . '_' . $i;
                }

                // Get the extension from the map, fallback to 'jpg' if not found
                $extension = $extensionMap[$baseName] ?? 'jpg';

                $image = [
                    'url_Link' => $baseUrl . $folder . '/' . $baseName . '.' . $extension,
                    'alt_Szoveg' => 'Image ' . $i . ' in ' . $folder,
                    'leiras' => 'Description of image ' . $i . ' in ' . $folder,
                ];

                Kepek::create($image);
            }
        }

        Kepek::factory(100)->create();
        $this->command->info('Kepek tábla sikeresen feltöltve!');
    }
}