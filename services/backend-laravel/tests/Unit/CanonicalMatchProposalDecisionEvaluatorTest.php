<?php

namespace Tests\Unit;

use App\Domain\CanonicalMatchProposalDecisionEvaluator as Evaluator;
use App\Domain\CommonAuthorityEvidenceContract as CommonContract;
use PHPUnit\Framework\TestCase;

final class CanonicalMatchProposalDecisionEvaluatorTest extends TestCase
{
    public function testLifecycleVocabulariesRemainExactAndUnknownIsNotProposalState(): void
    {
        self::assertSame(['NOT_ENROLLED', 'ENROLLED', 'PAUSED', 'WITHDRAWN'], Evaluator::participationVocabulary());
        self::assertSame(['PENDING', 'MUTUALLY_ACCEPTED', 'DECLINED', 'WITHDRAWN', 'EXPIRED'], Evaluator::proposalLifecycleVocabulary());
        self::assertNotContains(Evaluator::DERIVED_UNKNOWN, Evaluator::proposalLifecycleVocabulary());
    }

    public function testExactlyTwoDistinctParticipantsAreRequired(): void
    {
        $one = $this->proposal();
        $one['participants'] = ['synthetic-participant-A'];
        $three = $this->proposal();
        $three['participants'][] = 'synthetic-participant-C';
        $duplicate = $this->proposal();
        $duplicate['participants'] = ['synthetic-participant-A', 'synthetic-participant-A'];

        self::assertSame(Evaluator::DERIVED_UNKNOWN, Evaluator::evaluate($one, [], [])['classification']);
        self::assertSame(Evaluator::DERIVED_UNKNOWN, Evaluator::evaluate($three, [], [])['classification']);
        self::assertSame(Evaluator::DERIVED_UNKNOWN, Evaluator::evaluate($duplicate, [], [])['classification']);
    }

    public function testProposalIdentityAndParticipantsRemainExplicit(): void
    {
        $result = $this->evaluatePending([
            $this->slot('synthetic-participant-A'),
            $this->slot('synthetic-participant-B'),
        ]);

        self::assertSame('synthetic-proposal-A', $result['proposal_identity']);
        self::assertSame(['synthetic-participant-A', 'synthetic-participant-B'], $result['participants']);
    }

    public function testOneSidedAcceptanceRemainsPending(): void
    {
        $result = $this->evaluatePending([
            $this->slot('synthetic-participant-A', Evaluator::SLOT_ACCEPTED),
            $this->slot('synthetic-participant-B', Evaluator::SLOT_PENDING),
        ]);

        self::assertSame(Evaluator::PROPOSAL_PENDING, $result['classification']);
        self::assertNotSame(Evaluator::PROPOSAL_MUTUALLY_ACCEPTED, $result['classification']);
    }

    public function testTwoCurrentFreshExactProposalAcceptSlotsDeriveMutualAcceptance(): void
    {
        $result = $this->evaluatePending([
            $this->slot('synthetic-participant-A', Evaluator::SLOT_ACCEPTED),
            $this->slot('synthetic-participant-B', Evaluator::SLOT_ACCEPTED),
        ]);

        self::assertSame(Evaluator::PROPOSAL_MUTUALLY_ACCEPTED, $result['classification']);
        self::assertCount(2, $result['dependency_vector']['decision_slots']);
    }

    public function testCrossProposalSlotFailsClosed(): void
    {
        $result = $this->evaluatePending([
            $this->slot('synthetic-participant-A', proposalIdentity: 'synthetic-proposal-B'),
            $this->slot('synthetic-participant-B'),
        ]);

        self::assertSame(Evaluator::DERIVED_UNKNOWN, $result['classification']);
        self::assertContains('CROSS_PROPOSAL_SLOT', $result['reasons']);
    }

    public function testWrongParticipantSlotFailsClosed(): void
    {
        $result = $this->evaluatePending([
            $this->slot('synthetic-participant-A'),
            $this->slot('synthetic-participant-C'),
        ]);

        self::assertSame(Evaluator::DERIVED_UNKNOWN, $result['classification']);
        self::assertContains('WRONG_PARTICIPANT_SLOT', $result['reasons']);
    }

    public function testConflictingEqualRevisionDuplicateFailsClosed(): void
    {
        $result = $this->evaluatePending([
            $this->slot('synthetic-participant-A', Evaluator::SLOT_ACCEPTED),
            $this->slot('synthetic-participant-A', Evaluator::SLOT_DECLINED),
            $this->slot('synthetic-participant-B'),
        ]);

        self::assertSame(Evaluator::DERIVED_UNKNOWN, $result['classification']);
        self::assertContains('CONFLICTING_EQUAL_REVISION_SLOT:synthetic-participant-A', $result['reasons']);
    }

    public function testIncomparableDuplicateRevisionFailsClosed(): void
    {
        $otherLineage = $this->slot('synthetic-participant-A', revision: 8);
        $otherLineage['source_evidence']['source_revision'] = CommonContract::sourceRevision(
            'synthetic-slot-authority',
            'synthetic-slot-scope',
            'synthetic-slot-lineage-B',
            'synthetic-proposal-A',
            8,
        );

        $result = $this->evaluatePending([
            $this->slot('synthetic-participant-A'),
            $otherLineage,
            $this->slot('synthetic-participant-B'),
        ]);

        self::assertSame(Evaluator::DERIVED_UNKNOWN, $result['classification']);
        self::assertContains('INCOMPARABLE_DUPLICATE_SLOT:synthetic-participant-A', $result['reasons']);
    }

    public function testComparableNewerSlotControlsWithoutArrivalOrder(): void
    {
        $older = $this->slot('synthetic-participant-A', Evaluator::SLOT_DECLINED, revision: 6);
        $newer = $this->slot('synthetic-participant-A', Evaluator::SLOT_ACCEPTED, revision: 7);
        $participantB = $this->slot('synthetic-participant-B', Evaluator::SLOT_ACCEPTED);

        $olderFirst = $this->evaluatePending([$older, $newer, $participantB]);
        $newerFirst = $this->evaluatePending([$newer, $older, $participantB]);

        self::assertSame(Evaluator::PROPOSAL_MUTUALLY_ACCEPTED, $olderFirst['classification']);
        self::assertSame($olderFirst, $newerFirst);
        self::assertSame(7, $olderFirst['dependency_vector']['decision_slots'][0]['source_revision']['value']);
    }

    public function testMissingSlotYieldsUnknownNotDeclined(): void
    {
        $result = $this->evaluatePending([$this->slot('synthetic-participant-A')]);

        self::assertSame(Evaluator::DERIVED_UNKNOWN, $result['classification']);
        self::assertNotSame(Evaluator::PROPOSAL_DECLINED, $result['classification']);
    }

    public function testNonUsableSlotConditionsYieldUnknown(): void
    {
        foreach ([
            CommonContract::CONDITION_UNKNOWN,
            CommonContract::CONDITION_UNAVAILABLE,
            CommonContract::CONDITION_STALE,
            CommonContract::CONDITION_SUPERSEDED,
            CommonContract::CONDITION_INCOMPARABLE,
        ] as $condition) {
            $result = $this->evaluatePending([
                $this->slot('synthetic-participant-A', condition: $condition),
                $this->slot('synthetic-participant-B'),
            ]);

            self::assertSame(Evaluator::DERIVED_UNKNOWN, $result['classification']);
        }
    }

    public function testCurrentButStaleSlotFailsClosed(): void
    {
        $result = $this->evaluatePending([
            $this->slot('synthetic-participant-A', currentness: true, freshness: false),
            $this->slot('synthetic-participant-B'),
        ]);

        self::assertSame(Evaluator::DERIVED_UNKNOWN, $result['classification']);
    }

    public function testFreshnessCannotManufactureSlotCurrentness(): void
    {
        $result = $this->evaluatePending([
            $this->slot('synthetic-participant-A', currentness: false, freshness: true),
            $this->slot('synthetic-participant-B'),
        ]);

        self::assertSame(Evaluator::DERIVED_UNKNOWN, $result['classification']);
    }

    public function testSourceBindingMismatchFailsClosed(): void
    {
        $slot = $this->slot('synthetic-participant-A');
        $slot['required_bindings']['subject'] = 'synthetic-participant-B';

        $result = $this->evaluatePending([$slot, $this->slot('synthetic-participant-B')]);

        self::assertSame(Evaluator::DERIVED_UNKNOWN, $result['classification']);
    }

    public function testNoGlobalRevisionAppearsInDerivedResult(): void
    {
        $result = $this->evaluatePending([
            $this->slot('synthetic-participant-A'),
            $this->slot('synthetic-participant-B'),
        ]);
        $encoded = json_encode($result);

        self::assertIsString($encoded);
        self::assertStringNotContainsString('global_revision', $encoded);
    }

    public function testPausedParticipationPreventsPendingAcceptanceUse(): void
    {
        $result = Evaluator::evaluate(
            $this->proposal(),
            [
                $this->participation('synthetic-participant-A', Evaluator::PARTICIPATION_PAUSED),
                $this->participation('synthetic-participant-B'),
            ],
            [$this->slot('synthetic-participant-A', Evaluator::SLOT_ACCEPTED), $this->slot('synthetic-participant-B', Evaluator::SLOT_ACCEPTED)],
        );

        self::assertSame(Evaluator::DERIVED_UNKNOWN, $result['classification']);
    }

    public function testWithdrawnParticipationPreventsPendingAcceptanceUse(): void
    {
        $result = Evaluator::evaluate(
            $this->proposal(),
            [
                $this->participation('synthetic-participant-A', Evaluator::PARTICIPATION_WITHDRAWN),
                $this->participation('synthetic-participant-B'),
            ],
            [$this->slot('synthetic-participant-A', Evaluator::SLOT_ACCEPTED), $this->slot('synthetic-participant-B', Evaluator::SLOT_ACCEPTED)],
        );

        self::assertSame(Evaluator::DERIVED_UNKNOWN, $result['classification']);
    }

    public function testTerminalProposalIdentityCannotReopenFromAcceptSlots(): void
    {
        $result = Evaluator::evaluate(
            $this->proposal(Evaluator::PROPOSAL_DECLINED),
            [],
            [$this->slot('synthetic-participant-A', Evaluator::SLOT_ACCEPTED), $this->slot('synthetic-participant-B', Evaluator::SLOT_ACCEPTED)],
        );

        self::assertSame(Evaluator::PROPOSAL_DECLINED, $result['classification']);
        self::assertFalse($result['proposal_reopened']);
        self::assertFalse($result['lifecycle_reset']);
    }

    public function testLaterLifecycleRequiresFreshProposalIdentityAndSlots(): void
    {
        $terminal = Evaluator::evaluate($this->proposal(Evaluator::PROPOSAL_EXPIRED), [], []);
        $newProposal = $this->proposal(proposalIdentity: 'synthetic-proposal-B');
        $newResult = Evaluator::evaluate(
            $newProposal,
            [$this->participation('synthetic-participant-A'), $this->participation('synthetic-participant-B')],
            [
                $this->slot('synthetic-participant-A', Evaluator::SLOT_ACCEPTED, 'synthetic-proposal-B'),
                $this->slot('synthetic-participant-B', Evaluator::SLOT_ACCEPTED, 'synthetic-proposal-B'),
            ],
        );

        self::assertSame(Evaluator::PROPOSAL_EXPIRED, $terminal['classification']);
        self::assertSame(Evaluator::PROPOSAL_MUTUALLY_ACCEPTED, $newResult['classification']);
        self::assertNotSame($terminal['proposal_identity'], $newResult['proposal_identity']);
    }

    public function testDeclineIsConsumedOnlyFromValidCurrentAuthoritativeEvidence(): void
    {
        $valid = Evaluator::evaluate($this->proposal(Evaluator::PROPOSAL_DECLINED), [], []);
        $stale = Evaluator::evaluate(
            $this->proposal(Evaluator::PROPOSAL_DECLINED, condition: CommonContract::CONDITION_STALE),
            [],
            [],
        );

        self::assertSame(Evaluator::PROPOSAL_DECLINED, $valid['classification']);
        self::assertSame(Evaluator::DERIVED_UNKNOWN, $stale['classification']);
    }

    public function testWithdrawalRequiresValidActorBoundAuthoritativeEvidence(): void
    {
        $valid = Evaluator::evaluate(
            $this->proposal(Evaluator::PROPOSAL_WITHDRAWN, actor: 'synthetic-participant-A'),
            [],
            [],
        );
        $invalid = $this->proposal(Evaluator::PROPOSAL_WITHDRAWN, actor: 'synthetic-participant-A');
        $invalid['required_bindings']['actor'] = 'synthetic-participant-B';

        self::assertSame(Evaluator::PROPOSAL_WITHDRAWN, $valid['classification']);
        self::assertSame(Evaluator::DERIVED_UNKNOWN, Evaluator::evaluate($invalid, [], [])['classification']);
    }

    public function testExpiryIsConsumedAsAuthoritativeStateWithoutClockPolicy(): void
    {
        $result = Evaluator::evaluate($this->proposal(Evaluator::PROPOSAL_EXPIRED), [], []);
        $encoded = json_encode($result);

        self::assertSame(Evaluator::PROPOSAL_EXPIRED, $result['classification']);
        self::assertIsString($encoded);
        self::assertStringNotContainsString('duration', $encoded);
        self::assertStringNotContainsString('clock', $encoded);
    }

    public function testAcceptedTerminalStateCannotBeOverriddenByStaleLaterSlots(): void
    {
        $result = Evaluator::evaluate(
            $this->proposal(Evaluator::PROPOSAL_MUTUALLY_ACCEPTED),
            [],
            [
                $this->slot('synthetic-participant-A', Evaluator::SLOT_DECLINED, condition: CommonContract::CONDITION_STALE),
                $this->slot('synthetic-participant-B', Evaluator::SLOT_DECLINED, condition: CommonContract::CONDITION_STALE),
            ],
        );

        self::assertSame(Evaluator::PROPOSAL_MUTUALLY_ACCEPTED, $result['classification']);
    }

    public function testUnresolvedProposalPolicyIsOnlyConsumedAsPrecondition(): void
    {
        $proposal = $this->proposal();
        $proposal['at_most_one_unresolved_precondition'] = false;

        $result = Evaluator::evaluate(
            $proposal,
            [$this->participation('synthetic-participant-A'), $this->participation('synthetic-participant-B')],
            [$this->slot('synthetic-participant-A'), $this->slot('synthetic-participant-B')],
        );

        self::assertSame(Evaluator::DERIVED_UNKNOWN, $result['classification']);
    }

    public function testEvaluatorCreatesNoDownstreamAuthorityOrRankingSignals(): void
    {
        $result = $this->evaluatePending([$this->slot('synthetic-participant-A'), $this->slot('synthetic-participant-B')]);

        self::assertFalse($result['product_connection_created']);
        self::assertFalse($result['messaging_consent_authority']);
        self::assertFalse($result['conversation_authority']);
        self::assertFalse($result['relationship_authority']);
        self::assertFalse($result['home_authority']);
        self::assertFalse($result['notification_authority']);
        self::assertFalse($result['launch_eligibility']);
        self::assertFalse($result['ranking_computed']);
        self::assertFalse($result['compatibility_total_computed']);
        self::assertFalse($result['person_worth_inferred']);
    }

    public function testEvaluationDoesNotMutateParticipationProposalOrSlotEvidence(): void
    {
        $proposal = $this->proposal();
        $participation = [$this->participation('synthetic-participant-A'), $this->participation('synthetic-participant-B')];
        $slots = [$this->slot('synthetic-participant-A'), $this->slot('synthetic-participant-B')];
        $proposalBefore = $proposal;
        $participationBefore = $participation;
        $slotsBefore = $slots;

        $result = Evaluator::evaluate($proposal, $participation, $slots);

        self::assertFalse($result['source_evidence_mutated']);
        self::assertSame($proposalBefore, $proposal);
        self::assertSame($participationBefore, $participation);
        self::assertSame($slotsBefore, $slots);
    }

    public function testPrivacyMinimalResultOmitsRawPrivateFixturePayload(): void
    {
        $proposal = $this->proposal();
        $proposal['synthetic_private_reason'] = 'synthetic-private-MUST-NOT-LEAK';
        $slotA = $this->slot('synthetic-participant-A');
        $slotA['synthetic_private_reason'] = 'synthetic-slot-private-MUST-NOT-LEAK';
        $result = Evaluator::evaluate(
            $proposal,
            [$this->participation('synthetic-participant-A'), $this->participation('synthetic-participant-B')],
            [$slotA, $this->slot('synthetic-participant-B')],
        );
        $encoded = json_encode($result);

        self::assertIsString($encoded);
        self::assertStringNotContainsString('MUST-NOT-LEAK', $encoded);
        self::assertStringNotContainsString('required_bindings', $encoded);
        self::assertFalse($result['source_authority']);
        self::assertFalse($result['permission']);
        self::assertFalse($result['bearer_capability']);
    }

    public function testCorrectionRevocationAndSupersessionInvalidateWithoutReopening(): void
    {
        $derived = $this->evaluatePending([
            $this->slot('synthetic-participant-A', Evaluator::SLOT_ACCEPTED),
            $this->slot('synthetic-participant-B', Evaluator::SLOT_ACCEPTED),
        ]);

        foreach ([
            CommonContract::INVALIDATION_CORRECTION,
            CommonContract::INVALIDATION_REVOCATION,
            CommonContract::INVALIDATION_SUPERSESSION,
        ] as $relation) {
            $invalidated = Evaluator::invalidate($derived, 'synthetic-slot-synthetic-participant-A', $relation);

            self::assertSame(Evaluator::DERIVED_UNKNOWN, $invalidated['classification']);
            self::assertFalse($invalidated['valid_for_protected_use']);
            self::assertFalse($invalidated['lifecycle_reset']);
            self::assertFalse($invalidated['proposal_reopened']);
            self::assertSame('synthetic-proposal-A', $invalidated['proposal_identity']);
        }
    }

    /** @param list<array<string, mixed>> $slots */
    private function evaluatePending(array $slots): array
    {
        return Evaluator::evaluate(
            $this->proposal(),
            [$this->participation('synthetic-participant-A'), $this->participation('synthetic-participant-B')],
            $slots,
        );
    }

    /** @return array<string, mixed> */
    private function proposal(
        string $state = Evaluator::PROPOSAL_PENDING,
        string $proposalIdentity = 'synthetic-proposal-A',
        string $condition = CommonContract::CONDITION_PRESENT,
        ?bool $currentness = true,
        ?bool $freshness = true,
        string $actor = 'synthetic-match-authority-actor',
    ): array {
        $terminal = $state !== Evaluator::PROPOSAL_PENDING;
        $bindings = $this->bindings(
            'synthetic-proposal-authority',
            'synthetic-proposal-scope',
            $actor,
            $proposalIdentity,
            ['synthetic-participant-A', 'synthetic-participant-B'],
            'synthetic-match-use',
            $proposalIdentity,
            $terminal,
        );

        return [
            'proposal_identity' => $proposalIdentity,
            'lifecycle_state' => $state,
            'participants' => ['synthetic-participant-A', 'synthetic-participant-B'],
            'protected_use_scope' => 'synthetic-match-use',
            'at_most_one_unresolved_precondition' => true,
            'required_bindings' => $bindings,
            'source_evidence' => CommonContract::evidence(
                $bindings,
                $condition,
                CommonContract::sourceRevision(
                    'synthetic-proposal-authority',
                    'synthetic-proposal-scope',
                    'synthetic-proposal-lineage',
                    $proposalIdentity,
                    4,
                ),
                $currentness,
                $freshness,
            ),
        ];
    }

    /** @return array<string, mixed> */
    private function participation(
        string $participantIdentity,
        string $state = Evaluator::PARTICIPATION_ENROLLED,
    ): array {
        $context = 'synthetic-participation-'.$participantIdentity;
        $bindings = $this->bindings(
            'synthetic-participation-authority',
            'synthetic-participation-scope',
            $participantIdentity,
            $participantIdentity,
            [$participantIdentity],
            'synthetic-match-use',
            $context,
            $state === Evaluator::PARTICIPATION_WITHDRAWN,
        );

        return [
            'participant_identity' => $participantIdentity,
            'state' => $state,
            'required_bindings' => $bindings,
            'source_evidence' => CommonContract::evidence(
                $bindings,
                CommonContract::CONDITION_PRESENT,
                CommonContract::sourceRevision(
                    'synthetic-participation-authority',
                    'synthetic-participation-scope',
                    'synthetic-participation-lineage',
                    $context,
                    5,
                ),
                true,
                true,
            ),
        ];
    }

    /** @return array<string, mixed> */
    private function slot(
        string $participantIdentity,
        string $decision = Evaluator::SLOT_PENDING,
        string $proposalIdentity = 'synthetic-proposal-A',
        string $condition = CommonContract::CONDITION_PRESENT,
        ?bool $currentness = true,
        ?bool $freshness = true,
        int $revision = 7,
    ): array {
        $bindings = $this->bindings(
            'synthetic-slot-authority',
            'synthetic-slot-scope',
            $participantIdentity,
            $participantIdentity,
            [$participantIdentity],
            'synthetic-match-use',
            $proposalIdentity,
            false,
        );

        return [
            'slot_identity' => 'synthetic-slot-'.$participantIdentity,
            'proposal_identity' => $proposalIdentity,
            'participant_identity' => $participantIdentity,
            'protected_use_scope' => 'synthetic-match-use',
            'decision' => $decision,
            'required_bindings' => $bindings,
            'source_evidence' => CommonContract::evidence(
                $bindings,
                $condition,
                CommonContract::sourceRevision(
                    'synthetic-slot-authority',
                    'synthetic-slot-scope',
                    'synthetic-slot-lineage-A',
                    $proposalIdentity,
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
        string $purpose,
        string $context,
        bool $terminal,
    ): array {
        return [
            'authority_owner' => $authorityOwner,
            'authority_scope' => $authorityScope,
            'actor' => $actor,
            'actor_role' => 'synthetic-match-role',
            'subject' => $subject,
            'participants' => $participants,
            'audience' => 'synthetic-match-audience',
            'purpose' => $purpose,
            'aggregate_context' => $context,
            'lifecycle_identity' => $context,
            'terminal' => $terminal,
        ];
    }
}
