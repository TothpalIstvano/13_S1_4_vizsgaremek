<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('jelentesek', function (Blueprint $table) {
            $table->id();

            // Ki jelenti be
            $table->unsignedInteger('bejelento_id')->nullable();
            $table->foreign('bejelento_id')->references('id')->on('felhasznalok')->nullOnDelete();


            // Mit jelent be: 'post' vagy 'comment'
            $table->enum('tipus', ['post', 'comment']);

            // A bejelentett tartalom id-ja
            // Poszthoz vagy kommenthez mutat (polimorf helyett két nullable FK)
            $table->unsignedInteger('poszt_id')->nullable();
            $table->foreign('poszt_id')->references('id')->on('posztok')->cascadeOnDelete();


            $table->unsignedInteger('komment_id')->nullable();
            $table->foreign('komment_id')->references('id')->on('kommentek')->cascadeOnDelete();

            // Bejelentés oka (a ReportModal-ban definiált értékek)
            $table->enum('ok', [
                'serto',        // Sértő tartalom
                'spam',         // Spam vagy félrevezető
                '18plus',       // 18+ tartalom
                'szemelyes',    // Személyes adatok
                'jogsertes',    // Szerzői jogi jogsértés
                'egyeb',        // Egyéb
            ]);

            // Opcionális szöveges leírás
            $table->text('leiras')->nullable();

            // Admin feldolgozás státusza
            $table->enum('statusz', [
                'fuggoben',     // Még nem nézte meg senki
                'atnezte',      // Admin megnézte
                'megoldva',     // Intézkedés történt
                'elvetve',      // Alaptalannak ítélték
            ])->default('fuggoben');

            // Admin megjegyzés (opcionális)
            $table->text('admin_megjegyzes')->nullable();

            // Ki intézkedett
            $table->unsignedInteger('kezelo_admin_id')->nullable();
            $table->foreign('kezelo_admin_id')->references('id')->on('felhasznalok')->nullOnDelete();

            $table->timestamp('kezeles_datuma')->nullable();

            $table->timestamps();

            /* Egy felhasználó ugyanazt a tartalmat csak egyszer jelentheti be
            $table->unique(['bejelento_id', 'tipus', 'poszt_id'],    'egyedi_poszt_jelentes');
            $table->unique(['bejelento_id', 'tipus', 'komment_id'],  'egyedi_komment_jelentes');
            */

            // Gyors keresés 
            $table->index(['statusz', 'created_at']);
            $table->index('tipus');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('jelentesek');
    }
};