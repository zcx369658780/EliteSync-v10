<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_profile_showcase_publications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained('users')->cascadeOnDelete();
            $table->foreignId('source_draft_id')->constrained('user_profile_showcase_drafts')->cascadeOnDelete();
            $table->timestamp('source_draft_updated_at')->nullable();
            $table->string('source_moderation_status', 32);
            $table->json('published_payload');
            $table->boolean('public_display_eligible')->default(true);
            $table->boolean('matching_scoring_eligible')->default(false);
            $table->timestamp('published_at');
            $table->timestamps();

            $table->index(['source_draft_id', 'published_at'], 'showcase_pub_source_draft_published_idx');
            $table->index(['public_display_eligible', 'published_at'], 'showcase_pub_display_published_idx');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_profile_showcase_publications');
    }
};
