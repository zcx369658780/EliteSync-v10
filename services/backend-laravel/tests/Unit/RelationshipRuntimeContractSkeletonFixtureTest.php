<?php

namespace Tests\Unit;

use Tests\TestCase;

class RelationshipRuntimeContractSkeletonFixtureTest extends TestCase
{
    private function fixture(): array
    {
        $path = base_path('tests/Fixtures/relationship_runtime/relationship_runtime_contract_skeleton.json');
        $this->assertFileExists($path);

        $raw = file_get_contents($path);
        $this->assertNotFalse($raw);

        $data = json_decode((string) $raw, true);
        $this->assertIsArray($data);

        return $data;
    }

    public function test_relationship_runtime_fixture_defines_l1_static_contract_states(): void
    {
        $fixture = $this->fixture();

        $this->assertSame('relationship_runtime_test_contract_v1', $fixture['contract_version'] ?? null);
        $this->assertSame('L1_TEST_ONLY_FIXTURE_SKELETON', $fixture['evidence_level'] ?? null);

        $states = (array) ($fixture['states'] ?? []);
        $this->assertNotEmpty($states);

        $stateNames = array_map(fn ($row) => (string) ($row['state'] ?? ''), $states);
        $this->assertSame([
            'not_started',
            'preparing',
            'waiting',
            'reveal_available',
            'revealed',
            'opener_prepared',
            'conversation_opened',
            'feedback_pending',
            'feedback_recorded_local',
            'feedback_recorded_remote_future',
            'next_round_pending',
            'no_candidate',
            'paused_or_unavailable',
            'auth_session_failure',
        ], $stateNames);

        foreach ($states as $idx => $row) {
            $this->assertIsArray($row, "state row {$idx} should be object");
            foreach ((array) ($fixture['required_state_fields'] ?? []) as $field) {
                $this->assertArrayHasKey($field, $row, "state row {$idx} missing {$field}");
            }
            $this->assertStringStartsWith('relationship.', (string) $row['fallback_copy_key']);
        }
    }

    public function test_relationship_runtime_fixture_keeps_write_side_capabilities_disabled(): void
    {
        $fixture = $this->fixture();

        foreach ((array) ($fixture['runtime_claims'] ?? []) as $claim => $enabled) {
            $this->assertFalse($enabled, "top-level runtime claim {$claim} must stay false in B3");
        }

        foreach ((array) ($fixture['states'] ?? []) as $row) {
            $state = (string) ($row['state'] ?? 'unknown');
            $capabilities = (array) ($row['capabilities'] ?? []);
            $claims = (array) ($row['runtime_claims'] ?? []);

            foreach ([
                'can_auto_send',
                'can_upload_media',
                'can_persist_feedback_remote',
                'can_push_notification',
            ] as $capability) {
                $this->assertArrayHasKey($capability, $capabilities, "state {$state} missing {$capability}");
                $this->assertFalse($capabilities[$capability], "state {$state} must not enable {$capability}");
            }

            foreach ($claims as $claim => $enabled) {
                $this->assertFalse($enabled, "state {$state} runtime claim {$claim} must stay false in B3");
            }
        }
    }

    public function test_relationship_runtime_fixture_documents_manual_send_and_local_feedback_boundaries(): void
    {
        $fixture = $this->fixture();
        $states = collect((array) ($fixture['states'] ?? []))->keyBy('state');

        $opener = (array) $states->get('opener_prepared');
        $suggestions = (array) ($opener['opener_suggestions'] ?? []);
        $this->assertNotEmpty($suggestions);
        $this->assertTrue((bool) ($suggestions[0]['manual_send_allowed'] ?? false));
        $this->assertFalse((bool) ($suggestions[0]['auto_send_allowed'] ?? true));

        $localFeedback = (array) $states->get('feedback_recorded_local');
        $this->assertTrue((bool) data_get($localFeedback, 'feedback.local_only'));
        $this->assertSame('not_authorized_for_remote', data_get($localFeedback, 'feedback.sync_state'));

        $remoteFuture = (array) $states->get('feedback_recorded_remote_future');
        $this->assertNull(data_get($remoteFuture, 'feedback.remote_record_id'));
        $this->assertSame('future_gate_not_active', data_get($remoteFuture, 'feedback.sync_state'));
    }
}
