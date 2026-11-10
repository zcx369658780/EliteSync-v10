<?php

namespace Tests\Unit;

use App\Domain\CommonAuthorityEvidenceContract as CommonContract;
use App\Domain\NotificationEligibilityPrivacyMinimalPayloadEvaluator as Evaluator;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

final class NotificationEligibilityPrivacyMinimalPayloadEvaluatorTest extends TestCase
{
    public function testSourceEventAloneDoesNotImplyEligibility(): void
    {
        $result = Evaluator::evaluate([$this->sourceEvent()], [], $this->context());

        self::assertSame(Evaluator::UNKNOWN, $result['eligibility']);
        self::assertNull($result['payload']);
    }

    public function testEligibleRequiresCurrentFreshBindingValidSourceAndEligibilityEvidence(): void
    {
        $result = $this->evaluate();

        self::assertSame(Evaluator::ELIGIBLE, $result['eligibility']);
        self::assertSame('PRIVACY_MINIMAL_NOTIFICATION_PAYLOAD', $result['payload']['record_kind']);
        self::assertCount(2, $result['dependency_vector']);
    }

    public function testExplicitCurrentFreshBindingValidNegativeEvidenceIsIneligible(): void
    {
        $result = $this->evaluate(eligibility: $this->eligibility(Evaluator::INELIGIBLE));

        self::assertSame(Evaluator::INELIGIBLE, $result['eligibility']);
        self::assertNull($result['payload']);
    }

    #[DataProvider('unusableEvidenceProvider')]
    public function testUnusableEligibilityEvidenceFailsClosed(
        string $condition,
        ?bool $currentness,
        ?bool $freshness,
    ): void {
        $evidence = $this->eligibility(Evaluator::ELIGIBLE, condition: $condition, currentness: $currentness, freshness: $freshness);
        $result = $this->evaluate(eligibility: $evidence);

        self::assertSame(Evaluator::UNKNOWN, $result['eligibility']);
        self::assertNull($result['payload']);
    }

    /** @return iterable<string, array{string, ?bool, ?bool}> */
    public static function unusableEvidenceProvider(): iterable
    {
        yield 'unknown' => [CommonContract::CONDITION_UNKNOWN, true, true];
        yield 'unavailable' => [CommonContract::CONDITION_UNAVAILABLE, true, true];
        yield 'stale condition' => [CommonContract::CONDITION_STALE, true, true];
        yield 'superseded' => [CommonContract::CONDITION_SUPERSEDED, true, true];
        yield 'incomparable condition' => [CommonContract::CONDITION_INCOMPARABLE, true, true];
        yield 'not current' => [CommonContract::CONDITION_PRESENT, false, true];
        yield 'not fresh' => [CommonContract::CONDITION_PRESENT, true, false];
    }

    public function testMissingEligibilityAndMissingSourceBothRemainUnknown(): void
    {
        self::assertSame(Evaluator::UNKNOWN, Evaluator::evaluate([], [$this->eligibility()], $this->context())['eligibility']);
        self::assertSame(Evaluator::UNKNOWN, Evaluator::evaluate([$this->sourceEvent()], [], $this->context())['eligibility']);
    }

    public function testBindingMismatchFailsClosed(): void
    {
        $context = $this->context();
        $context['eligibility_required_bindings']['purpose'] = 'synthetic-other-purpose';

        self::assertSame(Evaluator::UNKNOWN, $this->evaluate(context: $context)['eligibility']);
    }

    public function testConflictingEqualRevisionEvidenceFailsClosed(): void
    {
        $positive = $this->eligibility();
        $negative = $positive;
        $negative['eligibility_classification'] = Evaluator::INELIGIBLE;
        $result = Evaluator::evaluate([$this->sourceEvent()], [$positive, $negative], $this->context());

        self::assertSame(Evaluator::UNKNOWN, $result['eligibility']);
        self::assertSame('CONFLICTING', $result['eligibility_resolution']);
    }

    public function testCrossLineageEvidenceIsIncomparableAndFailsClosed(): void
    {
        $other = $this->eligibility(lineage: 'synthetic-other-lineage');
        $result = Evaluator::evaluate([$this->sourceEvent()], [$this->eligibility(), $other], $this->context());

        self::assertSame(Evaluator::UNKNOWN, $result['eligibility']);
        self::assertSame('INCOMPARABLE', $result['eligibility_resolution']);
    }

    public function testExactDuplicateEvidenceDeduplicates(): void
    {
        $evidence = $this->eligibility();
        $result = Evaluator::evaluate([$this->sourceEvent()], [$evidence, $evidence], $this->context());

        self::assertSame(Evaluator::ELIGIBLE, $result['eligibility']);
    }

    public function testSameLineageNewerEvidenceControlsIndependentOfArrivalOrder(): void
    {
        $older = $this->eligibility(Evaluator::INELIGIBLE, revision: 1);
        $newer = $this->eligibility(Evaluator::ELIGIBLE, revision: 2);

        $forward = Evaluator::evaluate([$this->sourceEvent()], [$older, $newer], $this->context());
        $reverse = Evaluator::evaluate([$this->sourceEvent()], [$newer, $older], $this->context());

        self::assertSame(Evaluator::ELIGIBLE, $forward['eligibility']);
        self::assertSame($forward, $reverse);
        self::assertSame(2, $forward['dependency_vector'][1]['source_local_revision']);
        self::assertArrayNotHasKey('global_revision', $forward['dependency_vector'][1]);
    }

    public function testPayloadIsStrictlyPrivacyMinimalAndIgnoresRawPrivateInput(): void
    {
        $eligibility = $this->eligibility();
        $eligibility['conversation_content'] = 'synthetic-private-MUST-NOT-LEAK';
        $eligibility['message_preview'] = 'synthetic-private-MUST-NOT-LEAK';
        $eligibility['unread_count'] = 42;
        $eligibility['hidden_safety_evidence'] = 'synthetic-private-MUST-NOT-LEAK';
        $eligibility['real_name'] = 'synthetic-private-MUST-NOT-LEAK';
        $eligibility['device_token'] = 'synthetic-private-MUST-NOT-LEAK';
        $encoded = json_encode($this->evaluate(eligibility: $eligibility)['payload']);

        self::assertIsString($encoded);
        self::assertStringNotContainsString('MUST-NOT-LEAK', $encoded);
        self::assertStringNotContainsString('unread_count', $encoded);
        self::assertSame([
            'record_kind', 'event_reference', 'context_reference', 'category',
            'generic_title_token', 'generic_body_token', 'route_identity',
            'route_is_locator_only', 'external_copy_generic',
            'source_event_dependency_identity', 'eligibility_dependency_identity',
            'source_authority', 'permission', 'bearer_capability', 'domain_success',
            'consent_authority', 'connection_authority', 'conversation_authority',
            'relationship_authority', 'home_authority', 'launch_authority',
            'ranking_authority', 'compatibility_total_authority', 'person_worth_authority',
        ], array_keys($this->evaluate(eligibility: $eligibility)['payload']));
    }

    #[DataProvider('externalAudienceProvider')]
    public function testExternalAndLockScreenPayloadsRemainGeneric(string $audience): void
    {
        $context = $this->context($audience);
        $payload = $this->evaluate(context: $context, eligibility: $this->eligibility(audience: $audience))['payload'];

        self::assertSame(Evaluator::GENERIC_TITLE_TOKEN, $payload['generic_title_token']);
        self::assertSame(Evaluator::GENERIC_BODY_TOKEN, $payload['generic_body_token']);
        self::assertTrue($payload['external_copy_generic']);
    }

    /** @return iterable<string, array{string}> */
    public static function externalAudienceProvider(): iterable
    {
        yield 'external' => [Evaluator::AUDIENCE_EXTERNAL];
        yield 'lock screen' => [Evaluator::AUDIENCE_LOCK_SCREEN];
    }

    public function testRouteIsLocatorOnlyAndProtectedActionRequiresFreshRevalidation(): void
    {
        $context = $this->context();
        $context['route_identity'] = 'synthetic-route-A';
        $result = $this->evaluate(context: $context);

        self::assertSame('synthetic-route-A', $result['payload']['route_identity']);
        self::assertTrue($result['payload']['route_is_locator_only']);
        self::assertFalse($result['payload']['permission']);
        self::assertFalse($result['payload']['bearer_capability']);
        self::assertTrue($result['protected_action_revalidation_required']);
        self::assertSame('FRESH_SOURCE_AUTHORITY', $result['revalidation_authority']);
    }

    public function testPayloadCreatesNoSourceOrDownstreamAuthority(): void
    {
        $result = $this->evaluate();

        foreach ([
            'source_authority', 'permission', 'bearer_capability', 'domain_success',
            'consent_authority', 'connection_authority', 'conversation_authority',
            'relationship_authority', 'home_authority', 'launch_authority',
            'ranking_computed', 'compatibility_total_computed', 'person_worth_computed',
        ] as $key) {
            self::assertFalse($result[$key]);
        }
    }

    #[DataProvider('deliveryProvider')]
    public function testDeliveryObservationNeverBecomesDomainOutcome(string $observation): void
    {
        $result = $this->evaluate(delivery: $observation);

        self::assertSame(Evaluator::ELIGIBLE, $result['eligibility']);
        self::assertSame($observation, $result['delivery_observation']);
        self::assertFalse($result['delivery_is_domain_outcome']);
        self::assertFalse($result['domain_success']);
        self::assertFalse($result['domain_failure']);
    }

    /** @return iterable<string, array{string}> */
    public static function deliveryProvider(): iterable
    {
        yield 'not attempted' => [Evaluator::DELIVERY_NOT_ATTEMPTED];
        yield 'attempted' => [Evaluator::DELIVERY_ATTEMPTED];
        yield 'delivered' => [Evaluator::DELIVERY_DELIVERED];
        yield 'failed' => [Evaluator::DELIVERY_FAILED];
        yield 'opened' => [Evaluator::DELIVERY_OPENED];
        yield 'dismissed' => [Evaluator::DELIVERY_DISMISSED];
    }

    public function testDeliveryObservationDoesNotMutateInputs(): void
    {
        $source = $this->sourceEvent();
        $eligibility = $this->eligibility();
        $context = $this->context();
        $before = [$source, $eligibility, $context];

        $result = Evaluator::evaluate([$source], [$eligibility], $context, Evaluator::DELIVERY_OPENED);

        self::assertSame($before, [$source, $eligibility, $context]);
        self::assertFalse($result['source_event_mutated']);
        self::assertFalse($result['eligibility_written']);
        self::assertFalse($result['delivery_written']);
        self::assertTrue($result['zero_writer']);
    }

    #[DataProvider('invalidationProvider')]
    public function testDependencyInvalidationRemovesEligibilityAndPayloadWithoutLifecycleChange(string $relation): void
    {
        $result = $this->evaluate();
        $invalidated = Evaluator::invalidate($result, 'synthetic-eligibility-A', $relation);

        self::assertSame(Evaluator::UNKNOWN, $invalidated['eligibility']);
        self::assertNull($invalidated['payload']);
        self::assertFalse($invalidated['source_domain_lifecycle_changed']);
        self::assertFalse($invalidated['invalidation']['source_domain_lifecycle_changed']);
        self::assertFalse($invalidated['invalidation']['lifecycle_reset']);
        self::assertFalse($invalidated['invalidation']['reopened']);
    }

    /** @return iterable<string, array{string}> */
    public static function invalidationProvider(): iterable
    {
        yield 'correction' => [CommonContract::INVALIDATION_CORRECTION];
        yield 'revocation' => [CommonContract::INVALIDATION_REVOCATION];
        yield 'supersession' => [CommonContract::INVALIDATION_SUPERSESSION];
    }

    public function testWrongEventOrContextReferenceFailsClosed(): void
    {
        $wrongEvent = $this->eligibility();
        $wrongEvent['event_reference'] = 'synthetic-event-other';
        $wrongContext = $this->eligibility();
        $wrongContext['context_reference'] = 'synthetic-context-other';

        self::assertSame(Evaluator::UNKNOWN, $this->evaluate(eligibility: $wrongEvent)['eligibility']);
        self::assertSame(Evaluator::UNKNOWN, $this->evaluate(eligibility: $wrongContext)['eligibility']);
    }

    public function testUnknownDecisionCannotGeneratePayload(): void
    {
        $eligibility = $this->eligibility();
        $eligibility['eligibility_classification'] = Evaluator::UNKNOWN;
        $result = $this->evaluate(eligibility: $eligibility);

        self::assertSame(Evaluator::UNKNOWN, $result['eligibility']);
        self::assertNull($result['payload']);
    }

    /** @return array<string, mixed> */
    private function evaluate(
        ?array $source = null,
        ?array $eligibility = null,
        ?array $context = null,
        string $delivery = Evaluator::DELIVERY_NOT_ATTEMPTED,
    ): array {
        return Evaluator::evaluate(
            [$source ?? $this->sourceEvent()],
            [$eligibility ?? $this->eligibility()],
            $context ?? $this->context(),
            $delivery,
        );
    }

    /** @return array<string, mixed> */
    private function sourceEvent(
        string $lineage = 'synthetic-source-lineage-A',
        int $revision = 1,
        string $condition = CommonContract::CONDITION_PRESENT,
        ?bool $currentness = true,
        ?bool $freshness = true,
    ): array {
        $evidence = CommonContract::evidence(
            $this->sourceBindings(),
            $condition,
            CommonContract::sourceRevision(
                'synthetic-domain-owner',
                'synthetic-event-scope',
                $lineage,
                'synthetic-event-context-A',
                $revision,
            ),
            $currentness,
            $freshness,
        );
        $evidence['dependency_identity'] = 'synthetic-source-event-A';
        $evidence['event_reference'] = 'synthetic-event-A';

        return $evidence;
    }

    /** @return array<string, mixed> */
    private function eligibility(
        string $classification = Evaluator::ELIGIBLE,
        string $lineage = 'synthetic-eligibility-lineage-A',
        int $revision = 1,
        string $condition = CommonContract::CONDITION_PRESENT,
        ?bool $currentness = true,
        ?bool $freshness = true,
        string $audience = Evaluator::AUDIENCE_IN_APP,
    ): array {
        $evidence = CommonContract::evidence(
            $this->eligibilityBindings($audience),
            $condition,
            CommonContract::sourceRevision(
                'synthetic-notification-policy-owner',
                'synthetic-eligibility-scope',
                $lineage,
                'synthetic-notification-context-A',
                $revision,
            ),
            $currentness,
            $freshness,
        );
        $evidence['dependency_identity'] = 'synthetic-eligibility-A';
        $evidence['event_reference'] = 'synthetic-event-A';
        $evidence['context_reference'] = 'synthetic-context-A';
        $evidence['eligibility_classification'] = $classification;

        return $evidence;
    }

    /** @return array<string, mixed> */
    private function context(string $audience = Evaluator::AUDIENCE_IN_APP): array
    {
        return [
            'event_reference' => 'synthetic-event-A',
            'context_reference' => 'synthetic-context-A',
            'category' => 'PRODUCT_CONNECTION',
            'audience' => $audience,
            'purpose' => 'synthetic-notification-purpose',
            'source_required_bindings' => $this->sourceBindings(),
            'eligibility_required_bindings' => $this->eligibilityBindings($audience),
        ];
    }

    /** @return array<string, mixed> */
    private function sourceBindings(): array
    {
        return [
            'authority_owner' => 'synthetic-domain-owner',
            'authority_scope' => 'synthetic-event-scope',
            'actor' => 'synthetic-actor-A',
            'actor_role' => 'synthetic-domain-role',
            'subject' => 'synthetic-subject-A',
            'participants' => ['synthetic-participant-A'],
            'audience' => 'synthetic-notification-derivation',
            'purpose' => 'synthetic-event-purpose',
            'aggregate_context' => 'synthetic-event-context-A',
            'lifecycle_identity' => 'synthetic-event-lifecycle-A',
            'terminal' => false,
        ];
    }

    /** @return array<string, mixed> */
    private function eligibilityBindings(string $audience): array
    {
        return [
            'authority_owner' => 'synthetic-notification-policy-owner',
            'authority_scope' => 'synthetic-eligibility-scope',
            'actor' => 'synthetic-actor-A',
            'actor_role' => 'synthetic-notification-role',
            'subject' => 'synthetic-subject-A',
            'participants' => ['synthetic-participant-A'],
            'audience' => $audience,
            'purpose' => 'synthetic-notification-purpose',
            'aggregate_context' => 'synthetic-notification-context-A',
            'lifecycle_identity' => 'synthetic-eligibility-lifecycle-A',
            'terminal' => false,
        ];
    }
}
