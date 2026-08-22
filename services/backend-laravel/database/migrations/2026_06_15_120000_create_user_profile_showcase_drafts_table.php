<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_profile_showcase_drafts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained('users')->cascadeOnDelete();
            $table->text('self_intro')->nullable();
            $table->json('interest_tags')->nullable();
            $table->json('lifestyle_tags')->nullable();
            $table->text('opener_note')->nullable();
            $table->string('visibility_intent', 32)->default('private_draft');
            $table->string('draft_status', 32)->default('draft');
            $table->string('moderation_status', 32)->default('not_submitted');
            $table->string('source_type', 64)->default('user_confirmed');
            $table->boolean('public_display_eligible')->default(false);
            $table->boolean('matching_scoring_eligible')->default(false);
            $table->timestamps();

            $table->index(['user_id', 'draft_status']);
            $table->index(['user_id', 'moderation_status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_profile_showcase_drafts');
    }
};
