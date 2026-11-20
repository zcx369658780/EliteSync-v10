<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (DB::connection()->getDriverName() !== 'sqlite') {
            Schema::table('status_posts', fn (Blueprint $table) => $table->string('audience', 24)->default('SELF')->change());
        }
        Schema::table('status_posts', function (Blueprint $table) {
            $table->string('comment_policy', 16)->nullable();
            $table->string('comment_policy_source', 16)->nullable();
            $table->unsignedInteger('audience_revision')->default(1);
            $table->string('cover_audience', 16)->nullable();
            $table->json('cover_original_viewer_ids')->nullable();
            $table->index(['audience', 'is_deleted', 'id'], 'status_posts_audience_feed_idx');
        });
        Schema::table('status_post_comments', function (Blueprint $table) {
            $table->string('original_audience', 24)->nullable();
        });
    }

    public function down(): void
    {
        // A-only readers must never receive an audience they cannot enforce.
        DB::table('status_posts')->where('audience', 'PUBLIC_AUTHENTICATED')
            ->update(['audience' => 'SELF']);
        DB::table('status_post_comments')->where('original_audience', 'PUBLIC_AUTHENTICATED')
            ->update(['original_viewer_ids' => null]);
        DB::table('status_posts')->whereNotNull('cover_media_asset_id')
            ->where('audience', 'FRIENDS')->update(['audience' => 'SELF']);
        Schema::table('status_posts', function (Blueprint $table) {
            $table->dropIndex('status_posts_audience_feed_idx');
            $table->dropColumn(['comment_policy', 'comment_policy_source', 'audience_revision', 'cover_audience', 'cover_original_viewer_ids']);
        });
        Schema::table('status_post_comments', fn (Blueprint $table) => $table->dropColumn('original_audience'));
        if (DB::connection()->getDriverName() !== 'sqlite') {
            Schema::table('status_posts', fn (Blueprint $table) => $table->string('audience', 16)->default('SELF')->change());
        }
    }
};
