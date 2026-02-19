<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use App\Models\Varosok;

class VarosokSeeder extends Seeder
{
    public function run(): void
    {
        $csvFile = database_path('seeders/iranyitoszamok.csv');

        if (!file_exists($csvFile)) {
            $this->command->error("CSV file not found at: $csvFile");
            return;
        }

        $handle = fopen($csvFile, 'r');
        if (!$handle) {
            $this->command->error('Could not open CSV file.');
            return;
        }

        $batch = [];
        $batchSize = 500;
        $inserted = 0;

        DB::beginTransaction();
        try {
            while (($row = fgetcsv($handle, 0, ';', '"', '"')) !== false) {
                if (count($row) < 3) {
                    continue;
                }

                $postalCode = trim($row[0]);
                $cityName = trim($row[1]);
                $county = trim($row[2]);

                if (empty($postalCode) || empty($cityName)) {
                    continue;
                }

                $batch[] = [
                    'iranyitoszam' => $postalCode,
                    'varos_nev' => $cityName,
                    'megye' => $county,
                ];

                if (count($batch) >= $batchSize) {
                    DB::table('varosok')->insert($batch);
                    $inserted += count($batch);
                    $batch = [];
                }
            }

            if (!empty($batch)) {
                DB::table('varosok')->insert($batch);
                $inserted += count($batch);
            }

            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            $this->command->error('Import failed: ' . $e->getMessage());
        } finally {
            fclose($handle);
        }

        $this->command->info('Varosok table seeded successfully!');
    }
}