<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('dating_round_channels', function (Blueprint $table) {
            $table->string('channel_key', 64)->primary();
            $table->unsignedBigInteger('active_round_id')->nullable()->unique();
            $table->unsignedInteger('state_version')->default(1);
            $table->timestamps();
        });

        Schema::create('dating_rounds', function (Blueprint $table) {
            $table->id();
            $table->uuid('round_key')->unique();
            $table->string('channel_key', 64);
            $table->string('cadence_key', 120);
            $table->string('state', 32);
            $table->unsignedInteger('state_version')->default(1);
            $table->timestamp('scheduled_for')->nullable();
            $table->timestamp('reveal_at')->nullable();
            $table->timestamp('revealed_at')->nullable();
            $table->timestamp('closed_at')->nullable();
            $table->unsignedBigInteger('active_run_id')->nullable();
            $table->string('created_by_type', 32);
            $table->unsignedBigInteger('created_by_id')->nullable();
            $table->string('source', 32);
            $table->string('failure_code', 64)->nullable();
            $table->string('failure_summary', 255)->nullable();
            $table->timestamps();

            $table->unique(['channel_key', 'cadence_key']);
            $table->foreign('channel_key')->references('channel_key')->on('dating_round_channels')->restrictOnDelete();
        });

        if (DB::getDriverName() !== 'sqlite') {
            Schema::table('dating_round_channels', function (Blueprint $table) {
                $table->foreign('active_round_id')->references('id')->on('dating_rounds')->restrictOnDelete();
            });
        }

        Schema::create('matching_runs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('round_id')->constrained('dating_rounds')->restrictOnDelete();
            $table->uuid('run_key')->unique();
            $table->string('idempotency_key', 120)->unique();
            $table->uuid('correlation_id')->index();
            $table->unsignedInteger('attempt_no');
            $table->string('state', 32);
            $table->string('outcome', 32)->nullable();
            $table->string('trigger_source', 32);
            $table->string('actor_type', 32);
            $table->unsignedBigInteger('actor_id')->nullable();
            $table->string('reason_code', 64)->nullable();
            $table->unsignedInteger('eligible_count')->default(0);
            $table->unsignedInteger('candidate_count')->default(0);
            $table->unsignedInteger('pair_count')->default(0);
            $table->unsignedInteger('no_candidate_count')->default(0);
            $table->string('lease_owner', 120)->nullable();
            $table->unsignedBigInteger('fencing_token')->default(0);
            $table->timestamp('lease_expires_at')->nullable();
            $table->timestamp('heartbeat_at')->nullable();
            $table->timestamp('started_at')->nullable();
            $table->timestamp('finished_at')->nullable();
            $table->timestamp('eligibility_cutoff_at');
            $table->string('algorithm_version', 64);
            $table->string('config_version', 64);
            $table->string('candidate_digest', 64)->nullable();
            $table->string('digest_version', 32)->nullable();
            $table->string('digest_key_version', 32)->nullable();
            $table->foreignId('supersedes_run_id')->nullable()->constrained('matching_runs')->restrictOnDelete();
            $table->string('error_code', 64)->nullable();
            $table->string('error_summary', 255)->nullable();
            $table->unsignedInteger('timeout_seconds')->nullable();
            $table->timestamps();

            $table->unique(['round_id', 'attempt_no']);
        });

        Schema::table('dating_rounds', function (Blueprint $table) {
            $table->foreign('active_run_id')->references('id')->on('matching_runs')->restrictOnDelete();
        });

        Schema::create('matching_run_candidates', function (Blueprint $table) {
            $table->id();
            $table->foreignId('matching_run_id')->constrained('matching_runs')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->restrictOnDelete();
            $table->timestamp('eligibility_version_at')->nullable();
            $table->timestamp('profile_version_at')->nullable();
            $table->timestamps();
            $table->unique(['matching_run_id', 'user_id']);
        });

        Schema::create('dating_round_user_states', function (Blueprint $table) {
            $table->id();
            $table->foreignId('round_id')->constrained('dating_rounds')->restrictOnDelete();
            $table->foreignId('user_id')->constrained('users')->restrictOnDelete();
            $table->string('state', 32);
            $table->unsignedBigInteger('dating_match_id')->nullable();
            $table->string('reason_code', 64)->nullable();
            $table->string('next_action_code', 64)->nullable();
            $table->timestamp('reveal_eligible_at')->nullable();
            $table->boolean('conversation_eligible')->default(false);
            $table->unsignedInteger('projection_version')->default(1);
            $table->timestamps();
            $table->unique(['round_id', 'user_id']);
        });

        Schema::create('matching_operation_audits', function (Blueprint $table) {
            $table->id();
            $table->foreignId('round_id')->nullable()->constrained('dating_rounds')->restrictOnDelete();
            $table->foreignId('matching_run_id')->nullable()->constrained('matching_runs')->restrictOnDelete();
            $table->string('action', 32);
            $table->string('actor_type', 32);
            $table->unsignedBigInteger('actor_id')->nullable();
            $table->string('role_snapshot', 64)->nullable();
            $table->string('reason_code', 64)->nullable();
            $table->uuid('correlation_id')->nullable()->index();
            $table->string('idempotency_key', 120)->nullable()->index();
            $table->json('before_state')->nullable();
            $table->json('after_state')->nullable();
            $table->json('aggregate_summary')->nullable();
            $table->string('source_channel', 32);
            $table->timestamp('created_at')->useCurrent();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('matching_operation_audits');
        Schema::dropIfExists('dating_round_user_states');
        Schema::dropIfExists('matching_run_candidates');
        Schema::table('dating_rounds', fn (Blueprint $table) => $table->dropForeign(['active_run_id']));
        Schema::dropIfExists('matching_runs');
        if (DB::getDriverName() !== 'sqlite') {
            Schema::table('dating_round_channels', fn (Blueprint $table) => $table->dropForeign(['active_round_id']));
        }
        Schema::dropIfExists('dating_rounds');
        Schema::dropIfExists('dating_round_channels');
    }
};
