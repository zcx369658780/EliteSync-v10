<?php

namespace Tests\Unit;

use App\Domain\CommonAuthorityEvidenceContract;
use App\Domain\InMemoryLogicalPersistenceRepositoryContract as Repository;
use App\Domain\MessagingConsentPersistenceApplicationAdapter;
use App\Domain\PersistenceBoundaryApplicationInterfaceIntegrationContract;
use App\Domain\SqliteInMemoryLogicalPersistenceAdapter;
use PHPUnit\Framework\TestCase;

final class MessagingConsentPersistenceApplicationAdapterTest extends TestCase
{
    public function test_single_source_correlation_and_exact_duplicate_are_non_authoritative(): void
    {
        [$adapter, $store] = $this->adapter();
        $request = $this->request();
        $first = $adapter->correlateCurrentSynthetic($request);
        $duplicate = $adapter->correlateCurrentSynthetic($request);

        self::assertSame(Repository::STORED_NEW, $first['storage_disposition']);
        self::assertSame(Repository::EXACT_DUPLICATE, $duplicate['storage_disposition']);
        self::assertSame('EXACT_SOURCE_CORRELATION', $first['condition']);
        self::assertTrue($first['correlation_usable']);
        self::assertSame($first['logical_record_identity'], $duplicate['logical_record_identity']);
        self::assertSame(1, $store->count());
        self::assertSame($this->request(), $request);
        $this->assertNonAuthority($first);
        $this->assertNonAuthority($duplicate);
    }

    public function test_missing_unknown_stale_and_cross_context_inputs_fail_closed(): void
    {
        $mutations = [];
        $request = $this->request();
        $request['consent_evidence'] = null;
        $mutations[] = $request;
        $request = $this->request();
        $request['consent_evidence']['source_condition'] = 'UNKNOWN';
        $request['consent_evidence']['currentness'] = null;
        $request['consent_evidence']['freshness'] = null;
        $mutations[] = $request;
        $request = $this->request();
        $request['consent_evidence']['source_condition'] = 'STALE';
        $request['consent_evidence']['currentness'] = false;
        $request['consent_evidence']['freshness'] = false;
        $mutations[] = $request;
        foreach (['connection_identity', 'participants', 'purpose'] as $field) {
            $request = $this->request();
            $request['consent'][$field] = match ($field) {
                'connection_identity' => 'other-connection',
                'participants' => ['participant-a', 'other-participant'],
                default => 'CONVERSATION_LIVE_SEND',
            };
            $mutations[] = $request;
        }
        $request = $this->request();
        $request['consent_evidence']['required_bindings']['authority_owner'] = 'OTHER_OWNER';
        $mutations[] = $request;

        foreach ($mutations as $input) {
            [$adapter] = $this->adapter();
            $result = $adapter->correlateCurrentSynthetic($input);
            self::assertFalse($result['correlation_usable']);
            $this->assertNonAuthority($result);
        }
    }

    public function test_both_sources_must_match_the_explicit_synthetic_protected_audience(): void
    {
        $invalid = [];
        $request = $this->request();
        unset($request['protected_audience']);
        $invalid[] = $request;
        $request = $this->request();
        $request['protected_audience'] = 7;
        $invalid[] = $request;
        $request = $this->request();
        $request['protected_audience'] = '';
        $invalid[] = $request;
        $request = $this->request();
        $request['connection_evidence']['required_bindings']['audience'] = 'OTHER_AUDIENCE';
        $invalid[] = $request;
        $request = $this->request();
        $request['consent_evidence']['required_bindings']['audience'] = 'OTHER_AUDIENCE';
        $invalid[] = $request;
        $request = $this->request();
        $request['connection_evidence']['required_bindings']['audience'] = 'CN_AUDIENCE';
        $request['consent_evidence']['required_bindings']['audience'] = 'MC_AUDIENCE';
        $invalid[] = $request;

        foreach ($invalid as $input) {
            [$adapter, $store] = $this->adapter();
            $result = $adapter->correlateCurrentSynthetic($input);
            self::assertFalse($result['correlation_usable']);
            self::assertSame(0, $store->count());
            $this->assertNonAuthority($result);
        }
    }

    public function test_changed_identity_equal_revision_and_incomparable_lineage_are_unusable(): void
    {
        foreach (['changed', 'equal', 'incomparable'] as $case) {
            [$adapter] = $this->adapter();
            self::assertSame(Repository::STORED_NEW, $adapter->correlateCurrentSynthetic($this->request())['storage_disposition']);
            $request = $this->request();
            if ($case === 'changed') {
                $request['consent_evidence']['state'] = 'MC_PENDING';
            } else {
                $request['consent_evidence']['evidence_identity'] = 'mc-event-other';
                if ($case === 'incomparable') {
                    $request['consent_evidence']['source_revision']['lineage'] = 'other-mc-lineage';
                }
            }
            $result = $adapter->correlateCurrentSynthetic($request);
            self::assertSame(match ($case) {
                'changed' => Repository::CHANGED_INPUT_REUSE_REJECTED,
                'equal' => Repository::CONFLICTING_EQUAL_REVISION_REJECTED,
                default => Repository::INCOMPARABLE_COEXISTS,
            }, $result['storage_disposition']);
            self::assertFalse($result['correlation_usable']);
            $this->assertNonAuthority($result);
        }
    }

    public function test_exact_dependency_invalidation_cannot_be_reopened_by_replay(): void
    {
        [$adapter] = $this->adapter();
        $request = $this->request();
        self::assertTrue($adapter->correlateCurrentSynthetic($request)['correlation_usable']);
        $wrong = $request + ['dependency_identity' => 'other', 'relation' => CommonAuthorityEvidenceContract::INVALIDATION_REVOCATION];
        self::assertSame('INVALIDATION_TARGET_NOT_BOUND', $adapter->invalidateCurrentSynthetic($wrong)['condition']);
        $invalidate = $request + [
            'dependency_identity' => 'mc-event',
            'relation' => CommonAuthorityEvidenceContract::INVALIDATION_REVOCATION,
        ];
        $result = $adapter->invalidateCurrentSynthetic($invalidate);
        self::assertSame('EXACT_DEPENDENCY_INVALIDATED', $result['condition']);
        self::assertFalse($adapter->correlateCurrentSynthetic($request)['correlation_usable']);
        $this->assertNonAuthority($result);
    }

    /** @return array{MessagingConsentPersistenceApplicationAdapter, SqliteInMemoryLogicalPersistenceAdapter} */
    private function adapter(): array
    {
        $store = new SqliteInMemoryLogicalPersistenceAdapter();
        return [new MessagingConsentPersistenceApplicationAdapter(
            new PersistenceBoundaryApplicationInterfaceIntegrationContract($store),
        ), $store];
    }

    /** @return array<string, mixed> */
    private function request(): array
    {
        $participants = ['participant-a', 'participant-b'];
        return [
            'protected_audience' => 'SYNTHETIC_AUDIENCE',
            'connection' => ['connection_identity' => 'connection-a', 'participants' => $participants],
            'connection_evidence' => $this->evidence('CN_ACTIVE', 'connection-a', 'connection-a', 'CN_SOURCE', 'CN_SCOPE', 'CN_USE', 'cn-lineage', 5, 'cn-event', $participants),
            'consent' => [
                'consent_identity' => 'consent-a', 'connection_identity' => 'connection-a',
                'participants' => $participants, 'requester' => 'participant-a',
                'recipient' => 'participant-b', 'purpose' => 'CONVERSATION_LIVE_READ',
            ],
            'consent_evidence' => $this->evidence('MC_ACTIVE', 'consent-a', 'connection-a', 'MC_SOURCE', 'MC_SCOPE', 'CONVERSATION_LIVE_READ', 'mc-lineage', 7, 'mc-event', $participants),
        ];
    }

    /** @param list<string> $participants @return array<string, mixed> */
    private function evidence(
        string $state, string $context, string $subject, string $owner, string $scope,
        string $purpose, string $lineage, int $value, string $event, array $participants,
    ): array {
        return [
            'evidence_identity' => $event,
            'required_bindings' => [
                'authority_owner' => $owner, 'authority_scope' => $scope,
                'actor' => $owner, 'actor_role' => 'SYNTHETIC_SOURCE',
                'subject' => $subject, 'participants' => $participants,
                'audience' => 'SYNTHETIC_AUDIENCE', 'purpose' => $purpose,
                'aggregate_context' => $context, 'lifecycle_identity' => $context,
                'terminal' => false,
            ],
            'source_revision' => [
                'authority_owner' => $owner, 'authority_scope' => $scope,
                'lineage' => $lineage, 'aggregate_context' => $context, 'value' => $value,
            ],
            'state' => $state, 'source_condition' => 'PRESENT',
            'currentness' => true, 'freshness' => true,
            'protected_binding_satisfied' => true,
        ];
    }

    /** @param array<string, mixed> $result */
    private function assertNonAuthority(array $result): void
    {
        foreach (['source_authority', 'permission', 'live_read_allowed', 'live_send_allowed', 'message_sent'] as $key) {
            self::assertFalse($result[$key]);
        }
    }
}
