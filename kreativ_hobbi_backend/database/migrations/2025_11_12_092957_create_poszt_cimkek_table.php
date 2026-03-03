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
        Schema::create('posztCimkek', function (Blueprint $table) {
            $table->unsignedInteger('poszt_id');
            $table->unsignedInteger('cimke_id');
            $table->primary(['poszt_id', 'cimke_id']);
            $table->foreign('poszt_id')->references('id')->on('posztok')->onDelete('cascade');
            $table->foreign('cimke_id')->references('id')->on('cimkek')->onDelete('cascade');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('posztCimkek');
    }
};
