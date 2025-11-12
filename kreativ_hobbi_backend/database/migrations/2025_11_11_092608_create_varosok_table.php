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
        Schema::create('varosok', function (Blueprint $table) {
            $table->unsignedInteger('id')->primary()->autoIncrement();
            $table->string('varos_nev', 100)->unique()->isNotEmpty();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('varosok');
    }
};
