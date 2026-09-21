<?php

namespace App\Domain;

use InvalidArgumentException;

final class ProductConnectionPersistenceApplicationAdapter
{
    private const CONNECTION_KEYS = ['connection_identity', 'participants', 'protected_use_scope'];
    private const STATE_EVIDENCE_KEYS = [
        'state_evidence_identity', 'connection_identity', 'participants', 'state', 'required_bindings', 'source_evidence',
    ];
    private const TRANSITION_EVIDENCE_KEYS = [
        'transition_identity', 'connection_identity', 'participants', 'from_state', 'to_state',
        'expected_state_revision', 'required_bindings', 'source_evidence',
    ];
    private const BINDING_KEYS = [
        'authority_owner', 'authority_scope', 'actor', 'actor_role', 'subject', 'participants',
        'audience', 'purpose', 'aggregate_context', 'lifecycle_identity', 'terminal',
    ];
    private const EVIDENCE_KEYS = [
        'record_kind', 'bindings', 'source_condition', 'source_revision', 'currentness', 'freshness', 'authoritative_outcome',
    ];
    private const REVISION_KEYS = ['authority_owner', 'authority_scope', 'lineage', 'aggregate_context', 'value'];
    private const CURRENT_REASONS = [
        'MISSING_CURRENT_STATE_EVIDENCE', 'CROSS_CONNECTION_STATE_EVIDENCE', 'STATE_PARTICIPANT_MISMATCH',
        'CONFLICTING_STATE_EVIDENCE_IDENTITY', 'INCOMPARABLE_DUPLICATE_STATE_EVIDENCE',
        'CONFLICTING_EQUAL_REVISION_STATE_EVIDENCE', 'CURRENT_STATE_NOT_CURRENT_FRESH_BOUND', 'DEPENDENCY_INVALIDATED',
    ];
    private const TRANSITION_REASONS = [
        'MISSING_CURRENT_STATE_EVIDENCE', 'CROSS_CONNECTION_STATE_EVIDENCE', 'STATE_PARTICIPANT_MISMATCH',
        'CONFLICTING_STATE_EVIDENCE_IDENTITY', 'INCOMPARABLE_DUPLICATE_STATE_EVIDENCE',
        'CONFLICTING_EQUAL_REVISION_STATE_EVIDENCE', 'CURRENT_STATE_NOT_CURRENT_FRESH_BOUND',
        'MISSING_TRANSITION_EVIDENCE', 'CROSS_CONNECTION_TRANSITION_EVIDENCE', 'TRANSITION_PARTICIPANT_MISMATCH',
        'CONFLICTING_TRANSITION_IDENTITY', 'INCOMPARABLE_DUPLICATE_TRANSITION_EVIDENCE',
        'CONFLICTING_EQUAL_REVISION_TRANSITION_EVIDENCE', 'TRANSITION_NOT_CURRENT_FRESH_BOUND',
        'TRANSITION_CURRENT_CONTEXT_MISMATCH', 'TERMINAL_CONNECTION_IDENTITY_CANNOT_REOPEN',
        'DIRECT_NONE_TO_ACTIVE_REJECTED', 'TRANSITION_NOT_ALLOWED', 'DEPENDENCY_INVALIDATED',
    ];
    private const FALSE_RESULT_FIELDS = [
        'global_revision', 'last_write_wins', 'last_received_wins', 'source_authority', 'domain_writer_authority',
        'authoritative_mutation_success', 'permission', 'permission_token', 'bearer_capability',
        'transport_execution_authority', 'production_ready', 'deployable', 'real_data_authorized', 'readiness_authority',
        'match_authority', 'connection_authority', 'consent_authority', 'conversation_authority', 'relationship_authority',
        'home_action_authority', 'notification_delivery_authority', 'launch_authority', 'connection_created',
        'connection_activated', 'match_substituted_for_connection', 'messaging_consent_granted', 'conversation_granted',
        'source_evidence_mutated',
    ];

    public function __construct(
        private readonly PersistenceBoundaryApplicationInterfaceIntegrationContract $application,
    ) {}

    /** @param array<string, mixed> $request @return array<string, mixed> */
    public function evaluateCurrentSynthetic(array $request): array
    {
        return $this->execute($request, false, false);
    }

    /** @param array<string, mixed> $request @return array<string, mixed> */
    public function evaluateTransitionSynthetic(array $request): array
    {
        return $this->execute($request, true, false);
    }

    /** @param array<string, mixed> $request @return array<string, mixed> */
    public function invalidateCurrentSynthetic(array $request): array
    {
        return $this->execute($request, false, true);
    }

    /** @param array<string, mixed> $request @return array<string, mixed> */
    public function invalidateTransitionSynthetic(array $request): array
    {
        return $this->execute($request, true, true);
    }

    /** @param array<string, mixed> $request @return array<string, mixed> */
    private function execute(array $request, bool $transition, bool $invalidate): array
    {
        $this->assertRequest($request, $transition, $invalidate);
        $connection = $request['connection'];
        $before = $transition
            ? ProductConnectionStateTransitionEvaluator::evaluateTransition(
                $connection,
                $request['state_evidence'],
                $request['transition_evidence'],
                null,
            )
            : ProductConnectionStateTransitionEvaluator::evaluateCurrent($connection, $request['state_evidence']);
        $this->assertDerived($before, $connection, $transition, false);
        $derived = $before;

        if ($invalidate) {
            $identity = $request['dependency_identity'];
            $retained = array_values(array_filter([
                $before['dependency_vector']['current_state'] ?? null,
                $before['dependency_vector']['transition'] ?? null,
            ], static fn (mixed $dependency): bool => is_array($dependency)));
            $matches = array_filter($retained, static fn (array $dependency): bool =>
                ($dependency['state_evidence_identity'] ?? $dependency['transition_identity'] ?? null) === $identity
            );

            if (count($matches) !== 1) {
                throw new InvalidArgumentException('SELECTED_DEPENDENCY_INVALIDATION_TARGET_REQUIRED');
            }

            $derived = ProductConnectionStateTransitionEvaluator::invalidate($before, $identity, $request['relation']);
            $this->assertDerived($derived, $connection, $transition, true);

            if ($derived['classification'] !== 'UNKNOWN'
                || $derived['reasons'] !== ['DEPENDENCY_INVALIDATED']
                || $derived['dependency_vector'] !== $before['dependency_vector']
                || $derived['current_state'] !== $before['current_state']
                || $derived['proposed_state'] !== $before['proposed_state']
                || $derived['connection_active_for_downstream_consideration'] !== false
                || $derived['valid_for_protected_use'] !== false
                || $derived['invalidation'] !== [
                    'dependency_identity' => $identity,
                    'relation' => $request['relation'],
                ]
                || $derived['lifecycle_reset'] !== false
                || $derived['connection_reopened'] !== false) {
                throw new InvalidArgumentException('INVALID_PRODUCT_CONNECTION_INVALIDATION_RESULT');
            }
        }

        $payload = $this->buildPayload($derived, $request, $transition, $invalidate);

        return $this->submitAndRead($payload, $invalidate
            ? ($transition ? 'INVALIDATE_TRANSITION_DEPENDENCY' : 'INVALIDATE_CURRENT_STATE_DEPENDENCY')
            : ($transition ? 'EVALUATE_TRANSITION' : 'EVALUATE_CURRENT_STATE'));
    }

    /** @param array<string, mixed> $request */
    private function assertRequest(array $request, bool $transition, bool $invalidate): void
    {
        $keys = ['synthetic_dev_test_only', 'connection', 'state_evidence'];

        if ($transition) {
            $keys[] = 'transition_evidence';
        }

        if ($invalidate) {
            array_push($keys, 'dependency_identity', 'relation');
        }

        if (! $this->hasExactKeys($request, $keys)
            || ($request['synthetic_dev_test_only'] ?? null) !== true
            || ! is_array($request['connection'] ?? null)
            || ! is_array($request['state_evidence'] ?? null)
            || ! array_is_list($request['state_evidence'])
            || ($transition && (! is_array($request['transition_evidence'] ?? null)
                || ! array_is_list($request['transition_evidence'])))) {
            throw new InvalidArgumentException('INVALID_EVIDENCE_SHAPE');
        }

        $connection = $request['connection'];

        if (! $this->nonEmptyString($connection['connection_identity'] ?? null)) {
            throw new InvalidArgumentException('CONNECTION_IDENTITY_REQUIRED');
        }

        if (! $this->validParticipantPair($connection['participants'] ?? null)) {
            throw new InvalidArgumentException('EXACTLY_TWO_PARTICIPANTS_REQUIRED');
        }

        if (! $this->nonEmptyString($connection['protected_use_scope'] ?? null)) {
            throw new InvalidArgumentException('PROTECTED_USE_SCOPE_REQUIRED');
        }

        if (! $this->hasExactKeys($connection, self::CONNECTION_KEYS)) {
            throw new InvalidArgumentException('INVALID_EVIDENCE_SHAPE');
        }

        foreach ($request['state_evidence'] as $item) {
            if (! is_array($item)
                || ! $this->hasExactKeys($item, self::STATE_EVIDENCE_KEYS)
                || ! $this->nonEmptyString($item['state_evidence_identity'] ?? null)
                || ! $this->nonEmptyString($item['connection_identity'] ?? null)
                || ! $this->validParticipantPair($item['participants'] ?? null)
                || ! is_array($item['required_bindings'] ?? null)
                || ! is_array($item['source_evidence'] ?? null)) {
                throw new InvalidArgumentException('INVALID_EVIDENCE_SHAPE');
            }

            if (! in_array($item['state'] ?? null, ProductConnectionStateTransitionEvaluator::lifecycleVocabulary(), true)) {
                throw new InvalidArgumentException('INVALID_CONNECTION_STATE');
            }

            $this->assertEvidence($item['required_bindings'], $item['source_evidence']);
        }

        if ($transition) {
            foreach ($request['transition_evidence'] as $item) {
                if (! is_array($item)
                    || ! $this->hasExactKeys($item, self::TRANSITION_EVIDENCE_KEYS)
                    || ! $this->nonEmptyString($item['transition_identity'] ?? null)
                    || ! $this->nonEmptyString($item['connection_identity'] ?? null)
                    || ! $this->validParticipantPair($item['participants'] ?? null)
                    || ! is_array($item['required_bindings'] ?? null)
                    || ! is_array($item['source_evidence'] ?? null)
                    || ! is_array($item['expected_state_revision'] ?? null)
                    || ! $this->validRevision($item['expected_state_revision'])) {
                    throw new InvalidArgumentException('INVALID_EVIDENCE_SHAPE');
                }

                if (! in_array($item['from_state'] ?? null, ProductConnectionStateTransitionEvaluator::lifecycleVocabulary(), true)) {
                    throw new InvalidArgumentException('INVALID_CONNECTION_STATE');
                }

                if (! in_array($item['to_state'] ?? null, ProductConnectionStateTransitionEvaluator::lifecycleVocabulary(), true)) {
                    throw new InvalidArgumentException('INVALID_TARGET_STATE');
                }

                $this->assertEvidence($item['required_bindings'], $item['source_evidence']);
            }
        }

        if ($invalidate && (! $this->nonEmptyString($request['dependency_identity'] ?? null)
            || ! in_array($request['relation'] ?? null, [
                CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
                CommonAuthorityEvidenceContract::INVALIDATION_REVOCATION,
                CommonAuthorityEvidenceContract::INVALIDATION_SUPERSESSION,
            ], true))) {
            throw new InvalidArgumentException('INVALID_EVIDENCE_SHAPE');
        }
    }

    /** @param array<string, mixed> $required @param array<string, mixed> $evidence */
    private function assertEvidence(array $required, array $evidence): void
    {
        if (! $this->validBindings($required)
            || ! $this->hasExactKeys($evidence, self::EVIDENCE_KEYS)
            || ($evidence['record_kind'] ?? null) !== 'SOURCE_EVIDENCE'
            || ! is_array($evidence['bindings'] ?? null)
            || ! $this->validBindings($evidence['bindings'])
            || ! is_array($evidence['source_revision'] ?? null)
            || ! $this->validRevision($evidence['source_revision'])
            || ($evidence['source_revision']['authority_owner'] ?? null) !== $evidence['bindings']['authority_owner']
            || ($evidence['source_revision']['authority_scope'] ?? null) !== $evidence['bindings']['authority_scope']
            || ($evidence['source_revision']['aggregate_context'] ?? null) !== $evidence['bindings']['aggregate_context']
            || ! in_array($evidence['source_condition'] ?? null, [
                CommonAuthorityEvidenceContract::CONDITION_PRESENT,
                CommonAuthorityEvidenceContract::CONDITION_ABSENT,
                CommonAuthorityEvidenceContract::CONDITION_UNKNOWN,
                CommonAuthorityEvidenceContract::CONDITION_UNAVAILABLE,
                CommonAuthorityEvidenceContract::CONDITION_STALE,
                CommonAuthorityEvidenceContract::CONDITION_SUPERSEDED,
                CommonAuthorityEvidenceContract::CONDITION_INCOMPARABLE,
            ], true)
            || ! $this->nullableBoolean($evidence['currentness'] ?? null)
            || ! $this->nullableBoolean($evidence['freshness'] ?? null)
            || ! in_array($evidence['authoritative_outcome'] ?? null, [
                CommonAuthorityEvidenceContract::OUTCOME_COMMITTED,
                CommonAuthorityEvidenceContract::OUTCOME_REJECTED,
                CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN,
            ], true)) {
            throw new InvalidArgumentException('INVALID_EVIDENCE_SHAPE');
        }
    }

    /** @param array<string, mixed> $derived @param array<string, mixed> $connection */
    private function assertDerived(array $derived, array $connection, bool $transition, bool $invalidated): void
    {
        $expectedFact = $transition
            ? 'PRODUCT_CONNECTION_TRANSITION_DERIVATION'
            : 'PRODUCT_CONNECTION_CURRENT_STATE_DERIVATION';
        $reasons = $derived['reasons'] ?? null;
        $vocabulary = $transition ? self::TRANSITION_REASONS : self::CURRENT_REASONS;

        if (($derived['record_kind'] ?? null) !== $expectedFact
            || ($derived['connection_identity'] ?? null) !== $connection['connection_identity']
            || ($derived['participants'] ?? null) !== $connection['participants']
            || ! is_array($derived['dependency_vector'] ?? null)
            || ! is_array($reasons)
            || ! array_is_list($reasons)
            || count($reasons) !== count(array_unique($reasons))
            || $reasons !== array_values(array_filter(
                $vocabulary,
                static fn (string $reason): bool => in_array($reason, $reasons, true),
            ))
            || ($invalidated && ! isset($derived['invalidation']))) {
            throw new InvalidArgumentException('INVALID_PRODUCT_CONNECTION_EVALUATOR_RESULT');
        }

        foreach ([
            'source_authority', 'connection_created', 'connection_activated', 'match_substituted_for_connection',
            'messaging_consent_granted', 'conversation_granted', 'relationship_authority', 'home_action_authority',
            'notification_authority', 'launch_authority', 'bearer_capability', 'ranking_computed',
            'compatibility_total_computed', 'desirability_computed', 'person_worth_computed',
            'source_evidence_mutated', 'lifecycle_reset', 'connection_reopened',
        ] as $field) {
            if (($derived[$field] ?? null) !== false) {
                throw new InvalidArgumentException('INVALID_PRODUCT_CONNECTION_EVALUATOR_RESULT');
            }
        }
    }

    /** @param array<string, mixed> $derived @param array<string, mixed> $request @return array<string, mixed> */
    private function buildPayload(array $derived, array $request, bool $transition, bool $invalidated): array
    {
        $current = is_array($derived['dependency_vector']['current_state'] ?? null)
            ? $this->recoverCurrentDependency($derived['dependency_vector']['current_state'], $request)
            : null;
        $transitionDependency = $transition && is_array($derived['dependency_vector']['transition'] ?? null)
            ? $this->recoverTransitionDependency($derived['dependency_vector']['transition'], $request)
            : null;

        if ($current !== null && $transitionDependency !== null
            && $current['state_evidence_identity'] === $transitionDependency['transition_identity']) {
            throw new InvalidArgumentException('PRODUCT_CONNECTION_DEPENDENCY_IDENTITY_COLLISION');
        }

        $participants = $request['connection']['participants'];
        sort($participants, SORT_STRING);
        $currentState = $derived['current_state'];
        $ordinaryInvalidation = [
            'invalidated' => false,
            'relation' => null,
            'dependency_identity' => null,
            'lifecycle_reset' => false,
            'connection_reopened' => false,
        ];
        $invalidation = $invalidated ? [
            'invalidated' => true,
            'relation' => $request['relation'],
            'dependency_identity' => $request['dependency_identity'],
            'lifecycle_reset' => false,
            'connection_reopened' => false,
        ] : $ordinaryInvalidation;
        $base = [
            'connection_identity' => $request['connection']['connection_identity'],
            'participant_references' => $participants,
            'protected_use_scope' => $request['connection']['protected_use_scope'],
            'classification' => $derived['classification'],
            'current_state' => $currentState,
            'reason_categories' => $derived['reasons'],
            'current_state_dependency' => $current,
        ];

        if (! $transition) {
            return [
                'payload_kind' => 'PRODUCT_CONNECTION_CURRENT_STATE',
                'derived_fact_class' => 'PRODUCT_CONNECTION_CURRENT_STATE_DERIVATION',
                ...$base,
                'connection_active_for_downstream_consideration' => $derived['connection_active_for_downstream_consideration'],
                'valid_for_protected_use' => $derived['valid_for_protected_use'],
                'terminality' => ['current_state_terminal' => $this->terminal($currentState)],
                'invalidation' => $invalidation,
            ];
        }

        return [
            'payload_kind' => 'PRODUCT_CONNECTION_TRANSITION',
            'derived_fact_class' => 'PRODUCT_CONNECTION_TRANSITION_DERIVATION',
            'connection_identity' => $base['connection_identity'],
            'participant_references' => $base['participant_references'],
            'protected_use_scope' => $base['protected_use_scope'],
            'classification' => $base['classification'],
            'current_state' => $base['current_state'],
            'proposed_state' => $derived['proposed_state'],
            'reason_categories' => $base['reason_categories'],
            'current_state_dependency' => $current,
            'transition_dependency' => $transitionDependency,
            'connection_active_for_downstream_consideration' => $derived['connection_active_for_downstream_consideration'],
            'valid_for_protected_use' => $derived['valid_for_protected_use'],
            'terminality' => [
                'current_state_terminal' => $this->terminal($currentState),
                'proposed_state_terminal' => $this->terminal($derived['proposed_state']),
                'terminal_reopen_rejected' => $derived['reasons'] === ['TERMINAL_CONNECTION_IDENTITY_CANNOT_REOPEN'],
            ],
            'invalidation' => $invalidation,
        ];
    }

    /** @param array<string, mixed> $selected @param array<string, mixed> $request @return array<string, mixed> */
    private function recoverCurrentDependency(array $selected, array $request): array
    {
        $matches = array_values(array_filter($request['state_evidence'], static fn (array $item): bool =>
            $item['state_evidence_identity'] === $selected['state_evidence_identity']
            && $item['connection_identity'] === $selected['connection_identity']
            && $item['state'] === $selected['state']
            && $item['source_evidence']['source_revision'] === $selected['source_revision']
            && $item['source_evidence']['source_condition'] === $selected['source_condition']
        ));

        if ($matches === []) {
            throw new InvalidArgumentException('SELECTED_EVIDENCE_RECOVERY_FAILED');
        }

        $tuples = array_map(fn (array $item): array => [
            $this->protectedBindingSatisfied($item, $request['connection'], true),
            $item['source_evidence']['currentness'],
            $item['source_evidence']['freshness'],
        ], $matches);

        if (count(array_unique(array_map('serialize', $tuples))) !== 1) {
            throw new InvalidArgumentException('SELECTED_EVIDENCE_RECOVERY_FAILED');
        }

        $revision = $selected['source_revision'];

        return [
            'dependency_type' => 'CURRENT_STATE_EVIDENCE',
            'state_evidence_identity' => $selected['state_evidence_identity'],
            'connection_identity' => $selected['connection_identity'],
            'state' => $selected['state'],
            'authority_owner' => $revision['authority_owner'],
            'authority_scope' => $revision['authority_scope'],
            'aggregate_context' => $revision['aggregate_context'],
            'source_lineage' => $revision['lineage'],
            'source_revision_value' => $revision['value'],
            'source_condition' => $selected['source_condition'],
            'protected_binding_satisfied' => $tuples[0][0],
            'currentness' => $tuples[0][1],
            'freshness' => $tuples[0][2],
        ];
    }

    /** @param array<string, mixed> $selected @param array<string, mixed> $request @return array<string, mixed> */
    private function recoverTransitionDependency(array $selected, array $request): array
    {
        $matches = array_values(array_filter($request['transition_evidence'], static fn (array $item): bool =>
            $item['transition_identity'] === $selected['transition_identity']
            && $item['connection_identity'] === $selected['connection_identity']
            && $item['from_state'] === $selected['from_state']
            && $item['to_state'] === $selected['to_state']
            && $item['source_evidence']['source_revision'] === $selected['source_revision']
            && $item['source_evidence']['source_condition'] === $selected['source_condition']
        ));

        if ($matches === []) {
            throw new InvalidArgumentException('SELECTED_EVIDENCE_RECOVERY_FAILED');
        }

        $tuples = array_map(fn (array $item): array => [
            $item['expected_state_revision'],
            $this->protectedBindingSatisfied($item, $request['connection'], false),
            $item['source_evidence']['currentness'],
            $item['source_evidence']['freshness'],
        ], $matches);

        if (count(array_unique(array_map('serialize', $tuples))) !== 1) {
            throw new InvalidArgumentException('SELECTED_EVIDENCE_RECOVERY_FAILED');
        }

        $revision = $selected['source_revision'];

        return [
            'dependency_type' => 'TRANSITION_EVIDENCE',
            'transition_identity' => $selected['transition_identity'],
            'connection_identity' => $selected['connection_identity'],
            'from_state' => $selected['from_state'],
            'to_state' => $selected['to_state'],
            'expected_state_revision' => $tuples[0][0],
            'authority_owner' => $revision['authority_owner'],
            'authority_scope' => $revision['authority_scope'],
            'aggregate_context' => $revision['aggregate_context'],
            'source_lineage' => $revision['lineage'],
            'source_revision_value' => $revision['value'],
            'source_condition' => $selected['source_condition'],
            'protected_binding_satisfied' => $tuples[0][1],
            'currentness' => $tuples[0][2],
            'freshness' => $tuples[0][3],
        ];
    }

    /** @param array<string, mixed> $item @param array<string, mixed> $connection */
    private function protectedBindingSatisfied(array $item, array $connection, bool $current): bool
    {
        $required = $item['required_bindings'];
        $source = $item['source_evidence']['bindings'];

        return $this->bindingsEqualByField($required, $source)
            && $required['subject'] === $connection['connection_identity']
            && $required['aggregate_context'] === $connection['connection_identity']
            && $required['lifecycle_identity'] === $connection['connection_identity']
            && $this->sameParticipants($required['participants'], $connection['participants'])
            && $required['purpose'] === $connection['protected_use_scope']
            && (! $current || $required['terminal'] === $this->terminal($item['state']));
    }

    /** @param array<string, mixed> $required @param array<string, mixed> $source */
    private function bindingsEqualByField(array $required, array $source): bool
    {
        foreach (self::BINDING_KEYS as $key) {
            if (! array_key_exists($key, $required)
                || ! array_key_exists($key, $source)
                || $required[$key] !== $source[$key]) {
                return false;
            }
        }

        return true;
    }

    /** @param array<string, mixed> $payload @return array<string, mixed> */
    private function submitAndRead(array $payload, string $operation): array
    {
        $record = $this->buildRecord($payload);
        $validation = (new InMemoryLogicalPersistenceRepositoryContract())->store($record);

        if (($validation['storage_outcome'] ?? null) !== InMemoryLogicalPersistenceRepositoryContract::STORED_NEW) {
            throw new InvalidArgumentException('INVALID_PRODUCT_CONNECTION_PERSISTENCE_RECORD');
        }

        $submission = $this->application->submitAuthoritativeMutation($record);
        $storage = $submission['persistence']['storage_outcome'] ?? null;
        $retrievable = in_array($storage, [
            InMemoryLogicalPersistenceRepositoryContract::STORED_NEW,
            InMemoryLogicalPersistenceRepositoryContract::EXACT_DUPLICATE,
            InMemoryLogicalPersistenceRepositoryContract::INCOMPARABLE_COEXISTS,
        ], true);
        $retrieval = null;

        if ($retrievable) {
            $retrieval = $this->application->retrieveCurrentProjection([
                'record_family' => InMemoryLogicalPersistenceRepositoryContract::RECORD_FAMILY_PRODUCT_CONNECTION,
                'authority_owner' => 'PRODUCT_CONNECTION_DERIVATION',
                'authority_scope' => $record['bindings']['authority_scope'],
                'aggregate_context' => $payload['connection_identity'],
                'lineage' => $record['source_revision']['lineage'],
            ], [
                'viewer' => 'PRODUCT_CONNECTION_DERIVATION',
                'subject' => $payload['connection_identity'],
                'participants' => $payload['participant_references'],
                'audience' => 'INTERNAL_APPLICATION_PERSISTENCE',
                'purpose' => $payload['protected_use_scope'],
                'aggregate_context' => $payload['connection_identity'],
            ]);
        }

        $exact = $retrieval !== null && $this->exactReadback($retrieval, $record, $payload);
        $dependencyInvalidated = $payload['invalidation']['invalidated'];
        $domainUsable = $payload['payload_kind'] === 'PRODUCT_CONNECTION_CURRENT_STATE'
            ? $payload['classification'] !== 'UNKNOWN' && $payload['valid_for_protected_use']
            : $payload['classification'] === 'ADMISSIBLE' && $payload['valid_for_protected_use'];
        $usable = $exact && ! $dependencyInvalidated && $domainUsable;
        $factLabel = $payload['payload_kind'] === 'PRODUCT_CONNECTION_CURRENT_STATE'
            ? 'PRODUCT_CONNECTION_CURRENT_STATE'
            : 'PRODUCT_CONNECTION_TRANSITION';
        $condition = match (true) {
            ! $retrievable => 'STORAGE_REJECTED_RETRIEVAL_SKIPPED',
            $exact && $dependencyInvalidated => $factLabel.'_DEPENDENCY_INVALIDATED_PROJECTION_MATERIALIZED_UNUSABLE',
            $exact && $usable => 'EXACT_'.$factLabel.'_PROJECTION_MATERIALIZED_USABLE',
            $exact => 'EXACT_'.$factLabel.'_PROJECTION_MATERIALIZED_DOMAIN_UNUSABLE',
            default => $factLabel.'_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED',
        };
        $result = [
            'record_kind' => 'PRODUCT_CONNECTION_PERSISTENCE_APPLICATION_ADAPTER_RESULT',
            'operation' => $operation,
            'fact_class' => $payload['derived_fact_class'],
            'classification' => $payload['classification'],
            'reason_categories' => $payload['reason_categories'],
            'product_connection_payload' => $payload,
            'logical_record_identity' => $record['logical_record_identity'],
            'logical_intent_identity' => $record['logical_intent']['intent_identity'],
            'lifecycle_identity' => $record['bindings']['lifecycle_identity'],
            'source_projection_lineage' => $record['source_revision']['lineage'],
            'derived_correlation_revision' => 0,
            'storage_disposition' => $storage,
            'projection_read_disposition' => $retrieval['resolution'] ?? null,
            'binding_classification' => $retrieval['binding_classification'] ?? null,
            'materialized_projection_usable' => $usable,
            'authoritative_outcome' => CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN,
            'reconciliation_required' => true,
            'invalidation_required' => $dependencyInvalidated,
            'revalidation_required' => ! $usable,
            'condition' => $condition,
            'synthetic_dev_test_only' => true,
            'source_local_revision_only' => true,
            'global_revision' => false,
            'last_write_wins' => false,
            'last_received_wins' => false,
            'transport_disposition' => null,
            'http_status' => null,
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
            'connection_created' => false,
            'connection_activated' => false,
            'match_substituted_for_connection' => false,
            'messaging_consent_granted' => false,
            'conversation_granted' => false,
            'source_evidence_mutated' => false,
        ];

        foreach (self::FALSE_RESULT_FIELDS as $field) {
            if ($result[$field] !== false) {
                throw new InvalidArgumentException('PRODUCT_CONNECTION_NON_AUTHORITY_RESULT_VIOLATION');
            }
        }

        return $result;
    }

    /** @param array<string, mixed> $payload @return array<string, mixed> */
    private function buildRecord(array $payload): array
    {
        $scope = $payload['derived_fact_class'].'|'.$payload['protected_use_scope'];
        $lifecycleBasis = [
            'record_family' => InMemoryLogicalPersistenceRepositoryContract::RECORD_FAMILY_PRODUCT_CONNECTION,
            'authority_owner' => 'PRODUCT_CONNECTION_DERIVATION',
            'actor' => 'PRODUCT_CONNECTION_DERIVATION',
            'actor_role' => 'DERIVED_NON_AUTHORITATIVE_CORRELATION',
            'connection_identity' => $payload['connection_identity'],
            'protected_use_scope' => $payload['protected_use_scope'],
            'subject' => $payload['connection_identity'],
            'participants' => $payload['participant_references'],
            'audience' => 'INTERNAL_APPLICATION_PERSISTENCE',
            'purpose' => $payload['protected_use_scope'],
            'aggregate_context' => $payload['connection_identity'],
        ];
        $bindings = [
            'authority_owner' => 'PRODUCT_CONNECTION_DERIVATION',
            'authority_scope' => $scope,
            'actor' => 'PRODUCT_CONNECTION_DERIVATION',
            'actor_role' => 'DERIVED_NON_AUTHORITATIVE_CORRELATION',
            'subject' => $payload['connection_identity'],
            'participants' => $payload['participant_references'],
            'audience' => 'INTERNAL_APPLICATION_PERSISTENCE',
            'purpose' => $payload['protected_use_scope'],
            'aggregate_context' => $payload['connection_identity'],
            'lifecycle_identity' => 'product-connection-lifecycle-v1:'.$this->digest($lifecycleBasis),
            'terminal' => $payload['terminality']['current_state_terminal'],
        ];
        $semantic = [
            'record_family' => InMemoryLogicalPersistenceRepositoryContract::RECORD_FAMILY_PRODUCT_CONNECTION,
            'derived_fact_class' => $payload['derived_fact_class'],
            'bindings' => $bindings,
            'derived_projection_payload' => $payload,
            'schema_marker' => $payload['payload_kind'] === 'PRODUCT_CONNECTION_CURRENT_STATE'
                ? 'product-connection-current-state-derived-projection-v1'
                : 'product-connection-transition-derived-projection-v1',
        ];
        $digest = $this->digest($semantic);
        [$currentness, $freshness] = $this->aggregatePayloadDependencies($payload);

        return [
            'logical_record_identity' => 'product-connection-record-v1:'.$digest,
            'record_family' => InMemoryLogicalPersistenceRepositoryContract::RECORD_FAMILY_PRODUCT_CONNECTION,
            'bindings' => $bindings,
            'source_revision' => [
                'authority_owner' => 'PRODUCT_CONNECTION_DERIVATION',
                'authority_scope' => $scope,
                'lineage' => 'product-connection-lineage-v1:'.$digest,
                'aggregate_context' => $payload['connection_identity'],
                'value' => 0,
            ],
            'source_condition' => CommonAuthorityEvidenceContract::CONDITION_PRESENT,
            'currentness' => $currentness,
            'freshness' => $freshness,
            'logical_intent' => [
                'intent_identity' => 'product-connection-intent-v1:'.$digest,
                'semantic_input' => $semantic,
            ],
            'authoritative_outcome' => CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN,
            'authoritative_outcome_metadata' => null,
            'correction_metadata' => null,
            'projection_metadata' => [
                'projection_identity' => 'product-connection-projection-v1:'.$digest,
                'represented_source_revision_value' => 0,
                'lag_classification' => match ($currentness) { true => 'CURRENT', false => 'LAGGED', null => 'UNKNOWN' },
                'projection_currentness' => $currentness,
            ],
            'transport_observation' => 'AMBIGUOUS',
            'private_fixture_extensions' => [],
            'derived_projection_payload' => $payload,
        ];
    }

    /** @param array<string, mixed> $payload @return array{?bool, ?bool} */
    private function aggregatePayloadDependencies(array $payload): array
    {
        $current = $payload['current_state_dependency'];
        $transition = $payload['transition_dependency'] ?? null;

        if ($current === null) {
            return [null, null];
        }

        if ($payload['payload_kind'] === 'PRODUCT_CONNECTION_CURRENT_STATE') {
            return [$current['currentness'], $current['freshness']];
        }

        if ($transition === null) {
            return [
                $current['currentness'] === false ? false : null,
                $current['freshness'] === false ? false : null,
            ];
        }

        return [
            $this->aggregatePair($current['currentness'], $transition['currentness']),
            $this->aggregatePair($current['freshness'], $transition['freshness']),
        ];
    }

    private function aggregatePair(?bool $left, ?bool $right): ?bool
    {
        if ($left === false || $right === false) {
            return false;
        }

        return $left === true && $right === true ? true : null;
    }

    /** @param array<string, mixed> $retrieval @param array<string, mixed> $record @param array<string, mixed> $payload */
    private function exactReadback(array $retrieval, array $record, array $payload): bool
    {
        $projection = $retrieval['projection'] ?? null;

        return ($retrieval['resolution'] ?? null) === InMemoryLogicalPersistenceRepositoryContract::RESOLVED
            && ($retrieval['binding_classification'] ?? null) === 'EXACT'
            && is_array($projection)
            && ($projection['record_family'] ?? null) === InMemoryLogicalPersistenceRepositoryContract::RECORD_FAMILY_PRODUCT_CONNECTION
            && ($projection['authority_owner'] ?? null) === 'PRODUCT_CONNECTION_DERIVATION'
            && ($projection['authority_scope'] ?? null) === $record['bindings']['authority_scope']
            && ($projection['projection_invalidated'] ?? true) === false
            && ($projection['logical_record_identity'] ?? null) === $record['logical_record_identity']
            && ($projection['logical_intent_identity'] ?? null) === $record['logical_intent']['intent_identity']
            && ($projection['lifecycle_identity'] ?? null) === $record['bindings']['lifecycle_identity']
            && ($projection['source_revision_lineage'] ?? null) === $record['source_revision']['lineage']
            && ($projection['projection_identity'] ?? null) === $record['projection_metadata']['projection_identity']
            && ($projection['represented_source_revision_value'] ?? null) === 0
            && ($projection['subject_reference'] ?? null) === $record['bindings']['subject']
            && ($projection['participant_references'] ?? null) === $record['bindings']['participants']
            && ($projection['audience'] ?? null) === $record['bindings']['audience']
            && ($projection['purpose'] ?? null) === $record['bindings']['purpose']
            && ($projection['aggregate_context'] ?? null) === $record['bindings']['aggregate_context']
            && ($projection['terminal'] ?? null) === $record['bindings']['terminal']
            && ($projection['currentness'] ?? null) === $record['currentness']
            && ($projection['freshness'] ?? null) === $record['freshness']
            && ($projection['projection_currentness'] ?? null) === $record['projection_metadata']['projection_currentness']
            && ($projection['projection_lag'] ?? null) === $record['projection_metadata']['lag_classification']
            && ($projection['derived_projection_payload'] ?? null) === $payload;
    }

    /** @param array<string, mixed> $bindings */
    private function validBindings(array $bindings): bool
    {
        if (! $this->hasExactKeys($bindings, self::BINDING_KEYS)
            || ! is_array($bindings['participants'] ?? null)
            || ! array_is_list($bindings['participants'])
            || $bindings['participants'] === []
            || ! $this->allNonEmptyStrings($bindings['participants'])
            || ! is_bool($bindings['terminal'] ?? null)) {
            return false;
        }

        foreach (array_diff(self::BINDING_KEYS, ['participants', 'terminal']) as $key) {
            if (! $this->nonEmptyString($bindings[$key] ?? null)) {
                return false;
            }
        }

        return true;
    }

    /** @param array<string, mixed> $revision */
    private function validRevision(array $revision): bool
    {
        if (! $this->hasExactKeys($revision, self::REVISION_KEYS)
            || ! is_int($revision['value'] ?? null)
            || $revision['value'] < 0) {
            return false;
        }

        foreach (array_diff(self::REVISION_KEYS, ['value']) as $key) {
            if (! $this->nonEmptyString($revision[$key] ?? null)) {
                return false;
            }
        }

        return true;
    }

    private function validParticipantPair(mixed $participants): bool
    {
        return is_array($participants)
            && array_is_list($participants)
            && count($participants) === 2
            && count(array_unique($participants)) === 2
            && $this->allNonEmptyStrings($participants);
    }

    /** @param list<mixed> $left @param list<mixed> $right */
    private function sameParticipants(array $left, array $right): bool
    {
        sort($left, SORT_STRING);
        sort($right, SORT_STRING);

        return $left === $right;
    }

    private function terminal(mixed $state): bool
    {
        return is_string($state) && in_array($state, ['CN_CLOSED', 'CN_DECLINED', 'CN_WITHDRAWN', 'CN_EXPIRED'], true);
    }

    /** @param array<string, mixed> $value @param list<string> $expected */
    private function hasExactKeys(array $value, array $expected): bool
    {
        $keys = array_keys($value);
        sort($keys);
        sort($expected);

        return $keys === $expected;
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

    private function nullableBoolean(mixed $value): bool
    {
        return is_bool($value) || $value === null;
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
