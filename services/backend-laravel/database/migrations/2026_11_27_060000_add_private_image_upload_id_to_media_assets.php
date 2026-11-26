<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('media_assets', function (Blueprint $table) {
            $table->uuid('client_upload_id')->nullable();
            $table->unique(['owner_user_id', 'client_upload_id'], 'media_owner_upload_unique');
        });
    }

    public function down(): void
    {
        Schema::table('media_assets', function (Blueprint $table) {
            $table->dropUnique('media_owner_upload_unique');
            $table->dropColumn('client_upload_id');
        });
    }
};
