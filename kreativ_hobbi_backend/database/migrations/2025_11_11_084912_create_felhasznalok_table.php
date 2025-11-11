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
            $table->id();
            $table->string('felhasznalo_nev', 100)->unique()->isNotEmpty();
            $table->string('email', 150)->unique()->isNotEmpty();
            $table->string('jelszo')->isNotEmpty();
            $table->unsignedInteger('profilKep_id');
            $table->enum('statusz', ['aktív', 'inaktív']);
            $table->timestamp('utolso_bejelentkezes')->nullable();
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

