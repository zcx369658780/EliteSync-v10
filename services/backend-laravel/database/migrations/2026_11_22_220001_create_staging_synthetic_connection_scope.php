<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('staging_connection_instance', function (Blueprint $table) {
            $table->unsignedTinyInteger('id')->primary();
            $table->char('marker', 64);
        });
        Schema::create('staging_connection_grants', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_a');
            $table->unsignedBigInteger('user_b');
            $table->string('approval', 64)->unique();
            $table->timestamp('granted_at');
            $table->timestamp('expires_at');
            $table->timestamp('revoked_at')->nullable();
            $table->string('revocation', 64)->nullable()->unique();
            $table->unique(['user_a', 'user_b']);
            $table->index('user_b');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('staging_connection_grants');
        Schema::dropIfExists('staging_connection_instance');
    }
};
