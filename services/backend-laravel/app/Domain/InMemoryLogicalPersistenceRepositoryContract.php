<?php

namespace App\Domain;

use InvalidArgumentException;

final class InMemoryLogicalPersistenceRepositoryContract
{
    public const RECORD_FAMILY_RR03 = 'RR03_RUNTIME_READINESS_DERIVED_PROJECTION';

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
        } elseif (($record['derived_projection_payload'] ?? null) !== null) {
            return ['valid' => false, 'reason' => 'DERIVED_PAYLOAD_NOT_ALLOWED_FOR_RECORD_FAMILY'];
        }

        $fingerprintRecord = $record;

        if (! $isRr03) {
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
                'derived_projection_payload' => $isRr03
                    ? $record['derived_projection_payload']
                    : null,
            ],
        ];
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

        if ($derivedPayload !== null && $invalidation !== null) {
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
