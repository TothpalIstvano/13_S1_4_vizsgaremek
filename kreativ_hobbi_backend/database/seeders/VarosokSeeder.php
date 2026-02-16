<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use App\Models\Varosok;

class VarosokSeeder extends Seeder
{
    public function run(): void
    {
        // Path to your CSV file
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

        // Skip the first line (header) – it contains messy column names
        fgetcsv($handle, 0, ';', '"', '"');

        $batch = [];
        $batchSize = 500;
        $inserted = 0;

        DB::beginTransaction();
        try {
            while (($row = fgetcsv($handle, 0, ';', '"', '"')) !== false) {
                // Each row should have at least 3 columns: postal code, city, county
                if (count($row) < 3) {
                    continue; // skip malformed lines
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

            // Insert any remaining rows
            if (!empty($batch)) {
                DB::table('varosok')->insert($batch);
                $inserted += count($batch);
            }

            DB::commit();
            $this->command->info("Successfully inserted $inserted rows from CSV.");
        } catch (\Exception $e) {
            DB::rollBack();
            $this->command->error('Import failed: ' . $e->getMessage());
        } finally {
            fclose($handle);
        }

        // Optional: you can still add extra test records via factory if you want
        // Varosok::factory()->count(20)->create();

        $this->command->info('Varosok table seeded successfully!');
    }
}