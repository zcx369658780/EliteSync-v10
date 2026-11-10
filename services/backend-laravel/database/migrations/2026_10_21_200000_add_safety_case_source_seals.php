<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('safety_case_evidence',function(Blueprint $t){
            $t->json('source_fact')->nullable();$t->string('fact_hash',64)->nullable();$t->dateTime('retain_until')->nullable();
        });
    }
    public function down(): void
    {
        throw new LogicException('Safety source seals require a separately authorized non-destructive rollback plan');
    }
};
