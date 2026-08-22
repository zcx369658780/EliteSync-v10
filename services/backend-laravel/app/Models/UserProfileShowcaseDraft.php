<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserProfileShowcaseDraft extends Model
{
    protected $fillable = [
        'user_id',
        'self_intro',
        'interest_tags',
        'lifestyle_tags',
        'opener_note',
        'visibility_intent',
        'draft_status',
        'moderation_status',
        'source_type',
        'public_display_eligible',
        'matching_scoring_eligible',
    ];

    protected function casts(): array
    {
        return [
            'interest_tags' => 'array',
            'lifestyle_tags' => 'array',
            'public_display_eligible' => 'boolean',
            'matching_scoring_eligible' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
