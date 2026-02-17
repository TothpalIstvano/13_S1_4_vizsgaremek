<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('varosok', function (Blueprint $table) {
            $table->unsignedInteger('id')->primary()->autoIncrement();
            $table->string('iranyitoszam', 5)->nullable();
            $table->string('varos_nev', 100);
            $table->string('megye', 100)->nullable();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('varosok');
    }
};