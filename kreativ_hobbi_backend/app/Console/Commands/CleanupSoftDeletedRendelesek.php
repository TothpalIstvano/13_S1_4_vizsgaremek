<?php

namespace App\Console\Commands;

use App\Models\Rendelesek;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

class CleanupSoftDeletedRendelesek extends Command
{
    protected $signature = 'rendelesek:cleanup {--days=1500}';
    protected $description = 'Soft-deletelt rendelések végleges törlése X nap után';

    public function handle(): int
    {
        $days = (int) $this->option('days');

        // withTrashed() — soft-deletelteket is lekérdezi
        // onlyTrashed() — CSAK a soft-deletelteket
        $torlendo = Rendelesek::onlyTrashed()
            ->where('deleted_at', '<', now()->subDays($days))
            ->get();

        $count = $torlendo->count();

        if ($count === 0) {
            $this->info('Nincs törlendő rekord.');
            return self::SUCCESS;
        }

        // forceDelete() = végleges törlés az adatbázisból
        Rendelesek::onlyTrashed()
            ->where('deleted_at', '<', now()->subDays($days))
            ->forceDelete();

        Log::info("Rendelések véglegesen törölve", [
            'darab' => $count,
            'napok' => $days,
        ]);

        $this->info("{$count} rendelés véglegesen törölve.");
        return self::SUCCESS;
    }
}
