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
        Schema::create('felhasznaloAdatok', function (Blueprint $table) {
            $table->unsignedInteger('felhasznalo_id')->primary();
            $table->rememberToken();
            $table->enum('szerepkor', ['admin', 'moderator', 'sima', 'felfuggesztett'])->default('sima');
            $table->string('vezeteknev', 100)->nullable();
            $table->string('keresztnev', 100)->nullable();
            $table->unsignedInteger('varos')->nullable();
            $table->string('utca', 255)->nullable();
            $table->integer('hazszam')->nullable();
            $table->string('emeletAjto', 10)->nullable();
            $table->string('telefonszam', 20)->nullable();
            $table->string('kartyaszam')->nullable();
            $table->foreign('felhasznalo_id')->references('id')->on('felhasznalok')->onDelete('cascade');
            $table->foreign('varos')->references('id')->on('varosok')->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('felhasznaloAdatok');
    }
};


