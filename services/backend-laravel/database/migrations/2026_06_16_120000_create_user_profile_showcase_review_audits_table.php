<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_profile_showcase_review_audits', function (Blueprint $table) {
            $table->id();
            $table->foreignId('draft_id')->constrained('user_profile_showcase_drafts')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('actor_type', 64);
            $table->string('actor_id', 128);
            $table->string('previous_moderation_status', 32);
            $table->string('new_moderation_status', 32);
            $table->string('reason_code', 96);
            $table->string('note', 240)->nullable();
            $table->string('reviewed_fields_hash', 64)->nullable();
            $table->string('correlation_id', 128)->nullable();
            $table->timestamps();

            $table->index(['draft_id', 'created_at']);
            $table->index(['actor_type', 'actor_id']);
            $table->index(['new_moderation_status', 'created_at'], 'upsra_status_created_at_idx');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_profile_showcase_review_audits');
    }
};
