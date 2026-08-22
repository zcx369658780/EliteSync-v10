<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class UserProfileShowcasePublication extends Model
{
    protected $fillable = [
        'user_id',
        'source_draft_id',
        'source_draft_updated_at',
        'source_moderation_status',
        'published_payload',
        'public_display_eligible',
        'matching_scoring_eligible',
        'published_at',
    ];

    protected function casts(): array
    {
        return [
            'source_draft_updated_at' => 'datetime',
            'published_payload' => 'array',
            'public_display_eligible' => 'boolean',
            'matching_scoring_eligible' => 'boolean',
            'published_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function sourceDraft(): BelongsTo
    {
        return $this->belongsTo(UserProfileShowcaseDraft::class, 'source_draft_id');
    }

    public function audits(): HasMany
    {
        return $this->hasMany(UserProfileShowcasePublicationAudit::class, 'publication_id');
    }
}
