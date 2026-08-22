<?php

namespace Tests\Unit;

use Tests\TestCase;

class ProfileShowcasePublicDisplayPublicationContractSkeletonTest extends TestCase
{
    private function fixture(): array
    {
        $path = base_path('tests/Fixtures/profile_showcase_publication/public_display_publication_contract_skeleton.json');
        $this->assertFileExists($path);

        $raw = file_get_contents($path);
        $this->assertNotFalse($raw);

        $data = json_decode((string) $raw, true);
        $this->assertIsArray($data);

        return $data;
    }

    public function test_contract_fixture_defines_publication_boundary_shape(): void
    {
        $fixture = $this->fixture();

        $this->assertSame('profile_showcase_public_display_publication_test_contract_v1', $fixture['contract_version'] ?? null);
        $this->assertSame('L1_TEST_ONLY_FIXTURE_SKELETON', $fixture['evidence_level'] ?? null);
        $this->assertSame('test_only_static_contract_no_runtime_behavior', $fixture['fixture_scope'] ?? null);
        $this->assertSame('private_personal_showcase_draft_to_owner_authorized_public_display', $fixture['review_surface'] ?? null);

        $this->assertTrue((bool) ($fixture['auth_required'] ?? false));
        $this->assertTrue((bool) ($fixture['own_user_only'] ?? false));
        $this->assertTrue((bool) ($fixture['owner_confirmation_required'] ?? false));
        $this->assertSame('approved', $fixture['source_moderation_status_required'] ?? null);

        $this->assertSame('GET/POST /api/v1/profile/showcase/publication', $fixture['publication_route_family_candidate'] ?? null);
        $this->assertContains('DELETE /api/v1/profile/showcase/publication', (array) ($fixture['deferred_route_actions'] ?? []));
        $this->assertContains('unpublish_or_hide', (array) ($fixture['deferred_route_actions'] ?? []));
    }

    public function test_only_approved_owner_confirmed_private_draft_is_publish_eligible(): void
    {
        $fixture = $this->fixture();
        $cases = [];
        foreach ((array) ($fixture['cases'] ?? []) as $case) {
            $cases[(string) ($case['case_id'] ?? '')] = (array) $case;
        }

        $eligible = array_values(array_filter($cases, static fn ($case): bool => (bool) ($case['publish_eligible'] ?? false)));
        $this->assertCount(3, $eligible);

        foreach ($eligible as $case) {
            $this->assertSame('approved', $case['source_moderation_status'] ?? null);
            $this->assertTrue((bool) ($case['owner_confirmation_present'] ?? false));
            $this->assertTrue((bool) ($case['auth_required'] ?? false));
            $this->assertTrue((bool) ($case['own_user_only'] ?? false));
            $this->assertSame('published', $case['expected_publication_status'] ?? null);
            $this->assertTrue((bool) ($case['public_display_eligible'] ?? false));
            $this->assertFalse((bool) ($case['matching_scoring_eligible'] ?? true));
        }

        $missingConfirmation = $cases['missing_owner_confirmation_rejected'] ?? [];
        $this->assertFalse((bool) ($missingConfirmation['publish_eligible'] ?? true));
        $this->assertSame('profile_showcase_publication_requires_owner_confirmation', $missingConfirmation['expected_error_code'] ?? null);
        $this->assertFalse((bool) ($missingConfirmation['public_display_eligible'] ?? true));
        $this->assertFalse((bool) ($missingConfirmation['matching_scoring_eligible'] ?? true));
    }

    public function test_non_approved_states_remain_not_publish_eligible(): void
    {
        $fixture = $this->fixture();
        $nonApprovedStates = [
            'pending',
            'rejected',
            'needs_revision',
            'manual_review_required',
            'error',
        ];

        foreach ((array) ($fixture['cases'] ?? []) as $case) {
            if (! in_array((string) ($case['source_moderation_status'] ?? ''), $nonApprovedStates, true)) {
                continue;
            }

            $caseId = (string) ($case['case_id'] ?? 'unknown');
            $this->assertFalse((bool) ($case['publish_eligible'] ?? true), "{$caseId} must not be publish eligible");
            $this->assertSame('profile_showcase_publication_requires_approved_draft', $case['expected_error_code'] ?? null);
            $this->assertFalse((bool) ($case['public_display_eligible'] ?? true), "{$caseId} must not enable public display");
            $this->assertFalse((bool) ($case['matching_scoring_eligible'] ?? true), "{$caseId} must not enable matching/scoring");
        }
    }

    public function test_published_response_blocks_internal_and_unrelated_payloads(): void
    {
        $fixture = $this->fixture();
        $cases = [];
        foreach ((array) ($fixture['cases'] ?? []) as $case) {
            $cases[(string) ($case['case_id'] ?? '')] = (array) $case;
        }

        $metadataCase = $cases['published_response_no_internal_review_metadata'] ?? [];
        $this->assertFalse((bool) ($metadataCase['internal_metadata_exposed'] ?? true));

        $forbiddenPayloads = (array) ($metadataCase['forbidden_payloads'] ?? []);
        foreach ([
            'audit_notes',
            'reviewer_identity',
            'provider_internals',
            'internal_command_details',
            'generated_tags',
            'questionnaire',
            'astrology_payload',
            'private_matching_payload',
        ] as $payload) {
            $this->assertContains($payload, $forbiddenPayloads);
        }

        foreach ((array) ($fixture['runtime_claims'] ?? []) as $claim => $enabled) {
            $this->assertFalse($enabled, "runtime claim {$claim} must stay false");
        }

        $this->assertContains('route_registration', (array) ($fixture['forbidden_runtime_actions'] ?? []));
        $this->assertContains('recommendation_or_scoring', (array) ($fixture['forbidden_runtime_actions'] ?? []));
        $this->assertContains('endpoint_smoke', (array) ($fixture['forbidden_runtime_actions'] ?? []));
    }
}
