<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('privacy_preferences', fn (Blueprint $t) => $t->unsignedInteger('requests_revision')->default(0));
        Schema::table('formal_relationships', function (Blueprint $t) {
            $t->string('request_source_kind', 24)->nullable();
            $t->unsignedBigInteger('request_source_id')->nullable();
            $t->unsignedInteger('request_source_revision')->nullable();
            $t->unsignedInteger('request_permission_revision')->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('formal_relationships', fn (Blueprint $t) => $t->dropColumn(['request_source_kind', 'request_source_id', 'request_source_revision', 'request_permission_revision']));
        Schema::table('privacy_preferences', fn (Blueprint $t) => $t->dropColumn('requests_revision'));
    }
};
