<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('posztok', function (Blueprint $table) {
            $table->unsignedInteger('id')->primary()->autoIncrement();
            $table->string('cim', 255)->nullable(false);
            $table->string('kivonat', 255)->nullable(false);
            $table->text('tartalom', )->nullable(false);
            $table->unsignedInteger('szerzo_id')->nullable();
            $table->unsignedInteger('fo_kep_id')->nullable();
            $table->timestamp('letrehozas_datuma')->useCurrent()->useCurrentOnUpdate();
            $table->enum('statusz', ['piszkozat', 'közzétett', 'archivált', 'törölt'])->default('piszkozat');
            $table->foreign('szerzo_id')->references('id')->on('felhasznalok')->onDelete('set null');
            $table->foreign('fo_kep_id')->references('id')->on('kepek')->onDelete('set null');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('posztok');
    }
};
