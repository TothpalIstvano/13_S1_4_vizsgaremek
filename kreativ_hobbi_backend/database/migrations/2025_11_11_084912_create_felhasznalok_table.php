<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('felhasznalok', function (Blueprint $table) {
            $table->unsignedInteger('id')->autoIncrement();
            $table->string('felhasz_nev', 100)->unique()->nullable(false);
            $table->string('email', 150)->unique()->nullable(false);
            $table->string('jelszo')->nullable(false);
            $table->unsignedInteger('profilKep_id')->default(0);
            $table->enum('statusz', ['aktív', 'inaktív']);
            $table->timestamp('letrehozas_Datuma');
            $table->timestamp('utolso_Belepes')->nullable()->useCurrent()->useCurrentOnUpdate();
            $table->foreign('profilKep_id')->references('id')->on('kepek');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('felhasznalok');
    }
};

