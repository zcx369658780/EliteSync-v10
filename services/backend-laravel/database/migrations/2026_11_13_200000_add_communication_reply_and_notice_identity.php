<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('chat_messages', function (Blueprint $table) {
            $table->unsignedBigInteger('reply_to_message_id')->nullable();
        });
        Schema::table('notifications', function (Blueprint $table) {
            $table->string('source_event_key', 191)->nullable();
            $table->unique(['user_id', 'source_event_key'], 'notifications_recipient_event_unique');
        });
    }

    public function down(): void
    {
        Schema::table('notifications', function (Blueprint $table) {
            $table->dropUnique('notifications_recipient_event_unique');
            $table->dropColumn('source_event_key');
        });
        Schema::table('chat_messages', fn (Blueprint $table) => $table->dropColumn('reply_to_message_id'));
    }
};
