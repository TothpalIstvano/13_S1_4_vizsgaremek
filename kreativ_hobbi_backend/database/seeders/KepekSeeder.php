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
        $baseUrl = 'http://127.0.0.1:8000/storage/';
        $mappak = ['profilKepek', 'blog', 'termekKepek'];

        foreach ($mappak as $mappa) {
            $fajlok = Storage::disk('public')->files($mappa);

            foreach ($fajlok as $fajl) {
                Kepek::create([
                    'url_Link' => $baseUrl . $fajl,
                    'alt_Szoveg' => basename($fajl) . ' in ' . $mappa,
                    'leiras' => 'Description of ' . basename($fajl) . ' in ' . $mappa,
                ]);
            }
        }

        Kepek::factory(100)->create();
        $this->command->info('Kepek tábla sikeresen feltöltve!');
    }
}