<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('legacy_admin_batches', function (Blueprint $table) {
            $table->string('id', 64)->primary();
            $table->string('source_system', 64);
            $table->string('snapshot', 64);
            $table->string('target', 64);
            $table->string('approval', 64);
            $table->char('manifest_hash', 64);
            $table->timestamp('rolled_back_at')->nullable();
            $table->timestamp('created_at');
        });

        Schema::create('legacy_admin_mappings', function (Blueprint $table) {
            $table->id();
            $table->string('batch_id', 64);
            $table->foreign('batch_id')->references('id')->on('legacy_admin_batches')->restrictOnDelete();
            $table->string('source_system', 64);
            $table->unsignedBigInteger('legacy_user_id');
            $table->foreignId('user_id')->unique()->constrained()->restrictOnDelete();
            $table->string('candidate', 64);
            $table->char('phone_fingerprint', 64);
            $table->string('state', 24);
            $table->char('activation_hash', 64)->nullable()->unique();
            $table->timestamp('activation_expires_at')->nullable();
            $table->unique(['source_system', 'legacy_user_id']);
            $table->unique(['batch_id', 'candidate']);
            $table->timestamps();
        });

        Schema::create('legacy_admin_restore_audits', function (Blueprint $table) {
            $table->id();
            $table->string('batch_id', 64);
            $table->foreign('batch_id')->references('id')->on('legacy_admin_batches')->restrictOnDelete();
            $table->foreignId('mapping_id')->constrained('legacy_admin_mappings')->restrictOnDelete();
            $table->string('actor', 64);
            $table->string('action', 24);
            $table->json('fields')->nullable();
            $table->timestamp('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('legacy_admin_restore_audits');
        Schema::dropIfExists('legacy_admin_mappings');
        Schema::dropIfExists('legacy_admin_batches');
    }
};
