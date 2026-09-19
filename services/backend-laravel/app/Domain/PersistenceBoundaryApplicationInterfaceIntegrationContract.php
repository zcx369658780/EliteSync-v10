<?php

namespace App\Domain;

final class PersistenceBoundaryApplicationInterfaceIntegrationContract
{
    public const GRANTED = 'GRANTED';
    public const DENIED = 'DENIED';
    public const UNKNOWN = 'UNKNOWN';

    /** @var array<string, string> */
    private array $intentFingerprints = [];

    public function __construct(
        private readonly SqliteInMemoryLogicalPersistenceAdapter $persistence,
    ) {}

    /**
     * @param array<string, mixed> $record
     * @return array<string, mixed>
     */
    public function submitAuthoritativeMutation(array $record): array
    {
        $persistence = $this->persistence->store($record);
        $storageOutcome = $persistence['storage_outcome'] ?? null;
        $acceptedForCorrelation = ($persistence['stored'] ?? false) === true
            || $storageOutcome === InMemoryLogicalPersistenceRepositoryContract::EXACT_DUPLICATE;
        $identity = is_string($record['logical_record_identity'] ?? null)
            ? $record['logical_record_identity']
            : null;
        $intent = is_array($record['logical_intent'] ?? null) ? $record['logical_intent'] : null;

        if ($acceptedForCorrelation && $identity !== null && $intent !== null) {
            $this->intentFingerprints[$identity] = $this->fingerprint($intent);
        }

        $sourceCarried = $acceptedForCorrelation
            && is_array($record['authoritative_outcome_metadata'] ?? null)
            && ($record['authoritative_outcome_metadata']['source_carried'] ?? false) === true
            && in_array($record['authoritative_outcome'] ?? null, [
                CommonAuthorityEvidenceContract::OUTCOME_COMMITTED,
                CommonAuthorityEvidenceContract::OUTCOME_REJECTED,
                CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN,
            ], true);
        $authoritativeOutcome = $sourceCarried
            ? $record['authoritative_outcome']
            : CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN;

        $explanation = match (true) {
            $sourceCarried => 'SOURCE_CARRIED_OUTCOME_PRESERVED',
            $acceptedForCorrelation => 'STORAGE_WITHOUT_SOURCE_OUTCOME_REQUIRES_RECONCILIATION',
            default => 'PERSISTENCE_REJECTED_WITHOUT_AUTHORITY_OUTCOME',
        };

        return array_merge(self::nonAuthorityFields(), [
            'record_kind' => 'APPLICATION_INTERFACE_MUTATION_SUBMISSION_RESULT',
            'persistence' => $persistence,
            'authoritative_outcome' => $authoritativeOutcome,
            'authoritative_outcome_source_carried' => $sourceCarried,
            'transport_observation' => is_string($record['transport_observation'] ?? null)
                ? $record['transport_observation']
                : 'UNKNOWN',
            'transport_is_domain_outcome' => false,
            'reconciliation_required' => $authoritativeOutcome === CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN,
            'logical_intent_identity' => is_string($intent['intent_identity'] ?? null)
                ? $intent['intent_identity']
                : null,
            'source_revision' => is_array($record['source_revision'] ?? null)
                ? $record['source_revision']
                : null,
            'currentness' => $record['currentness'] ?? null,
            'freshness' => $record['freshness'] ?? null,
            'explanation_category' => $explanation,
            'source_local_revision_only' => true,
            'global_revision' => false,
            'last_write_wins' => false,
            'last_received_wins' => false,
        ]);
    }

    /**
     * @param array<string, mixed> $expectedIntent
     * @return array<string, mixed>
     */
    public function reconcileAuthoritativeOutcome(string $logicalRecordIdentity, array $expectedIntent): array
    {
        $read = $this->persistence->readExact($logicalRecordIdentity);
        $projection = is_array($read['record'] ?? null) ? $read['record'] : null;
        $registeredFingerprint = $this->intentFingerprints[$logicalRecordIdentity] ?? null;
        $candidateFingerprint = $expectedIntent === [] ? null : $this->fingerprint($expectedIntent);

        $intentBinding = match (true) {
            $projection === null || $registeredFingerprint === null || $candidateFingerprint === null => self::UNKNOWN,
            ($projection['logical_intent_identity'] ?? null) !== ($expectedIntent['intent_identity'] ?? null) => 'MISMATCH',
            $registeredFingerprint !== $candidateFingerprint => 'MISMATCH',
            default => 'EXACT',
        };

        $sourceCarried = $intentBinding === 'EXACT'
            && ($projection['authoritative_outcome_source_carried'] ?? false) === true;
        $carriedOutcome = $projection['authoritative_outcome'] ?? CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN;
        $authoritativeOutcome = $sourceCarried && in_array($carriedOutcome, [
            CommonAuthorityEvidenceContract::OUTCOME_COMMITTED,
            CommonAuthorityEvidenceContract::OUTCOME_REJECTED,
            CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN,
        ], true)
            ? $carriedOutcome
            : CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN;

        return array_merge(self::nonAuthorityFields(), [
            'record_kind' => 'APPLICATION_INTERFACE_AUTHORITATIVE_OUTCOME_RECONCILIATION_RESULT',
            'persistence_resolution' => $read['resolution'] ?? InMemoryLogicalPersistenceRepositoryContract::UNKNOWN,
            'logical_record_identity' => $logicalRecordIdentity,
            'intent_binding' => $intentBinding,
            'authoritative_outcome' => $authoritativeOutcome,
            'authoritative_outcome_source_carried' => $sourceCarried,
            'source_condition' => $projection['source_condition'] ?? null,
            'source_revision' => $projection === null ? null : [
                'authority_owner' => $projection['authority_owner'],
                'authority_scope' => $projection['authority_scope'],
                'lineage' => $projection['source_revision_lineage'],
                'aggregate_context' => $projection['aggregate_context'],
                'value' => $projection['source_revision_value'],
            ],
            'currentness' => $projection['currentness'] ?? null,
            'freshness' => $projection['freshness'] ?? null,
            'transport_observation' => $projection['transport_observation'] ?? null,
            'transport_is_domain_outcome' => false,
            'mutation_replayed' => false,
            'mutation_resubmitted' => false,
            'reconciliation_is_read_only' => true,
            'explanation_category' => $intentBinding === 'EXACT'
                ? 'SOURCE_CARRIED_OUTCOME_ONLY'
                : 'IMMUTABLE_INTENT_NOT_EXACTLY_BOUND',
            'source_local_revision_only' => true,
            'global_revision' => false,
            'last_write_wins' => false,
            'last_received_wins' => false,
        ]);
    }

    /**
     * @param array<string, mixed> $query
     * @param array<string, mixed> $requestBindings
     * @return array<string, mixed>
     */
    public function retrieveCurrentProjection(array $query, array $requestBindings): array
    {
        $resolution = $this->persistence->resolveCurrent($query);
        $projection = is_array($resolution['record'] ?? null) ? $resolution['record'] : null;
        $binding = $this->projectionBindingClassification($projection, $requestBindings);
        $safeProjection = $binding === 'EXACT' ? $projection : null;
        $applicationResolution = $binding === 'MISMATCH'
            ? InMemoryLogicalPersistenceRepositoryContract::UNKNOWN
            : ($resolution['resolution'] ?? InMemoryLogicalPersistenceRepositoryContract::UNKNOWN);

        return array_merge(self::nonAuthorityFields(), [
            'record_kind' => 'APPLICATION_INTERFACE_CURRENT_PROJECTION_RESULT',
            'resolution' => $applicationResolution,
            'persistence_resolution' => $resolution['resolution'] ?? InMemoryLogicalPersistenceRepositoryContract::UNKNOWN,
            'binding_classification' => $binding,
            'viewer_reference' => is_string($requestBindings['viewer'] ?? null)
                ? $requestBindings['viewer']
                : null,
            'projection' => $safeProjection,
            'read_only' => true,
            'privacy_minimal' => true,
            'projection_is_permission' => false,
            'source_local_revision_only' => true,
            'global_revision' => false,
            'last_write_wins' => false,
            'last_received_wins' => false,
        ]);
    }

    /**
     * @param array<string, mixed> $query
     * @param array<string, mixed> $requiredBindings
     * @param array<string, mixed> $sourceEvidence
     * @return array<string, mixed>
     */
    public function revalidateProtectedAction(
        array $query,
        array $requiredBindings,
        array $sourceEvidence,
    ): array {
        $resolution = $this->persistence->resolveCurrent($query);
        $projection = is_array($resolution['record'] ?? null) ? $resolution['record'] : null;
        $reasons = [];
        $persistenceResolution = $resolution['resolution'] ?? InMemoryLogicalPersistenceRepositoryContract::UNKNOWN;

        if ($projection === null) {
            $reasons[] = 'SOURCE_EVIDENCE_UNAVAILABLE';
        }

        if ($persistenceResolution !== InMemoryLogicalPersistenceRepositoryContract::RESOLVED) {
            $reasons[] = match ($persistenceResolution) {
                InMemoryLogicalPersistenceRepositoryContract::INVALIDATED => 'INVALIDATED',
                InMemoryLogicalPersistenceRepositoryContract::STALE => 'STALE',
                InMemoryLogicalPersistenceRepositoryContract::INCOMPARABLE => 'INCOMPARABLE',
                InMemoryLogicalPersistenceRepositoryContract::MISSING => 'MISSING',
                InMemoryLogicalPersistenceRepositoryContract::ABSENT => 'ABSENT',
                InMemoryLogicalPersistenceRepositoryContract::UNAVAILABLE => 'UNAVAILABLE',
                InMemoryLogicalPersistenceRepositoryContract::SUPERSEDED => 'SUPERSEDED',
                default => 'CURRENT_SOURCE_EVIDENCE_NOT_ESTABLISHED',
            };
        }

        $protected = CommonAuthorityEvidenceContract::evaluateProtected($sourceEvidence, $requiredBindings);
        array_push($reasons, ...$protected['reasons']);

        if ($projection !== null && ! $this->evidenceMatchesProjection($sourceEvidence, $projection)) {
            $reasons[] = 'PERSISTED_PROJECTION_AND_SOURCE_EVIDENCE_MISMATCH';
        }

        if (($projection['projection_invalidated'] ?? false) === true) {
            $reasons[] = 'INVALIDATED';
        }

        $reasons = array_values(array_unique($reasons));
        $knownDenialReasons = [
            'STALE',
            'INVALIDATED',
            'SOURCE_CONDITION_NOT_PRESENT',
            'NOT_CURRENT',
            'NOT_FRESH',
            'PERSISTED_PROJECTION_AND_SOURCE_EVIDENCE_MISMATCH',
        ];
        $hasBindingMismatch = count(array_filter(
            $reasons,
            static fn (string $reason): bool => str_starts_with($reason, 'BINDING_MISMATCH:'),
        )) > 0;
        $hasKnownDenial = $hasBindingMismatch || array_intersect($knownDenialReasons, $reasons) !== [];

        $classification = $reasons === [] && ($protected['satisfied'] ?? false) === true
            ? self::GRANTED
            : ($hasKnownDenial ? self::DENIED : self::UNKNOWN);

        return array_merge(self::nonAuthorityFields(), [
            'record_kind' => 'APPLICATION_INTERFACE_PROTECTED_ACTION_REVALIDATION_RESULT',
            'classification' => $classification,
            'reasons' => $reasons,
            'persistence_resolution' => $persistenceResolution,
            'source_condition' => $projection['source_condition'] ?? ($sourceEvidence['source_condition'] ?? null),
            'source_revision' => $sourceEvidence['source_revision'] ?? null,
            'currentness' => $sourceEvidence['currentness'] ?? null,
            'freshness' => $sourceEvidence['freshness'] ?? null,
            'descriptive_only' => true,
            'execution_must_revalidate' => true,
            'reusable_permission' => false,
            'source_local_revision_only' => true,
            'global_revision' => false,
            'last_write_wins' => false,
            'last_received_wins' => false,
        ]);
    }

    /** @return array<string, mixed> */
    public function observeInvalidation(string $logicalRecordIdentity, string $relation): array
    {
        $observation = $this->persistence->observeInvalidation($logicalRecordIdentity, $relation);
        $projection = is_array($observation['record'] ?? null) ? $observation['record'] : null;

        return array_merge(self::nonAuthorityFields(), [
            'record_kind' => 'APPLICATION_INTERFACE_INVALIDATION_OBSERVATION_RESULT',
            'resolution' => $observation['resolution'] ?? InMemoryLogicalPersistenceRepositoryContract::UNKNOWN,
            'logical_record_identity' => $logicalRecordIdentity,
            'relation' => $projection['invalidation_relation'] ?? (
                ($observation['resolution'] ?? null) === InMemoryLogicalPersistenceRepositoryContract::INVALIDATED
                    ? $relation
                    : null
            ),
            'dependent_projection_invalidated' => ($projection['projection_invalidated'] ?? false) === true,
            'dependent_protected_use_valid' => false,
            'lifecycle_reset' => ($projection['lifecycle_reset'] ?? false) === true,
            'reopened' => ($projection['reopened'] ?? false) === true,
            'new_aggregate_created' => ($projection['new_aggregate_created'] ?? false) === true,
            'transition_synthesized' => ($projection['transition_synthesized'] ?? false) === true,
            'deletion_inferred' => false,
            'adverse_meaning_inferred' => false,
            'global_ordering' => false,
            'source_local_revision_only' => true,
            'last_write_wins' => false,
            'last_received_wins' => false,
        ]);
    }

    /**
     * @param array<string, mixed>|null $projection
     * @param array<string, mixed> $requestBindings
     */
    private function projectionBindingClassification(?array $projection, array $requestBindings): string
    {
        $required = ['viewer', 'subject', 'participants', 'audience', 'purpose', 'aggregate_context'];

        foreach ($required as $key) {
            if (! array_key_exists($key, $requestBindings)) {
                return self::UNKNOWN;
            }
        }

        if (! is_string($requestBindings['viewer']) || $requestBindings['viewer'] === '') {
            return self::UNKNOWN;
        }

        if ($projection === null) {
            return 'EXACT';
        }

        $comparisons = [
            'subject' => 'subject_reference',
            'participants' => 'participant_references',
            'audience' => 'audience',
            'purpose' => 'purpose',
            'aggregate_context' => 'aggregate_context',
        ];

        foreach ($comparisons as $requestKey => $projectionKey) {
            if ($requestBindings[$requestKey] !== ($projection[$projectionKey] ?? null)) {
                return 'MISMATCH';
            }
        }

        return 'EXACT';
    }

    /**
     * @param array<string, mixed> $sourceEvidence
     * @param array<string, mixed> $projection
     */
    private function evidenceMatchesProjection(array $sourceEvidence, array $projection): bool
    {
        $bindings = is_array($sourceEvidence['bindings'] ?? null) ? $sourceEvidence['bindings'] : [];
        $revision = is_array($sourceEvidence['source_revision'] ?? null) ? $sourceEvidence['source_revision'] : [];

        return ($sourceEvidence['record_kind'] ?? null) === 'SOURCE_EVIDENCE'
            && ($bindings['authority_owner'] ?? null) === ($projection['authority_owner'] ?? null)
            && ($bindings['authority_scope'] ?? null) === ($projection['authority_scope'] ?? null)
            && ($bindings['subject'] ?? null) === ($projection['subject_reference'] ?? null)
            && ($bindings['participants'] ?? null) === ($projection['participant_references'] ?? null)
            && ($bindings['audience'] ?? null) === ($projection['audience'] ?? null)
            && ($bindings['purpose'] ?? null) === ($projection['purpose'] ?? null)
            && ($bindings['aggregate_context'] ?? null) === ($projection['aggregate_context'] ?? null)
            && ($bindings['lifecycle_identity'] ?? null) === ($projection['lifecycle_identity'] ?? null)
            && ($bindings['terminal'] ?? null) === ($projection['terminal'] ?? null)
            && ($revision['authority_owner'] ?? null) === ($projection['authority_owner'] ?? null)
            && ($revision['authority_scope'] ?? null) === ($projection['authority_scope'] ?? null)
            && ($revision['lineage'] ?? null) === ($projection['source_revision_lineage'] ?? null)
            && ($revision['aggregate_context'] ?? null) === ($projection['aggregate_context'] ?? null)
            && ($revision['value'] ?? null) === ($projection['source_revision_value'] ?? null)
            && ($sourceEvidence['source_condition'] ?? null) === ($projection['source_condition'] ?? null)
            && ($sourceEvidence['currentness'] ?? null) === ($projection['currentness'] ?? null)
            && ($sourceEvidence['freshness'] ?? null) === ($projection['freshness'] ?? null);
    }

    /** @return array<string, false> */
    private static function nonAuthorityFields(): array
    {
        return [
            'source_authority' => false,
            'domain_writer_authority' => false,
            'authoritative_mutation_success' => false,
            'permission' => false,
            'permission_token' => false,
            'bearer_capability' => false,
            'transport_execution_authority' => false,
            'production_ready' => false,
            'deployable' => false,
            'real_data_authorized' => false,
            'readiness_authority' => false,
            'match_authority' => false,
            'connection_authority' => false,
            'consent_authority' => false,
            'conversation_authority' => false,
            'relationship_authority' => false,
            'home_action_authority' => false,
            'notification_delivery_authority' => false,
            'launch_authority' => false,
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
