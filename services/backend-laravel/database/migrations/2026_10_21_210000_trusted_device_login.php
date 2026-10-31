<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('device_sessions', function (Blueprint $table) {
            // Never backfill a historical issuance/refresh as a password login.
            $table->timestamp('trusted_login_at')->nullable();
            $table->string('device_id', 128)->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('device_sessions', function (Blueprint $table) {
            $table->dropColumn(['trusted_login_at', 'device_id']);
        });
    }
};
