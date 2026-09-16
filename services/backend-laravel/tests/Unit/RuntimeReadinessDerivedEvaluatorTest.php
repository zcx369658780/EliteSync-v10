<?php

namespace Tests\Unit;

use App\Domain\CommonAuthorityEvidenceContract as CommonContract;
use App\Domain\RuntimeReadinessDerivedEvaluator as Evaluator;
use PHPUnit\Framework\TestCase;

final class RuntimeReadinessDerivedEvaluatorTest extends TestCase
{
    public function testAllExactCurrentFreshSatisfiedPrerequisitesProduceReady(): void
    {
        $result = Evaluator::derive(
            $this->prerequisiteSet(['synthetic-member-A', 'synthetic-member-B']),
            [
                $this->member('synthetic-member-A', Evaluator::FACT_CHECKLIST),
                $this->member('synthetic-member-B', Evaluator::FACT_VERIFICATION),
            ],
        );

        self::assertSame(Evaluator::READINESS_READY, $result['classification']);
        self::assertSame(Evaluator::FACT_EFFECTIVE_READINESS, $result['fact_class']);
        self::assertTrue($result['valid_for_protected_use']);
    }

    public function testReadinessFactClassesRemainDistinctAndOnlyEffectiveReadinessIsDerived(): void
    {
        self::assertCount(5, array_unique([
            Evaluator::FACT_ELIGIBILITY,
            Evaluator::FACT_CHECKLIST,
            Evaluator::FACT_VERIFICATION,
            Evaluator::FACT_EFFECTIVE_READINESS,
            Evaluator::FACT_PRESENTATION,
        ]));

        $result = Evaluator::derive($this->prerequisiteSet([]), []);

        self::assertSame(Evaluator::FACT_EFFECTIVE_READINESS, $result['fact_class']);
        self::assertNotSame(Evaluator::FACT_PRESENTATION, $result['fact_class']);
    }

    public function testUnknownPrerequisiteSetProducesUnknown(): void
    {
        $set = $this->prerequisiteSet(['synthetic-member-A']);
        $set['state'] = Evaluator::SET_UNKNOWN;

        $result = Evaluator::derive($set, [$this->member('synthetic-member-A')]);

        self::assertSame(Evaluator::READINESS_UNKNOWN, $result['classification']);
        self::assertContains('UNKNOWN_PREREQUISITE_SET', $result['reasons']);
    }

    public function testKnownEmptyPrerequisiteSetIsDistinctFromUnknownSet(): void
    {
        $empty = Evaluator::derive($this->prerequisiteSet([]), []);
        $unknownSet = $this->prerequisiteSet([]);
        $unknownSet['state'] = Evaluator::SET_UNKNOWN;
        $unknown = Evaluator::derive($unknownSet, []);

        self::assertSame(Evaluator::READINESS_READY, $empty['classification']);
        self::assertSame(Evaluator::READINESS_UNKNOWN, $unknown['classification']);
        self::assertNotSame($empty['classification'], $unknown['classification']);
    }

    public function testUnavailablePrerequisiteSetProducesUnknown(): void
    {
        $result = Evaluator::derive(
            $this->prerequisiteSet(['synthetic-member-A'], CommonContract::CONDITION_UNAVAILABLE),
            [$this->member('synthetic-member-A')],
        );

        self::assertSame(Evaluator::READINESS_UNKNOWN, $result['classification']);
    }

    public function testStalePrerequisiteSetProducesUnknown(): void
    {
        $result = Evaluator::derive(
            $this->prerequisiteSet(['synthetic-member-A'], CommonContract::CONDITION_STALE),
            [$this->member('synthetic-member-A')],
        );

        self::assertSame(Evaluator::READINESS_UNKNOWN, $result['classification']);
    }

    public function testSupersededPrerequisiteSetProducesUnknown(): void
    {
        $result = Evaluator::derive(
            $this->prerequisiteSet(['synthetic-member-A'], CommonContract::CONDITION_SUPERSEDED),
            [$this->member('synthetic-member-A')],
        );

        self::assertSame(Evaluator::READINESS_UNKNOWN, $result['classification']);
    }

    public function testIncomparablePrerequisiteSetProducesUnknown(): void
    {
        $result = Evaluator::derive(
            $this->prerequisiteSet(['synthetic-member-A'], CommonContract::CONDITION_INCOMPARABLE),
            [$this->member('synthetic-member-A')],
        );

        self::assertSame(Evaluator::READINESS_UNKNOWN, $result['classification']);
    }

    public function testCurrentButStalePrerequisiteSetProducesUnknown(): void
    {
        $result = Evaluator::derive(
            $this->prerequisiteSet(['synthetic-member-A'], currentness: true, freshness: false),
            [$this->member('synthetic-member-A')],
        );

        self::assertSame(Evaluator::READINESS_UNKNOWN, $result['classification']);
    }

    public function testFreshnessCannotManufacturePrerequisiteSetCurrentness(): void
    {
        $result = Evaluator::derive(
            $this->prerequisiteSet(['synthetic-member-A'], currentness: false, freshness: true),
            [$this->member('synthetic-member-A')],
        );

        self::assertSame(Evaluator::READINESS_UNKNOWN, $result['classification']);
    }

    public function testMissingRequiredMemberProducesUnknownNotNotReady(): void
    {
        $result = Evaluator::derive($this->prerequisiteSet(['synthetic-member-A']), []);

        self::assertSame(Evaluator::READINESS_UNKNOWN, $result['classification']);
        self::assertContains('MISSING_REQUIRED_MEMBER:synthetic-member-A', $result['reasons']);
        self::assertNotSame(Evaluator::READINESS_NOT_READY, $result['classification']);
    }

    public function testUnknownMemberConditionProducesUnknown(): void
    {
        $result = Evaluator::derive(
            $this->prerequisiteSet(['synthetic-member-A']),
            [$this->member('synthetic-member-A', condition: CommonContract::CONDITION_UNKNOWN)],
        );

        self::assertSame(Evaluator::READINESS_UNKNOWN, $result['classification']);
        self::assertStringContainsString('UNKNOWN', implode('|', $result['reasons']));
    }

    public function testAbsentMemberConditionRemainsDistinctFromUnknown(): void
    {
        $unknown = Evaluator::derive(
            $this->prerequisiteSet(['synthetic-member-A']),
            [$this->member('synthetic-member-A', condition: CommonContract::CONDITION_UNKNOWN)],
        );
        $absent = Evaluator::derive(
            $this->prerequisiteSet(['synthetic-member-A']),
            [$this->member('synthetic-member-A', condition: CommonContract::CONDITION_ABSENT)],
        );

        self::assertSame(Evaluator::READINESS_UNKNOWN, $unknown['classification']);
        self::assertSame(Evaluator::READINESS_UNKNOWN, $absent['classification']);
        self::assertNotSame($unknown['reasons'], $absent['reasons']);
        self::assertStringContainsString('ABSENT', implode('|', $absent['reasons']));
    }

    public function testOnlyAuthoritativeCurrentFreshUnsatisfiedMemberProducesNotReady(): void
    {
        $result = Evaluator::derive(
            $this->prerequisiteSet(['synthetic-member-A']),
            [$this->member('synthetic-member-A', outcome: Evaluator::OUTCOME_UNSATISFIED)],
        );

        self::assertSame(Evaluator::READINESS_NOT_READY, $result['classification']);
        self::assertContains('AUTHORITATIVE_REQUIRED_MEMBER_UNSATISFIED', $result['reasons']);
    }

    public function testSatisfiedMemberCannotRepairAnotherUnknownMember(): void
    {
        $result = Evaluator::derive(
            $this->prerequisiteSet(['synthetic-member-A', 'synthetic-member-B']),
            [
                $this->member('synthetic-member-A'),
                $this->member('synthetic-member-B', condition: CommonContract::CONDITION_UNKNOWN),
            ],
        );

        self::assertSame(Evaluator::READINESS_UNKNOWN, $result['classification']);
    }

    public function testAuthoritativeNegativeCannotOverrideAnotherUnknownMember(): void
    {
        $result = Evaluator::derive(
            $this->prerequisiteSet(['synthetic-member-A', 'synthetic-member-B']),
            [
                $this->member('synthetic-member-A', outcome: Evaluator::OUTCOME_UNSATISFIED),
                $this->member('synthetic-member-B', condition: CommonContract::CONDITION_UNKNOWN),
            ],
        );

        self::assertSame(Evaluator::READINESS_UNKNOWN, $result['classification']);
    }

    public function testCurrentButStaleMemberProducesUnknown(): void
    {
        $result = Evaluator::derive(
            $this->prerequisiteSet(['synthetic-member-A']),
            [$this->member('synthetic-member-A', currentness: true, freshness: false)],
        );

        self::assertSame(Evaluator::READINESS_UNKNOWN, $result['classification']);
    }

    public function testFreshnessCannotManufactureMemberCurrentness(): void
    {
        $result = Evaluator::derive(
            $this->prerequisiteSet(['synthetic-member-A']),
            [$this->member('synthetic-member-A', currentness: false, freshness: true)],
        );

        self::assertSame(Evaluator::READINESS_UNKNOWN, $result['classification']);
    }

    public function testMemberSourceBindingMismatchProducesUnknown(): void
    {
        $member = $this->member('synthetic-member-A');
        $member['required_bindings']['actor_role'] = 'synthetic-role-mismatch';

        $result = Evaluator::derive($this->prerequisiteSet(['synthetic-member-A']), [$member]);

        self::assertSame(Evaluator::READINESS_UNKNOWN, $result['classification']);
    }

    public function testProtectedUseScopeMismatchProducesUnknown(): void
    {
        $member = $this->member('synthetic-member-A');
        $member['protected_use_scope'] = 'synthetic-use-B';

        $result = Evaluator::derive($this->prerequisiteSet(['synthetic-member-A']), [$member]);

        self::assertSame(Evaluator::READINESS_UNKNOWN, $result['classification']);
    }

    public function testExtraNonRequiredMemberCannotInfluenceReadyResult(): void
    {
        $baseline = Evaluator::derive(
            $this->prerequisiteSet(['synthetic-member-A']),
            [$this->member('synthetic-member-A')],
        );
        $withExtra = Evaluator::derive(
            $this->prerequisiteSet(['synthetic-member-A']),
            [
                $this->member('synthetic-member-A'),
                $this->member('synthetic-extra-member', outcome: Evaluator::OUTCOME_UNSATISFIED),
            ],
        );

        self::assertSame(Evaluator::READINESS_READY, $withExtra['classification']);
        self::assertSame($baseline, $withExtra);
    }

    public function testRequiredMembersMustBelongToExactPrerequisiteSet(): void
    {
        $result = Evaluator::derive(
            $this->prerequisiteSet(['synthetic-member-A', 'synthetic-member-B']),
            [$this->member('synthetic-member-A'), $this->member('synthetic-member-C')],
        );

        self::assertSame(Evaluator::READINESS_UNKNOWN, $result['classification']);
        self::assertContains('MISSING_REQUIRED_MEMBER:synthetic-member-B', $result['reasons']);
    }

    public function testIncomparableDuplicateEvidenceFailsClosed(): void
    {
        $otherLineage = $this->member('synthetic-member-A', revision: 9);
        $otherLineage['source_evidence']['source_revision'] = CommonContract::sourceRevision(
            'synthetic-member-authority',
            'synthetic-member-scope',
            'synthetic-member-lineage-B',
            'synthetic-member-context',
            9,
        );

        $result = Evaluator::derive(
            $this->prerequisiteSet(['synthetic-member-A']),
            [$this->member('synthetic-member-A'), $otherLineage],
        );

        self::assertSame(Evaluator::READINESS_UNKNOWN, $result['classification']);
        self::assertContains('INCOMPARABLE_DUPLICATE_EVIDENCE:synthetic-member-A', $result['reasons']);
    }

    public function testConflictingEqualRevisionDuplicateEvidenceFailsClosed(): void
    {
        $result = Evaluator::derive(
            $this->prerequisiteSet(['synthetic-member-A']),
            [
                $this->member('synthetic-member-A', outcome: Evaluator::OUTCOME_SATISFIED),
                $this->member('synthetic-member-A', outcome: Evaluator::OUTCOME_UNSATISFIED),
            ],
        );

        self::assertSame(Evaluator::READINESS_UNKNOWN, $result['classification']);
        self::assertContains('CONFLICTING_DUPLICATE_EVIDENCE:synthetic-member-A', $result['reasons']);
    }

    public function testComparableNewerEvidenceControlsWithoutArrivalOrder(): void
    {
        $older = $this->member('synthetic-member-A', outcome: Evaluator::OUTCOME_UNSATISFIED, revision: 6);
        $newer = $this->member('synthetic-member-A', outcome: Evaluator::OUTCOME_SATISFIED, revision: 7);

        $olderFirst = Evaluator::derive($this->prerequisiteSet(['synthetic-member-A']), [$older, $newer]);
        $newerFirst = Evaluator::derive($this->prerequisiteSet(['synthetic-member-A']), [$newer, $older]);

        self::assertSame(Evaluator::READINESS_READY, $olderFirst['classification']);
        self::assertSame($olderFirst, $newerFirst);
        self::assertSame(7, $olderFirst['dependency_vector']['members'][0]['source_revision']['value']);
    }

    public function testDependencyVectorContainsExactSetAndRequiredMemberRevisions(): void
    {
        $result = Evaluator::derive(
            $this->prerequisiteSet(['synthetic-member-A', 'synthetic-member-B']),
            [
                $this->member('synthetic-member-A', Evaluator::FACT_ELIGIBILITY, revision: 11),
                $this->member('synthetic-member-B', Evaluator::FACT_VERIFICATION, revision: 12),
            ],
        );

        self::assertSame('synthetic-set-A', $result['dependency_vector']['prerequisite_set']['set_identity']);
        self::assertSame(3, $result['dependency_vector']['prerequisite_set']['source_revision']['value']);
        self::assertSame(['synthetic-member-A', 'synthetic-member-B'], array_column($result['dependency_vector']['members'], 'member_identity'));
        self::assertSame([11, 12], array_map(
            static fn (array $member): int => $member['source_revision']['value'],
            $result['dependency_vector']['members'],
        ));
    }

    public function testCorrectionInvalidatesPriorDerivedResultWithoutMutatingInputs(): void
    {
        $set = $this->prerequisiteSet(['synthetic-member-A']);
        $members = [$this->member('synthetic-member-A')];
        $setBefore = $set;
        $membersBefore = $members;
        $derived = Evaluator::derive($set, $members);

        $invalidated = Evaluator::invalidate(
            $derived,
            'synthetic-member-A',
            CommonContract::INVALIDATION_CORRECTION,
        );

        self::assertSame(Evaluator::READINESS_UNKNOWN, $invalidated['classification']);
        self::assertFalse($invalidated['valid_for_protected_use']);
        self::assertSame($setBefore, $set);
        self::assertSame($membersBefore, $members);
    }

    public function testRevocationInvalidatesPriorDerivedResult(): void
    {
        $derived = Evaluator::derive(
            $this->prerequisiteSet(['synthetic-member-A']),
            [$this->member('synthetic-member-A')],
        );

        $invalidated = Evaluator::invalidate(
            $derived,
            'synthetic-member-A',
            CommonContract::INVALIDATION_REVOCATION,
        );

        self::assertSame(Evaluator::READINESS_UNKNOWN, $invalidated['classification']);
        self::assertSame(CommonContract::INVALIDATION_REVOCATION, $invalidated['invalidation']['relation']);
    }

    public function testSupersessionOfSetInvalidatesPriorDerivedResult(): void
    {
        $derived = Evaluator::derive(
            $this->prerequisiteSet(['synthetic-member-A']),
            [$this->member('synthetic-member-A')],
        );

        $invalidated = Evaluator::invalidate(
            $derived,
            'synthetic-set-A',
            CommonContract::INVALIDATION_SUPERSESSION,
        );

        self::assertSame(Evaluator::READINESS_UNKNOWN, $invalidated['classification']);
        self::assertSame(CommonContract::INVALIDATION_SUPERSESSION, $invalidated['invalidation']['relation']);
    }

    public function testDerivationDoesNotBackWriteOrRepairSourceEvidence(): void
    {
        $set = $this->prerequisiteSet(['synthetic-member-A']);
        $members = [$this->member('synthetic-member-A', condition: CommonContract::CONDITION_UNKNOWN)];
        $setBefore = $set;
        $membersBefore = $members;

        $result = Evaluator::derive($set, $members);

        self::assertSame(Evaluator::READINESS_UNKNOWN, $result['classification']);
        self::assertFalse($result['source_evidence_repaired']);
        self::assertFalse($result['source_evidence_mutated']);
        self::assertSame($setBefore, $set);
        self::assertSame($membersBefore, $members);
    }

    public function testDerivedProjectionHasNoGlobalRevisionAndIsNotAuthorityOrPermission(): void
    {
        $result = Evaluator::derive(
            $this->prerequisiteSet(['synthetic-member-A']),
            [$this->member('synthetic-member-A')],
        );
        $encoded = json_encode($result);

        self::assertIsString($encoded);
        self::assertStringNotContainsString('global_revision', $encoded);
        self::assertFalse($result['source_authority']);
        self::assertFalse($result['permission']);
        self::assertFalse($result['bearer_capability']);
        self::assertFalse($result['reusable_protected_action_grant']);
    }

    public function testDerivedResultCreatesNoLaunchOrDownstreamDomainAuthority(): void
    {
        $result = Evaluator::derive($this->prerequisiteSet([]), []);

        self::assertFalse($result['launch_eligibility']);
        self::assertFalse($result['verification_truth']);
        self::assertFalse($result['match_authority']);
        self::assertFalse($result['connection_authority']);
        self::assertFalse($result['consent_authority']);
        self::assertFalse($result['conversation_authority']);
    }

    public function testOutputIsPrivacyMinimalAndOmitsSourceEvidenceAndBindings(): void
    {
        $set = $this->prerequisiteSet(['synthetic-member-A']);
        $set['synthetic_private_payload'] = 'synthetic-private-MUST-NOT-LEAK';
        $member = $this->member('synthetic-member-A');
        $member['synthetic_private_payload'] = 'synthetic-member-private-MUST-NOT-LEAK';

        $result = Evaluator::derive($set, [$member]);
        $encoded = json_encode($result);

        self::assertIsString($encoded);
        self::assertStringNotContainsString('MUST-NOT-LEAK', $encoded);
        self::assertStringNotContainsString('required_bindings', $encoded);
        self::assertStringNotContainsString('SOURCE_EVIDENCE', $encoded);
    }

    /**
     * @param list<string> $requiredMemberIds
     * @return array<string, mixed>
     */
    private function prerequisiteSet(
        array $requiredMemberIds,
        string $condition = CommonContract::CONDITION_PRESENT,
        ?bool $currentness = true,
        ?bool $freshness = true,
    ): array {
        $bindings = $this->bindings(
            'synthetic-set-authority',
            'synthetic-set-scope',
            'synthetic-set-subject',
            'synthetic-readiness-use',
            'synthetic-set-context',
        );

        return [
            'set_identity' => 'synthetic-set-A',
            'state' => Evaluator::SET_KNOWN,
            'protected_use_scope' => 'synthetic-readiness-use',
            'required_member_ids' => $requiredMemberIds,
            'required_bindings' => $bindings,
            'source_evidence' => CommonContract::evidence(
                $bindings,
                $condition,
                CommonContract::sourceRevision(
                    'synthetic-set-authority',
                    'synthetic-set-scope',
                    'synthetic-set-lineage',
                    'synthetic-set-context',
                    3,
                ),
                $currentness,
                $freshness,
            ),
        ];
    }

    /** @return array<string, mixed> */
    private function member(
        string $memberIdentity,
        string $factClass = Evaluator::FACT_CHECKLIST,
        string $condition = CommonContract::CONDITION_PRESENT,
        ?bool $currentness = true,
        ?bool $freshness = true,
        string $outcome = Evaluator::OUTCOME_SATISFIED,
        int $revision = 7,
    ): array {
        $bindings = $this->bindings(
            'synthetic-member-authority',
            'synthetic-member-scope',
            $memberIdentity,
            'synthetic-readiness-use',
            'synthetic-member-context',
        );

        return [
            'member_identity' => $memberIdentity,
            'fact_class' => $factClass,
            'protected_use_scope' => 'synthetic-readiness-use',
            'required_bindings' => $bindings,
            'source_evidence' => CommonContract::evidence(
                $bindings,
                $condition,
                CommonContract::sourceRevision(
                    'synthetic-member-authority',
                    'synthetic-member-scope',
                    'synthetic-member-lineage-A',
                    'synthetic-member-context',
                    $revision,
                ),
                $currentness,
                $freshness,
            ),
            'prerequisite_outcome' => $outcome,
        ];
    }

    /** @return array<string, mixed> */
    private function bindings(
        string $authorityOwner,
        string $authorityScope,
        string $subject,
        string $purpose,
        string $context,
    ): array {
        return [
            'authority_owner' => $authorityOwner,
            'authority_scope' => $authorityScope,
            'actor' => 'synthetic-readiness-actor',
            'actor_role' => 'synthetic-readiness-role',
            'subject' => $subject,
            'participants' => ['synthetic-readiness-participant'],
            'audience' => 'synthetic-readiness-audience',
            'purpose' => $purpose,
            'aggregate_context' => $context,
            'lifecycle_identity' => 'synthetic-readiness-lifecycle',
            'terminal' => false,
        ];
    }
}
