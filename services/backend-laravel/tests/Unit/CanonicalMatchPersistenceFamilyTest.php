<?php

namespace Tests\Unit;

use App\Domain\CommonAuthorityEvidenceContract;
use App\Domain\InMemoryLogicalPersistenceRepositoryContract;
use App\Domain\SqliteInMemoryLogicalPersistenceAdapter;
use PHPUnit\Framework\TestCase;

final class CanonicalMatchPersistenceFamilyTest extends TestCase
{
    public function test_valid_match_record_has_reference_sqlite_projection_and_physical_parity(): void
    {
        $record = $this->matchRecord(['source_participants' => ['synthetic-member-b', 'synthetic-member-a']]);
        $canonicalRecord = $this->matchRecord();

        self::assertSame($canonicalRecord, $record);

        [$reference, $sqlite] = $this->repositories();
        $referenceStore = $reference->store($record);
        $sqliteStore = $sqlite->store($record);

        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::STORED_NEW, $referenceStore['storage_outcome']);
        self::assertSame($referenceStore, $sqliteStore);

        $referenceExact = $reference->readExact($record['logical_record_identity']);
        $sqliteExact = $sqlite->readExact($record['logical_record_identity']);
        self::assertSame($referenceExact, $sqliteExact);
        self::assertSame($record['derived_projection_payload'], $referenceExact['record']['derived_projection_payload']);

        $query = $this->queryFor($record);
        self::assertSame($reference->resolveCurrent($query), $sqlite->resolveCurrent($query));
        self::assertSame($reference->readHistory($query), $sqlite->readHistory($query));
        self::assertSame(
            $reference->privacyMinimalProjection($record['logical_record_identity']),
            $sqlite->privacyMinimalProjection($record['logical_record_identity']),
        );

        $facts = $sqlite->physicalBoundaryFacts();
        self::assertSame('sqlite::memory:', $facts['dsn']);
        self::assertSame(['logical_invalidations', 'logical_records'], $facts['disposable_tables']);
        self::assertTrue($facts['schema_initialized']);
        self::assertFalse($facts['persistent_database']);
        self::assertFalse($facts['insertion_order_authority']);
        self::assertFalse($facts['sql_execution_order_authority']);
        self::assertFalse($facts['row_presence_is_source_authority']);
    }

    public function test_match_digest_authority_and_envelope_boundaries_reject_tampering(): void
    {
        $record = $this->matchRecord();
        $variants = [];

        foreach (['logical_record_identity', 'source_lineage', 'intent_identity', 'projection_identity'] as $field) {
            $candidate = $record;

            match ($field) {
                'logical_record_identity' => $candidate['logical_record_identity'] = 'canonical-match-record-v1:wrong',
                'source_lineage' => $candidate['source_revision']['lineage'] = 'canonical-match-lineage-v1:wrong',
                'intent_identity' => $candidate['logical_intent']['intent_identity'] = 'canonical-match-intent-v1:wrong',
                'projection_identity' => $candidate['projection_metadata']['projection_identity'] = 'canonical-match-projection-v1:wrong',
            };

            $variants[] = $candidate;
        }

        $semanticInput = $record;
        $semanticInput['logical_intent']['semantic_input']['schema_marker'] = 'wrong';
        $variants[] = $semanticInput;

        foreach ([
            ['bindings', 'authority_owner', 'WRONG_OWNER'],
            ['bindings', 'authority_scope', 'WRONG_SCOPE'],
            ['bindings', 'aggregate_context', 'wrong-context'],
            ['source_revision', 'authority_owner', 'WRONG_OWNER'],
            ['source_revision', 'value', 1],
        ] as [$container, $key, $value]) {
            $candidate = $record;
            $candidate[$container][$key] = $value;
            $variants[] = $candidate;
        }

        $wrongCondition = $record;
        $wrongCondition['source_condition'] = CommonAuthorityEvidenceContract::CONDITION_UNKNOWN;
        $variants[] = $wrongCondition;

        $wrongOutcome = $record;
        $wrongOutcome['authoritative_outcome'] = CommonAuthorityEvidenceContract::OUTCOME_COMMITTED;
        $variants[] = $wrongOutcome;

        $wrongCorrection = $record;
        $wrongCorrection['correction_metadata'] = [
            'relation' => CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
            'displaced_record_identity' => 'old',
        ];
        $variants[] = $wrongCorrection;

        $wrongTransport = $record;
        $wrongTransport['transport_observation'] = 'ACKNOWLEDGED';
        $variants[] = $wrongTransport;

        foreach ($variants as $candidate) {
            $this->assertBothReject($candidate);
        }
    }

    public function test_reason_dependency_ordering_and_collision_rules_are_exact(): void
    {
        $record = $this->matchRecord();

        $unknownReason = $record;
        $unknownReason['derived_projection_payload']['reason_categories'] = ['NOT_ALLOWED'];
        $this->assertBothReject($this->resign($unknownReason));

        $preMaterializationReason = $record;
        $preMaterializationReason['derived_projection_payload']['reason_categories'] = ['INVALID_PROPOSAL_SHAPE'];
        $this->assertBothReject($this->resign($preMaterializationReason));

        $duplicateReasons = $record;
        $duplicateReasons['derived_projection_payload']['reason_categories'] = [
            'MISSING_PARTICIPATION',
            'MISSING_PARTICIPATION',
        ];
        $this->assertBothReject($this->resign($duplicateReasons));

        $outOfOrderReasons = $record;
        $outOfOrderReasons['derived_projection_payload']['reason_categories'] = [
            'MISSING_PARTICIPATION',
            'PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE',
        ];
        $this->assertBothReject($this->resign($outOfOrderReasons));

        $badProposal = $record;
        $badProposal['derived_projection_payload']['proposal_dependency']['lifecycle_state'] = 'BROKEN';
        $this->assertBothReject($this->resign($badProposal));

        $outOfOrderParticipation = $record;
        $outOfOrderParticipation['derived_projection_payload']['participation_dependencies'] = array_reverse(
            $outOfOrderParticipation['derived_projection_payload']['participation_dependencies'],
        );
        $this->assertBothReject($this->resign($outOfOrderParticipation));

        $outOfOrderSlots = $record;
        $outOfOrderSlots['derived_projection_payload']['decision_slot_dependencies'] = array_reverse(
            $outOfOrderSlots['derived_projection_payload']['decision_slot_dependencies'],
        );
        $this->assertBothReject($this->resign($outOfOrderSlots));

        $collision = $record;
        $collision['derived_projection_payload']['decision_slot_dependencies'][0]['slot_identity'] = 'synthetic-proposal';
        $this->assertBothReject($this->resign($collision));
    }

    public function test_currentness_freshness_completeness_and_terminal_source_rules_are_exact(): void
    {
        $mismatch = $this->matchRecord();
        $mismatch['currentness'] = false;
        $this->assertBothReject($this->resign($mismatch));

        $partial = $this->matchRecord();
        array_pop($partial['derived_projection_payload']['participation_dependencies']);
        $partial['derived_projection_payload']['decision_slot_dependencies'] = [];
        $partial['derived_projection_payload']['classification'] = 'UNKNOWN';
        $partial['derived_projection_payload']['reason_categories'] = ['MISSING_PARTICIPATION'];
        $partial['currentness'] = null;
        $partial['freshness'] = null;
        $partial = $this->resign($partial);
        $this->assertBothStore($partial, InMemoryLogicalPersistenceRepositoryContract::STORED_NEW);

        $terminalSource = $this->terminalSourceRecord();
        $this->assertBothStore($terminalSource, InMemoryLogicalPersistenceRepositoryContract::STORED_NEW);

        $terminalWithParticipation = $terminalSource;
        $terminalWithParticipation['derived_projection_payload']['participation_dependencies'][] =
            $this->matchRecord()['derived_projection_payload']['participation_dependencies'][0];
        $this->assertBothReject($this->resign($terminalWithParticipation));
    }

    public function test_sticky_terminality_and_dependency_invalidation_are_exact(): void
    {
        $terminal = $this->terminalDerivedRecord();
        $this->assertBothStore($terminal, InMemoryLogicalPersistenceRepositoryContract::STORED_NEW);

        $invalidated = $this->stickyInvalidatedRecord();
        $this->assertBothStore($invalidated, InMemoryLogicalPersistenceRepositoryContract::STORED_NEW);

        $terminalFalse = $invalidated;
        $terminalFalse['derived_projection_payload']['terminality']['derived_terminal'] = false;
        $terminalFalse['bindings']['terminal'] = false;
        $this->assertBothReject($this->resign($terminalFalse));

        $missingPrior = $invalidated;
        $missingPrior['derived_projection_payload']['terminality']['classification_before_invalidation'] = null;
        $this->assertBothReject($this->resign($missingPrior));

        $wrongIdentity = $invalidated;
        $wrongIdentity['derived_projection_payload']['invalidation']['dependency_identity'] = 'not-a-dependency';
        $this->assertBothReject($this->resign($wrongIdentity));

        $wrongRelation = $invalidated;
        $wrongRelation['derived_projection_payload']['invalidation']['relation'] = 'DELETE';
        $this->assertBothReject($this->resign($wrongRelation));

        $nonInvalidatedPrior = $this->matchRecord();
        $nonInvalidatedPrior['derived_projection_payload']['terminality']['classification_before_invalidation'] = 'PENDING';
        $this->assertBothReject($this->resign($nonInvalidatedPrior));
    }

    public function test_duplicate_incomparable_exact_lineage_and_terminal_guards_have_parity(): void
    {
        [$reference, $sqlite] = $this->repositories();
        $first = $this->matchRecord();

        self::assertSame($reference->store($first), $sqlite->store($first));
        $duplicateReference = $reference->store($first);
        $duplicateSqlite = $sqlite->store($first);
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::EXACT_DUPLICATE, $duplicateReference['storage_outcome']);
        self::assertSame($duplicateReference, $duplicateSqlite);
        self::assertTrue($duplicateReference['idempotent_correlation']);

        $second = $this->matchRecord();
        $second['derived_projection_payload']['decision_slot_dependencies'][1]['source_revision_value'] = 2;
        $second = $this->resign($second);
        $secondReference = $reference->store($second);
        $secondSqlite = $sqlite->store($second);
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::INCOMPARABLE_COEXISTS, $secondReference['storage_outcome']);
        self::assertSame($secondReference, $secondSqlite);
        self::assertNotSame($first['logical_record_identity'], $second['logical_record_identity']);
        self::assertNotSame($first['source_revision']['lineage'], $second['source_revision']['lineage']);
        self::assertSame(
            $second['logical_record_identity'],
            $reference->resolveCurrent($this->queryFor($second))['record']['logical_record_identity'],
        );
        self::assertSame(
            $reference->resolveCurrent($this->queryFor($second)),
            $sqlite->resolveCurrent($this->queryFor($second)),
        );

        foreach ($this->repositories() as $repository) {
            $terminal = $this->terminalDerivedRecord();
            self::assertSame(InMemoryLogicalPersistenceRepositoryContract::STORED_NEW, $repository->store($terminal)['storage_outcome']);
            self::assertSame(InMemoryLogicalPersistenceRepositoryContract::INVALID_RECORD_REJECTED, $repository->store($this->matchRecord())['storage_outcome']);
            self::assertSame(InMemoryLogicalPersistenceRepositoryContract::INCOMPARABLE_COEXISTS, $repository->store($this->stickyInvalidatedRecord())['storage_outcome']);
        }
    }

    public function test_generic_overlay_does_not_rewrite_match_dependency_invalidation(): void
    {
        foreach ($this->repositories() as $repository) {
            $ordinary = $this->matchRecord();
            $repository->store($ordinary);
            $ordinaryPayload = $ordinary['derived_projection_payload'];
            $overlay = $repository->observeInvalidation(
                $ordinary['logical_record_identity'],
                CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
            );
            self::assertSame(InMemoryLogicalPersistenceRepositoryContract::INVALIDATED, $overlay['resolution']);
            self::assertTrue($overlay['record']['projection_invalidated']);
            self::assertSame(CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION, $overlay['record']['invalidation_relation']);
            self::assertSame($ordinaryPayload, $overlay['record']['derived_projection_payload']);

            $dependencyInvalidated = $this->stickyInvalidatedRecord();
            $repository->store($dependencyInvalidated);
            $domainPayload = $dependencyInvalidated['derived_projection_payload'];
            $domainProjection = $repository->privacyMinimalProjection($dependencyInvalidated['logical_record_identity']);
            self::assertFalse($domainProjection['record']['projection_invalidated']);
            self::assertSame($domainPayload, $domainProjection['record']['derived_projection_payload']);
            self::assertSame(
                'synthetic-slot-a',
                $domainProjection['record']['derived_projection_payload']['invalidation']['dependency_identity'],
            );

            $domainOverlay = $repository->observeInvalidation(
                $dependencyInvalidated['logical_record_identity'],
                CommonAuthorityEvidenceContract::INVALIDATION_REVOCATION,
            );
            self::assertTrue($domainOverlay['record']['projection_invalidated']);
            self::assertSame(CommonAuthorityEvidenceContract::INVALIDATION_REVOCATION, $domainOverlay['record']['invalidation_relation']);
            self::assertSame($domainPayload, $domainOverlay['record']['derived_projection_payload']);
        }
    }

    public function test_rr03_overlay_and_generic_derived_payload_rules_are_unchanged(): void
    {
        foreach ($this->repositories() as $repository) {
            $rr03 = $this->rr03Record();
            self::assertSame(InMemoryLogicalPersistenceRepositoryContract::STORED_NEW, $repository->store($rr03)['storage_outcome']);
            $overlay = $repository->observeInvalidation(
                $rr03['logical_record_identity'],
                CommonAuthorityEvidenceContract::INVALIDATION_SUPERSESSION,
            );
            self::assertSame([
                'invalidated' => true,
                'relation' => CommonAuthorityEvidenceContract::INVALIDATION_SUPERSESSION,
                'dependency_identity' => $rr03['logical_record_identity'],
            ], $overlay['record']['derived_projection_payload']['invalidation']);

            $generic = $rr03;
            $generic['logical_record_identity'] = 'generic-record';
            $generic['record_family'] = 'GENERIC_FAMILY';
            self::assertSame(InMemoryLogicalPersistenceRepositoryContract::INVALID_RECORD_REJECTED, $repository->store($generic)['storage_outcome']);
        }
    }

    /** @return array{InMemoryLogicalPersistenceRepositoryContract, SqliteInMemoryLogicalPersistenceAdapter} */
    private function repositories(): array
    {
        return [
            new InMemoryLogicalPersistenceRepositoryContract(),
            new SqliteInMemoryLogicalPersistenceAdapter(),
        ];
    }

    /** @param array<string, mixed> $record */
    private function assertBothReject(array $record): void
    {
        foreach ($this->repositories() as $repository) {
            self::assertSame(
                InMemoryLogicalPersistenceRepositoryContract::INVALID_RECORD_REJECTED,
                $repository->store($record)['storage_outcome'],
            );
        }
    }

    /** @param array<string, mixed> $record */
    private function assertBothStore(array $record, string $expected): void
    {
        foreach ($this->repositories() as $repository) {
            self::assertSame($expected, $repository->store($record)['storage_outcome']);
        }
    }

    /** @param array<string, mixed> $options @return array<string, mixed> */
    private function matchRecord(array $options = []): array
    {
        $participants = $options['source_participants'] ?? ['synthetic-member-a', 'synthetic-member-b'];
        sort($participants, SORT_STRING);
        $proposalIdentity = 'synthetic-proposal';
        $scope = 'SYNTHETIC_MATCH_REVIEW';
        $proposal = $this->proposalDependency($proposalIdentity, 'PENDING', false);
        $participation = [
            $this->participationDependency($participants[0]),
            $this->participationDependency($participants[1]),
        ];
        $slots = [
            $this->slotDependency('synthetic-slot-a', $proposalIdentity, $participants[0], 'PENDING'),
            $this->slotDependency('synthetic-slot-b', $proposalIdentity, $participants[1], 'PENDING'),
        ];
        $payload = [
            'payload_kind' => 'CANONICAL_MATCH_PROPOSAL_DECISION',
            'derived_fact_class' => 'CANONICAL_MATCH_PROPOSAL_DECISION',
            'classification' => 'PENDING',
            'proposal_identity' => $proposalIdentity,
            'protected_use_scope' => $scope,
            'reason_categories' => [],
            'proposal_dependency' => $proposal,
            'participation_dependencies' => $participation,
            'decision_slot_dependencies' => $slots,
            'terminality' => [
                'source_proposal_terminal' => false,
                'derived_terminal' => false,
                'classification_before_invalidation' => null,
                'lifecycle_reset' => false,
                'proposal_reopened' => false,
            ],
            'invalidation' => [
                'invalidated' => false,
                'relation' => null,
                'dependency_identity' => null,
                'lifecycle_reset' => false,
                'proposal_reopened' => false,
            ],
        ];
        $bindings = [
            'authority_owner' => 'CANONICAL_MATCH_DERIVATION',
            'authority_scope' => 'CANONICAL_MATCH_PROPOSAL_DECISION|'.$scope,
            'actor' => 'synthetic-actor',
            'actor_role' => 'SYNTHETIC_REVIEWER',
            'subject' => 'synthetic-subject',
            'participants' => $participants,
            'audience' => 'SYNTHETIC_AUDIENCE',
            'purpose' => $scope,
            'aggregate_context' => $proposalIdentity,
            'lifecycle_identity' => '',
            'terminal' => false,
        ];
        $record = [
            'logical_record_identity' => '',
            'record_family' => InMemoryLogicalPersistenceRepositoryContract::RECORD_FAMILY_CANONICAL_MATCH,
            'bindings' => $bindings,
            'source_revision' => [
                'authority_owner' => 'CANONICAL_MATCH_DERIVATION',
                'authority_scope' => 'CANONICAL_MATCH_PROPOSAL_DECISION|'.$scope,
                'lineage' => '',
                'aggregate_context' => $proposalIdentity,
                'value' => 0,
            ],
            'source_condition' => CommonAuthorityEvidenceContract::CONDITION_PRESENT,
            'currentness' => true,
            'freshness' => true,
            'logical_intent' => [
                'intent_identity' => '',
                'semantic_input' => [],
            ],
            'authoritative_outcome' => CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN,
            'authoritative_outcome_metadata' => null,
            'correction_metadata' => null,
            'projection_metadata' => [
                'projection_identity' => '',
                'represented_source_revision_value' => 0,
                'lag_classification' => 'CURRENT',
                'projection_currentness' => true,
            ],
            'transport_observation' => 'AMBIGUOUS',
            'private_fixture_extensions' => [],
            'derived_projection_payload' => $payload,
        ];

        return $this->resign($record);
    }

    /** @return array<string, mixed> */
    private function terminalDerivedRecord(): array
    {
        $record = $this->matchRecord();
        $record['derived_projection_payload']['classification'] = 'MUTUALLY_ACCEPTED';
        $record['derived_projection_payload']['decision_slot_dependencies'][0]['decision'] = 'ACCEPTED';
        $record['derived_projection_payload']['decision_slot_dependencies'][1]['decision'] = 'ACCEPTED';
        $record['derived_projection_payload']['terminality']['derived_terminal'] = true;
        $record['bindings']['terminal'] = true;

        return $this->resign($record);
    }

    /** @return array<string, mixed> */
    private function stickyInvalidatedRecord(): array
    {
        $record = $this->terminalDerivedRecord();
        $record['derived_projection_payload']['classification'] = 'UNKNOWN';
        $record['derived_projection_payload']['reason_categories'] = ['DEPENDENCY_INVALIDATED'];
        $record['derived_projection_payload']['terminality']['classification_before_invalidation'] = 'MUTUALLY_ACCEPTED';
        $record['derived_projection_payload']['invalidation'] = [
            'invalidated' => true,
            'relation' => CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
            'dependency_identity' => 'synthetic-slot-a',
            'lifecycle_reset' => false,
            'proposal_reopened' => false,
        ];

        return $this->resign($record);
    }

    /** @return array<string, mixed> */
    private function terminalSourceRecord(): array
    {
        $record = $this->matchRecord();
        $record['derived_projection_payload']['classification'] = 'EXPIRED';
        $record['derived_projection_payload']['proposal_dependency'] =
            $this->proposalDependency('synthetic-proposal', 'EXPIRED', true);
        $record['derived_projection_payload']['participation_dependencies'] = [];
        $record['derived_projection_payload']['decision_slot_dependencies'] = [];
        $record['derived_projection_payload']['terminality']['source_proposal_terminal'] = true;
        $record['derived_projection_payload']['terminality']['derived_terminal'] = true;
        $record['bindings']['terminal'] = true;

        return $this->resign($record);
    }

    /** @return array<string, mixed> */
    private function proposalDependency(string $identity, string $state, bool $terminal): array
    {
        return [
            'proposal_identity' => $identity,
            'lifecycle_state' => $state,
            'terminal' => $terminal,
            'authority_owner' => 'PROPOSAL_SOURCE',
            'authority_scope' => 'PROPOSAL_SCOPE',
            'aggregate_context' => $identity,
            'source_lineage' => 'proposal-lineage',
            'source_revision_value' => 1,
            'source_condition' => CommonAuthorityEvidenceContract::CONDITION_PRESENT,
            'currentness' => true,
            'freshness' => true,
        ];
    }

    /** @return array<string, mixed> */
    private function participationDependency(string $participant): array
    {
        return [
            'participant_identity' => $participant,
            'state' => 'ENROLLED',
            'authority_owner' => 'PARTICIPATION_SOURCE',
            'authority_scope' => 'PARTICIPATION_SCOPE',
            'aggregate_context' => $participant,
            'source_lineage' => 'participation-lineage-'.$participant,
            'source_revision_value' => 1,
            'source_condition' => CommonAuthorityEvidenceContract::CONDITION_PRESENT,
            'currentness' => true,
            'freshness' => true,
        ];
    }

    /** @return array<string, mixed> */
    private function slotDependency(string $slot, string $proposal, string $participant, string $decision): array
    {
        return [
            'slot_identity' => $slot,
            'proposal_identity' => $proposal,
            'participant_identity' => $participant,
            'decision' => $decision,
            'authority_owner' => 'SLOT_SOURCE',
            'authority_scope' => 'SLOT_SCOPE',
            'aggregate_context' => $proposal,
            'source_lineage' => 'slot-lineage-'.$slot,
            'source_revision_value' => 1,
            'source_condition' => CommonAuthorityEvidenceContract::CONDITION_PRESENT,
            'currentness' => true,
            'freshness' => true,
        ];
    }

    /** @param array<string, mixed> $record @return array<string, mixed> */
    private function resign(array $record): array
    {
        $payload = $record['derived_projection_payload'];
        $bindings = $record['bindings'];
        $lifecycleBasis = [
            'record_family' => InMemoryLogicalPersistenceRepositoryContract::RECORD_FAMILY_CANONICAL_MATCH,
            'proposal_identity' => $payload['proposal_identity'],
            'protected_use_scope' => $payload['protected_use_scope'],
            'subject' => $bindings['subject'],
            'participants' => $bindings['participants'],
            'audience' => $bindings['audience'],
            'purpose' => $bindings['purpose'],
            'aggregate_context' => $bindings['aggregate_context'],
        ];
        $record['bindings']['lifecycle_identity'] = 'canonical-match-lifecycle-v1:'.$this->digest($lifecycleBasis);
        $semanticInput = [
            'record_family' => InMemoryLogicalPersistenceRepositoryContract::RECORD_FAMILY_CANONICAL_MATCH,
            'bindings' => $record['bindings'],
            'derived_projection_payload' => $payload,
            'schema_marker' => 'canonical-match-derived-projection-v1',
        ];
        $digest = $this->digest($semanticInput);
        $record['logical_record_identity'] = 'canonical-match-record-v1:'.$digest;
        $record['logical_intent'] = [
            'intent_identity' => 'canonical-match-intent-v1:'.$digest,
            'semantic_input' => $semanticInput,
        ];
        $record['source_revision']['lineage'] = 'canonical-match-lineage-v1:'.$digest;
        $record['projection_metadata']['projection_identity'] = 'canonical-match-projection-v1:'.$digest;
        $record['projection_metadata']['represented_source_revision_value'] = 0;
        $record['projection_metadata']['projection_currentness'] = $record['currentness'];
        $record['projection_metadata']['lag_classification'] = match ($record['currentness']) {
            true => 'CURRENT',
            false => 'LAGGED',
            null => 'UNKNOWN',
        };

        return $record;
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
    private function rr03Record(): array
    {
        $bindings = [
            'authority_owner' => 'RUNTIME_READINESS_DERIVATION',
            'authority_scope' => 'EFFECTIVE_READINESS|SYNTHETIC_SCOPE',
            'actor' => 'synthetic-actor',
            'actor_role' => 'SYNTHETIC_REVIEWER',
            'subject' => 'synthetic-subject',
            'participants' => ['synthetic-member'],
            'audience' => 'SYNTHETIC_AUDIENCE',
            'purpose' => 'SYNTHETIC_SCOPE',
            'aggregate_context' => 'synthetic-set',
            'lifecycle_identity' => 'rr03-lifecycle',
            'terminal' => false,
        ];

        return [
            'logical_record_identity' => 'rr03-record',
            'record_family' => InMemoryLogicalPersistenceRepositoryContract::RECORD_FAMILY_RR03,
            'bindings' => $bindings,
            'source_revision' => [
                'authority_owner' => 'RUNTIME_READINESS_DERIVATION',
                'authority_scope' => 'EFFECTIVE_READINESS|SYNTHETIC_SCOPE',
                'lineage' => 'rr03-lineage',
                'aggregate_context' => 'synthetic-set',
                'value' => 0,
            ],
            'source_condition' => CommonAuthorityEvidenceContract::CONDITION_PRESENT,
            'currentness' => true,
            'freshness' => true,
            'logical_intent' => [
                'intent_identity' => 'rr03-intent',
                'semantic_input' => ['fixture' => 'rr03'],
            ],
            'authoritative_outcome' => CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN,
            'authoritative_outcome_metadata' => null,
            'correction_metadata' => null,
            'projection_metadata' => [
                'projection_identity' => 'rr03-projection',
                'represented_source_revision_value' => 0,
                'lag_classification' => 'CURRENT',
                'projection_currentness' => true,
            ],
            'transport_observation' => 'AMBIGUOUS',
            'private_fixture_extensions' => [],
            'derived_projection_payload' => [
                'payload_kind' => 'RR03_RUNTIME_READINESS',
                'derived_fact_class' => 'EFFECTIVE_READINESS',
                'classification' => 'READY',
                'prerequisite_set_state' => 'KNOWN_PREREQUISITE_SET',
                'prerequisite_set_identity' => 'synthetic-set',
                'prerequisite_set_revision' => null,
                'prerequisite_set_condition' => CommonAuthorityEvidenceContract::CONDITION_PRESENT,
                'prerequisite_set_currentness' => true,
                'prerequisite_set_freshness' => true,
                'protected_use_scope' => 'SYNTHETIC_SCOPE',
                'reason_categories' => [],
                'dependencies' => [],
                'invalidation' => [
                    'invalidated' => false,
                    'relation' => null,
                    'dependency_identity' => null,
                ],
            ],
        ];
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
