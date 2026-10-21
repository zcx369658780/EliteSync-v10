<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('formal_relationships', fn (Blueprint $t) => $t->timestamp('activated_at')->nullable());
        // Preserve the existing server-recorded activation fact, never infer it from a resumed generation.
        foreach (DB::table('journey_audits')->where('action', 'CONFIRM')->orderBy('id')->get() as $audit) {
            if ((json_decode($audit->facts, true)['state'] ?? null) === 'ACTIVE') {
                DB::table('formal_relationships')->where('id', $audit->aggregate_id)->whereNull('activated_at')->update(['activated_at' => $audit->created_at]);
            }
        }
    }

    public function down(): void
    {
        Schema::table('formal_relationships', fn (Blueprint $t) => $t->dropColumn('activated_at'));
    }
};
