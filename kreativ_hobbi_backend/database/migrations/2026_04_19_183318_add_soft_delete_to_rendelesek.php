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
        Schema::table('rendelesek', function (Blueprint $table) {
            $table->softDeletes(); // deleted_at oszlop
        });
    }

    public function down(): void
    {
        Schema::table('rendelesek', function (Blueprint $table) {
            $table->dropSoftDeletes();
        });
    }
};
