<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('device_sessions', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignId('user_id')->index();
            $table->string('label', 80);
            $table->timestamp('last_used_at');
            $table->timestamp('revoked_at')->nullable();
            $table->timestamps();
        });
        Schema::table('personal_access_tokens', function (Blueprint $table) {
            $table->uuid('device_session_id')->nullable()->index();
        });
        Schema::create('account_closures', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignId('user_id')->unique();
            $table->string('idempotency_key', 100);
            $table->string('receipt_hash', 64)->unique();
            $table->string('status', 60)->default('DELETION_PENDING');
            $table->unsignedInteger('attempts')->default(0);
            $table->text('result')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();
        });
        // Only the server-side, version-specific initializer may populate this registry.
        Schema::create('v1011_erasure_members', function (Blueprint $table) {
            $table->foreignId('user_id')->primary();
            $table->string('dataset');
            $table->string('provenance');
            $table->timestamp('registered_at');
        });
        Schema::create('v1011_erasure_assets', function (Blueprint $t) {
            $t->unsignedBigInteger('asset_id')->primary();
            $t->unsignedBigInteger('user_id')->index();
            $t->string('dataset');
            $t->string('storage_key');
            $t->string('sha256', 64);
            $t->boolean('evidence_hold')->default(false);
            $t->timestamp('registered_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('v1011_erasure_assets');
        Schema::dropIfExists('v1011_erasure_members');
        Schema::dropIfExists('account_closures');
        Schema::table('personal_access_tokens', fn (Blueprint $table) => $table->dropColumn('device_session_id'));
        Schema::dropIfExists('device_sessions');
    }
};
