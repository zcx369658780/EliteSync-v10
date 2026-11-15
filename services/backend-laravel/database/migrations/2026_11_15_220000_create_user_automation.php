<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('automation_authorizations', function (Blueprint $t) {
            $t->id();
            $t->foreignId('user_id')->constrained()->cascadeOnDelete();
            $t->string('scope_key', 80);
            $t->string('policy_version', 60);
            $t->string('consent_version', 60);
            $t->string('state', 16);
            $t->unsignedInteger('revision');
            $t->timestamp('granted_at')->nullable();
            $t->timestamp('paused_at')->nullable();
            $t->timestamp('revoked_at')->nullable();
            $t->timestamp('expires_at')->nullable();
            $t->timestamp('last_checked_at')->nullable();
            $t->timestamps();
            $t->unique(['user_id', 'scope_key']);
        });
        Schema::table('matching_participations', function (Blueprint $t) {
            $t->foreignId('automation_authorization_id')->nullable()->constrained('automation_authorizations')->nullOnDelete();
            $t->unsignedInteger('automation_authorization_revision')->nullable();
            $t->unsignedBigInteger('automation_round_id')->nullable();
        });
        Schema::create('automation_tasks', function (Blueprint $t) {
            $t->id();
            $t->foreignId('user_id')->constrained()->cascadeOnDelete();
            $t->foreignId('authorization_id')->constrained('automation_authorizations')->cascadeOnDelete();
            $t->string('scope_key', 80);
            $t->string('cycle_key', 100);
            $t->foreignId('round_id')->nullable()->constrained('dating_rounds')->restrictOnDelete();
            $t->string('idempotency_key', 64)->unique();
            $t->uuid('correlation_id');
            $t->unsignedInteger('authorization_revision');
            $t->string('condition_fingerprint', 64);
            $t->string('state', 16);
            $t->unsignedInteger('attempt_count')->default(0);
            $t->unsignedInteger('max_attempts')->default(3);
            $t->timestamp('available_at');
            $t->timestamp('started_at')->nullable();
            $t->timestamp('finished_at')->nullable();
            $t->string('lease_owner', 100)->nullable();
            $t->unsignedBigInteger('fencing_token')->default(0);
            $t->timestamp('lease_expires_at')->nullable();
            $t->string('result_code', 80)->nullable();
            $t->string('error_code', 80)->nullable();
            $t->string('reconciliation', 32)->default('NONE');
            $t->timestamps();
            $t->unique(['user_id', 'scope_key', 'cycle_key']);
            $t->index(['state', 'available_at']);
        });
        Schema::create('automation_effects', function (Blueprint $t) {
            $t->foreignId('task_id')->primary()->constrained('automation_tasks')->cascadeOnDelete();
            $t->foreignId('user_id')->constrained()->cascadeOnDelete();
            $t->unsignedInteger('authorization_revision');
            $t->unsignedInteger('participation_revision');
            $t->unsignedInteger('participation_generation');
            $t->timestamp('created_at');
        });
        Schema::create('automation_commands', function (Blueprint $t) {
            $t->id();
            $t->foreignId('user_id')->constrained()->cascadeOnDelete();
            $t->uuid('request_key');
            $t->string('request_hash', 64);
            $t->string('action', 16);
            $t->unsignedInteger('applied_revision');
            $t->timestamp('created_at');
            $t->unique(['user_id', 'request_key']);
        });
        Schema::create('automation_audits', function (Blueprint $t) {
            $t->id();
            $t->foreignId('user_id')->constrained()->cascadeOnDelete();
            $t->unsignedBigInteger('task_id')->nullable();
            $t->string('action', 80);
            $t->timestamp('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('automation_audits');
        Schema::dropIfExists('automation_commands');
        Schema::dropIfExists('automation_effects');
        Schema::dropIfExists('automation_tasks');
        Schema::table('matching_participations', function (Blueprint $t) {
            $t->dropConstrainedForeignId('automation_authorization_id');
            $t->dropColumn('automation_authorization_revision');
            $t->dropColumn('automation_round_id');
        });
        Schema::dropIfExists('automation_authorizations');
    }
};
