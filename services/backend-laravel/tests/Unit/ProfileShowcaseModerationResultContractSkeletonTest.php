<?php

namespace Tests\Unit;

use Tests\TestCase;

class ProfileShowcaseModerationResultContractSkeletonTest extends TestCase
{
    private function fixture(): array
    {
        $path = base_path('tests/Fixtures/profile_showcase_moderation/moderation_result_contract_skeleton.json');
        $this->assertFileExists($path);

        $raw = file_get_contents($path);
        $this->assertNotFalse($raw);

        $data = json_decode((string) $raw, true);
        $this->assertIsArray($data);

        return $data;
    }

    public function test_contract_fixture_defines_expected_decisions_and_fields(): void
    {
        $fixture = $this->fixture();

        $this->assertSame('profile_showcase_moderation_result_test_contract_v1', $fixture['contract_version'] ?? null);
        $this->assertSame('L1_TEST_ONLY_FIXTURE_SKELETON', $fixture['evidence_level'] ?? null);
        $this->assertSame('test_only_static_contract_no_runtime_behavior', $fixture['fixture_scope'] ?? null);

        $this->assertSame([
            'self_intro',
            'interest_tags',
            'lifestyle_tags',
            'opener_note',
        ], $fixture['moderated_fields'] ?? []);

        $this->assertSame([
            'approved',
            'rejected',
            'needs_revision',
            'manual_review_required',
            'error',
        ], $fixture['normalized_decisions'] ?? []);

        $results = (array) ($fixture['results'] ?? []);
        $this->assertCount(5, $results);

        $decisions = array_map(fn ($row) => (string) ($row['decision'] ?? ''), $results);
        $this->assertSame($fixture['normalized_decisions'], $decisions);

        foreach ($results as $idx => $row) {
            foreach ((array) ($fixture['required_result_fields'] ?? []) as $field) {
                $this->assertArrayHasKey($field, $row, "result row {$idx} missing {$field}");
            }
            $this->assertStringStartsWith('profile_showcase.review.', (string) $row['user_copy_key']);
        }
    }

    public function test_contract_fixture_keeps_public_display_and_matching_disabled(): void
    {
        $fixture = $this->fixture();

        foreach ((array) ($fixture['runtime_claims'] ?? []) as $claim => $enabled) {
            $this->assertFalse($enabled, "top-level runtime claim {$claim} must stay false");
        }

        foreach ((array) ($fixture['results'] ?? []) as $row) {
            $decision = (string) ($row['decision'] ?? 'unknown');

            $this->assertFalse((bool) ($row['public_display_eligible'] ?? true), "{$decision} must not enable public display");
            $this->assertFalse((bool) ($row['matching_scoring_eligible'] ?? true), "{$decision} must not enable matching/scoring");

            foreach ((array) ($row['runtime_claims'] ?? []) as $claim => $enabled) {
                $this->assertFalse($enabled, "decision {$decision} runtime claim {$claim} must stay false");
            }
        }
    }

    public function test_contract_fixture_documents_fail_closed_error_and_manual_review_states(): void
    {
        $fixture = $this->fixture();
        $results = [];
        foreach ((array) ($fixture['results'] ?? []) as $row) {
            $results[(string) ($row['decision'] ?? '')] = (array) $row;
        }

        $manual = $results['manual_review_required'] ?? [];
        $this->assertSame('pending', $manual['moderation_status'] ?? null);
        $this->assertContains('wait_for_review', (array) ($manual['allowed_next_actions'] ?? []));
        $this->assertContains('edit_resets_to_not_submitted', (array) ($manual['allowed_next_actions'] ?? []));

        $error = $results['error'] ?? [];
        $this->assertSame('pending', $error['moderation_status'] ?? null);
        $this->assertContains('retry_later', (array) ($error['allowed_next_actions'] ?? []));
        $this->assertFalse((bool) ($error['public_display_eligible'] ?? true));
        $this->assertFalse((bool) ($error['matching_scoring_eligible'] ?? true));

        $approved = $results['approved'] ?? [];
        $this->assertContains('edit_resets_to_not_submitted', (array) ($approved['allowed_next_actions'] ?? []));
        $this->assertFalse((bool) ($approved['public_display_eligible'] ?? true));
        $this->assertFalse((bool) ($approved['matching_scoring_eligible'] ?? true));
    }
}
