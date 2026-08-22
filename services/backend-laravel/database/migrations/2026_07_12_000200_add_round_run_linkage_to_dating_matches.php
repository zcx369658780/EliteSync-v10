<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('dating_matches', function (Blueprint $table) {
            $table->foreignId('round_id')->nullable()->after('id')->constrained('dating_rounds')->restrictOnDelete();
            $table->foreignId('matching_run_id')->nullable()->after('round_id')->constrained('matching_runs')->restrictOnDelete();
            $table->string('pair_key', 64)->nullable()->after('matching_run_id');
            $table->unsignedSmallInteger('pair_key_version')->nullable()->after('pair_key');
            $table->timestamp('released_at')->nullable()->after('drop_released');
            $table->unique(['round_id', 'pair_key']);
        });

        Schema::table('dating_round_user_states', function (Blueprint $table) {
            $table->foreign('dating_match_id')->references('id')->on('dating_matches')->restrictOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('dating_round_user_states', function (Blueprint $table) {
            $table->dropForeign(['dating_match_id']);
            if (DB::getDriverName() !== 'sqlite') {
                $table->dropIndex('dating_round_user_states_dating_match_id_foreign');
            }
        });
        Schema::table('dating_matches', function (Blueprint $table) {
            $table->dropForeign(['round_id']);
            $table->dropForeign(['matching_run_id']);
            $table->dropUnique(['round_id', 'pair_key']);
            $table->dropColumn(['round_id', 'matching_run_id', 'pair_key', 'pair_key_version', 'released_at']);
        });
    }
};
