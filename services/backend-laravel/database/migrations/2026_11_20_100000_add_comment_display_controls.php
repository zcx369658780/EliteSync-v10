<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('status_post_comments', function (Blueprint $table) {
            $table->uuid('parent_id')->nullable();
            $table->string('independent_response', 16)->nullable();
            $table->boolean('withdrawn')->default(false);
            $table->boolean('hidden_by_owner')->default(false);
        });
    }

    public function down(): void
    {
        DB::table('status_post_comments')->where('state', 'ACTIVE')
            ->where(fn ($q) => $q->where('withdrawn', true)->orWhere('hidden_by_owner', true)->orWhereNotNull('parent_id'))
            ->update(['state' => 'HIDDEN']);
        Schema::table('status_post_comments', fn (Blueprint $table) => $table
            ->dropColumn(['parent_id', 'independent_response', 'withdrawn', 'hidden_by_owner']));
    }
};
