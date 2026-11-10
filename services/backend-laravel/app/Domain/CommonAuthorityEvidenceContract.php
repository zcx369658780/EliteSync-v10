<?php

namespace App\Domain;

use InvalidArgumentException;

final class CommonAuthorityEvidenceContract
{
    public const CONDITION_PRESENT = 'PRESENT';
    public const CONDITION_ABSENT = 'ABSENT';
    public const CONDITION_UNKNOWN = 'UNKNOWN';
    public const CONDITION_UNAVAILABLE = 'UNAVAILABLE';
    public const CONDITION_STALE = 'STALE';
    public const CONDITION_SUPERSEDED = 'SUPERSEDED';
    public const CONDITION_INCOMPARABLE = 'INCOMPARABLE';

    public const REVISION_OLDER = 'OLDER';
    public const REVISION_EQUAL = 'EQUAL';
    public const REVISION_NEWER = 'NEWER';

    public const INTENT_EXACT_DUPLICATE = 'EXACT_DUPLICATE';
    public const INTENT_DISTINCT = 'DISTINCT_INTENT';
    public const INTENT_CHANGED_INPUT_REJECTED = 'CHANGED_INPUT_REUSE_REJECTED';

    public const OUTCOME_COMMITTED = 'COMMITTED';
    public const OUTCOME_REJECTED = 'REJECTED';
    public const OUTCOME_UNKNOWN = 'UNKNOWN';

    public const INVALIDATION_CORRECTION = 'CORRECTION';
    public const INVALIDATION_REVOCATION = 'REVOCATION';
    public const INVALIDATION_SUPERSESSION = 'SUPERSESSION';

    private const BINDING_KEYS = [
        'authority_owner',
        'authority_scope',
        'actor',
        'actor_role',
        'subject',
        'participants',
        'audience',
        'purpose',
        'aggregate_context',
        'lifecycle_identity',
        'terminal',
    ];

    private const REVISION_KEYS = [
        'authority_owner',
        'authority_scope',
        'lineage',
        'aggregate_context',
        'value',
    ];

    /**
     * @param array<string, mixed> $bindings
     * @param array<string, mixed> $revision
     * @return array<string, mixed>
     */
    public static function evidence(
        array $bindings,
        string $condition,
        array $revision,
        ?bool $currentness,
        ?bool $freshness,
        string $outcome = self::OUTCOME_UNKNOWN,
    ): array {
        self::assertBindings($bindings);
        self::assertCondition($condition);
        self::assertRevision($revision);
        self::assertOutcome($outcome);

        if (
            $revision['authority_owner'] !== $bindings['authority_owner']
            || $revision['authority_scope'] !== $bindings['authority_scope']
            || $revision['aggregate_context'] !== $bindings['aggregate_context']
        ) {
            throw new InvalidArgumentException('Revision must be bound to the same source authority and context.');
        }

        return [
            'record_kind' => 'SOURCE_EVIDENCE',
            'bindings' => $bindings,
            'source_condition' => $condition,
            'source_revision' => $revision,
            'currentness' => $currentness,
            'freshness' => $freshness,
            'authoritative_outcome' => $outcome,
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public static function sourceRevision(
        string $authorityOwner,
        string $authorityScope,
        string $lineage,
        string $aggregateContext,
        int $value,
    ): array {
        foreach ([$authorityOwner, $authorityScope, $lineage, $aggregateContext] as $binding) {
            if ($binding === '') {
                throw new InvalidArgumentException('Revision bindings must be non-empty.');
            }
        }

        if ($value < 0) {
            throw new InvalidArgumentException('Source-local revision must be non-negative.');
        }

        return [
            'authority_owner' => $authorityOwner,
            'authority_scope' => $authorityScope,
            'lineage' => $lineage,
            'aggregate_context' => $aggregateContext,
            'value' => $value,
        ];
    }

    /**
     * @param array<string, mixed> $left
     * @param array<string, mixed> $right
     */
    public static function compareSourceRevisions(array $left, array $right): string
    {
        self::assertRevision($left);
        self::assertRevision($right);

        foreach (['authority_owner', 'authority_scope', 'lineage', 'aggregate_context'] as $key) {
            if ($left[$key] !== $right[$key]) {
                return self::CONDITION_INCOMPARABLE;
            }
        }

        return match ($left['value'] <=> $right['value']) {
            -1 => self::REVISION_OLDER,
            0 => self::REVISION_EQUAL,
            1 => self::REVISION_NEWER,
        };
    }

    /**
     * @param array<string, mixed> $evidence
     * @param array<string, mixed> $requiredBindings
     * @return array{satisfied: bool, reasons: list<string>}
     */
    public static function evaluateProtected(array $evidence, array $requiredBindings): array
    {
        if (($evidence['record_kind'] ?? null) !== 'SOURCE_EVIDENCE') {
            return ['satisfied' => false, 'reasons' => ['NOT_SOURCE_AUTHORITY']];
        }

        $reasons = [];

        foreach (self::BINDING_KEYS as $key) {
            if (! array_key_exists($key, $requiredBindings)) {
                $reasons[] = 'MISSING_REQUIRED_BINDING:'.$key;
                continue;
            }

            if (($evidence['bindings'][$key] ?? null) !== $requiredBindings[$key]) {
                $reasons[] = 'BINDING_MISMATCH:'.$key;
            }
        }

        if (($evidence['source_condition'] ?? null) !== self::CONDITION_PRESENT) {
            $reasons[] = 'SOURCE_CONDITION_NOT_PRESENT';
        }

        if (($evidence['currentness'] ?? null) !== true) {
            $reasons[] = 'NOT_CURRENT';
        }

        if (($evidence['freshness'] ?? null) !== true) {
            $reasons[] = 'NOT_FRESH';
        }

        return ['satisfied' => $reasons === [], 'reasons' => $reasons];
    }

    /**
     * @param array<string, mixed> $semanticInput
     * @return array{intent_identity: string, semantic_input: array<string, mixed>}
     */
    public static function bindIntent(string $intentIdentity, array $semanticInput): array
    {
        if ($intentIdentity === '' || $semanticInput === []) {
            throw new InvalidArgumentException('Intent identity and semantic input are required.');
        }

        return [
            'intent_identity' => $intentIdentity,
            'semantic_input' => $semanticInput,
        ];
    }

    /**
     * @param array<string, mixed> $registered
     * @param array<string, mixed> $candidate
     */
    public static function correlateIntent(array $registered, array $candidate): string
    {
        if (($registered['intent_identity'] ?? null) !== ($candidate['intent_identity'] ?? null)) {
            return self::INTENT_DISTINCT;
        }

        if (($registered['semantic_input'] ?? null) === ($candidate['semantic_input'] ?? null)) {
            return self::INTENT_EXACT_DUPLICATE;
        }

        return self::INTENT_CHANGED_INPUT_REJECTED;
    }

    /**
     * @return array{correlation: bool, permission: false, success: false}
     */
    public static function idempotencyMeaning(string $correlation): array
    {
        return [
            'correlation' => $correlation === self::INTENT_EXACT_DUPLICATE,
            'permission' => false,
            'success' => false,
        ];
    }

    public static function outcomeAfterTransport(string $transportObservation): string
    {
        if (! in_array($transportObservation, ['AMBIGUOUS', 'ACKNOWLEDGED', 'FAILED'], true)) {
            throw new InvalidArgumentException('Unknown transport observation.');
        }

        return self::OUTCOME_UNKNOWN;
    }

    public static function reconcileOutcome(string $assertedOutcome, bool $sourceAuthoritative): string
    {
        self::assertOutcome($assertedOutcome);

        if (! $sourceAuthoritative) {
            return self::OUTCOME_UNKNOWN;
        }

        return $assertedOutcome;
    }

    /**
     * @param array<string, mixed> $evidence
     * @return array<string, mixed>
     */
    public static function invalidate(array $evidence, string $relation): array
    {
        if (! in_array($relation, [
            self::INVALIDATION_CORRECTION,
            self::INVALIDATION_REVOCATION,
            self::INVALIDATION_SUPERSESSION,
        ], true)) {
            throw new InvalidArgumentException('Unknown invalidation relation.');
        }

        if (($evidence['record_kind'] ?? null) !== 'SOURCE_EVIDENCE') {
            throw new InvalidArgumentException('Only source evidence can be invalidated.');
        }

        return [
            'record_kind' => 'INVALIDATION_RESULT',
            'relation' => $relation,
            'source_condition' => self::CONDITION_SUPERSEDED,
            'valid_for_protected_use' => false,
            'projection_invalidated' => true,
            'lifecycle_identity' => $evidence['bindings']['lifecycle_identity'],
            'terminal' => $evidence['bindings']['terminal'],
            'lifecycle_reset' => false,
            'reopened' => false,
            'new_aggregate_created' => false,
            'transition_synthesized' => false,
        ];
    }

    /**
     * @param array<string, mixed> $evidence
     * @return array<string, mixed>
     */
    public static function privacyMinimalProjection(array $evidence): array
    {
        if (($evidence['record_kind'] ?? null) !== 'SOURCE_EVIDENCE') {
            throw new InvalidArgumentException('Projection requires source evidence.');
        }

        return [
            'record_kind' => 'PRIVACY_MINIMAL_PROJECTION',
            'authority_owner' => $evidence['bindings']['authority_owner'],
            'authority_scope' => $evidence['bindings']['authority_scope'],
            'subject_reference' => $evidence['bindings']['subject'],
            'participant_references' => $evidence['bindings']['participants'],
            'audience' => $evidence['bindings']['audience'],
            'purpose' => $evidence['bindings']['purpose'],
            'aggregate_context' => $evidence['bindings']['aggregate_context'],
            'source_condition' => $evidence['source_condition'],
            'revision_lineage' => $evidence['source_revision']['lineage'],
            'revision_value' => $evidence['source_revision']['value'],
            'currentness' => $evidence['currentness'],
            'freshness' => $evidence['freshness'],
            'authoritative_outcome' => $evidence['authoritative_outcome'],
            'source_authority' => false,
            'permission' => false,
            'bearer_capability' => false,
            'success_proof' => false,
            'substitute_writer' => false,
        ];
    }

    /**
     * @param array<string, mixed> $bindings
     */
    private static function assertBindings(array $bindings): void
    {
        $keys = array_keys($bindings);
        sort($keys);
        $expected = self::BINDING_KEYS;
        sort($expected);

        if ($keys !== $expected) {
            throw new InvalidArgumentException('Bindings must contain exactly the common contract fields.');
        }

        foreach (self::BINDING_KEYS as $key) {
            if ($key === 'participants') {
                if (! is_array($bindings[$key]) || $bindings[$key] === []) {
                    throw new InvalidArgumentException('Participants must be a non-empty exact set.');
                }
                continue;
            }

            if ($key === 'terminal') {
                if (! is_bool($bindings[$key])) {
                    throw new InvalidArgumentException('Terminal marker must be boolean.');
                }
                continue;
            }

            if (! is_string($bindings[$key]) || $bindings[$key] === '') {
                throw new InvalidArgumentException('Every binding must be a non-empty string.');
            }
        }
    }

    private static function assertCondition(string $condition): void
    {
        if (! in_array($condition, [
            self::CONDITION_PRESENT,
            self::CONDITION_ABSENT,
            self::CONDITION_UNKNOWN,
            self::CONDITION_UNAVAILABLE,
            self::CONDITION_STALE,
            self::CONDITION_SUPERSEDED,
            self::CONDITION_INCOMPARABLE,
        ], true)) {
            throw new InvalidArgumentException('Unknown source condition.');
        }
    }

    /**
     * @param array<string, mixed> $revision
     */
    private static function assertRevision(array $revision): void
    {
        $keys = array_keys($revision);
        sort($keys);
        $expected = self::REVISION_KEYS;
        sort($expected);

        if ($keys !== $expected) {
            throw new InvalidArgumentException('Revision must be source-local and contain no global revision.');
        }

        foreach (['authority_owner', 'authority_scope', 'lineage', 'aggregate_context'] as $key) {
            if (! is_string($revision[$key]) || $revision[$key] === '') {
                throw new InvalidArgumentException('Revision bindings must be non-empty strings.');
            }
        }

        if (! is_int($revision['value']) || $revision['value'] < 0) {
            throw new InvalidArgumentException('Revision value must be a non-negative source-local integer.');
        }
    }

    private static function assertOutcome(string $outcome): void
    {
        if (! in_array($outcome, [
            self::OUTCOME_COMMITTED,
            self::OUTCOME_REJECTED,
            self::OUTCOME_UNKNOWN,
        ], true)) {
            throw new InvalidArgumentException('Unknown authoritative outcome.');
        }
    }
}
