<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('buddy_discovery_publications', function (Blueprint $table) {
            $table->id();
            $table->foreignUuid('activity_id')->constrained('buddy_activities')->restrictOnDelete();
            $table->unsignedInteger('generation');
            $table->unsignedInteger('owner_epoch');
            $table->string('author_label', 40);
            $table->string('state', 20)->default('PUBLISHED');
            $table->dateTime('published_at');
            $table->dateTime('expires_at');
            $table->foreignId('consumed_by')->nullable()->constrained('users')->restrictOnDelete();
            $table->timestamps();
            $table->unique(['activity_id', 'generation']);
            $table->index(['state', 'id']);
        });
        Schema::table('buddy_invitations', function (Blueprint $table) {
            $table->foreignId('discovery_publication_id')->nullable()->unique()
                ->constrained('buddy_discovery_publications')->restrictOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('buddy_invitations', function (Blueprint $table) {
            $table->dropConstrainedForeignId('discovery_publication_id');
        });
        Schema::dropIfExists('buddy_discovery_publications');
    }
};
