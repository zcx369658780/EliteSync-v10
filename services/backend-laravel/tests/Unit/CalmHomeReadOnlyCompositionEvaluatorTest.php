<?php

namespace Tests\Unit;

use App\Domain\CalmHomeReadOnlyCompositionEvaluator as Evaluator;
use App\Domain\CommonAuthorityEvidenceContract as CommonContract;
use PHPUnit\Framework\TestCase;

final class CalmHomeReadOnlyCompositionEvaluatorTest extends TestCase
{
    public function testCompositionIsReadOnlyAndDoesNotMutateInputs(): void
    {
        $inputs = $this->allValidInputs();
        $before = $inputs;

        $result = Evaluator::compose($inputs);

        self::assertSame($before, $inputs);
        self::assertFalse($result['source_state_written']);
        self::assertFalse($result['source_state_mutated']);
    }

    public function testExactlyThreeConceptualSectionsRemainDistinct(): void
    {
        $result = Evaluator::compose([]);

        self::assertSame([
            Evaluator::SECTION_CURRENT_STATE,
            Evaluator::SECTION_NEXT_DECISION,
            Evaluator::SECTION_OPTIONAL_SUPPORT,
        ], array_keys($result['sections']));
    }

    public function testPrivacyMinimalProjectionOmitsBindingsAndPrivatePayloads(): void
    {
        $input = $this->readinessInput();
        $input['derived_result']['required_bindings'] = ['synthetic-private-MUST-NOT-LEAK'];
        $input['derived_result']['synthetic_private_profile'] = 'synthetic-private-MUST-NOT-LEAK';
        $encoded = json_encode(Evaluator::compose([$input]));

        self::assertIsString($encoded);
        self::assertStringNotContainsString('MUST-NOT-LEAK', $encoded);
        self::assertStringNotContainsString('required_bindings', $encoded);
    }

    public function testReadinessMayContributeStateWithoutLaunchAuthority(): void
    {
        $result = Evaluator::compose([$this->readinessInput()]);
        $fragment = $result['sections']['CURRENT_STATE']['fragments'][Evaluator::DOMAIN_READINESS];

        self::assertSame('NOT_READY', $fragment['classification']);
        self::assertFalse($result['launch_authority']);
    }

    public function testMatchMayContributeCandidateWithoutCreatingConnection(): void
    {
        $result = Evaluator::compose([$this->matchInput(withCandidate: true)]);

        self::assertSame(Evaluator::ACTION_RESPOND_MATCH, $result['sections']['NEXT_DECISION']['primary_action']['category']);
        self::assertFalse($result['connection_created']);
    }

    public function testConnectionMayContributeCandidateWithoutConsentOrConversationCreation(): void
    {
        $result = Evaluator::compose([$this->connectionInput(withCandidate: true)]);

        self::assertSame(Evaluator::ACTION_RESPOND_CONNECTION, $result['sections']['NEXT_DECISION']['primary_action']['category']);
        self::assertFalse($result['consent_created']);
        self::assertFalse($result['conversation_created']);
    }

    public function testConversationCandidateRequiresAtLeastOneAcceptedLiveCapability(): void
    {
        $denied = Evaluator::compose([$this->conversationInput(false, false, true)]);
        $read = Evaluator::compose([$this->conversationInput(true, false, true)]);
        $send = Evaluator::compose([$this->conversationInput(false, true, true)]);

        self::assertNull($denied['sections']['NEXT_DECISION']['primary_action']);
        self::assertSame(Evaluator::ACTION_OPEN_CONVERSATION, $read['sections']['NEXT_DECISION']['primary_action']['category']);
        self::assertSame(Evaluator::ACTION_OPEN_CONVERSATION, $send['sections']['NEXT_DECISION']['primary_action']['category']);
    }

    public function testLiveReadAndSendRemainDistinctVisibleFacts(): void
    {
        $readOnly = Evaluator::compose([$this->conversationInput(true, false)]);
        $fragment = $readOnly['sections']['CURRENT_STATE']['fragments'][Evaluator::DOMAIN_CONVERSATION];

        self::assertTrue($fragment['live_read_allowed']);
        self::assertFalse($fragment['live_send_allowed']);
    }

    public function testUnavailableDomainIsHandledSourceLocally(): void
    {
        $unknownReadiness = $this->readinessInput();
        $unknownReadiness['availability'] = Evaluator::AVAILABILITY_UNAVAILABLE;
        $result = Evaluator::compose([$unknownReadiness, $this->connectionInput()]);

        self::assertSame('UNAVAILABLE', $result['sections']['CURRENT_STATE']['fragments'][Evaluator::DOMAIN_READINESS]['availability']);
        self::assertSame('CN_PENDING', $result['sections']['CURRENT_STATE']['fragments'][Evaluator::DOMAIN_CONNECTION]['classification']);
    }

    public function testEveryUnusableAvailabilityRemainsSourceLocal(): void
    {
        foreach ([
            Evaluator::AVAILABILITY_UNKNOWN,
            Evaluator::AVAILABILITY_UNAVAILABLE,
            Evaluator::AVAILABILITY_STALE,
            Evaluator::AVAILABILITY_SUPERSEDED,
            Evaluator::AVAILABILITY_INCOMPARABLE,
        ] as $availability) {
            $match = $this->matchInput(withCandidate: true);
            $match['availability'] = $availability;
            $result = Evaluator::compose([$match, $this->connectionInput()]);

            self::assertSame($availability, $result['sections']['CURRENT_STATE']['fragments'][Evaluator::DOMAIN_MATCH]['availability']);
            self::assertSame('CN_PENDING', $result['sections']['CURRENT_STATE']['fragments'][Evaluator::DOMAIN_CONNECTION]['classification']);
            self::assertNull($result['sections']['NEXT_DECISION']['primary_action']);
        }
    }

    public function testUnknownSourceDoesNotEraseIndependentValidFacts(): void
    {
        $unknownMatch = $this->matchInput();
        $unknownMatch['availability'] = Evaluator::AVAILABILITY_UNKNOWN;
        $result = Evaluator::compose([$unknownMatch, $this->readinessInput(), $this->conversationInput(true, false)]);

        self::assertSame('NOT_READY', $result['sections']['CURRENT_STATE']['fragments'][Evaluator::DOMAIN_READINESS]['classification']);
        self::assertTrue($result['sections']['CURRENT_STATE']['fragments'][Evaluator::DOMAIN_CONVERSATION]['live_read_allowed']);
    }

    public function testZeroValidCandidatesYieldsNoPrimaryAction(): void
    {
        $result = Evaluator::compose([$this->readinessInput(withCandidate: false)]);

        self::assertSame(0, $result['sections']['NEXT_DECISION']['valid_candidate_count']);
        self::assertNull($result['sections']['NEXT_DECISION']['primary_action']);
    }

    public function testExactlyOneValidCandidateMayBecomePrimary(): void
    {
        $result = Evaluator::compose([$this->readinessInput(withCandidate: true)]);

        self::assertSame(1, $result['sections']['NEXT_DECISION']['valid_candidate_count']);
        self::assertSame(Evaluator::ACTION_COMPLETE_READINESS, $result['sections']['NEXT_DECISION']['primary_action']['category']);
    }

    public function testMultipleValidCandidatesWithoutPrecedenceYieldNoPrimary(): void
    {
        $result = Evaluator::compose([
            $this->readinessInput(withCandidate: true),
            $this->matchInput(withCandidate: true),
        ]);

        self::assertSame(2, $result['sections']['NEXT_DECISION']['valid_candidate_count']);
        self::assertNull($result['sections']['NEXT_DECISION']['primary_action']);
        self::assertSame('NO_ACCEPTED_PRECEDENCE_MULTI_CANDIDATE', $result['sections']['NEXT_DECISION']['resolution']);
    }

    public function testHomeNeverRanksScoresOrChoosesByArbitraryOrder(): void
    {
        $result = Evaluator::compose($this->allValidInputs(withCandidates: true));

        self::assertFalse($result['sections']['NEXT_DECISION']['precedence_applied']);
        self::assertFalse($result['sections']['NEXT_DECISION']['ranking_applied']);
        self::assertNull($result['sections']['NEXT_DECISION']['primary_action']);
        self::assertFalse($result['ranking_computed']);
        self::assertFalse($result['compatibility_total_computed']);
    }

    public function testReorderingDomainInputsDoesNotChangeNoPrecedenceOutcome(): void
    {
        $forward = $this->allValidInputs(withCandidates: true);
        $reverse = array_reverse($forward);

        self::assertSame(Evaluator::compose($forward), Evaluator::compose($reverse));
    }

    public function testExactDuplicateActionIdentityAndPayloadDeduplicates(): void
    {
        $input = $this->matchInput(withCandidate: true);
        $input['action_candidates'][] = $input['action_candidates'][0];
        $result = Evaluator::compose([$input]);

        self::assertSame(1, $result['sections']['NEXT_DECISION']['valid_candidate_count']);
        self::assertSame('synthetic-action-match-A', $result['sections']['NEXT_DECISION']['primary_action']['action_identity']);
    }

    public function testConflictingSameIdentityPayloadFailsClosed(): void
    {
        $input = $this->matchInput(withCandidate: true);
        $conflict = $input['action_candidates'][0];
        $conflict['semantic_payload']['presentation_variant'] = 'COMPACT';
        $input['action_candidates'][] = $conflict;
        $result = Evaluator::compose([$input]);

        self::assertNull($result['sections']['NEXT_DECISION']['primary_action']);
        self::assertContains('synthetic-action-match-A', $result['sections']['NEXT_DECISION']['conflicting_action_identities']);
        self::assertSame('CONFLICTING_ACTION_IDENTITY_FAIL_CLOSED', $result['sections']['NEXT_DECISION']['resolution']);
    }

    public function testDependencyInvalidationRemovesOnlyAffectedFragmentAndCandidate(): void
    {
        $composition = Evaluator::compose([
            $this->readinessInput(withCandidate: true),
            $this->connectionInput(withCandidate: true),
            $this->conversationInput(true, false),
        ]);
        foreach ([
            CommonContract::INVALIDATION_CORRECTION,
            CommonContract::INVALIDATION_REVOCATION,
            CommonContract::INVALIDATION_SUPERSESSION,
        ] as $relation) {
            $invalidated = Evaluator::invalidate(
                $composition,
                Evaluator::DOMAIN_READINESS,
                'synthetic-readiness-dependency-A',
                $relation,
            );

            self::assertSame('INVALIDATED', $invalidated['sections']['CURRENT_STATE']['fragments'][Evaluator::DOMAIN_READINESS]['availability']);
            self::assertSame('CN_PENDING', $invalidated['sections']['CURRENT_STATE']['fragments'][Evaluator::DOMAIN_CONNECTION]['classification']);
            self::assertTrue($invalidated['sections']['CURRENT_STATE']['fragments'][Evaluator::DOMAIN_CONVERSATION]['live_read_allowed']);
            self::assertSame(1, $invalidated['sections']['NEXT_DECISION']['valid_candidate_count']);
            self::assertSame(Evaluator::ACTION_RESPOND_CONNECTION, $invalidated['sections']['NEXT_DECISION']['primary_action']['category']);
        }
    }

    public function testHomeCreatesNoSourceOrDownstreamAuthority(): void
    {
        $result = Evaluator::compose($this->allValidInputs());

        self::assertFalse($result['source_authority']);
        self::assertFalse($result['permission']);
        self::assertFalse($result['bearer_capability']);
        self::assertFalse($result['launch_authority']);
        self::assertFalse($result['match_created']);
        self::assertFalse($result['connection_created']);
        self::assertFalse($result['consent_created']);
        self::assertFalse($result['conversation_created']);
        self::assertFalse($result['relationship_authority']);
        self::assertFalse($result['notification_authority']);
    }

    public function testHomeReadsOrEmitsNoPrivateConversationOrForbiddenSignals(): void
    {
        $input = $this->conversationInput(true, true);
        $input['derived_result']['synthetic_message'] = 'synthetic-private-MUST-NOT-LEAK';
        $input['derived_result']['unread_count'] = 999;
        $input['derived_result']['hidden_safety_evidence'] = 'synthetic-private-MUST-NOT-LEAK';
        $encoded = json_encode(Evaluator::compose([$input]));

        self::assertIsString($encoded);
        self::assertStringNotContainsString('MUST-NOT-LEAK', $encoded);
        self::assertStringNotContainsString('unread_count', $encoded);
        $result = Evaluator::compose([$input]);
        self::assertFalse($result['conversation_content_read']);
        self::assertFalse($result['conversation_content_exposed']);
        self::assertFalse($result['telemetry_read']);
        self::assertFalse($result['analytics_authority']);
        self::assertFalse($result['training_authority']);
        self::assertFalse($result['ads_authority']);
        self::assertFalse($result['desirability_computed']);
        self::assertFalse($result['person_worth_computed']);
    }

    /** @return list<array<string, mixed>> */
    private function allValidInputs(bool $withCandidates = false): array
    {
        return [
            $this->readinessInput(withCandidate: $withCandidates),
            $this->matchInput(withCandidate: $withCandidates),
            $this->connectionInput(withCandidate: $withCandidates),
            $this->conversationInput(true, false, $withCandidates),
        ];
    }

    /** @return array<string, mixed> */
    private function readinessInput(bool $withCandidate = false): array
    {
        return $this->input(
            Evaluator::DOMAIN_READINESS,
            'synthetic-readiness-dependency-A',
            [
                'record_kind' => 'RUNTIME_READINESS_DERIVATION',
                'classification' => 'NOT_READY',
                'prerequisite_set_identity' => 'synthetic-readiness-set-A',
                'valid_for_protected_use' => true,
            ],
            $withCandidate ? [$this->candidate(
                'synthetic-action-readiness-A',
                Evaluator::ACTION_COMPLETE_READINESS,
                'synthetic-readiness-set-A',
            )] : [],
        );
    }

    /** @return array<string, mixed> */
    private function matchInput(bool $withCandidate = false): array
    {
        return $this->input(
            Evaluator::DOMAIN_MATCH,
            'synthetic-match-dependency-A',
            [
                'record_kind' => 'CANONICAL_MATCH_PROPOSAL_DECISION_DERIVATION',
                'classification' => 'PENDING',
                'proposal_identity' => 'synthetic-proposal-A',
                'valid_for_protected_use' => true,
            ],
            $withCandidate ? [$this->candidate(
                'synthetic-action-match-A',
                Evaluator::ACTION_RESPOND_MATCH,
                'synthetic-proposal-A',
            )] : [],
        );
    }

    /** @return array<string, mixed> */
    private function connectionInput(bool $withCandidate = false): array
    {
        return $this->input(
            Evaluator::DOMAIN_CONNECTION,
            'synthetic-connection-dependency-A',
            [
                'record_kind' => 'PRODUCT_CONNECTION_CURRENT_STATE_DERIVATION',
                'classification' => 'CN_PENDING',
                'current_state' => 'CN_PENDING',
                'connection_identity' => 'synthetic-connection-A',
                'connection_active_for_downstream_consideration' => false,
                'valid_for_protected_use' => true,
            ],
            $withCandidate ? [$this->candidate(
                'synthetic-action-connection-A',
                Evaluator::ACTION_RESPOND_CONNECTION,
                'synthetic-connection-A',
            )] : [],
        );
    }

    /** @return array<string, mixed> */
    private function conversationInput(bool $read, bool $send, bool $withCandidate = false): array
    {
        return $this->input(
            Evaluator::DOMAIN_CONVERSATION,
            'synthetic-conversation-dependency-A',
            [
                'record_kind' => 'CONVERSATION_LIVE_GATE_DERIVATION',
                'connection_identity' => 'synthetic-connection-A',
                'live_read_allowed' => $read,
                'live_send_allowed' => $send,
                'valid_for_live_read' => $read,
                'valid_for_live_send' => $send,
            ],
            $withCandidate ? [$this->candidate(
                'synthetic-action-conversation-A',
                Evaluator::ACTION_OPEN_CONVERSATION,
                'synthetic-connection-A',
            )] : [],
        );
    }

    /** @return array<string, mixed> */
    private function input(string $domain, string $dependencyIdentity, array $result, array $candidates): array
    {
        return [
            'domain' => $domain,
            'availability' => Evaluator::AVAILABILITY_PRESENT,
            'dependency_identity' => $dependencyIdentity,
            'derived_result' => $result,
            'action_candidates' => $candidates,
        ];
    }

    /** @return array<string, mixed> */
    private function candidate(string $identity, string $category, string $contextIdentity): array
    {
        return [
            'action_identity' => $identity,
            'category' => $category,
            'currently_valid' => true,
            'semantic_payload' => [
                'context_identity' => $contextIdentity,
                'presentation_variant' => 'STANDARD',
            ],
        ];
    }
}
