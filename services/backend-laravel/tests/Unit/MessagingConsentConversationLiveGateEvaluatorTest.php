<?php

namespace Tests\Unit;

use App\Domain\CommonAuthorityEvidenceContract as CommonContract;
use App\Domain\MessagingConsentConversationLiveGateEvaluator as Evaluator;
use App\Domain\ProductConnectionStateTransitionEvaluator as ConnectionEvaluator;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

final class MessagingConsentConversationLiveGateEvaluatorTest extends TestCase
{
    public function testConsentVocabularyIsExactAndUnknownIsExcluded(): void
    {
        self::assertSame([
            'MC_NONE',
            'MC_PENDING',
            'MC_ACTIVE',
            'MC_DECLINED',
            'MC_WITHDRAWN',
            'MC_REVOKED',
        ], Evaluator::lifecycleVocabulary());
        self::assertNotContains(Evaluator::DERIVED_UNKNOWN, Evaluator::lifecycleVocabulary());
    }

    public function testExactlyTwoDistinctConnectionParticipantsAreRequired(): void
    {
        $one = $this->consent();
        $one['participants'] = ['synthetic-participant-A'];
        $duplicate = $this->consent();
        $duplicate['participants'] = ['synthetic-participant-A', 'synthetic-participant-A'];

        self::assertSame(Evaluator::DERIVED_UNKNOWN, $this->transitionResult($one, Evaluator::STATE_NONE, Evaluator::STATE_PENDING)['classification']);
        self::assertSame(Evaluator::DERIVED_UNKNOWN, $this->transitionResult($duplicate, Evaluator::STATE_NONE, Evaluator::STATE_PENDING)['classification']);
    }

    public function testNoneToPendingRequiresCurrentFreshExactActiveConnection(): void
    {
        $active = $this->transitionResult($this->consent(), Evaluator::STATE_NONE, Evaluator::STATE_PENDING);
        $stale = $this->transitionResult(
            $this->consent(),
            Evaluator::STATE_NONE,
            Evaluator::STATE_PENDING,
            connectionFreshness: false,
        );

        self::assertSame(Evaluator::TRANSITION_ADMISSIBLE, $active['classification']);
        self::assertSame(Evaluator::DERIVED_UNKNOWN, $stale['classification']);
    }

    #[DataProvider('nonActiveConnectionProvider')]
    public function testNonActiveConnectionCannotCreateUsableConsentRequest(string $connectionState): void
    {
        $result = $this->transitionResult(
            $this->consent(),
            Evaluator::STATE_NONE,
            Evaluator::STATE_PENDING,
            connectionState: $connectionState,
        );

        self::assertSame(Evaluator::TRANSITION_REJECTED, $result['classification']);
        self::assertContains('CONSENT_REQUEST_REQUIRES_CURRENT_ACTIVE_CONNECTION', $result['reasons']);
    }

    /** @return iterable<string, array{string}> */
    public static function nonActiveConnectionProvider(): iterable
    {
        yield 'none' => [ConnectionEvaluator::STATE_NONE];
        yield 'pending' => [ConnectionEvaluator::STATE_PENDING];
        yield 'paused' => [ConnectionEvaluator::STATE_PAUSED];
        yield 'closed' => [ConnectionEvaluator::STATE_CLOSED];
        yield 'declined' => [ConnectionEvaluator::STATE_DECLINED];
        yield 'withdrawn' => [ConnectionEvaluator::STATE_WITHDRAWN];
        yield 'expired' => [ConnectionEvaluator::STATE_EXPIRED];
    }

    #[DataProvider('roleBoundTransitionProvider')]
    public function testRoleBoundCanonicalTransitionIsAdmissible(string $from, string $to, string $actor): void
    {
        $result = $this->transitionResult($this->consent(), $from, $to, actor: $actor);

        self::assertSame(Evaluator::TRANSITION_ADMISSIBLE, $result['classification']);
        self::assertSame($from, $result['current_state']);
        self::assertSame($to, $result['proposed_state']);
    }

    /** @return iterable<string, array{string, string, string}> */
    public static function roleBoundTransitionProvider(): iterable
    {
        yield 'requester requests' => [Evaluator::STATE_NONE, Evaluator::STATE_PENDING, 'synthetic-participant-A'];
        yield 'recipient accepts' => [Evaluator::STATE_PENDING, Evaluator::STATE_ACTIVE, 'synthetic-participant-B'];
        yield 'recipient declines' => [Evaluator::STATE_PENDING, Evaluator::STATE_DECLINED, 'synthetic-participant-B'];
        yield 'requester withdraws' => [Evaluator::STATE_PENDING, Evaluator::STATE_WITHDRAWN, 'synthetic-participant-A'];
        yield 'requester revokes' => [Evaluator::STATE_ACTIVE, Evaluator::STATE_REVOKED, 'synthetic-participant-A'];
        yield 'recipient revokes' => [Evaluator::STATE_ACTIVE, Evaluator::STATE_REVOKED, 'synthetic-participant-B'];
    }

    public function testRequesterSelfAcceptCannotSubstituteForRecipientAcceptance(): void
    {
        $result = $this->transitionResult(
            $this->consent(),
            Evaluator::STATE_PENDING,
            Evaluator::STATE_ACTIVE,
            actor: 'synthetic-participant-A',
        );

        self::assertSame(Evaluator::TRANSITION_REJECTED, $result['classification']);
        self::assertContains('RECIPIENT_BOUND_DECISION_REQUIRED', $result['reasons']);
    }

    #[DataProvider('forbiddenTransitionProvider')]
    public function testPauseResumeCloseAndImplicitReactivationAreRejected(string $from, string $to): void
    {
        $result = $this->transitionResult($this->consent(), $from, $to, actor: 'synthetic-participant-B');

        self::assertSame(Evaluator::TRANSITION_REJECTED, $result['classification']);
    }

    /** @return iterable<string, array{string, string}> */
    public static function forbiddenTransitionProvider(): iterable
    {
        yield 'active to pending' => [Evaluator::STATE_ACTIVE, Evaluator::STATE_PENDING];
        yield 'pause target' => [Evaluator::STATE_ACTIVE, 'MC_PAUSED'];
        yield 'resume source' => [Evaluator::STATE_NONE, Evaluator::STATE_ACTIVE];
        yield 'close target' => [Evaluator::STATE_ACTIVE, 'MC_CLOSED'];
    }

    #[DataProvider('terminalConsentProvider')]
    public function testTerminalSameIdentityConsentCannotReopen(string $terminal): void
    {
        $result = $this->transitionResult($this->consent(), $terminal, Evaluator::STATE_PENDING);

        self::assertSame(Evaluator::TRANSITION_REJECTED, $result['classification']);
        self::assertContains('TERMINAL_CONSENT_IDENTITY_CANNOT_REOPEN', $result['reasons']);
        self::assertFalse($result['consent_reopened']);
        self::assertFalse($result['consent_lifecycle_reset']);
    }

    /** @return iterable<string, array{string}> */
    public static function terminalConsentProvider(): iterable
    {
        yield 'declined' => [Evaluator::STATE_DECLINED];
        yield 'withdrawn' => [Evaluator::STATE_WITHDRAWN];
        yield 'revoked' => [Evaluator::STATE_REVOKED];
    }

    public function testLaterConsentLifecycleRequiresFreshIdentityAndFullPath(): void
    {
        $old = $this->transitionResult($this->consent(), Evaluator::STATE_REVOKED, Evaluator::STATE_PENDING);
        $freshConsent = $this->consent('synthetic-consent-B');
        $request = $this->transitionResult($freshConsent, Evaluator::STATE_NONE, Evaluator::STATE_PENDING);
        $accept = $this->transitionResult(
            $freshConsent,
            Evaluator::STATE_PENDING,
            Evaluator::STATE_ACTIVE,
            actor: 'synthetic-participant-B',
        );

        self::assertSame(Evaluator::TRANSITION_REJECTED, $old['classification']);
        self::assertSame(Evaluator::TRANSITION_ADMISSIBLE, $request['classification']);
        self::assertSame(Evaluator::TRANSITION_ADMISSIBLE, $accept['classification']);
        self::assertNotSame($old['consent_identity'], $request['consent_identity']);
    }

    public function testNewConnectionIdentityDoesNotInheritOldConsent(): void
    {
        $newConnection = $this->connection('synthetic-connection-B');
        $result = Evaluator::evaluateLiveGates(
            $newConnection,
            [$this->connectionEvidence(ConnectionEvaluator::STATE_ACTIVE, 'synthetic-connection-B')],
            $this->consent(connectionIdentity: 'synthetic-connection-A'),
            [$this->consentEvidence(Evaluator::STATE_ACTIVE)],
            $this->consent('synthetic-consent-send-A', 'synthetic-connection-A', Evaluator::PURPOSE_LIVE_SEND),
            [$this->consentEvidence(Evaluator::STATE_ACTIVE, purpose: Evaluator::PURPOSE_LIVE_SEND, consentIdentity: 'synthetic-consent-send-A')],
        );

        self::assertFalse($result['live_read_allowed']);
        self::assertFalse($result['live_send_allowed']);
        self::assertFalse($result['connection_inherited_consent']);
    }

    public function testCrossConnectionAndWrongParticipantConsentEvidenceFailClosed(): void
    {
        $cross = $this->consentEvidence(Evaluator::STATE_ACTIVE, connectionIdentity: 'synthetic-connection-B');
        $wrongParticipant = $this->consentEvidence(Evaluator::STATE_ACTIVE);
        $wrongParticipant['participants'] = ['synthetic-participant-A', 'synthetic-participant-C'];

        $crossResult = $this->liveGate(readEvidence: [$cross]);
        $participantResult = $this->liveGate(readEvidence: [$wrongParticipant]);

        self::assertFalse($crossResult['live_read_allowed']);
        self::assertFalse($participantResult['live_read_allowed']);
    }

    public function testMissingAndUnusableConsentConditionsFailClosed(): void
    {
        self::assertFalse($this->liveGate(readEvidence: [])['live_read_allowed']);

        foreach ([
            CommonContract::CONDITION_UNKNOWN,
            CommonContract::CONDITION_UNAVAILABLE,
            CommonContract::CONDITION_STALE,
            CommonContract::CONDITION_SUPERSEDED,
            CommonContract::CONDITION_INCOMPARABLE,
        ] as $condition) {
            $result = $this->liveGate(readEvidence: [$this->consentEvidence(Evaluator::STATE_ACTIVE, condition: $condition)]);
            self::assertFalse($result['live_read_allowed']);
        }
    }

    public function testCurrentButStaleFailsAndFreshnessCannotManufactureCurrentness(): void
    {
        $stale = $this->liveGate(readEvidence: [$this->consentEvidence(Evaluator::STATE_ACTIVE, currentness: true, freshness: false)]);
        $notCurrent = $this->liveGate(readEvidence: [$this->consentEvidence(Evaluator::STATE_ACTIVE, currentness: false, freshness: true)]);

        self::assertFalse($stale['live_read_allowed']);
        self::assertFalse($notCurrent['live_read_allowed']);
    }

    public function testConflictingEqualRevisionConsentEvidenceFailsClosed(): void
    {
        $result = $this->liveGate(readEvidence: [
            $this->consentEvidence(Evaluator::STATE_ACTIVE),
            $this->consentEvidence(Evaluator::STATE_REVOKED),
        ]);

        self::assertFalse($result['live_read_allowed']);
        self::assertContains('CONFLICTING_EQUAL_REVISION_CONSENT_EVIDENCE', $result['reasons']['read']);
    }

    public function testIncomparableDuplicateConsentEvidenceFailsClosed(): void
    {
        $incomparable = $this->consentEvidence(Evaluator::STATE_ACTIVE, revision: 9);
        $incomparable['source_evidence']['source_revision'] = CommonContract::sourceRevision(
            'synthetic-consent-authority',
            'synthetic-consent-scope',
            'synthetic-consent-lineage-B',
            'synthetic-consent-A',
            9,
        );
        $result = $this->liveGate(readEvidence: [
            $this->consentEvidence(Evaluator::STATE_ACTIVE),
            $incomparable,
        ]);

        self::assertFalse($result['live_read_allowed']);
        self::assertContains('INCOMPARABLE_DUPLICATE_CONSENT_EVIDENCE', $result['reasons']['read']);
    }

    public function testNewerSameLineageConsentControlsWithoutArrivalOrder(): void
    {
        $older = $this->consentEvidence(Evaluator::STATE_REVOKED, revision: 7);
        $newer = $this->consentEvidence(Evaluator::STATE_ACTIVE, revision: 8);
        $olderFirst = $this->liveGate(readEvidence: [$older, $newer]);
        $newerFirst = $this->liveGate(readEvidence: [$newer, $older]);

        self::assertTrue($olderFirst['live_read_allowed']);
        self::assertSame($olderFirst, $newerFirst);
        self::assertSame(8, $olderFirst['dependency_vector']['read_consent']['source_revision']['value']);
    }

    public function testNoGlobalRevisionOrLastReceivedWinsAuthorityExists(): void
    {
        $encoded = json_encode($this->liveGate());

        self::assertIsString($encoded);
        self::assertStringNotContainsString('global_revision', $encoded);
        self::assertStringNotContainsString('last_received', $encoded);
    }

    public function testActiveConnectionWithoutActiveConsentGrantsNoLiveAccess(): void
    {
        $result = $this->liveGate(
            readEvidence: [$this->consentEvidence(Evaluator::STATE_PENDING)],
            sendEvidence: [$this->consentEvidence(Evaluator::STATE_PENDING, purpose: Evaluator::PURPOSE_LIVE_SEND, consentIdentity: 'synthetic-consent-send-A')],
        );

        self::assertFalse($result['live_read_allowed']);
        self::assertFalse($result['live_send_allowed']);
    }

    public function testActiveConsentWithoutCurrentActiveConnectionGrantsNoLiveAccess(): void
    {
        $result = $this->liveGate(connectionState: ConnectionEvaluator::STATE_PAUSED);

        self::assertFalse($result['live_read_allowed']);
        self::assertFalse($result['live_send_allowed']);
    }

    public function testReadPurposeConsentAllowsReadOnly(): void
    {
        $result = $this->liveGate(sendEvidence: []);

        self::assertTrue($result['live_read_allowed']);
        self::assertFalse($result['live_send_allowed']);
    }

    public function testSendPurposeConsentAllowsSendOnly(): void
    {
        $result = $this->liveGate(readEvidence: []);

        self::assertFalse($result['live_read_allowed']);
        self::assertTrue($result['live_send_allowed']);
    }

    public function testReadAndSendPurposeBindingsDoNotSubstitute(): void
    {
        $readAsSend = $this->consentEvidence(Evaluator::STATE_ACTIVE);
        $sendAsRead = $this->consentEvidence(
            Evaluator::STATE_ACTIVE,
            purpose: Evaluator::PURPOSE_LIVE_SEND,
            consentIdentity: 'synthetic-consent-send-A',
        );
        $result = $this->liveGate(readEvidence: [$sendAsRead], sendEvidence: [$readAsSend]);

        self::assertFalse($result['live_read_allowed']);
        self::assertFalse($result['live_send_allowed']);
    }

    public function testRevocationImmediatelyFailsClosed(): void
    {
        $result = $this->liveGate(readEvidence: [$this->consentEvidence(Evaluator::STATE_REVOKED)]);

        self::assertFalse($result['live_read_allowed']);
        self::assertTrue($result['live_send_allowed']);
    }

    public function testConnectionAndConsentDependencyInvalidationAreScopedAndDoNotReopen(): void
    {
        $gate = $this->liveGate();
        $connectionInvalidated = Evaluator::invalidateLiveGate(
            $gate,
            'synthetic-connection-state-A',
            CommonContract::INVALIDATION_CORRECTION,
        );
        $readInvalidated = Evaluator::invalidateLiveGate(
            $gate,
            'synthetic-consent-evidence-A',
            CommonContract::INVALIDATION_SUPERSESSION,
        );

        self::assertFalse($connectionInvalidated['live_read_allowed']);
        self::assertFalse($connectionInvalidated['live_send_allowed']);
        self::assertFalse($readInvalidated['live_read_allowed']);
        self::assertTrue($readInvalidated['live_send_allowed']);
        self::assertFalse($readInvalidated['connection_lifecycle_reset']);
        self::assertFalse($readInvalidated['consent_lifecycle_reset']);
        self::assertFalse($readInvalidated['connection_reopened']);
        self::assertFalse($readInvalidated['consent_reopened']);
    }

    public function testEvaluatorCreatesNoConversationContentOrDownstreamAuthority(): void
    {
        $result = $this->liveGate();

        self::assertFalse($result['conversation_content_read']);
        self::assertFalse($result['conversation_content_written']);
        self::assertFalse($result['message_created']);
        self::assertFalse($result['message_sent']);
        self::assertFalse($result['unread_count_authority']);
        self::assertFalse($result['preview_authority']);
        self::assertFalse($result['notification_authority']);
        self::assertFalse($result['relationship_authority']);
        self::assertFalse($result['home_authority']);
    }

    public function testEvaluationDoesNotMutateConnectionOrConsentEvidence(): void
    {
        $connection = $this->connection();
        $connectionEvidence = [$this->connectionEvidence(ConnectionEvaluator::STATE_ACTIVE)];
        $readConsent = $this->consent();
        $readEvidence = [$this->consentEvidence(Evaluator::STATE_ACTIVE)];
        $sendConsent = $this->consent('synthetic-consent-send-A', purpose: Evaluator::PURPOSE_LIVE_SEND);
        $sendEvidence = [$this->consentEvidence(Evaluator::STATE_ACTIVE, purpose: Evaluator::PURPOSE_LIVE_SEND, consentIdentity: 'synthetic-consent-send-A')];
        $before = [$connection, $connectionEvidence, $readConsent, $readEvidence, $sendConsent, $sendEvidence];

        $result = Evaluator::evaluateLiveGates($connection, $connectionEvidence, $readConsent, $readEvidence, $sendConsent, $sendEvidence);

        self::assertFalse($result['source_evidence_mutated']);
        self::assertSame($before, [$connection, $connectionEvidence, $readConsent, $readEvidence, $sendConsent, $sendEvidence]);
    }

    public function testPrivacyMinimalResultOmitsRawPrivatePayloadAndForbiddenUseAuthorities(): void
    {
        $readEvidence = $this->consentEvidence(Evaluator::STATE_ACTIVE);
        $readEvidence['synthetic_private_reason'] = 'synthetic-private-MUST-NOT-LEAK';
        $result = $this->liveGate(readEvidence: [$readEvidence]);
        $encoded = json_encode($result);

        self::assertIsString($encoded);
        self::assertStringNotContainsString('MUST-NOT-LEAK', $encoded);
        self::assertStringNotContainsString('required_bindings', $encoded);
        self::assertFalse($result['ranking_computed']);
        self::assertFalse($result['compatibility_total_computed']);
        self::assertFalse($result['desirability_computed']);
        self::assertFalse($result['person_worth_computed']);
        self::assertFalse($result['training_authority']);
        self::assertFalse($result['analytics_authority']);
        self::assertFalse($result['ads_authority']);
    }

    private function transitionResult(
        array $consent,
        string $from,
        string $to,
        string $actor = 'synthetic-participant-A',
        string $connectionState = ConnectionEvaluator::STATE_ACTIVE,
        ?bool $connectionFreshness = true,
    ): array {
        return Evaluator::evaluateTransition(
            $consent,
            $this->connection($consent['connection_identity'] ?? 'synthetic-connection-A'),
            [$this->connectionEvidence($connectionState, $consent['connection_identity'] ?? 'synthetic-connection-A', freshness: $connectionFreshness)],
            [$this->consentEvidence($from, $consent['purpose'] ?? Evaluator::PURPOSE_LIVE_READ, $consent['consent_identity'] ?? 'synthetic-consent-A', $consent['connection_identity'] ?? 'synthetic-connection-A')],
            [$this->transitionEvidence($from, $to, $actor, $consent)],
        );
    }

    private function liveGate(
        ?array $readEvidence = null,
        ?array $sendEvidence = null,
        string $connectionState = ConnectionEvaluator::STATE_ACTIVE,
    ): array {
        $readEvidence ??= [$this->consentEvidence(Evaluator::STATE_ACTIVE)];
        $sendEvidence ??= [$this->consentEvidence(
            Evaluator::STATE_ACTIVE,
            purpose: Evaluator::PURPOSE_LIVE_SEND,
            consentIdentity: 'synthetic-consent-send-A',
        )];

        return Evaluator::evaluateLiveGates(
            $this->connection(),
            [$this->connectionEvidence($connectionState)],
            $this->consent(),
            $readEvidence,
            $this->consent('synthetic-consent-send-A', purpose: Evaluator::PURPOSE_LIVE_SEND),
            $sendEvidence,
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
    private function connectionEvidence(
        string $state,
        string $connectionIdentity = 'synthetic-connection-A',
        string $condition = CommonContract::CONDITION_PRESENT,
        ?bool $currentness = true,
        ?bool $freshness = true,
        int $revision = 7,
    ): array {
        $participants = ['synthetic-participant-A', 'synthetic-participant-B'];
        $terminal = in_array($state, [
            ConnectionEvaluator::STATE_CLOSED,
            ConnectionEvaluator::STATE_DECLINED,
            ConnectionEvaluator::STATE_WITHDRAWN,
            ConnectionEvaluator::STATE_EXPIRED,
        ], true);
        $bindings = $this->bindings(
            'synthetic-connection-authority',
            'synthetic-connection-scope',
            'synthetic-connection-authority-actor',
            $connectionIdentity,
            $participants,
            'synthetic-connection-transition-use',
            $connectionIdentity,
            $terminal,
        );

        return [
            'state_evidence_identity' => 'synthetic-connection-state-A',
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
    private function consent(
        string $consentIdentity = 'synthetic-consent-A',
        string $connectionIdentity = 'synthetic-connection-A',
        string $purpose = Evaluator::PURPOSE_LIVE_READ,
    ): array {
        return [
            'consent_identity' => $consentIdentity,
            'connection_identity' => $connectionIdentity,
            'participants' => ['synthetic-participant-A', 'synthetic-participant-B'],
            'requester' => 'synthetic-participant-A',
            'recipient' => 'synthetic-participant-B',
            'purpose' => $purpose,
        ];
    }

    /** @return array<string, mixed> */
    private function consentEvidence(
        string $state,
        string $purpose = Evaluator::PURPOSE_LIVE_READ,
        string $consentIdentity = 'synthetic-consent-A',
        string $connectionIdentity = 'synthetic-connection-A',
        string $condition = CommonContract::CONDITION_PRESENT,
        ?bool $currentness = true,
        ?bool $freshness = true,
        int $revision = 8,
    ): array {
        $participants = ['synthetic-participant-A', 'synthetic-participant-B'];
        $bindings = $this->bindings(
            'synthetic-consent-authority',
            'synthetic-consent-scope',
            'synthetic-consent-authority-actor',
            $connectionIdentity,
            $participants,
            $purpose,
            $consentIdentity,
            in_array($state, [Evaluator::STATE_DECLINED, Evaluator::STATE_WITHDRAWN, Evaluator::STATE_REVOKED], true),
        );

        return [
            'consent_evidence_identity' => $purpose === Evaluator::PURPOSE_LIVE_READ
                ? 'synthetic-consent-evidence-A'
                : 'synthetic-consent-send-evidence-A',
            'consent_identity' => $consentIdentity,
            'connection_identity' => $connectionIdentity,
            'participants' => $participants,
            'purpose' => $purpose,
            'state' => $state,
            'required_bindings' => $bindings,
            'source_evidence' => CommonContract::evidence(
                $bindings,
                $condition,
                CommonContract::sourceRevision(
                    'synthetic-consent-authority',
                    'synthetic-consent-scope',
                    'synthetic-consent-lineage-A',
                    $consentIdentity,
                    $revision,
                ),
                $currentness,
                $freshness,
            ),
        ];
    }

    /** @param array<string, mixed> $consent @return array<string, mixed> */
    private function transitionEvidence(string $from, string $to, string $actor, array $consent): array
    {
        $participants = $consent['participants'] ?? ['synthetic-participant-A', 'synthetic-participant-B'];
        $consentIdentity = $consent['consent_identity'] ?? 'synthetic-consent-A';
        $connectionIdentity = $consent['connection_identity'] ?? 'synthetic-connection-A';
        $purpose = $consent['purpose'] ?? Evaluator::PURPOSE_LIVE_READ;
        $bindings = $this->bindings(
            'synthetic-consent-transition-authority',
            'synthetic-consent-transition-scope',
            $actor,
            $connectionIdentity,
            $participants,
            $purpose,
            $consentIdentity,
            false,
        );

        return [
            'transition_identity' => 'synthetic-consent-transition-A',
            'consent_identity' => $consentIdentity,
            'connection_identity' => $connectionIdentity,
            'participants' => $participants,
            'purpose' => $purpose,
            'actor' => $actor,
            'from_state' => $from,
            'to_state' => $to,
            'expected_state_revision' => CommonContract::sourceRevision(
                'synthetic-consent-authority',
                'synthetic-consent-scope',
                'synthetic-consent-lineage-A',
                $consentIdentity,
                8,
            ),
            'required_bindings' => $bindings,
            'source_evidence' => CommonContract::evidence(
                $bindings,
                CommonContract::CONDITION_PRESENT,
                CommonContract::sourceRevision(
                    'synthetic-consent-transition-authority',
                    'synthetic-consent-transition-scope',
                    'synthetic-consent-transition-lineage-A',
                    $consentIdentity,
                    9,
                ),
                true,
                true,
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
            'actor_role' => 'synthetic-consent-role',
            'subject' => $subject,
            'participants' => $participants,
            'audience' => 'synthetic-conversation-gate-audience',
            'purpose' => $purpose,
            'aggregate_context' => $context,
            'lifecycle_identity' => $context,
            'terminal' => $terminal,
        ];
    }
}
