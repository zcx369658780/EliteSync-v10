<?php

namespace App\Domain;

use InvalidArgumentException;

final class InMemoryLogicalPersistenceRepositoryContract
{
    public const RECORD_FAMILY_RR03 = 'RR03_RUNTIME_READINESS_DERIVED_PROJECTION';
    public const RECORD_FAMILY_CANONICAL_MATCH = 'CANONICAL_MATCH_PROPOSAL_DECISION_DERIVED_PROJECTION';
    public const RECORD_FAMILY_PRODUCT_CONNECTION = 'PRODUCT_CONNECTION_STATE_TRANSITION_DERIVED_PROJECTION';

    public const STORED_NEW = 'STORED_NEW';
    public const EXACT_DUPLICATE = 'EXACT_DUPLICATE';
    public const CHANGED_INPUT_REUSE_REJECTED = 'CHANGED_INPUT_REUSE_REJECTED';
    public const CONFLICTING_EQUAL_REVISION_REJECTED = 'CONFLICTING_EQUAL_REVISION_REJECTED';
    public const INCOMPARABLE_COEXISTS = 'INCOMPARABLE_COEXISTS';
    public const INVALID_RECORD_REJECTED = 'INVALID_RECORD_REJECTED';

    public const FOUND = 'FOUND';
    public const RESOLVED = 'RESOLVED';
    public const MISSING = 'MISSING';
    public const UNKNOWN = 'UNKNOWN';
    public const ABSENT = 'ABSENT';
    public const UNAVAILABLE = 'UNAVAILABLE';
    public const STALE = 'STALE';
    public const SUPERSEDED = 'SUPERSEDED';
    public const CONFLICTING = 'CONFLICTING';
    public const INCOMPARABLE = 'INCOMPARABLE';
    public const INVALIDATED = 'INVALIDATED';

    private const RECORD_KEYS = [
        'logical_record_identity',
        'record_family',
        'bindings',
        'source_revision',
        'source_condition',
        'currentness',
        'freshness',
        'logical_intent',
        'authoritative_outcome',
        'authoritative_outcome_metadata',
        'correction_metadata',
        'projection_metadata',
        'transport_observation',
        'private_fixture_extensions',
    ];

    private const RR03_PAYLOAD_KEYS = [
        'payload_kind',
        'derived_fact_class',
        'classification',
        'prerequisite_set_state',
        'prerequisite_set_identity',
        'prerequisite_set_revision',
        'prerequisite_set_condition',
        'prerequisite_set_currentness',
        'prerequisite_set_freshness',
        'protected_use_scope',
        'reason_categories',
        'dependencies',
        'invalidation',
    ];

    private const RR03_DEPENDENCY_KEYS = [
        'dependency_identity',
        'fact_class',
        'authority_owner',
        'authority_scope',
        'aggregate_context',
        'source_lineage',
        'source_revision_value',
        'source_condition',
        'currentness',
        'freshness',
        'prerequisite_outcome',
    ];

    private const RR03_REASON_CATEGORIES = [
        'UNKNOWN_PREREQUISITE_SET',
        'INVALID_PREREQUISITE_SET',
        'PREREQUISITE_SET_UNUSABLE',
        'MISSING_REQUIRED_MEMBER',
        'INVALID_REQUIRED_MEMBER',
        'INCOMPARABLE_DUPLICATE_EVIDENCE',
        'CONFLICTING_DUPLICATE_EVIDENCE',
        'INVALID_MEMBER_FACT_CLASS',
        'PROTECTED_USE_SCOPE_MISMATCH',
        'MEMBER_UNUSABLE',
        'UNKNOWN_MEMBER_OUTCOME',
        'AUTHORITATIVE_REQUIRED_MEMBER_UNSATISFIED',
        'DEPENDENCY_INVALIDATED',
    ];

    private const MATCH_PAYLOAD_KEYS = [
        'payload_kind',
        'derived_fact_class',
        'classification',
        'proposal_identity',
        'protected_use_scope',
        'reason_categories',
        'proposal_dependency',
        'participation_dependencies',
        'decision_slot_dependencies',
        'terminality',
        'invalidation',
    ];

    private const MATCH_PROPOSAL_DEPENDENCY_KEYS = [
        'proposal_identity',
        'lifecycle_state',
        'terminal',
        'authority_owner',
        'authority_scope',
        'aggregate_context',
        'source_lineage',
        'source_revision_value',
        'source_condition',
        'currentness',
        'freshness',
    ];

    private const MATCH_PARTICIPATION_DEPENDENCY_KEYS = [
        'participant_identity',
        'state',
        'authority_owner',
        'authority_scope',
        'aggregate_context',
        'source_lineage',
        'source_revision_value',
        'source_condition',
        'currentness',
        'freshness',
    ];

    private const MATCH_SLOT_DEPENDENCY_KEYS = [
        'slot_identity',
        'proposal_identity',
        'participant_identity',
        'decision',
        'authority_owner',
        'authority_scope',
        'aggregate_context',
        'source_lineage',
        'source_revision_value',
        'source_condition',
        'currentness',
        'freshness',
    ];

    private const MATCH_CLASSIFICATIONS = [
        'PENDING',
        'MUTUALLY_ACCEPTED',
        'DECLINED',
        'WITHDRAWN',
        'EXPIRED',
        'UNKNOWN',
    ];

    private const MATCH_TERMINAL_CLASSIFICATIONS = [
        'MUTUALLY_ACCEPTED',
        'DECLINED',
        'WITHDRAWN',
        'EXPIRED',
    ];

    private const MATCH_REASON_CATEGORIES = [
        'PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE',
        'UNRESOLVED_PROPOSAL_PRECONDITION_NOT_ESTABLISHED',
        'INVALID_PARTICIPATION_EVIDENCE_SET',
        'MISSING_PARTICIPATION',
        'PARTICIPATION_NOT_USABLE',
        'PARTICIPATION_PREVENTS_ACCEPTANCE',
        'CROSS_PROPOSAL_SLOT',
        'WRONG_PARTICIPANT_SLOT',
        'MISSING_DECISION_SLOT',
        'CONFLICTING_SLOT_IDENTITY',
        'INCOMPARABLE_DUPLICATE_SLOT',
        'CONFLICTING_EQUAL_REVISION_SLOT',
        'DECISION_SLOT_NOT_CURRENT_FRESH_BOUND',
        'CONFLICTING_TERMINAL_SLOT_DECISIONS',
        'DEPENDENCY_INVALIDATED',
    ];

    private const PRODUCT_CONNECTION_CURRENT_PAYLOAD_KEYS = [
        'payload_kind',
        'derived_fact_class',
        'connection_identity',
        'participant_references',
        'protected_use_scope',
        'classification',
        'current_state',
        'reason_categories',
        'current_state_dependency',
        'connection_active_for_downstream_consideration',
        'valid_for_protected_use',
        'terminality',
        'invalidation',
    ];

    private const PRODUCT_CONNECTION_TRANSITION_PAYLOAD_KEYS = [
        'payload_kind',
        'derived_fact_class',
        'connection_identity',
        'participant_references',
        'protected_use_scope',
        'classification',
        'current_state',
        'proposed_state',
        'reason_categories',
        'current_state_dependency',
        'transition_dependency',
        'connection_active_for_downstream_consideration',
        'valid_for_protected_use',
        'terminality',
        'invalidation',
    ];

    private const PRODUCT_CONNECTION_CURRENT_DEPENDENCY_KEYS = [
        'dependency_type',
        'state_evidence_identity',
        'connection_identity',
        'state',
        'authority_owner',
        'authority_scope',
        'aggregate_context',
        'source_lineage',
        'source_revision_value',
        'source_condition',
        'protected_binding_satisfied',
        'currentness',
        'freshness',
    ];

    private const PRODUCT_CONNECTION_TRANSITION_DEPENDENCY_KEYS = [
        'dependency_type',
        'transition_identity',
        'connection_identity',
        'from_state',
        'to_state',
        'expected_state_revision',
        'authority_owner',
        'authority_scope',
        'aggregate_context',
        'source_lineage',
        'source_revision_value',
        'source_condition',
        'protected_binding_satisfied',
        'currentness',
        'freshness',
    ];

    private const PRODUCT_CONNECTION_STATES = [
        'CN_NONE',
        'CN_PENDING',
        'CN_ACTIVE',
        'CN_PAUSED',
        'CN_CLOSED',
        'CN_DECLINED',
        'CN_WITHDRAWN',
        'CN_EXPIRED',
    ];

    private const PRODUCT_CONNECTION_TERMINAL_STATES = [
        'CN_CLOSED',
        'CN_DECLINED',
        'CN_WITHDRAWN',
        'CN_EXPIRED',
    ];

    private const PRODUCT_CONNECTION_CURRENT_REASONS = [
        'MISSING_CURRENT_STATE_EVIDENCE',
        'CROSS_CONNECTION_STATE_EVIDENCE',
        'STATE_PARTICIPANT_MISMATCH',
        'CONFLICTING_STATE_EVIDENCE_IDENTITY',
        'INCOMPARABLE_DUPLICATE_STATE_EVIDENCE',
        'CONFLICTING_EQUAL_REVISION_STATE_EVIDENCE',
        'CURRENT_STATE_NOT_CURRENT_FRESH_BOUND',
        'DEPENDENCY_INVALIDATED',
    ];

    private const PRODUCT_CONNECTION_TRANSITION_REASONS = [
        'MISSING_CURRENT_STATE_EVIDENCE',
        'CROSS_CONNECTION_STATE_EVIDENCE',
        'STATE_PARTICIPANT_MISMATCH',
        'CONFLICTING_STATE_EVIDENCE_IDENTITY',
        'INCOMPARABLE_DUPLICATE_STATE_EVIDENCE',
        'CONFLICTING_EQUAL_REVISION_STATE_EVIDENCE',
        'CURRENT_STATE_NOT_CURRENT_FRESH_BOUND',
        'MISSING_TRANSITION_EVIDENCE',
        'CROSS_CONNECTION_TRANSITION_EVIDENCE',
        'TRANSITION_PARTICIPANT_MISMATCH',
        'CONFLICTING_TRANSITION_IDENTITY',
        'INCOMPARABLE_DUPLICATE_TRANSITION_EVIDENCE',
        'CONFLICTING_EQUAL_REVISION_TRANSITION_EVIDENCE',
        'TRANSITION_NOT_CURRENT_FRESH_BOUND',
        'TRANSITION_CURRENT_CONTEXT_MISMATCH',
        'TERMINAL_CONNECTION_IDENTITY_CANNOT_REOPEN',
        'DIRECT_NONE_TO_ACTIVE_REJECTED',
        'TRANSITION_NOT_ALLOWED',
        'DEPENDENCY_INVALIDATED',
    ];

    /** @var array<string, array<string, mixed>> */
    private array $records = [];

    /** @var array<string, string> */
    private array $inputFingerprints = [];

    /** @var array<string, array{logical_record_identity: string, intent_fingerprint: string}> */
    private array $intentBindings = [];

    /** @var array<string, array<string, mixed>> */
    private array $invalidations = [];

    /**
     * @param array<string, mixed> $record
     * @return array<string, mixed>
     */
    public function store(array $record): array
    {
        $validated = $this->validateRecord($record);

        if (($validated['valid'] ?? false) !== true) {
            return $this->storageResult(
                self::INVALID_RECORD_REJECTED,
                false,
                is_string($validated['reason'] ?? null) ? $validated['reason'] : 'INVALID_RECORD',
            );
        }

        /** @var array<string, mixed> $normalized */
        $normalized = $validated['record'];
        $identity = $normalized['logical_record_identity'];
        $inputFingerprint = $validated['input_fingerprint'];
        $intentIdentity = $normalized['logical_intent_identity'];
        $intentFingerprint = $validated['intent_fingerprint'];

        if (isset($this->records[$identity])) {
            if ($this->inputFingerprints[$identity] === $inputFingerprint) {
                return $this->storageResult(
                    self::EXACT_DUPLICATE,
                    false,
                    'EXACT_LOGICAL_IDENTITY_AND_SEMANTIC_INPUT',
                    $identity,
                    true,
                );
            }

            if (($this->records[$identity]['logical_intent_identity'] ?? null) === $intentIdentity) {
                return $this->storageResult(
                    self::CHANGED_INPUT_REUSE_REJECTED,
                    false,
                    'LOGICAL_IDENTITY_REUSED_WITH_CHANGED_SEMANTIC_INPUT',
                    $identity,
                );
            }

            return $this->storageResult(
                self::INVALID_RECORD_REJECTED,
                false,
                'LOGICAL_RECORD_IDENTITY_REUSE_REJECTED',
                $identity,
            );
        }

        if (isset($this->intentBindings[$intentIdentity])) {
            $registered = $this->intentBindings[$intentIdentity];

            if ($registered['intent_fingerprint'] !== $intentFingerprint) {
                return $this->storageResult(
                    self::CHANGED_INPUT_REUSE_REJECTED,
                    false,
                    'IMMUTABLE_INTENT_CHANGED_INPUT',
                    $identity,
                );
            }

            return $this->storageResult(
                self::INVALID_RECORD_REJECTED,
                false,
                'INTENT_IDENTITY_REUSED_FOR_DIFFERENT_LOGICAL_RECORD',
                $identity,
            );
        }

        foreach ($this->records as $existing) {
            if (
                ($existing['bindings']['lifecycle_identity'] ?? null) === $normalized['bindings']['lifecycle_identity']
                && ($existing['bindings']['terminal'] ?? false) === true
                && ($normalized['bindings']['terminal'] ?? null) !== true
            ) {
                return $this->storageResult(
                    self::INVALID_RECORD_REJECTED,
                    false,
                    'TERMINAL_IDENTITY_REOPEN_REJECTED',
                    $identity,
                );
            }
        }

        $incomparableExists = false;

        foreach ($this->records as $existing) {
            if (($existing['record_family'] ?? null) !== $normalized['record_family']) {
                continue;
            }

            $comparison = CommonAuthorityEvidenceContract::compareSourceRevisions(
                $existing['source_revision'],
                $normalized['source_revision'],
            );

            if ($comparison === CommonAuthorityEvidenceContract::REVISION_EQUAL) {
                return $this->storageResult(
                    self::CONFLICTING_EQUAL_REVISION_REJECTED,
                    false,
                    'EQUAL_SOURCE_LOCAL_REVISION_WITH_CONFLICTING_RECORD',
                    $identity,
                );
            }

            if ($comparison === CommonAuthorityEvidenceContract::CONDITION_INCOMPARABLE) {
                $incomparableExists = true;
            }
        }

        $this->records[$identity] = $normalized;
        $this->inputFingerprints[$identity] = $inputFingerprint;
        $this->intentBindings[$intentIdentity] = [
            'logical_record_identity' => $identity,
            'intent_fingerprint' => $intentFingerprint,
        ];

        return $this->storageResult(
            $incomparableExists ? self::INCOMPARABLE_COEXISTS : self::STORED_NEW,
            true,
            $incomparableExists ? 'INCOMPARABLE_SOURCE_LOCAL_RECORDS_RETAINED' : 'NEW_LOGICAL_RECORD_STORED',
            $identity,
        );
    }

    /** @return array<string, mixed> */
    public function readExact(string $logicalRecordIdentity): array
    {
        if (! isset($this->records[$logicalRecordIdentity])) {
            return $this->readResult(self::MISSING, null, 'LOGICAL_RECORD_IDENTITY_NOT_FOUND');
        }

        return $this->readResult(
            self::FOUND,
            $this->project($this->records[$logicalRecordIdentity]),
            'EXACT_LOGICAL_RECORD_IDENTITY_FOUND',
        );
    }

    /**
     * @param array<string, mixed> $query
     * @return array<string, mixed>
     */
    public function resolveCurrent(array $query): array
    {
        if (! $this->validQuery($query, false)) {
            return $this->resolutionResult(self::UNKNOWN, null, 'INVALID_EXACT_CONTEXT_QUERY');
        }

        $candidates = array_values(array_filter(
            $this->records,
            static fn (array $record): bool => $record['record_family'] === $query['record_family']
                && $record['bindings']['authority_owner'] === $query['authority_owner']
                && $record['bindings']['authority_scope'] === $query['authority_scope']
                && $record['bindings']['aggregate_context'] === $query['aggregate_context'],
        ));

        if ($candidates === []) {
            return $this->resolutionResult(self::MISSING, null, 'EXACT_LOGICAL_CONTEXT_NOT_FOUND');
        }

        $lineage = $query['lineage'] ?? null;

        if ($lineage === null) {
            $lineages = array_values(array_unique(array_map(
                static fn (array $record): string => $record['source_revision']['lineage'],
                $candidates,
            )));

            if (count($lineages) !== 1) {
                return $this->resolutionResult(
                    self::INCOMPARABLE,
                    null,
                    'MULTIPLE_INCOMPARABLE_LINEAGES_REQUIRE_EXACT_LINEAGE',
                );
            }

            $lineage = $lineages[0];
        }

        $candidates = array_values(array_filter(
            $candidates,
            static fn (array $record): bool => $record['source_revision']['lineage'] === $lineage,
        ));

        if ($candidates === []) {
            return $this->resolutionResult(self::MISSING, null, 'EXACT_SOURCE_LOCAL_LINEAGE_NOT_FOUND');
        }

        usort($candidates, static function (array $left, array $right): int {
            $revisionOrder = $left['source_revision']['value'] <=> $right['source_revision']['value'];

            return $revisionOrder !== 0
                ? $revisionOrder
                : $left['logical_record_identity'] <=> $right['logical_record_identity'];
        });

        $selected = $candidates[array_key_last($candidates)];
        $projection = $this->project($selected);
        $identity = $selected['logical_record_identity'];

        if (isset($this->invalidations[$identity])) {
            return $this->resolutionResult(self::INVALIDATED, $projection, 'DEPENDENCY_OR_PROJECTION_INVALIDATED');
        }

        $conditionResolution = match ($selected['source_condition']) {
            CommonAuthorityEvidenceContract::CONDITION_PRESENT => null,
            CommonAuthorityEvidenceContract::CONDITION_ABSENT => self::ABSENT,
            CommonAuthorityEvidenceContract::CONDITION_UNKNOWN => self::UNKNOWN,
            CommonAuthorityEvidenceContract::CONDITION_UNAVAILABLE => self::UNAVAILABLE,
            CommonAuthorityEvidenceContract::CONDITION_STALE => self::STALE,
            CommonAuthorityEvidenceContract::CONDITION_SUPERSEDED => self::SUPERSEDED,
            CommonAuthorityEvidenceContract::CONDITION_INCOMPARABLE => self::INCOMPARABLE,
        };

        if ($conditionResolution !== null) {
            return $this->resolutionResult(
                $conditionResolution,
                $projection,
                'SOURCE_CONDITION_'.$selected['source_condition'],
            );
        }

        if ($selected['currentness'] !== true) {
            return $this->resolutionResult(self::UNKNOWN, $projection, 'SOURCE_CURRENTNESS_NOT_ESTABLISHED');
        }

        if ($selected['freshness'] !== true) {
            return $this->resolutionResult(self::STALE, $projection, 'SOURCE_FRESHNESS_NOT_ESTABLISHED');
        }

        return $this->resolutionResult(self::RESOLVED, $projection, 'EXACT_COMPARABLE_RECORD_RESOLVED');
    }

    /**
     * @param array<string, mixed> $query
     * @return array<string, mixed>
     */
    public function readHistory(array $query): array
    {
        if (! $this->validQuery($query, true)) {
            return array_merge($this->readResult(self::UNKNOWN, null, 'INVALID_EXACT_LINEAGE_QUERY'), [
                'records' => [],
            ]);
        }

        $records = array_values(array_filter(
            $this->records,
            static fn (array $record): bool => $record['record_family'] === $query['record_family']
                && $record['bindings']['authority_owner'] === $query['authority_owner']
                && $record['bindings']['authority_scope'] === $query['authority_scope']
                && $record['bindings']['aggregate_context'] === $query['aggregate_context']
                && $record['source_revision']['lineage'] === $query['lineage'],
        ));

        usort($records, static function (array $left, array $right): int {
            $revisionOrder = $left['source_revision']['value'] <=> $right['source_revision']['value'];

            return $revisionOrder !== 0
                ? $revisionOrder
                : $left['logical_record_identity'] <=> $right['logical_record_identity'];
        });

        if ($records === []) {
            return array_merge($this->readResult(self::MISSING, null, 'EXACT_SOURCE_LOCAL_HISTORY_NOT_FOUND'), [
                'records' => [],
            ]);
        }

        return array_merge($this->readResult(self::RESOLVED, null, 'EXACT_SOURCE_LOCAL_HISTORY_RESOLVED'), [
            'records' => array_map(fn (array $record): array => $this->project($record), $records),
        ]);
    }

    /** @return array<string, mixed> */
    public function observeInvalidation(string $logicalRecordIdentity, string $relation): array
    {
        if (! isset($this->records[$logicalRecordIdentity])) {
            return $this->readResult(self::MISSING, null, 'INVALIDATION_TARGET_NOT_FOUND');
        }

        try {
            $invalidation = CommonAuthorityEvidenceContract::invalidate(
                $this->records[$logicalRecordIdentity]['source_evidence'],
                $relation,
            );
        } catch (InvalidArgumentException) {
            return $this->readResult(self::UNKNOWN, null, 'INVALID_INVALIDATION_RELATION');
        }

        $this->invalidations[$logicalRecordIdentity] = $invalidation;

        return $this->readResult(
            self::INVALIDATED,
            $this->project($this->records[$logicalRecordIdentity]),
            'DEPENDENT_PROJECTION_INVALIDATED_WITHOUT_LIFECYCLE_RESET',
        );
    }

    /** @return array<string, mixed> */
    public function privacyMinimalProjection(string $logicalRecordIdentity): array
    {
        if (! isset($this->records[$logicalRecordIdentity])) {
            return $this->readResult(self::MISSING, null, 'PROJECTION_SOURCE_NOT_FOUND');
        }

        return $this->readResult(
            self::FOUND,
            $this->project($this->records[$logicalRecordIdentity]),
            'PRIVACY_MINIMAL_NON_AUTHORITATIVE_PROJECTION',
        );
    }

    public function count(): int
    {
        return count($this->records);
    }

    /**
     * @param array<string, mixed> $record
     * @return array<string, mixed>
     */
    private function validateRecord(array $record): array
    {
        $keys = array_keys($record);
        sort($keys);
        $expected = self::RECORD_KEYS;
        sort($expected);

        $expectedWithDerivedPayload = [...$expected, 'derived_projection_payload'];
        sort($expectedWithDerivedPayload);

        if ($keys !== $expected && $keys !== $expectedWithDerivedPayload) {
            return ['valid' => false, 'reason' => 'LOGICAL_RECORD_FIELDS_MUST_MATCH_EXACT_CONTRACT'];
        }

        if (
            ! is_string($record['logical_record_identity'])
            || $record['logical_record_identity'] === ''
            || ! is_string($record['record_family'])
            || $record['record_family'] === ''
        ) {
            return ['valid' => false, 'reason' => 'LOGICAL_IDENTITY_AND_FAMILY_REQUIRED'];
        }

        if (
            ! is_array($record['bindings'])
            || ! is_array($record['source_revision'])
            || ! is_string($record['source_condition'])
            || (! is_bool($record['currentness']) && $record['currentness'] !== null)
            || (! is_bool($record['freshness']) && $record['freshness'] !== null)
            || ! is_array($record['logical_intent'])
            || ! is_string($record['authoritative_outcome'])
            || ! is_array($record['projection_metadata'])
            || ! is_string($record['transport_observation'])
            || ! is_array($record['private_fixture_extensions'])
        ) {
            return ['valid' => false, 'reason' => 'MALFORMED_LOGICAL_RECORD'];
        }

        $isRr03 = $record['record_family'] === self::RECORD_FAMILY_RR03;
        $isCanonicalMatch = $record['record_family'] === self::RECORD_FAMILY_CANONICAL_MATCH;
        $isProductConnection = $record['record_family'] === self::RECORD_FAMILY_PRODUCT_CONNECTION;

        if ($isRr03) {
            if (! array_key_exists('derived_projection_payload', $record)
                || ! is_array($record['derived_projection_payload'])
                || ! $this->validRr03Payload($record['derived_projection_payload'])) {
                return ['valid' => false, 'reason' => 'INVALID_RR03_DERIVED_PROJECTION_PAYLOAD'];
            }

            if (
                ($record['source_revision']['authority_owner'] ?? null) !== 'RUNTIME_READINESS_DERIVATION'
                || ($record['source_revision']['value'] ?? null) !== 0
                || $record['source_condition'] !== CommonAuthorityEvidenceContract::CONDITION_PRESENT
                || $record['authoritative_outcome'] !== CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN
                || $record['authoritative_outcome_metadata'] !== null
            ) {
                return ['valid' => false, 'reason' => 'INVALID_RR03_REVISION_OR_AUTHORITY_BOUNDARY'];
            }
        } elseif ($isCanonicalMatch) {
            if (! array_key_exists('derived_projection_payload', $record)
                || ! is_array($record['derived_projection_payload'])
                || ! $this->validCanonicalMatchRecord($record)) {
                return ['valid' => false, 'reason' => 'INVALID_CANONICAL_MATCH_DERIVED_PROJECTION'];
            }
        } elseif ($isProductConnection) {
            if (! array_key_exists('derived_projection_payload', $record)
                || ! is_array($record['derived_projection_payload'])
                || ! $this->validProductConnectionRecord($record)) {
                return ['valid' => false, 'reason' => 'INVALID_PRODUCT_CONNECTION_DERIVED_PROJECTION'];
            }
        } elseif (($record['derived_projection_payload'] ?? null) !== null) {
            return ['valid' => false, 'reason' => 'DERIVED_PAYLOAD_NOT_ALLOWED_FOR_RECORD_FAMILY'];
        }

        $fingerprintRecord = $record;

        if (! $isRr03 && ! $isCanonicalMatch && ! $isProductConnection) {
            unset($fingerprintRecord['derived_projection_payload']);
        }

        try {
            $evidence = CommonAuthorityEvidenceContract::evidence(
                $record['bindings'],
                $record['source_condition'],
                $record['source_revision'],
                $record['currentness'],
                $record['freshness'],
                $record['authoritative_outcome'],
            );
            $intent = CommonAuthorityEvidenceContract::bindIntent(
                $record['logical_intent']['intent_identity'] ?? '',
                is_array($record['logical_intent']['semantic_input'] ?? null)
                    ? $record['logical_intent']['semantic_input']
                    : [],
            );
            $transportOutcome = CommonAuthorityEvidenceContract::outcomeAfterTransport(
                $record['transport_observation'],
            );
        } catch (InvalidArgumentException) {
            return ['valid' => false, 'reason' => 'COMMON_AUTHORITY_CONTRACT_REJECTED_RECORD'];
        }

        $authoritativeMetadata = $record['authoritative_outcome_metadata'];

        if ($authoritativeMetadata !== null) {
            $authoritativeMetadataKeys = is_array($authoritativeMetadata)
                ? array_keys($authoritativeMetadata)
                : [];
            sort($authoritativeMetadataKeys);

            if (
                ! is_array($authoritativeMetadata)
                || $authoritativeMetadataKeys !== ['outcome_reference', 'source_carried']
                || ($authoritativeMetadata['source_carried'] ?? null) !== true
                || ! is_string($authoritativeMetadata['outcome_reference'] ?? null)
                || $authoritativeMetadata['outcome_reference'] === ''
            ) {
                return ['valid' => false, 'reason' => 'AUTHORITATIVE_OUTCOME_METADATA_MUST_BE_SOURCE_CARRIED'];
            }
        }

        $correctionMetadata = $record['correction_metadata'];

        if ($correctionMetadata !== null) {
            $correctionMetadataKeys = is_array($correctionMetadata)
                ? array_keys($correctionMetadata)
                : [];
            sort($correctionMetadataKeys);

            if (
                ! is_array($correctionMetadata)
                || $correctionMetadataKeys !== ['displaced_record_identity', 'relation']
                || ! in_array($correctionMetadata['relation'] ?? null, [
                    CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
                    CommonAuthorityEvidenceContract::INVALIDATION_REVOCATION,
                    CommonAuthorityEvidenceContract::INVALIDATION_SUPERSESSION,
                ], true)
                || ! is_string($correctionMetadata['displaced_record_identity'] ?? null)
                || $correctionMetadata['displaced_record_identity'] === ''
            ) {
                return ['valid' => false, 'reason' => 'INVALID_CORRECTION_METADATA'];
            }
        }

        $projectionMetadata = $record['projection_metadata'];
        $projectionKeys = array_keys($projectionMetadata);
        sort($projectionKeys);

        if (
            $projectionKeys !== [
                'lag_classification',
                'projection_currentness',
                'projection_identity',
                'represented_source_revision_value',
            ]
            || ! is_string($projectionMetadata['projection_identity'] ?? null)
            || $projectionMetadata['projection_identity'] === ''
            || ! is_int($projectionMetadata['represented_source_revision_value'] ?? null)
            || ! is_string($projectionMetadata['lag_classification'] ?? null)
            || ! in_array($projectionMetadata['lag_classification'], ['CURRENT', 'LAGGED', 'UNKNOWN'], true)
            || (! is_bool($projectionMetadata['projection_currentness'] ?? null)
                && ($projectionMetadata['projection_currentness'] ?? null) !== null)
        ) {
            return ['valid' => false, 'reason' => 'INVALID_PROJECTION_METADATA'];
        }

        if ($projectionMetadata['represented_source_revision_value'] < 0) {
            return ['valid' => false, 'reason' => 'INVALID_PROJECTION_REVISION'];
        }

        $intentFingerprint = $this->fingerprint([
            'record_family' => $record['record_family'],
            'bindings' => $record['bindings'],
            'source_revision' => $record['source_revision'],
            'logical_intent_semantic_input' => $intent['semantic_input'],
        ]);

        return [
            'valid' => true,
            'input_fingerprint' => $this->fingerprint($fingerprintRecord),
            'intent_fingerprint' => $intentFingerprint,
            'record' => [
                'record_kind' => 'IN_MEMORY_LOGICAL_PERSISTENCE_STORED_RECORD',
                'logical_record_identity' => $record['logical_record_identity'],
                'record_family' => $record['record_family'],
                'bindings' => $record['bindings'],
                'source_revision' => $record['source_revision'],
                'source_condition' => $record['source_condition'],
                'currentness' => $record['currentness'],
                'freshness' => $record['freshness'],
                'logical_intent_identity' => $intent['intent_identity'],
                'logical_intent_fingerprint' => $this->fingerprint($intent['semantic_input']),
                'authoritative_outcome' => $record['authoritative_outcome'],
                'authoritative_outcome_metadata' => $authoritativeMetadata,
                'correction_metadata' => $correctionMetadata,
                'projection_metadata' => $projectionMetadata,
                'transport_observation' => $record['transport_observation'],
                'transport_authoritative_outcome' => $transportOutcome,
                'source_evidence' => $evidence,
                'derived_projection_payload' => ($isRr03 || $isCanonicalMatch || $isProductConnection)
                    ? $record['derived_projection_payload']
                    : null,
            ],
        ];
    }

    /** @param array<string, mixed> $record */
    private function validProductConnectionRecord(array $record): bool
    {
        $payload = $record['derived_projection_payload'] ?? null;

        if (! is_array($payload) || $this->containsPrivateSentinel($payload)) {
            return false;
        }

        $currentFact = ($payload['payload_kind'] ?? null) === 'PRODUCT_CONNECTION_CURRENT_STATE'
            && ($payload['derived_fact_class'] ?? null) === 'PRODUCT_CONNECTION_CURRENT_STATE_DERIVATION';
        $transitionFact = ($payload['payload_kind'] ?? null) === 'PRODUCT_CONNECTION_TRANSITION'
            && ($payload['derived_fact_class'] ?? null) === 'PRODUCT_CONNECTION_TRANSITION_DERIVATION';

        if ((! $currentFact && ! $transitionFact)
            || ! $this->hasExactKeys(
                $payload,
                $currentFact
                    ? self::PRODUCT_CONNECTION_CURRENT_PAYLOAD_KEYS
                    : self::PRODUCT_CONNECTION_TRANSITION_PAYLOAD_KEYS,
            )
            || ! $this->nonEmptyString($payload['connection_identity'] ?? null)
            || ! $this->nonEmptyString($payload['protected_use_scope'] ?? null)) {
            return false;
        }

        $participants = $payload['participant_references'] ?? null;

        if (! is_array($participants)
            || ! array_is_list($participants)
            || count($participants) !== 2
            || ! $this->allNonEmptyStrings($participants)
            || count(array_unique($participants)) !== 2) {
            return false;
        }

        $sortedParticipants = $participants;
        sort($sortedParticipants, SORT_STRING);

        if ($participants !== $sortedParticipants) {
            return false;
        }

        $reasonVocabulary = $currentFact
            ? self::PRODUCT_CONNECTION_CURRENT_REASONS
            : self::PRODUCT_CONNECTION_TRANSITION_REASONS;
        $reasons = $payload['reason_categories'] ?? null;

        if (! is_array($reasons)
            || ! array_is_list($reasons)
            || count($reasons) !== count(array_unique($reasons))
            || $reasons !== array_values(array_filter(
                $reasonVocabulary,
                static fn (string $reason): bool => in_array($reason, $reasons, true),
            ))) {
            return false;
        }

        $currentDependency = $payload['current_state_dependency'] ?? null;
        $transitionDependency = $transitionFact ? ($payload['transition_dependency'] ?? null) : null;

        if (($currentDependency !== null
                && (! is_array($currentDependency)
                    || ! $this->validProductConnectionCurrentDependency(
                        $currentDependency,
                        $payload['connection_identity'],
                    )))
            || ($transitionDependency !== null
                && (! is_array($transitionDependency)
                    || ! $this->validProductConnectionTransitionDependency(
                        $transitionDependency,
                        $payload['connection_identity'],
                    )))) {
            return false;
        }

        if (is_array($currentDependency)
            && is_array($transitionDependency)
            && $currentDependency['state_evidence_identity'] === $transitionDependency['transition_identity']) {
            return false;
        }

        $invalidation = $payload['invalidation'] ?? null;

        if (! is_array($invalidation)
            || ! $this->hasExactKeys($invalidation, [
                'invalidated',
                'relation',
                'dependency_identity',
                'lifecycle_reset',
                'connection_reopened',
            ])
            || ! is_bool($invalidation['invalidated'] ?? null)
            || ($invalidation['lifecycle_reset'] ?? null) !== false
            || ($invalidation['connection_reopened'] ?? null) !== false) {
            return false;
        }

        $dependencyIdentities = array_values(array_filter([
            is_array($currentDependency) ? $currentDependency['state_evidence_identity'] : null,
            is_array($transitionDependency) ? $transitionDependency['transition_identity'] : null,
        ], static fn (mixed $identity): bool => is_string($identity)));

        if ($invalidation['invalidated']) {
            if ($reasons !== ['DEPENDENCY_INVALIDATED']
                || ! in_array($invalidation['relation'] ?? null, [
                    CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
                    CommonAuthorityEvidenceContract::INVALIDATION_REVOCATION,
                    CommonAuthorityEvidenceContract::INVALIDATION_SUPERSESSION,
                ], true)
                || ! $this->nonEmptyString($invalidation['dependency_identity'] ?? null)
                || count(array_filter(
                    $dependencyIdentities,
                    static fn (string $identity): bool => $identity === $invalidation['dependency_identity'],
                )) !== 1) {
                return false;
            }
        } elseif ($invalidation['relation'] !== null
            || $invalidation['dependency_identity'] !== null
            || in_array('DEPENDENCY_INVALIDATED', $reasons, true)) {
            return false;
        }

        $expectedCurrentness = $this->productConnectionAggregate(
            $currentDependency,
            $transitionDependency,
            'currentness',
            $transitionFact,
        );
        $expectedFreshness = $this->productConnectionAggregate(
            $currentDependency,
            $transitionDependency,
            'freshness',
            $transitionFact,
        );

        if ($record['currentness'] !== $expectedCurrentness
            || $record['freshness'] !== $expectedFreshness
            || ! $this->validProductConnectionPayloadMatrix(
                $payload,
                $currentDependency,
                $transitionDependency,
                $currentFact,
                $expectedCurrentness,
                $expectedFreshness,
            )) {
            return false;
        }

        $bindings = $record['bindings'] ?? null;
        $sourceRevision = $record['source_revision'] ?? null;
        $projection = $record['projection_metadata'] ?? null;
        $intent = $record['logical_intent'] ?? null;
        $scope = $payload['derived_fact_class'].'|'.$payload['protected_use_scope'];

        if (! is_array($bindings)
            || ! is_array($sourceRevision)
            || ! is_array($projection)
            || ! is_array($intent)
            || ! $this->hasExactKeys($intent, ['intent_identity', 'semantic_input'])
            || ($bindings['authority_owner'] ?? null) !== 'PRODUCT_CONNECTION_DERIVATION'
            || ($bindings['authority_scope'] ?? null) !== $scope
            || ($bindings['actor'] ?? null) !== 'PRODUCT_CONNECTION_DERIVATION'
            || ($bindings['actor_role'] ?? null) !== 'DERIVED_NON_AUTHORITATIVE_CORRELATION'
            || ($bindings['subject'] ?? null) !== $payload['connection_identity']
            || ($bindings['participants'] ?? null) !== $participants
            || ($bindings['audience'] ?? null) !== 'INTERNAL_APPLICATION_PERSISTENCE'
            || ($bindings['purpose'] ?? null) !== $payload['protected_use_scope']
            || ($bindings['aggregate_context'] ?? null) !== $payload['connection_identity']
            || ($bindings['terminal'] ?? null) !== ($payload['terminality']['current_state_terminal'] ?? null)
            || ($sourceRevision['authority_owner'] ?? null) !== 'PRODUCT_CONNECTION_DERIVATION'
            || ($sourceRevision['authority_scope'] ?? null) !== $scope
            || ($sourceRevision['aggregate_context'] ?? null) !== $payload['connection_identity']
            || ($sourceRevision['value'] ?? null) !== 0
            || $record['source_condition'] !== CommonAuthorityEvidenceContract::CONDITION_PRESENT
            || $record['authoritative_outcome'] !== CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN
            || $record['authoritative_outcome_metadata'] !== null
            || $record['correction_metadata'] !== null
            || $record['transport_observation'] !== 'AMBIGUOUS'
            || $record['private_fixture_extensions'] !== []) {
            return false;
        }

        $lifecycleBasis = [
            'record_family' => self::RECORD_FAMILY_PRODUCT_CONNECTION,
            'authority_owner' => 'PRODUCT_CONNECTION_DERIVATION',
            'actor' => 'PRODUCT_CONNECTION_DERIVATION',
            'actor_role' => 'DERIVED_NON_AUTHORITATIVE_CORRELATION',
            'connection_identity' => $payload['connection_identity'],
            'protected_use_scope' => $payload['protected_use_scope'],
            'subject' => $payload['connection_identity'],
            'participants' => $participants,
            'audience' => 'INTERNAL_APPLICATION_PERSISTENCE',
            'purpose' => $payload['protected_use_scope'],
            'aggregate_context' => $payload['connection_identity'],
        ];
        $expectedLifecycle = 'product-connection-lifecycle-v1:'.$this->fingerprint($lifecycleBasis);

        if (($bindings['lifecycle_identity'] ?? null) !== $expectedLifecycle) {
            return false;
        }

        $schemaMarker = $currentFact
            ? 'product-connection-current-state-derived-projection-v1'
            : 'product-connection-transition-derived-projection-v1';
        $semanticInput = [
            'record_family' => self::RECORD_FAMILY_PRODUCT_CONNECTION,
            'derived_fact_class' => $payload['derived_fact_class'],
            'bindings' => $bindings,
            'derived_projection_payload' => $payload,
            'schema_marker' => $schemaMarker,
        ];
        $digest = $this->fingerprint($semanticInput);
        $expectedLag = match ($record['currentness']) {
            true => 'CURRENT',
            false => 'LAGGED',
            null => 'UNKNOWN',
        };

        return $record['logical_record_identity'] === 'product-connection-record-v1:'.$digest
            && ($intent['intent_identity'] ?? null) === 'product-connection-intent-v1:'.$digest
            && ($intent['semantic_input'] ?? null) === $semanticInput
            && ($sourceRevision['lineage'] ?? null) === 'product-connection-lineage-v1:'.$digest
            && ($projection['projection_identity'] ?? null) === 'product-connection-projection-v1:'.$digest
            && ($projection['represented_source_revision_value'] ?? null) === 0
            && ($projection['projection_currentness'] ?? null) === $record['currentness']
            && ($projection['lag_classification'] ?? null) === $expectedLag;
    }

    /** @param array<string, mixed> $dependency */
    private function validProductConnectionCurrentDependency(array $dependency, string $connectionIdentity): bool
    {
        return $this->hasExactKeys($dependency, self::PRODUCT_CONNECTION_CURRENT_DEPENDENCY_KEYS)
            && ($dependency['dependency_type'] ?? null) === 'CURRENT_STATE_EVIDENCE'
            && $this->nonEmptyString($dependency['state_evidence_identity'] ?? null)
            && ($dependency['connection_identity'] ?? null) === $connectionIdentity
            && in_array($dependency['state'] ?? null, self::PRODUCT_CONNECTION_STATES, true)
            && $this->validProductConnectionDependencySource($dependency)
            && is_bool($dependency['protected_binding_satisfied'] ?? null);
    }

    /** @param array<string, mixed> $dependency */
    private function validProductConnectionTransitionDependency(array $dependency, string $connectionIdentity): bool
    {
        $expectedRevision = $dependency['expected_state_revision'] ?? null;

        return $this->hasExactKeys($dependency, self::PRODUCT_CONNECTION_TRANSITION_DEPENDENCY_KEYS)
            && ($dependency['dependency_type'] ?? null) === 'TRANSITION_EVIDENCE'
            && $this->nonEmptyString($dependency['transition_identity'] ?? null)
            && ($dependency['connection_identity'] ?? null) === $connectionIdentity
            && in_array($dependency['from_state'] ?? null, self::PRODUCT_CONNECTION_STATES, true)
            && in_array($dependency['to_state'] ?? null, self::PRODUCT_CONNECTION_STATES, true)
            && is_array($expectedRevision)
            && $this->hasExactKeys($expectedRevision, [
                'authority_owner',
                'authority_scope',
                'lineage',
                'aggregate_context',
                'value',
            ])
            && $this->nonEmptyString($expectedRevision['authority_owner'] ?? null)
            && $this->nonEmptyString($expectedRevision['authority_scope'] ?? null)
            && $this->nonEmptyString($expectedRevision['lineage'] ?? null)
            && $this->nonEmptyString($expectedRevision['aggregate_context'] ?? null)
            && is_int($expectedRevision['value'] ?? null)
            && $expectedRevision['value'] >= 0
            && $this->validProductConnectionDependencySource($dependency)
            && is_bool($dependency['protected_binding_satisfied'] ?? null);
    }

    /** @param array<string, mixed> $dependency */
    private function validProductConnectionDependencySource(array $dependency): bool
    {
        foreach (['authority_owner', 'authority_scope', 'aggregate_context', 'source_lineage'] as $key) {
            if (! $this->nonEmptyString($dependency[$key] ?? null)) {
                return false;
            }
        }

        return is_int($dependency['source_revision_value'] ?? null)
            && $dependency['source_revision_value'] >= 0
            && $this->validSourceCondition($dependency['source_condition'] ?? null)
            && $this->nullableBoolean($dependency['currentness'] ?? null)
            && $this->nullableBoolean($dependency['freshness'] ?? null);
    }

    /**
     * @param array<string, mixed>|null $current
     * @param array<string, mixed>|null $transition
     */
    private function productConnectionAggregate(
        ?array $current,
        ?array $transition,
        string $field,
        bool $transitionFact,
    ): ?bool {
        if ($current === null) {
            return null;
        }

        if (! $transitionFact) {
            return $current[$field];
        }

        if ($transition === null) {
            return $current[$field] === false ? false : null;
        }

        if ($current[$field] === false || $transition[$field] === false) {
            return false;
        }

        return $current[$field] === true && $transition[$field] === true ? true : null;
    }

    /**
     * @param array<string, mixed> $payload
     * @param array<string, mixed>|null $current
     * @param array<string, mixed>|null $transition
     */
    private function validProductConnectionPayloadMatrix(
        array $payload,
        ?array $current,
        ?array $transition,
        bool $currentFact,
        ?bool $aggregateCurrentness,
        ?bool $aggregateFreshness,
    ): bool {
        $classification = $payload['classification'] ?? null;
        $currentState = $payload['current_state'] ?? null;
        $reasons = $payload['reason_categories'];
        $invalidated = $payload['invalidation']['invalidated'];
        $currentTerminal = is_string($currentState)
            && in_array($currentState, self::PRODUCT_CONNECTION_TERMINAL_STATES, true);

        if (! is_bool($payload['connection_active_for_downstream_consideration'] ?? null)
            || ! is_bool($payload['valid_for_protected_use'] ?? null)
            || ! is_array($payload['terminality'] ?? null)) {
            return false;
        }

        if ($currentFact) {
            if (! $this->hasExactKeys($payload['terminality'], ['current_state_terminal'])
                || ! is_bool($payload['terminality']['current_state_terminal'] ?? null)
                || $payload['terminality']['current_state_terminal'] !== $currentTerminal
                || ! in_array($classification, [...self::PRODUCT_CONNECTION_STATES, 'UNKNOWN'], true)) {
                return false;
            }

            if ($invalidated) {
                return $classification === 'UNKNOWN'
                    && $current !== null
                    && ($currentState === null || $currentState === $current['state'])
                    && $payload['connection_active_for_downstream_consideration'] === false
                    && $payload['valid_for_protected_use'] === false;
            }

            if ($classification !== 'UNKNOWN') {
                return $reasons === []
                    && $current !== null
                    && $this->productConnectionDependencyUsable($current)
                    && $currentState === $classification
                    && $current['state'] === $classification
                    && $aggregateCurrentness === true
                    && $aggregateFreshness === true
                    && $payload['connection_active_for_downstream_consideration'] === ($classification === 'CN_ACTIVE')
                    && $payload['valid_for_protected_use'] === true;
            }

            if ($reasons === ['CURRENT_STATE_NOT_CURRENT_FRESH_BOUND']) {
                return $current !== null
                    && ! $this->productConnectionDependencyUsable($current)
                    && $currentState === null
                    && $payload['terminality']['current_state_terminal'] === false
                    && $payload['connection_active_for_downstream_consideration'] === false
                    && $payload['valid_for_protected_use'] === false;
            }

            return count($reasons) === 1
                && in_array($reasons[0], array_slice(self::PRODUCT_CONNECTION_CURRENT_REASONS, 0, 6), true)
                && $current === null
                && $currentState === null
                && $aggregateCurrentness === null
                && $aggregateFreshness === null
                && $payload['terminality']['current_state_terminal'] === false
                && $payload['connection_active_for_downstream_consideration'] === false
                && $payload['valid_for_protected_use'] === false;
        }

        $proposedState = $payload['proposed_state'] ?? null;
        $proposedTerminal = is_string($proposedState)
            && in_array($proposedState, self::PRODUCT_CONNECTION_TERMINAL_STATES, true);

        if (! $this->hasExactKeys($payload['terminality'], [
            'current_state_terminal',
            'proposed_state_terminal',
            'terminal_reopen_rejected',
        ])
            || ! is_bool($payload['terminality']['current_state_terminal'] ?? null)
            || ! is_bool($payload['terminality']['proposed_state_terminal'] ?? null)
            || ! is_bool($payload['terminality']['terminal_reopen_rejected'] ?? null)
            || $payload['terminality']['current_state_terminal'] !== $currentTerminal
            || $payload['terminality']['proposed_state_terminal'] !== $proposedTerminal
            || $payload['terminality']['terminal_reopen_rejected']
                !== ($reasons === ['TERMINAL_CONNECTION_IDENTITY_CANNOT_REOPEN'])
            || ! in_array($classification, ['ADMISSIBLE', 'REJECTED', 'UNKNOWN'], true)) {
            return false;
        }

        if ($invalidated) {
            return $classification === 'UNKNOWN'
                && ($current !== null || $transition !== null)
                && $payload['connection_active_for_downstream_consideration'] === false
                && $payload['valid_for_protected_use'] === false;
        }

        if ($current === null) {
            return $classification === 'UNKNOWN'
                && count($reasons) === 1
                && in_array($reasons[0], array_slice(self::PRODUCT_CONNECTION_TRANSITION_REASONS, 0, 6), true)
                && $transition === null
                && $currentState === null
                && $proposedState === null
                && $aggregateCurrentness === null
                && $aggregateFreshness === null
                && $payload['connection_active_for_downstream_consideration'] === false
                && $payload['valid_for_protected_use'] === false;
        }

        if ($reasons === ['CURRENT_STATE_NOT_CURRENT_FRESH_BOUND']) {
            return $classification === 'UNKNOWN'
                && $transition === null
                && ! $this->productConnectionDependencyUsable($current)
                && $currentState === null
                && $proposedState === null
                && $payload['connection_active_for_downstream_consideration'] === false
                && $payload['valid_for_protected_use'] === false;
        }

        if ($transition === null) {
            return $classification === 'UNKNOWN'
                && count($reasons) === 1
                && in_array($reasons[0], array_slice(self::PRODUCT_CONNECTION_TRANSITION_REASONS, 7, 6), true)
                && $this->productConnectionDependencyUsable($current)
                && $currentState === $current['state']
                && $proposedState === null
                && $aggregateCurrentness === null
                && $aggregateFreshness === null
                && $payload['connection_active_for_downstream_consideration'] === ($currentState === 'CN_ACTIVE')
                && $payload['valid_for_protected_use'] === false;
        }

        if ($currentState !== $current['state']
            || $proposedState !== $transition['to_state']
            || $payload['connection_active_for_downstream_consideration'] !== ($currentState === 'CN_ACTIVE')) {
            return false;
        }

        if ($reasons === ['TRANSITION_NOT_CURRENT_FRESH_BOUND']) {
            return $classification === 'UNKNOWN'
                && $this->productConnectionDependencyUsable($current)
                && ! $this->productConnectionDependencyUsable($transition)
                && $payload['valid_for_protected_use'] === false;
        }

        $bothUsable = $this->productConnectionDependencyUsable($current)
            && $this->productConnectionDependencyUsable($transition);

        if (! $bothUsable || $aggregateCurrentness !== true || $aggregateFreshness !== true) {
            return false;
        }

        $currentRevision = [
            'authority_owner' => $current['authority_owner'],
            'authority_scope' => $current['authority_scope'],
            'lineage' => $current['source_lineage'],
            'aggregate_context' => $current['aggregate_context'],
            'value' => $current['source_revision_value'],
        ];
        $contextMatches = $transition['from_state'] === $currentState
            && $transition['expected_state_revision'] === $currentRevision;

        if ($reasons === ['TRANSITION_CURRENT_CONTEXT_MISMATCH']) {
            return $classification === 'UNKNOWN'
                && ! $contextMatches
                && $payload['valid_for_protected_use'] === false;
        }

        if (! $contextMatches) {
            return false;
        }

        $pair = $currentState.'->'.$proposedState;
        $allowed = in_array($pair, [
            'CN_NONE->CN_PENDING',
            'CN_PENDING->CN_ACTIVE',
            'CN_PENDING->CN_DECLINED',
            'CN_PENDING->CN_WITHDRAWN',
            'CN_PENDING->CN_EXPIRED',
            'CN_ACTIVE->CN_PAUSED',
            'CN_ACTIVE->CN_CLOSED',
            'CN_PAUSED->CN_ACTIVE',
            'CN_PAUSED->CN_CLOSED',
        ], true);

        if ($classification === 'ADMISSIBLE') {
            return $reasons === []
                && ! $currentTerminal
                && $allowed
                && $payload['valid_for_protected_use'] === true;
        }

        if ($classification !== 'REJECTED'
            || count($reasons) !== 1
            || $payload['valid_for_protected_use'] !== false) {
            return false;
        }

        return match ($reasons[0]) {
            'TERMINAL_CONNECTION_IDENTITY_CANNOT_REOPEN' => $currentTerminal,
            'DIRECT_NONE_TO_ACTIVE_REJECTED' => $pair === 'CN_NONE->CN_ACTIVE',
            'TRANSITION_NOT_ALLOWED' => ! $currentTerminal && ! $allowed && $pair !== 'CN_NONE->CN_ACTIVE',
            default => false,
        };
    }

    /** @param array<string, mixed> $dependency */
    private function productConnectionDependencyUsable(array $dependency): bool
    {
        return ($dependency['protected_binding_satisfied'] ?? null) === true
            && ($dependency['source_condition'] ?? null) === CommonAuthorityEvidenceContract::CONDITION_PRESENT
            && ($dependency['currentness'] ?? null) === true
            && ($dependency['freshness'] ?? null) === true;
    }

    /** @param array<string, mixed> $record */
    private function validCanonicalMatchRecord(array $record): bool
    {
        $payload = $record['derived_projection_payload'] ?? null;

        if (! is_array($payload)
            || ! $this->hasExactKeys($payload, self::MATCH_PAYLOAD_KEYS)
            || ($payload['payload_kind'] ?? null) !== 'CANONICAL_MATCH_PROPOSAL_DECISION'
            || ($payload['derived_fact_class'] ?? null) !== 'CANONICAL_MATCH_PROPOSAL_DECISION'
            || ! in_array($payload['classification'] ?? null, self::MATCH_CLASSIFICATIONS, true)
            || ! $this->nonEmptyString($payload['proposal_identity'] ?? null)
            || ! $this->nonEmptyString($payload['protected_use_scope'] ?? null)
            || $this->containsPrivateSentinel($payload)) {
            return false;
        }

        $reasons = $payload['reason_categories'] ?? null;

        if (! is_array($reasons)
            || ! array_is_list($reasons)
            || ! $this->allNonEmptyStrings($reasons)
            || count($reasons) !== count(array_unique($reasons))) {
            return false;
        }

        $canonicalReasons = array_values(array_filter(
            self::MATCH_REASON_CATEGORIES,
            static fn (string $reason): bool => in_array($reason, $reasons, true),
        ));

        if ($reasons !== $canonicalReasons) {
            return false;
        }

        $bindings = $record['bindings'] ?? null;
        $sourceRevision = $record['source_revision'] ?? null;
        $projectionMetadata = $record['projection_metadata'] ?? null;
        $logicalIntent = $record['logical_intent'] ?? null;

        if (! is_array($bindings)
            || ! is_array($sourceRevision)
            || ! is_array($projectionMetadata)
            || ! is_array($logicalIntent)
            || ! $this->hasExactKeys($logicalIntent, ['intent_identity', 'semantic_input'])
            || ! is_array($logicalIntent['semantic_input'] ?? null)) {
            return false;
        }

        $participants = $bindings['participants'] ?? null;

        if (! is_array($participants)
            || ! array_is_list($participants)
            || count($participants) !== 2
            || ! $this->allNonEmptyStrings($participants)
            || count(array_unique($participants)) !== 2) {
            return false;
        }

        $sortedParticipants = $participants;
        sort($sortedParticipants, SORT_STRING);

        if ($participants !== $sortedParticipants) {
            return false;
        }

        $proposal = $payload['proposal_dependency'] ?? null;
        $participation = $payload['participation_dependencies'] ?? null;
        $slots = $payload['decision_slot_dependencies'] ?? null;

        if (! is_array($proposal)
            || ! $this->validCanonicalMatchProposalDependency($proposal, $payload['proposal_identity'])
            || ! is_array($participation)
            || ! array_is_list($participation)
            || ! is_array($slots)
            || ! array_is_list($slots)) {
            return false;
        }

        $participationIdentities = [];

        foreach ($participation as $dependency) {
            if (! is_array($dependency)
                || ! $this->validCanonicalMatchParticipationDependency($dependency, $participants)) {
                return false;
            }

            $participationIdentities[] = $dependency['participant_identity'];
        }

        if (count($participationIdentities) !== count(array_unique($participationIdentities))) {
            return false;
        }

        $sortedParticipation = $participation;
        usort($sortedParticipation, self::compareCanonicalMatchParticipationDependencies(...));

        if ($participation !== $sortedParticipation) {
            return false;
        }

        $slotIdentities = [];
        $slotParticipantIdentities = [];

        foreach ($slots as $dependency) {
            if (! is_array($dependency)
                || ! $this->validCanonicalMatchSlotDependency(
                    $dependency,
                    $payload['proposal_identity'],
                    $participants,
                )) {
                return false;
            }

            $slotIdentities[] = $dependency['slot_identity'];
            $slotParticipantIdentities[] = $dependency['participant_identity'];
        }

        if (count($slotIdentities) !== count(array_unique($slotIdentities))
            || count($slotParticipantIdentities) !== count(array_unique($slotParticipantIdentities))) {
            return false;
        }

        $sortedSlots = $slots;
        usort($sortedSlots, self::compareCanonicalMatchSlotDependencies(...));

        if ($slots !== $sortedSlots) {
            return false;
        }

        $dependencyIdentities = [
            $payload['proposal_identity'],
            ...$participants,
            ...$slotIdentities,
        ];
        $persistedDependencyIdentities = [
            $payload['proposal_identity'],
            ...$participationIdentities,
            ...$slotIdentities,
        ];

        if (count($dependencyIdentities) !== count(array_unique($dependencyIdentities))) {
            return false;
        }

        $sourceProposalTerminal = $proposal['terminal'];

        if ($sourceProposalTerminal) {
            if ($participation !== [] || $slots !== []) {
                return false;
            }

            $complete = true;
        } else {
            $complete = count($participation) === 2
                && count($slots) === 2
                && $this->sameIdentitySet($participationIdentities, $participants)
                && $this->sameIdentitySet($slotParticipantIdentities, $participants);
        }

        if ($record['currentness'] !== $this->canonicalMatchAggregate(
            $proposal,
            $participation,
            $slots,
            'currentness',
            $complete,
        ) || $record['freshness'] !== $this->canonicalMatchAggregate(
            $proposal,
            $participation,
            $slots,
            'freshness',
            $complete,
        )) {
            return false;
        }

        $terminality = $payload['terminality'] ?? null;
        $invalidation = $payload['invalidation'] ?? null;

        if (! is_array($terminality)
            || ! $this->hasExactKeys($terminality, [
                'source_proposal_terminal',
                'derived_terminal',
                'classification_before_invalidation',
                'lifecycle_reset',
                'proposal_reopened',
            ])
            || ! is_bool($terminality['source_proposal_terminal'] ?? null)
            || ! is_bool($terminality['derived_terminal'] ?? null)
            || $terminality['source_proposal_terminal'] !== $sourceProposalTerminal
            || ($terminality['lifecycle_reset'] ?? null) !== false
            || ($terminality['proposal_reopened'] ?? null) !== false
            || ($bindings['terminal'] ?? null) !== $terminality['derived_terminal']
            || ! is_array($invalidation)
            || ! $this->hasExactKeys($invalidation, [
                'invalidated',
                'relation',
                'dependency_identity',
                'lifecycle_reset',
                'proposal_reopened',
            ])
            || ! is_bool($invalidation['invalidated'] ?? null)
            || ($invalidation['lifecycle_reset'] ?? null) !== false
            || ($invalidation['proposal_reopened'] ?? null) !== false) {
            return false;
        }

        if ($invalidation['invalidated'] === false) {
            $expectedTerminal = in_array($payload['classification'], self::MATCH_TERMINAL_CLASSIFICATIONS, true);

            if ($invalidation['relation'] !== null
                || $invalidation['dependency_identity'] !== null
                || $terminality['classification_before_invalidation'] !== null
                || $terminality['derived_terminal'] !== $expectedTerminal
                || in_array('DEPENDENCY_INVALIDATED', $reasons, true)) {
                return false;
            }

            if ($sourceProposalTerminal && $payload['classification'] !== $proposal['lifecycle_state']) {
                return false;
            }
        } else {
            $before = $terminality['classification_before_invalidation'] ?? null;
            $expectedTerminal = in_array($before, self::MATCH_TERMINAL_CLASSIFICATIONS, true);

            if ($payload['classification'] !== 'UNKNOWN'
                || ! in_array($before, self::MATCH_CLASSIFICATIONS, true)
                || $terminality['derived_terminal'] !== $expectedTerminal
                || $reasons !== ['DEPENDENCY_INVALIDATED']
                || ! in_array($invalidation['relation'] ?? null, [
                    CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
                    CommonAuthorityEvidenceContract::INVALIDATION_REVOCATION,
                    CommonAuthorityEvidenceContract::INVALIDATION_SUPERSESSION,
                ], true)
                || ! $this->nonEmptyString($invalidation['dependency_identity'] ?? null)
                || count(array_filter(
                    $persistedDependencyIdentities,
                    static fn (string $identity): bool => $identity === $invalidation['dependency_identity'],
                )) !== 1) {
                return false;
            }

            if ($sourceProposalTerminal && $before !== $proposal['lifecycle_state']) {
                return false;
            }
        }

        $scope = 'CANONICAL_MATCH_PROPOSAL_DECISION|'.$payload['protected_use_scope'];

        if (($bindings['authority_owner'] ?? null) !== 'CANONICAL_MATCH_DERIVATION'
            || ($bindings['authority_scope'] ?? null) !== $scope
            || ($bindings['aggregate_context'] ?? null) !== $payload['proposal_identity']
            || ($bindings['purpose'] ?? null) !== $payload['protected_use_scope']
            || ($sourceRevision['authority_owner'] ?? null) !== 'CANONICAL_MATCH_DERIVATION'
            || ($sourceRevision['authority_scope'] ?? null) !== $scope
            || ($sourceRevision['aggregate_context'] ?? null) !== $bindings['aggregate_context']
            || ($sourceRevision['value'] ?? null) !== 0
            || $record['source_condition'] !== CommonAuthorityEvidenceContract::CONDITION_PRESENT
            || $record['authoritative_outcome'] !== CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN
            || $record['authoritative_outcome_metadata'] !== null
            || $record['correction_metadata'] !== null
            || $record['transport_observation'] !== 'AMBIGUOUS'
            || $record['private_fixture_extensions'] !== []) {
            return false;
        }

        $lifecycleBasis = [
            'record_family' => self::RECORD_FAMILY_CANONICAL_MATCH,
            'proposal_identity' => $payload['proposal_identity'],
            'protected_use_scope' => $payload['protected_use_scope'],
            'subject' => $bindings['subject'] ?? null,
            'participants' => $participants,
            'audience' => $bindings['audience'] ?? null,
            'purpose' => $bindings['purpose'] ?? null,
            'aggregate_context' => $bindings['aggregate_context'] ?? null,
        ];
        $expectedLifecycle = 'canonical-match-lifecycle-v1:'.$this->fingerprint($lifecycleBasis);

        if (($bindings['lifecycle_identity'] ?? null) !== $expectedLifecycle) {
            return false;
        }

        $semanticInput = [
            'record_family' => self::RECORD_FAMILY_CANONICAL_MATCH,
            'bindings' => $bindings,
            'derived_projection_payload' => $payload,
            'schema_marker' => 'canonical-match-derived-projection-v1',
        ];
        $digest = $this->fingerprint($semanticInput);

        if ($record['logical_record_identity'] !== 'canonical-match-record-v1:'.$digest
            || ($logicalIntent['intent_identity'] ?? null) !== 'canonical-match-intent-v1:'.$digest
            || $logicalIntent['semantic_input'] !== $semanticInput
            || ($sourceRevision['lineage'] ?? null) !== 'canonical-match-lineage-v1:'.$digest
            || ($projectionMetadata['projection_identity'] ?? null) !== 'canonical-match-projection-v1:'.$digest
            || ($projectionMetadata['represented_source_revision_value'] ?? null) !== 0
            || ($projectionMetadata['projection_currentness'] ?? null) !== $record['currentness']) {
            return false;
        }

        $expectedLag = match ($record['currentness']) {
            true => 'CURRENT',
            false => 'LAGGED',
            null => 'UNKNOWN',
        };

        return ($projectionMetadata['lag_classification'] ?? null) === $expectedLag;
    }

    /** @param array<string, mixed> $dependency */
    private function validCanonicalMatchProposalDependency(array $dependency, string $proposalIdentity): bool
    {
        if (! $this->hasExactKeys($dependency, self::MATCH_PROPOSAL_DEPENDENCY_KEYS)
            || ($dependency['proposal_identity'] ?? null) !== $proposalIdentity
            || ! in_array($dependency['lifecycle_state'] ?? null, [
                'PENDING',
                'MUTUALLY_ACCEPTED',
                'DECLINED',
                'WITHDRAWN',
                'EXPIRED',
            ], true)
            || ! is_bool($dependency['terminal'] ?? null)
            || $dependency['terminal'] !== ($dependency['lifecycle_state'] !== 'PENDING')) {
            return false;
        }

        return $this->validCanonicalMatchSourceFields($dependency);
    }

    /** @param array<string, mixed> $dependency @param list<string> $participants */
    private function validCanonicalMatchParticipationDependency(array $dependency, array $participants): bool
    {
        if (! $this->hasExactKeys($dependency, self::MATCH_PARTICIPATION_DEPENDENCY_KEYS)
            || ! $this->nonEmptyString($dependency['participant_identity'] ?? null)
            || ! in_array($dependency['participant_identity'], $participants, true)
            || ! in_array($dependency['state'] ?? null, [
                'NOT_ENROLLED',
                'ENROLLED',
                'PAUSED',
                'WITHDRAWN',
            ], true)) {
            return false;
        }

        return $this->validCanonicalMatchSourceFields($dependency);
    }

    /** @param array<string, mixed> $dependency @param list<string> $participants */
    private function validCanonicalMatchSlotDependency(
        array $dependency,
        string $proposalIdentity,
        array $participants,
    ): bool {
        if (! $this->hasExactKeys($dependency, self::MATCH_SLOT_DEPENDENCY_KEYS)
            || ! $this->nonEmptyString($dependency['slot_identity'] ?? null)
            || ($dependency['proposal_identity'] ?? null) !== $proposalIdentity
            || ! $this->nonEmptyString($dependency['participant_identity'] ?? null)
            || ! in_array($dependency['participant_identity'], $participants, true)
            || ! in_array($dependency['decision'] ?? null, [
                'PENDING',
                'ACCEPTED',
                'DECLINED',
                'WITHDRAWN',
            ], true)) {
            return false;
        }

        return $this->validCanonicalMatchSourceFields($dependency);
    }

    /** @param array<string, mixed> $dependency */
    private function validCanonicalMatchSourceFields(array $dependency): bool
    {
        foreach (['authority_owner', 'authority_scope', 'aggregate_context', 'source_lineage'] as $key) {
            if (! $this->nonEmptyString($dependency[$key] ?? null)) {
                return false;
            }
        }

        return is_int($dependency['source_revision_value'] ?? null)
            && $dependency['source_revision_value'] >= 0
            && $this->validSourceCondition($dependency['source_condition'] ?? null)
            && $this->nullableBoolean($dependency['currentness'] ?? null)
            && $this->nullableBoolean($dependency['freshness'] ?? null);
    }

    private function validSourceCondition(mixed $condition): bool
    {
        return in_array($condition, [
            CommonAuthorityEvidenceContract::CONDITION_PRESENT,
            CommonAuthorityEvidenceContract::CONDITION_ABSENT,
            CommonAuthorityEvidenceContract::CONDITION_UNKNOWN,
            CommonAuthorityEvidenceContract::CONDITION_UNAVAILABLE,
            CommonAuthorityEvidenceContract::CONDITION_STALE,
            CommonAuthorityEvidenceContract::CONDITION_SUPERSEDED,
            CommonAuthorityEvidenceContract::CONDITION_INCOMPARABLE,
        ], true);
    }

    /**
     * @param array<string, mixed> $proposal
     * @param list<array<string, mixed>> $participation
     * @param list<array<string, mixed>> $slots
     */
    private function canonicalMatchAggregate(
        array $proposal,
        array $participation,
        array $slots,
        string $field,
        bool $complete,
    ): ?bool {
        $values = [$proposal[$field]];

        foreach ([...$participation, ...$slots] as $dependency) {
            $values[] = $dependency[$field];
        }

        if (in_array(false, $values, true)) {
            return false;
        }

        if (! $complete || in_array(null, $values, true)) {
            return null;
        }

        return true;
    }

    /** @param list<string> $left @param list<string> $right */
    private function sameIdentitySet(array $left, array $right): bool
    {
        sort($left, SORT_STRING);
        sort($right, SORT_STRING);

        return $left === $right;
    }

    /** @param array<string, mixed> $left @param array<string, mixed> $right */
    private static function compareCanonicalMatchParticipationDependencies(array $left, array $right): int
    {
        foreach ([
            'participant_identity',
            'authority_owner',
            'authority_scope',
            'aggregate_context',
            'source_lineage',
            'source_revision_value',
        ] as $key) {
            $comparison = $left[$key] <=> $right[$key];

            if ($comparison !== 0) {
                return $comparison;
            }
        }

        return 0;
    }

    /** @param array<string, mixed> $left @param array<string, mixed> $right */
    private static function compareCanonicalMatchSlotDependencies(array $left, array $right): int
    {
        foreach ([
            'participant_identity',
            'slot_identity',
            'authority_owner',
            'authority_scope',
            'aggregate_context',
            'source_lineage',
            'source_revision_value',
        ] as $key) {
            $comparison = $left[$key] <=> $right[$key];

            if ($comparison !== 0) {
                return $comparison;
            }
        }

        return 0;
    }

    /** @param list<mixed> $values */
    private function allNonEmptyStrings(array $values): bool
    {
        foreach ($values as $value) {
            if (! $this->nonEmptyString($value)) {
                return false;
            }
        }

        return true;
    }

    private function nonEmptyString(mixed $value): bool
    {
        return is_string($value) && $value !== '';
    }

    /** @param array<string, mixed> $payload */
    private function validRr03Payload(array $payload): bool
    {
        if (! $this->hasExactKeys($payload, self::RR03_PAYLOAD_KEYS)
            || ($payload['payload_kind'] ?? null) !== 'RR03_RUNTIME_READINESS'
            || ($payload['derived_fact_class'] ?? null) !== RuntimeReadinessDerivedEvaluator::FACT_EFFECTIVE_READINESS
            || ! in_array($payload['classification'] ?? null, [
                RuntimeReadinessDerivedEvaluator::READINESS_READY,
                RuntimeReadinessDerivedEvaluator::READINESS_NOT_READY,
                RuntimeReadinessDerivedEvaluator::READINESS_UNKNOWN,
            ], true)
            || ! in_array($payload['prerequisite_set_state'] ?? null, [
                RuntimeReadinessDerivedEvaluator::SET_KNOWN,
                RuntimeReadinessDerivedEvaluator::SET_UNKNOWN,
            ], true)
            || ! $this->nullableNonEmptyString($payload['prerequisite_set_identity'] ?? null)
            || ! $this->validNullableRevision($payload['prerequisite_set_revision'] ?? null)
            || ! in_array($payload['prerequisite_set_condition'] ?? null, [
                CommonAuthorityEvidenceContract::CONDITION_PRESENT,
                CommonAuthorityEvidenceContract::CONDITION_ABSENT,
                CommonAuthorityEvidenceContract::CONDITION_UNKNOWN,
                CommonAuthorityEvidenceContract::CONDITION_UNAVAILABLE,
                CommonAuthorityEvidenceContract::CONDITION_STALE,
                CommonAuthorityEvidenceContract::CONDITION_SUPERSEDED,
                CommonAuthorityEvidenceContract::CONDITION_INCOMPARABLE,
                null,
            ], true)
            || ! $this->nullableBoolean($payload['prerequisite_set_currentness'] ?? null)
            || ! $this->nullableBoolean($payload['prerequisite_set_freshness'] ?? null)
            || ! $this->nullableNonEmptyString($payload['protected_use_scope'] ?? null)
            || ! is_array($payload['reason_categories'] ?? null)
            || ! array_is_list($payload['reason_categories'])
            || count($payload['reason_categories']) !== count(array_unique($payload['reason_categories']))
            || array_diff($payload['reason_categories'], self::RR03_REASON_CATEGORIES) !== []
            || ! is_array($payload['dependencies'] ?? null)
            || ! array_is_list($payload['dependencies'])
            || ! is_array($payload['invalidation'] ?? null)
            || $this->containsPrivateSentinel($payload)) {
            return false;
        }

        $canonicalDependencies = [];
        $canonicalTuples = [];

        foreach ($payload['dependencies'] as $dependency) {
            if (! is_array($dependency) || ! $this->validRr03Dependency($dependency)) {
                return false;
            }

            $canonicalDependencies[] = $dependency;
            $canonicalTuples[] = $this->fingerprint(array_intersect_key($dependency, array_flip([
                'dependency_identity',
                'fact_class',
                'authority_owner',
                'authority_scope',
                'aggregate_context',
                'source_lineage',
                'source_revision_value',
            ])));
        }

        $sortedDependencies = $canonicalDependencies;
        usort($sortedDependencies, self::compareRr03Dependencies(...));

        if ($canonicalDependencies !== $sortedDependencies
            || count($canonicalTuples) !== count(array_unique($canonicalTuples))) {
            return false;
        }

        $invalidation = $payload['invalidation'];

        if (! $this->hasExactKeys($invalidation, ['invalidated', 'relation', 'dependency_identity'])
            || ! is_bool($invalidation['invalidated'] ?? null)) {
            return false;
        }

        if ($invalidation['invalidated'] === false) {
            return $invalidation['relation'] === null && $invalidation['dependency_identity'] === null;
        }

        return in_array($invalidation['relation'] ?? null, [
            CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
            CommonAuthorityEvidenceContract::INVALIDATION_REVOCATION,
            CommonAuthorityEvidenceContract::INVALIDATION_SUPERSESSION,
        ], true) && $this->nullableNonEmptyString($invalidation['dependency_identity'] ?? null)
            && $invalidation['dependency_identity'] !== null;
    }

    /** @param array<string, mixed> $dependency */
    private function validRr03Dependency(array $dependency): bool
    {
        if (! $this->hasExactKeys($dependency, self::RR03_DEPENDENCY_KEYS)) {
            return false;
        }

        foreach (['dependency_identity', 'authority_owner', 'authority_scope', 'aggregate_context', 'source_lineage'] as $key) {
            if (! is_string($dependency[$key] ?? null) || $dependency[$key] === '') {
                return false;
            }
        }

        return in_array($dependency['fact_class'] ?? null, [
            RuntimeReadinessDerivedEvaluator::FACT_ELIGIBILITY,
            RuntimeReadinessDerivedEvaluator::FACT_CHECKLIST,
            RuntimeReadinessDerivedEvaluator::FACT_VERIFICATION,
        ], true)
            && is_int($dependency['source_revision_value'] ?? null)
            && $dependency['source_revision_value'] >= 0
            && in_array($dependency['source_condition'] ?? null, [
                CommonAuthorityEvidenceContract::CONDITION_PRESENT,
                CommonAuthorityEvidenceContract::CONDITION_ABSENT,
                CommonAuthorityEvidenceContract::CONDITION_UNKNOWN,
                CommonAuthorityEvidenceContract::CONDITION_UNAVAILABLE,
                CommonAuthorityEvidenceContract::CONDITION_STALE,
                CommonAuthorityEvidenceContract::CONDITION_SUPERSEDED,
                CommonAuthorityEvidenceContract::CONDITION_INCOMPARABLE,
            ], true)
            && $this->nullableBoolean($dependency['currentness'] ?? null)
            && $this->nullableBoolean($dependency['freshness'] ?? null)
            && in_array($dependency['prerequisite_outcome'] ?? null, [
                RuntimeReadinessDerivedEvaluator::OUTCOME_SATISFIED,
                RuntimeReadinessDerivedEvaluator::OUTCOME_UNSATISFIED,
                null,
            ], true);
    }

    /** @param array<string, mixed> $revision */
    private function validNullableRevision(mixed $revision): bool
    {
        if ($revision === null) {
            return true;
        }

        if (! is_array($revision)
            || ! $this->hasExactKeys($revision, ['authority_owner', 'authority_scope', 'aggregate_context', 'lineage', 'value'])) {
            return false;
        }

        foreach (['authority_owner', 'authority_scope', 'aggregate_context', 'lineage'] as $key) {
            if (! is_string($revision[$key] ?? null) || $revision[$key] === '') {
                return false;
            }
        }

        return is_int($revision['value'] ?? null) && $revision['value'] >= 0;
    }

    private function nullableNonEmptyString(mixed $value): bool
    {
        return $value === null || (is_string($value) && $value !== '');
    }

    private function nullableBoolean(mixed $value): bool
    {
        return $value === null || is_bool($value);
    }

    /** @param array<string, mixed> $value @param list<string> $expected */
    private function hasExactKeys(array $value, array $expected): bool
    {
        $keys = array_keys($value);
        sort($keys);
        sort($expected);

        return $keys === $expected;
    }

    /** @param array<string, mixed> $left @param array<string, mixed> $right */
    private static function compareRr03Dependencies(array $left, array $right): int
    {
        foreach ([
            'dependency_identity',
            'fact_class',
            'authority_owner',
            'authority_scope',
            'aggregate_context',
            'source_lineage',
            'source_revision_value',
        ] as $key) {
            $comparison = $left[$key] <=> $right[$key];

            if ($comparison !== 0) {
                return $comparison;
            }
        }

        return 0;
    }

    private function containsPrivateSentinel(mixed $value): bool
    {
        if (is_string($value)) {
            return str_contains($value, 'MUST-NOT-LEAK');
        }

        if (! is_array($value)) {
            return false;
        }

        foreach ($value as $nested) {
            if ($this->containsPrivateSentinel($nested)) {
                return true;
            }
        }

        return false;
    }

    /**
     * @param array<string, mixed> $query
     */
    private function validQuery(array $query, bool $lineageRequired): bool
    {
        $required = ['record_family', 'authority_owner', 'authority_scope', 'aggregate_context', 'lineage'];
        $keys = array_keys($query);
        sort($keys);
        sort($required);

        if ($keys !== $required) {
            return false;
        }

        foreach (['record_family', 'authority_owner', 'authority_scope', 'aggregate_context'] as $key) {
            if (! is_string($query[$key]) || $query[$key] === '') {
                return false;
            }
        }

        if ($lineageRequired) {
            return is_string($query['lineage']) && $query['lineage'] !== '';
        }

        return $query['lineage'] === null || (is_string($query['lineage']) && $query['lineage'] !== '');
    }

    /** @param array<string, mixed> $record @return array<string, mixed> */
    private function project(array $record): array
    {
        $identity = $record['logical_record_identity'];
        $invalidation = $this->invalidations[$identity] ?? null;
        $authoritativeMetadata = $record['authoritative_outcome_metadata'];
        $correctionMetadata = $record['correction_metadata'];
        $derivedPayload = $record['derived_projection_payload'] ?? null;

        if ($derivedPayload !== null
            && $invalidation !== null
            && ! in_array($record['record_family'], [
                self::RECORD_FAMILY_CANONICAL_MATCH,
                self::RECORD_FAMILY_PRODUCT_CONNECTION,
            ], true)) {
            $derivedPayload['invalidation'] = [
                'invalidated' => true,
                'relation' => $invalidation['relation'],
                'dependency_identity' => $identity,
            ];
        }

        return [
            'record_kind' => 'PRIVACY_MINIMAL_LOGICAL_PERSISTENCE_PROJECTION',
            'logical_record_identity' => $identity,
            'record_family' => $record['record_family'],
            'authority_owner' => $record['bindings']['authority_owner'],
            'authority_scope' => $record['bindings']['authority_scope'],
            'subject_reference' => $record['bindings']['subject'],
            'participant_references' => $record['bindings']['participants'],
            'audience' => $record['bindings']['audience'],
            'purpose' => $record['bindings']['purpose'],
            'aggregate_context' => $record['bindings']['aggregate_context'],
            'lifecycle_identity' => $record['bindings']['lifecycle_identity'],
            'terminal' => $record['bindings']['terminal'],
            'source_condition' => $record['source_condition'],
            'source_revision_lineage' => $record['source_revision']['lineage'],
            'source_revision_value' => $record['source_revision']['value'],
            'currentness' => $record['currentness'],
            'freshness' => $record['freshness'],
            'logical_intent_identity' => $record['logical_intent_identity'],
            'authoritative_outcome' => $record['authoritative_outcome'],
            'authoritative_outcome_source_carried' => ($authoritativeMetadata['source_carried'] ?? false) === true,
            'authoritative_outcome_reference' => $authoritativeMetadata['outcome_reference'] ?? null,
            'correction_relation' => $correctionMetadata['relation'] ?? null,
            'displaced_record_identity' => $correctionMetadata['displaced_record_identity'] ?? null,
            'projection_identity' => $record['projection_metadata']['projection_identity'],
            'represented_source_revision_value' => $record['projection_metadata']['represented_source_revision_value'],
            'projection_lag' => $record['projection_metadata']['lag_classification'],
            'projection_currentness' => $record['projection_metadata']['projection_currentness'],
            'projection_invalidated' => ($invalidation['projection_invalidated'] ?? false) === true,
            'invalidation_relation' => $invalidation['relation'] ?? null,
            'lifecycle_reset' => ($invalidation['lifecycle_reset'] ?? false) === true,
            'reopened' => ($invalidation['reopened'] ?? false) === true,
            'new_aggregate_created' => ($invalidation['new_aggregate_created'] ?? false) === true,
            'transition_synthesized' => ($invalidation['transition_synthesized'] ?? false) === true,
            'transport_observation' => $record['transport_observation'],
            'transport_authoritative_outcome' => $record['transport_authoritative_outcome'],
            ...($derivedPayload === null ? [] : ['derived_projection_payload' => $derivedPayload]),
            'transport_is_domain_outcome' => false,
            'source_authority' => false,
            'projection_authority' => false,
            'permission' => false,
            'bearer_capability' => false,
            'domain_success' => false,
            'substitute_writer' => false,
        ];
    }

    /** @return array<string, mixed> */
    private function storageResult(
        string $outcome,
        bool $stored,
        string $reason,
        ?string $identity = null,
        bool $idempotent = false,
    ): array {
        return array_merge(self::nonAuthorityFields(), [
            'record_kind' => 'LOGICAL_PERSISTENCE_STORAGE_DISPOSITION',
            'storage_outcome' => $outcome,
            'logical_record_identity' => $identity,
            'stored' => $stored,
            'idempotent_correlation' => $idempotent,
            'reason' => $reason,
        ]);
    }

    /** @param array<string, mixed>|null $record @return array<string, mixed> */
    private function readResult(string $resolution, ?array $record, string $reason): array
    {
        return array_merge(self::nonAuthorityFields(), [
            'record_kind' => 'LOGICAL_PERSISTENCE_READ_DISPOSITION',
            'resolution' => $resolution,
            'record' => $record,
            'reason' => $reason,
        ]);
    }

    /** @param array<string, mixed>|null $record @return array<string, mixed> */
    private function resolutionResult(string $resolution, ?array $record, string $reason): array
    {
        return array_merge($this->readResult($resolution, $record, $reason), [
            'source_local_revision_only' => true,
            'last_write_wins' => false,
            'last_received_wins' => false,
        ]);
    }

    /** @return array<string, false> */
    private static function nonAuthorityFields(): array
    {
        return [
            'source_authority' => false,
            'authoritative_mutation_success' => false,
            'readiness_authority' => false,
            'match_authority' => false,
            'connection_authority' => false,
            'consent_authority' => false,
            'conversation_authority' => false,
            'relationship_authority' => false,
            'home_action_authority' => false,
            'notification_delivery_authority' => false,
            'launch_authority' => false,
            'permission' => false,
            'bearer_capability' => false,
            'success' => false,
            'domain_success' => false,
            'sql_selected' => false,
            'nosql_selected' => false,
            'sqlite_selected' => false,
            'eloquent_selected' => false,
            'schema_selected' => false,
            'database_connection_selected' => false,
            'filesystem_persistence_selected' => false,
            'cache_selected' => false,
            'transaction_semantics' => false,
            'lock_semantics' => false,
            'cas_semantics' => false,
            'isolation_semantics' => false,
            'queue_semantics' => false,
            'api_semantics' => false,
        ];
    }

    private function fingerprint(mixed $value): string
    {
        return hash('sha256', serialize($this->canonicalize($value)));
    }

    private function canonicalize(mixed $value): mixed
    {
        if (! is_array($value)) {
            return $value;
        }

        if (array_is_list($value)) {
            return array_map(fn (mixed $item): mixed => $this->canonicalize($item), $value);
        }

        ksort($value);

        foreach ($value as $key => $item) {
            $value[$key] = $this->canonicalize($item);
        }

        return $value;
    }
}
