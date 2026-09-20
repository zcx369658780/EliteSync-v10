<?php

namespace Tests\Unit;

use App\Domain\CanonicalMatchPersistenceApplicationAdapter;
use App\Domain\CommonAuthorityEvidenceContract;
use App\Domain\InMemoryLogicalPersistenceRepositoryContract;
use App\Domain\PersistenceBoundaryApplicationInterfaceIntegrationContract;
use App\Domain\SqliteInMemoryLogicalPersistenceAdapter;
use InvalidArgumentException;
use PHPUnit\Framework\TestCase;
use ReflectionMethod;

final class CanonicalMatchPersistenceApplicationAdapterTest extends TestCase
{
    private const RESULT_KEYS = [
        'record_kind',
        'operation',
        'match_classification',
        'reason_categories',
        'match_payload',
        'logical_record_identity',
        'logical_intent_identity',
        'lifecycle_identity',
        'source_projection_lineage',
        'derived_correlation_revision',
        'storage_disposition',
        'projection_read_disposition',
        'binding_classification',
        'materialized_projection_usable',
        'authoritative_outcome',
        'reconciliation_required',
        'invalidation_required',
        'revalidation_required',
        'condition',
        'synthetic_dev_test_only',
        'source_local_revision_only',
        'global_revision',
        'last_write_wins',
        'last_received_wins',
        'transport_disposition',
        'http_status',
        'source_authority',
        'match_authority',
        'connection_authority',
        'consent_authority',
        'conversation_authority',
        'relationship_authority',
        'home_action_authority',
        'notification_delivery_authority',
        'launch_authority',
        'permission',
        'bearer_capability',
        'production_ready',
        'real_data_authorized',
    ];

    public function test_pending_materializes_exactly_with_deterministic_privacy_and_non_authority_result(): void
    {
        [$adapter] = $this->adapter();
        $request = $this->request();
        $before = $request;
        $result = $adapter->evaluateSynthetic($request);

        self::assertSame($before, $request);
        self::assertSame('PENDING', $result['match_classification']);
        self::assertSame([], $result['reason_categories']);
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::STORED_NEW, $result['storage_disposition']);
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::RESOLVED, $result['projection_read_disposition']);
        self::assertSame('EXACT', $result['binding_classification']);
        self::assertTrue($result['materialized_projection_usable']);
        self::assertFalse($result['invalidation_required']);
        self::assertFalse($result['revalidation_required']);
        self::assertSame('EXACT_PRIVACY_MINIMAL_CANONICAL_MATCH_PROJECTION_MATERIALIZED', $result['condition']);
        self::assertSame(CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN, $result['authoritative_outcome']);
        self::assertSame(0, $result['derived_correlation_revision']['value']);
        self::assertSame(
            InMemoryLogicalPersistenceRepositoryContract::RECORD_FAMILY_CANONICAL_MATCH,
            'CANONICAL_MATCH_PROPOSAL_DECISION_DERIVED_PROJECTION',
        );

        $keys = array_keys($result);
        sort($keys);
        $expectedKeys = self::RESULT_KEYS;
        sort($expectedKeys);
        self::assertSame($expectedKeys, $keys);
        self::assertTrue($result['synthetic_dev_test_only']);
        self::assertTrue($result['source_local_revision_only']);

        foreach ([
            'global_revision',
            'last_write_wins',
            'last_received_wins',
            'source_authority',
            'match_authority',
            'connection_authority',
            'consent_authority',
            'conversation_authority',
            'relationship_authority',
            'home_action_authority',
            'notification_delivery_authority',
            'launch_authority',
            'permission',
            'bearer_capability',
            'production_ready',
            'real_data_authorized',
        ] as $field) {
            self::assertFalse($result[$field]);
        }

        self::assertNull($result['transport_disposition']);
        self::assertNull($result['http_status']);
        self::assertFalse($this->containsKey($result, 'source_evidence'));
        self::assertFalse($this->containsKey($result, 'required_bindings'));
        self::assertStringNotContainsString('MUST-NOT-LEAK', serialize($result));
    }

    public function test_terminal_classifications_and_semantic_unknown_materialize_with_exact_sticky_shape(): void
    {
        foreach ([
            ['ACCEPTED', 'ACCEPTED', 'MUTUALLY_ACCEPTED'],
            ['DECLINED', 'PENDING', 'DECLINED'],
            ['WITHDRAWN', 'PENDING', 'WITHDRAWN'],
        ] as [$firstDecision, $secondDecision, $classification]) {
            [$adapter] = $this->adapter();
            $result = $adapter->evaluateSynthetic($this->request([
                'decisions' => [
                    'synthetic-member-a' => $firstDecision,
                    'synthetic-member-b' => $secondDecision,
                ],
            ]));

            self::assertSame($classification, $result['match_classification']);
            self::assertTrue($result['match_payload']['terminality']['derived_terminal']);
            self::assertTrue($result['materialized_projection_usable']);
        }

        [$adapter] = $this->adapter();
        $unknown = $adapter->evaluateSynthetic($this->request([
            'decisions' => [
                'synthetic-member-a' => 'DECLINED',
                'synthetic-member-b' => 'WITHDRAWN',
            ],
        ]));
        self::assertSame('UNKNOWN', $unknown['match_classification']);
        self::assertSame(['CONFLICTING_TERMINAL_SLOT_DECISIONS'], $unknown['reason_categories']);
        self::assertTrue($unknown['materialized_projection_usable']);
        self::assertFalse($unknown['match_payload']['terminality']['derived_terminal']);
        self::assertTrue($unknown['match_payload']['proposal_dependency']['currentness']);
        self::assertTrue($unknown['match_payload']['proposal_dependency']['freshness']);
    }

    public function test_structural_failures_throw_before_any_persistence_and_valid_semantic_gaps_persist_unknown(): void
    {
        [$adapter] = $this->adapter();
        $malformed = $this->request();
        unset($malformed['proposal']['source_evidence']);

        try {
            $adapter->evaluateSynthetic($malformed);
            self::fail('Malformed proposal was not rejected.');
        } catch (InvalidArgumentException) {
            self::assertSame(
                InMemoryLogicalPersistenceRepositoryContract::STORED_NEW,
                $adapter->evaluateSynthetic($this->request())['storage_disposition'],
            );
        }

        foreach (['participation_evidence', 'decision_slot_evidence'] as $container) {
            [$isolated] = $this->adapter();
            $bad = $this->request();
            unset($bad[$container][0]['source_evidence']['source_revision']['lineage']);
            $this->expectInvalidArgumentFrom(fn (): array => $isolated->evaluateSynthetic($bad));
        }

        [$missingParticipationAdapter] = $this->adapter();
        $missingParticipation = $this->request();
        array_pop($missingParticipation['participation_evidence']);
        $participationResult = $missingParticipationAdapter->evaluateSynthetic($missingParticipation);
        self::assertSame('UNKNOWN', $participationResult['match_classification']);
        self::assertSame(['MISSING_PARTICIPATION'], $participationResult['reason_categories']);
        self::assertFalse($participationResult['materialized_projection_usable']);
        self::assertCount(1, $participationResult['match_payload']['participation_dependencies']);

        [$missingSlotAdapter] = $this->adapter();
        $missingSlot = $this->request();
        array_pop($missingSlot['decision_slot_evidence']);
        $slotResult = $missingSlotAdapter->evaluateSynthetic($missingSlot);
        self::assertSame('UNKNOWN', $slotResult['match_classification']);
        self::assertSame(['MISSING_DECISION_SLOT'], $slotResult['reason_categories']);
        self::assertFalse($slotResult['materialized_projection_usable']);

        foreach ([
            ['proposal_identity', 'another-proposal', 'CROSS_PROPOSAL_SLOT'],
            ['participant_identity', 'outsider', 'WRONG_PARTICIPANT_SLOT'],
        ] as [$field, $value, $reason]) {
            [$semanticAdapter] = $this->adapter();
            $semantic = $this->request();
            $semantic['decision_slot_evidence'][0][$field] = $value;
            $result = $semanticAdapter->evaluateSynthetic($semantic);
            self::assertSame('UNKNOWN', $result['match_classification']);
            self::assertSame([$reason], $result['reason_categories']);
            self::assertFalse($result['materialized_projection_usable']);
        }
    }

    public function test_duplicate_slot_reasons_are_bounded_and_suffixes_do_not_leak(): void
    {
        [$adapter] = $this->adapter();
        $request = $this->request();
        $duplicate = $request['decision_slot_evidence'][0];
        $duplicate['slot_identity'] = 'another-slot-a';
        $request['decision_slot_evidence'][] = $duplicate;
        $result = $adapter->evaluateSynthetic($request);

        self::assertSame('UNKNOWN', $result['match_classification']);
        self::assertSame(['CONFLICTING_SLOT_IDENTITY'], $result['reason_categories']);
        self::assertStringNotContainsString('synthetic-member-a', implode('|', $result['reason_categories']));

        [$incomparableAdapter] = $this->adapter();
        $incomparable = $this->request();
        $otherLineage = $incomparable['decision_slot_evidence'][0];
        $otherLineage['required_bindings']['authority_owner'] = 'ALT_SLOT_SOURCE';
        $otherLineage['source_evidence'] = $this->evidence(
            $otherLineage['required_bindings'],
            'alt-slot-lineage',
            1,
        );
        $incomparable['decision_slot_evidence'][] = $otherLineage;
        $incomparableResult = $incomparableAdapter->evaluateSynthetic($incomparable);
        self::assertSame(['INCOMPARABLE_DUPLICATE_SLOT'], $incomparableResult['reason_categories']);
    }

    public function test_invalidation_freshly_binds_sticky_terminality_and_repeats_idempotently(): void
    {
        [$adapter] = $this->adapter();
        $terminalRequest = $this->request([
            'decisions' => [
                'synthetic-member-a' => 'ACCEPTED',
                'synthetic-member-b' => 'ACCEPTED',
            ],
        ]);
        $ordinary = $adapter->evaluateSynthetic($terminalRequest);
        self::assertSame('MUTUALLY_ACCEPTED', $ordinary['match_classification']);

        $invalidationRequest = $terminalRequest + [
            'invalidation_request' => [
                'dependency_identity' => 'synthetic-slot-a',
                'relation' => CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
            ],
        ];
        $before = $invalidationRequest;
        $invalidated = $adapter->invalidateSynthetic($invalidationRequest);

        self::assertSame($before, $invalidationRequest);
        self::assertSame('INVALIDATE', $invalidated['operation']);
        self::assertSame('UNKNOWN', $invalidated['match_classification']);
        self::assertSame(['DEPENDENCY_INVALIDATED'], $invalidated['reason_categories']);
        self::assertSame('MUTUALLY_ACCEPTED', $invalidated['match_payload']['terminality']['classification_before_invalidation']);
        self::assertTrue($invalidated['match_payload']['terminality']['derived_terminal']);
        self::assertFalse($invalidated['materialized_projection_usable']);
        self::assertTrue($invalidated['invalidation_required']);
        self::assertTrue($invalidated['revalidation_required']);
        self::assertSame(
            'CANONICAL_MATCH_DEPENDENCY_INVALIDATED_PROJECTION_MATERIALIZED_UNUSABLE',
            $invalidated['condition'],
        );

        $repeat = $adapter->invalidateSynthetic($invalidationRequest);
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::EXACT_DUPLICATE, $repeat['storage_disposition']);
        self::assertSame($invalidated['logical_record_identity'], $repeat['logical_record_identity']);

        [$pendingAdapter] = $this->adapter();
        $pendingRequest = $this->request() + [
            'invalidation_request' => [
                'dependency_identity' => 'synthetic-slot-b',
                'relation' => CommonAuthorityEvidenceContract::INVALIDATION_REVOCATION,
            ],
        ];
        $pending = $pendingAdapter->invalidateSynthetic($pendingRequest);
        self::assertSame('PENDING', $pending['match_payload']['terminality']['classification_before_invalidation']);
        self::assertFalse($pending['match_payload']['terminality']['derived_terminal']);
    }

    public function test_unknown_or_colliding_invalidation_target_is_rejected_before_submit(): void
    {
        foreach (['not-a-dependency', ''] as $target) {
            [$adapter] = $this->adapter();
            $request = $this->request() + [
                'invalidation_request' => [
                    'dependency_identity' => $target,
                    'relation' => CommonAuthorityEvidenceContract::INVALIDATION_SUPERSESSION,
                ],
            ];
            $this->expectInvalidArgumentFrom(fn (): array => $adapter->invalidateSynthetic($request));
        }

        [$collisionAdapter] = $this->adapter();
        $collision = $this->request();
        $collision['decision_slot_evidence'][0]['slot_identity'] = 'synthetic-proposal';
        $collision['invalidation_request'] = [
            'dependency_identity' => 'synthetic-proposal',
            'relation' => CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
        ];
        $this->expectInvalidArgumentFrom(fn (): array => $collisionAdapter->invalidateSynthetic($collision));
    }

    public function test_duplicate_incomparable_and_terminal_reopen_storage_dispositions_are_preserved(): void
    {
        [$adapter] = $this->adapter();
        $request = $this->request();
        $first = $adapter->evaluateSynthetic($request);
        $duplicate = $adapter->evaluateSynthetic($request);
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::STORED_NEW, $first['storage_disposition']);
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::EXACT_DUPLICATE, $duplicate['storage_disposition']);
        self::assertSame($first['logical_record_identity'], $duplicate['logical_record_identity']);

        $changed = $this->request(['slot_b_revision' => 2]);
        $incomparable = $adapter->evaluateSynthetic($changed);
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::INCOMPARABLE_COEXISTS, $incomparable['storage_disposition']);
        self::assertNotSame($first['logical_record_identity'], $incomparable['logical_record_identity']);
        self::assertNotSame($first['source_projection_lineage'], $incomparable['source_projection_lineage']);
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::RESOLVED, $incomparable['projection_read_disposition']);

        [$terminalAdapter] = $this->adapter();
        $terminalAdapter->evaluateSynthetic($this->request([
            'decisions' => [
                'synthetic-member-a' => 'ACCEPTED',
                'synthetic-member-b' => 'ACCEPTED',
            ],
        ]));
        $reopen = $terminalAdapter->evaluateSynthetic($this->request());
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::INVALID_RECORD_REJECTED, $reopen['storage_disposition']);
        self::assertNull($reopen['projection_read_disposition']);
        self::assertSame('STORAGE_REJECTED_RETRIEVAL_SKIPPED', $reopen['condition']);
        self::assertFalse($reopen['materialized_projection_usable']);
    }

    public function test_generic_overlay_and_exact_readback_mismatches_fail_closed_without_reclassifying_match(): void
    {
        [$adapter, $application] = $this->adapter();
        $request = $this->request();
        $first = $adapter->evaluateSynthetic($request);
        $application->observeInvalidation(
            $first['logical_record_identity'],
            CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
        );
        $overlay = $adapter->evaluateSynthetic($request);
        self::assertSame('PENDING', $overlay['match_classification']);
        self::assertFalse($overlay['materialized_projection_usable']);
        self::assertSame('CANONICAL_MATCH_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED', $overlay['condition']);

        [$isolatedAdapter, $isolatedApplication] = $this->adapter();
        $clean = $isolatedAdapter->evaluateSynthetic($request);
        $record = $this->invokePrivate($isolatedAdapter, 'buildRecord', [$clean['match_payload'], $request['proposal']]);
        $retrieval = $isolatedApplication->retrieveCurrentProjection([
            'record_family' => InMemoryLogicalPersistenceRepositoryContract::RECORD_FAMILY_CANONICAL_MATCH,
            'authority_owner' => 'CANONICAL_MATCH_DERIVATION',
            'authority_scope' => 'CANONICAL_MATCH_PROPOSAL_DECISION|SYNTHETIC_MATCH_REVIEW',
            'aggregate_context' => 'synthetic-proposal',
            'lineage' => $record['source_revision']['lineage'],
        ], [
            'viewer' => 'synthetic-actor',
            'subject' => 'synthetic-subject',
            'participants' => ['synthetic-member-a', 'synthetic-member-b'],
            'audience' => 'SYNTHETIC_AUDIENCE',
            'purpose' => 'SYNTHETIC_MATCH_REVIEW',
            'aggregate_context' => 'synthetic-proposal',
        ]);
        self::assertTrue($this->invokePrivate($isolatedAdapter, 'exactReadback', [$retrieval, $record, $clean['match_payload']]));

        foreach ([
            ['resolution', InMemoryLogicalPersistenceRepositoryContract::UNKNOWN],
            ['binding_classification', 'MISMATCH'],
            ['projection.record_family', 'WRONG_FAMILY'],
            ['projection.logical_record_identity', 'wrong-record'],
            ['projection.logical_intent_identity', 'wrong-intent'],
            ['projection.derived_projection_payload', []],
        ] as [$path, $value]) {
            $mismatch = $retrieval;
            if (str_starts_with($path, 'projection.')) {
                $mismatch['projection'][substr($path, 11)] = $value;
            } else {
                $mismatch[$path] = $value;
            }
            self::assertFalse($this->invokePrivate(
                $isolatedAdapter,
                'exactReadback',
                [$mismatch, $record, $clean['match_payload']],
            ));
        }

        $bindingMismatch = $isolatedApplication->retrieveCurrentProjection([
            'record_family' => InMemoryLogicalPersistenceRepositoryContract::RECORD_FAMILY_CANONICAL_MATCH,
            'authority_owner' => 'CANONICAL_MATCH_DERIVATION',
            'authority_scope' => 'CANONICAL_MATCH_PROPOSAL_DECISION|SYNTHETIC_MATCH_REVIEW',
            'aggregate_context' => 'synthetic-proposal',
            'lineage' => $record['source_revision']['lineage'],
        ], [
            'viewer' => 'synthetic-actor',
            'subject' => 'wrong-subject',
            'participants' => ['synthetic-member-a', 'synthetic-member-b'],
            'audience' => 'SYNTHETIC_AUDIENCE',
            'purpose' => 'SYNTHETIC_MATCH_REVIEW',
            'aggregate_context' => 'synthetic-proposal',
        ]);
        self::assertSame('MISMATCH', $bindingMismatch['binding_classification']);
        self::assertFalse($this->invokePrivate(
            $isolatedAdapter,
            'exactReadback',
            [$bindingMismatch, $record, $clean['match_payload']],
        ));
    }

    public function test_source_has_exact_call_sites_and_no_ip13f_or_transport_execution_surface(): void
    {
        $source = file_get_contents(
            dirname(__DIR__, 2).'/app/Domain/CanonicalMatchPersistenceApplicationAdapter.php',
        );

        self::assertIsString($source);
        self::assertSame(2, substr_count($source, 'CanonicalMatchProposalDecisionEvaluator::evaluate('));
        self::assertSame(1, substr_count($source, 'CanonicalMatchProposalDecisionEvaluator::invalidate('));
        self::assertSame(1, substr_count($source, 'submitAuthoritativeMutation('));
        self::assertSame(1, substr_count($source, 'retrieveCurrentProjection('));
        self::assertSame(0, substr_count($source, 'observeInvalidation('));
        self::assertStringNotContainsString('DeferredMessaging', $source);
        self::assertStringNotContainsString('IP-13F', $source);
        self::assertStringNotContainsString('Http\\', $source);
    }

    /** @return array{CanonicalMatchPersistenceApplicationAdapter, PersistenceBoundaryApplicationInterfaceIntegrationContract} */
    private function adapter(): array
    {
        $application = new PersistenceBoundaryApplicationInterfaceIntegrationContract(
            new SqliteInMemoryLogicalPersistenceAdapter(),
        );

        return [new CanonicalMatchPersistenceApplicationAdapter($application), $application];
    }

    /** @param array<string, mixed> $options @return array<string, mixed> */
    private function request(array $options = []): array
    {
        $proposalIdentity = 'synthetic-proposal';
        $scope = 'SYNTHETIC_MATCH_REVIEW';
        $participants = ['synthetic-member-b', 'synthetic-member-a'];
        $lifecycle = $options['lifecycle'] ?? 'PENDING';
        $proposalBindings = $this->bindings(
            'PROPOSAL_SOURCE',
            'PROPOSAL_SCOPE',
            'synthetic-subject',
            $participants,
            $scope,
            $proposalIdentity,
            $lifecycle !== 'PENDING',
        );
        $proposal = [
            'proposal_identity' => $proposalIdentity,
            'participants' => $participants,
            'protected_use_scope' => $scope,
            'lifecycle_state' => $lifecycle,
            'at_most_one_unresolved_precondition' => $options['precondition'] ?? true,
            'required_bindings' => $proposalBindings,
            'source_evidence' => $this->evidence($proposalBindings, 'proposal-lineage', 1),
        ];
        $participation = [];
        $slots = [];
        $decisions = $options['decisions'] ?? [
            'synthetic-member-a' => 'PENDING',
            'synthetic-member-b' => 'PENDING',
        ];

        foreach ($participants as $participant) {
            $participationBindings = $this->bindings(
                'PARTICIPATION_SOURCE',
                'PARTICIPATION_SCOPE',
                $participant,
                [$participant],
                $scope,
                $participant,
                false,
            );
            $participation[] = [
                'participant_identity' => $participant,
                'state' => 'ENROLLED',
                'required_bindings' => $participationBindings,
                'source_evidence' => $this->evidence(
                    $participationBindings,
                    'participation-lineage-'.$participant,
                    1,
                ),
            ];
            $suffix = str_ends_with($participant, '-a') ? 'a' : 'b';
            $slotBindings = $this->bindings(
                'SLOT_SOURCE',
                'SLOT_SCOPE',
                $participant,
                [$participant],
                $scope,
                $proposalIdentity,
                false,
            );
            $slots[] = [
                'slot_identity' => 'synthetic-slot-'.$suffix,
                'proposal_identity' => $proposalIdentity,
                'participant_identity' => $participant,
                'protected_use_scope' => $scope,
                'decision' => $decisions[$participant],
                'required_bindings' => $slotBindings,
                'source_evidence' => $this->evidence(
                    $slotBindings,
                    'slot-lineage-'.$suffix,
                    $suffix === 'b' ? ($options['slot_b_revision'] ?? 1) : 1,
                ),
            ];
        }

        return [
            'synthetic_fixture' => CanonicalMatchPersistenceApplicationAdapter::SYNTHETIC_FIXTURE_MARKER,
            'proposal' => $proposal,
            'participation_evidence' => $participation,
            'decision_slot_evidence' => $slots,
        ];
    }

    /** @return array<string, mixed> */
    private function bindings(
        string $owner,
        string $authorityScope,
        string $subject,
        array $participants,
        string $purpose,
        string $context,
        bool $terminal,
    ): array {
        return [
            'authority_owner' => $owner,
            'authority_scope' => $authorityScope,
            'actor' => 'synthetic-actor',
            'actor_role' => 'SYNTHETIC_REVIEWER',
            'subject' => $subject,
            'participants' => $participants,
            'audience' => 'SYNTHETIC_AUDIENCE',
            'purpose' => $purpose,
            'aggregate_context' => $context,
            'lifecycle_identity' => 'source-lifecycle-'.$context,
            'terminal' => $terminal,
        ];
    }

    /** @param array<string, mixed> $bindings @return array<string, mixed> */
    private function evidence(array $bindings, string $lineage, int $revision): array
    {
        return CommonAuthorityEvidenceContract::evidence(
            $bindings,
            CommonAuthorityEvidenceContract::CONDITION_PRESENT,
            CommonAuthorityEvidenceContract::sourceRevision(
                $bindings['authority_owner'],
                $bindings['authority_scope'],
                $lineage,
                $bindings['aggregate_context'],
                $revision,
            ),
            true,
            true,
            CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN,
        );
    }

    private function expectInvalidArgumentFrom(callable $operation): void
    {
        try {
            $operation();
            self::fail('Expected InvalidArgumentException was not thrown.');
        } catch (InvalidArgumentException) {
            self::assertTrue(true);
        }
    }

    private function containsKey(mixed $value, string $needle): bool
    {
        if (! is_array($value)) {
            return false;
        }

        if (array_key_exists($needle, $value)) {
            return true;
        }

        foreach ($value as $nested) {
            if ($this->containsKey($nested, $needle)) {
                return true;
            }
        }

        return false;
    }

    /** @param list<mixed> $arguments */
    private function invokePrivate(object $object, string $method, array $arguments): mixed
    {
        $reflection = new ReflectionMethod($object, $method);
        $reflection->setAccessible(true);

        return $reflection->invokeArgs($object, $arguments);
    }
}
