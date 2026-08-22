<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\UserProfileShowcaseDraft;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ProfileShowcasePublicationApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_unauthenticated_publication_requests_are_rejected(): void
    {
        $this->getJson('/api/v1/profile/showcase/publication')->assertUnauthorized();
        $this->postJson('/api/v1/profile/showcase/publication', [
            'confirm_public_display' => true,
        ])->assertUnauthorized();
    }

    public function test_get_returns_not_published_for_owner_without_publication(): void
    {
        Sanctum::actingAs($this->user('13800001401'));

        $this->getJson('/api/v1/profile/showcase/publication')
            ->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('publication', null)
            ->assertJsonPath('copy_state.publication_status', 'not_published')
            ->assertJsonPath('copy_state.public_display_eligible', false)
            ->assertJsonPath('copy_state.matching_scoring_eligible', false);
    }

    public function test_post_requires_existing_private_draft(): void
    {
        Sanctum::actingAs($this->user('13800001402'));

        $this->postJson('/api/v1/profile/showcase/publication', [
            'confirm_public_display' => true,
        ])->assertStatus(422)
            ->assertJsonPath('ok', false)
            ->assertJsonPath('error.code', 'profile_showcase_publication_draft_missing');
    }

    public function test_post_rejects_non_approved_private_draft_states(): void
    {
        $statuses = [
            'not_submitted',
            'pending',
            'rejected',
            'needs_revision',
            'manual_review_required',
            'error',
        ];

        foreach ($statuses as $idx => $status) {
            $user = $this->user('1380000141' . $idx);
            Sanctum::actingAs($user);
            $this->draft($user, $status);

            $this->postJson('/api/v1/profile/showcase/publication', [
                'confirm_public_display' => true,
            ])->assertStatus(422)
                ->assertJsonPath('ok', false)
                ->assertJsonPath('error.code', 'profile_showcase_publication_requires_approved_draft');
        }

        $this->assertDatabaseCount('user_profile_showcase_publications', 0);
        $this->assertDatabaseCount('user_profile_showcase_publication_audits', 0);
    }

    public function test_post_requires_explicit_owner_confirmation(): void
    {
        $user = $this->user('13800001403');
        Sanctum::actingAs($user);
        $this->draft($user, 'approved');

        $this->postJson('/api/v1/profile/showcase/publication')
            ->assertStatus(422)
            ->assertJsonPath('error.code', 'profile_showcase_publication_requires_owner_confirmation');

        $this->postJson('/api/v1/profile/showcase/publication', [
            'confirm_public_display' => false,
        ])->assertStatus(422)
            ->assertJsonPath('error.code', 'profile_showcase_publication_requires_owner_confirmation');

        $this->assertDatabaseCount('user_profile_showcase_publications', 0);
    }

    public function test_owner_can_publish_approved_private_draft_with_minimized_response_and_audit(): void
    {
        $user = $this->user('13800001404');
        Sanctum::actingAs($user);
        $draft = $this->draft($user, 'approved');

        $response = $this->postJson('/api/v1/profile/showcase/publication', [
            'confirm_public_display' => true,
        ])->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('publication.publication_status', 'published')
            ->assertJsonPath('publication.source_draft_id', $draft->id)
            ->assertJsonPath('publication.moderation_status', 'approved')
            ->assertJsonPath('publication.public_display_eligible', true)
            ->assertJsonPath('publication.matching_scoring_eligible', false)
            ->assertJsonPath('publication.public_fields.self_intro', '想公开展示的一段介绍。')
            ->assertJsonPath('publication.public_fields.interest_tags.0', '阅读')
            ->assertJsonPath('copy_state.publication_status', 'published')
            ->assertJsonPath('copy_state.public_display_eligible', true)
            ->assertJsonPath('copy_state.matching_scoring_eligible', false);

        $payload = (array) $response->json('publication');
        $this->assertArrayNotHasKey('audit_note', $payload);
        $this->assertArrayNotHasKey('reviewer_id', $payload);
        $this->assertArrayNotHasKey('reviewer_identity', $payload);
        $this->assertArrayNotHasKey('provider', $payload);
        $this->assertArrayNotHasKey('internal_command', $payload);
        $this->assertArrayNotHasKey('generated_tags', $payload);
        $this->assertArrayNotHasKey('questionnaire', $payload);
        $this->assertArrayNotHasKey('astrology_payload', $payload);
        $this->assertArrayNotHasKey('private_matching_payload', $payload);

        $this->assertDatabaseHas('user_profile_showcase_publications', [
            'user_id' => $user->id,
            'source_draft_id' => $draft->id,
            'source_moderation_status' => 'approved',
            'public_display_eligible' => true,
            'matching_scoring_eligible' => false,
        ]);

        $this->assertDatabaseHas('user_profile_showcase_publication_audits', [
            'user_id' => $user->id,
            'source_draft_id' => $draft->id,
            'actor_type' => 'draft_owner',
            'actor_id' => (string) $user->id,
            'action' => 'owner_publish_confirmed',
            'previous_publication_status' => 'not_published',
            'new_publication_status' => 'published',
        ]);

        $this->assertDatabaseCount('dating_matches', 0);
    }

    public function test_repeated_publish_is_idempotent_for_same_source_snapshot(): void
    {
        $user = $this->user('13800001405');
        Sanctum::actingAs($user);
        $this->draft($user, 'approved');

        $first = $this->postJson('/api/v1/profile/showcase/publication', [
            'confirm_public_display' => true,
        ])->assertOk();

        $second = $this->postJson('/api/v1/profile/showcase/publication', [
            'confirm_public_display' => true,
        ])->assertOk();

        $this->assertSame($first->json('publication.id'), $second->json('publication.id'));
        $this->assertDatabaseCount('user_profile_showcase_publications', 1);
        $this->assertDatabaseCount('user_profile_showcase_publication_audits', 1);
    }

    public function test_publication_is_owner_isolated(): void
    {
        $userA = $this->user('13800001406');
        $userB = $this->user('13800001407');

        Sanctum::actingAs($userA);
        $this->draft($userA, 'approved');
        $this->postJson('/api/v1/profile/showcase/publication', [
            'confirm_public_display' => true,
        ])->assertOk();

        Sanctum::actingAs($userB);
        $this->getJson('/api/v1/profile/showcase/publication')
            ->assertOk()
            ->assertJsonPath('publication', null)
            ->assertJsonPath('copy_state.publication_status', 'not_published');

        $this->postJson('/api/v1/profile/showcase/publication', [
            'confirm_public_display' => true,
        ])->assertStatus(422)
            ->assertJsonPath('error.code', 'profile_showcase_publication_draft_missing');
    }

    private function user(string $phone): User
    {
        return User::factory()->create([
            'phone' => $phone,
        ]);
    }

    private function draft(User $user, string $moderationStatus): UserProfileShowcaseDraft
    {
        return UserProfileShowcaseDraft::query()->create([
            'user_id' => $user->id,
            'self_intro' => '想公开展示的一段介绍。',
            'interest_tags' => ['阅读', '咖啡'],
            'lifestyle_tags' => ['周末慢生活'],
            'opener_note' => '可以从一本书聊起。',
            'visibility_intent' => 'private_draft',
            'draft_status' => 'draft',
            'moderation_status' => $moderationStatus,
            'source_type' => 'user_confirmed',
            'public_display_eligible' => false,
            'matching_scoring_eligible' => false,
        ]);
    }
}
