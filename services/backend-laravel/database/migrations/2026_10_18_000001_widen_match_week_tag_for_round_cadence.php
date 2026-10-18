<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Changing only the column keeps its existing standalone and composite indexes.
        Schema::table('dating_matches', function (Blueprint $table) {
            $table->string('week_tag', 120)->change();
        });
    }

    public function down(): void
    {
        // Schema rollback requires stopped writers; MariaDB DDL is not transactional.
        $length = DB::getDriverName() === 'sqlite' ? 'length' : 'char_length';
        if (DB::table('dating_matches')->whereRaw($length.'(week_tag) > ?', [16])->exists()) {
            throw new RuntimeException('week_tag_rollback_blocked_values_exceed_16_characters');
        }

        Schema::table('dating_matches', function (Blueprint $table) {
            $table->string('week_tag', 16)->change();
        });
    }
};
