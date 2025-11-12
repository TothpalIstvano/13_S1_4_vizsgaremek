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
        Schema::create('kedvencek', function (Blueprint $table) {
            $table->unsignedInteger('felhasznalo_id')->nullable(false);
            $table->unsignedInteger('termek_id')->nullable(false);
            $table->primary(['felhasznalo_id', 'termek_id']);
            $table->foreign('felhasznalo_id')->references('id')->on('felhasznalok');
            $table->foreign('termek_id')->references('id')->on('termekek');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('kedvencek');
    }
};
