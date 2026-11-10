<?php

namespace Tests\Unit;

use App\Domain\CommonAuthorityEvidenceContract as CommonContract;
use App\Domain\InMemoryLogicalPersistenceRepositoryContract as Repository;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

final class InMemoryLogicalPersistenceRepositoryContractTest extends TestCase
{
    public function testStoreIsNonAuthoritativeAndDoesNotMutateInput(): void
    {
        $repository = new Repository();
        $record = $this->record();
        $before = $record;

        $stored = $repository->store($record);

        self::assertSame(Repository::STORED_NEW, $stored['storage_outcome']);
        self::assertSame($before, $record);
        self::assertTrue($stored['stored']);
        self::assertFalse($stored['source_authority']);
        self::assertFalse($stored['authoritative_mutation_success']);
        self::assertFalse($stored['permission']);
        self::assertFalse($stored['domain_success']);
    }

    public function testExactDuplicateIsIdempotentWithoutDuplicatingHistory(): void
    {
        $repository = new Repository();
        $record = $this->record();

        self::assertSame(Repository::STORED_NEW, $repository->store($record)['storage_outcome']);
        $duplicate = $repository->store($record);
        $history = $repository->readHistory($this->query());

        self::assertSame(Repository::EXACT_DUPLICATE, $duplicate['storage_outcome']);
        self::assertTrue($duplicate['idempotent_correlation']);
        self::assertFalse($duplicate['permission']);
        self::assertFalse($duplicate['success']);
        self::assertCount(1, $history['records']);
        self::assertSame(1, $repository->count());
    }

    public function testChangedSemanticInputCannotReuseIntentIdentity(): void
    {
        $repository = new Repository();
        $first = $this->record(intentIdentity: 'synthetic-intent-fixed', intentValue: 'synthetic-value-A');
        $changed = $this->record(
            identity: 'synthetic-record-B',
            revision: 2,
            intentIdentity: 'synthetic-intent-fixed',
            intentValue: 'synthetic-value-B',
        );

        $repository->store($first);
        $result = $repository->store($changed);

        self::assertSame(Repository::CHANGED_INPUT_REUSE_REJECTED, $result['storage_outcome']);
        self::assertFalse($result['stored']);
        self::assertSame(1, $repository->count());
    }

    public function testSameLogicalIdentityWithAnyChangedSemanticInputIsRejected(): void
    {
        $repository = new Repository();
        $record = $this->record();
        $changed = $record;
        $changed['freshness'] = false;

        $repository->store($record);
        $result = $repository->store($changed);

        self::assertSame(Repository::CHANGED_INPUT_REUSE_REJECTED, $result['storage_outcome']);
        self::assertFalse($result['stored']);
        self::assertSame(1, $repository->count());
    }

    public function testSameLineageNewerRevisionResolvesIndependentOfStoreOrder(): void
    {
        $older = $this->record(identity: 'synthetic-record-older', revision: 1);
        $newer = $this->record(identity: 'synthetic-record-newer', revision: 2);
        $forward = new Repository();
        $reverse = new Repository();

        $forward->store($older);
        $forward->store($newer);
        $reverse->store($newer);
        $reverse->store($older);

        $forwardResolution = $forward->resolveCurrent($this->query());
        $reverseResolution = $reverse->resolveCurrent($this->query());

        self::assertSame(Repository::RESOLVED, $forwardResolution['resolution']);
        self::assertSame('synthetic-record-newer', $forwardResolution['record']['logical_record_identity']);
        self::assertSame($forwardResolution, $reverseResolution);
        self::assertFalse($forwardResolution['last_write_wins']);
        self::assertFalse($forwardResolution['last_received_wins']);
    }

    public function testEqualRevisionDuplicateDeduplicatesAndConflictFailsClosed(): void
    {
        $repository = new Repository();
        $record = $this->record();
        $conflict = $this->record(
            identity: 'synthetic-record-conflict',
            intentIdentity: 'synthetic-intent-conflict',
            intentValue: 'synthetic-conflicting-value',
        );

        $repository->store($record);

        self::assertSame(Repository::EXACT_DUPLICATE, $repository->store($record)['storage_outcome']);
        self::assertSame(
            Repository::CONFLICTING_EQUAL_REVISION_REJECTED,
            $repository->store($conflict)['storage_outcome'],
        );
        self::assertSame(1, $repository->count());
    }

    public function testCrossLineageRecordsCoexistButResolveAsIncomparableWithoutExactLineage(): void
    {
        $repository = new Repository();
        $repository->store($this->record());
        $second = $repository->store($this->record(
            identity: 'synthetic-record-lineage-B',
            lineage: 'synthetic-lineage-B',
        ));

        $broad = $repository->resolveCurrent($this->query(lineage: null));
        $exact = $repository->resolveCurrent($this->query());

        self::assertSame(Repository::INCOMPARABLE_COEXISTS, $second['storage_outcome']);
        self::assertSame(Repository::INCOMPARABLE, $broad['resolution']);
        self::assertNull($broad['record']);
        self::assertSame(Repository::RESOLVED, $exact['resolution']);
    }

    public function testCrossAuthorityScopeAndContextRecordsAreIncomparable(): void
    {
        foreach ([
            'authority' => $this->record(identity: 'synthetic-record-authority-B', owner: 'synthetic-owner-B'),
            'scope' => $this->record(identity: 'synthetic-record-scope-B', scope: 'synthetic-scope-B'),
            'context' => $this->record(identity: 'synthetic-record-context-B', context: 'synthetic-context-B'),
        ] as $record) {
            $repository = new Repository();
            $repository->store($this->record());
            self::assertSame(Repository::INCOMPARABLE_COEXISTS, $repository->store($record)['storage_outcome']);
        }
    }

    public function testNoGlobalRevisionIsSynthesized(): void
    {
        $repository = new Repository();
        $repository->store($this->record());

        $result = [
            $repository->readExact('synthetic-record-A'),
            $repository->resolveCurrent($this->query()),
            $repository->readHistory($this->query()),
        ];

        self::assertFalse($this->containsKeyRecursively($result, 'global_revision'));
    }

    public function testUnknownAbsentAndMissingRemainDistinct(): void
    {
        $repository = new Repository();
        $unknown = $this->record(condition: CommonContract::CONDITION_UNKNOWN);
        $absent = $this->record(
            identity: 'synthetic-record-absent',
            context: 'synthetic-context-absent',
            lineage: 'synthetic-lineage-absent',
            condition: CommonContract::CONDITION_ABSENT,
        );
        $repository->store($unknown);
        $repository->store($absent);

        self::assertSame(Repository::UNKNOWN, $repository->resolveCurrent($this->query())['resolution']);
        self::assertSame(
            Repository::ABSENT,
            $repository->resolveCurrent($this->query(context: 'synthetic-context-absent', lineage: 'synthetic-lineage-absent'))['resolution'],
        );
        self::assertSame(Repository::MISSING, $repository->readExact('synthetic-record-missing')['resolution']);
    }

    public function testUnavailableAndMalformedRecordsFailClosed(): void
    {
        $repository = new Repository();
        $unavailable = $this->record(condition: CommonContract::CONDITION_UNAVAILABLE);
        $malformed = $this->record(identity: 'synthetic-record-malformed');
        unset($malformed['source_revision']);

        $repository->store($unavailable);
        $rejected = $repository->store($malformed);

        self::assertSame(Repository::UNAVAILABLE, $repository->resolveCurrent($this->query())['resolution']);
        self::assertSame(Repository::INVALID_RECORD_REJECTED, $rejected['storage_outcome']);
        self::assertFalse($rejected['stored']);
    }

    public function testStaleAndSupersededRemainDistinct(): void
    {
        $repository = new Repository();
        $repository->store($this->record(condition: CommonContract::CONDITION_STALE));
        $repository->store($this->record(
            identity: 'synthetic-record-superseded',
            context: 'synthetic-context-superseded',
            lineage: 'synthetic-lineage-superseded',
            condition: CommonContract::CONDITION_SUPERSEDED,
        ));

        self::assertSame(Repository::STALE, $repository->resolveCurrent($this->query())['resolution']);
        self::assertSame(
            Repository::SUPERSEDED,
            $repository->resolveCurrent($this->query(context: 'synthetic-context-superseded', lineage: 'synthetic-lineage-superseded'))['resolution'],
        );
    }

    public function testCurrentnessAndFreshnessRemainIndependentAndFailClosed(): void
    {
        $currentStale = new Repository();
        $freshNotCurrent = new Repository();
        $currentStale->store($this->record(currentness: true, freshness: false));
        $freshNotCurrent->store($this->record(currentness: false, freshness: true));

        $staleResult = $currentStale->resolveCurrent($this->query());
        $notCurrentResult = $freshNotCurrent->resolveCurrent($this->query());

        self::assertSame(Repository::STALE, $staleResult['resolution']);
        self::assertTrue($staleResult['record']['currentness']);
        self::assertFalse($staleResult['record']['freshness']);
        self::assertSame(Repository::UNKNOWN, $notCurrentResult['resolution']);
        self::assertFalse($notCurrentResult['record']['currentness']);
        self::assertTrue($notCurrentResult['record']['freshness']);
    }

    #[DataProvider('invalidationProvider')]
    public function testInvalidationDisablesProjectionWithoutLifecycleReset(string $relation): void
    {
        $repository = new Repository();
        $repository->store($this->record(terminal: true));

        $observed = $repository->observeInvalidation('synthetic-record-A', $relation);
        $read = $repository->readExact('synthetic-record-A');

        self::assertSame(Repository::INVALIDATED, $observed['resolution']);
        self::assertTrue($read['record']['projection_invalidated']);
        self::assertSame($relation, $read['record']['invalidation_relation']);
        self::assertTrue($read['record']['terminal']);
        self::assertFalse($read['record']['lifecycle_reset']);
        self::assertFalse($read['record']['reopened']);
        self::assertFalse($read['record']['new_aggregate_created']);
        self::assertFalse($read['record']['transition_synthesized']);
    }

    /** @return iterable<string, array{string}> */
    public static function invalidationProvider(): iterable
    {
        yield 'correction' => [CommonContract::INVALIDATION_CORRECTION];
        yield 'revocation' => [CommonContract::INVALIDATION_REVOCATION];
        yield 'supersession' => [CommonContract::INVALIDATION_SUPERSESSION];
    }

    public function testTerminalIdentityCannotReopenAndFreshLifecycleUsesDistinctIdentity(): void
    {
        $repository = new Repository();
        $repository->store($this->record(terminal: true));
        $reopen = $this->record(
            identity: 'synthetic-record-reopen',
            revision: 2,
            terminal: false,
            intentIdentity: 'synthetic-intent-reopen',
        );
        $freshLifecycle = $this->record(
            identity: 'synthetic-record-fresh-lifecycle',
            context: 'synthetic-context-fresh',
            lineage: 'synthetic-lineage-fresh',
            lifecycleIdentity: 'synthetic-lifecycle-fresh',
            intentIdentity: 'synthetic-intent-fresh',
        );

        $rejected = $repository->store($reopen);
        $accepted = $repository->store($freshLifecycle);

        self::assertSame(Repository::INVALID_RECORD_REJECTED, $rejected['storage_outcome']);
        self::assertSame('TERMINAL_IDENTITY_REOPEN_REJECTED', $rejected['reason']);
        self::assertSame(Repository::INCOMPARABLE_COEXISTS, $accepted['storage_outcome']);
    }

    public function testAuthoritativeOutcomeMetadataIsCarriedButNeverInventedByStorage(): void
    {
        $repository = new Repository();
        $committed = $this->record(
            outcome: CommonContract::OUTCOME_COMMITTED,
            authoritativeMetadata: [
                'source_carried' => true,
                'outcome_reference' => 'synthetic-authoritative-outcome-A',
            ],
        );
        $repository->store($committed);

        $projection = $repository->privacyMinimalProjection('synthetic-record-A');

        self::assertSame(CommonContract::OUTCOME_COMMITTED, $projection['record']['authoritative_outcome']);
        self::assertSame('synthetic-authoritative-outcome-A', $projection['record']['authoritative_outcome_reference']);
        self::assertTrue($projection['record']['authoritative_outcome_source_carried']);
        self::assertFalse($projection['authoritative_mutation_success']);

        $withoutOutcome = new Repository();
        $withoutOutcome->store($this->record());
        $unknownProjection = $withoutOutcome->privacyMinimalProjection('synthetic-record-A');
        self::assertSame(CommonContract::OUTCOME_UNKNOWN, $unknownProjection['record']['authoritative_outcome']);
        self::assertFalse($unknownProjection['record']['authoritative_outcome_source_carried']);
        self::assertNull($unknownProjection['record']['authoritative_outcome_reference']);
    }

    public function testTransportObservationNeverBecomesDomainOutcome(): void
    {
        $repository = new Repository();
        $repository->store($this->record(transportObservation: 'ACKNOWLEDGED'));

        $projection = $repository->privacyMinimalProjection('synthetic-record-A');

        self::assertSame('ACKNOWLEDGED', $projection['record']['transport_observation']);
        self::assertSame(CommonContract::OUTCOME_UNKNOWN, $projection['record']['transport_authoritative_outcome']);
        self::assertFalse($projection['record']['transport_is_domain_outcome']);
        self::assertFalse($projection['domain_success']);
    }

    public function testProjectionLagIsExplicitAndPrivateFixtureMaterialIsOmitted(): void
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
            'analytics_signal' => 'synthetic-private-MUST-NOT-LEAK',
        ];
        $repository->store($record);

        $projection = $repository->privacyMinimalProjection('synthetic-record-A');
        $encoded = json_encode($projection);

        self::assertIsString($encoded);
        self::assertStringNotContainsString('MUST-NOT-LEAK', $encoded);
        self::assertStringNotContainsString('conversation_content', $encoded);
        self::assertSame('LAGGED', $projection['record']['projection_lag']);
        self::assertFalse($projection['record']['projection_currentness']);
        self::assertFalse($projection['record']['projection_authority']);
    }

    public function testRepositoryCreatesNoDomainOrLaunchAuthority(): void
    {
        $repository = new Repository();
        $repository->store($this->record());
        $result = $repository->resolveCurrent($this->query());

        foreach ([
            'source_authority', 'authoritative_mutation_success', 'readiness_authority',
            'match_authority', 'connection_authority', 'consent_authority',
            'conversation_authority', 'relationship_authority', 'home_action_authority',
            'notification_delivery_authority', 'launch_authority', 'permission', 'domain_success',
        ] as $key) {
            self::assertFalse($result[$key], $key);
        }
    }

    public function testRepositoryCreatesNoPhysicalPersistenceOrConcurrencySemantics(): void
    {
        $repository = new Repository();
        $result = $repository->store($this->record());

        foreach ([
            'sql_selected', 'nosql_selected', 'sqlite_selected', 'eloquent_selected',
            'schema_selected', 'database_connection_selected', 'filesystem_persistence_selected',
            'cache_selected', 'transaction_semantics', 'lock_semantics', 'cas_semantics',
            'isolation_semantics', 'queue_semantics', 'api_semantics',
        ] as $key) {
            self::assertFalse($result[$key], $key);
        }
    }

    public function testRepeatedReadsAreDeterministic(): void
    {
        $repository = new Repository();
        $repository->store($this->record());

        self::assertSame(
            $repository->resolveCurrent($this->query()),
            $repository->resolveCurrent($this->query()),
        );
        self::assertSame(
            $repository->readExact('synthetic-record-A'),
            $repository->readExact('synthetic-record-A'),
        );
    }

    public function testHistoryIsBoundedToExactAuthorityScopeLineageAndContext(): void
    {
        $repository = new Repository();
        $repository->store($this->record(identity: 'synthetic-record-newer', revision: 2));
        $repository->store($this->record(identity: 'synthetic-record-older', revision: 1));
        $repository->store($this->record(
            identity: 'synthetic-record-other-lineage',
            lineage: 'synthetic-lineage-other',
        ));

        $history = $repository->readHistory($this->query());
        $other = $repository->readHistory($this->query(lineage: 'synthetic-lineage-missing'));

        self::assertSame([1, 2], array_column($history['records'], 'source_revision_value'));
        self::assertCount(2, $history['records']);
        self::assertSame(Repository::MISSING, $other['resolution']);
        self::assertSame([], $other['records']);
    }

    /** @return array<string, mixed> */
    private function record(
        string $identity = 'synthetic-record-A',
        int $revision = 1,
        string $lineage = 'synthetic-lineage-A',
        string $owner = 'synthetic-owner-A',
        string $scope = 'synthetic-scope-A',
        string $context = 'synthetic-context-A',
        string $condition = CommonContract::CONDITION_PRESENT,
        ?bool $currentness = true,
        ?bool $freshness = true,
        ?string $intentIdentity = null,
        ?string $intentValue = null,
        bool $terminal = false,
        string $lifecycleIdentity = 'synthetic-lifecycle-A',
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
                'authority_owner' => $owner,
                'authority_scope' => $scope,
                'actor' => 'synthetic-actor-A',
                'actor_role' => 'synthetic-role-A',
                'subject' => 'synthetic-subject-A',
                'participants' => ['synthetic-participant-A', 'synthetic-participant-B'],
                'audience' => 'synthetic-audience-A',
                'purpose' => 'synthetic-purpose-A',
                'aggregate_context' => $context,
                'lifecycle_identity' => $lifecycleIdentity,
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
        string $context = 'synthetic-context-A',
        ?string $lineage = 'synthetic-lineage-A',
    ): array {
        return [
            'record_family' => 'SYNTHETIC_LOGICAL_FAMILY',
            'authority_owner' => 'synthetic-owner-A',
            'authority_scope' => 'synthetic-scope-A',
            'aggregate_context' => $context,
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
