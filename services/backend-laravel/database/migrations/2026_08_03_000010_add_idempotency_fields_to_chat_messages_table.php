<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('chat_messages', function (Blueprint $table) {
            $table->string('client_message_id', 36)->nullable();
            $table->char('request_fingerprint', 64)->nullable();

            $table->unique(
                ['sender_id', 'client_message_id'],
                'chat_messages_sender_client_message_id_unique'
            );
        });
    }

    public function down(): void
    {
        Schema::table('chat_messages', function (Blueprint $table) {
            $table->dropUnique('chat_messages_sender_client_message_id_unique');
            $table->dropColumn(['client_message_id', 'request_fingerprint']);
        });
    }
};
