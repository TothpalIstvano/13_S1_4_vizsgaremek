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
        Schema::create('poszt_kepek', function (Blueprint $table) {
            $table->unsignedInteger('poszt_id')->isNotEmpty();
            $table->unsignedInteger('kep_id')->isNotEmpty();
            $table->primary(['poszt_id','kep_id']);
            $table->foreign('poszt_id')->references('id')->on('posztok')->onDelete('cascade');
            $table->foreign('kep_id')->references('id')->on('kepek')->onDelete('cascade');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('poszt_kepek');
    }
};
