<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('product_connections', function (Blueprint $t) {
            $t->id();
            $t->unsignedBigInteger('match_id')->unique();
            $t->unsignedBigInteger('user_a');
            $t->unsignedBigInteger('user_b');
            $t->unsignedBigInteger('requester_id');
            $t->string('state', 24)->default('CN_NONE');
            $t->unsignedInteger('revision')->default(0);
            $t->timestamps();
        });
        Schema::create('messaging_consents', function (Blueprint $t) {
            $t->id();
            $t->unsignedBigInteger('connection_id');
            $t->string('purpose', 32);
            $t->string('state', 24)->default('MC_NONE');
            $t->unsignedBigInteger('requester_id');
            $t->unsignedInteger('revision')->default(0);
            $t->unsignedInteger('connection_revision');
            $t->timestamps();
            $t->unique(['connection_id', 'purpose']);
        });
        Schema::create('live_consent_events', function (Blueprint $t) {
            $t->id();
            $t->unsignedBigInteger('connection_id');
            $t->string('kind', 24);
            $t->unsignedBigInteger('actor_id');
            $t->string('from_state', 24);
            $t->string('to_state', 24);
            $t->unsignedInteger('revision');
            $t->timestamp('created_at');
        });
        Schema::create('questionnaire_drafts', function (Blueprint $t) {
            $t->id();
            $t->unsignedBigInteger('user_id')->unique();
            $t->json('payload');
            $t->timestamps();
        });
    }

    public function down(): void
    {
        foreach (['questionnaire_drafts', 'live_consent_events', 'messaging_consents', 'product_connections'] as $name) {
            Schema::dropIfExists($name);
        }
    }
};
