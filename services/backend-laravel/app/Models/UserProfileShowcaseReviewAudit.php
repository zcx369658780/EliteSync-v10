<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserProfileShowcaseReviewAudit extends Model
{
    protected $fillable = [
        'draft_id',
        'user_id',
        'actor_type',
        'actor_id',
        'previous_moderation_status',
        'new_moderation_status',
        'reason_code',
        'note',
        'reviewed_fields_hash',
        'correlation_id',
    ];

    public function draft(): BelongsTo
    {
        return $this->belongsTo(UserProfileShowcaseDraft::class, 'draft_id');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
