<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('user_natal_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();
            $table->json('input');
            $table->json('settings');
            $table->json('context');
            $table->char('input_signature', 64);
            $table->unsignedBigInteger('input_revision')->default(0);
            $table->unsignedBigInteger('result_revision')->nullable();
            $table->string('status', 32);
            $table->json('results')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_natal_profiles');
    }
};
