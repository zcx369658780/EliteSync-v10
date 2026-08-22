<?php

namespace App\Models;

use App\Domain\Matching\OperationAction;
use Illuminate\Database\Eloquent\Model;

class MatchingOperationAudit extends Model
{
    public const UPDATED_AT = null;
    protected $fillable = ['round_id', 'matching_run_id', 'action', 'actor_type', 'actor_id', 'role_snapshot', 'reason_code', 'correlation_id', 'idempotency_key', 'before_state', 'after_state', 'aggregate_summary', 'source_channel', 'created_at'];
    protected function casts(): array { return ['action' => OperationAction::class, 'before_state' => 'array', 'after_state' => 'array', 'aggregate_summary' => 'array', 'created_at' => 'datetime']; }

    protected static function booted(): void
    {
        static::updating(fn () => throw new \LogicException('matching operation audits are append-only'));
        static::deleting(fn () => throw new \LogicException('matching operation audits are append-only'));
    }
}
