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
        Schema::create('kommentek', function (Blueprint $table) {
            $table->unsignedInteger('id')->primary()->autoIncrement();
            $table->string('komment')->nullable(false);
            $table->unsignedInteger('poszt_id')->nullable(false);
            $table->unsignedInteger('kommentelo')->nullable(false);
            $table->unsignedInteger('elozetes_komment_id')->nullable();
            $table->foreign('poszt_id')->references('id')->on('posztok')->onDelete('cascade');
            $table->foreign('kommentelo')->references('id')->on('felhasznalok')->onDelete('cascade');
            $table->foreign('elozetes_komment_id')->references('id')->on('kommentek')->onDelete('cascade');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('kommentek');
    }
};
