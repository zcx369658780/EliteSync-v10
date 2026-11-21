<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('synthetic_connection_pairs', function (Blueprint $table) {
            $table->foreignId('user_a')->constrained('users')->cascadeOnDelete();
            $table->foreignId('user_b')->constrained('users')->cascadeOnDelete();
            $table->timestamp('granted_at');
            $table->timestamp('expires_at');
            $table->timestamp('revoked_at')->nullable();
            $table->primary(['user_a', 'user_b']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('synthetic_connection_pairs');
    }
};
