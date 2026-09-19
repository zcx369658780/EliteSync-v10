<?php

namespace App\Domain;

use InvalidArgumentException;

final class RuntimeReadinessPersistenceApplicationAdapter
{
    public const SYNTHETIC_FIXTURE_MARKER = 'ELITESYNC_RR03_SYNTHETIC_DEV_TEST_V1';

    private const PREREQUISITE_SET_KEYS = [
        'synthetic_fixture',
        'state',
        'set_identity',
        'required_member_ids',
        'protected_use_scope',
        'required_bindings',
        'source_evidence',
        'private_fixture_extensions',
    ];

    private const MEMBER_KEYS = [
        'synthetic_fixture',
        'member_identity',
        'fact_class',
        'protected_use_scope',
        'required_bindings',
        'source_evidence',
        'prerequisite_outcome',
        'private_fixture_extensions',
    ];

    private const NON_AUTHORITY_FIELDS = [
        'source_authority',
        'domain_writer_authority',
        'authoritative_mutation_success',
        'permission',
        'permission_token',
        'bearer_capability',
        'authentication_authority',
        'transport_execution_authority',
        'http_semantics',
        'controller_authority',
        'route_authority',
        'production_ready',
        'deployable',
        'real_data_authorized',
        'match_authority',
        'connection_authority',
        'consent_authority',
        'conversation_authority',
        'relationship_authority',
        'launch_authority',
    ];

    public function __construct(
        private readonly PersistenceBoundaryApplicationInterfaceIntegrationContract $application,
    ) {}

    /**
     * @param array<string, mixed> $prerequisiteSet
     * @param list<array<string, mixed>> $memberEvidence
     * @return array<string, mixed>
     */
    public function evaluateSynthetic(array $prerequisiteSet, array $memberEvidence): array
    {
        $this->assertSyntheticInput($prerequisiteSet, $memberEvidence);

        $derived = RuntimeReadinessDerivedEvaluator::derive($prerequisiteSet, $memberEvidence);
        $payload = $this->buildPayload($derived, $prerequisiteSet, $memberEvidence);
        $record = $this->buildRecord($payload, $prerequisiteSet);
        $submission = $this->application->submitAuthoritativeMutation($record);
        $storageDisposition = $submission['persistence']['storage_outcome']
            ?? InMemoryLogicalPersistenceRepositoryContract::INVALID_RECORD_REJECTED;
        $retrievable = in_array($storageDisposition, [
            InMemoryLogicalPersistenceRepositoryContract::STORED_NEW,
            InMemoryLogicalPersistenceRepositoryContract::EXACT_DUPLICATE,
        ], true);
        $retrieval = null;

        if ($retrievable) {
            $retrieval = $this->application->retrieveCurrentProjection([
                'record_family' => InMemoryLogicalPersistenceRepositoryContract::RECORD_FAMILY_RR03,
                'authority_owner' => $record['bindings']['authority_owner'],
                'authority_scope' => $record['bindings']['authority_scope'],
                'aggregate_context' => $record['bindings']['aggregate_context'],
                'lineage' => $record['source_revision']['lineage'],
            ], [
                'viewer' => $record['bindings']['actor'],
                'subject' => $record['bindings']['subject'],
                'participants' => $record['bindings']['participants'],
                'audience' => $record['bindings']['audience'],
                'purpose' => $record['bindings']['purpose'],
                'aggregate_context' => $record['bindings']['aggregate_context'],
            ]);
        }

        $readbackPayload = $retrieval['projection']['derived_projection_payload'] ?? null;
        $projectionUsable = $retrieval !== null
            && ($retrieval['resolution'] ?? null) === InMemoryLogicalPersistenceRepositoryContract::RESOLVED
            && ($retrieval['binding_classification'] ?? null) === 'EXACT'
            && ($retrieval['projection']['projection_invalidated'] ?? true) === false
            && is_array($readbackPayload)
            && $readbackPayload === $payload;
        $condition = match (true) {
            ! $retrievable => 'STORAGE_REJECTED_RETRIEVAL_SKIPPED',
            $projectionUsable => 'EXACT_PRIVACY_MINIMAL_RR03_PROJECTION_MATERIALIZED',
            default => 'RR03_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED',
        };

        return array_merge($this->nonAuthorityFields(), [
            'record_kind' => 'RUNTIME_READINESS_PERSISTENCE_APPLICATION_ADAPTER_RESULT',
            'readiness_classification' => $derived['classification'],
            'rr03_payload' => $payload,
            'logical_record_identity' => $record['logical_record_identity'],
            'logical_intent_identity' => $record['logical_intent']['intent_identity'],
            'source_projection_lineage' => $record['source_revision']['lineage'],
            'lifecycle_identity' => $record['bindings']['lifecycle_identity'],
            'source_revision' => $record['source_revision'],
            'storage_disposition' => $storageDisposition,
            'projection_read_disposition' => $retrieval['resolution'] ?? null,
            'materialized_projection_usable' => $projectionUsable,
            'authoritative_outcome' => $submission['authoritative_outcome']
                ?? CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN,
            'reconciliation_required' => ($submission['reconciliation_required'] ?? true) === true,
            'invalidation_required' => ($payload['invalidation']['invalidated'] ?? false) === true,
            'revalidation_required' => ! $projectionUsable,
            'transport_disposition' => null,
            'http_status' => null,
            'condition' => $condition,
            'synthetic_dev_test_only' => true,
            'source_local_revision_only' => true,
            'global_revision' => false,
            'last_write_wins' => false,
            'last_received_wins' => false,
        ]);
    }

    /** @param array<string, mixed> $prerequisiteSet @param list<array<string, mixed>> $memberEvidence */
    private function assertSyntheticInput(array $prerequisiteSet, array $memberEvidence): void
    {
        if (! $this->hasExactKeys($prerequisiteSet, self::PREREQUISITE_SET_KEYS)
            || ($prerequisiteSet['synthetic_fixture'] ?? null) !== self::SYNTHETIC_FIXTURE_MARKER
            || ! in_array($prerequisiteSet['state'] ?? null, [
                RuntimeReadinessDerivedEvaluator::SET_KNOWN,
                RuntimeReadinessDerivedEvaluator::SET_UNKNOWN,
            ], true)
            || ! is_array($prerequisiteSet['required_member_ids'] ?? null)
            || ! array_is_list($prerequisiteSet['required_member_ids'])
            || count($prerequisiteSet['required_member_ids'])
                !== count(array_unique($prerequisiteSet['required_member_ids']))
            || ! is_string($prerequisiteSet['protected_use_scope'] ?? null)
            || $prerequisiteSet['protected_use_scope'] === ''
            || ! is_array($prerequisiteSet['required_bindings'] ?? null)
            || ! is_array($prerequisiteSet['source_evidence'] ?? null)
            || ! is_array($prerequisiteSet['private_fixture_extensions'] ?? null)) {
            throw new InvalidArgumentException('Malformed or non-synthetic prerequisite set rejected.');
        }

        foreach ($prerequisiteSet['required_member_ids'] as $identity) {
            if (! is_string($identity) || $identity === '') {
                throw new InvalidArgumentException('Malformed synthetic prerequisite member identity rejected.');
            }
        }

        if (! ($prerequisiteSet['set_identity'] === null
            || (is_string($prerequisiteSet['set_identity']) && $prerequisiteSet['set_identity'] !== ''))) {
            throw new InvalidArgumentException('Malformed synthetic prerequisite-set identity rejected.');
        }

        $this->assertEvidenceContainer(
            $prerequisiteSet['required_bindings'],
            $prerequisiteSet['source_evidence'],
        );

        if (! array_is_list($memberEvidence)) {
            throw new InvalidArgumentException('Synthetic member evidence must be a list.');
        }

        foreach ($memberEvidence as $member) {
            if (! is_array($member)
                || ! $this->hasExactKeys($member, self::MEMBER_KEYS)
                || ($member['synthetic_fixture'] ?? null) !== self::SYNTHETIC_FIXTURE_MARKER
                || ! is_string($member['member_identity'] ?? null)
                || $member['member_identity'] === ''
                || ! is_array($member['required_bindings'] ?? null)
                || ! is_array($member['source_evidence'] ?? null)
                || ! is_array($member['private_fixture_extensions'] ?? null)) {
                throw new InvalidArgumentException('Malformed or non-synthetic member evidence rejected.');
            }

            $this->assertEvidenceContainer($member['required_bindings'], $member['source_evidence']);
        }
    }

    /** @param array<string, mixed> $requiredBindings @param array<string, mixed> $sourceEvidence */
    private function assertEvidenceContainer(array $requiredBindings, array $sourceEvidence): void
    {
        if (! $this->hasExactKeys($sourceEvidence, [
            'record_kind',
            'bindings',
            'source_condition',
            'source_revision',
            'currentness',
            'freshness',
            'authoritative_outcome',
        ]) || ($sourceEvidence['record_kind'] ?? null) !== 'SOURCE_EVIDENCE'
            || ! is_array($sourceEvidence['bindings'] ?? null)
            || ! is_array($sourceEvidence['source_revision'] ?? null)
            || (! is_bool($sourceEvidence['currentness'] ?? null)
                && ($sourceEvidence['currentness'] ?? null) !== null)
            || (! is_bool($sourceEvidence['freshness'] ?? null)
                && ($sourceEvidence['freshness'] ?? null) !== null)) {
            throw new InvalidArgumentException('Malformed synthetic source evidence rejected.');
        }

        CommonAuthorityEvidenceContract::evidence(
            $sourceEvidence['bindings'],
            $sourceEvidence['source_condition'],
            $sourceEvidence['source_revision'],
            $sourceEvidence['currentness'],
            $sourceEvidence['freshness'],
            $sourceEvidence['authoritative_outcome'],
        );
        CommonAuthorityEvidenceContract::evidence(
            $requiredBindings,
            $sourceEvidence['source_condition'],
            $sourceEvidence['source_revision'],
            $sourceEvidence['currentness'],
            $sourceEvidence['freshness'],
            $sourceEvidence['authoritative_outcome'],
        );
    }

    /**
     * @param array<string, mixed> $derived
     * @param array<string, mixed> $prerequisiteSet
     * @param list<array<string, mixed>> $memberEvidence
     * @return array<string, mixed>
     */
    private function buildPayload(array $derived, array $prerequisiteSet, array $memberEvidence): array
    {
        $dependencies = [];

        foreach ($derived['dependency_vector']['members'] ?? [] as $selected) {
            $revision = $selected['source_revision'] ?? null;
            $member = $this->findSelectedMember($memberEvidence, $selected['member_identity'] ?? null, $revision);

            if ($member === null || ! is_array($revision)) {
                throw new InvalidArgumentException('Selected evaluator dependency is structurally incomplete.');
            }

            $dependencies[] = [
                'dependency_identity' => $selected['member_identity'],
                'fact_class' => $selected['fact_class'],
                'authority_owner' => $revision['authority_owner'],
                'authority_scope' => $revision['authority_scope'],
                'aggregate_context' => $revision['aggregate_context'],
                'source_lineage' => $revision['lineage'],
                'source_revision_value' => $revision['value'],
                'source_condition' => $selected['source_condition'],
                'currentness' => $member['source_evidence']['currentness'] ?? null,
                'freshness' => $member['source_evidence']['freshness'] ?? null,
                'prerequisite_outcome' => $selected['prerequisite_outcome'],
            ];
        }

        usort($dependencies, self::compareDependencies(...));

        return [
            'payload_kind' => 'RR03_RUNTIME_READINESS',
            'derived_fact_class' => RuntimeReadinessDerivedEvaluator::FACT_EFFECTIVE_READINESS,
            'classification' => $derived['classification'],
            'prerequisite_set_state' => $prerequisiteSet['state'],
            'prerequisite_set_identity' => $derived['prerequisite_set_identity'],
            'prerequisite_set_revision' => $this->payloadRevision(
                $derived['dependency_vector']['prerequisite_set']['source_revision'] ?? null,
            ),
            'prerequisite_set_condition' => $derived['dependency_vector']['prerequisite_set']['source_condition'] ?? null,
            'prerequisite_set_currentness' => $prerequisiteSet['source_evidence']['currentness'] ?? null,
            'prerequisite_set_freshness' => $prerequisiteSet['source_evidence']['freshness'] ?? null,
            'protected_use_scope' => $derived['protected_use_scope'],
            'reason_categories' => $this->boundedReasons($derived['reasons'] ?? []),
            'dependencies' => $dependencies,
            'invalidation' => [
                'invalidated' => false,
                'relation' => null,
                'dependency_identity' => null,
            ],
        ];
    }

    /** @param array<string, mixed> $payload @param array<string, mixed> $prerequisiteSet @return array<string, mixed> */
    private function buildRecord(array $payload, array $prerequisiteSet): array
    {
        $sourceBindings = $prerequisiteSet['required_bindings'];
        $lifecycleBasis = [
            'prerequisite_set_identity' => $payload['prerequisite_set_identity'],
            'protected_use_scope' => $payload['protected_use_scope'],
            'subject' => $sourceBindings['subject'] ?? null,
            'participants' => $sourceBindings['participants'] ?? null,
            'audience' => $sourceBindings['audience'] ?? null,
            'purpose' => $sourceBindings['purpose'] ?? null,
            'aggregate_context' => $sourceBindings['aggregate_context'] ?? null,
        ];
        $lifecycleIdentity = 'rr03-lifecycle-v1:'.$this->digest($lifecycleBasis);
        $scope = 'EFFECTIVE_READINESS|'.$payload['protected_use_scope'];
        $bindings = [
            'authority_owner' => 'RUNTIME_READINESS_DERIVATION',
            'authority_scope' => $scope,
            'actor' => $sourceBindings['actor'],
            'actor_role' => $sourceBindings['actor_role'],
            'subject' => $sourceBindings['subject'],
            'participants' => $sourceBindings['participants'],
            'audience' => $sourceBindings['audience'],
            'purpose' => $sourceBindings['purpose'],
            'aggregate_context' => $sourceBindings['aggregate_context'],
            'lifecycle_identity' => $lifecycleIdentity,
            'terminal' => $sourceBindings['terminal'],
        ];
        $semanticIdentity = [
            'record_family' => InMemoryLogicalPersistenceRepositoryContract::RECORD_FAMILY_RR03,
            'bindings' => $bindings,
            'lifecycle_basis' => $lifecycleBasis,
            'derived_projection_payload' => $payload,
        ];
        $digest = $this->digest($semanticIdentity);
        $logicalRecordIdentity = 'rr03-record-v1:'.$digest;
        $intentIdentity = 'rr03-intent-v1:'.$digest;
        $lineage = 'rr03-lineage-v1:'.$digest;

        return [
            'logical_record_identity' => $logicalRecordIdentity,
            'record_family' => InMemoryLogicalPersistenceRepositoryContract::RECORD_FAMILY_RR03,
            'bindings' => $bindings,
            'source_revision' => [
                'authority_owner' => 'RUNTIME_READINESS_DERIVATION',
                'authority_scope' => $scope,
                'lineage' => $lineage,
                'aggregate_context' => $bindings['aggregate_context'],
                'value' => 0,
            ],
            'source_condition' => CommonAuthorityEvidenceContract::CONDITION_PRESENT,
            'currentness' => $this->dependencySummary($payload, 'currentness'),
            'freshness' => $this->dependencySummary($payload, 'freshness'),
            'logical_intent' => [
                'intent_identity' => $intentIdentity,
                'semantic_input' => $semanticIdentity,
            ],
            'authoritative_outcome' => CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN,
            'authoritative_outcome_metadata' => null,
            'correction_metadata' => null,
            'projection_metadata' => [
                'projection_identity' => 'rr03-projection-v1:'.$digest,
                'represented_source_revision_value' => 0,
                'lag_classification' => 'CURRENT',
                'projection_currentness' => $this->dependencySummary($payload, 'currentness'),
            ],
            'transport_observation' => 'AMBIGUOUS',
            'private_fixture_extensions' => [],
            'derived_projection_payload' => $payload,
        ];
    }

    /** @param list<array<string, mixed>> $members @param array<string, mixed>|null $revision */
    private function findSelectedMember(array $members, mixed $identity, ?array $revision): ?array
    {
        foreach ($members as $member) {
            if (($member['member_identity'] ?? null) === $identity
                && ($member['source_evidence']['source_revision'] ?? null) === $revision) {
                return $member;
            }
        }

        return null;
    }

    /** @param array<string, mixed>|null $revision @return array<string, mixed>|null */
    private function payloadRevision(?array $revision): ?array
    {
        if ($revision === null) {
            return null;
        }

        return [
            'authority_owner' => $revision['authority_owner'],
            'authority_scope' => $revision['authority_scope'],
            'aggregate_context' => $revision['aggregate_context'],
            'lineage' => $revision['lineage'],
            'value' => $revision['value'],
        ];
    }

    /** @param list<string> $reasons @return list<string> */
    private function boundedReasons(array $reasons): array
    {
        $mapping = [
            'UNKNOWN_PREREQUISITE_SET' => 'UNKNOWN_PREREQUISITE_SET',
            'INVALID_PREREQUISITE_SET_STATE' => 'INVALID_PREREQUISITE_SET',
            'INVALID_EXACT_PREREQUISITE_SET' => 'INVALID_PREREQUISITE_SET',
            'PREREQUISITE_SET_NOT_CURRENT_FRESH_AUTHORITATIVE' => 'PREREQUISITE_SET_UNUSABLE',
            'MISSING_REQUIRED_MEMBER' => 'MISSING_REQUIRED_MEMBER',
            'INVALID_REQUIRED_MEMBER_ID' => 'INVALID_REQUIRED_MEMBER',
            'INVALID_MEMBER_EVIDENCE' => 'INVALID_REQUIRED_MEMBER',
            'INCOMPARABLE_DUPLICATE_EVIDENCE' => 'INCOMPARABLE_DUPLICATE_EVIDENCE',
            'CONFLICTING_DUPLICATE_EVIDENCE' => 'CONFLICTING_DUPLICATE_EVIDENCE',
            'INVALID_MEMBER_FACT_CLASS' => 'INVALID_MEMBER_FACT_CLASS',
            'PROTECTED_USE_SCOPE_MISMATCH' => 'PROTECTED_USE_SCOPE_MISMATCH',
            'MEMBER_NOT_CURRENT_FRESH_AUTHORITATIVE' => 'MEMBER_UNUSABLE',
            'UNKNOWN_MEMBER_OUTCOME' => 'UNKNOWN_MEMBER_OUTCOME',
            'AUTHORITATIVE_REQUIRED_MEMBER_UNSATISFIED' => 'AUTHORITATIVE_REQUIRED_MEMBER_UNSATISFIED',
            'DEPENDENCY_INVALIDATED' => 'DEPENDENCY_INVALIDATED',
        ];
        $bounded = [];

        foreach ($reasons as $reason) {
            $category = explode(':', $reason, 2)[0];

            if (! isset($mapping[$category])) {
                throw new InvalidArgumentException('Unmapped readiness reason rejected.');
            }

            if (! in_array($mapping[$category], $bounded, true)) {
                $bounded[] = $mapping[$category];
            }
        }

        return $bounded;
    }

    /** @param array<string, mixed> $payload */
    private function dependencySummary(array $payload, string $field): ?bool
    {
        if ($payload['prerequisite_set_state'] !== RuntimeReadinessDerivedEvaluator::SET_KNOWN) {
            return null;
        }

        $values = [$payload['prerequisite_set_'.$field]];

        foreach ($payload['dependencies'] as $dependency) {
            $values[] = $dependency[$field];
        }

        if (in_array(false, $values, true)) {
            return false;
        }

        return in_array(null, $values, true) ? null : true;
    }

    /** @param array<string, mixed> $left @param array<string, mixed> $right */
    private static function compareDependencies(array $left, array $right): int
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

    /** @param array<string, mixed> $value @param list<string> $expected */
    private function hasExactKeys(array $value, array $expected): bool
    {
        $keys = array_keys($value);
        sort($keys);
        sort($expected);

        return $keys === $expected;
    }

    /** @return array<string, false> */
    private function nonAuthorityFields(): array
    {
        return array_fill_keys(self::NON_AUTHORITY_FIELDS, false);
    }

    private function digest(mixed $value): string
    {
        return hash('sha256', serialize($this->canonicalize($value)));
    }

    private function canonicalize(mixed $value): mixed
    {
        if (! is_array($value)) {
            return $value;
        }

        if (array_is_list($value)) {
            return array_map($this->canonicalize(...), $value);
        }

        ksort($value);

        foreach ($value as $key => $nested) {
            $value[$key] = $this->canonicalize($nested);
        }

        return $value;
    }
}
