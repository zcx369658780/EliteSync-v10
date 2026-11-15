<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('lifestyle_discoveries', function (Blueprint $table) {
            $table->foreignId('user_id')->primary()->constrained()->cascadeOnDelete();
            $table->string('questionnaire_version', 40);
            $table->string('preference_projection_version', 40);
            $table->json('answers');
            $table->json('derived_preferences');
            $table->string('status', 24);
            $table->unsignedBigInteger('revision');
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();
        });
        Schema::create('lifestyle_discovery_commands', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->uuid('request_key');
            $table->string('request_hash', 64);
            $table->string('action', 16);
            $table->unsignedBigInteger('applied_revision');
            $table->timestamp('created_at');
            $table->unique(['user_id', 'request_key']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('lifestyle_discovery_commands');
        Schema::dropIfExists('lifestyle_discoveries');
    }
};
