<?php

namespace App\Models;

use App\Domain\Matching\UserRoundState;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DatingRoundUserState extends Model
{
    protected $fillable = ['round_id', 'user_id', 'state', 'dating_match_id', 'reason_code', 'next_action_code', 'reveal_eligible_at', 'conversation_eligible', 'projection_version'];
    protected function casts(): array { return ['state' => UserRoundState::class, 'reveal_eligible_at' => 'datetime', 'conversation_eligible' => 'boolean']; }
    public function round(): BelongsTo { return $this->belongsTo(DatingRound::class); }
    public function match(): BelongsTo { return $this->belongsTo(DatingMatch::class, 'dating_match_id'); }
}
