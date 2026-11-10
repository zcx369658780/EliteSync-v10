<?php

namespace App\Domain;

use Throwable;

/** A deterministic, process-memory-only gate probe; it cannot read or send content. */
final class MessagingConsentSyntheticLiveGateUsePoint
{
    /** @var list<array<string, mixed>> */
    private array $snapshots;

    private int $nextSnapshot = 0;
    private int $acquisitions = 0;
    private int $readSentinels = 0;
    private int $sendSentinels = 0;

    /** @var list<string> */
    private array $events = [];

    /** @param list<array<string, mixed>> $snapshots */
    public function __construct(array $snapshots)
    {
        $this->snapshots = array_is_list($snapshots) ? $snapshots : [];
    }

    /** @param array<string, mixed> $context @return array<string, mixed> */
    public function attemptReadSynthetic(array $context): array
    {
        return $this->attempt($context, 'READ');
    }

    /** @param array<string, mixed> $context @return array<string, mixed> */
    public function attemptSendSynthetic(array $context): array
    {
        return $this->attempt($context, 'SEND');
    }

    /** @param array<string, mixed> $context @return array<string, mixed> */
    private function attempt(array $context, string $operation): array
    {
        $start = count($this->events);
        if (! $this->validContext($context)) {
            return $this->result('INVALID_CONTEXT', false, $start);
        }

        // Each invocation consumes a new in-memory snapshot, including at the send commit probe.
        $this->acquisitions++;
        $this->events[] = 'ACQUIRE_'.$operation;
        $snapshot = $this->snapshots[$this->nextSnapshot] ?? null;
        $this->nextSnapshot++;
        if (! is_array($snapshot)) {
            return $this->result('SOURCE_UNAVAILABLE', false, $start);
        }
        if (! $this->validSnapshot($snapshot, $context)) {
            return $this->result('SOURCE_REJECTED', false, $start);
        }

        try {
            $this->events[] = 'EVALUATE_'.$operation;
            $gate = MessagingConsentConversationLiveGateEvaluator::evaluateLiveGates(
                $snapshot['connection'], $snapshot['connection_evidence'],
                $snapshot['read_consent'], $snapshot['read_consent_evidence'],
                $snapshot['send_consent'], $snapshot['send_consent_evidence'],
            );
            foreach ($snapshot['invalidations'] as $invalidation) {
                if (! $this->validInvalidation($invalidation, $gate)) {
                    return $this->result('INVALIDATION_UNBOUND', false, $start);
                }
                $gate = MessagingConsentConversationLiveGateEvaluator::invalidateLiveGate(
                    $gate, $invalidation['dependency_identity'], $invalidation['relation'],
                );
                $this->events[] = 'INVALIDATE_'.$operation;
            }
        } catch (Throwable) {
            return $this->result('EVALUATION_UNKNOWN', false, $start);
        }

        $field = $operation === 'READ' ? 'live_read_allowed' : 'live_send_allowed';
        $validField = $operation === 'READ' ? 'valid_for_live_read' : 'valid_for_live_send';
        if (($gate[$field] ?? false) !== true || ($gate[$validField] ?? false) !== true) {
            return $this->result('GATE_DENIED', false, $start);
        }

        // A sentinel is only a counter. No payload, callback, repository, or transport exists here.
        if ($operation === 'READ') {
            $this->readSentinels++;
        } else {
            $this->sendSentinels++;
        }
        $this->events[] = $operation.'_SENTINEL';

        return $this->result('SYNTHETIC_SENTINEL_CREATED', true, $start);
    }

    /** @param array<string, mixed> $context */
    private function validContext(array $context): bool
    {
        if (! $this->exactKeys($context, [
            'connection_identity', 'participants', 'protected_audience',
            'read_consent_identity', 'send_consent_identity', 'requester', 'recipient',
            'synthetic_intent_identity',
        ])) {
            return false;
        }
        foreach ([
            'connection_identity', 'protected_audience', 'read_consent_identity',
            'send_consent_identity', 'requester', 'recipient', 'synthetic_intent_identity',
        ] as $key) {
            if (! $this->nonEmpty($context[$key])) {
                return false;
            }
        }
        $participants = $context['participants'];
        return is_array($participants) && array_is_list($participants) && count($participants) === 2
            && $this->nonEmpty($participants[0]) && $this->nonEmpty($participants[1])
            && $participants[0] !== $participants[1]
            && $context['read_consent_identity'] !== $context['send_consent_identity']
            && in_array($context['requester'], $participants, true)
            && in_array($context['recipient'], $participants, true)
            && $context['requester'] !== $context['recipient'];
    }

    /** @param array<string, mixed> $snapshot @param array<string, mixed> $context */
    private function validSnapshot(array $snapshot, array $context): bool
    {
        if (! $this->exactKeys($snapshot, [
            'source_status', 'connection', 'connection_evidence', 'read_consent',
            'read_consent_evidence', 'send_consent', 'send_consent_evidence', 'invalidations',
        ]) || $snapshot['source_status'] !== 'OK'
            || ! is_array($snapshot['connection'])
            || ! is_array($snapshot['read_consent']) || ! is_array($snapshot['send_consent'])
            || ($snapshot['connection']['connection_identity'] ?? null) !== $context['connection_identity']
            || ($snapshot['connection']['participants'] ?? null) !== $context['participants']
            || ($snapshot['read_consent']['consent_identity'] ?? null) !== $context['read_consent_identity']
            || ($snapshot['send_consent']['consent_identity'] ?? null) !== $context['send_consent_identity']
            || ($snapshot['read_consent']['purpose'] ?? null) !== MessagingConsentConversationLiveGateEvaluator::PURPOSE_LIVE_READ
            || ($snapshot['send_consent']['purpose'] ?? null) !== MessagingConsentConversationLiveGateEvaluator::PURPOSE_LIVE_SEND
            || ! is_array($snapshot['invalidations']) || ! array_is_list($snapshot['invalidations'])) {
            return false;
        }
        foreach (['read_consent', 'send_consent'] as $key) {
            $consent = $snapshot[$key];
            if (($consent['connection_identity'] ?? null) !== $context['connection_identity']
                || ($consent['participants'] ?? null) !== $context['participants']
                || ($consent['requester'] ?? null) !== $context['requester']
                || ($consent['recipient'] ?? null) !== $context['recipient']) {
                return false;
            }
        }
        foreach ([
            'connection_evidence' => null,
            'read_consent_evidence' => MessagingConsentConversationLiveGateEvaluator::PURPOSE_LIVE_READ,
            'send_consent_evidence' => MessagingConsentConversationLiveGateEvaluator::PURPOSE_LIVE_SEND,
        ] as $key => $purpose) {
            $items = $snapshot[$key];
            if (! is_array($items) || ! array_is_list($items) || count($items) > 8) {
                return false;
            }
            foreach ($items as $item) {
                if (! is_array($item) || ! is_array($item['required_bindings'] ?? null)) {
                    return false;
                }
                $bindings = $item['required_bindings'];
                if (($bindings['audience'] ?? null) !== $context['protected_audience']
                    || ($bindings['participants'] ?? null) !== $context['participants']
                    || ($purpose !== null && ($bindings['purpose'] ?? null) !== $purpose)
                    || ($purpose === null && ($bindings['purpose'] ?? null) !== ($snapshot['connection']['protected_use_scope'] ?? null))) {
                    return false;
                }
            }
        }
        return true;
    }

    /** @param mixed $invalidation @param array<string, mixed> $gate */
    private function validInvalidation(mixed $invalidation, array $gate): bool
    {
        if (! is_array($invalidation) || ! $this->exactKeys($invalidation, ['dependency_identity', 'relation'])
            || ! $this->nonEmpty($invalidation['dependency_identity'])
            || ! in_array($invalidation['relation'], [
                CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
                CommonAuthorityEvidenceContract::INVALIDATION_REVOCATION,
                CommonAuthorityEvidenceContract::INVALIDATION_SUPERSESSION,
            ], true)) {
            return false;
        }
        $dependencies = $gate['dependency_vector'] ?? [];
        $identities = [
            $dependencies['connection']['state_evidence_identity'] ?? null,
            $dependencies['read_consent']['consent_evidence_identity'] ?? null,
            $dependencies['send_consent']['consent_evidence_identity'] ?? null,
        ];
        return in_array($invalidation['dependency_identity'], $identities, true);
    }

    /** @return array<string, mixed> */
    private function result(string $condition, bool $sentinel, int $start): array
    {
        return [
            'record_kind' => 'SYNTHETIC_LIVE_GATE_USE_POINT_PROBE',
            'condition' => $condition,
            'synthetic_only' => true,
            'sentinel_constructed' => $sentinel,
            'acquisition_count' => $this->acquisitions,
            'read_sentinel_count' => $this->readSentinels,
            'send_sentinel_count' => $this->sendSentinels,
            'events' => array_slice($this->events, $start),
            'source_authority' => false,
            'permission' => false,
            'message_sent' => false,
            'conversation_content_read' => false,
        ];
    }

    /** @param array<string, mixed> $value @param list<string> $keys */
    private function exactKeys(array $value, array $keys): bool
    {
        $actual = array_keys($value);
        sort($actual);
        sort($keys);
        return $actual === $keys;
    }

    private function nonEmpty(mixed $value): bool
    {
        return is_string($value) && $value !== '';
    }
}
