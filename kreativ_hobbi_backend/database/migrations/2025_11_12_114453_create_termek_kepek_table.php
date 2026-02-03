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
        Schema::create('termekKepek', function (Blueprint $table) {
            $table->unsignedInteger('termek_id')->nullable(false);
            $table->unsignedInteger('kep_id')->nullable(false)->default(0);
            $table->integer('rendezes')->default(1);
            $table->primary(['termek_id', 'kep_id']);
            $table->foreign('termek_id')->references('id')->on('termekek')->onDelete('cascade');
            $table->foreign('kep_id')->references('id')->on('kepek')->onDelete('cascade');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('termekKepek');
    }
};
