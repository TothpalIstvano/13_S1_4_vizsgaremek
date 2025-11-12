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
        Schema::create('rendeltTermekek', function (Blueprint $table) {
            $table->unsignedInteger('id')->primary()->autoIncrement();
            $table->unsignedInteger('rendeles_id')->nullable(false);
            $table->unsignedInteger('termek_id')->nullable(false);
            $table->integer('mennyiseg')->nullable(false);
            $table->decimal('egysegar', 10, 2)->nullable(false);
            $table->unsignedInteger('szin_id')->nullable(true);
            $table->foreign('rendeles_id')->references('id')->on('rendelesek')->onDelete('cascade');
            $table->foreign('termek_id')->references('id')->on('termekek')->onDelete('cascade');
            $table->foreign('szin_id')->references('id')->on('szinek')->onDelete('cascade');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('rendeltTermekek');
    }
};
