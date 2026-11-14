<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('user_tool_revisions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('tool', 16);
            $table->unsignedBigInteger('record_id');
            $table->unsignedBigInteger('input_revision');
            $table->json('snapshot');
            $table->timestamps();
            $table->unique(['user_id', 'tool', 'record_id', 'input_revision'], 'tool_revision_unique');
            $table->index(['user_id', 'tool', 'record_id', 'id'], 'tool_history_cursor');
        });
        Schema::create('dynamic_chart_commands', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->uuid('request_key');
            $table->char('request_hash', 64);
            // Keep a minimal tombstone after chart deletion so retries cannot recreate it.
            $table->unsignedBigInteger('chart_id');
            $table->unsignedBigInteger('input_revision');
            $table->timestamps();
            $table->unique(['user_id', 'request_key']);
        });
        Schema::table('mbti_attempts', function (Blueprint $table) {
            $table->uuid('request_key')->nullable();
            $table->char('request_hash', 64)->nullable();
            $table->unique(['user_id', 'request_key'], 'mbti_attempts_request_unique');
        });
    }

    public function down(): void
    {
        Schema::table('mbti_attempts', function (Blueprint $table) {
            $table->dropUnique('mbti_attempts_request_unique');
            $table->dropColumn(['request_key', 'request_hash']);
        });
        Schema::dropIfExists('user_tool_revisions');
        Schema::dropIfExists('dynamic_chart_commands');
    }
};
