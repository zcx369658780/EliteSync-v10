<?php

namespace Tests\Unit;

use Tests\TestCase;

class ProfileShowcaseManualReviewContractSkeletonTest extends TestCase
{
    private function fixture(): array
    {
        $path = base_path('tests/Fixtures/profile_showcase_moderation/manual_review_contract_skeleton.json');
        $this->assertFileExists($path);

        $raw = file_get_contents($path);
        $this->assertNotFalse($raw);

        $data = json_decode((string) $raw, true);
        $this->assertIsArray($data);

        return $data;
    }

    public function test_contract_fixture_defines_test_only_actor_and_audit_shape(): void
    {
        $fixture = $this->fixture();

        $this->assertSame('profile_showcase_manual_review_test_contract_v1', $fixture['contract_version'] ?? null);
        $this->assertSame('L1_TEST_ONLY_FIXTURE_SKELETON', $fixture['evidence_level'] ?? null);
        $this->assertSame('test_only_static_contract_no_runtime_behavior', $fixture['fixture_scope'] ?? null);
        $this->assertSame('private_personal_showcase_draft', $fixture['review_surface'] ?? null);

        $this->assertSame([
            'self_intro',
            'interest_tags',
            'lifestyle_tags',
            'opener_note',
        ], $fixture['moderated_fields'] ?? []);

        $this->assertContains('internal_manual_reviewer', (array) ($fixture['allowed_actor_types'] ?? []));
        $this->assertContains('strict_test_harness', (array) ($fixture['allowed_actor_types'] ?? []));
        $this->assertContains('draft_owner', (array) ($fixture['forbidden_actor_types'] ?? []));

        $this->assertSame([
            'draft_id',
            'user_id',
            'actor_type',
            'actor_id',
            'previous_moderation_status',
            'new_moderation_status',
            'reason_code',
            'note',
            'reviewed_fields_hash',
            'created_at',
        ], $fixture['required_audit_fields'] ?? []);
    }

    public function test_contract_forbids_owner_self_review_and_runtime_power(): void
    {
        $fixture = $this->fixture();

        foreach ((array) ($fixture['runtime_claims'] ?? []) as $claim => $enabled) {
            $this->assertFalse($enabled, "runtime claim {$claim} must stay false");
        }

        $forbidden = (array) ($fixture['forbidden_transitions'] ?? []);
        $ownerSelfReview = array_values(array_filter($forbidden, static function ($row): bool {
            return ($row['from'] ?? null) === 'pending'
                && ($row['to'] ?? null) === 'approved'
                && ($row['actor_type'] ?? null) === 'draft_owner';
        }));

        $this->assertCount(1, $ownerSelfReview);
        $this->assertSame('draft_owner_self_review_forbidden', $ownerSelfReview[0]['reason'] ?? null);

        $this->assertContains('owner_self_review', (array) ($fixture['forbidden_runtime_actions'] ?? []));
        $this->assertContains('product_route', (array) ($fixture['forbidden_runtime_actions'] ?? []));
        $this->assertContains('database_migration', (array) ($fixture['forbidden_runtime_actions'] ?? []));
        $this->assertContains('provider_call', (array) ($fixture['forbidden_runtime_actions'] ?? []));
    }

    public function test_allowed_transitions_remain_private_and_audited(): void
    {
        $fixture = $this->fixture();
        $allowed = (array) ($fixture['allowed_transitions'] ?? []);

        $this->assertCount(4, $allowed);

        foreach ($allowed as $idx => $transition) {
            $this->assertSame('pending', $transition['from'] ?? null, "transition {$idx} should start from pending");
            $this->assertContains((string) ($transition['actor_type'] ?? ''), (array) ($fixture['allowed_actor_types'] ?? []));
            $this->assertTrue((bool) ($transition['audit_required'] ?? false), "transition {$idx} must require audit");
            $this->assertFalse((bool) ($transition['public_display_eligible'] ?? true), "transition {$idx} must not enable public display");
            $this->assertFalse((bool) ($transition['matching_scoring_eligible'] ?? true), "transition {$idx} must not enable matching/scoring");
        }

        $reasonRequiredTargets = ['rejected', 'needs_revision', 'manual_review_required'];
        foreach ($allowed as $transition) {
            if (in_array((string) ($transition['to'] ?? ''), $reasonRequiredTargets, true)) {
                $this->assertTrue((bool) ($transition['reason_code_required'] ?? false));
            }
        }
    }

    public function test_audit_minimization_blocks_private_and_unrelated_payloads(): void
    {
        $fixture = $this->fixture();
        $minimization = (array) ($fixture['audit_minimization'] ?? []);

        $this->assertFalse((bool) ($minimization['raw_content_duplication_allowed'] ?? true));
        $this->assertFalse((bool) ($minimization['raw_provider_response_allowed'] ?? true));
        $this->assertFalse((bool) ($minimization['secrets_or_env_allowed'] ?? true));
        $this->assertFalse((bool) ($minimization['unrelated_profile_fields_allowed'] ?? true));
        $this->assertFalse((bool) ($minimization['matching_payload_allowed'] ?? true));
        $this->assertFalse((bool) ($minimization['astrology_payload_allowed'] ?? true));
        $this->assertLessThanOrEqual(240, (int) ($minimization['note_max_length'] ?? 999));
    }
}
