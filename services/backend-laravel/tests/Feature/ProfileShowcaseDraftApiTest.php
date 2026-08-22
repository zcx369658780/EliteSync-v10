<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\UserProfileShowcaseDraft;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ProfileShowcaseDraftApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_unauthenticated_requests_are_rejected(): void
    {
        $this->getJson('/api/v1/profile/showcase/draft')->assertUnauthorized();
        $this->putJson('/api/v1/profile/showcase/draft', [])->assertUnauthorized();
        $this->postJson('/api/v1/profile/showcase/draft/submit-review', [])->assertUnauthorized();
        $this->deleteJson('/api/v1/profile/showcase/draft')->assertUnauthorized();
    }

    public function test_authenticated_user_gets_empty_draft_safely(): void
    {
        Sanctum::actingAs($this->user('13800001201'));

        $this->getJson('/api/v1/profile/showcase/draft')
            ->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('draft', null)
            ->assertJsonPath('copy_state.public_display_eligible', false)
            ->assertJsonPath('copy_state.matching_scoring_eligible', false);
    }

    public function test_authenticated_user_can_create_and_read_private_draft(): void
    {
        $user = $this->user('13800001202');
        Sanctum::actingAs($user);

        $this->putJson('/api/v1/profile/showcase/draft', [
            'self_intro' => '  喜欢慢节奏聊天，也重视边界感。  ',
            'interest_tags' => ['咖啡', '散步'],
            'lifestyle_tags' => ['周末慢生活'],
            'opener_note' => '可以从最近读到的一本书聊起。',
        ])->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('draft.self_intro', '喜欢慢节奏聊天，也重视边界感。')
            ->assertJsonPath('draft.interest_tags.0', '咖啡')
            ->assertJsonPath('draft.lifestyle_tags.0', '周末慢生活')
            ->assertJsonPath('draft.opener_note', '可以从最近读到的一本书聊起。')
            ->assertJsonPath('draft.visibility_intent', 'private_draft')
            ->assertJsonPath('draft.draft_status', 'draft')
            ->assertJsonPath('draft.moderation_status', 'not_submitted')
            ->assertJsonPath('draft.source_type', 'user_confirmed')
            ->assertJsonPath('draft.public_display_eligible', false)
            ->assertJsonPath('draft.matching_scoring_eligible', false)
            ->assertJsonPath('copy_state.save_label', 'saved_private_draft');

        $this->assertDatabaseHas('user_profile_showcase_drafts', [
            'user_id' => $user->id,
            'self_intro' => '喜欢慢节奏聊天，也重视边界感。',
            'visibility_intent' => 'private_draft',
            'draft_status' => 'draft',
            'moderation_status' => 'not_submitted',
            'source_type' => 'user_confirmed',
            'public_display_eligible' => false,
            'matching_scoring_eligible' => false,
        ]);

        $this->getJson('/api/v1/profile/showcase/draft')
            ->assertOk()
            ->assertJsonPath('draft.self_intro', '喜欢慢节奏聊天，也重视边界感。')
            ->assertJsonPath('draft.public_display_eligible', false)
            ->assertJsonPath('draft.matching_scoring_eligible', false);
    }

    public function test_put_replaces_existing_draft_for_same_user(): void
    {
        $user = $this->user('13800001203');
        Sanctum::actingAs($user);

        $this->putJson('/api/v1/profile/showcase/draft', [
            'self_intro' => '第一版',
            'interest_tags' => ['咖啡'],
        ])->assertOk();

        $this->putJson('/api/v1/profile/showcase/draft', [
            'self_intro' => '第二版',
            'interest_tags' => ['电影', '散步'],
            'lifestyle_tags' => [],
            'opener_note' => '',
        ])->assertOk()
            ->assertJsonPath('draft.self_intro', '第二版')
            ->assertJsonPath('draft.interest_tags.0', '电影')
            ->assertJsonPath('draft.interest_tags.1', '散步')
            ->assertJsonPath('draft.opener_note', null);

        $this->assertSame(1, UserProfileShowcaseDraft::query()->where('user_id', $user->id)->count());
    }

    public function test_delete_clears_draft_idempotently(): void
    {
        $user = $this->user('13800001204');
        Sanctum::actingAs($user);

        $this->putJson('/api/v1/profile/showcase/draft', [
            'self_intro' => '待清空',
        ])->assertOk();

        $this->deleteJson('/api/v1/profile/showcase/draft')
            ->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('draft', null)
            ->assertJsonPath('copy_state.save_label', 'cleared_private_draft');

        $this->deleteJson('/api/v1/profile/showcase/draft')->assertOk();
        $this->getJson('/api/v1/profile/showcase/draft')
            ->assertOk()
            ->assertJsonPath('draft', null);

        $this->assertDatabaseHas('user_profile_showcase_drafts', [
            'user_id' => $user->id,
            'self_intro' => null,
            'draft_status' => 'cleared',
            'moderation_status' => 'not_submitted',
            'public_display_eligible' => false,
            'matching_scoring_eligible' => false,
        ]);
    }

    public function test_user_cannot_access_another_users_draft(): void
    {
        $userA = $this->user('13800001205');
        $userB = $this->user('13800001206');

        Sanctum::actingAs($userA);
        $this->putJson('/api/v1/profile/showcase/draft', [
            'self_intro' => '用户A草稿',
        ])->assertOk();

        Sanctum::actingAs($userB);
        $this->getJson('/api/v1/profile/showcase/draft')
            ->assertOk()
            ->assertJsonPath('draft', null);

        $this->deleteJson('/api/v1/profile/showcase/draft')->assertOk();

        Sanctum::actingAs($userA);
        $this->getJson('/api/v1/profile/showcase/draft')
            ->assertOk()
            ->assertJsonPath('draft.self_intro', '用户A草稿');
    }

    public function test_validation_rejects_oversized_and_invalid_fields(): void
    {
        Sanctum::actingAs($this->user('13800001207'));

        $response = $this->putJson('/api/v1/profile/showcase/draft', [
            'self_intro' => str_repeat('a', 501),
            'interest_tags' => array_fill(0, 11, 'tag'),
            'lifestyle_tags' => ['ok', str_repeat('b', 25)],
            'opener_note' => str_repeat('c', 281),
        ])->assertStatus(422)
            ->assertJsonPath('ok', false)
            ->assertJsonPath('error.code', 'validation_error');

        $details = (array) $response->json('error.details');
        $this->assertArrayHasKey('self_intro', $details);
        $this->assertArrayHasKey('interest_tags', $details);
        $this->assertArrayHasKey('lifestyle_tags.1', $details);
        $this->assertArrayHasKey('opener_note', $details);
    }

    public function test_client_cannot_override_safety_source_or_matching_defaults(): void
    {
        Sanctum::actingAs($this->user('13800001208'));

        $response = $this->putJson('/api/v1/profile/showcase/draft', [
            'self_intro' => '安全默认值尝试',
            'source' => ['type' => 'questionnaire_answer'],
            'visibility' => 'public',
            'visibility_intent' => 'public',
            'draft_status' => 'published',
            'moderation_status' => 'approved',
            'source_type' => 'generated_suggestion',
            'public_display_eligible' => true,
            'matching_scoring_eligible' => true,
            'copy_state' => ['save_label' => 'safety_passed'],
        ])->assertStatus(422)
            ->assertJsonPath('ok', false)
            ->assertJsonPath('error.code', 'validation_error');

        $details = (array) $response->json('error.details');
        $this->assertArrayHasKey('source', $details);
        $this->assertArrayHasKey('visibility', $details);
        $this->assertArrayHasKey('visibility_intent', $details);
        $this->assertArrayHasKey('draft_status', $details);
        $this->assertArrayHasKey('moderation_status', $details);
        $this->assertArrayHasKey('source_type', $details);
        $this->assertArrayHasKey('public_display_eligible', $details);
        $this->assertArrayHasKey('matching_scoring_eligible', $details);
        $this->assertArrayHasKey('copy_state', $details);

        $this->assertDatabaseCount('user_profile_showcase_drafts', 0);
    }

    public function test_save_has_no_basic_profile_astro_or_matching_side_effects(): void
    {
        $user = $this->user('13800001209');
        $snapshot = $user->only(['name', 'birthday', 'gender', 'city', 'relationship_goal']);

        Sanctum::actingAs($user);
        $this->putJson('/api/v1/profile/showcase/draft', [
            'self_intro' => '仅私有草稿',
            'interest_tags' => ['阅读'],
        ])->assertOk()
            ->assertJsonPath('draft.public_display_eligible', false)
            ->assertJsonPath('draft.matching_scoring_eligible', false)
            ->assertJsonPath('draft.moderation_status', 'not_submitted')
            ->assertJsonPath('draft.visibility_intent', 'private_draft');

        $user->refresh();
        $this->assertSame($snapshot['name'], $user->name);
        $this->assertSame(optional($snapshot['birthday'])->format('Y-m-d'), optional($user->birthday)->format('Y-m-d'));
        $this->assertSame($snapshot['gender'], $user->gender);
        $this->assertSame($snapshot['city'], $user->city);
        $this->assertSame($snapshot['relationship_goal'], $user->relationship_goal);
        $this->assertDatabaseCount('user_astro_profiles', 0);
        $this->assertDatabaseCount('dating_matches', 0);
    }

    public function test_submit_for_review_requires_existing_private_draft(): void
    {
        $user = $this->user('13800001210');
        Sanctum::actingAs($user);

        $this->postJson('/api/v1/profile/showcase/draft/submit-review')
            ->assertStatus(422)
            ->assertJsonPath('ok', false)
            ->assertJsonPath('error.code', 'private_draft_required');

        $this->assertDatabaseCount('user_profile_showcase_drafts', 0);
    }

    public function test_submit_for_review_marks_private_draft_pending_without_public_or_scoring_eligibility(): void
    {
        $user = $this->user('13800001211');
        $snapshot = $user->only(['name', 'birthday', 'gender', 'city', 'relationship_goal']);
        Sanctum::actingAs($user);

        $this->putJson('/api/v1/profile/showcase/draft', [
            'self_intro' => '想先提交审核，但仍保持私有。',
            'interest_tags' => ['阅读'],
            'lifestyle_tags' => ['周末慢生活'],
            'opener_note' => '可以从最近读到的一本书聊起。',
        ])->assertOk();

        $this->postJson('/api/v1/profile/showcase/draft/submit-review')
            ->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('draft.visibility_intent', 'private_draft')
            ->assertJsonPath('draft.draft_status', 'draft')
            ->assertJsonPath('draft.moderation_status', 'pending')
            ->assertJsonPath('draft.source_type', 'user_confirmed')
            ->assertJsonPath('draft.public_display_eligible', false)
            ->assertJsonPath('draft.matching_scoring_eligible', false)
            ->assertJsonPath('copy_state.save_label', 'submitted_for_review_pending')
            ->assertJsonPath('copy_state.moderation_status', 'pending')
            ->assertJsonPath('copy_state.public_display_eligible', false)
            ->assertJsonPath('copy_state.matching_scoring_eligible', false);

        $this->assertDatabaseHas('user_profile_showcase_drafts', [
            'user_id' => $user->id,
            'visibility_intent' => 'private_draft',
            'draft_status' => 'draft',
            'moderation_status' => 'pending',
            'source_type' => 'user_confirmed',
            'public_display_eligible' => false,
            'matching_scoring_eligible' => false,
        ]);

        $this->getJson('/api/v1/profile/showcase/draft')
            ->assertOk()
            ->assertJsonPath('draft.moderation_status', 'pending')
            ->assertJsonPath('draft.public_display_eligible', false)
            ->assertJsonPath('draft.matching_scoring_eligible', false);

        $user->refresh();
        $this->assertSame($snapshot['name'], $user->name);
        $this->assertSame(optional($snapshot['birthday'])->format('Y-m-d'), optional($user->birthday)->format('Y-m-d'));
        $this->assertSame($snapshot['gender'], $user->gender);
        $this->assertSame($snapshot['city'], $user->city);
        $this->assertSame($snapshot['relationship_goal'], $user->relationship_goal);
        $this->assertDatabaseCount('user_astro_profiles', 0);
        $this->assertDatabaseCount('dating_matches', 0);
    }

    public function test_submit_for_review_rejects_client_safety_overrides(): void
    {
        $user = $this->user('13800001212');
        Sanctum::actingAs($user);

        $this->putJson('/api/v1/profile/showcase/draft', [
            'self_intro' => '审核覆盖尝试',
        ])->assertOk();

        $response = $this->postJson('/api/v1/profile/showcase/draft/submit-review', [
            'moderation_status' => 'approved',
            'public_display_eligible' => true,
            'matching_scoring_eligible' => true,
            'copy_state' => ['save_label' => 'safety_passed'],
        ])->assertStatus(422)
            ->assertJsonPath('ok', false)
            ->assertJsonPath('error.code', 'validation_error');

        $details = (array) $response->json('error.details');
        $this->assertArrayHasKey('moderation_status', $details);
        $this->assertArrayHasKey('public_display_eligible', $details);
        $this->assertArrayHasKey('matching_scoring_eligible', $details);
        $this->assertArrayHasKey('copy_state', $details);

        $this->assertDatabaseHas('user_profile_showcase_drafts', [
            'user_id' => $user->id,
            'moderation_status' => 'not_submitted',
            'public_display_eligible' => false,
            'matching_scoring_eligible' => false,
        ]);
    }

    public function test_editing_pending_draft_resets_review_status_to_not_submitted(): void
    {
        $user = $this->user('13800001213');
        Sanctum::actingAs($user);

        $this->putJson('/api/v1/profile/showcase/draft', [
            'self_intro' => '待审核版本',
        ])->assertOk();
        $this->postJson('/api/v1/profile/showcase/draft/submit-review')->assertOk();

        $this->putJson('/api/v1/profile/showcase/draft', [
            'self_intro' => '修改后重新变为未提交',
        ])->assertOk()
            ->assertJsonPath('draft.self_intro', '修改后重新变为未提交')
            ->assertJsonPath('draft.moderation_status', 'not_submitted')
            ->assertJsonPath('draft.public_display_eligible', false)
            ->assertJsonPath('draft.matching_scoring_eligible', false);

        $this->assertDatabaseHas('user_profile_showcase_drafts', [
            'user_id' => $user->id,
            'self_intro' => '修改后重新变为未提交',
            'moderation_status' => 'not_submitted',
            'public_display_eligible' => false,
            'matching_scoring_eligible' => false,
        ]);
    }

    public function test_private_draft_api_exposes_safe_review_result_statuses_only(): void
    {
        $statuses = [
            'not_submitted',
            'pending',
            'approved',
            'rejected',
            'needs_revision',
            'manual_review_required',
        ];

        foreach ($statuses as $index => $status) {
            $user = $this->user('138000013' . str_pad((string) $index, 2, '0', STR_PAD_LEFT));
            Sanctum::actingAs($user);

            UserProfileShowcaseDraft::query()->create([
                'user_id' => $user->id,
                'self_intro' => '私有草稿审核状态 ' . $status,
                'interest_tags' => ['阅读'],
                'lifestyle_tags' => ['周末慢生活'],
                'opener_note' => '仍然只是私有草稿。',
                'visibility_intent' => 'private_draft',
                'draft_status' => 'draft',
                'moderation_status' => $status,
                'source_type' => 'user_confirmed',
                'public_display_eligible' => false,
                'matching_scoring_eligible' => false,
            ]);

            $response = $this->getJson('/api/v1/profile/showcase/draft')
                ->assertOk()
                ->assertJsonPath('draft.moderation_status', $status)
                ->assertJsonPath('copy_state.moderation_status', $status)
                ->assertJsonPath('draft.visibility_intent', 'private_draft')
                ->assertJsonPath('draft.public_display_eligible', false)
                ->assertJsonPath('draft.matching_scoring_eligible', false)
                ->assertJsonPath('copy_state.public_display_eligible', false)
                ->assertJsonPath('copy_state.matching_scoring_eligible', false);

            $payload = (array) $response->json('draft');
            $this->assertArrayNotHasKey('audit_note', $payload);
            $this->assertArrayNotHasKey('reviewer_id', $payload);
            $this->assertArrayNotHasKey('reviewer_identity', $payload);
            $this->assertArrayNotHasKey('internal_command', $payload);
            $this->assertArrayNotHasKey('provider', $payload);
        }
    }

    public function test_private_draft_api_uses_error_fallback_for_unknown_review_result_status(): void
    {
        $user = $this->user('13800001390');
        Sanctum::actingAs($user);

        UserProfileShowcaseDraft::query()->create([
            'user_id' => $user->id,
            'self_intro' => '未知审核状态仍需安全降级。',
            'interest_tags' => ['阅读'],
            'lifestyle_tags' => ['周末慢生活'],
            'opener_note' => '仍然只是私有草稿。',
            'visibility_intent' => 'private_draft',
            'draft_status' => 'draft',
            'moderation_status' => 'provider_internal_hold',
            'source_type' => 'user_confirmed',
            'public_display_eligible' => true,
            'matching_scoring_eligible' => true,
        ]);

        $this->getJson('/api/v1/profile/showcase/draft')
            ->assertOk()
            ->assertJsonPath('draft.moderation_status', 'error')
            ->assertJsonPath('copy_state.moderation_status', 'error')
            ->assertJsonPath('draft.visibility_intent', 'private_draft')
            ->assertJsonPath('draft.public_display_eligible', false)
            ->assertJsonPath('draft.matching_scoring_eligible', false)
            ->assertJsonPath('copy_state.public_display_eligible', false)
            ->assertJsonPath('copy_state.matching_scoring_eligible', false);
    }

    private function user(string $phone): User
    {
        return User::create([
            'phone' => $phone,
            'name' => 'Profile Draft User',
            'password' => 'secret123',
            'birthday' => '1996-06-13',
            'gender' => 'female',
            'city' => '上海市',
            'relationship_goal' => 'dating',
        ]);
    }
}
