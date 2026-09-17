<?php

namespace Tests\Unit;

use App\Domain\CommonAuthorityEvidenceContract as CommonContract;
use App\Domain\InMemoryLogicalPersistenceRepositoryContract as Repository;
use App\Domain\LogicalPersistenceAdapterConformanceContract as Conformance;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

final class LogicalPersistenceAdapterConformanceContractTest extends TestCase
{
    public function testAcceptedReferenceOperationFamilyIsConformantAgainstItself(): void
    {
        $repository = new Repository();
        $store = $repository->store($this->record());
        $operations = [
            Conformance::OPERATION_STORE => $store,
            Conformance::OPERATION_READ_EXACT => $repository->readExact('synthetic-record-A'),
            Conformance::OPERATION_RESOLVE_CURRENT => $repository->resolveCurrent($this->query()),
            Conformance::OPERATION_READ_HISTORY => $repository->readHistory($this->query()),
            Conformance::OPERATION_PRIVACY_MINIMAL_PROJECTION => $repository->privacyMinimalProjection('synthetic-record-A'),
            Conformance::OPERATION_OBSERVE_INVALIDATION => $repository->observeInvalidation(
                'synthetic-record-A',
                CommonContract::INVALIDATION_CORRECTION,
            ),
        ];

        foreach ($operations as $operation => $reference) {
            $result = Conformance::evaluate($operation, $reference, $reference);
            self::assertSame(Conformance::CONFORMANT, $result['classification'], $operation);
            self::assertTrue($result['semantic_equivalence'], $operation);
            self::assertTrue($result['comparison_complete'], $operation);
            $this->assertNoAuthority($result);
        }
    }

    public function testStorageAndExactDuplicateRemainNonAuthoritative(): void
    {
        $repository = new Repository();
        $stored = $repository->store($this->record());
        $duplicate = $repository->store($this->record());

        self::assertSame(Repository::STORED_NEW, $stored['storage_outcome']);
        self::assertSame(Repository::EXACT_DUPLICATE, $duplicate['storage_outcome']);
        self::assertFalse($duplicate['permission']);
        self::assertFalse($duplicate['success']);
        self::assertSame(
            Conformance::CONFORMANT,
            Conformance::evaluate(Conformance::OPERATION_STORE, $duplicate, $duplicate)['classification'],
        );
    }

    public function testChangedInputIntentReuseRemainsRejected(): void
    {
        $repository = new Repository();
        $repository->store($this->record(intentIdentity: 'synthetic-intent-fixed', intentValue: 'synthetic-value-A'));
        $rejected = $repository->store($this->record(
            identity: 'synthetic-record-B',
            revision: 2,
            intentIdentity: 'synthetic-intent-fixed',
            intentValue: 'synthetic-value-B',
        ));

        self::assertSame(Repository::CHANGED_INPUT_REUSE_REJECTED, $rejected['storage_outcome']);
        self::assertSame(
            Conformance::CONFORMANT,
            Conformance::evaluate(Conformance::OPERATION_STORE, $rejected, $rejected)['classification'],
        );
    }

    public function testSameLineageNewerResolutionIsIndependentOfInsertionOrder(): void
    {
        $older = $this->record(identity: 'synthetic-record-older', revision: 1);
        $newer = $this->record(identity: 'synthetic-record-newer', revision: 2);
        $forward = new Repository();
        $reverse = new Repository();
        $forward->store($older);
        $forward->store($newer);
        $reverse->store($newer);
        $reverse->store($older);

        $reference = $forward->resolveCurrent($this->query());
        $candidate = $reverse->resolveCurrent($this->query());

        self::assertSame(Repository::RESOLVED, $reference['resolution']);
        self::assertSame('synthetic-record-newer', $reference['record']['logical_record_identity']);
        self::assertSame(Conformance::CONFORMANT, Conformance::evaluate(
            Conformance::OPERATION_RESOLVE_CURRENT,
            $reference,
            $candidate,
        )['classification']);
    }

    public function testEqualRevisionConflictAndCrossLineageIncomparabilityRemainFailClosed(): void
    {
        $repository = new Repository();
        $repository->store($this->record());
        $conflict = $repository->store($this->record(
            identity: 'synthetic-record-conflict',
            intentIdentity: 'synthetic-intent-conflict',
            intentValue: 'synthetic-conflict',
        ));
        $crossLineage = $repository->store($this->record(
            identity: 'synthetic-record-lineage-B',
            lineage: 'synthetic-lineage-B',
        ));
        $incomparable = $repository->resolveCurrent($this->query(lineage: null));

        self::assertSame(Repository::CONFLICTING_EQUAL_REVISION_REJECTED, $conflict['storage_outcome']);
        self::assertSame(Repository::INCOMPARABLE_COEXISTS, $crossLineage['storage_outcome']);
        self::assertSame(Repository::INCOMPARABLE, $incomparable['resolution']);
        self::assertSame(Conformance::CONFORMANT, Conformance::evaluate(
            Conformance::OPERATION_RESOLVE_CURRENT,
            $incomparable,
            $incomparable,
        )['classification']);
        self::assertFalse($this->containsKeyRecursively($incomparable, 'global_revision'));
    }

    public function testUnknownAbsentAndMissingRemainDistinct(): void
    {
        $unknownRepository = new Repository();
        $absentRepository = new Repository();
        $missingRepository = new Repository();
        $unknownRepository->store($this->record(condition: CommonContract::CONDITION_UNKNOWN));
        $absentRepository->store($this->record(condition: CommonContract::CONDITION_ABSENT));
        $unknown = $unknownRepository->resolveCurrent($this->query());
        $absent = $absentRepository->resolveCurrent($this->query());
        $missing = $missingRepository->readExact('synthetic-record-missing');

        self::assertSame(Repository::UNKNOWN, $unknown['resolution']);
        self::assertSame(Repository::ABSENT, $absent['resolution']);
        self::assertSame(Repository::MISSING, $missing['resolution']);

        foreach ([
            Conformance::OPERATION_RESOLVE_CURRENT => [$unknown, $absent],
            Conformance::OPERATION_READ_EXACT => [$missing],
        ] as $operation => $results) {
            foreach ($results as $result) {
                self::assertSame(Conformance::CONFORMANT, Conformance::evaluate($operation, $result, $result)['classification']);
            }
        }
    }

    public function testStaleSupersededAndCurrentnessFreshnessRemainDistinct(): void
    {
        $cases = [
            Repository::STALE => $this->record(condition: CommonContract::CONDITION_STALE),
            Repository::SUPERSEDED => $this->record(condition: CommonContract::CONDITION_SUPERSEDED),
            'CURRENT_NOT_FRESH' => $this->record(currentness: true, freshness: false),
            'FRESH_NOT_CURRENT' => $this->record(currentness: false, freshness: true),
        ];

        foreach ($cases as $case => $record) {
            $repository = new Repository();
            $repository->store($record);
            $result = $repository->resolveCurrent($this->query());
            self::assertSame(Conformance::CONFORMANT, Conformance::evaluate(
                Conformance::OPERATION_RESOLVE_CURRENT,
                $result,
                $result,
            )['classification'], $case);
        }

        $currentStale = new Repository();
        $freshNotCurrent = new Repository();
        $currentStale->store($cases['CURRENT_NOT_FRESH']);
        $freshNotCurrent->store($cases['FRESH_NOT_CURRENT']);
        self::assertSame(Repository::STALE, $currentStale->resolveCurrent($this->query())['resolution']);
        self::assertSame(Repository::UNKNOWN, $freshNotCurrent->resolveCurrent($this->query())['resolution']);
    }

    public function testTerminalIdentityAndInvalidationSemanticsRemainPreserved(): void
    {
        $repository = new Repository();
        $repository->store($this->record(terminal: true));
        $reopen = $repository->store($this->record(
            identity: 'synthetic-record-reopen',
            revision: 2,
            terminal: false,
            intentIdentity: 'synthetic-intent-reopen',
        ));
        $invalidated = $repository->observeInvalidation(
            'synthetic-record-A',
            CommonContract::INVALIDATION_SUPERSESSION,
        );

        self::assertSame(Repository::INVALID_RECORD_REJECTED, $reopen['storage_outcome']);
        self::assertSame('TERMINAL_IDENTITY_REOPEN_REJECTED', $reopen['reason']);
        self::assertTrue($invalidated['record']['terminal']);
        self::assertTrue($invalidated['record']['projection_invalidated']);
        self::assertFalse($invalidated['record']['lifecycle_reset']);
        self::assertFalse($invalidated['record']['reopened']);
        self::assertFalse($invalidated['record']['new_aggregate_created']);
        self::assertFalse($invalidated['record']['transition_synthesized']);
        self::assertSame(Conformance::CONFORMANT, Conformance::evaluate(
            Conformance::OPERATION_OBSERVE_INVALIDATION,
            $invalidated,
            $invalidated,
        )['classification']);
    }

    public function testSourceCarriedOutcomeIsPreservedButCannotBeInvented(): void
    {
        $carriedRepository = new Repository();
        $carriedRepository->store($this->record(
            outcome: CommonContract::OUTCOME_COMMITTED,
            authoritativeMetadata: [
                'source_carried' => true,
                'outcome_reference' => 'synthetic-authoritative-outcome-A',
            ],
        ));
        $carried = $carriedRepository->privacyMinimalProjection('synthetic-record-A');
        self::assertSame(Conformance::CONFORMANT, Conformance::evaluate(
            Conformance::OPERATION_PRIVACY_MINIMAL_PROJECTION,
            $carried,
            $carried,
        )['classification']);

        $unknownRepository = new Repository();
        $unknownRepository->store($this->record());
        $reference = $unknownRepository->privacyMinimalProjection('synthetic-record-A');
        $invented = $reference;
        $invented['record']['authoritative_outcome_source_carried'] = true;
        $invented['record']['authoritative_outcome_reference'] = 'synthetic-invented-outcome';

        self::assertSame(Conformance::NON_CONFORMANT, Conformance::evaluate(
            Conformance::OPERATION_PRIVACY_MINIMAL_PROJECTION,
            $reference,
            $invented,
        )['classification']);
    }

    public function testTransportObservationRemainsNonDomainOutcome(): void
    {
        $repository = new Repository();
        $repository->store($this->record(transportObservation: 'ACKNOWLEDGED'));
        $reference = $repository->privacyMinimalProjection('synthetic-record-A');

        self::assertFalse($reference['record']['transport_is_domain_outcome']);
        self::assertSame(CommonContract::OUTCOME_UNKNOWN, $reference['record']['transport_authoritative_outcome']);
        self::assertSame(Conformance::CONFORMANT, Conformance::evaluate(
            Conformance::OPERATION_PRIVACY_MINIMAL_PROJECTION,
            $reference,
            $reference,
        )['classification']);
    }

    public function testPrivacyMinimalProjectionOmitsPrivateSentinelMaterial(): void
    {
        $repository = new Repository();
        $record = $this->record();
        $record['private_fixture_extensions'] = [
            'conversation_content' => 'synthetic-private-MUST-NOT-LEAK',
            'message_preview' => 'synthetic-private-MUST-NOT-LEAK',
            'hidden_safety_evidence' => 'synthetic-private-MUST-NOT-LEAK',
            'credential' => 'synthetic-private-MUST-NOT-LEAK',
            'device_token' => 'synthetic-private-MUST-NOT-LEAK',
            'provider_payload' => 'synthetic-private-MUST-NOT-LEAK',
        ];
        $repository->store($record);
        $projection = $repository->privacyMinimalProjection('synthetic-record-A');
        $encoded = json_encode($projection);

        self::assertIsString($encoded);
        self::assertStringNotContainsString('MUST-NOT-LEAK', $encoded);
        self::assertSame(Conformance::CONFORMANT, Conformance::evaluate(
            Conformance::OPERATION_PRIVACY_MINIMAL_PROJECTION,
            $projection,
            $projection,
        )['classification']);
    }

    public function testChangedStorageAndResolutionDispositionsAreNonConformant(): void
    {
        $repository = new Repository();
        $storageReference = $repository->store($this->record());
        $storageMutation = $storageReference;
        $storageMutation['storage_outcome'] = Repository::EXACT_DUPLICATE;
        $resolutionReference = $repository->resolveCurrent($this->query());
        $resolutionMutation = $resolutionReference;
        $resolutionMutation['resolution'] = Repository::MISSING;

        self::assertSame(Conformance::NON_CONFORMANT, Conformance::evaluate(
            Conformance::OPERATION_STORE,
            $storageReference,
            $storageMutation,
        )['classification']);
        self::assertSame(Conformance::NON_CONFORMANT, Conformance::evaluate(
            Conformance::OPERATION_RESOLVE_CURRENT,
            $resolutionReference,
            $resolutionMutation,
        )['classification']);
    }

    #[DataProvider('synthesizedAuthorityProvider')]
    public function testSynthesizedAuthorityOrSuccessIsNonConformant(string $field): void
    {
        $repository = new Repository();
        $reference = $repository->store($this->record());
        $candidate = $reference;
        $candidate[$field] = true;

        $result = Conformance::evaluate(Conformance::OPERATION_STORE, $reference, $candidate);

        self::assertSame(Conformance::NON_CONFORMANT, $result['classification']);
        $this->assertNoAuthority($result);
    }

    /** @return iterable<string, array{string}> */
    public static function synthesizedAuthorityProvider(): iterable
    {
        yield 'source authority' => ['source_authority'];
        yield 'permission' => ['permission'];
        yield 'domain success' => ['domain_success'];
    }

    public function testGlobalRevisionAndLastWriteOrReceiveWinsMarkersAreNonConformant(): void
    {
        $repository = new Repository();
        $repository->store($this->record());
        $reference = $repository->resolveCurrent($this->query());

        foreach ([
            'global revision' => ['global_revision', 'synthetic-global-revision'],
            'last write wins' => ['last_write_wins', true],
            'last received wins' => ['last_received_wins', true],
        ] as [$field, $value]) {
            $candidate = $reference;
            $candidate[$field] = $value;
            self::assertSame(Conformance::NON_CONFORMANT, Conformance::evaluate(
                Conformance::OPERATION_RESOLVE_CURRENT,
                $reference,
                $candidate,
            )['classification']);
        }
    }

    public function testPrivateFieldOrSentinelLeakIsNonConformant(): void
    {
        $repository = new Repository();
        $repository->store($this->record());
        $reference = $repository->privacyMinimalProjection('synthetic-record-A');
        $candidate = $reference;
        $candidate['record']['conversation_content'] = 'synthetic-private-MUST-NOT-LEAK';

        self::assertSame(Conformance::NON_CONFORMANT, Conformance::evaluate(
            Conformance::OPERATION_PRIVACY_MINIMAL_PROJECTION,
            $reference,
            $candidate,
        )['classification']);
    }

    public function testStructurallyIncompleteEvidenceIsUnknown(): void
    {
        $repository = new Repository();
        $repository->store($this->record());
        $reference = $repository->resolveCurrent($this->query());
        $incompleteCandidate = $reference;
        unset($incompleteCandidate['resolution']);

        self::assertSame(Conformance::UNKNOWN, Conformance::evaluate(
            Conformance::OPERATION_RESOLVE_CURRENT,
            $reference,
            $incompleteCandidate,
        )['classification']);
        self::assertSame(Conformance::UNKNOWN, Conformance::evaluate(
            Conformance::OPERATION_RESOLVE_CURRENT,
            [],
            $reference,
        )['classification']);
        self::assertSame(Conformance::UNKNOWN, Conformance::evaluate(
            'SYNTHETIC_UNKNOWN_OPERATION',
            $reference,
            $reference,
        )['classification']);
    }

    public function testEvaluationIsDeterministicAndDoesNotMutateEvidence(): void
    {
        $repository = new Repository();
        $repository->store($this->record());
        $reference = $repository->resolveCurrent($this->query());
        $candidate = $reference;
        $referenceBefore = $reference;
        $candidateBefore = $candidate;

        $first = Conformance::evaluate(Conformance::OPERATION_RESOLVE_CURRENT, $reference, $candidate);
        $second = Conformance::evaluate(Conformance::OPERATION_RESOLVE_CURRENT, $reference, $candidate);

        self::assertSame($first, $second);
        self::assertSame($referenceBefore, $reference);
        self::assertSame($candidateBefore, $candidate);
    }

    /** @param array<string, mixed> $result */
    private function assertNoAuthority(array $result): void
    {
        foreach ([
            'source_authority', 'authoritative_mutation_success', 'permission', 'bearer_capability',
            'domain_success', 'readiness_authority', 'match_authority', 'connection_authority',
            'consent_authority', 'conversation_authority', 'relationship_authority',
            'home_action_authority', 'notification_delivery_authority', 'launch_authority',
            'production_ready', 'durability_established', 'transactional', 'concurrent_safe', 'deployable',
        ] as $field) {
            self::assertFalse($result[$field], $field);
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
    ): array {
        $intentIdentity ??= 'synthetic-intent-'.$identity;
        $intentValue ??= 'synthetic-intent-input-'.$identity;

        return [
            'logical_record_identity' => $identity,
            'record_family' => 'SYNTHETIC_LOGICAL_FAMILY',
            'bindings' => [
                'authority_owner' => 'synthetic-owner-A',
                'authority_scope' => 'synthetic-scope-A',
                'actor' => 'synthetic-actor-A',
                'actor_role' => 'synthetic-role-A',
                'subject' => 'synthetic-subject-A',
                'participants' => ['synthetic-participant-A', 'synthetic-participant-B'],
                'audience' => 'synthetic-audience-A',
                'purpose' => 'synthetic-purpose-A',
                'aggregate_context' => 'synthetic-context-A',
                'lifecycle_identity' => 'synthetic-lifecycle-A',
                'terminal' => $terminal,
            ],
            'source_revision' => CommonContract::sourceRevision(
                'synthetic-owner-A',
                'synthetic-scope-A',
                $lineage,
                'synthetic-context-A',
                $revision,
            ),
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
    private function query(?string $lineage = 'synthetic-lineage-A'): array
    {
        return [
            'record_family' => 'SYNTHETIC_LOGICAL_FAMILY',
            'authority_owner' => 'synthetic-owner-A',
            'authority_scope' => 'synthetic-scope-A',
            'aggregate_context' => 'synthetic-context-A',
            'lineage' => $lineage,
        ];
    }

    /** @param array<mixed> $value */
    private function containsKeyRecursively(array $value, string $needle): bool
    {
        foreach ($value as $key => $nested) {
            if ($key === $needle) {
                return true;
            }

            if (is_array($nested) && $this->containsKeyRecursively($nested, $needle)) {
                return true;
            }
        }

        return false;
    }
}
