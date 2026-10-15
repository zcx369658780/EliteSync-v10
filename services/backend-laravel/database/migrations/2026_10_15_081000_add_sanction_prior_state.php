<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('admin_sanctions', function (Blueprint $table): void {
            // NULL deliberately identifies legacy sanctions whose effects cannot be attributed.
            $table->json('prior_state')->nullable();
            $table->json('applied_state')->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('admin_sanctions', function (Blueprint $table): void {
            $table->dropColumn(['prior_state', 'applied_state']);
        });
    }
};
