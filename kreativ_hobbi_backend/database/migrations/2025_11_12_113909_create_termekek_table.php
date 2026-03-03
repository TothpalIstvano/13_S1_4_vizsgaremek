<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use function Laravel\Prompts\table;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('termekek', function (Blueprint $table) {
            $table->unsignedInteger('id')->primary()->autoIncrement();
            $table->string('nev', 255);
            $table->text('leiras')->nullable();
            $table->decimal('ar', 10, 0);
            $table->integer('darab')->default(0);
            $table->integer('meter')->nullable();
            $table->unsignedInteger('kategoria_id');
            $table->unsignedInteger('fo_kep_id')->nullable();
            $table->foreign('kategoria_id')->references('id')->on('kategoriak')->onDelete('cascade');
            $table->foreign('fo_kep_id')->references('id')->on('kepek')->onDelete('set null');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('termekek');
    }
};
