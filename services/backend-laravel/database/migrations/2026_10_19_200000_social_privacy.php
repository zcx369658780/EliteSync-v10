<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('privacy_preferences', function (Blueprint $t) {
            $t->unsignedBigInteger('user_id')->primary();
            $t->boolean('requests_enabled')->default(false);
            $t->json('fields')->nullable();
            $t->unsignedInteger('revision')->default(0);
            $t->timestamps();
        });
        Schema::create('social_invitations', function (Blueprint $t) {
            $t->id();
            $t->unsignedBigInteger('recipient_id')->index();
            $t->string('token_hash', 64)->unique();
            $t->string('purpose', 24);
            $t->unsignedBigInteger('sender_id')->nullable();
            $t->timestamp('expires_at');
            $t->timestamp('revoked_at')->nullable();
            $t->timestamps();
        });
        Schema::create('social_requests', function (Blueprint $t) {
            $t->id();
            $t->unsignedBigInteger('sender_id');
            $t->unsignedBigInteger('recipient_id');
            $t->string('pair_key', 80)->index();
            $t->string('purpose', 24);
            $t->string('state', 24);
            $t->unsignedBigInteger('invitation_id')->nullable();
            $t->string('idempotency_key', 100);
            $t->string('input_hash', 64);
            $t->timestamp('expires_at');
            $t->timestamps();
            $t->unique(['sender_id', 'idempotency_key']);
        });
        Schema::create('friendships', function (Blueprint $t) {
            $t->id();
            $t->unsignedBigInteger('user_a');
            $t->unsignedBigInteger('user_b');
            $t->string('state', 24);
            $t->unsignedInteger('revision')->default(1);
            $t->timestamps();
            $t->unique(['user_a', 'user_b']);
        });
        Schema::create('conversation_hidden_views', function (Blueprint $t) {
            $t->unsignedBigInteger('user_id');
            $t->unsignedBigInteger('conversation_id');
            $t->unsignedBigInteger('hidden_through_id');
            $t->timestamps();
            $t->primary(['user_id', 'conversation_id']);
        });
        Schema::table('status_posts', fn (Blueprint $t) => $t->string('audience', 16)->default('SELF'));
        Schema::table('product_connections', function (Blueprint $t) {
            $t->unsignedBigInteger('match_id')->nullable()->change();
            $t->dropUnique('product_connections_match_id_unique');
            $t->unsignedBigInteger('friendship_id')->nullable()->index();
            $t->unsignedBigInteger('social_request_id')->nullable()->index();
            $t->unsignedInteger('lifecycle_generation')->default(1);
        });
    }

    public function down(): void
    {
        // The old schema cannot represent non-match or multiple lifecycles. Never silently discard them.
        if (DB::table('product_connections')->whereNull('match_id')->exists()
            || DB::table('product_connections')->select('match_id')->groupBy('match_id')->havingRaw('COUNT(*) > 1')->exists()) {
            throw new RuntimeException('V1011_DATA_REQUIRES_VERIFIED_BACKUP_RESTORE');
        }
        Schema::table('product_connections', function (Blueprint $t) {
            $t->dropColumn(['friendship_id', 'social_request_id', 'lifecycle_generation']);
            $t->unsignedBigInteger('match_id')->nullable(false)->change();
            $t->unique('match_id');
        });
        Schema::table('status_posts', fn (Blueprint $t) => $t->dropColumn('audience'));
        foreach (['conversation_hidden_views', 'friendships', 'social_requests', 'social_invitations', 'privacy_preferences'] as $table) {
            Schema::dropIfExists($table);
        }
    }
};
