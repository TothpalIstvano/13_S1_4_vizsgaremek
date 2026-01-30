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
            $table->unsignedInteger('felhasznalo_id')->nullable(false);
            $table->enum('statusz',['függőben','szállítás alatt','teljesítve','törölve'])->default('függőben')->nullable(false);
            $table->decimal('osszeg', 10, 2)->nullable(false);
            $table->foreign('felhasznalo_id')->references('id')->on('felhasznalok')->nullable()->onDelete('cascade');
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
