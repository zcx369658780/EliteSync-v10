<?php

namespace Tests\Unit;

use Tests\TestCase;

class RelationshipRuntimeLocalFakePayloadConsumerTest extends TestCase
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

    private function localConsumerRows(array $fixture): array
    {
        return array_map(function (array $state): array {
            $capabilities = (array) ($state['capabilities'] ?? []);
            $claims = (array) ($state['runtime_claims'] ?? []);

            return [
                'id' => (string) ($state['id'] ?? ''),
                'state' => (string) ($state['state'] ?? ''),
                'round_id' => (string) ($state['round_id'] ?? ''),
                'fallback_copy_key' => (string) ($state['fallback_copy_key'] ?? ''),
                'can_reveal' => (bool) ($capabilities['can_reveal'] ?? false),
                'can_open_conversation' => (bool) ($capabilities['can_open_conversation'] ?? false),
                'manual_send_only' => $this->manualSendOnly($state),
                'local_feedback_only' => $this->localFeedbackOnly($state),
                'candidate_summary_present' => array_key_exists('candidate_summary', $state) && is_array($state['candidate_summary']),
                'candidate_present' => array_key_exists('candidate', $state) && is_array($state['candidate']),
                'candidate_source_labels' => (array) data_get($state, 'candidate.source_labels', []),
                'explanation_blocks_present' => ! empty($state['explanation_blocks']) && is_array($state['explanation_blocks']),
                'read_model_only' => (bool) data_get($state, 'conversation.read_model_only', false),
                'can_send' => (bool) data_get($state, 'conversation.can_send', false),
                'runtime_write_claimed' => in_array(true, array_values($claims), true),
                'forbidden_capability_enabled' => $this->hasForbiddenCapability($capabilities),
                'reason_code' => $state['reason_code'] ?? null,
            ];
        }, (array) ($fixture['states'] ?? []));
    }

    private function manualSendOnly(array $state): bool
    {
        $suggestions = (array) ($state['opener_suggestions'] ?? []);

        foreach ($suggestions as $suggestion) {
            $suggestion = (array) $suggestion;
            if (
                ($suggestion['manual_send_allowed'] ?? false) === true
                && ($suggestion['auto_send_allowed'] ?? true) === false
            ) {
                return true;
            }
        }

        return false;
    }

    private function localFeedbackOnly(array $state): bool
    {
        $feedback = (array) ($state['feedback'] ?? []);

        return ($feedback['local_only'] ?? false) === true
            || (
                ($feedback['can_record_local'] ?? false) === true
                && ($feedback['can_record_remote'] ?? true) === false
            );
    }

    private function hasForbiddenCapability(array $capabilities): bool
    {
        foreach ([
            'can_auto_send',
            'can_upload_media',
            'can_persist_feedback_remote',
            'can_push_notification',
        ] as $field) {
            if (($capabilities[$field] ?? false) === true) {
                return true;
            }
        }

        return false;
    }

    public function test_local_fake_payload_consumer_projects_all_contract_states(): void
    {
        $rows = $this->localConsumerRows($this->fixture());

        $this->assertCount(14, $rows);
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
        ], array_column($rows, 'state'));

        foreach ($rows as $row) {
            $this->assertNotSame('', $row['id']);
            $this->assertNotSame('', $row['round_id']);
            $this->assertStringStartsWith('relationship.', $row['fallback_copy_key']);
            $this->assertFalse($row['runtime_write_claimed'], "state {$row['state']} must stay read-only");
            $this->assertFalse($row['forbidden_capability_enabled'], "state {$row['state']} enabled a forbidden capability");
        }
    }

    public function test_local_fake_payload_consumer_preserves_manual_send_and_read_model_boundaries(): void
    {
        $rows = collect($this->localConsumerRows($this->fixture()))->keyBy('state');

        $this->assertTrue($rows['reveal_available']['can_reveal']);
        $this->assertTrue($rows['reveal_available']['candidate_summary_present']);
        $this->assertFalse($rows['reveal_available']['candidate_present']);

        $this->assertTrue($rows['revealed']['candidate_present']);
        $this->assertTrue($rows['revealed']['explanation_blocks_present']);
        $this->assertContains('test_only', $rows['revealed']['candidate_source_labels']);
        $this->assertContains('not_runtime_evidence', $rows['revealed']['candidate_source_labels']);

        $this->assertTrue($rows['opener_prepared']['manual_send_only']);
        $this->assertTrue($rows['opener_prepared']['can_open_conversation']);
        $this->assertFalse($rows['opener_prepared']['runtime_write_claimed']);

        $this->assertTrue($rows['conversation_opened']['read_model_only']);
        $this->assertTrue($rows['conversation_opened']['can_open_conversation']);
        $this->assertFalse($rows['conversation_opened']['can_send']);
        $this->assertFalse($rows['conversation_opened']['manual_send_only']);
    }

    public function test_local_fake_payload_consumer_keeps_fallback_and_future_write_states_non_runtime(): void
    {
        $fixture = $this->fixture();
        $rows = collect($this->localConsumerRows($fixture))->keyBy('state');

        $this->assertTrue($rows['feedback_pending']['local_feedback_only']);
        $this->assertTrue($rows['feedback_recorded_local']['local_feedback_only']);
        $this->assertFalse($rows['feedback_recorded_remote_future']['runtime_write_claimed']);

        $this->assertFalse($rows['no_candidate']['candidate_present']);
        $this->assertSame('no_safe_candidate', $rows['no_candidate']['reason_code']);
        $this->assertSame('service_unavailable', $rows['paused_or_unavailable']['reason_code']);
        $this->assertSame('session_required', $rows['auth_session_failure']['reason_code']);

        $placeholders = (array) ($fixture['future_write_contract_placeholders'] ?? []);
        $mediaFuture = (array) ($placeholders['media_upload_future'] ?? []);
        $notificationPlaceholder = (array) ($placeholders['notification_return_placeholder'] ?? []);

        $this->assertFalse((bool) ($mediaFuture['runtime_write_allowed'] ?? true));
        $this->assertFalse((bool) ($notificationPlaceholder['read_state_write_allowed'] ?? true));
        $this->assertFalse((bool) ($notificationPlaceholder['push_delivery_claimed'] ?? true));
    }
}
