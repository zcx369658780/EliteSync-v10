<?php

namespace Tests\Unit;

use App\Domain\CommonAuthorityEvidenceContract;
use App\Domain\InMemoryLogicalPersistenceRepositoryContract;
use App\Domain\PersistenceBoundaryApplicationInterfaceIntegrationContract;
use App\Domain\SqliteInMemoryLogicalPersistenceAdapter;
use PHPUnit\Framework\TestCase;

final class PersistenceBoundaryApplicationInterfaceIntegrationContractTest extends TestCase
{
    public function testMutationStorageRemainsSeparateFromAuthorityAndDuplicatesAreCorrelationOnly(): void
    {
        $adapter = new SqliteInMemoryLogicalPersistenceAdapter();
        $contract = new PersistenceBoundaryApplicationInterfaceIntegrationContract($adapter);
        $record = $this->record('SYNTHETIC-RECORD-UNKNOWN');

        $first = $contract->submitAuthoritativeMutation($record);
        $duplicate = $contract->submitAuthoritativeMutation($record);

        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::STORED_NEW, $first['persistence']['storage_outcome']);
        self::assertTrue($first['persistence']['stored']);
        self::assertSame(CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN, $first['authoritative_outcome']);
        self::assertTrue($first['reconciliation_required']);
        self::assertSame('ACKNOWLEDGED', $first['transport_observation']);
        self::assertFalse($first['transport_is_domain_outcome']);
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::EXACT_DUPLICATE, $duplicate['persistence']['storage_outcome']);
        self::assertTrue($duplicate['persistence']['idempotent_correlation']);
        self::assertFalse($duplicate['authoritative_mutation_success']);
        self::assertFalse($duplicate['source_authority']);
        self::assertSame(1, $adapter->count());
        $this->assertNonAuthority($first);
        $this->assertNonAuthority($duplicate);
    }

    public function testOnlySourceCarriedCommittedAndRejectedOutcomesArePreserved(): void
    {
        foreach ([
            CommonAuthorityEvidenceContract::OUTCOME_COMMITTED,
            CommonAuthorityEvidenceContract::OUTCOME_REJECTED,
        ] as $outcome) {
            $contract = new PersistenceBoundaryApplicationInterfaceIntegrationContract(
                new SqliteInMemoryLogicalPersistenceAdapter(),
            );
            $result = $contract->submitAuthoritativeMutation(
                $this->record('SYNTHETIC-RECORD-'.$outcome, $outcome, true),
            );

            self::assertSame($outcome, $result['authoritative_outcome']);
            self::assertTrue($result['authoritative_outcome_source_carried']);
            self::assertFalse($result['reconciliation_required']);
            self::assertSame('SOURCE_CARRIED_OUTCOME_PRESERVED', $result['explanation_category']);
            $this->assertNonAuthority($result);
        }
    }

    public function testChangedInputIntentReuseIsRejectedAndAcknowledgementNeverBecomesOutcome(): void
    {
        $adapter = new SqliteInMemoryLogicalPersistenceAdapter();
        $contract = new PersistenceBoundaryApplicationInterfaceIntegrationContract($adapter);
        $record = $this->record('SYNTHETIC-RECORD-IMMUTABLE');
        $contract->submitAuthoritativeMutation($record);
        $record['logical_intent']['semantic_input']['synthetic_action'] = 'SYNTHETIC-CHANGED-ACTION';

        $changed = $contract->submitAuthoritativeMutation($record);

        self::assertSame(
            InMemoryLogicalPersistenceRepositoryContract::CHANGED_INPUT_REUSE_REJECTED,
            $changed['persistence']['storage_outcome'],
        );
        self::assertSame(CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN, $changed['authoritative_outcome']);
        self::assertSame('ACKNOWLEDGED', $changed['transport_observation']);
        self::assertFalse($changed['transport_is_domain_outcome']);
        self::assertSame(1, $adapter->count());
        $this->assertNonAuthority($changed);
    }

    public function testReconciliationIsReadOnlyAndBindsTheSameImmutableIntent(): void
    {
        $adapter = new SqliteInMemoryLogicalPersistenceAdapter();
        $contract = new PersistenceBoundaryApplicationInterfaceIntegrationContract($adapter);
        $record = $this->record(
            'SYNTHETIC-RECORD-RECONCILE',
            CommonAuthorityEvidenceContract::OUTCOME_COMMITTED,
            true,
        );
        $contract->submitAuthoritativeMutation($record);
        $before = $adapter->count();

        $exact = $contract->reconcileAuthoritativeOutcome(
            $record['logical_record_identity'],
            $record['logical_intent'],
        );
        $changedIntent = $record['logical_intent'];
        $changedIntent['semantic_input']['synthetic_action'] = 'SYNTHETIC-DIFFERENT-ACTION';
        $mismatch = $contract->reconcileAuthoritativeOutcome(
            $record['logical_record_identity'],
            $changedIntent,
        );

        self::assertSame($before, $adapter->count());
        self::assertSame('EXACT', $exact['intent_binding']);
        self::assertSame(CommonAuthorityEvidenceContract::OUTCOME_COMMITTED, $exact['authoritative_outcome']);
        self::assertFalse($exact['mutation_replayed']);
        self::assertFalse($exact['mutation_resubmitted']);
        self::assertSame('MISMATCH', $mismatch['intent_binding']);
        self::assertSame(CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN, $mismatch['authoritative_outcome']);
        self::assertFalse($mismatch['mutation_replayed']);
        self::assertFalse($mismatch['mutation_resubmitted']);
        self::assertSame($record['source_revision'], $exact['source_revision']);
        self::assertTrue($exact['currentness']);
        self::assertTrue($exact['freshness']);
        $this->assertNonAuthority($exact);
        $this->assertNonAuthority($mismatch);
    }

    public function testProjectionIsPrivacyMinimalReadOnlyAndPreservesDistinctConditions(): void
    {
        $conditions = [
            CommonAuthorityEvidenceContract::CONDITION_UNKNOWN => InMemoryLogicalPersistenceRepositoryContract::UNKNOWN,
            CommonAuthorityEvidenceContract::CONDITION_ABSENT => InMemoryLogicalPersistenceRepositoryContract::ABSENT,
            CommonAuthorityEvidenceContract::CONDITION_UNAVAILABLE => InMemoryLogicalPersistenceRepositoryContract::UNAVAILABLE,
            CommonAuthorityEvidenceContract::CONDITION_STALE => InMemoryLogicalPersistenceRepositoryContract::STALE,
            CommonAuthorityEvidenceContract::CONDITION_SUPERSEDED => InMemoryLogicalPersistenceRepositoryContract::SUPERSEDED,
            CommonAuthorityEvidenceContract::CONDITION_INCOMPARABLE => InMemoryLogicalPersistenceRepositoryContract::INCOMPARABLE,
        ];

        foreach ($conditions as $condition => $resolution) {
            $adapter = new SqliteInMemoryLogicalPersistenceAdapter();
            $contract = new PersistenceBoundaryApplicationInterfaceIntegrationContract($adapter);
            $record = $this->record('SYNTHETIC-CONDITION-'.$condition, condition: $condition);
            $contract->submitAuthoritativeMutation($record);

            $result = $contract->retrieveCurrentProjection($this->query(), $this->projectionBindings());

            self::assertSame($resolution, $result['resolution']);
            self::assertSame($condition, $result['projection']['source_condition']);
            self::assertFalse($result['permission']);
            self::assertFalse($result['projection']['permission']);
            self::assertArrayNotHasKey('private_fixture_extensions', $result['projection']);
            self::assertNotContains('MUST-NOT-LEAK-SYNTHETIC-PRIVATE', $result['projection'], true);
            self::assertSame(1, $adapter->count());
            $this->assertNonAuthority($result);
        }

        $missing = (new PersistenceBoundaryApplicationInterfaceIntegrationContract(
            new SqliteInMemoryLogicalPersistenceAdapter(),
        ))->retrieveCurrentProjection($this->query(), $this->projectionBindings());
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::MISSING, $missing['resolution']);
        self::assertNull($missing['projection']);

        $notCurrentContract = new PersistenceBoundaryApplicationInterfaceIntegrationContract(
            new SqliteInMemoryLogicalPersistenceAdapter(),
        );
        $notCurrentContract->submitAuthoritativeMutation(
            $this->record('SYNTHETIC-NOT-CURRENT', currentness: false, freshness: true),
        );
        $notCurrent = $notCurrentContract->retrieveCurrentProjection($this->query(), $this->projectionBindings());
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::UNKNOWN, $notCurrent['resolution']);
        self::assertFalse($notCurrent['projection']['currentness']);
        self::assertTrue($notCurrent['projection']['freshness']);

        $notFreshContract = new PersistenceBoundaryApplicationInterfaceIntegrationContract(
            new SqliteInMemoryLogicalPersistenceAdapter(),
        );
        $notFreshContract->submitAuthoritativeMutation(
            $this->record('SYNTHETIC-NOT-FRESH', currentness: true, freshness: false),
        );
        $notFresh = $notFreshContract->retrieveCurrentProjection($this->query(), $this->projectionBindings());
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::STALE, $notFresh['resolution']);
        self::assertTrue($notFresh['projection']['currentness']);
        self::assertFalse($notFresh['projection']['freshness']);
    }

    public function testProtectedActionGrantIsExactDescriptiveNonBearerAndDeterministic(): void
    {
        $contract = new PersistenceBoundaryApplicationInterfaceIntegrationContract(
            new SqliteInMemoryLogicalPersistenceAdapter(),
        );
        $record = $this->record('SYNTHETIC-REVALIDATION-GRANT');
        $contract->submitAuthoritativeMutation($record);
        $evidence = $this->evidence($record);

        $first = $contract->revalidateProtectedAction($this->query(), $record['bindings'], $evidence);
        $second = $contract->revalidateProtectedAction($this->query(), $record['bindings'], $evidence);

        self::assertSame(PersistenceBoundaryApplicationInterfaceIntegrationContract::GRANTED, $first['classification']);
        self::assertSame($first, $second);
        self::assertTrue($first['descriptive_only']);
        self::assertTrue($first['execution_must_revalidate']);
        self::assertFalse($first['bearer_capability']);
        self::assertFalse($first['permission_token']);
        self::assertFalse($first['source_authority']);
        self::assertFalse($first['domain_writer_authority']);
        self::assertFalse($first['transport_execution_authority']);
        self::assertFalse($first['production_ready']);
        $this->assertNonAuthority($first);
    }

    public function testProtectedActionWrongBindingsStaleCurrentnessIncomparableAndInvalidationFailClosed(): void
    {
        $record = $this->record('SYNTHETIC-REVALIDATION-BINDINGS');
        $contract = new PersistenceBoundaryApplicationInterfaceIntegrationContract(
            new SqliteInMemoryLogicalPersistenceAdapter(),
        );
        $contract->submitAuthoritativeMutation($record);
        $evidence = $this->evidence($record);

        foreach ([
            'actor' => 'SYNTHETIC-WRONG-ACTOR',
            'actor_role' => 'SYNTHETIC-WRONG-ROLE',
            'subject' => 'SYNTHETIC-WRONG-SUBJECT',
            'participants' => ['SYNTHETIC-WRONG-PARTICIPANT'],
            'audience' => 'SYNTHETIC-WRONG-AUDIENCE',
            'purpose' => 'SYNTHETIC-WRONG-PURPOSE',
            'aggregate_context' => 'SYNTHETIC-WRONG-CONTEXT',
        ] as $key => $wrongValue) {
            $required = $record['bindings'];
            $required[$key] = $wrongValue;
            $result = $contract->revalidateProtectedAction($this->query(), $required, $evidence);
            self::assertNotSame(PersistenceBoundaryApplicationInterfaceIntegrationContract::GRANTED, $result['classification']);
            $this->assertNonAuthority($result);
        }

        foreach ([
            ['SYNTHETIC-STALE', CommonAuthorityEvidenceContract::CONDITION_PRESENT, true, false],
            ['SYNTHETIC-NOT-CURRENT-GATE', CommonAuthorityEvidenceContract::CONDITION_PRESENT, false, true],
            ['SYNTHETIC-INCOMPARABLE-GATE', CommonAuthorityEvidenceContract::CONDITION_INCOMPARABLE, true, true],
        ] as [$identity, $condition, $currentness, $freshness]) {
            $isolated = new PersistenceBoundaryApplicationInterfaceIntegrationContract(
                new SqliteInMemoryLogicalPersistenceAdapter(),
            );
            $candidate = $this->record($identity, condition: $condition, currentness: $currentness, freshness: $freshness);
            $isolated->submitAuthoritativeMutation($candidate);
            $result = $isolated->revalidateProtectedAction(
                $this->query(),
                $candidate['bindings'],
                $this->evidence($candidate),
            );
            self::assertNotSame(PersistenceBoundaryApplicationInterfaceIntegrationContract::GRANTED, $result['classification']);
        }

        $contract->observeInvalidation(
            $record['logical_record_identity'],
            CommonAuthorityEvidenceContract::INVALIDATION_REVOCATION,
        );
        $invalidated = $contract->revalidateProtectedAction($this->query(), $record['bindings'], $evidence);
        self::assertSame(PersistenceBoundaryApplicationInterfaceIntegrationContract::DENIED, $invalidated['classification']);
        self::assertContains('INVALIDATED', $invalidated['reasons']);
        self::assertFalse($invalidated['bearer_capability']);
    }

    public function testCorrectionRevocationAndSupersessionInvalidateWithoutLifecycleMutation(): void
    {
        foreach ([
            CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
            CommonAuthorityEvidenceContract::INVALIDATION_REVOCATION,
            CommonAuthorityEvidenceContract::INVALIDATION_SUPERSESSION,
        ] as $relation) {
            $adapter = new SqliteInMemoryLogicalPersistenceAdapter();
            $contract = new PersistenceBoundaryApplicationInterfaceIntegrationContract($adapter);
            $record = $this->record('SYNTHETIC-INVALIDATION-'.$relation);
            $contract->submitAuthoritativeMutation($record);
            $before = $adapter->count();

            $result = $contract->observeInvalidation($record['logical_record_identity'], $relation);
            $projection = $contract->retrieveCurrentProjection($this->query(), $this->projectionBindings());

            self::assertSame($relation, $result['relation']);
            self::assertSame(InMemoryLogicalPersistenceRepositoryContract::INVALIDATED, $result['resolution']);
            self::assertTrue($result['dependent_projection_invalidated']);
            self::assertFalse($result['dependent_protected_use_valid']);
            self::assertFalse($result['lifecycle_reset']);
            self::assertFalse($result['reopened']);
            self::assertFalse($result['new_aggregate_created']);
            self::assertFalse($result['transition_synthesized']);
            self::assertFalse($result['global_ordering']);
            self::assertSame(InMemoryLogicalPersistenceRepositoryContract::INVALIDATED, $projection['resolution']);
            self::assertSame($before, $adapter->count());
            $this->assertNonAuthority($result);
        }
    }

    public function testAllFiveFamiliesExplicitlyDenyCrossDomainAndProductionAuthority(): void
    {
        $contract = new PersistenceBoundaryApplicationInterfaceIntegrationContract(
            new SqliteInMemoryLogicalPersistenceAdapter(),
        );
        $record = $this->record('SYNTHETIC-FIVE-FAMILIES');
        $mutation = $contract->submitAuthoritativeMutation($record);
        $results = [
            $mutation,
            $contract->reconcileAuthoritativeOutcome($record['logical_record_identity'], $record['logical_intent']),
            $contract->retrieveCurrentProjection($this->query(), $this->projectionBindings()),
            $contract->revalidateProtectedAction($this->query(), $record['bindings'], $this->evidence($record)),
            $contract->observeInvalidation(
                $record['logical_record_identity'],
                CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
            ),
        ];

        foreach ($results as $result) {
            $this->assertNonAuthority($result);
            foreach ([
                'readiness_authority',
                'match_authority',
                'connection_authority',
                'consent_authority',
                'conversation_authority',
                'relationship_authority',
                'home_action_authority',
                'notification_delivery_authority',
                'launch_authority',
            ] as $field) {
                self::assertFalse($result[$field]);
            }
        }
    }

    /** @return array<string, mixed> */
    private function record(
        string $identity,
        string $outcome = CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN,
        bool $sourceCarried = false,
        string $condition = CommonAuthorityEvidenceContract::CONDITION_PRESENT,
        ?bool $currentness = true,
        ?bool $freshness = true,
    ): array {
        return [
            'logical_record_identity' => $identity,
            'record_family' => 'SYNTHETIC-APPLICATION-BOUNDARY',
            'bindings' => $this->bindings(),
            'source_revision' => CommonAuthorityEvidenceContract::sourceRevision(
                'SYNTHETIC-AUTHORITY',
                'SYNTHETIC-SCOPE',
                'SYNTHETIC-LINEAGE',
                'SYNTHETIC-CONTEXT',
                1,
            ),
            'source_condition' => $condition,
            'currentness' => $currentness,
            'freshness' => $freshness,
            'logical_intent' => CommonAuthorityEvidenceContract::bindIntent(
                'SYNTHETIC-INTENT-'.$identity,
                [
                    'synthetic_action' => 'SYNTHETIC-ACTION',
                    'synthetic_target' => 'SYNTHETIC-TARGET',
                    'expected_source_revision_relation' => CommonAuthorityEvidenceContract::REVISION_EQUAL,
                ],
            ),
            'authoritative_outcome' => $outcome,
            'authoritative_outcome_metadata' => $sourceCarried
                ? ['outcome_reference' => 'SYNTHETIC-SOURCE-OUTCOME-'.$identity, 'source_carried' => true]
                : null,
            'correction_metadata' => null,
            'projection_metadata' => [
                'projection_identity' => 'SYNTHETIC-PROJECTION-'.$identity,
                'represented_source_revision_value' => 1,
                'lag_classification' => 'CURRENT',
                'projection_currentness' => true,
            ],
            'transport_observation' => 'ACKNOWLEDGED',
            'private_fixture_extensions' => [
                'synthetic_private_note' => 'MUST-NOT-LEAK-SYNTHETIC-PRIVATE',
            ],
        ];
    }

    /** @return array<string, mixed> */
    private function bindings(): array
    {
        return [
            'authority_owner' => 'SYNTHETIC-AUTHORITY',
            'authority_scope' => 'SYNTHETIC-SCOPE',
            'actor' => 'SYNTHETIC-ACTOR',
            'actor_role' => 'SYNTHETIC-ROLE',
            'subject' => 'SYNTHETIC-SUBJECT',
            'participants' => ['SYNTHETIC-PARTICIPANT-A', 'SYNTHETIC-PARTICIPANT-B'],
            'audience' => 'SYNTHETIC-AUDIENCE',
            'purpose' => 'SYNTHETIC-PURPOSE',
            'aggregate_context' => 'SYNTHETIC-CONTEXT',
            'lifecycle_identity' => 'SYNTHETIC-LIFECYCLE',
            'terminal' => false,
        ];
    }

    /** @return array<string, mixed> */
    private function query(): array
    {
        return [
            'record_family' => 'SYNTHETIC-APPLICATION-BOUNDARY',
            'authority_owner' => 'SYNTHETIC-AUTHORITY',
            'authority_scope' => 'SYNTHETIC-SCOPE',
            'aggregate_context' => 'SYNTHETIC-CONTEXT',
            'lineage' => 'SYNTHETIC-LINEAGE',
        ];
    }

    /** @return array<string, mixed> */
    private function projectionBindings(): array
    {
        return [
            'viewer' => 'SYNTHETIC-VIEWER',
            'subject' => 'SYNTHETIC-SUBJECT',
            'participants' => ['SYNTHETIC-PARTICIPANT-A', 'SYNTHETIC-PARTICIPANT-B'],
            'audience' => 'SYNTHETIC-AUDIENCE',
            'purpose' => 'SYNTHETIC-PURPOSE',
            'aggregate_context' => 'SYNTHETIC-CONTEXT',
        ];
    }

    /** @param array<string, mixed> $record @return array<string, mixed> */
    private function evidence(array $record): array
    {
        return CommonAuthorityEvidenceContract::evidence(
            $record['bindings'],
            $record['source_condition'],
            $record['source_revision'],
            $record['currentness'],
            $record['freshness'],
            $record['authoritative_outcome'],
        );
    }

    /** @param array<string, mixed> $result */
    private function assertNonAuthority(array $result): void
    {
        foreach ([
            'source_authority',
            'domain_writer_authority',
            'authoritative_mutation_success',
            'permission_token',
            'bearer_capability',
            'transport_execution_authority',
            'production_ready',
            'deployable',
            'real_data_authorized',
        ] as $field) {
            self::assertArrayHasKey($field, $result);
            self::assertFalse($result[$field]);
        }
    }
}
