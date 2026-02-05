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
        Schema::create('termekKategoriak', function (Blueprint $table) {
            $table->unsignedInteger('termek_id')->nullable(false);
            $table->unsignedInteger('kategoria_id')->nullable(false);
            $table->primary(['termek_id', 'kategoria_id']);
            $table->foreign('termek_id')->references('id')->on('termekek')->onDelete('cascade');
            $table->foreign('kategoria_id')->references('id')->on('kategoriak')->onDelete('cascade');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('termekKategoriak');
    }
};
