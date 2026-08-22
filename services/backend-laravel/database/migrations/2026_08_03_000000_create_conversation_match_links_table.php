<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('conversation_match_links', function (Blueprint $table) {
            $table->id();
            $table->foreignId('conversation_id')->constrained('conversations')->cascadeOnDelete();
            $table->foreignId('dating_match_id')->unique()->constrained('dating_matches')->restrictOnDelete();
            $table->timestamp('linked_at');
            $table->timestamps();

            $table->unique(['conversation_id', 'dating_match_id']);
            $table->index(['conversation_id', 'linked_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('conversation_match_links');
    }
};
