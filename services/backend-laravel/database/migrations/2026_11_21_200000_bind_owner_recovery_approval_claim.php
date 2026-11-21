<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('legacy_admin_batches', function (Blueprint $table) {
            $table->string('owner_approval_claim', 64)->nullable()->unique();
        });
    }

    public function down(): void
    {
        Schema::table('legacy_admin_batches', function (Blueprint $table) {
            $table->dropUnique(['owner_approval_claim']);
            $table->dropColumn('owner_approval_claim');
        });
    }
};
