<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('platform_events', function (Blueprint $t) {
            $t->uuid('id')->primary();
            $t->foreignId('organizer_id')->constrained('users')->restrictOnDelete();
            $t->string('title',100); $t->string('city',40); $t->string('venue',100);
            $t->dateTime('start_at'); $t->dateTime('end_at');
            $t->unsignedTinyInteger('capacity'); $t->string('state',20)->default('DRAFT');
            $t->unsignedInteger('revision')->default(1); $t->timestamps();
        });
        Schema::create('platform_event_budgets', function (Blueprint $t) {
            $t->foreignUuid('event_id')->primary()->constrained('platform_events')->restrictOnDelete();
            $t->string('currency_code',3)->default('CNY');
            $t->unsignedInteger('venue_cost')->default(0); $t->unsignedInteger('materials_cost')->default(0);
            $t->unsignedInteger('travel_cost')->default(0); $t->unsignedInteger('total')->default(0);
            $t->string('state',40)->default('DRAFT'); $t->unsignedInteger('revision')->default(1); $t->timestamps();
        });
        Schema::create('platform_event_grants', function (Blueprint $t) {
            $t->uuid('id')->primary(); $t->foreignUuid('event_id')->constrained('platform_events')->restrictOnDelete();
            $t->foreignId('recipient_id')->nullable()->constrained('users')->restrictOnDelete();
            $t->string('token_hash',64)->nullable()->unique(); $t->string('state',16)->default('PENDING');
            $t->dateTime('expires_at'); $t->timestamps(); $t->index(['recipient_id','event_id']);
        });
        Schema::create('platform_event_registrations', function (Blueprint $t) {
            $t->uuid('id')->primary(); $t->foreignUuid('event_id')->constrained('platform_events')->restrictOnDelete();
            $t->foreignId('user_id')->constrained('users')->restrictOnDelete();
            $t->foreignUuid('grant_id')->constrained('platform_event_grants')->restrictOnDelete();
            $t->string('state',32)->default('INVITED'); $t->unsignedInteger('revision')->default(1);
            $t->unsignedInteger('wait_order')->nullable(); $t->string('attendance',24)->default('UNVERIFIED');
            $t->timestamps(); $t->unique(['event_id','user_id']);
        });
        Schema::create('platform_event_commands', function (Blueprint $t) {
            $t->id(); $t->foreignId('actor_id')->constrained('users')->restrictOnDelete();
            $t->string('idempotency_key',80); $t->string('fingerprint',64); $t->uuid('event_id');
            $t->unsignedInteger('result_revision'); $t->timestamps(); $t->unique(['actor_id','idempotency_key']);
        });
        Schema::create('platform_event_audits', function (Blueprint $t) {
            $t->id(); $t->uuid('event_id'); $t->unsignedBigInteger('actor_id')->nullable();
            $t->string('action',40); $t->json('facts'); $t->timestamps();
        });
        Schema::create('safety_cases', function (Blueprint $t) {
            $t->uuid('id')->primary(); $t->foreignUuid('event_id')->constrained('platform_events')->restrictOnDelete();
            $t->foreignId('report_id')->unique()->constrained('moderation_reports')->restrictOnDelete();
            $t->foreignId('reporter_id')->constrained('users')->restrictOnDelete();
            $t->foreignId('subject_id')->constrained('users')->restrictOnDelete();
            $t->uuid('reporter_registration_id'); $t->uuid('subject_registration_id');
            $t->string('category',24); $t->string('state',32)->default('OPEN');
            $t->unsignedInteger('revision')->default(1); $t->dateTime('review_due_at');
            $t->unsignedBigInteger('sanction_id')->nullable(); $t->string('idempotency_key',80);
            $t->timestamps(); $t->unique(['reporter_id','idempotency_key']);
        });
        Schema::create('safety_rule_advisories',function(Blueprint $t){
            $t->foreignUuid('case_id')->primary()->constrained('safety_cases')->restrictOnDelete();
            $t->string('rule_version',40); $t->string('classification',40);
            $t->string('status',24)->default('ADVISORY_ONLY'); $t->string('uncertainty',200); $t->timestamps();
        });
        Schema::create('safety_case_evidence', function (Blueprint $t) {
            $t->uuid('id')->primary(); $t->foreignUuid('case_id')->constrained('safety_cases')->restrictOnDelete();
            $t->string('source_type',40); $t->uuid('source_id'); $t->unsignedInteger('source_revision');
            $t->string('source_hash',64); $t->string('scope',40); $t->timestamps();
        });
        Schema::create('safety_case_decisions', function (Blueprint $t) {
            $t->uuid('id')->primary(); $t->foreignUuid('case_id')->constrained('safety_cases')->restrictOnDelete();
            $t->foreignId('reviewer_id')->constrained('users')->restrictOnDelete(); $t->string('action',32);
            $t->string('reason',1000); $t->unsignedInteger('expected_revision');
            $t->uuid('corroborating_case_id')->nullable(); $t->string('rule_version',40);
            $t->string('rule_class',40); $t->string('rule_status',24)->default('ADVISORY_ONLY');
            $t->string('rule_uncertainty',200); $t->timestamps();
        });
        Schema::create('safety_case_reviews', function (Blueprint $t) {
            $t->uuid('id')->primary(); $t->foreignUuid('case_id')->constrained('safety_cases')->restrictOnDelete();
            $t->foreignId('appeal_id')->index()->constrained('sanction_appeals')->restrictOnDelete();
            $t->foreignId('sanction_id')->constrained('admin_sanctions')->restrictOnDelete();
            $t->foreignId('reviewer_id')->constrained('users')->restrictOnDelete();
            $t->string('outcome',16); $t->string('reason',1000); $t->unsignedInteger('expected_revision'); $t->timestamps();
        });
        Schema::table('sanction_appeals', function (Blueprint $t) {
            $t->unsignedInteger('revision')->default(1);
            $t->string('review_outcome',16)->nullable(); $t->timestamp('reviewed_at')->nullable();
        });
        Schema::create('platform_admin_sessions',function(Blueprint $t){
            $t->string('session_hash',64)->primary(); $t->foreignId('user_id')->constrained('users')->restrictOnDelete();
            $t->timestamp('revoked_at')->nullable(); $t->timestamps();
        });
    }

    public function down(): void
    {
        throw new LogicException('Event and Safety records require a separately authorized non-destructive rollback plan');
    }
};
