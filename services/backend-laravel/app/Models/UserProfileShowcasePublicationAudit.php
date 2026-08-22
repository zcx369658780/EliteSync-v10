<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserProfileShowcasePublicationAudit extends Model
{
    protected $fillable = [
        'publication_id',
        'user_id',
        'source_draft_id',
        'actor_type',
        'actor_id',
        'action',
        'previous_publication_status',
        'new_publication_status',
    ];

    public function publication(): BelongsTo
    {
        return $this->belongsTo(UserProfileShowcasePublication::class, 'publication_id');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function sourceDraft(): BelongsTo
    {
        return $this->belongsTo(UserProfileShowcaseDraft::class, 'source_draft_id');
    }
}
