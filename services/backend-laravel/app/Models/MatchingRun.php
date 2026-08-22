<?php

namespace App\Models;

use App\Domain\Matching\RunOutcome;
use App\Domain\Matching\RunState;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class MatchingRun extends Model
{
    protected $fillable = ['round_id', 'run_key', 'idempotency_key', 'correlation_id', 'attempt_no', 'state', 'outcome', 'trigger_source', 'actor_type', 'actor_id', 'reason_code', 'eligible_count', 'candidate_count', 'pair_count', 'no_candidate_count', 'lease_owner', 'fencing_token', 'lease_expires_at', 'heartbeat_at', 'started_at', 'finished_at', 'eligibility_cutoff_at', 'algorithm_version', 'config_version', 'candidate_digest', 'digest_version', 'digest_key_version', 'supersedes_run_id', 'error_code', 'error_summary', 'timeout_seconds'];

    protected function casts(): array
    {
        return ['state' => RunState::class, 'outcome' => RunOutcome::class, 'lease_expires_at' => 'datetime', 'heartbeat_at' => 'datetime', 'started_at' => 'datetime', 'finished_at' => 'datetime', 'eligibility_cutoff_at' => 'datetime'];
    }

    public function round(): BelongsTo { return $this->belongsTo(DatingRound::class, 'round_id'); }
    public function candidates(): HasMany { return $this->hasMany(MatchingRunCandidate::class, 'matching_run_id'); }
    public function supersedes(): BelongsTo { return $this->belongsTo(self::class, 'supersedes_run_id'); }
}
