<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('user_dynamic_charts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('chart_type', 24);
            $table->json('request');
            $table->json('settings');
            $table->json('prepared');
            $table->char('input_signature', 64);
            $table->unsignedBigInteger('input_revision');
            $table->unsignedBigInteger('result_revision')->nullable();
            $table->unsignedInteger('selected_event_index')->nullable();
            $table->string('status', 40);
            $table->json('results')->nullable();
            $table->timestamps();
            $table->index(['user_id', 'id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_dynamic_charts');
    }
};
