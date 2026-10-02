<?php

namespace Tests\Unit;

use App\Domain\CommonAuthorityEvidenceContract as Evidence;
use App\Domain\MessagingConsentConversationLiveGateEvaluator as Consent;
use App\Domain\MessagingConsentSyntheticLiveGateUsePoint;
use App\Domain\ProductConnectionStateTransitionEvaluator as Connection;
use PHPUnit\Framework\TestCase;

final class MessagingConsentSyntheticLiveGateUsePointTest extends TestCase
{
    public function test_read_and_send_take_separate_snapshots_and_only_build_their_own_sentinel(): void
    {
        $read = $this->snapshot();
        $read['send_consent_evidence'] = [];
        $send = $this->snapshot();
        $send['read_consent_evidence'] = [];
        $point = new MessagingConsentSyntheticLiveGateUsePoint([$read, $send]);

        $readResult = $point->attemptReadSynthetic($this->context());
        self::assertSame('SYNTHETIC_SENTINEL_CREATED', $readResult['condition']);
        self::assertSame(['ACQUIRE_READ', 'EVALUATE_READ', 'READ_SENTINEL'], $readResult['events']);
        self::assertSame(1, $readResult['read_sentinel_count']);
        self::assertSame(0, $readResult['send_sentinel_count']);

        $sendResult = $point->attemptSendSynthetic($this->context());
        self::assertSame('SYNTHETIC_SENTINEL_CREATED', $sendResult['condition']);
        self::assertSame(['ACQUIRE_SEND', 'EVALUATE_SEND', 'SEND_SENTINEL'], $sendResult['events']);
        self::assertSame(2, $sendResult['acquisition_count']);
        self::assertSame(1, $sendResult['read_sentinel_count']);
        self::assertSame(1, $sendResult['send_sentinel_count']);
        $this->assertNonAuthority($readResult);
        $this->assertNonAuthority($sendResult);
    }

    public function test_missing_nonactive_and_wrong_purpose_or_binding_fail_closed(): void
    {
        $cases = [];
        $item = $this->snapshot(); $item['connection_evidence'] = []; $cases[] = $item;
        $item = $this->snapshot(); $item['read_consent_evidence'] = []; $cases[] = $item;
        $item = $this->snapshot(); $item['connection_evidence'][0] = $this->connectionEvidence('CN_CLOSED'); $cases[] = $item;
        $item = $this->snapshot(); $item['read_consent_evidence'][0] = $this->consentEvidence('MC_PENDING', Consent::PURPOSE_LIVE_READ); $cases[] = $item;
        $item = $this->snapshot(); $item['read_consent']['purpose'] = Consent::PURPOSE_LIVE_SEND; $cases[] = $item;
        $item = $this->snapshot(); $item['read_consent_evidence'][0]['required_bindings']['audience'] = 'other-audience'; $cases[] = $item;
        $item = $this->snapshot(); $item['read_consent_evidence'][0]['participants'][1] = 'other-participant'; $cases[] = $item;
        $item = $this->snapshot(); $item['read_consent']['connection_identity'] = 'other-connection'; $cases[] = $item;

        foreach ($cases as $snapshot) {
            $point = new MessagingConsentSyntheticLiveGateUsePoint([$snapshot]);
            $result = $point->attemptReadSynthetic($this->context());
            self::assertFalse($result['sentinel_constructed']);
            self::assertSame(0, $result['read_sentinel_count']);
            self::assertSame(1, $result['acquisition_count']);
            $this->assertNonAuthority($result);
        }
    }

    public function test_newer_revocation_stale_source_invalidation_and_timeout_cannot_build_sentinel(): void
    {
        $cases = [];
        $item = $this->snapshot();
        $item['read_consent_evidence'] = [
            $this->consentEvidence('MC_ACTIVE', Consent::PURPOSE_LIVE_READ, 7),
            $this->consentEvidence('MC_REVOKED', Consent::PURPOSE_LIVE_READ, 8),
        ];
        $cases[] = $item;
        $item = $this->snapshot();
        $item['read_consent_evidence'][0]['source_evidence']['freshness'] = false;
        $cases[] = $item;
        $item = $this->snapshot();
        $item['invalidations'] = [[
            'dependency_identity' => 'read-evidence',
            'relation' => Evidence::INVALIDATION_REVOCATION,
        ]];
        $cases[] = $item;
        $item = $this->snapshot(); $item['source_status'] = 'TIMEOUT'; $cases[] = $item;

        foreach ($cases as $snapshot) {
            $point = new MessagingConsentSyntheticLiveGateUsePoint([$snapshot]);
            $result = $point->attemptReadSynthetic($this->context());
            self::assertFalse($result['sentinel_constructed']);
            self::assertSame(0, $result['read_sentinel_count']);
            $this->assertNonAuthority($result);
        }
    }

    public function test_send_commit_uses_new_snapshot_after_read_and_rejects_changed_consent_or_connection(): void
    {
        foreach (['consent', 'connection'] as $changed) {
            $later = $this->snapshot();
            if ($changed === 'consent') {
                $later['send_consent_evidence'][0] = $this->consentEvidence('MC_REVOKED', Consent::PURPOSE_LIVE_SEND);
            } else {
                $later['connection_evidence'][0] = $this->connectionEvidence('CN_CLOSED');
            }
            $point = new MessagingConsentSyntheticLiveGateUsePoint([$this->snapshot(), $later]);
            self::assertTrue($point->attemptReadSynthetic($this->context())['sentinel_constructed']);
            $result = $point->attemptSendSynthetic($this->context());
            self::assertFalse($result['sentinel_constructed']);
            self::assertSame(2, $result['acquisition_count']);
            self::assertSame(0, $result['send_sentinel_count']);
            $this->assertNonAuthority($result);
        }
    }

    public function test_prebuilt_payload_is_rejected_before_acquisition_or_sentinel(): void
    {
        $point = new MessagingConsentSyntheticLiveGateUsePoint([$this->snapshot()]);
        $context = $this->context();
        $context['prebuilt_private_sentinel'] = 'forbidden';
        $result = $point->attemptReadSynthetic($context);
        self::assertSame('INVALID_CONTEXT', $result['condition']);
        self::assertSame(0, $result['acquisition_count']);
        self::assertSame([], $result['events']);
        self::assertFalse($result['sentinel_constructed']);
        $this->assertNonAuthority($result);
    }

    /** @return array<string, mixed> */
    private function context(): array
    {
        return [
            'connection_identity' => 'connection-a',
            'participants' => ['participant-a', 'participant-b'],
            'protected_audience' => 'conversation-audience',
            'read_consent_identity' => 'consent-read',
            'send_consent_identity' => 'consent-send',
            'requester' => 'participant-a', 'recipient' => 'participant-b',
            'synthetic_intent_identity' => 'intent-a',
        ];
    }

    /** @return array<string, mixed> */
    private function snapshot(): array
    {
        return [
            'source_status' => 'OK',
            'connection' => [
                'connection_identity' => 'connection-a',
                'participants' => ['participant-a', 'participant-b'],
                'protected_use_scope' => 'connection-use',
            ],
            'connection_evidence' => [$this->connectionEvidence('CN_ACTIVE')],
            'read_consent' => $this->consent('consent-read', Consent::PURPOSE_LIVE_READ),
            'read_consent_evidence' => [$this->consentEvidence('MC_ACTIVE', Consent::PURPOSE_LIVE_READ)],
            'send_consent' => $this->consent('consent-send', Consent::PURPOSE_LIVE_SEND),
            'send_consent_evidence' => [$this->consentEvidence('MC_ACTIVE', Consent::PURPOSE_LIVE_SEND)],
            'invalidations' => [],
        ];
    }

    /** @return array<string, mixed> */
    private function connectionEvidence(string $state): array
    {
        $terminal = in_array($state, ['CN_CLOSED', 'CN_DECLINED', 'CN_WITHDRAWN', 'CN_EXPIRED'], true);
        $bindings = $this->bindings('CN_SOURCE', 'CN_SCOPE', 'connection-a', 'connection-a', 'connection-use', $terminal);
        return [
            'state_evidence_identity' => 'connection-evidence',
            'connection_identity' => 'connection-a',
            'participants' => ['participant-a', 'participant-b'],
            'state' => $state,
            'required_bindings' => $bindings,
            'source_evidence' => Evidence::evidence(
                $bindings, Evidence::CONDITION_PRESENT,
                Evidence::sourceRevision('CN_SOURCE', 'CN_SCOPE', 'cn-lineage', 'connection-a', 7),
                true, true,
            ),
        ];
    }

    /** @return array<string, mixed> */
    private function consent(string $identity, string $purpose): array
    {
        return [
            'consent_identity' => $identity,
            'connection_identity' => 'connection-a',
            'participants' => ['participant-a', 'participant-b'],
            'requester' => 'participant-a', 'recipient' => 'participant-b',
            'purpose' => $purpose,
        ];
    }

    /** @return array<string, mixed> */
    private function consentEvidence(string $state, string $purpose, int $revision = 7): array
    {
        $identity = $purpose === Consent::PURPOSE_LIVE_READ ? 'consent-read' : 'consent-send';
        $event = $purpose === Consent::PURPOSE_LIVE_READ ? 'read-evidence' : 'send-evidence';
        $terminal = in_array($state, ['MC_DECLINED', 'MC_WITHDRAWN', 'MC_REVOKED'], true);
        $bindings = $this->bindings('MC_SOURCE', 'MC_SCOPE', 'connection-a', $identity, $purpose, $terminal);
        return [
            'consent_evidence_identity' => $event,
            'consent_identity' => $identity,
            'connection_identity' => 'connection-a',
            'participants' => ['participant-a', 'participant-b'],
            'purpose' => $purpose,
            'state' => $state,
            'required_bindings' => $bindings,
            'source_evidence' => Evidence::evidence(
                $bindings, Evidence::CONDITION_PRESENT,
                Evidence::sourceRevision('MC_SOURCE', 'MC_SCOPE', 'mc-lineage-'.$identity, $identity, $revision),
                true, true,
            ),
        ];
    }

    /** @return array<string, mixed> */
    private function bindings(string $owner, string $scope, string $subject, string $context, string $purpose, bool $terminal): array
    {
        return [
            'authority_owner' => $owner, 'authority_scope' => $scope,
            'actor' => $owner, 'actor_role' => 'SYNTHETIC_SOURCE',
            'subject' => $subject,
            'participants' => ['participant-a', 'participant-b'],
            'audience' => 'conversation-audience', 'purpose' => $purpose,
            'aggregate_context' => $context, 'lifecycle_identity' => $context,
            'terminal' => $terminal,
        ];
    }

    /** @param array<string, mixed> $result */
    private function assertNonAuthority(array $result): void
    {
        self::assertTrue($result['synthetic_only']);
        foreach (['source_authority', 'permission', 'message_sent', 'conversation_content_read'] as $key) {
            self::assertFalse($result[$key]);
        }
    }
}
