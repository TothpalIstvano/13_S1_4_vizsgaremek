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
        Schema::create('posztReakciok', function (Blueprint $table) {
            $table->unsignedInteger('poszt_id');
            $table->unsignedInteger('felhasznalo_id');
            $table->enum('reakcio', ['like', 'dislike']);
            $table->primary(['poszt_id', 'felhasznalo_id']);
            $table->foreign('poszt_id')->references('id')->on('posztok')->onDelete('cascade');
            $table->foreign('felhasznalo_id')->references('id')->on('felhasznalok')->onDelete('cascade');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('posztReakciok');
    }
};
