<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('user_profile_showcase_publications', function (Blueprint $table) {
            $table->unsignedInteger('access_epoch')->default(1);
        });
        Schema::create('candidate_showcase_bindings', function (Blueprint $table) {
            $table->id();
            $table->foreignUuid('proposal_id')->constrained('match_proposals')->restrictOnDelete();
            $table->foreignId('owner_id')->constrained('users')->restrictOnDelete();
            $table->foreignId('viewer_id')->constrained('users')->restrictOnDelete();
            $table->foreignId('publication_id')->constrained('user_profile_showcase_publications')->restrictOnDelete();
            $table->unsignedBigInteger('source_submission_id');
            $table->unsignedInteger('publication_revision');
            $table->unsignedInteger('access_epoch');
            $table->json('snapshot');
            $table->timestamp('created_at');
            $table->unique(['proposal_id', 'owner_id']);
        });
        Schema::table('status_post_comments', function (Blueprint $table) {
            // NULL deliberately leaves legacy permission unproven; never infer it from today's post.
            $table->json('original_viewer_ids')->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('status_post_comments', fn (Blueprint $table) => $table->dropColumn('original_viewer_ids'));
        Schema::dropIfExists('candidate_showcase_bindings');
        Schema::table('user_profile_showcase_publications', fn (Blueprint $table) => $table->dropColumn('access_epoch'));
    }
};
