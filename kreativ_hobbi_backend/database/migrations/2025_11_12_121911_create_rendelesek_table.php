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
        Schema::create('rendelesek', function (Blueprint $table) {
            $table->unsignedInteger('id')->primary()->autoIncrement();
            $table->unsignedInteger('felhasznalo_id')->nullable();
            $table->enum('statusz',['függőben','szállítás alatt','teljesítve','törölve'])->default('függőben');
            $table->enum('fizetes_statusz', ['függőben', 'fizetve', 'sikertelen'])->default('függőben');
            $table->decimal('osszeg', 10, 2);
            $table->string('szallitasi_nev');
            $table->string('szallitasi_email');
            $table->string('szallitasi_telefon');
            $table->string('szallitasi_utca');
            $table->string('szallitasi_hazszam');
            $table->string('szallitasi_emeletAjto')->nullable();
            $table->string('szallitasi_varos_nev');
            $table->unsignedInteger('szallitasi_varos_id')->nullable();
            $table->foreign('szallitasi_varos_id')->references('id')->on('varosok')->onDelete('set null');
            $table->foreign('felhasznalo_id')->references('id')->on('felhasznalok')->onDelete('set null');
            $table->timestamp('rendeles_datuma')->useCurrent();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('rendelesek');
    }
};
