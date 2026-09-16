<?php

namespace Tests\Unit;

use App\Domain\CalmHomeReadOnlyCompositionEvaluator as HomeEvaluator;
use App\Domain\CanonicalMatchProposalDecisionEvaluator as MatchEvaluator;
use App\Domain\CommonAuthorityEvidenceContract as CommonContract;
use App\Domain\CoreDomainSemanticIntegrationHarness as Harness;
use App\Domain\MessagingConsentConversationLiveGateEvaluator as ConsentEvaluator;
use App\Domain\NotificationEligibilityPrivacyMinimalPayloadEvaluator as NotificationEvaluator;
use App\Domain\ProductConnectionStateTransitionEvaluator as ConnectionEvaluator;
use App\Domain\RuntimeReadinessDerivedEvaluator as ReadinessEvaluator;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

final class CoreDomainSemanticIntegrationHarnessTest extends TestCase
{
    public function testReadinessDoesNotCreateDownstreamAuthority(): void
    {
        $result = Harness::run($this->scenario());

        self::assertSame(ReadinessEvaluator::READINESS_NOT_READY, $result['readiness']['classification']);
        self::assertFalse($result['readiness']['match_authority']);
        self::assertFalse($result['readiness']['connection_authority']);
        self::assertFalse($result['readiness']['consent_authority']);
        self::assertFalse($result['readiness']['conversation_authority']);
        self::assertFalse($result['readiness']['launch_eligibility']);
        self::assertFalse($result['home_action_authority']);
        self::assertFalse($result['notification_authority']);
    }

    public function testMutuallyAcceptedMatchDoesNotCreateConnection(): void
    {
        $scenario = $this->scenario();
        $scenario['match']['slot_evidence'] = [
            $this->matchSlot('synthetic-participant-A', MatchEvaluator::SLOT_ACCEPTED),
            $this->matchSlot('synthetic-participant-B', MatchEvaluator::SLOT_ACCEPTED),
        ];
        $result = Harness::run($scenario);

        self::assertSame(MatchEvaluator::PROPOSAL_MUTUALLY_ACCEPTED, $result['match']['classification']);
        self::assertFalse($result['match']['product_connection_created']);
        self::assertFalse($result['match']['messaging_consent_authority']);
        self::assertFalse($result['match']['conversation_authority']);
    }

    public function testActiveConnectionDoesNotCreateConsent(): void
    {
        $result = Harness::run($this->scenario());

        self::assertSame(ConnectionEvaluator::STATE_ACTIVE, $result['connection']['classification']);
        self::assertTrue($result['connection']['connection_active_for_downstream_consideration']);
        self::assertFalse($result['connection']['messaging_consent_granted']);
        self::assertFalse($result['connection']['conversation_granted']);
    }

    public function testConsentAloneCannotEnableConversationWithoutFreshActiveConnection(): void
    {
        $scenario = $this->scenario();
        $scenario['connection']['state_evidence'] = [
            $this->connectionEvidence(ConnectionEvaluator::STATE_ACTIVE, freshness: false),
        ];
        $scenario['conversation']['read_consent_evidence'] = [$this->consentEvidence(ConsentEvaluator::STATE_ACTIVE)];
        $scenario['conversation']['send_consent_evidence'] = [$this->consentEvidence(
            ConsentEvaluator::STATE_ACTIVE,
            ConsentEvaluator::PURPOSE_LIVE_SEND,
            'synthetic-consent-send-A',
        )];
        $result = Harness::run($scenario);

        self::assertSame(ConnectionEvaluator::DERIVED_UNKNOWN, $result['connection']['classification']);
        self::assertFalse($result['conversation']['live_read_allowed']);
        self::assertFalse($result['conversation']['live_send_allowed']);
    }

    public function testExactActiveConnectionAndPurposeBoundConsentEnableOnlyCorrespondingGate(): void
    {
        $result = Harness::run($this->scenario());

        self::assertTrue($result['conversation']['live_read_allowed']);
        self::assertFalse($result['conversation']['live_send_allowed']);
        self::assertTrue($result['conversation']['valid_for_live_read']);
        self::assertFalse($result['conversation']['valid_for_live_send']);

        $scenario = $this->scenario();
        $scenario['conversation']['read_consent_evidence'] = [$this->consentEvidence(ConsentEvaluator::STATE_PENDING)];
        $scenario['conversation']['send_consent_evidence'] = [$this->consentEvidence(
            ConsentEvaluator::STATE_ACTIVE,
            ConsentEvaluator::PURPOSE_LIVE_SEND,
            'synthetic-consent-send-A',
        )];
        $sendOnly = Harness::run($scenario);

        self::assertFalse($sendOnly['conversation']['live_read_allowed']);
        self::assertTrue($sendOnly['conversation']['live_send_allowed']);
    }

    public function testHomeRemainsZeroWriterAndMultipleCandidatesHaveNoPrimaryAction(): void
    {
        $result = Harness::run($this->scenario());
        $decision = $result['home']['sections'][HomeEvaluator::SECTION_NEXT_DECISION];

        self::assertTrue($result['zero_writer']);
        self::assertFalse($result['home']['source_state_written']);
        self::assertFalse($result['home']['source_state_mutated']);
        self::assertFalse($result['home']['source_authority']);
        self::assertSame(2, $decision['valid_candidate_count']);
        self::assertNull($decision['primary_action']);
        self::assertSame('NO_ACCEPTED_PRECEDENCE_MULTI_CANDIDATE', $decision['resolution']);
        self::assertFalse($decision['precedence_applied']);
        self::assertFalse($decision['ranking_applied']);
    }

    public function testNotificationSourceEventAloneDoesNotImplyEligibilityOrPayload(): void
    {
        $scenario = $this->scenario();
        $scenario['notification']['eligibility_evidence'] = [];
        $result = Harness::run($scenario);

        self::assertSame(NotificationEvaluator::UNKNOWN, $result['notification']['eligibility']);
        self::assertNull($result['notification']['payload']);
    }

    public function testIneligibleNotificationCannotGeneratePayload(): void
    {
        $scenario = $this->scenario();
        $scenario['notification']['eligibility_evidence'] = [
            $this->notificationEligibility(NotificationEvaluator::INELIGIBLE),
        ];
        $result = Harness::run($scenario);

        self::assertSame(NotificationEvaluator::INELIGIBLE, $result['notification']['eligibility']);
        self::assertNull($result['notification']['payload']);
    }

    public function testEligibleExternalPayloadIsGenericPrivacyMinimalAndRouteIsNotPermission(): void
    {
        $result = Harness::run($this->scenario());
        $notification = $result['notification'];
        $payload = $notification['payload'];

        self::assertSame(NotificationEvaluator::ELIGIBLE, $notification['eligibility']);
        self::assertSame(NotificationEvaluator::GENERIC_TITLE_TOKEN, $payload['generic_title_token']);
        self::assertSame(NotificationEvaluator::GENERIC_BODY_TOKEN, $payload['generic_body_token']);
        self::assertTrue($payload['external_copy_generic']);
        self::assertSame('synthetic-route-A', $payload['route_identity']);
        self::assertTrue($payload['route_is_locator_only']);
        self::assertFalse($payload['permission']);
        self::assertFalse($payload['bearer_capability']);
        self::assertTrue($notification['protected_action_revalidation_required']);
    }

    #[DataProvider('deliveryObservationProvider')]
    public function testDeliveryOpenAndDismissNeverCreateDomainOutcome(string $observation): void
    {
        $scenario = $this->scenario();
        $scenario['notification']['delivery_observation'] = $observation;
        $result = Harness::run($scenario);

        self::assertSame($observation, $result['notification']['delivery_observation']);
        self::assertFalse($result['notification']['delivery_is_domain_outcome']);
        self::assertFalse($result['notification']['domain_success']);
        self::assertFalse($result['notification']['domain_failure']);
        self::assertFalse($result['domain_success']);
    }

    /** @return iterable<string, array{string}> */
    public static function deliveryObservationProvider(): iterable
    {
        yield 'delivered' => [NotificationEvaluator::DELIVERY_DELIVERED];
        yield 'failed' => [NotificationEvaluator::DELIVERY_FAILED];
        yield 'opened' => [NotificationEvaluator::DELIVERY_OPENED];
        yield 'dismissed' => [NotificationEvaluator::DELIVERY_DISMISSED];
    }

    #[DataProvider('invalidationProvider')]
    public function testInvalidationIsDependencyScopedAndDoesNotResetLifecycle(string $relation): void
    {
        $result = Harness::run($this->scenario());
        $invalidated = Harness::invalidate(
            $result,
            Harness::DOMAIN_READINESS,
            'synthetic-readiness-member-A',
            $relation,
        );

        self::assertSame(ReadinessEvaluator::READINESS_UNKNOWN, $invalidated['readiness']['classification']);
        self::assertSame(HomeEvaluator::AVAILABILITY_INVALIDATED, $invalidated['home']['sections']['CURRENT_STATE']['fragments'][HomeEvaluator::DOMAIN_READINESS]['availability']);
        self::assertSame($result['match'], $invalidated['match']);
        self::assertSame($result['connection'], $invalidated['connection']);
        self::assertSame($result['conversation'], $invalidated['conversation']);
        self::assertSame($result['notification'], $invalidated['notification']);
        self::assertFalse($invalidated['integration_invalidation']['lifecycle_reset']);
        self::assertFalse($invalidated['integration_invalidation']['reopened']);
        self::assertFalse($invalidated['integration_invalidation']['source_written']);
    }

    /** @return iterable<string, array{string}> */
    public static function invalidationProvider(): iterable
    {
        yield 'correction' => [CommonContract::INVALIDATION_CORRECTION];
        yield 'revocation' => [CommonContract::INVALIDATION_REVOCATION];
        yield 'supersession' => [CommonContract::INVALIDATION_SUPERSESSION];
    }

    public function testUnknownReadinessRemainsUnknownWithoutSubstitutingOtherDomainSuccess(): void
    {
        $scenario = $this->scenario();
        $scenario['readiness']['member_evidence'] = [$this->readinessMember(CommonContract::CONDITION_UNKNOWN)];
        $result = Harness::run($scenario);

        self::assertSame(ReadinessEvaluator::READINESS_UNKNOWN, $result['readiness']['classification']);
        self::assertSame(HomeEvaluator::AVAILABILITY_UNKNOWN, $result['home']['sections']['CURRENT_STATE']['fragments'][HomeEvaluator::DOMAIN_READINESS]['availability']);
        self::assertSame(ConnectionEvaluator::STATE_ACTIVE, $result['connection']['classification']);
        self::assertTrue($result['conversation']['live_read_allowed']);
        self::assertFalse($result['semantic_guards']['cross_domain_substitution']);
    }

    #[DataProvider('unusableSourceConditionProvider')]
    public function testEveryUnusableSourceConditionFailsClosedWithoutCrossDomainRepair(string $condition): void
    {
        $scenario = $this->scenario();
        $scenario['readiness']['member_evidence'] = [$this->readinessMember($condition)];
        $result = Harness::run($scenario);

        self::assertSame(ReadinessEvaluator::READINESS_UNKNOWN, $result['readiness']['classification']);
        self::assertSame(HomeEvaluator::AVAILABILITY_UNKNOWN, $result['home']['sections']['CURRENT_STATE']['fragments'][HomeEvaluator::DOMAIN_READINESS]['availability']);
        self::assertSame(ConnectionEvaluator::STATE_ACTIVE, $result['connection']['classification']);
        self::assertFalse($result['semantic_guards']['cross_domain_substitution']);
    }

    /** @return iterable<string, array{string}> */
    public static function unusableSourceConditionProvider(): iterable
    {
        yield 'unknown' => [CommonContract::CONDITION_UNKNOWN];
        yield 'unavailable' => [CommonContract::CONDITION_UNAVAILABLE];
        yield 'stale' => [CommonContract::CONDITION_STALE];
        yield 'superseded' => [CommonContract::CONDITION_SUPERSEDED];
        yield 'incomparable' => [CommonContract::CONDITION_INCOMPARABLE];
    }

    public function testIncomparableNotificationEvidenceFailsClosedDownstream(): void
    {
        $scenario = $this->scenario();
        $scenario['notification']['eligibility_evidence'][] = $this->notificationEligibility(lineage: 'synthetic-eligibility-lineage-B');
        $result = Harness::run($scenario);

        self::assertSame(NotificationEvaluator::UNKNOWN, $result['notification']['eligibility']);
        self::assertSame('INCOMPARABLE', $result['notification']['eligibility_resolution']);
        self::assertNull($result['notification']['payload']);
    }

    public function testSourceLocalNewerEvidenceControlsIndependentOfArrivalOrder(): void
    {
        $older = $this->notificationEligibility(NotificationEvaluator::INELIGIBLE, revision: 1);
        $newer = $this->notificationEligibility(NotificationEvaluator::ELIGIBLE, revision: 2);
        $forward = $this->scenario();
        $forward['notification']['eligibility_evidence'] = [$older, $newer];
        $reverse = $forward;
        $reverse['notification']['eligibility_evidence'] = [$newer, $older];

        $forwardResult = Harness::run($forward);
        $reverseResult = Harness::run($reverse);

        self::assertSame($forwardResult, $reverseResult);
        self::assertSame(NotificationEvaluator::ELIGIBLE, $forwardResult['notification']['eligibility']);
        self::assertSame(2, $forwardResult['notification']['dependency_vector'][1]['source_local_revision']);
        self::assertFalse($forwardResult['semantic_guards']['last_received_wins']);
        self::assertNull($forwardResult['semantic_guards']['global_revision']);
        self::assertFalse($this->containsKeyRecursively($forwardResult, 'global_revision', ignoreSemanticGuard: true));
    }

    public function testReorderingIndependentInputsDoesNotCreateAuthority(): void
    {
        $forward = $this->scenario();
        $reverse = $forward;
        $reverse['match']['participation_evidence'] = array_reverse($reverse['match']['participation_evidence']);
        $reverse['match']['slot_evidence'] = array_reverse($reverse['match']['slot_evidence']);

        self::assertSame(Harness::run($forward), Harness::run($reverse));
        self::assertFalse(Harness::run($reverse)['semantic_guards']['independent_input_order_creates_authority']);
    }

    public function testForbiddenPrivateProviderAndSafetyFixtureMaterialDoesNotLeak(): void
    {
        $scenario = $this->scenario();
        foreach ([
            'conversation_content', 'message_preview', 'unread_count', 'hidden_safety_evidence',
            'real_identity', 'profile_data', 'credential', 'device_token', 'provider_payload',
            'analytics_signal', 'training_signal', 'ads_signal',
        ] as $key) {
            $scenario['notification']['eligibility_evidence'][0][$key] = 'synthetic-private-MUST-NOT-LEAK';
        }
        $result = Harness::run($scenario);
        $encoded = json_encode($result);

        self::assertIsString($encoded);
        self::assertStringNotContainsString('MUST-NOT-LEAK', $encoded);
        self::assertFalse($result['device_token_read']);
        self::assertFalse($result['provider_payload_created']);
    }

    public function testIntegratedResultCreatesNoRankingOrOperationalAuthority(): void
    {
        $result = Harness::run($this->scenario());

        foreach ([
            'source_authority', 'source_state_written', 'source_state_mutated', 'match_created',
            'connection_created', 'consent_created', 'conversation_created', 'home_action_authority',
            'notification_authority', 'permission', 'bearer_capability', 'domain_success',
            'relationship_authority', 'launch_authority', 'persistence_authority', 'endpoint_authority',
            'transport_authority', 'provider_authority', 'client_authority', 'legal_authority',
            'safety_authority', 'deployment_authority', 'production_authority', 'ranking_computed',
            'compatibility_total_computed', 'desirability_computed', 'person_worth_computed',
            'conversation_content_read', 'message_preview_read', 'private_unread_count_read',
            'hidden_safety_evidence_read', 'private_identity_read', 'credential_read',
            'device_token_read', 'provider_payload_created', 'analytics_authority',
            'training_authority', 'ads_authority',
        ] as $key) {
            self::assertFalse($result[$key], $key);
        }
    }

    public function testHarnessIsDeterministicZeroWriterAndDoesNotMutateScenario(): void
    {
        $scenario = $this->scenario();
        $before = $scenario;
        $first = Harness::run($scenario);
        $second = Harness::run($scenario);

        self::assertSame($before, $scenario);
        self::assertSame($first, $second);
        self::assertTrue($first['deterministic']);
        self::assertTrue($first['zero_writer']);
    }

    /** @return array<string, mixed> */
    private function scenario(): array
    {
        return [
            'readiness' => [
                'prerequisite_set' => $this->prerequisiteSet(),
                'member_evidence' => [$this->readinessMember()],
            ],
            'match' => [
                'proposal' => $this->matchProposal(),
                'participation_evidence' => [
                    $this->matchParticipation('synthetic-participant-A'),
                    $this->matchParticipation('synthetic-participant-B'),
                ],
                'slot_evidence' => [
                    $this->matchSlot('synthetic-participant-A'),
                    $this->matchSlot('synthetic-participant-B'),
                ],
            ],
            'connection' => [
                'context' => $this->connection(),
                'state_evidence' => [$this->connectionEvidence(ConnectionEvaluator::STATE_ACTIVE)],
            ],
            'conversation' => [
                'read_consent' => $this->consent(),
                'read_consent_evidence' => [$this->consentEvidence(ConsentEvaluator::STATE_ACTIVE)],
                'send_consent' => $this->consent('synthetic-consent-send-A', ConsentEvaluator::PURPOSE_LIVE_SEND),
                'send_consent_evidence' => [$this->consentEvidence(
                    ConsentEvaluator::STATE_PENDING,
                    ConsentEvaluator::PURPOSE_LIVE_SEND,
                    'synthetic-consent-send-A',
                )],
            ],
            'home' => [
                'dependency_identities' => [
                    Harness::DOMAIN_READINESS => 'synthetic-readiness-member-A',
                    Harness::DOMAIN_MATCH => 'synthetic-slot-synthetic-participant-A',
                    Harness::DOMAIN_CONNECTION => 'synthetic-connection-state-A',
                    Harness::DOMAIN_CONVERSATION => 'synthetic-consent-evidence-A',
                ],
                'action_candidates' => [
                    Harness::DOMAIN_READINESS => [$this->homeCandidate(
                        'synthetic-home-readiness-action-A',
                        HomeEvaluator::ACTION_COMPLETE_READINESS,
                        'synthetic-set-A',
                    )],
                    Harness::DOMAIN_MATCH => [$this->homeCandidate(
                        'synthetic-home-match-action-A',
                        HomeEvaluator::ACTION_RESPOND_MATCH,
                        'synthetic-proposal-A',
                    )],
                ],
            ],
            'notification' => [
                'source_event_evidence' => [$this->notificationSourceEvent()],
                'eligibility_evidence' => [$this->notificationEligibility()],
                'context' => $this->notificationContext(),
                'delivery_observation' => NotificationEvaluator::DELIVERY_NOT_ATTEMPTED,
            ],
        ];
    }

    /** @return array<string, mixed> */
    private function prerequisiteSet(): array
    {
        $bindings = $this->bindings('synthetic-set-authority', 'synthetic-set-scope', 'synthetic-set-subject', ['synthetic-readiness-participant'], 'synthetic-readiness-use', 'synthetic-set-context', 'synthetic-readiness-lifecycle');

        return [
            'set_identity' => 'synthetic-set-A',
            'state' => ReadinessEvaluator::SET_KNOWN,
            'protected_use_scope' => 'synthetic-readiness-use',
            'required_member_ids' => ['synthetic-readiness-member-A'],
            'required_bindings' => $bindings,
            'source_evidence' => $this->evidence($bindings, 'synthetic-set-lineage', 1),
        ];
    }

    /** @return array<string, mixed> */
    private function readinessMember(string $condition = CommonContract::CONDITION_PRESENT): array
    {
        $bindings = $this->bindings('synthetic-member-authority', 'synthetic-member-scope', 'synthetic-readiness-member-A', ['synthetic-readiness-participant'], 'synthetic-readiness-use', 'synthetic-member-context', 'synthetic-readiness-lifecycle');

        return [
            'member_identity' => 'synthetic-readiness-member-A',
            'fact_class' => ReadinessEvaluator::FACT_CHECKLIST,
            'protected_use_scope' => 'synthetic-readiness-use',
            'required_bindings' => $bindings,
            'source_evidence' => $this->evidence($bindings, 'synthetic-member-lineage', 1, $condition),
            'prerequisite_outcome' => ReadinessEvaluator::OUTCOME_UNSATISFIED,
        ];
    }

    /** @return array<string, mixed> */
    private function matchProposal(): array
    {
        $participants = ['synthetic-participant-A', 'synthetic-participant-B'];
        $bindings = $this->bindings('synthetic-proposal-authority', 'synthetic-proposal-scope', 'synthetic-proposal-A', $participants, 'synthetic-match-use', 'synthetic-proposal-A', 'synthetic-proposal-A');

        return [
            'proposal_identity' => 'synthetic-proposal-A',
            'lifecycle_state' => MatchEvaluator::PROPOSAL_PENDING,
            'participants' => $participants,
            'protected_use_scope' => 'synthetic-match-use',
            'at_most_one_unresolved_precondition' => true,
            'required_bindings' => $bindings,
            'source_evidence' => $this->evidence($bindings, 'synthetic-proposal-lineage', 1),
        ];
    }

    /** @return array<string, mixed> */
    private function matchParticipation(string $participant): array
    {
        $context = 'synthetic-participation-'.$participant;
        $bindings = $this->bindings('synthetic-participation-authority', 'synthetic-participation-scope', $participant, [$participant], 'synthetic-match-use', $context, $context);

        return [
            'participant_identity' => $participant,
            'state' => MatchEvaluator::PARTICIPATION_ENROLLED,
            'required_bindings' => $bindings,
            'source_evidence' => $this->evidence($bindings, 'synthetic-participation-lineage', 1),
        ];
    }

    /** @return array<string, mixed> */
    private function matchSlot(string $participant, string $decision = MatchEvaluator::SLOT_PENDING): array
    {
        $bindings = $this->bindings('synthetic-slot-authority', 'synthetic-slot-scope', $participant, [$participant], 'synthetic-match-use', 'synthetic-proposal-A', 'synthetic-proposal-A');

        return [
            'slot_identity' => 'synthetic-slot-'.$participant,
            'proposal_identity' => 'synthetic-proposal-A',
            'participant_identity' => $participant,
            'protected_use_scope' => 'synthetic-match-use',
            'decision' => $decision,
            'required_bindings' => $bindings,
            'source_evidence' => $this->evidence($bindings, 'synthetic-slot-lineage', 1),
        ];
    }

    /** @return array<string, mixed> */
    private function connection(): array
    {
        return [
            'connection_identity' => 'synthetic-connection-A',
            'participants' => ['synthetic-participant-A', 'synthetic-participant-B'],
            'protected_use_scope' => 'synthetic-connection-transition-use',
        ];
    }

    /** @return array<string, mixed> */
    private function connectionEvidence(
        string $state,
        string $condition = CommonContract::CONDITION_PRESENT,
        ?bool $freshness = true,
    ): array {
        $participants = ['synthetic-participant-A', 'synthetic-participant-B'];
        $bindings = $this->bindings('synthetic-connection-authority', 'synthetic-connection-scope', 'synthetic-connection-A', $participants, 'synthetic-connection-transition-use', 'synthetic-connection-A', 'synthetic-connection-A');

        return [
            'state_evidence_identity' => 'synthetic-connection-state-A',
            'connection_identity' => 'synthetic-connection-A',
            'participants' => $participants,
            'state' => $state,
            'required_bindings' => $bindings,
            'source_evidence' => $this->evidence($bindings, 'synthetic-connection-lineage', 1, $condition, true, $freshness),
        ];
    }

    /** @return array<string, mixed> */
    private function consent(
        string $identity = 'synthetic-consent-read-A',
        string $purpose = ConsentEvaluator::PURPOSE_LIVE_READ,
    ): array {
        return [
            'consent_identity' => $identity,
            'connection_identity' => 'synthetic-connection-A',
            'participants' => ['synthetic-participant-A', 'synthetic-participant-B'],
            'requester' => 'synthetic-participant-A',
            'recipient' => 'synthetic-participant-B',
            'purpose' => $purpose,
        ];
    }

    /** @return array<string, mixed> */
    private function consentEvidence(
        string $state,
        string $purpose = ConsentEvaluator::PURPOSE_LIVE_READ,
        string $identity = 'synthetic-consent-read-A',
    ): array {
        $participants = ['synthetic-participant-A', 'synthetic-participant-B'];
        $bindings = $this->bindings('synthetic-consent-authority', 'synthetic-consent-scope', 'synthetic-connection-A', $participants, $purpose, $identity, $identity);

        return [
            'consent_evidence_identity' => $purpose === ConsentEvaluator::PURPOSE_LIVE_READ
                ? 'synthetic-consent-evidence-A'
                : 'synthetic-consent-send-evidence-A',
            'consent_identity' => $identity,
            'connection_identity' => 'synthetic-connection-A',
            'participants' => $participants,
            'purpose' => $purpose,
            'state' => $state,
            'required_bindings' => $bindings,
            'source_evidence' => $this->evidence($bindings, 'synthetic-consent-lineage', 1),
        ];
    }

    /** @return array<string, mixed> */
    private function homeCandidate(string $identity, string $category, string $context): array
    {
        return [
            'action_identity' => $identity,
            'category' => $category,
            'currently_valid' => true,
            'semantic_payload' => [
                'context_identity' => $context,
                'presentation_variant' => 'STANDARD',
            ],
        ];
    }

    /** @return array<string, mixed> */
    private function notificationSourceEvent(): array
    {
        $bindings = $this->bindings('synthetic-domain-owner', 'synthetic-event-scope', 'synthetic-subject-A', ['synthetic-participant-A'], 'synthetic-event-purpose', 'synthetic-event-context-A', 'synthetic-event-lifecycle-A', 'synthetic-notification-derivation');
        $evidence = $this->evidence($bindings, 'synthetic-source-lineage', 1);
        $evidence['dependency_identity'] = 'synthetic-source-event-A';
        $evidence['event_reference'] = 'synthetic-event-A';

        return $evidence;
    }

    /** @return array<string, mixed> */
    private function notificationEligibility(
        string $classification = NotificationEvaluator::ELIGIBLE,
        string $lineage = 'synthetic-eligibility-lineage-A',
        int $revision = 1,
    ): array {
        $bindings = $this->notificationEligibilityBindings();
        $evidence = $this->evidence($bindings, $lineage, $revision);
        $evidence['dependency_identity'] = 'synthetic-notification-eligibility-A';
        $evidence['event_reference'] = 'synthetic-event-A';
        $evidence['context_reference'] = 'synthetic-notification-context-A';
        $evidence['eligibility_classification'] = $classification;

        return $evidence;
    }

    /** @return array<string, mixed> */
    private function notificationContext(): array
    {
        return [
            'event_reference' => 'synthetic-event-A',
            'context_reference' => 'synthetic-notification-context-A',
            'category' => 'PRODUCT_CONNECTION',
            'audience' => NotificationEvaluator::AUDIENCE_EXTERNAL,
            'purpose' => 'synthetic-notification-purpose',
            'source_required_bindings' => $this->notificationSourceBindings(),
            'eligibility_required_bindings' => $this->notificationEligibilityBindings(),
            'route_identity' => 'synthetic-route-A',
        ];
    }

    /** @return array<string, mixed> */
    private function notificationSourceBindings(): array
    {
        return $this->bindings('synthetic-domain-owner', 'synthetic-event-scope', 'synthetic-subject-A', ['synthetic-participant-A'], 'synthetic-event-purpose', 'synthetic-event-context-A', 'synthetic-event-lifecycle-A', 'synthetic-notification-derivation');
    }

    /** @return array<string, mixed> */
    private function notificationEligibilityBindings(): array
    {
        return $this->bindings('synthetic-notification-policy-owner', 'synthetic-eligibility-scope', 'synthetic-subject-A', ['synthetic-participant-A'], 'synthetic-notification-purpose', 'synthetic-notification-context-A', 'synthetic-eligibility-lifecycle-A', NotificationEvaluator::AUDIENCE_EXTERNAL);
    }

    /**
     * @param array<string, mixed> $bindings
     * @return array<string, mixed>
     */
    private function evidence(
        array $bindings,
        string $lineage,
        int $revision,
        string $condition = CommonContract::CONDITION_PRESENT,
        ?bool $currentness = true,
        ?bool $freshness = true,
    ): array {
        return CommonContract::evidence(
            $bindings,
            $condition,
            CommonContract::sourceRevision(
                $bindings['authority_owner'],
                $bindings['authority_scope'],
                $lineage,
                $bindings['aggregate_context'],
                $revision,
            ),
            $currentness,
            $freshness,
        );
    }

    /** @return array<string, mixed> */
    private function bindings(
        string $owner,
        string $scope,
        string $subject,
        array $participants,
        string $purpose,
        string $context,
        string $lifecycle,
        string $audience = 'synthetic-integration-audience',
    ): array {
        return [
            'authority_owner' => $owner,
            'authority_scope' => $scope,
            'actor' => 'synthetic-integration-actor',
            'actor_role' => 'synthetic-integration-role',
            'subject' => $subject,
            'participants' => $participants,
            'audience' => $audience,
            'purpose' => $purpose,
            'aggregate_context' => $context,
            'lifecycle_identity' => $lifecycle,
            'terminal' => false,
        ];
    }

    /** @param array<string, mixed> $value */
    private function containsKeyRecursively(array $value, string $needle, bool $ignoreSemanticGuard = false): bool
    {
        $isSemanticGuard = $ignoreSemanticGuard
            && (($value['source_local_revision_only'] ?? false) === true);

        foreach ($value as $key => $nested) {
            if ($key === $needle && ! $isSemanticGuard) {
                return true;
            }

            if (is_array($nested) && $this->containsKeyRecursively($nested, $needle, $ignoreSemanticGuard)) {
                return true;
            }
        }

        return false;
    }
}
