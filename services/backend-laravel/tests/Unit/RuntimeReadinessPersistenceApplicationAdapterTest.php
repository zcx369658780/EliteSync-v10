<?php

namespace Tests\Unit;

use App\Domain\CommonAuthorityEvidenceContract;
use App\Domain\InMemoryLogicalPersistenceRepositoryContract;
use App\Domain\LogicalPersistenceAdapterConformanceContract;
use App\Domain\PersistenceBoundaryApplicationInterfaceIntegrationContract;
use App\Domain\RuntimeReadinessDerivedEvaluator;
use App\Domain\RuntimeReadinessPersistenceApplicationAdapter;
use App\Domain\SqliteInMemoryLogicalPersistenceAdapter;
use InvalidArgumentException;
use PHPUnit\Framework\TestCase;
use ReflectionMethod;

final class RuntimeReadinessPersistenceApplicationAdapterTest extends TestCase
{
    private const PRIVATE_SENTINEL = 'MUST-NOT-LEAK-RR03-PRIVATE';

    public function testReadyIsLosslesslyMaterializedWithoutAuthoritySubstitution(): void
    {
        [$adapter, $application, $sqlite] = $this->system();
        $set = $this->prerequisiteSet();
        $members = $this->members();
        $setBefore = $set;
        $membersBefore = $members;

        $result = $adapter->evaluateSynthetic($set, $members);

        self::assertSame(RuntimeReadinessDerivedEvaluator::READINESS_READY, $result['readiness_classification']);
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::STORED_NEW, $result['storage_disposition']);
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::RESOLVED, $result['projection_read_disposition']);
        self::assertTrue($result['materialized_projection_usable']);
        self::assertSame(CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN, $result['authoritative_outcome']);
        self::assertSame(0, $result['source_revision']['value']);
        self::assertStringStartsWith('rr03-record-v1:', $result['logical_record_identity']);
        self::assertStringStartsWith('rr03-intent-v1:', $result['logical_intent_identity']);
        self::assertStringStartsWith('rr03-lineage-v1:', $result['source_projection_lineage']);
        self::assertNull($result['transport_disposition']);
        self::assertNull($result['http_status']);
        self::assertSame($setBefore, $set);
        self::assertSame($membersBefore, $members);
        self::assertStringNotContainsString(self::PRIVATE_SENTINEL, json_encode($result, JSON_THROW_ON_ERROR));

        $expectedPayloadKeys = [
            'classification', 'dependencies', 'derived_fact_class', 'invalidation', 'payload_kind',
            'prerequisite_set_condition', 'prerequisite_set_currentness', 'prerequisite_set_freshness',
            'prerequisite_set_identity', 'prerequisite_set_revision', 'prerequisite_set_state',
            'protected_use_scope', 'reason_categories',
        ];
        $actualPayloadKeys = array_keys($result['rr03_payload']);
        sort($actualPayloadKeys);
        self::assertSame($expectedPayloadKeys, $actualPayloadKeys);
        self::assertSame(['synthetic-member-a', 'synthetic-member-b'], array_column(
            $result['rr03_payload']['dependencies'],
            'dependency_identity',
        ));
        self::assertSame(['logical_invalidations', 'logical_records'], $sqlite->physicalBoundaryFacts()['disposable_tables']);
        self::assertSame('sqlite::memory:', $sqlite->physicalBoundaryFacts()['dsn']);

        foreach ($this->mandatoryNonAuthorityFields() as $field) {
            self::assertFalse($result[$field], $field);
        }

        self::assertInstanceOf(PersistenceBoundaryApplicationInterfaceIntegrationContract::class, $application);
    }

    public function testNotReadyRemainsSeparateFromStorageAndAuthoritativeOutcome(): void
    {
        [$adapter] = $this->system();
        $members = $this->members();
        $members[0]['prerequisite_outcome'] = RuntimeReadinessDerivedEvaluator::OUTCOME_UNSATISFIED;

        $result = $adapter->evaluateSynthetic($this->prerequisiteSet(), $members);

        self::assertSame(RuntimeReadinessDerivedEvaluator::READINESS_NOT_READY, $result['readiness_classification']);
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::STORED_NEW, $result['storage_disposition']);
        self::assertTrue($result['materialized_projection_usable']);
        self::assertSame(CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN, $result['authoritative_outcome']);
        self::assertFalse($result['authoritative_mutation_success']);
        self::assertSame(['AUTHORITATIVE_REQUIRED_MEMBER_UNSATISFIED'], $result['rr03_payload']['reason_categories']);
    }

    public function testUnknownFromUnusableMemberFailsProjectionUseClosedWithoutChangingClassification(): void
    {
        [$adapter] = $this->system();
        $members = $this->members();
        $members[0]['source_evidence']['freshness'] = false;

        $result = $adapter->evaluateSynthetic($this->prerequisiteSet(), $members);

        self::assertSame(RuntimeReadinessDerivedEvaluator::READINESS_UNKNOWN, $result['readiness_classification']);
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::STALE, $result['projection_read_disposition']);
        self::assertFalse($result['materialized_projection_usable']);
        self::assertSame(['MEMBER_UNUSABLE'], $result['rr03_payload']['reason_categories']);
        self::assertFalse(array_column(
            $result['rr03_payload']['dependencies'],
            'freshness',
            'dependency_identity',
        )['synthetic-member-b']);
    }

    public function testUnknownPrerequisiteSetIsDistinctFromKnownEmptySet(): void
    {
        [$unknownAdapter] = $this->system();
        $unknownSet = $this->prerequisiteSet(RuntimeReadinessDerivedEvaluator::SET_UNKNOWN, []);
        $unknownSet['set_identity'] = null;
        $unknown = $unknownAdapter->evaluateSynthetic($unknownSet, []);

        [$knownAdapter] = $this->system();
        $known = $knownAdapter->evaluateSynthetic(
            $this->prerequisiteSet(RuntimeReadinessDerivedEvaluator::SET_KNOWN, []),
            [],
        );

        self::assertSame(RuntimeReadinessDerivedEvaluator::READINESS_UNKNOWN, $unknown['readiness_classification']);
        self::assertSame('UNKNOWN_PREREQUISITE_SET', $unknown['rr03_payload']['reason_categories'][0]);
        self::assertSame(RuntimeReadinessDerivedEvaluator::READINESS_READY, $known['readiness_classification']);
        self::assertNotSame($unknown['logical_record_identity'], $known['logical_record_identity']);
    }

    public function testExactDuplicateIsIdempotentCorrelationOnly(): void
    {
        [$adapter, , $sqlite] = $this->system();
        $set = $this->prerequisiteSet();
        $members = $this->members();

        $first = $adapter->evaluateSynthetic($set, $members);
        $duplicate = $adapter->evaluateSynthetic($set, $members);

        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::STORED_NEW, $first['storage_disposition']);
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::EXACT_DUPLICATE, $duplicate['storage_disposition']);
        self::assertSame($first['logical_record_identity'], $duplicate['logical_record_identity']);
        self::assertSame($first['logical_intent_identity'], $duplicate['logical_intent_identity']);
        self::assertSame(1, $sqlite->count());
        self::assertSame(CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN, $duplicate['authoritative_outcome']);
        self::assertFalse($duplicate['source_authority']);
    }

    public function testDistinctDependencyRevisionVectorsCreateDistinctCoexistingIdentities(): void
    {
        [$adapter, , $sqlite] = $this->system();
        $first = $adapter->evaluateSynthetic($this->prerequisiteSet(), $this->members());
        $changed = $this->members();
        $changed[0] = $this->member('synthetic-member-b', RuntimeReadinessDerivedEvaluator::FACT_VERIFICATION, 8);
        $second = $adapter->evaluateSynthetic($this->prerequisiteSet(), $changed);

        self::assertNotSame($first['logical_record_identity'], $second['logical_record_identity']);
        self::assertNotSame($first['logical_intent_identity'], $second['logical_intent_identity']);
        self::assertNotSame($first['source_projection_lineage'], $second['source_projection_lineage']);
        self::assertSame($first['lifecycle_identity'], $second['lifecycle_identity']);
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::INCOMPARABLE_COEXISTS, $second['storage_disposition']);
        self::assertNull($second['projection_read_disposition']);
        self::assertSame(2, $sqlite->count());
    }

    public function testTerminalLifecycleCannotReopenAndRejectedStorageSkipsRetrieval(): void
    {
        [$adapter] = $this->system();
        $terminalSet = $this->prerequisiteSet();
        $terminalSet['required_bindings']['terminal'] = true;
        $terminalSet['source_evidence']['bindings']['terminal'] = true;
        $adapter->evaluateSynthetic($terminalSet, $this->members());

        $reopenedSet = $this->prerequisiteSet();
        $rejected = $adapter->evaluateSynthetic($reopenedSet, $this->members());

        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::INVALID_RECORD_REJECTED, $rejected['storage_disposition']);
        self::assertNull($rejected['projection_read_disposition']);
        self::assertFalse($rejected['materialized_projection_usable']);
        self::assertSame(RuntimeReadinessDerivedEvaluator::READINESS_READY, $rejected['readiness_classification']);
    }

    public function testInvalidationMakesReadbackUnusableWithoutLifecycleResetOrReopen(): void
    {
        [$adapter, $application] = $this->system();
        $set = $this->prerequisiteSet();
        $members = $this->members();
        $first = $adapter->evaluateSynthetic($set, $members);

        $observation = $application->observeInvalidation(
            $first['logical_record_identity'],
            CommonAuthorityEvidenceContract::INVALIDATION_REVOCATION,
        );
        $afterInvalidation = $adapter->evaluateSynthetic($set, $members);

        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::INVALIDATED, $observation['resolution']);
        self::assertTrue($observation['dependent_projection_invalidated']);
        self::assertFalse($observation['lifecycle_reset']);
        self::assertFalse($observation['reopened']);
        self::assertFalse($observation['new_aggregate_created']);
        self::assertSame(RuntimeReadinessDerivedEvaluator::READINESS_READY, $afterInvalidation['readiness_classification']);
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::INVALIDATED, $afterInvalidation['projection_read_disposition']);
        self::assertFalse($afterInvalidation['materialized_projection_usable']);
    }

    public function testSixIp13bOperationFamiliesRemainConformantForRr03(): void
    {
        $record = $this->rr03Record();
        $reference = new InMemoryLogicalPersistenceRepositoryContract();
        $sqlite = new SqliteInMemoryLogicalPersistenceAdapter();
        $query = $this->queryFor($record);

        $pairs = [
            LogicalPersistenceAdapterConformanceContract::OPERATION_STORE => [
                $reference->store($record), $sqlite->store($record),
            ],
            LogicalPersistenceAdapterConformanceContract::OPERATION_READ_EXACT => [
                $reference->readExact($record['logical_record_identity']),
                $sqlite->readExact($record['logical_record_identity']),
            ],
            LogicalPersistenceAdapterConformanceContract::OPERATION_RESOLVE_CURRENT => [
                $reference->resolveCurrent($query), $sqlite->resolveCurrent($query),
            ],
            LogicalPersistenceAdapterConformanceContract::OPERATION_READ_HISTORY => [
                $reference->readHistory($query), $sqlite->readHistory($query),
            ],
            LogicalPersistenceAdapterConformanceContract::OPERATION_PRIVACY_MINIMAL_PROJECTION => [
                $reference->privacyMinimalProjection($record['logical_record_identity']),
                $sqlite->privacyMinimalProjection($record['logical_record_identity']),
            ],
        ];

        foreach ($pairs as $operation => [$referenceResult, $candidateResult]) {
            self::assertSame(
                LogicalPersistenceAdapterConformanceContract::CONFORMANT,
                LogicalPersistenceAdapterConformanceContract::evaluate(
                    $operation,
                    $referenceResult,
                    $candidateResult,
                )['classification'],
                $operation,
            );
            self::assertSame(
                $referenceResult['record']['derived_projection_payload']
                    ?? $referenceResult['records'][0]['derived_projection_payload']
                    ?? null,
                $candidateResult['record']['derived_projection_payload']
                    ?? $candidateResult['records'][0]['derived_projection_payload']
                    ?? null,
            );
        }

        $referenceInvalidation = $reference->observeInvalidation(
            $record['logical_record_identity'],
            CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
        );
        $candidateInvalidation = $sqlite->observeInvalidation(
            $record['logical_record_identity'],
            CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
        );
        self::assertSame(
            LogicalPersistenceAdapterConformanceContract::CONFORMANT,
            LogicalPersistenceAdapterConformanceContract::evaluate(
                LogicalPersistenceAdapterConformanceContract::OPERATION_OBSERVE_INVALIDATION,
                $referenceInvalidation,
                $candidateInvalidation,
            )['classification'],
        );
        self::assertTrue($candidateInvalidation['record']['derived_projection_payload']['invalidation']['invalidated']);
        self::assertSame($record['logical_record_identity'], $candidateInvalidation['record']['derived_projection_payload']['invalidation']['dependency_identity']);
    }

    public function testIp13bRejectsSemanticMutationAndPrivateAuthorityButKeepsIncompleteEvidenceUnknown(): void
    {
        $record = $this->rr03Record();
        $referenceRepository = new InMemoryLogicalPersistenceRepositoryContract();
        $candidateRepository = new SqliteInMemoryLogicalPersistenceAdapter();
        $referenceRepository->store($record);
        $candidateRepository->store($record);
        $reference = $referenceRepository->readExact($record['logical_record_identity']);
        $candidate = $candidateRepository->readExact($record['logical_record_identity']);

        $mutated = $candidate;
        $mutated['record']['derived_projection_payload']['classification'] = RuntimeReadinessDerivedEvaluator::READINESS_UNKNOWN;
        self::assertSame(
            LogicalPersistenceAdapterConformanceContract::NON_CONFORMANT,
            LogicalPersistenceAdapterConformanceContract::evaluate(
                LogicalPersistenceAdapterConformanceContract::OPERATION_READ_EXACT,
                $reference,
                $mutated,
            )['classification'],
        );

        $incomplete = $candidate;
        unset($incomplete['record']['derived_projection_payload']);
        self::assertSame(
            LogicalPersistenceAdapterConformanceContract::UNKNOWN,
            LogicalPersistenceAdapterConformanceContract::evaluate(
                LogicalPersistenceAdapterConformanceContract::OPERATION_READ_EXACT,
                $reference,
                $incomplete,
            )['classification'],
        );

        $private = $candidate;
        $private['credential'] = self::PRIVATE_SENTINEL;
        self::assertSame(
            LogicalPersistenceAdapterConformanceContract::NON_CONFORMANT,
            LogicalPersistenceAdapterConformanceContract::evaluate(
                LogicalPersistenceAdapterConformanceContract::OPERATION_READ_EXACT,
                $reference,
                $private,
            )['classification'],
        );

        $authority = $candidate;
        $authority['record']['source_authority'] = true;
        self::assertSame(
            LogicalPersistenceAdapterConformanceContract::NON_CONFORMANT,
            LogicalPersistenceAdapterConformanceContract::evaluate(
                LogicalPersistenceAdapterConformanceContract::OPERATION_READ_EXACT,
                $reference,
                $authority,
            )['classification'],
        );
    }

    public function testRr03ValidationIsStrictAndNonRr03BehaviorRemainsCompatible(): void
    {
        $record = $this->rr03Record();
        $malformed = $record;
        $malformed['derived_projection_payload']['unexpected'] = true;
        $repository = new InMemoryLogicalPersistenceRepositoryContract();
        self::assertSame(
            InMemoryLogicalPersistenceRepositoryContract::INVALID_RECORD_REJECTED,
            $repository->store($malformed)['storage_outcome'],
        );

        $generic = $this->genericRecord();
        $genericWithNull = $generic;
        $genericWithNull['derived_projection_payload'] = null;
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::STORED_NEW, $repository->store($generic)['storage_outcome']);
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::EXACT_DUPLICATE, $repository->store($genericWithNull)['storage_outcome']);
        self::assertArrayNotHasKey(
            'derived_projection_payload',
            $repository->readExact($generic['logical_record_identity'])['record'],
        );

        $genericWithPayload = $generic;
        $genericWithPayload['logical_record_identity'] = 'generic-record-non-null-derived';
        $genericWithPayload['derived_projection_payload'] = $record['derived_projection_payload'];
        self::assertSame(
            InMemoryLogicalPersistenceRepositoryContract::INVALID_RECORD_REJECTED,
            $repository->store($genericWithPayload)['storage_outcome'],
        );
    }

    public function testMalformedOrNonSyntheticInputFailsBeforePersistence(): void
    {
        [$adapter, , $sqlite] = $this->system();
        $set = $this->prerequisiteSet();
        $set['synthetic_fixture'] = 'REAL_OR_UNMARKED';

        try {
            $adapter->evaluateSynthetic($set, $this->members());
            self::fail('Expected non-synthetic input rejection.');
        } catch (InvalidArgumentException) {
            self::assertSame(0, $sqlite->count());
        }
    }

    /** @return array{RuntimeReadinessPersistenceApplicationAdapter, PersistenceBoundaryApplicationInterfaceIntegrationContract, SqliteInMemoryLogicalPersistenceAdapter} */
    private function system(): array
    {
        $sqlite = new SqliteInMemoryLogicalPersistenceAdapter();
        $application = new PersistenceBoundaryApplicationInterfaceIntegrationContract($sqlite);

        return [new RuntimeReadinessPersistenceApplicationAdapter($application), $application, $sqlite];
    }

    /** @param list<string> $requiredMemberIds @return array<string, mixed> */
    private function prerequisiteSet(
        string $state = RuntimeReadinessDerivedEvaluator::SET_KNOWN,
        array $requiredMemberIds = ['synthetic-member-b', 'synthetic-member-a'],
    ): array {
        $bindings = $this->bindings('SYNTHETIC_SET_SOURCE', 'SYNTHETIC_SET_SCOPE', 'synthetic-set-lifecycle');

        return [
            'synthetic_fixture' => RuntimeReadinessPersistenceApplicationAdapter::SYNTHETIC_FIXTURE_MARKER,
            'state' => $state,
            'set_identity' => 'synthetic-prerequisite-set',
            'required_member_ids' => $requiredMemberIds,
            'protected_use_scope' => 'SYNTHETIC_RUNTIME_READINESS_USE',
            'required_bindings' => $bindings,
            'source_evidence' => CommonAuthorityEvidenceContract::evidence(
                $bindings,
                CommonAuthorityEvidenceContract::CONDITION_PRESENT,
                CommonAuthorityEvidenceContract::sourceRevision(
                    'SYNTHETIC_SET_SOURCE',
                    'SYNTHETIC_SET_SCOPE',
                    'synthetic-set-lineage',
                    'synthetic-runtime-context',
                    3,
                ),
                true,
                true,
            ),
            'private_fixture_extensions' => ['raw_fixture' => self::PRIVATE_SENTINEL],
        ];
    }

    /** @return list<array<string, mixed>> */
    private function members(): array
    {
        return [
            $this->member('synthetic-member-b', RuntimeReadinessDerivedEvaluator::FACT_VERIFICATION, 7),
            $this->member('synthetic-member-a', RuntimeReadinessDerivedEvaluator::FACT_ELIGIBILITY, 2),
            $this->member('unselected-member', RuntimeReadinessDerivedEvaluator::FACT_CHECKLIST, 99),
        ];
    }

    /** @return array<string, mixed> */
    private function member(string $identity, string $factClass, int $revisionValue): array
    {
        $owner = 'SYNTHETIC_MEMBER_SOURCE_'.$identity;
        $scope = 'SYNTHETIC_MEMBER_SCOPE_'.$identity;
        $bindings = $this->bindings($owner, $scope, 'lifecycle-'.$identity);

        return [
            'synthetic_fixture' => RuntimeReadinessPersistenceApplicationAdapter::SYNTHETIC_FIXTURE_MARKER,
            'member_identity' => $identity,
            'fact_class' => $factClass,
            'protected_use_scope' => 'SYNTHETIC_RUNTIME_READINESS_USE',
            'required_bindings' => $bindings,
            'source_evidence' => CommonAuthorityEvidenceContract::evidence(
                $bindings,
                CommonAuthorityEvidenceContract::CONDITION_PRESENT,
                CommonAuthorityEvidenceContract::sourceRevision(
                    $owner,
                    $scope,
                    'lineage-'.$identity,
                    'synthetic-runtime-context',
                    $revisionValue,
                ),
                true,
                true,
            ),
            'prerequisite_outcome' => RuntimeReadinessDerivedEvaluator::OUTCOME_SATISFIED,
            'private_fixture_extensions' => ['raw_fixture' => self::PRIVATE_SENTINEL.'-'.$identity],
        ];
    }

    /** @return array<string, mixed> */
    private function bindings(string $owner, string $scope, string $lifecycleIdentity): array
    {
        return [
            'authority_owner' => $owner,
            'authority_scope' => $scope,
            'actor' => 'synthetic-actor',
            'actor_role' => 'synthetic-role',
            'subject' => 'synthetic-subject',
            'participants' => ['synthetic-participant'],
            'audience' => 'synthetic-audience',
            'purpose' => 'SYNTHETIC_RUNTIME_READINESS_USE',
            'aggregate_context' => 'synthetic-runtime-context',
            'lifecycle_identity' => $lifecycleIdentity,
            'terminal' => false,
        ];
    }

    /** @return array<string, mixed> */
    private function rr03Record(): array
    {
        [$adapter] = $this->system();
        $set = $this->prerequisiteSet();
        $members = $this->members();
        $derived = RuntimeReadinessDerivedEvaluator::derive($set, $members);
        $buildPayload = new ReflectionMethod($adapter, 'buildPayload');
        $payload = $buildPayload->invoke($adapter, $derived, $set, $members);
        $buildRecord = new ReflectionMethod($adapter, 'buildRecord');

        return $buildRecord->invoke($adapter, $payload, $set);
    }

    /** @param array<string, mixed> $record @return array<string, mixed> */
    private function queryFor(array $record): array
    {
        return [
            'record_family' => $record['record_family'],
            'authority_owner' => $record['bindings']['authority_owner'],
            'authority_scope' => $record['bindings']['authority_scope'],
            'aggregate_context' => $record['bindings']['aggregate_context'],
            'lineage' => $record['source_revision']['lineage'],
        ];
    }

    /** @return array<string, mixed> */
    private function genericRecord(): array
    {
        $bindings = $this->bindings('GENERIC_SOURCE', 'GENERIC_SCOPE', 'generic-lifecycle');

        return [
            'logical_record_identity' => 'generic-record',
            'record_family' => 'GENERIC_SYNTHETIC_RECORD',
            'bindings' => $bindings,
            'source_revision' => CommonAuthorityEvidenceContract::sourceRevision(
                'GENERIC_SOURCE', 'GENERIC_SCOPE', 'generic-lineage', 'synthetic-runtime-context', 1,
            ),
            'source_condition' => CommonAuthorityEvidenceContract::CONDITION_PRESENT,
            'currentness' => true,
            'freshness' => true,
            'logical_intent' => [
                'intent_identity' => 'generic-intent',
                'semantic_input' => ['synthetic' => true],
            ],
            'authoritative_outcome' => CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN,
            'authoritative_outcome_metadata' => null,
            'correction_metadata' => null,
            'projection_metadata' => [
                'projection_identity' => 'generic-projection',
                'represented_source_revision_value' => 1,
                'lag_classification' => 'CURRENT',
                'projection_currentness' => true,
            ],
            'transport_observation' => 'AMBIGUOUS',
            'private_fixture_extensions' => [],
        ];
    }

    /** @return list<string> */
    private function mandatoryNonAuthorityFields(): array
    {
        return [
            'source_authority', 'domain_writer_authority', 'authoritative_mutation_success',
            'permission', 'permission_token', 'bearer_capability', 'authentication_authority',
            'transport_execution_authority', 'http_semantics', 'controller_authority', 'route_authority',
            'production_ready', 'deployable', 'real_data_authorized', 'match_authority',
            'connection_authority', 'consent_authority', 'conversation_authority',
            'relationship_authority', 'launch_authority',
        ];
    }
}
