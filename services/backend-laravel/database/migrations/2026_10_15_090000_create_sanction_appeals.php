<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sanction_appeals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sanction_id')->unique()->constrained('admin_sanctions')->restrictOnDelete();
            $table->foreignId('user_id')->constrained('users')->restrictOnDelete();
            $table->string('status', 24)->default('submitted');
            $table->string('note', 1000);
            $table->timestamp('submitted_at');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        throw new LogicException('Appeal records require an explicit non-destructive rollback plan');
    }
};
