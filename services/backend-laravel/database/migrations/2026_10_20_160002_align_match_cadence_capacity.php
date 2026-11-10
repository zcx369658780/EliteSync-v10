<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        // Round cadence_key already accepts 120 characters. Preserve it losslessly.
        Schema::table('dating_matches', fn (Blueprint $t) => $t->string('week_tag', 120)->change());
    }

    public function down(): void
    {
        // Do not silently truncate delivered cadence identities on rollback.
        if (\Illuminate\Support\Facades\DB::table('dating_matches')->whereRaw('LENGTH(week_tag) > 16')->exists()) {
            throw new \RuntimeException('Long cadence identities exist; rollback requires an explicit preservation plan.');
        }
        Schema::table('dating_matches', fn (Blueprint $t) => $t->string('week_tag', 16)->change());
    }
};
