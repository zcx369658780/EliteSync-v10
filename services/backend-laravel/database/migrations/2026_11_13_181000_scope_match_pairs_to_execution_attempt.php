<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('dating_matches', function (Blueprint $table) {
            $table->index('round_id', 'dating_matches_round_lookup_v1017');
            $table->dropUnique(['round_id', 'pair_key']);
            $table->unique(['matching_run_id', 'pair_key'], 'dating_matches_run_pair_v1017');
        });
    }

    public function down(): void
    {
        if (DB::table('dating_matches')->whereNotNull('round_id')->whereNotNull('pair_key')
            ->groupBy('round_id', 'pair_key')->havingRaw('COUNT(*) > 1')->exists()) {
            throw new \LogicException('Retained execution attempts share a pair; downgrade requires a lossless data plan.');
        }
        Schema::table('dating_matches', function (Blueprint $table) {
            $table->unique(['round_id', 'pair_key']);
            $table->dropUnique('dating_matches_run_pair_v1017');
            $table->dropIndex('dating_matches_round_lookup_v1017');
        });
    }
};
