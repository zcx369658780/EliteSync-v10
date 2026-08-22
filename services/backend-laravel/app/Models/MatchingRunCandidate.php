<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class MatchingRunCandidate extends Model
{
    protected $fillable = ['matching_run_id', 'user_id', 'eligibility_version_at', 'profile_version_at'];
    protected function casts(): array { return ['eligibility_version_at' => 'datetime', 'profile_version_at' => 'datetime']; }
    public function run(): BelongsTo { return $this->belongsTo(MatchingRun::class, 'matching_run_id'); }
    public function user(): BelongsTo { return $this->belongsTo(User::class); }
}
