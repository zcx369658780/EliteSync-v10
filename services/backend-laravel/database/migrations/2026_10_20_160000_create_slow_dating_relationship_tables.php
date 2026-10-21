<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('matching_participations', function (Blueprint $t) {
            $t->foreignId('user_id')->primary()->constrained('users');
            $t->string('state')->default('NOT_ENROLLED');
            $t->unsignedInteger('generation')->default(0);
            $t->unsignedInteger('revision')->default(0);
            $t->string('intent', 1000)->default('');
            $t->timestamp('opted_in_at')->nullable();
            $t->timestamps();
        });
        Schema::create('match_proposals', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->foreignId('dating_match_id')->unique()->constrained('dating_matches');
            $t->unsignedBigInteger('round_id');
            $t->unsignedBigInteger('run_id');
            $t->foreignId('user_a')->constrained('users');
            $t->foreignId('user_b')->constrained('users');
            $t->unsignedInteger('generation_a');
            $t->unsignedInteger('generation_b');
            $t->string('state')->default('PENDING');
            $t->string('decision_a')->default('PENDING');
            $t->string('decision_b')->default('PENDING');
            $t->unsignedInteger('revision')->default(1);
            $t->timestamp('revealed_at');
            $t->timestamp('expires_at');
            $t->timestamps();
        });
        Schema::create('match_proposal_slots', function (Blueprint $t) {
            $t->foreignId('user_id')->primary()->constrained('users');
            $t->uuid('proposal_id');
            $t->foreign('proposal_id')->references('id')->on('match_proposals');
        });
        Schema::create('development_identity_subjects', function (Blueprint $t) {
            $t->foreignId('user_id')->primary()->constrained('users');
            $t->string('dataset');
            $t->timestamps();
        });
        Schema::create('identity_assertions', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->foreignId('user_id')->constrained('users');
            $t->string('issuer');
            $t->string('dataset');
            $t->string('nonce')->unique();
            $t->unsignedInteger('revision')->default(1);
            $t->timestamp('valid_from');
            $t->timestamp('expires_at');
            $t->timestamp('revoked_at')->nullable();
            $t->string('signature', 64);
            $t->timestamps();
        });
        Schema::create('formal_relationships', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->foreignId('user_a')->constrained('users');
            $t->foreignId('user_b')->constrained('users');
            $t->foreignId('requester_id')->constrained('users');
            $t->string('state')->default('PENDING_MUTUAL');
            $t->unsignedInteger('revision')->default(1);
            $t->unsignedInteger('confirmation_generation')->default(1);
            $t->boolean('confirmed_a')->default(false);
            $t->boolean('confirmed_b')->default(false);
            $t->boolean('test_only')->default(true);
            $t->timestamps();
            $t->index(['user_a', 'user_b']);
        });
        Schema::create('formal_relationship_slots', function (Blueprint $t) {
            $t->foreignId('user_id')->primary()->constrained('users');
            $t->uuid('relationship_id');
            $t->foreign('relationship_id')->references('id')->on('formal_relationships');
        });
        Schema::create('journey_commands', function (Blueprint $t) {
            $t->id();
            $t->foreignId('actor_id')->constrained('users');
            $t->string('idempotency_key', 100);
            $t->string('fingerprint', 64);
            $t->json('response');
            $t->timestamps();
            $t->unique(['actor_id', 'idempotency_key']);
        });
        Schema::create('journey_audits', function (Blueprint $t) {
            $t->id();
            $t->unsignedBigInteger('actor_id')->nullable();
            $t->string('aggregate_id');
            $t->string('action');
            $t->json('facts');
            $t->timestamps();
        });
        Schema::table('users', fn (Blueprint $t) => $t->string('relationship_resume', 1000)->nullable());
        Schema::table('matching_run_candidates', fn (Blueprint $t) => $t->unsignedInteger('participation_generation')->nullable());
    }

    public function down(): void
    {
        Schema::table('matching_run_candidates', fn (Blueprint $t) => $t->dropColumn('participation_generation'));
        Schema::table('users', fn (Blueprint $t) => $t->dropColumn('relationship_resume'));
        foreach (['journey_audits','journey_commands','formal_relationship_slots','formal_relationships','identity_assertions','development_identity_subjects','match_proposal_slots','match_proposals','matching_participations'] as $table) {
            Schema::dropIfExists($table);
        }
    }
};
