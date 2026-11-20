<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', fn (Blueprint $table) => $table->string('private_birth_time', 5)->nullable());
        Schema::create('data_purpose_grants', function (Blueprint $table) {
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('purpose', 32);
            $table->string('state', 16);
            $table->string('basis', 32);
            $table->unsignedInteger('revision');
            $table->timestamp('expires_at')->nullable();
            $table->timestamps();
            $table->primary(['user_id', 'purpose']);
        });
        Schema::create('showcase_city_sources', function (Blueprint $table) {
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->unsignedInteger('draft_revision');
            $table->unsignedInteger('grant_revision');
            $table->char('source_digest', 64);
            $table->primary(['user_id', 'draft_revision']);
        });
        Schema::create('object_data_requests', function (Blueprint $table) {
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('object_type', 16);
            $table->string('object_key', 64);
            $table->string('object_version', 32);
            $table->uuid('request_key');
            $table->string('state', 24);
            $table->timestamps();
            $table->primary(['user_id', 'request_key']);
            $table->unique(['user_id', 'object_type', 'object_key']);
        });
    }

    public function down(): void
    {
        if (DB::table('user_dynamic_charts')->whereNotNull('prepared->_purpose_grant_revision')->exists()
            || DB::table('user_tool_revisions')->where('tool', 'dynamic')
                ->whereNotNull('snapshot->prepared->_purpose_grant_revision')->exists()) {
            throw new RuntimeException('Purpose-bound dynamic history requires a safe downgrade plan.');
        }

        // Downgrading to readers without purpose checks must not expose a
        // publication that had been dependent on a C-stage purpose.
        DB::table('user_profile_showcase_publications')
            ->whereExists(fn ($q) => $q->selectRaw('1')->from('showcase_city_sources')
                ->whereColumn('showcase_city_sources.user_id', 'user_profile_showcase_publications.user_id')
                ->whereColumn('showcase_city_sources.draft_revision', 'user_profile_showcase_publications.source_revision'))
            ->update(['public_display_eligible' => false, 'publication_status' => 'withdrawn',
                'access_epoch' => DB::raw('access_epoch + 1')]);
        // Existing approved drafts could otherwise publish after dropping their dependency.
        DB::table('user_profile_showcase_drafts')
            ->whereExists(fn ($q) => $q->selectRaw('1')->from('showcase_city_sources')
                ->whereColumn('showcase_city_sources.user_id', 'user_profile_showcase_drafts.user_id')
                ->whereColumn('showcase_city_sources.draft_revision', 'user_profile_showcase_drafts.revision'))
            ->update(['city' => null, 'moderation_status' => 'not_submitted',
                'revision' => DB::raw('revision + 1')]);
        DB::table('profile_showcase_submissions')
            ->whereExists(fn ($q) => $q->selectRaw('1')->from('showcase_city_sources')
                ->whereColumn('showcase_city_sources.user_id', 'profile_showcase_submissions.user_id')
                ->whereColumn('showcase_city_sources.draft_revision', 'profile_showcase_submissions.content_revision'))
            ->chunkById(100, function ($submissions) {
                foreach ($submissions as $submission) {
                    $snapshot = json_decode($submission->snapshot, true, 512, JSON_THROW_ON_ERROR);
                    unset($snapshot['city']);
                    DB::table('profile_showcase_submissions')->where('id', $submission->id)
                        ->update(['snapshot' => json_encode($snapshot, JSON_THROW_ON_ERROR)]);
                }
            });
        Schema::dropIfExists('object_data_requests');
        Schema::dropIfExists('showcase_city_sources');
        Schema::dropIfExists('data_purpose_grants');
        Schema::table('users', fn (Blueprint $table) => $table->dropColumn('private_birth_time'));
    }
};
