<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ConversationMatchLink extends Model
{
    protected $fillable = [
        'conversation_id',
        'dating_match_id',
        'linked_at',
    ];

    protected function casts(): array
    {
        return [
            'linked_at' => 'datetime',
        ];
    }

    public function conversation(): BelongsTo
    {
        return $this->belongsTo(Conversation::class);
    }

    public function datingMatch(): BelongsTo
    {
        return $this->belongsTo(DatingMatch::class);
    }
}
