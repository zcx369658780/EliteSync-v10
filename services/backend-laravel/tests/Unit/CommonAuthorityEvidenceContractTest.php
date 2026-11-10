<?php

namespace Tests\Unit;

use App\Domain\CommonAuthorityEvidenceContract as Contract;
use PHPUnit\Framework\TestCase;

final class CommonAuthorityEvidenceContractTest extends TestCase
{
    public function testCompleteBindingIsPreservedAndCanSatisfyProtectedEvaluation(): void
    {
        $bindings = $this->syntheticBindings();
        $evidence = $this->syntheticEvidence();

        self::assertSame($bindings, $evidence['bindings']);
        self::assertSame(['satisfied' => true, 'reasons' => []], Contract::evaluateProtected($evidence, $bindings));
    }

    public function testAuthorityOwnerOrScopeMismatchFailsClosed(): void
    {
        $required = $this->syntheticBindings();
        $required['authority_owner'] = 'synthetic-owner-B';
        $ownerResult = Contract::evaluateProtected($this->syntheticEvidence(), $required);

        $required = $this->syntheticBindings();
        $required['authority_scope'] = 'synthetic-scope-B';
        $scopeResult = Contract::evaluateProtected($this->syntheticEvidence(), $required);

        self::assertFalse($ownerResult['satisfied']);
        self::assertContains('BINDING_MISMATCH:authority_owner', $ownerResult['reasons']);
        self::assertFalse($scopeResult['satisfied']);
        self::assertContains('BINDING_MISMATCH:authority_scope', $scopeResult['reasons']);
    }

    public function testActorOrRoleMismatchFailsClosed(): void
    {
        $required = $this->syntheticBindings();
        $required['actor'] = 'synthetic-actor-B';
        self::assertFalse(Contract::evaluateProtected($this->syntheticEvidence(), $required)['satisfied']);

        $required = $this->syntheticBindings();
        $required['actor_role'] = 'synthetic-role-B';
        self::assertFalse(Contract::evaluateProtected($this->syntheticEvidence(), $required)['satisfied']);
    }

    public function testSubjectOrParticipantMismatchFailsClosed(): void
    {
        $required = $this->syntheticBindings();
        $required['subject'] = 'synthetic-subject-B';
        self::assertFalse(Contract::evaluateProtected($this->syntheticEvidence(), $required)['satisfied']);

        $required = $this->syntheticBindings();
        $required['participants'] = ['synthetic-participant-A'];
        self::assertFalse(Contract::evaluateProtected($this->syntheticEvidence(), $required)['satisfied']);
    }

    public function testAudienceOrPurposeMismatchFailsClosed(): void
    {
        $required = $this->syntheticBindings();
        $required['audience'] = 'synthetic-audience-B';
        self::assertFalse(Contract::evaluateProtected($this->syntheticEvidence(), $required)['satisfied']);

        $required = $this->syntheticBindings();
        $required['purpose'] = 'synthetic-purpose-B';
        self::assertFalse(Contract::evaluateProtected($this->syntheticEvidence(), $required)['satisfied']);
    }

    public function testMissingRequiredBindingFailsClosed(): void
    {
        $required = $this->syntheticBindings();
        unset($required['purpose']);

        $result = Contract::evaluateProtected($this->syntheticEvidence(), $required);

        self::assertFalse($result['satisfied']);
        self::assertContains('MISSING_REQUIRED_BINDING:purpose', $result['reasons']);
    }

    public function testUnknownAndAbsentRemainDistinctAndBothFailClosed(): void
    {
        self::assertNotSame(Contract::CONDITION_UNKNOWN, Contract::CONDITION_ABSENT);

        $unknown = $this->syntheticEvidence(Contract::CONDITION_UNKNOWN);
        $absent = $this->syntheticEvidence(Contract::CONDITION_ABSENT);

        self::assertSame(Contract::CONDITION_UNKNOWN, $unknown['source_condition']);
        self::assertSame(Contract::CONDITION_ABSENT, $absent['source_condition']);
        self::assertFalse(Contract::evaluateProtected($unknown, $this->syntheticBindings())['satisfied']);
        self::assertFalse(Contract::evaluateProtected($absent, $this->syntheticBindings())['satisfied']);
    }

    public function testAllNonPresentSourceConditionsFailClosed(): void
    {
        foreach ([
            Contract::CONDITION_UNKNOWN,
            Contract::CONDITION_UNAVAILABLE,
            Contract::CONDITION_STALE,
            Contract::CONDITION_SUPERSEDED,
            Contract::CONDITION_INCOMPARABLE,
        ] as $condition) {
            self::assertFalse(
                Contract::evaluateProtected($this->syntheticEvidence($condition), $this->syntheticBindings())['satisfied']
            );
        }
    }

    public function testSameLineageSourceLocalRevisionsCanBeCompared(): void
    {
        $older = $this->syntheticRevision(2);
        $newer = $this->syntheticRevision(3);

        self::assertSame(Contract::REVISION_OLDER, Contract::compareSourceRevisions($older, $newer));
        self::assertSame(Contract::REVISION_NEWER, Contract::compareSourceRevisions($newer, $older));
        self::assertSame(Contract::REVISION_EQUAL, Contract::compareSourceRevisions($older, $older));
    }

    public function testCrossLineageOrContextRevisionComparisonIsIncomparable(): void
    {
        $otherLineage = Contract::sourceRevision(
            'synthetic-owner-A',
            'synthetic-scope-A',
            'synthetic-lineage-B',
            'synthetic-context-A',
            99,
        );
        $otherContext = Contract::sourceRevision(
            'synthetic-owner-A',
            'synthetic-scope-A',
            'synthetic-lineage-A',
            'synthetic-context-B',
            99,
        );

        self::assertSame(Contract::CONDITION_INCOMPARABLE, Contract::compareSourceRevisions($this->syntheticRevision(), $otherLineage));
        self::assertSame(Contract::CONDITION_INCOMPARABLE, Contract::compareSourceRevisions($this->syntheticRevision(), $otherContext));
    }

    public function testRevisionAndProjectionContainNoGlobalRevision(): void
    {
        $revision = $this->syntheticRevision();
        $projection = Contract::privacyMinimalProjection($this->syntheticEvidence());

        self::assertArrayNotHasKey('global_revision', $revision);
        self::assertArrayNotHasKey('global_revision', $projection);
        self::assertArrayHasKey('revision_lineage', $projection);
        self::assertArrayHasKey('revision_value', $projection);
    }

    public function testCurrentEvidenceCanStillBeStaleForItsPurpose(): void
    {
        $evidence = $this->syntheticEvidence(Contract::CONDITION_PRESENT, true, false);
        $result = Contract::evaluateProtected($evidence, $this->syntheticBindings());

        self::assertTrue($evidence['currentness']);
        self::assertFalse($evidence['freshness']);
        self::assertFalse($result['satisfied']);
        self::assertContains('NOT_FRESH', $result['reasons']);
    }

    public function testFreshnessCannotManufactureCurrentness(): void
    {
        $evidence = $this->syntheticEvidence(Contract::CONDITION_PRESENT, false, true);
        $result = Contract::evaluateProtected($evidence, $this->syntheticBindings());

        self::assertFalse($evidence['currentness']);
        self::assertTrue($evidence['freshness']);
        self::assertFalse($result['satisfied']);
        self::assertContains('NOT_CURRENT', $result['reasons']);
    }

    public function testExactIntentDuplicateCorrelates(): void
    {
        $registered = Contract::bindIntent('synthetic-intent-A', $this->syntheticIntentInput());
        $candidate = Contract::bindIntent('synthetic-intent-A', $this->syntheticIntentInput());

        self::assertSame(Contract::INTENT_EXACT_DUPLICATE, Contract::correlateIntent($registered, $candidate));
    }

    public function testDifferentIntentIdentityDoesNotCorrelateAsDuplicate(): void
    {
        $registered = Contract::bindIntent('synthetic-intent-A', $this->syntheticIntentInput());
        $candidate = Contract::bindIntent('synthetic-intent-B', $this->syntheticIntentInput());

        self::assertSame(Contract::INTENT_DISTINCT, Contract::correlateIntent($registered, $candidate));
    }

    public function testSameIntentWithChangedOwnerOrScopeIsRejected(): void
    {
        $registered = Contract::bindIntent('synthetic-intent-A', $this->syntheticIntentInput());
        $changed = $this->syntheticIntentInput();
        $changed['authority_owner'] = 'synthetic-owner-B';
        self::assertSame(
            Contract::INTENT_CHANGED_INPUT_REJECTED,
            Contract::correlateIntent($registered, Contract::bindIntent('synthetic-intent-A', $changed)),
        );

        $changed = $this->syntheticIntentInput();
        $changed['authority_scope'] = 'synthetic-scope-B';
        self::assertSame(
            Contract::INTENT_CHANGED_INPUT_REJECTED,
            Contract::correlateIntent($registered, Contract::bindIntent('synthetic-intent-A', $changed)),
        );
    }

    public function testSameIntentWithChangedSubjectOrParticipantsIsRejected(): void
    {
        $registered = Contract::bindIntent('synthetic-intent-A', $this->syntheticIntentInput());
        $changed = $this->syntheticIntentInput();
        $changed['subject'] = 'synthetic-subject-B';
        self::assertSame(
            Contract::INTENT_CHANGED_INPUT_REJECTED,
            Contract::correlateIntent($registered, Contract::bindIntent('synthetic-intent-A', $changed)),
        );

        $changed = $this->syntheticIntentInput();
        $changed['participants'] = ['synthetic-participant-A'];
        self::assertSame(
            Contract::INTENT_CHANGED_INPUT_REJECTED,
            Contract::correlateIntent($registered, Contract::bindIntent('synthetic-intent-A', $changed)),
        );
    }

    public function testSameIntentWithChangedContextOrExpectedRevisionIsRejected(): void
    {
        $registered = Contract::bindIntent('synthetic-intent-A', $this->syntheticIntentInput());
        $changed = $this->syntheticIntentInput();
        $changed['aggregate_context'] = 'synthetic-context-B';
        self::assertSame(
            Contract::INTENT_CHANGED_INPUT_REJECTED,
            Contract::correlateIntent($registered, Contract::bindIntent('synthetic-intent-A', $changed)),
        );

        $changed = $this->syntheticIntentInput();
        $changed['expected_revision'] = 8;
        self::assertSame(
            Contract::INTENT_CHANGED_INPUT_REJECTED,
            Contract::correlateIntent($registered, Contract::bindIntent('synthetic-intent-A', $changed)),
        );
    }

    public function testSameIntentWithChangedAudienceOrPurposeIsRejected(): void
    {
        $registered = Contract::bindIntent('synthetic-intent-A', $this->syntheticIntentInput());
        $changed = $this->syntheticIntentInput();
        $changed['audience'] = 'synthetic-audience-B';
        self::assertSame(
            Contract::INTENT_CHANGED_INPUT_REJECTED,
            Contract::correlateIntent($registered, Contract::bindIntent('synthetic-intent-A', $changed)),
        );

        $changed = $this->syntheticIntentInput();
        $changed['purpose'] = 'synthetic-purpose-B';
        self::assertSame(
            Contract::INTENT_CHANGED_INPUT_REJECTED,
            Contract::correlateIntent($registered, Contract::bindIntent('synthetic-intent-A', $changed)),
        );
    }

    public function testIdempotencyCorrelationIsNeitherPermissionNorSuccess(): void
    {
        $meaning = Contract::idempotencyMeaning(Contract::INTENT_EXACT_DUPLICATE);

        self::assertTrue($meaning['correlation']);
        self::assertFalse($meaning['permission']);
        self::assertFalse($meaning['success']);
    }

    public function testTransportObservationCannotDecideAuthoritativeOutcome(): void
    {
        self::assertSame(Contract::OUTCOME_UNKNOWN, Contract::outcomeAfterTransport('AMBIGUOUS'));
        self::assertSame(Contract::OUTCOME_UNKNOWN, Contract::outcomeAfterTransport('ACKNOWLEDGED'));
        self::assertSame(Contract::OUTCOME_UNKNOWN, Contract::outcomeAfterTransport('FAILED'));
    }

    public function testOnlySourceAuthoritativeReconciliationResolvesUnknownOutcome(): void
    {
        self::assertSame(Contract::OUTCOME_UNKNOWN, Contract::reconcileOutcome(Contract::OUTCOME_COMMITTED, false));
        self::assertSame(Contract::OUTCOME_COMMITTED, Contract::reconcileOutcome(Contract::OUTCOME_COMMITTED, true));
        self::assertSame(Contract::OUTCOME_REJECTED, Contract::reconcileOutcome(Contract::OUTCOME_REJECTED, true));
    }

    public function testCorrectionInvalidatesEvidenceAndProjection(): void
    {
        $result = Contract::invalidate($this->syntheticEvidence(), Contract::INVALIDATION_CORRECTION);

        self::assertFalse($result['valid_for_protected_use']);
        self::assertTrue($result['projection_invalidated']);
        self::assertSame(Contract::INVALIDATION_CORRECTION, $result['relation']);
    }

    public function testRevocationInvalidatesEvidenceAndProjection(): void
    {
        $result = Contract::invalidate($this->syntheticEvidence(), Contract::INVALIDATION_REVOCATION);

        self::assertFalse($result['valid_for_protected_use']);
        self::assertTrue($result['projection_invalidated']);
        self::assertSame(Contract::INVALIDATION_REVOCATION, $result['relation']);
    }

    public function testSupersessionInvalidatesEvidenceAndProjection(): void
    {
        $result = Contract::invalidate($this->syntheticEvidence(), Contract::INVALIDATION_SUPERSESSION);

        self::assertFalse($result['valid_for_protected_use']);
        self::assertTrue($result['projection_invalidated']);
        self::assertSame(Contract::INVALIDATION_SUPERSESSION, $result['relation']);
    }

    public function testInvalidationDoesNotResetOrReopenLifecycleIdentity(): void
    {
        $result = Contract::invalidate($this->syntheticEvidence(), Contract::INVALIDATION_SUPERSESSION);

        self::assertSame('synthetic-lifecycle-A', $result['lifecycle_identity']);
        self::assertTrue($result['terminal']);
        self::assertFalse($result['lifecycle_reset']);
        self::assertFalse($result['reopened']);
        self::assertFalse($result['new_aggregate_created']);
        self::assertFalse($result['transition_synthesized']);
    }

    public function testPrivacyMinimalProjectionExcludesRawOrPrivateMaterial(): void
    {
        $evidence = $this->syntheticEvidence();
        $evidence['synthetic_private_material'] = 'synthetic-private-material-MUST-NOT-LEAK';
        $projection = Contract::privacyMinimalProjection($evidence);
        $encoded = json_encode($projection);

        self::assertArrayNotHasKey('bindings', $projection);
        self::assertArrayNotHasKey('synthetic_private_material', $projection);
        self::assertIsString($encoded);
        self::assertStringNotContainsString('MUST-NOT-LEAK', $encoded);
    }

    public function testProjectionIsNotAuthorityPermissionCapabilitySuccessOrWriter(): void
    {
        $projection = Contract::privacyMinimalProjection($this->syntheticEvidence());
        $evaluation = Contract::evaluateProtected($projection, $this->syntheticBindings());

        self::assertFalse($projection['source_authority']);
        self::assertFalse($projection['permission']);
        self::assertFalse($projection['bearer_capability']);
        self::assertFalse($projection['success_proof']);
        self::assertFalse($projection['substitute_writer']);
        self::assertSame(['satisfied' => false, 'reasons' => ['NOT_SOURCE_AUTHORITY']], $evaluation);
    }

    /** @return array<string, mixed> */
    private function syntheticBindings(): array
    {
        return [
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
            'terminal' => true,
        ];
    }

    /** @return array<string, mixed> */
    private function syntheticRevision(int $value = 7): array
    {
        return Contract::sourceRevision(
            'synthetic-owner-A',
            'synthetic-scope-A',
            'synthetic-lineage-A',
            'synthetic-context-A',
            $value,
        );
    }

    /** @return array<string, mixed> */
    private function syntheticEvidence(
        string $condition = Contract::CONDITION_PRESENT,
        ?bool $currentness = true,
        ?bool $freshness = true,
    ): array {
        return Contract::evidence(
            $this->syntheticBindings(),
            $condition,
            $this->syntheticRevision(),
            $currentness,
            $freshness,
        );
    }

    /** @return array<string, mixed> */
    private function syntheticIntentInput(): array
    {
        return [
            'authority_owner' => 'synthetic-owner-A',
            'authority_scope' => 'synthetic-scope-A',
            'actor' => 'synthetic-actor-A',
            'actor_role' => 'synthetic-role-A',
            'subject' => 'synthetic-subject-A',
            'participants' => ['synthetic-participant-A', 'synthetic-participant-B'],
            'audience' => 'synthetic-audience-A',
            'purpose' => 'synthetic-purpose-A',
            'aggregate_context' => 'synthetic-context-A',
            'expected_revision' => 7,
        ];
    }
}
