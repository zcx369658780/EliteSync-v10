<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('user_profile_showcase_drafts', function (Blueprint $table) {
            $table->unsignedInteger('revision')->default(1);
            $table->string('display_name', 80)->nullable();
            $table->string('city', 80)->nullable();
            $table->string('relationship_goal', 80)->nullable();
            $table->json('photo_ids')->nullable();
            $table->json('audiences')->nullable();
        });
        Schema::create('profile_showcase_submissions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('draft_id')->constrained('user_profile_showcase_drafts')->cascadeOnDelete();
            $table->unsignedInteger('content_revision');
            $table->json('snapshot');
            $table->string('state')->default('pending');
            $table->foreignId('reviewer_id')->nullable()->constrained('users');
            $table->string('reason', 1000)->nullable();
            $table->timestamp('reviewed_at')->nullable();
            $table->timestamps();
            $table->unique(['draft_id', 'content_revision']);
        });
        Schema::create('profile_showcase_photos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('media_asset_id')->constrained()->cascadeOnDelete();
            $table->uuid('client_upload_id');
            $table->char('input_hash', 64);
            $table->timestamps();
            $table->unique(['user_id', 'client_upload_id']);
        });
        Schema::table('user_profile_showcase_publications', function (Blueprint $table) {
            $table->unsignedInteger('revision')->default(1);
            $table->string('publication_status')->default('published');
            $table->unsignedInteger('source_revision')->nullable();
            $table->foreignId('source_submission_id')->nullable()->constrained('profile_showcase_submissions');
        });
        Schema::create('profile_operating_applications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();
            $table->unsignedInteger('revision')->default(1);
            $table->string('state')->default('pending');
            $table->string('note', 500);
            $table->string('feedback', 1000)->nullable();
            $table->foreignId('reviewer_id')->nullable()->constrained('users');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('profile_operating_applications');
        Schema::table('user_profile_showcase_publications', function (Blueprint $table) {
            $table->dropConstrainedForeignId('source_submission_id');
            $table->dropColumn(['revision', 'publication_status', 'source_revision']);
        });
        Schema::dropIfExists('profile_showcase_photos');
        Schema::dropIfExists('profile_showcase_submissions');
        Schema::table('user_profile_showcase_drafts', fn (Blueprint $table) =>
            $table->dropColumn(['revision', 'display_name', 'city', 'relationship_goal', 'photo_ids', 'audiences']));
    }
};
