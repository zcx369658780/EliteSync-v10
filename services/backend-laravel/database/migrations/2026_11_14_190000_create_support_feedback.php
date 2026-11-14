<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('support_feedback', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->uuid('request_key');
            $table->char('request_hash', 64);
            $table->string('source', 32);
            $table->string('category', 64);
            $table->text('content');
            $table->string('status', 20)->default('OPEN');
            $table->text('public_reply')->nullable();
            $table->unsignedInteger('revision')->default(1);
            $table->timestamps();
            $table->unique(['user_id', 'request_key']);
            $table->index(['user_id', 'id']);
        });
        Schema::create('support_feedback_updates', function (Blueprint $table) {
            $table->id();
            $table->foreignId('feedback_id')->constrained('support_feedback')->cascadeOnDelete();
            $table->foreignId('actor_user_id')->constrained('users');
            $table->uuid('request_key');
            $table->char('request_hash', 64);
            $table->string('category', 64);
            $table->string('previous_status', 20);
            $table->string('status', 20);
            $table->text('public_reply')->nullable();
            $table->text('internal_note')->nullable();
            $table->unsignedInteger('revision');
            $table->timestamp('created_at');
            $table->unique(['feedback_id', 'actor_user_id', 'request_key'], 'feedback_update_request_unique');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('support_feedback_updates');
        Schema::dropIfExists('support_feedback');
    }
};
