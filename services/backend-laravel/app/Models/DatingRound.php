<?php

namespace App\Models;

use App\Domain\Matching\RoundState;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class DatingRound extends Model
{
    protected $fillable = ['round_key', 'channel_key', 'cadence_key', 'state', 'state_version', 'scheduled_for', 'reveal_at', 'revealed_at', 'closed_at', 'active_run_id', 'created_by_type', 'created_by_id', 'source', 'failure_code', 'failure_summary'];

    protected function casts(): array
    {
        return ['state' => RoundState::class, 'scheduled_for' => 'datetime', 'reveal_at' => 'datetime', 'revealed_at' => 'datetime', 'closed_at' => 'datetime'];
    }

    public function activeRun(): BelongsTo { return $this->belongsTo(MatchingRun::class, 'active_run_id'); }
    public function runs(): HasMany { return $this->hasMany(MatchingRun::class, 'round_id'); }
    public function userStates(): HasMany { return $this->hasMany(DatingRoundUserState::class, 'round_id'); }
}
