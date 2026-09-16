<?php

namespace Tests\Unit;

use App\Domain\CommonAuthorityEvidenceContract as CommonContract;
use App\Domain\ProductConnectionStateTransitionEvaluator as Evaluator;
use PHPUnit\Framework\TestCase;

final class ProductConnectionStateTransitionEvaluatorTest extends TestCase
{
    public function testCanonicalVocabularyIsExactAndUnknownIsNotLifecycleState(): void
    {
        self::assertSame([
            'CN_NONE',
            'CN_PENDING',
            'CN_ACTIVE',
            'CN_PAUSED',
            'CN_CLOSED',
            'CN_DECLINED',
            'CN_WITHDRAWN',
            'CN_EXPIRED',
        ], Evaluator::lifecycleVocabulary());
        self::assertNotContains(Evaluator::DERIVED_UNKNOWN, Evaluator::lifecycleVocabulary());
    }

    public function testConnectionIdentityIsExplicitAndExactlyTwoDistinctParticipantsAreRequired(): void
    {
        $missingIdentity = $this->connection();
        $missingIdentity['connection_identity'] = '';
        $oneParticipant = $this->connection();
        $oneParticipant['participants'] = ['synthetic-participant-A'];
        $duplicateParticipant = $this->connection();
        $duplicateParticipant['participants'] = ['synthetic-participant-A', 'synthetic-participant-A'];

        self::assertSame(Evaluator::DERIVED_UNKNOWN, Evaluator::evaluateCurrent($missingIdentity, [])['classification']);
        self::assertSame(Evaluator::DERIVED_UNKNOWN, Evaluator::evaluateCurrent($oneParticipant, [])['classification']);
        self::assertSame(Evaluator::DERIVED_UNKNOWN, Evaluator::evaluateCurrent($duplicateParticipant, [])['classification']);
    }

    public function testCurrentStateRequiresCurrentFreshBindingValidEvidence(): void
    {
        $result = Evaluator::evaluateCurrent($this->connection(), [$this->stateEvidence(Evaluator::STATE_ACTIVE)]);

        self::assertSame(Evaluator::STATE_ACTIVE, $result['classification']);
        self::assertSame('synthetic-connection-A', $result['connection_identity']);
        self::assertTrue($result['connection_active_for_downstream_consideration']);
    }

    /** @dataProvider allowedTransitionProvider */
    public function testCanonicalTransitionIsAdmissible(string $from, string $to): void
    {
        $result = $this->evaluateTransition($from, $to);

        self::assertSame(Evaluator::TRANSITION_ADMISSIBLE, $result['classification']);
        self::assertSame($from, $result['current_state']);
        self::assertSame($to, $result['proposed_state']);
    }

    /** @return iterable<string, array{string, string}> */
    public static function allowedTransitionProvider(): iterable
    {
        yield 'none to pending' => [Evaluator::STATE_NONE, Evaluator::STATE_PENDING];
        yield 'pending to active' => [Evaluator::STATE_PENDING, Evaluator::STATE_ACTIVE];
        yield 'pending to declined' => [Evaluator::STATE_PENDING, Evaluator::STATE_DECLINED];
        yield 'pending to withdrawn' => [Evaluator::STATE_PENDING, Evaluator::STATE_WITHDRAWN];
        yield 'pending to expired' => [Evaluator::STATE_PENDING, Evaluator::STATE_EXPIRED];
        yield 'active to paused' => [Evaluator::STATE_ACTIVE, Evaluator::STATE_PAUSED];
        yield 'active to closed' => [Evaluator::STATE_ACTIVE, Evaluator::STATE_CLOSED];
        yield 'paused to active' => [Evaluator::STATE_PAUSED, Evaluator::STATE_ACTIVE];
        yield 'paused to closed' => [Evaluator::STATE_PAUSED, Evaluator::STATE_CLOSED];
    }

    public function testPendingToActiveRequiresExactCurrentConnectionContext(): void
    {
        $transition = $this->transitionEvidence(Evaluator::STATE_PENDING, Evaluator::STATE_ACTIVE);
        $transition['expected_state_revision']['value'] = 999;
        $result = Evaluator::evaluateTransition(
            $this->connection(),
            [$this->stateEvidence(Evaluator::STATE_PENDING)],
            [$transition],
        );

        self::assertSame(Evaluator::DERIVED_UNKNOWN, $result['classification']);
        self::assertContains('TRANSITION_CURRENT_CONTEXT_MISMATCH', $result['reasons']);
    }

    public function testDirectNoneToActiveIsExplicitlyRejected(): void
    {
        $result = $this->evaluateTransition(Evaluator::STATE_NONE, Evaluator::STATE_ACTIVE);

        self::assertSame(Evaluator::TRANSITION_REJECTED, $result['classification']);
        self::assertContains('DIRECT_NONE_TO_ACTIVE_REJECTED', $result['reasons']);
        self::assertFalse($result['connection_activated']);
    }

    public function testExpiryConsumesAuthoritativeEvidenceWithoutClockOrDurationPolicy(): void
    {
        $result = $this->evaluateTransition(Evaluator::STATE_PENDING, Evaluator::STATE_EXPIRED);
        $encoded = json_encode($result);

        self::assertSame(Evaluator::TRANSITION_ADMISSIBLE, $result['classification']);
        self::assertIsString($encoded);
        self::assertStringNotContainsString('clock', $encoded);
        self::assertStringNotContainsString('duration', $encoded);
        self::assertStringNotContainsString('timeout', $encoded);
    }

    /** @dataProvider terminalStateProvider */
    public function testTerminalSameIdentityStatesHaveNoOutgoingTransition(string $terminal): void
    {
        $result = $this->evaluateTransition($terminal, Evaluator::STATE_PENDING);

        self::assertSame(Evaluator::TRANSITION_REJECTED, $result['classification']);
        self::assertContains('TERMINAL_CONNECTION_IDENTITY_CANNOT_REOPEN', $result['reasons']);
        self::assertFalse($result['connection_reopened']);
        self::assertFalse($result['lifecycle_reset']);
    }

    /** @return iterable<string, array{string}> */
    public static function terminalStateProvider(): iterable
    {
        yield 'closed' => [Evaluator::STATE_CLOSED];
        yield 'declined' => [Evaluator::STATE_DECLINED];
        yield 'withdrawn' => [Evaluator::STATE_WITHDRAWN];
        yield 'expired' => [Evaluator::STATE_EXPIRED];
    }

    public function testLaterLifecycleAfterTerminalUsesFreshConnectionIdentity(): void
    {
        $terminal = $this->evaluateTransition(Evaluator::STATE_CLOSED, Evaluator::STATE_PENDING);
        $freshConnection = $this->connection('synthetic-connection-B');
        $freshResult = Evaluator::evaluateTransition(
            $freshConnection,
            [$this->stateEvidence(Evaluator::STATE_NONE, connectionIdentity: 'synthetic-connection-B')],
            [$this->transitionEvidence(Evaluator::STATE_NONE, Evaluator::STATE_PENDING, connectionIdentity: 'synthetic-connection-B')],
        );

        self::assertSame(Evaluator::TRANSITION_REJECTED, $terminal['classification']);
        self::assertSame(Evaluator::TRANSITION_ADMISSIBLE, $freshResult['classification']);
        self::assertNotSame($terminal['connection_identity'], $freshResult['connection_identity']);
    }

    public function testMutuallyAcceptedMatchCannotCreateOrActivateConnection(): void
    {
        $result = Evaluator::evaluateTransition(
            $this->connection(),
            [],
            [],
            ['classification' => 'MUTUALLY_ACCEPTED', 'match_identity' => 'synthetic-match-A'],
        );

        self::assertSame(Evaluator::DERIVED_UNKNOWN, $result['classification']);
        self::assertFalse($result['connection_created']);
        self::assertFalse($result['connection_activated']);
        self::assertFalse($result['match_substituted_for_connection']);
    }

    public function testCrossConnectionTransitionEvidenceFailsClosed(): void
    {
        $result = Evaluator::evaluateTransition(
            $this->connection(),
            [$this->stateEvidence(Evaluator::STATE_PENDING)],
            [$this->transitionEvidence(Evaluator::STATE_PENDING, Evaluator::STATE_ACTIVE, connectionIdentity: 'synthetic-connection-B')],
        );

        self::assertSame(Evaluator::DERIVED_UNKNOWN, $result['classification']);
        self::assertContains('CROSS_CONNECTION_TRANSITION_EVIDENCE', $result['reasons']);
    }

    public function testWrongParticipantStateAndTransitionEvidenceFailClosed(): void
    {
        $wrongState = $this->stateEvidence(Evaluator::STATE_PENDING);
        $wrongState['participants'] = ['synthetic-participant-A', 'synthetic-participant-C'];
        $stateResult = Evaluator::evaluateCurrent($this->connection(), [$wrongState]);

        $wrongTransition = $this->transitionEvidence(Evaluator::STATE_PENDING, Evaluator::STATE_ACTIVE);
        $wrongTransition['participants'] = ['synthetic-participant-A', 'synthetic-participant-C'];
        $transitionResult = Evaluator::evaluateTransition(
            $this->connection(),
            [$this->stateEvidence(Evaluator::STATE_PENDING)],
            [$wrongTransition],
        );

        self::assertSame(Evaluator::DERIVED_UNKNOWN, $stateResult['classification']);
        self::assertSame(Evaluator::DERIVED_UNKNOWN, $transitionResult['classification']);
    }

    public function testMissingCurrentEvidenceYieldsUnknown(): void
    {
        $result = Evaluator::evaluateCurrent($this->connection(), []);

        self::assertSame(Evaluator::DERIVED_UNKNOWN, $result['classification']);
        self::assertFalse($result['connection_active_for_downstream_consideration']);
    }

    public function testMissingOrUnavailableTransitionEvidenceYieldsUnknown(): void
    {
        $missing = Evaluator::evaluateTransition(
            $this->connection(),
            [$this->stateEvidence(Evaluator::STATE_PENDING)],
            [],
        );
        $unavailable = Evaluator::evaluateTransition(
            $this->connection(),
            [$this->stateEvidence(Evaluator::STATE_PENDING)],
            [$this->transitionEvidence(
                Evaluator::STATE_PENDING,
                Evaluator::STATE_ACTIVE,
                condition: CommonContract::CONDITION_UNAVAILABLE,
            )],
        );

        self::assertSame(Evaluator::DERIVED_UNKNOWN, $missing['classification']);
        self::assertSame(Evaluator::DERIVED_UNKNOWN, $unavailable['classification']);
    }

    public function testUnusableSourceConditionsYieldUnknown(): void
    {
        foreach ([
            CommonContract::CONDITION_UNKNOWN,
            CommonContract::CONDITION_UNAVAILABLE,
            CommonContract::CONDITION_STALE,
            CommonContract::CONDITION_SUPERSEDED,
            CommonContract::CONDITION_INCOMPARABLE,
        ] as $condition) {
            $result = Evaluator::evaluateCurrent(
                $this->connection(),
                [$this->stateEvidence(Evaluator::STATE_ACTIVE, condition: $condition)],
            );

            self::assertSame(Evaluator::DERIVED_UNKNOWN, $result['classification']);
            self::assertFalse($result['connection_active_for_downstream_consideration']);
        }
    }

    public function testCurrentButStaleFailsClosedAndFreshnessCannotManufactureCurrentness(): void
    {
        $stale = Evaluator::evaluateCurrent(
            $this->connection(),
            [$this->stateEvidence(Evaluator::STATE_ACTIVE, currentness: true, freshness: false)],
        );
        $notCurrent = Evaluator::evaluateCurrent(
            $this->connection(),
            [$this->stateEvidence(Evaluator::STATE_ACTIVE, currentness: false, freshness: true)],
        );

        self::assertSame(Evaluator::DERIVED_UNKNOWN, $stale['classification']);
        self::assertSame(Evaluator::DERIVED_UNKNOWN, $notCurrent['classification']);
    }

    public function testSameLineageNewerStateEvidenceControlsWithoutArrivalOrder(): void
    {
        $older = $this->stateEvidence(Evaluator::STATE_PENDING, revision: 6);
        $newer = $this->stateEvidence(Evaluator::STATE_ACTIVE, revision: 7);

        $olderFirst = Evaluator::evaluateCurrent($this->connection(), [$older, $newer]);
        $newerFirst = Evaluator::evaluateCurrent($this->connection(), [$newer, $older]);

        self::assertSame(Evaluator::STATE_ACTIVE, $olderFirst['classification']);
        self::assertSame($olderFirst, $newerFirst);
        self::assertSame(7, $olderFirst['dependency_vector']['current_state']['source_revision']['value']);
    }

    public function testConflictingEqualRevisionStateEvidenceFailsClosed(): void
    {
        $result = Evaluator::evaluateCurrent($this->connection(), [
            $this->stateEvidence(Evaluator::STATE_PENDING),
            $this->stateEvidence(Evaluator::STATE_ACTIVE),
        ]);

        self::assertSame(Evaluator::DERIVED_UNKNOWN, $result['classification']);
        self::assertContains('CONFLICTING_EQUAL_REVISION_STATE_EVIDENCE', $result['reasons']);
    }

    public function testIncomparableDuplicateStateEvidenceFailsClosed(): void
    {
        $otherLineage = $this->stateEvidence(Evaluator::STATE_ACTIVE, revision: 8);
        $otherLineage['source_evidence']['source_revision'] = CommonContract::sourceRevision(
            'synthetic-connection-authority',
            'synthetic-connection-scope',
            'synthetic-connection-lineage-B',
            'synthetic-connection-A',
            8,
        );

        $result = Evaluator::evaluateCurrent($this->connection(), [
            $this->stateEvidence(Evaluator::STATE_PENDING),
            $otherLineage,
        ]);

        self::assertSame(Evaluator::DERIVED_UNKNOWN, $result['classification']);
        self::assertContains('INCOMPARABLE_DUPLICATE_STATE_EVIDENCE', $result['reasons']);
    }

    public function testConflictingEqualRevisionTransitionEvidenceFailsClosed(): void
    {
        $result = Evaluator::evaluateTransition(
            $this->connection(),
            [$this->stateEvidence(Evaluator::STATE_PENDING)],
            [
                $this->transitionEvidence(Evaluator::STATE_PENDING, Evaluator::STATE_ACTIVE),
                $this->transitionEvidence(Evaluator::STATE_PENDING, Evaluator::STATE_DECLINED),
            ],
        );

        self::assertSame(Evaluator::DERIVED_UNKNOWN, $result['classification']);
        self::assertContains('CONFLICTING_EQUAL_REVISION_TRANSITION_EVIDENCE', $result['reasons']);
    }

    public function testIncomparableDuplicateTransitionEvidenceFailsClosed(): void
    {
        $otherLineage = $this->transitionEvidence(Evaluator::STATE_PENDING, Evaluator::STATE_ACTIVE, revision: 10);
        $otherLineage['source_evidence']['source_revision'] = CommonContract::sourceRevision(
            'synthetic-transition-authority',
            'synthetic-transition-scope',
            'synthetic-transition-lineage-B',
            'synthetic-connection-A',
            10,
        );

        $result = Evaluator::evaluateTransition(
            $this->connection(),
            [$this->stateEvidence(Evaluator::STATE_PENDING)],
            [
                $this->transitionEvidence(Evaluator::STATE_PENDING, Evaluator::STATE_ACTIVE),
                $otherLineage,
            ],
        );

        self::assertSame(Evaluator::DERIVED_UNKNOWN, $result['classification']);
        self::assertContains('INCOMPARABLE_DUPLICATE_TRANSITION_EVIDENCE', $result['reasons']);
    }

    public function testNewerTransitionEvidenceControlsWithoutArrivalOrder(): void
    {
        $older = $this->transitionEvidence(Evaluator::STATE_PENDING, Evaluator::STATE_DECLINED, revision: 8);
        $newer = $this->transitionEvidence(Evaluator::STATE_PENDING, Evaluator::STATE_ACTIVE, revision: 9);
        $olderFirst = Evaluator::evaluateTransition(
            $this->connection(),
            [$this->stateEvidence(Evaluator::STATE_PENDING)],
            [$older, $newer],
        );
        $newerFirst = Evaluator::evaluateTransition(
            $this->connection(),
            [$this->stateEvidence(Evaluator::STATE_PENDING)],
            [$newer, $older],
        );

        self::assertSame(Evaluator::TRANSITION_ADMISSIBLE, $olderFirst['classification']);
        self::assertSame(Evaluator::STATE_ACTIVE, $olderFirst['proposed_state']);
        self::assertSame($olderFirst, $newerFirst);
    }

    public function testNoGlobalRevisionOrLastReceivedWinsFieldExists(): void
    {
        $result = Evaluator::evaluateCurrent($this->connection(), [$this->stateEvidence(Evaluator::STATE_PENDING)]);
        $encoded = json_encode($result);

        self::assertIsString($encoded);
        self::assertStringNotContainsString('global_revision', $encoded);
        self::assertStringNotContainsString('last_received', $encoded);
    }

    public function testOnlyCurrentFreshActiveExposesBoundedDownstreamConsideration(): void
    {
        foreach (Evaluator::lifecycleVocabulary() as $state) {
            $result = Evaluator::evaluateCurrent($this->connection(), [$this->stateEvidence($state)]);

            self::assertSame($state === Evaluator::STATE_ACTIVE, $result['connection_active_for_downstream_consideration']);
        }

        $invalidActive = Evaluator::evaluateCurrent(
            $this->connection(),
            [$this->stateEvidence(Evaluator::STATE_ACTIVE, freshness: false)],
        );
        self::assertFalse($invalidActive['connection_active_for_downstream_consideration']);
    }

    public function testActiveLabelGrantsNoDownstreamAuthority(): void
    {
        $result = Evaluator::evaluateCurrent($this->connection(), [$this->stateEvidence(Evaluator::STATE_ACTIVE)]);

        self::assertTrue($result['connection_active_for_downstream_consideration']);
        self::assertFalse($result['messaging_consent_granted']);
        self::assertFalse($result['conversation_granted']);
        self::assertFalse($result['relationship_authority']);
        self::assertFalse($result['home_action_authority']);
        self::assertFalse($result['notification_authority']);
        self::assertFalse($result['launch_authority']);
        self::assertFalse($result['bearer_capability']);
    }

    public function testCorrectionRevocationAndSupersessionInvalidateWithoutResetOrReopen(): void
    {
        $derived = Evaluator::evaluateCurrent($this->connection(), [$this->stateEvidence(Evaluator::STATE_ACTIVE)]);
        $transitionDerived = $this->evaluateTransition(Evaluator::STATE_PENDING, Evaluator::STATE_ACTIVE);

        foreach ([
            CommonContract::INVALIDATION_CORRECTION,
            CommonContract::INVALIDATION_REVOCATION,
            CommonContract::INVALIDATION_SUPERSESSION,
        ] as $relation) {
            $invalidated = Evaluator::invalidate($derived, 'synthetic-state-evidence-A', $relation);

            self::assertSame(Evaluator::DERIVED_UNKNOWN, $invalidated['classification']);
            self::assertFalse($invalidated['connection_active_for_downstream_consideration']);
            self::assertFalse($invalidated['lifecycle_reset']);
            self::assertFalse($invalidated['connection_reopened']);
            self::assertSame('synthetic-connection-A', $invalidated['connection_identity']);

            $invalidatedTransition = Evaluator::invalidate($transitionDerived, 'synthetic-transition-A', $relation);
            self::assertSame(Evaluator::DERIVED_UNKNOWN, $invalidatedTransition['classification']);
            self::assertFalse($invalidatedTransition['lifecycle_reset']);
            self::assertFalse($invalidatedTransition['connection_reopened']);
        }
    }

    public function testEvaluationDoesNotMutateConnectionMatchStateOrTransitionEvidence(): void
    {
        $connection = $this->connection();
        $state = [$this->stateEvidence(Evaluator::STATE_PENDING)];
        $transition = [$this->transitionEvidence(Evaluator::STATE_PENDING, Evaluator::STATE_ACTIVE)];
        $match = ['classification' => 'MUTUALLY_ACCEPTED', 'match_identity' => 'synthetic-match-A'];
        $before = [$connection, $state, $transition, $match];

        $result = Evaluator::evaluateTransition($connection, $state, $transition, $match);

        self::assertFalse($result['source_evidence_mutated']);
        self::assertSame($before, [$connection, $state, $transition, $match]);
    }

    public function testPrivacyMinimalResultOmitsRawPrivateFixturePayloadAndScoring(): void
    {
        $state = $this->stateEvidence(Evaluator::STATE_ACTIVE);
        $state['synthetic_private_reason'] = 'synthetic-private-MUST-NOT-LEAK';
        $result = Evaluator::evaluateCurrent($this->connection(), [$state]);
        $encoded = json_encode($result);

        self::assertIsString($encoded);
        self::assertStringNotContainsString('MUST-NOT-LEAK', $encoded);
        self::assertStringNotContainsString('required_bindings', $encoded);
        self::assertFalse($result['ranking_computed']);
        self::assertFalse($result['compatibility_total_computed']);
        self::assertFalse($result['desirability_computed']);
        self::assertFalse($result['person_worth_computed']);
    }

    private function evaluateTransition(string $from, string $to): array
    {
        return Evaluator::evaluateTransition(
            $this->connection(),
            [$this->stateEvidence($from)],
            [$this->transitionEvidence($from, $to)],
        );
    }

    /** @return array<string, mixed> */
    private function connection(string $connectionIdentity = 'synthetic-connection-A'): array
    {
        return [
            'connection_identity' => $connectionIdentity,
            'participants' => ['synthetic-participant-A', 'synthetic-participant-B'],
            'protected_use_scope' => 'synthetic-connection-transition-use',
        ];
    }

    /** @return array<string, mixed> */
    private function stateEvidence(
        string $state,
        string $connectionIdentity = 'synthetic-connection-A',
        string $condition = CommonContract::CONDITION_PRESENT,
        ?bool $currentness = true,
        ?bool $freshness = true,
        int $revision = 7,
    ): array {
        $participants = ['synthetic-participant-A', 'synthetic-participant-B'];
        $bindings = $this->bindings(
            'synthetic-connection-authority',
            'synthetic-connection-scope',
            'synthetic-connection-authority-actor',
            $connectionIdentity,
            $participants,
            $connectionIdentity,
            in_array($state, [Evaluator::STATE_CLOSED, Evaluator::STATE_DECLINED, Evaluator::STATE_WITHDRAWN, Evaluator::STATE_EXPIRED], true),
        );

        return [
            'state_evidence_identity' => 'synthetic-state-evidence-A',
            'connection_identity' => $connectionIdentity,
            'participants' => $participants,
            'state' => $state,
            'required_bindings' => $bindings,
            'source_evidence' => CommonContract::evidence(
                $bindings,
                $condition,
                CommonContract::sourceRevision(
                    'synthetic-connection-authority',
                    'synthetic-connection-scope',
                    'synthetic-connection-lineage-A',
                    $connectionIdentity,
                    $revision,
                ),
                $currentness,
                $freshness,
            ),
        ];
    }

    /** @return array<string, mixed> */
    private function transitionEvidence(
        string $fromState,
        string $toState,
        string $connectionIdentity = 'synthetic-connection-A',
        string $condition = CommonContract::CONDITION_PRESENT,
        ?bool $currentness = true,
        ?bool $freshness = true,
        int $revision = 9,
    ): array {
        $participants = ['synthetic-participant-A', 'synthetic-participant-B'];
        $bindings = $this->bindings(
            'synthetic-transition-authority',
            'synthetic-transition-scope',
            'synthetic-participant-A',
            $connectionIdentity,
            $participants,
            $connectionIdentity,
            false,
        );

        return [
            'transition_identity' => 'synthetic-transition-A',
            'connection_identity' => $connectionIdentity,
            'participants' => $participants,
            'from_state' => $fromState,
            'to_state' => $toState,
            'expected_state_revision' => CommonContract::sourceRevision(
                'synthetic-connection-authority',
                'synthetic-connection-scope',
                'synthetic-connection-lineage-A',
                $connectionIdentity,
                7,
            ),
            'required_bindings' => $bindings,
            'source_evidence' => CommonContract::evidence(
                $bindings,
                $condition,
                CommonContract::sourceRevision(
                    'synthetic-transition-authority',
                    'synthetic-transition-scope',
                    'synthetic-transition-lineage-A',
                    $connectionIdentity,
                    $revision,
                ),
                $currentness,
                $freshness,
            ),
        ];
    }

    /** @return array<string, mixed> */
    private function bindings(
        string $authorityOwner,
        string $authorityScope,
        string $actor,
        string $subject,
        array $participants,
        string $context,
        bool $terminal,
    ): array {
        return [
            'authority_owner' => $authorityOwner,
            'authority_scope' => $authorityScope,
            'actor' => $actor,
            'actor_role' => 'synthetic-connection-role',
            'subject' => $subject,
            'participants' => $participants,
            'audience' => 'synthetic-connection-audience',
            'purpose' => 'synthetic-connection-transition-use',
            'aggregate_context' => $context,
            'lifecycle_identity' => $context,
            'terminal' => $terminal,
        ];
    }
}
