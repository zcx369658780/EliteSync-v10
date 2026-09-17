<?php

namespace Tests\Unit;

use App\Domain\CommonAuthorityEvidenceContract as CommonContract;
use App\Domain\InMemoryLogicalPersistenceRepositoryContract as Reference;
use App\Domain\LogicalPersistenceAdapterConformanceContract as Conformance;
use App\Domain\SqliteInMemoryLogicalPersistenceAdapter as Adapter;
use PHPUnit\Framework\TestCase;

final class SqliteInMemoryLogicalPersistenceAdapterTest extends TestCase
{
    public function testPhysicalBoundaryIsDisposableSqliteMemoryAndNonAuthoritative(): void
    {
        $adapter = new Adapter();
        $facts = $adapter->physicalBoundaryFacts();

        self::assertSame('sqlite::memory:', $facts['dsn']);
        self::assertSame('sqlite', $facts['driver']);
        self::assertSame(['logical_invalidations', 'logical_records'], $facts['disposable_tables']);
        self::assertTrue($facts['schema_initialized']);
        self::assertFalse($facts['persistent_database']);
        self::assertFalse($facts['rowid_exposed']);
        self::assertFalse($facts['insertion_order_authority']);
        self::assertFalse($facts['sql_execution_order_authority']);
        self::assertFalse($facts['sql_success_is_domain_success']);
        self::assertFalse($facts['row_presence_is_source_authority']);
        self::assertFalse($facts['table_existence_is_authority']);
        $this->assertNoAuthority($facts);
    }

    public function testAllSixOperationFamiliesConformToAcceptedReference(): void
    {
        $reference = new Reference();
        $adapter = new Adapter();
        $record = $this->record();

        $this->assertConformant(
            Conformance::OPERATION_STORE,
            $reference->store($record),
            $adapter->store($record),
        );
        $this->assertConformant(
            Conformance::OPERATION_READ_EXACT,
            $reference->readExact('synthetic-record-A'),
            $adapter->readExact('synthetic-record-A'),
        );
        $this->assertConformant(
            Conformance::OPERATION_RESOLVE_CURRENT,
            $reference->resolveCurrent($this->query()),
            $adapter->resolveCurrent($this->query()),
        );
        $this->assertConformant(
            Conformance::OPERATION_READ_HISTORY,
            $reference->readHistory($this->query()),
            $adapter->readHistory($this->query()),
        );
        $this->assertConformant(
            Conformance::OPERATION_PRIVACY_MINIMAL_PROJECTION,
            $reference->privacyMinimalProjection('synthetic-record-A'),
            $adapter->privacyMinimalProjection('synthetic-record-A'),
        );
        $this->assertConformant(
            Conformance::OPERATION_OBSERVE_INVALIDATION,
            $reference->observeInvalidation('synthetic-record-A', CommonContract::INVALIDATION_CORRECTION),
            $adapter->observeInvalidation('synthetic-record-A', CommonContract::INVALIDATION_CORRECTION),
        );
    }

    public function testExactDuplicateAndChangedInputIntentReuseMatchReference(): void
    {
        $reference = new Reference();
        $adapter = new Adapter();
        $record = $this->record(intentIdentity: 'synthetic-intent-fixed', intentValue: 'synthetic-value-A');

        $reference->store($record);
        $adapter->store($record);
        $duplicateReference = $reference->store($record);
        $duplicateAdapter = $adapter->store($record);
        $this->assertConformant(Conformance::OPERATION_STORE, $duplicateReference, $duplicateAdapter);
        self::assertSame(Reference::EXACT_DUPLICATE, $duplicateAdapter['storage_outcome']);
        self::assertTrue($duplicateAdapter['idempotent_correlation']);
        self::assertFalse($duplicateAdapter['permission']);
        self::assertFalse($duplicateAdapter['success']);
        self::assertSame(1, $adapter->count());

        $changed = $this->record(
            identity: 'synthetic-record-B',
            revision: 2,
            intentIdentity: 'synthetic-intent-fixed',
            intentValue: 'synthetic-value-B',
        );
        $changedReference = $reference->store($changed);
        $changedAdapter = $adapter->store($changed);
        $this->assertConformant(Conformance::OPERATION_STORE, $changedReference, $changedAdapter);
        self::assertSame(Reference::CHANGED_INPUT_REUSE_REJECTED, $changedAdapter['storage_outcome']);
        self::assertSame(1, $adapter->count());
    }

    public function testSameLineageResolutionIgnoresInsertionAndSqlOrder(): void
    {
        $older = $this->record(identity: 'synthetic-record-older', revision: 1);
        $newer = $this->record(identity: 'synthetic-record-newer', revision: 2);

        foreach ([[$older, $newer], [$newer, $older]] as $records) {
            $reference = new Reference();
            $adapter = new Adapter();

            foreach ($records as $record) {
                $this->assertConformant(
                    Conformance::OPERATION_STORE,
                    $reference->store($record),
                    $adapter->store($record),
                );
            }

            $referenceResult = $reference->resolveCurrent($this->query());
            $adapterResult = $adapter->resolveCurrent($this->query());
            $this->assertConformant(Conformance::OPERATION_RESOLVE_CURRENT, $referenceResult, $adapterResult);
            self::assertSame('synthetic-record-newer', $adapterResult['record']['logical_record_identity']);
        }
    }

    public function testEqualRevisionConflictAndCrossBindingRecordsFailClosed(): void
    {
        $reference = new Reference();
        $adapter = new Adapter();
        $reference->store($this->record());
        $adapter->store($this->record());

        $conflict = $this->record(
            identity: 'synthetic-record-conflict',
            intentIdentity: 'synthetic-intent-conflict',
            intentValue: 'synthetic-conflict',
        );
        $conflictReference = $reference->store($conflict);
        $conflictAdapter = $adapter->store($conflict);
        $this->assertConformant(Conformance::OPERATION_STORE, $conflictReference, $conflictAdapter);
        self::assertSame(Reference::CONFLICTING_EQUAL_REVISION_REJECTED, $conflictAdapter['storage_outcome']);

        $incomparableRecords = [
            $this->record(identity: 'synthetic-lineage-record', lineage: 'synthetic-lineage-B'),
            $this->record(identity: 'synthetic-authority-record', owner: 'synthetic-owner-B'),
            $this->record(identity: 'synthetic-scope-record', scope: 'synthetic-scope-B'),
            $this->record(identity: 'synthetic-context-record', context: 'synthetic-context-B'),
        ];

        foreach ($incomparableRecords as $record) {
            $referenceResult = $reference->store($record);
            $adapterResult = $adapter->store($record);
            $this->assertConformant(Conformance::OPERATION_STORE, $referenceResult, $adapterResult);
            self::assertSame(Reference::INCOMPARABLE_COEXISTS, $adapterResult['storage_outcome']);
        }

        $broadReference = $reference->resolveCurrent($this->query(lineage: null));
        $broadAdapter = $adapter->resolveCurrent($this->query(lineage: null));
        $this->assertConformant(Conformance::OPERATION_RESOLVE_CURRENT, $broadReference, $broadAdapter);
        self::assertSame(Reference::INCOMPARABLE, $broadAdapter['resolution']);
        self::assertFalse($this->containsKeyRecursively($broadAdapter, 'global_revision'));
    }

    public function testUnknownAbsentMissingStaleAndSupersededRemainDistinct(): void
    {
        $cases = [
            CommonContract::CONDITION_UNKNOWN => Reference::UNKNOWN,
            CommonContract::CONDITION_ABSENT => Reference::ABSENT,
            CommonContract::CONDITION_STALE => Reference::STALE,
            CommonContract::CONDITION_SUPERSEDED => Reference::SUPERSEDED,
        ];

        foreach ($cases as $condition => $expected) {
            $reference = new Reference();
            $adapter = new Adapter();
            $record = $this->record(condition: $condition);
            $reference->store($record);
            $adapter->store($record);
            $referenceResult = $reference->resolveCurrent($this->query());
            $adapterResult = $adapter->resolveCurrent($this->query());
            $this->assertConformant(Conformance::OPERATION_RESOLVE_CURRENT, $referenceResult, $adapterResult);
            self::assertSame($expected, $adapterResult['resolution']);
        }

        $reference = new Reference();
        $adapter = new Adapter();
        $referenceMissing = $reference->readExact('synthetic-missing-record');
        $adapterMissing = $adapter->readExact('synthetic-missing-record');
        $this->assertConformant(Conformance::OPERATION_READ_EXACT, $referenceMissing, $adapterMissing);
        self::assertSame(Reference::MISSING, $adapterMissing['resolution']);
    }

    public function testCurrentnessAndFreshnessRemainIndependent(): void
    {
        $cases = [
            'CURRENT_NOT_FRESH' => [$this->record(currentness: true, freshness: false), Reference::STALE],
            'FRESH_NOT_CURRENT' => [$this->record(currentness: false, freshness: true), Reference::UNKNOWN],
        ];

        foreach ($cases as $name => [$record, $expected]) {
            $reference = new Reference();
            $adapter = new Adapter();
            $reference->store($record);
            $adapter->store($record);
            $referenceResult = $reference->resolveCurrent($this->query());
            $adapterResult = $adapter->resolveCurrent($this->query());
            $this->assertConformant(Conformance::OPERATION_RESOLVE_CURRENT, $referenceResult, $adapterResult);
            self::assertSame($expected, $adapterResult['resolution'], $name);
            self::assertNotSame(Reference::RESOLVED, $adapterResult['resolution'], $name);
        }
    }

    public function testTerminalIdentityCannotReopenAndInvalidationDoesNotResetLifecycle(): void
    {
        $reference = new Reference();
        $adapter = new Adapter();
        $terminal = $this->record(terminal: true);
        $reference->store($terminal);
        $adapter->store($terminal);

        $reopen = $this->record(
            identity: 'synthetic-record-reopen',
            revision: 2,
            terminal: false,
            intentIdentity: 'synthetic-intent-reopen',
        );
        $reopenReference = $reference->store($reopen);
        $reopenAdapter = $adapter->store($reopen);
        $this->assertConformant(Conformance::OPERATION_STORE, $reopenReference, $reopenAdapter);
        self::assertSame('TERMINAL_IDENTITY_REOPEN_REJECTED', $reopenAdapter['reason']);

        foreach ([
            CommonContract::INVALIDATION_CORRECTION,
            CommonContract::INVALIDATION_REVOCATION,
            CommonContract::INVALIDATION_SUPERSESSION,
        ] as $relation) {
            $referenceResult = $reference->observeInvalidation('synthetic-record-A', $relation);
            $adapterResult = $adapter->observeInvalidation('synthetic-record-A', $relation);
            $this->assertConformant(Conformance::OPERATION_OBSERVE_INVALIDATION, $referenceResult, $adapterResult);
            self::assertTrue($adapterResult['record']['terminal']);
            self::assertTrue($adapterResult['record']['projection_invalidated']);
            self::assertFalse($adapterResult['record']['lifecycle_reset']);
            self::assertFalse($adapterResult['record']['reopened']);
            self::assertFalse($adapterResult['record']['new_aggregate_created']);
            self::assertFalse($adapterResult['record']['transition_synthesized']);
        }
    }

    public function testSourceCarriedOutcomeTransportAndPrivacyProjectionMatchReference(): void
    {
        $record = $this->record(
            outcome: CommonContract::OUTCOME_COMMITTED,
            authoritativeMetadata: [
                'source_carried' => true,
                'outcome_reference' => 'synthetic-authoritative-outcome-A',
            ],
            transportObservation: 'ACKNOWLEDGED',
        );
        $record['private_fixture_extensions'] = [
            'conversation_content' => 'synthetic-private-MUST-NOT-LEAK',
            'message_preview' => 'synthetic-private-MUST-NOT-LEAK',
            'hidden_safety_evidence' => 'synthetic-private-MUST-NOT-LEAK',
            'credential' => 'synthetic-private-MUST-NOT-LEAK',
            'device_token' => 'synthetic-private-MUST-NOT-LEAK',
            'provider_payload' => 'synthetic-private-MUST-NOT-LEAK',
        ];
        $reference = new Reference();
        $adapter = new Adapter();
        $reference->store($record);
        $adapter->store($record);
        $referenceResult = $reference->privacyMinimalProjection('synthetic-record-A');
        $adapterResult = $adapter->privacyMinimalProjection('synthetic-record-A');
        $this->assertConformant(
            Conformance::OPERATION_PRIVACY_MINIMAL_PROJECTION,
            $referenceResult,
            $adapterResult,
        );

        self::assertTrue($adapterResult['record']['authoritative_outcome_source_carried']);
        self::assertSame('synthetic-authoritative-outcome-A', $adapterResult['record']['authoritative_outcome_reference']);
        self::assertSame(CommonContract::OUTCOME_UNKNOWN, $adapterResult['record']['transport_authoritative_outcome']);
        self::assertFalse($adapterResult['record']['transport_is_domain_outcome']);
        $encoded = json_encode($adapterResult);
        self::assertIsString($encoded);
        self::assertStringNotContainsString('MUST-NOT-LEAK', $encoded);

        $unknownOutcomeAdapter = new Adapter();
        $unknownOutcomeAdapter->store($this->record());
        $projection = $unknownOutcomeAdapter->privacyMinimalProjection('synthetic-record-A');
        self::assertFalse($projection['record']['authoritative_outcome_source_carried']);
        self::assertNull($projection['record']['authoritative_outcome_reference']);
    }

    public function testMutatedAdapterResultIsNonConformant(): void
    {
        $reference = new Reference();
        $adapter = new Adapter();
        $record = $this->record();
        $reference->store($record);
        $adapter->store($record);
        $expected = $reference->resolveCurrent($this->query());
        $mutated = $adapter->resolveCurrent($this->query());
        $mutated['resolution'] = Reference::MISSING;

        $result = Conformance::evaluate(Conformance::OPERATION_RESOLVE_CURRENT, $expected, $mutated);

        self::assertSame(Conformance::NON_CONFORMANT, $result['classification']);
        self::assertFalse($result['semantic_equivalence']);
        $this->assertNoAuthority($result);
    }

    public function testInputsAreNotMutatedAndRepeatedReadsAreDeterministic(): void
    {
        $adapter = new Adapter();
        $record = $this->record();
        $query = $this->query();
        $recordBefore = $record;
        $queryBefore = $query;

        $adapter->store($record);
        $first = $adapter->resolveCurrent($query);
        $second = $adapter->resolveCurrent($query);

        self::assertSame($recordBefore, $record);
        self::assertSame($queryBefore, $query);
        self::assertSame($first, $second);
        self::assertFalse($first['source_authority']);
        self::assertFalse($first['authoritative_mutation_success']);
        self::assertFalse($first['domain_success']);
    }

    /** @param array<string, mixed> $reference @param array<string, mixed> $candidate */
    private function assertConformant(string $operation, array $reference, array $candidate): void
    {
        $classification = Conformance::evaluate($operation, $reference, $candidate);
        self::assertSame(Conformance::CONFORMANT, $classification['classification'], $operation);
        self::assertTrue($classification['comparison_complete'], $operation);
        self::assertTrue($classification['semantic_equivalence'], $operation);
        $this->assertNoAuthority($classification);
        $this->assertNoAuthority($candidate);
    }

    /** @param array<string, mixed> $result */
    private function assertNoAuthority(array $result): void
    {
        foreach ([
            'source_authority', 'authoritative_mutation_success', 'permission', 'bearer_capability',
            'success', 'domain_success', 'readiness_authority', 'match_authority', 'connection_authority',
            'consent_authority', 'conversation_authority', 'relationship_authority',
            'home_action_authority', 'notification_delivery_authority', 'launch_authority',
            'production_ready', 'durability_established', 'transactional', 'concurrent_safe', 'deployable',
        ] as $field) {
            if (array_key_exists($field, $result)) {
                self::assertFalse($result[$field], $field);
            }
        }
    }

    /** @return array<string, mixed> */
    private function record(
        string $identity = 'synthetic-record-A',
        int $revision = 1,
        string $lineage = 'synthetic-lineage-A',
        string $condition = CommonContract::CONDITION_PRESENT,
        ?bool $currentness = true,
        ?bool $freshness = true,
        ?string $intentIdentity = null,
        ?string $intentValue = null,
        bool $terminal = false,
        string $outcome = CommonContract::OUTCOME_UNKNOWN,
        ?array $authoritativeMetadata = null,
        string $transportObservation = 'AMBIGUOUS',
        string $owner = 'synthetic-owner-A',
        string $scope = 'synthetic-scope-A',
        string $context = 'synthetic-context-A',
        string $lifecycle = 'synthetic-lifecycle-A',
    ): array {
        $intentIdentity ??= 'synthetic-intent-'.$identity;
        $intentValue ??= 'synthetic-intent-input-'.$identity;

        return [
            'logical_record_identity' => $identity,
            'record_family' => 'SYNTHETIC_LOGICAL_FAMILY',
            'bindings' => [
                'authority_owner' => $owner,
                'authority_scope' => $scope,
                'actor' => 'synthetic-actor-A',
                'actor_role' => 'synthetic-role-A',
                'subject' => 'synthetic-subject-A',
                'participants' => ['synthetic-participant-A', 'synthetic-participant-B'],
                'audience' => 'synthetic-audience-A',
                'purpose' => 'synthetic-purpose-A',
                'aggregate_context' => $context,
                'lifecycle_identity' => $lifecycle,
                'terminal' => $terminal,
            ],
            'source_revision' => CommonContract::sourceRevision($owner, $scope, $lineage, $context, $revision),
            'source_condition' => $condition,
            'currentness' => $currentness,
            'freshness' => $freshness,
            'logical_intent' => CommonContract::bindIntent($intentIdentity, [
                'action' => 'synthetic-logical-store',
                'value' => $intentValue,
            ]),
            'authoritative_outcome' => $outcome,
            'authoritative_outcome_metadata' => $authoritativeMetadata,
            'correction_metadata' => null,
            'projection_metadata' => [
                'projection_identity' => 'synthetic-projection-'.$identity,
                'represented_source_revision_value' => $revision,
                'lag_classification' => 'LAGGED',
                'projection_currentness' => false,
            ],
            'transport_observation' => $transportObservation,
            'private_fixture_extensions' => [],
        ];
    }

    /** @return array<string, mixed> */
    private function query(
        ?string $lineage = 'synthetic-lineage-A',
        string $owner = 'synthetic-owner-A',
        string $scope = 'synthetic-scope-A',
        string $context = 'synthetic-context-A',
    ): array {
        return [
            'record_family' => 'SYNTHETIC_LOGICAL_FAMILY',
            'authority_owner' => $owner,
            'authority_scope' => $scope,
            'aggregate_context' => $context,
            'lineage' => $lineage,
        ];
    }

    /** @param array<mixed> $value */
    private function containsKeyRecursively(array $value, string $needle): bool
    {
        foreach ($value as $key => $nested) {
            if ($key === $needle || (is_array($nested) && $this->containsKeyRecursively($nested, $needle))) {
                return true;
            }
        }

        return false;
    }
}
