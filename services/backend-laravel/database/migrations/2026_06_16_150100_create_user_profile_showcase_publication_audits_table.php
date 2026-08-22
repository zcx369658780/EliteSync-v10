<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_profile_showcase_publication_audits', function (Blueprint $table) {
            $table->id();
            $table->foreignId('publication_id')->constrained('user_profile_showcase_publications')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('source_draft_id')->constrained('user_profile_showcase_drafts')->cascadeOnDelete();
            $table->string('actor_type', 64);
            $table->string('actor_id', 128);
            $table->string('action', 96);
            $table->string('previous_publication_status', 32);
            $table->string('new_publication_status', 32);
            $table->timestamps();

            $table->index(['publication_id', 'created_at'], 'showcase_pub_audit_publication_created_at_idx');
            $table->index(['user_id', 'created_at'], 'showcase_pub_audit_user_created_at_idx');
            $table->index(['action', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_profile_showcase_publication_audits');
    }
};
