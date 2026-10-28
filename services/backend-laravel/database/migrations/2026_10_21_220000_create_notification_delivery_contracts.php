<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notification_preferences', function (Blueprint $table) {
            $table->unsignedBigInteger('user_id')->primary();
            $table->json('categories');
            $table->boolean('silent')->default(false);
            $table->timestamps();
        });
        Schema::create('notification_devices', function (Blueprint $table) {
            $table->id();
            $table->string('device_id', 128)->unique();
            $table->unsignedBigInteger('user_id')->index();
            $table->uuid('device_session_id');
            $table->string('transport', 24);
            $table->string('token_hash', 64)->unique();
            $table->unsignedInteger('generation')->default(1);
            $table->timestamp('revoked_at')->nullable();
            $table->timestamps();
        });
        Schema::create('notification_delivery_attempts', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('notification_id');
            $table->unsignedBigInteger('device_record_id');
            $table->unsignedInteger('generation');
            $table->string('status', 32);
            $table->json('payload');
            $table->timestamps();
            $table->unique(['notification_id', 'device_record_id', 'generation'], 'notification_attempt_identity');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notification_delivery_attempts');
        Schema::dropIfExists('notification_devices');
        Schema::dropIfExists('notification_preferences');
    }
};
