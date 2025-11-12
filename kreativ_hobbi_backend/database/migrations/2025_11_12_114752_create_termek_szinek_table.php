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
        Schema::create('termekSzinek', function (Blueprint $table) {
            $table->unsignedInteger('termek_id')->nullable(false);
            $table->unsignedInteger('szin_id')->nullable(false);
            $table->primary(['termek_id', 'szin_id']);
            $table->foreign('termek_id')->references('id')->on('termekek');
            $table->foreign('szin_id')->references('id')->on('szinek');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('termekSzinek');
    }
};
