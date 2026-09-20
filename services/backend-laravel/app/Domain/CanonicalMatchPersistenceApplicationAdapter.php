<?php

namespace App\Domain;

use InvalidArgumentException;

final class CanonicalMatchPersistenceApplicationAdapter
{
    public const SYNTHETIC_FIXTURE_MARKER = 'ELITESYNC_CANONICAL_MATCH_SYNTHETIC_DEV_TEST_V1';

    private const ORDINARY_REQUEST_KEYS = [
        'synthetic_fixture',
        'proposal',
        'participation_evidence',
        'decision_slot_evidence',
    ];

    private const INVALIDATION_REQUEST_KEYS = [
        'synthetic_fixture',
        'proposal',
        'participation_evidence',
        'decision_slot_evidence',
        'invalidation_request',
    ];

    private const PROPOSAL_KEYS = [
        'proposal_identity',
        'participants',
        'protected_use_scope',
        'lifecycle_state',
        'at_most_one_unresolved_precondition',
        'required_bindings',
        'source_evidence',
    ];

    private const PARTICIPATION_KEYS = [
        'participant_identity',
        'state',
        'required_bindings',
        'source_evidence',
    ];

    private const SLOT_KEYS = [
        'slot_identity',
        'proposal_identity',
        'participant_identity',
        'protected_use_scope',
        'decision',
        'required_bindings',
        'source_evidence',
    ];

    private const EVIDENCE_KEYS = [
        'record_kind',
        'bindings',
        'source_condition',
        'source_revision',
        'currentness',
        'freshness',
        'authoritative_outcome',
    ];

    private const DERIVED_KEYS = [
        'record_kind',
        'classification',
        'proposal_identity',
        'participants',
        'dependency_vector',
        'reasons',
        'valid_for_protected_use',
        'source_authority',
        'permission',
        'bearer_capability',
        'product_connection_created',
        'messaging_consent_authority',
        'conversation_authority',
        'relationship_authority',
        'home_authority',
        'notification_authority',
        'launch_eligibility',
        'ranking_computed',
        'compatibility_total_computed',
        'person_worth_inferred',
        'source_evidence_mutated',
        'lifecycle_reset',
        'proposal_reopened',
    ];

    private const DERIVED_FALSE_FIELDS = [
        'source_authority',
        'permission',
        'bearer_capability',
        'product_connection_created',
        'messaging_consent_authority',
        'conversation_authority',
        'relationship_authority',
        'home_authority',
        'notification_authority',
        'launch_eligibility',
        'ranking_computed',
        'compatibility_total_computed',
        'person_worth_inferred',
        'source_evidence_mutated',
        'lifecycle_reset',
        'proposal_reopened',
    ];

    private const CLASSIFICATIONS = [
        'PENDING',
        'MUTUALLY_ACCEPTED',
        'DECLINED',
        'WITHDRAWN',
        'EXPIRED',
        'UNKNOWN',
    ];

    private const TERMINAL_CLASSIFICATIONS = [
        'MUTUALLY_ACCEPTED',
        'DECLINED',
        'WITHDRAWN',
        'EXPIRED',
    ];

    private const REASON_CATEGORIES = [
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

    private const PRE_MATERIALIZATION_REASONS = [
        'EXACTLY_TWO_PARTICIPANTS_REQUIRED',
        'INVALID_PROPOSAL_SHAPE',
        'INVALID_SLOT_EVIDENCE',
        'INVALID_SLOT_DECISION',
    ];

    public function __construct(
        private readonly PersistenceBoundaryApplicationInterfaceIntegrationContract $application,
    ) {}

    /** @param array<string, mixed> $request @return array<string, mixed> */
    public function evaluateSynthetic(array $request): array
    {
        $this->assertSyntheticRequest($request, false);
        $derived = CanonicalMatchProposalDecisionEvaluator::evaluate(
            $request['proposal'],
            $request['participation_evidence'],
            $request['decision_slot_evidence'],
        );
        $this->assertDerivedResult($derived, $request['proposal'], false);
        $payload = $this->buildPayload($derived, $request, null);

        return $this->submitAndRead('EVALUATE', $payload, $request['proposal']);
    }

    /** @param array<string, mixed> $request @return array<string, mixed> */
    public function invalidateSynthetic(array $request): array
    {
        $this->assertSyntheticRequest($request, true);
        $before = CanonicalMatchProposalDecisionEvaluator::evaluate(
            $request['proposal'],
            $request['participation_evidence'],
            $request['decision_slot_evidence'],
        );
        $this->assertDerivedResult($before, $request['proposal'], false);
        $ordinaryPayload = $this->buildPayload($before, $request, null);
        $target = $request['invalidation_request']['dependency_identity'];
        $identities = $this->persistedDependencyIdentities($ordinaryPayload);

        if (count(array_filter(
            $identities,
            static fn (string $identity): bool => $identity === $target,
        )) !== 1) {
            throw new InvalidArgumentException('Invalidation target must bind exactly one persisted dependency.');
        }

        $invalidated = CanonicalMatchProposalDecisionEvaluator::invalidate(
            $before,
            $target,
            $request['invalidation_request']['relation'],
        );
        $this->assertInvalidatedResult($invalidated, $before, $request['invalidation_request']);
        $payload = $this->buildPayload($invalidated, $request, $before['classification']);

        return $this->submitAndRead('INVALIDATE', $payload, $request['proposal']);
    }

    /** @param array<string, mixed> $request */
    private function assertSyntheticRequest(array $request, bool $invalidation): void
    {
        $expectedKeys = $invalidation ? self::INVALIDATION_REQUEST_KEYS : self::ORDINARY_REQUEST_KEYS;

        if (! $this->hasExactKeys($request, $expectedKeys)
            || ($request['synthetic_fixture'] ?? null) !== self::SYNTHETIC_FIXTURE_MARKER
            || ! is_array($request['proposal'] ?? null)
            || ! is_array($request['participation_evidence'] ?? null)
            || ! array_is_list($request['participation_evidence'])
            || ! is_array($request['decision_slot_evidence'] ?? null)
            || ! array_is_list($request['decision_slot_evidence'])) {
            throw new InvalidArgumentException('Malformed or non-synthetic Canonical Match request rejected.');
        }

        $proposal = $request['proposal'];
        $participants = $proposal['participants'] ?? null;

        if (! $this->hasExactKeys($proposal, self::PROPOSAL_KEYS)
            || ! $this->nonEmptyString($proposal['proposal_identity'] ?? null)
            || ! is_array($participants)
            || ! array_is_list($participants)
            || count($participants) !== 2
            || count(array_unique($participants)) !== 2
            || ! $this->allNonEmptyStrings($participants)
            || ! $this->nonEmptyString($proposal['protected_use_scope'] ?? null)
            || ! in_array($proposal['lifecycle_state'] ?? null, CanonicalMatchProposalDecisionEvaluator::proposalLifecycleVocabulary(), true)
            || ! is_bool($proposal['at_most_one_unresolved_precondition'] ?? null)
            || ! is_array($proposal['required_bindings'] ?? null)
            || ! is_array($proposal['source_evidence'] ?? null)) {
            throw new InvalidArgumentException('Malformed Canonical Match proposal rejected.');
        }

        $this->assertEvidenceContainer($proposal['required_bindings'], $proposal['source_evidence']);

        foreach ($request['participation_evidence'] as $participation) {
            if (! is_array($participation)
                || ! $this->hasExactKeys($participation, self::PARTICIPATION_KEYS)
                || ! $this->nonEmptyString($participation['participant_identity'] ?? null)
                || ! in_array($participation['state'] ?? null, CanonicalMatchProposalDecisionEvaluator::participationVocabulary(), true)
                || ! is_array($participation['required_bindings'] ?? null)
                || ! is_array($participation['source_evidence'] ?? null)) {
                throw new InvalidArgumentException('Malformed Canonical Match participation evidence rejected.');
            }

            $this->assertEvidenceContainer($participation['required_bindings'], $participation['source_evidence']);
        }

        foreach ($request['decision_slot_evidence'] as $slot) {
            if (! is_array($slot)
                || ! $this->hasExactKeys($slot, self::SLOT_KEYS)
                || ! $this->nonEmptyString($slot['slot_identity'] ?? null)
                || ! $this->nonEmptyString($slot['proposal_identity'] ?? null)
                || ! $this->nonEmptyString($slot['participant_identity'] ?? null)
                || ! $this->nonEmptyString($slot['protected_use_scope'] ?? null)
                || ! in_array($slot['decision'] ?? null, [
                    CanonicalMatchProposalDecisionEvaluator::SLOT_PENDING,
                    CanonicalMatchProposalDecisionEvaluator::SLOT_ACCEPTED,
                    CanonicalMatchProposalDecisionEvaluator::SLOT_DECLINED,
                    CanonicalMatchProposalDecisionEvaluator::SLOT_WITHDRAWN,
                ], true)
                || ! is_array($slot['required_bindings'] ?? null)
                || ! is_array($slot['source_evidence'] ?? null)) {
                throw new InvalidArgumentException('Malformed Canonical Match decision-slot evidence rejected.');
            }

            $this->assertEvidenceContainer($slot['required_bindings'], $slot['source_evidence']);
        }

        if ($invalidation) {
            $invalidationRequest = $request['invalidation_request'] ?? null;

            if (! is_array($invalidationRequest)
                || ! $this->hasExactKeys($invalidationRequest, ['dependency_identity', 'relation'])
                || ! $this->nonEmptyString($invalidationRequest['dependency_identity'] ?? null)
                || ! in_array($invalidationRequest['relation'] ?? null, [
                    CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
                    CommonAuthorityEvidenceContract::INVALIDATION_REVOCATION,
                    CommonAuthorityEvidenceContract::INVALIDATION_SUPERSESSION,
                ], true)) {
                throw new InvalidArgumentException('Malformed Canonical Match invalidation request rejected.');
            }
        }
    }

    /** @param array<string, mixed> $requiredBindings @param array<string, mixed> $sourceEvidence */
    private function assertEvidenceContainer(array $requiredBindings, array $sourceEvidence): void
    {
        if (! $this->hasExactKeys($sourceEvidence, self::EVIDENCE_KEYS)
            || ($sourceEvidence['record_kind'] ?? null) !== 'SOURCE_EVIDENCE'
            || ! is_array($sourceEvidence['bindings'] ?? null)
            || ! is_string($sourceEvidence['source_condition'] ?? null)
            || ! is_array($sourceEvidence['source_revision'] ?? null)
            || ! $this->nullableBoolean($sourceEvidence['currentness'] ?? null)
            || ! $this->nullableBoolean($sourceEvidence['freshness'] ?? null)
            || ! is_string($sourceEvidence['authoritative_outcome'] ?? null)) {
            throw new InvalidArgumentException('Malformed Canonical Match source evidence rejected.');
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

    /** @param array<string, mixed> $derived @param array<string, mixed> $proposal */
    private function assertDerivedResult(array $derived, array $proposal, bool $invalidated): void
    {
        $expectedKeys = $invalidated ? [...self::DERIVED_KEYS, 'invalidation'] : self::DERIVED_KEYS;

        if (! $this->hasExactKeys($derived, $expectedKeys)
            || ($derived['record_kind'] ?? null) !== 'CANONICAL_MATCH_PROPOSAL_DECISION_DERIVATION'
            || ! in_array($derived['classification'] ?? null, self::CLASSIFICATIONS, true)
            || ($derived['proposal_identity'] ?? null) !== $proposal['proposal_identity']
            || ($derived['participants'] ?? null) !== $proposal['participants']
            || ! is_array($derived['dependency_vector'] ?? null)
            || ! $this->hasExactKeys($derived['dependency_vector'], ['proposal', 'participation', 'decision_slots'])
            || ! is_array($derived['dependency_vector']['proposal'] ?? null)
            || ! is_array($derived['dependency_vector']['participation'] ?? null)
            || ! array_is_list($derived['dependency_vector']['participation'])
            || ! is_array($derived['dependency_vector']['decision_slots'] ?? null)
            || ! array_is_list($derived['dependency_vector']['decision_slots'])
            || ! is_array($derived['reasons'] ?? null)
            || ! array_is_list($derived['reasons'])
            || ! $this->allNonEmptyStrings($derived['reasons'])) {
            throw new InvalidArgumentException('Malformed Canonical Match evaluator result rejected.');
        }

        foreach (self::DERIVED_FALSE_FIELDS as $field) {
            if (($derived[$field] ?? null) !== false) {
                throw new InvalidArgumentException('Evaluator non-authority boundary rejected.');
            }
        }

        if (($derived['valid_for_protected_use'] ?? null) !== ($derived['classification'] !== 'UNKNOWN')) {
            throw new InvalidArgumentException('Evaluator protected-use classification is inconsistent.');
        }

        $this->boundedReasons($derived['reasons']);
    }

    /**
     * @param array<string, mixed> $invalidated
     * @param array<string, mixed> $before
     * @param array<string, mixed> $request
     */
    private function assertInvalidatedResult(array $invalidated, array $before, array $request): void
    {
        $this->assertDerivedResult($invalidated, [
            'proposal_identity' => $before['proposal_identity'],
            'participants' => $before['participants'],
        ], true);

        if ($invalidated['classification'] !== 'UNKNOWN'
            || $invalidated['valid_for_protected_use'] !== false
            || $invalidated['dependency_vector'] !== $before['dependency_vector']
            || $invalidated['reasons'] !== ['DEPENDENCY_INVALIDATED']
            || ($invalidated['invalidation'] ?? null) !== $request
            || $invalidated['lifecycle_reset'] !== false
            || $invalidated['proposal_reopened'] !== false) {
            throw new InvalidArgumentException('Evaluator invalidation result is not exactly bound.');
        }
    }

    /**
     * @param array<string, mixed> $derived
     * @param array<string, mixed> $request
     * @return array<string, mixed>
     */
    private function buildPayload(array $derived, array $request, ?string $classificationBeforeInvalidation): array
    {
        $proposal = $request['proposal'];
        $proposalDependency = $this->proposalDependency($derived['dependency_vector']['proposal'], $proposal);
        $participationDependencies = [];

        foreach ($derived['dependency_vector']['participation'] as $selected) {
            $participationDependencies[] = $this->participationDependency(
                $selected,
                $request['participation_evidence'],
            );
        }

        usort($participationDependencies, self::compareParticipationDependencies(...));
        $slotDependencies = [];

        foreach ($derived['dependency_vector']['decision_slots'] as $selected) {
            $slotDependencies[] = $this->slotDependency($selected, $request['decision_slot_evidence']);
        }

        usort($slotDependencies, self::compareSlotDependencies(...));
        $participants = $proposal['participants'];
        sort($participants, SORT_STRING);
        $slotIdentities = array_column($slotDependencies, 'slot_identity');
        $collisionIdentities = [$proposal['proposal_identity'], ...$participants, ...$slotIdentities];

        if (count($collisionIdentities) !== count(array_unique($collisionIdentities))) {
            throw new InvalidArgumentException('Canonical Match dependency identity collision rejected.');
        }

        $slotParticipants = array_column($slotDependencies, 'participant_identity');

        if (count($slotIdentities) !== count(array_unique($slotIdentities))
            || count($slotParticipants) !== count(array_unique($slotParticipants))) {
            throw new InvalidArgumentException('Canonical Match selected-slot collision rejected.');
        }

        $sourceTerminal = $proposalDependency['terminal'];

        if ($sourceTerminal && ($participationDependencies !== [] || $slotDependencies !== [])) {
            throw new InvalidArgumentException('Terminal proposal dependency vector rejected.');
        }

        $invalidated = $classificationBeforeInvalidation !== null;
        $terminalClassification = $invalidated ? $classificationBeforeInvalidation : $derived['classification'];
        $derivedTerminal = in_array($terminalClassification, self::TERMINAL_CLASSIFICATIONS, true);
        $invalidation = $invalidated ? [
            'invalidated' => true,
            'relation' => $derived['invalidation']['relation'],
            'dependency_identity' => $derived['invalidation']['dependency_identity'],
            'lifecycle_reset' => false,
            'proposal_reopened' => false,
        ] : [
            'invalidated' => false,
            'relation' => null,
            'dependency_identity' => null,
            'lifecycle_reset' => false,
            'proposal_reopened' => false,
        ];

        return [
            'payload_kind' => 'CANONICAL_MATCH_PROPOSAL_DECISION',
            'derived_fact_class' => 'CANONICAL_MATCH_PROPOSAL_DECISION',
            'classification' => $derived['classification'],
            'proposal_identity' => $proposal['proposal_identity'],
            'protected_use_scope' => $proposal['protected_use_scope'],
            'reason_categories' => $this->boundedReasons($derived['reasons']),
            'proposal_dependency' => $proposalDependency,
            'participation_dependencies' => $participationDependencies,
            'decision_slot_dependencies' => $slotDependencies,
            'terminality' => [
                'source_proposal_terminal' => $sourceTerminal,
                'derived_terminal' => $derivedTerminal,
                'classification_before_invalidation' => $classificationBeforeInvalidation,
                'lifecycle_reset' => false,
                'proposal_reopened' => false,
            ],
            'invalidation' => $invalidation,
        ];
    }

    /** @param array<string, mixed> $selected @param array<string, mixed> $proposal @return array<string, mixed> */
    private function proposalDependency(array $selected, array $proposal): array
    {
        $evidence = $proposal['source_evidence'];
        $revision = $evidence['source_revision'];

        if (! $this->hasExactKeys($selected, ['proposal_identity', 'lifecycle_state', 'source_revision', 'source_condition'])
            || $selected['proposal_identity'] !== $proposal['proposal_identity']
            || $selected['lifecycle_state'] !== $proposal['lifecycle_state']
            || $selected['source_revision'] !== $revision
            || $selected['source_condition'] !== $evidence['source_condition']) {
            throw new InvalidArgumentException('Evaluator proposal dependency is not exactly bound.');
        }

        return [
            'proposal_identity' => $proposal['proposal_identity'],
            'lifecycle_state' => $proposal['lifecycle_state'],
            'terminal' => $proposal['lifecycle_state'] !== CanonicalMatchProposalDecisionEvaluator::PROPOSAL_PENDING,
            ...$this->sourceFields($revision, $evidence),
        ];
    }

    /** @param array<string, mixed> $selected @param list<array<string, mixed>> $supplied @return array<string, mixed> */
    private function participationDependency(array $selected, array $supplied): array
    {
        if (! $this->hasExactKeys($selected, ['participant_identity', 'state', 'source_revision', 'source_condition'])) {
            throw new InvalidArgumentException('Malformed evaluator participation dependency rejected.');
        }

        $matches = array_values(array_filter(
            $supplied,
            static fn (array $item): bool => $item['participant_identity'] === $selected['participant_identity']
                && $item['state'] === $selected['state']
                && $item['source_evidence']['source_revision'] === $selected['source_revision']
                && $item['source_evidence']['source_condition'] === $selected['source_condition'],
        ));

        if (count($matches) !== 1 || ! is_array($selected['source_revision'])) {
            throw new InvalidArgumentException('Evaluator participation dependency is not exactly bound.');
        }

        $evidence = $matches[0]['source_evidence'];

        return [
            'participant_identity' => $selected['participant_identity'],
            'state' => $selected['state'],
            ...$this->sourceFields($selected['source_revision'], $evidence),
        ];
    }

    /** @param array<string, mixed> $selected @param list<array<string, mixed>> $supplied @return array<string, mixed> */
    private function slotDependency(array $selected, array $supplied): array
    {
        if (! $this->hasExactKeys($selected, [
            'slot_identity',
            'proposal_identity',
            'participant_identity',
            'decision',
            'source_revision',
            'source_condition',
        ])) {
            throw new InvalidArgumentException('Malformed evaluator selected-slot dependency rejected.');
        }

        $matches = array_values(array_filter(
            $supplied,
            static fn (array $item): bool => $item['slot_identity'] === $selected['slot_identity']
                && $item['proposal_identity'] === $selected['proposal_identity']
                && $item['participant_identity'] === $selected['participant_identity']
                && $item['decision'] === $selected['decision']
                && $item['source_evidence']['source_revision'] === $selected['source_revision']
                && $item['source_evidence']['source_condition'] === $selected['source_condition'],
        ));

        if (count($matches) !== 1 || ! is_array($selected['source_revision'])) {
            throw new InvalidArgumentException('Evaluator selected-slot dependency is not exactly bound.');
        }

        $evidence = $matches[0]['source_evidence'];

        return [
            'slot_identity' => $selected['slot_identity'],
            'proposal_identity' => $selected['proposal_identity'],
            'participant_identity' => $selected['participant_identity'],
            'decision' => $selected['decision'],
            ...$this->sourceFields($selected['source_revision'], $evidence),
        ];
    }

    /** @param array<string, mixed> $revision @param array<string, mixed> $evidence @return array<string, mixed> */
    private function sourceFields(array $revision, array $evidence): array
    {
        return [
            'authority_owner' => $revision['authority_owner'],
            'authority_scope' => $revision['authority_scope'],
            'aggregate_context' => $revision['aggregate_context'],
            'source_lineage' => $revision['lineage'],
            'source_revision_value' => $revision['value'],
            'source_condition' => $evidence['source_condition'],
            'currentness' => $evidence['currentness'],
            'freshness' => $evidence['freshness'],
        ];
    }

    /** @param list<string> $reasons @return list<string> */
    private function boundedReasons(array $reasons): array
    {
        $selected = [];

        foreach ($reasons as $reason) {
            if (! is_string($reason) || $reason === '') {
                throw new InvalidArgumentException('Malformed evaluator reason rejected.');
            }

            $category = explode(':', $reason, 2)[0];

            if (in_array($category, self::PRE_MATERIALIZATION_REASONS, true)
                || ! in_array($category, self::REASON_CATEGORIES, true)) {
                throw new InvalidArgumentException('Non-persistable Canonical Match evaluator reason rejected.');
            }

            $selected[$category] = true;
        }

        return array_values(array_filter(
            self::REASON_CATEGORIES,
            static fn (string $category): bool => isset($selected[$category]),
        ));
    }

    /** @param array<string, mixed> $payload @param array<string, mixed> $proposal @return array<string, mixed> */
    private function buildRecord(array $payload, array $proposal): array
    {
        $sourceBindings = $proposal['required_bindings'];
        $participants = $proposal['participants'];
        sort($participants, SORT_STRING);
        $scope = 'CANONICAL_MATCH_PROPOSAL_DECISION|'.$payload['protected_use_scope'];
        $lifecycleBasis = [
            'record_family' => InMemoryLogicalPersistenceRepositoryContract::RECORD_FAMILY_CANONICAL_MATCH,
            'proposal_identity' => $payload['proposal_identity'],
            'protected_use_scope' => $payload['protected_use_scope'],
            'subject' => $sourceBindings['subject'],
            'participants' => $participants,
            'audience' => $sourceBindings['audience'],
            'purpose' => $payload['protected_use_scope'],
            'aggregate_context' => $payload['proposal_identity'],
        ];
        $bindings = [
            'authority_owner' => 'CANONICAL_MATCH_DERIVATION',
            'authority_scope' => $scope,
            'actor' => $sourceBindings['actor'],
            'actor_role' => $sourceBindings['actor_role'],
            'subject' => $sourceBindings['subject'],
            'participants' => $participants,
            'audience' => $sourceBindings['audience'],
            'purpose' => $payload['protected_use_scope'],
            'aggregate_context' => $payload['proposal_identity'],
            'lifecycle_identity' => 'canonical-match-lifecycle-v1:'.$this->digest($lifecycleBasis),
            'terminal' => $payload['terminality']['derived_terminal'],
        ];
        $semanticInput = [
            'record_family' => InMemoryLogicalPersistenceRepositoryContract::RECORD_FAMILY_CANONICAL_MATCH,
            'bindings' => $bindings,
            'derived_projection_payload' => $payload,
            'schema_marker' => 'canonical-match-derived-projection-v1',
        ];
        $digest = $this->digest($semanticInput);
        $currentness = $this->dependencyAggregate($payload, 'currentness');
        $freshness = $this->dependencyAggregate($payload, 'freshness');

        return [
            'logical_record_identity' => 'canonical-match-record-v1:'.$digest,
            'record_family' => InMemoryLogicalPersistenceRepositoryContract::RECORD_FAMILY_CANONICAL_MATCH,
            'bindings' => $bindings,
            'source_revision' => [
                'authority_owner' => 'CANONICAL_MATCH_DERIVATION',
                'authority_scope' => $scope,
                'lineage' => 'canonical-match-lineage-v1:'.$digest,
                'aggregate_context' => $payload['proposal_identity'],
                'value' => 0,
            ],
            'source_condition' => CommonAuthorityEvidenceContract::CONDITION_PRESENT,
            'currentness' => $currentness,
            'freshness' => $freshness,
            'logical_intent' => [
                'intent_identity' => 'canonical-match-intent-v1:'.$digest,
                'semantic_input' => $semanticInput,
            ],
            'authoritative_outcome' => CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN,
            'authoritative_outcome_metadata' => null,
            'correction_metadata' => null,
            'projection_metadata' => [
                'projection_identity' => 'canonical-match-projection-v1:'.$digest,
                'represented_source_revision_value' => 0,
                'lag_classification' => match ($currentness) {
                    true => 'CURRENT',
                    false => 'LAGGED',
                    null => 'UNKNOWN',
                },
                'projection_currentness' => $currentness,
            ],
            'transport_observation' => 'AMBIGUOUS',
            'private_fixture_extensions' => [],
            'derived_projection_payload' => $payload,
        ];
    }

    /** @param array<string, mixed> $payload */
    private function dependencyAggregate(array $payload, string $field): ?bool
    {
        $proposal = $payload['proposal_dependency'];
        $participation = $payload['participation_dependencies'];
        $slots = $payload['decision_slot_dependencies'];
        $participants = array_column($participation, 'participant_identity');
        $slotParticipants = array_column($slots, 'participant_identity');
        $complete = $proposal['terminal'] || (
            count($participation) === 2
            && count($slots) === 2
            && count(array_unique($participants)) === 2
            && count(array_unique($slotParticipants)) === 2
        );
        $values = [$proposal[$field]];

        foreach ([...$participation, ...$slots] as $dependency) {
            $values[] = $dependency[$field];
        }

        if (in_array(false, $values, true)) {
            return false;
        }

        return ! $complete || in_array(null, $values, true) ? null : true;
    }

    /**
     * @param array<string, mixed> $payload
     * @param array<string, mixed> $proposal
     * @return array<string, mixed>
     */
    private function submitAndRead(string $operation, array $payload, array $proposal): array
    {
        $record = $this->buildRecord($payload, $proposal);
        $submission = $this->application->submitAuthoritativeMutation($record);
        $storageDisposition = $submission['persistence']['storage_outcome'] ?? null;
        $retrievable = in_array($storageDisposition, [
            InMemoryLogicalPersistenceRepositoryContract::STORED_NEW,
            InMemoryLogicalPersistenceRepositoryContract::EXACT_DUPLICATE,
            InMemoryLogicalPersistenceRepositoryContract::INCOMPARABLE_COEXISTS,
        ], true);
        $retrieval = null;

        if ($retrievable) {
            $retrieval = $this->application->retrieveCurrentProjection([
                'record_family' => InMemoryLogicalPersistenceRepositoryContract::RECORD_FAMILY_CANONICAL_MATCH,
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

        $exactReadback = $retrieval !== null && $this->exactReadback($retrieval, $record, $payload);
        $dependencyInvalidated = $payload['invalidation']['invalidated'] === true;
        $usable = $exactReadback && ! $dependencyInvalidated;
        $condition = match (true) {
            ! $retrievable => 'STORAGE_REJECTED_RETRIEVAL_SKIPPED',
            $exactReadback && $dependencyInvalidated => 'CANONICAL_MATCH_DEPENDENCY_INVALIDATED_PROJECTION_MATERIALIZED_UNUSABLE',
            $exactReadback => 'EXACT_PRIVACY_MINIMAL_CANONICAL_MATCH_PROJECTION_MATERIALIZED',
            default => 'CANONICAL_MATCH_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED',
        };

        return [
            'record_kind' => 'CANONICAL_MATCH_PERSISTENCE_APPLICATION_ADAPTER_RESULT',
            'operation' => $operation,
            'match_classification' => $payload['classification'],
            'reason_categories' => $payload['reason_categories'],
            'match_payload' => $payload,
            'logical_record_identity' => $record['logical_record_identity'],
            'logical_intent_identity' => $record['logical_intent']['intent_identity'],
            'lifecycle_identity' => $record['bindings']['lifecycle_identity'],
            'source_projection_lineage' => $record['source_revision']['lineage'],
            'derived_correlation_revision' => $record['source_revision'],
            'storage_disposition' => $storageDisposition,
            'projection_read_disposition' => $retrieval['resolution'] ?? null,
            'binding_classification' => $retrieval['binding_classification'] ?? null,
            'materialized_projection_usable' => $usable,
            'authoritative_outcome' => $submission['authoritative_outcome'] ?? CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN,
            'reconciliation_required' => ($submission['reconciliation_required'] ?? true) === true,
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
            'production_ready' => false,
            'real_data_authorized' => false,
        ];
    }

    /** @param array<string, mixed> $retrieval @param array<string, mixed> $record @param array<string, mixed> $payload */
    private function exactReadback(array $retrieval, array $record, array $payload): bool
    {
        $projection = $retrieval['projection'] ?? null;

        return ($retrieval['resolution'] ?? null) === InMemoryLogicalPersistenceRepositoryContract::RESOLVED
            && ($retrieval['binding_classification'] ?? null) === 'EXACT'
            && is_array($projection)
            && ($projection['record_family'] ?? null) === InMemoryLogicalPersistenceRepositoryContract::RECORD_FAMILY_CANONICAL_MATCH
            && ($projection['projection_invalidated'] ?? true) === false
            && ($projection['logical_record_identity'] ?? null) === $record['logical_record_identity']
            && ($projection['logical_intent_identity'] ?? null) === $record['logical_intent']['intent_identity']
            && ($projection['lifecycle_identity'] ?? null) === $record['bindings']['lifecycle_identity']
            && ($projection['source_revision_lineage'] ?? null) === $record['source_revision']['lineage']
            && ($projection['projection_identity'] ?? null) === $record['projection_metadata']['projection_identity']
            && ($projection['represented_source_revision_value'] ?? null) === 0
            && ($projection['terminal'] ?? null) === $payload['terminality']['derived_terminal']
            && ($projection['derived_projection_payload'] ?? null) === $payload;
    }

    /** @param array<string, mixed> $payload @return list<string> */
    private function persistedDependencyIdentities(array $payload): array
    {
        return [
            $payload['proposal_dependency']['proposal_identity'],
            ...array_column($payload['participation_dependencies'], 'participant_identity'),
            ...array_column($payload['decision_slot_dependencies'], 'slot_identity'),
        ];
    }

    /** @param array<string, mixed> $left @param array<string, mixed> $right */
    private static function compareParticipationDependencies(array $left, array $right): int
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
    private static function compareSlotDependencies(array $left, array $right): int
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

    private function nullableBoolean(mixed $value): bool
    {
        return is_bool($value) || $value === null;
    }

    private function nonEmptyString(mixed $value): bool
    {
        return is_string($value) && $value !== '';
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
