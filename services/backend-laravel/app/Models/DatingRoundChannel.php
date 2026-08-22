<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DatingRoundChannel extends Model
{
    protected $primaryKey = 'channel_key';
    public $incrementing = false;
    protected $keyType = 'string';
    protected $fillable = ['channel_key', 'active_round_id', 'state_version'];

    public function activeRound(): BelongsTo
    {
        return $this->belongsTo(DatingRound::class, 'active_round_id');
    }
}
