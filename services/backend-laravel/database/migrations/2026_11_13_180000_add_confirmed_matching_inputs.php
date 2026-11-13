<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('matching_inputs', function (Blueprint $table) {
            $table->foreignId('user_id')->primary()->constrained()->cascadeOnDelete();
            $table->unsignedInteger('revision')->default(1);
            $table->json('payload');
            $table->string('confirmation_version', 32);
            $table->char('confirmed_profile_hash', 64);
            $table->char('confirmed_goal_answer_hash', 64);
            $table->timestamps();
        });
        Schema::table('matching_run_candidates', function (Blueprint $table) {
            $table->char('matching_input_digest', 64)->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('matching_run_candidates', fn (Blueprint $table) => $table->dropColumn('matching_input_digest'));
        Schema::dropIfExists('matching_inputs');
    }
};
