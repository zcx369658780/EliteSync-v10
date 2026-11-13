<?php

namespace Tests\Feature;

use App\Models\MediaAsset;
use App\Models\User;
use App\Services\MediaAssetService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Tests\TestCase;

/** Route-level fixture checks. The separate APP/API/MariaDB/Web run proves the product chain. */
class ProfileShowcaseWorkflowTest extends TestCase
{
    use RefreshDatabase;

    private int $accountSequence = 0;

    protected function setUp(): void
    {
        parent::setUp();
        config(['restoration.enabled' => true]);
        Storage::fake('v1016_showcase');
    }

    private function account(string $role = 'user'): User
    {
        return User::factory()->create(['role' => $role, 'disabled' => false,
            'phone' => '901016'.str_pad((string) ++$this->accountSequence, 5, '0', STR_PAD_LEFT)]);
    }

    public function test_legacy_approved_draft_can_enter_snapshot_review_without_exposing_it(): void
    {
        $owner = $this->account();
        \App\Models\UserProfileShowcaseDraft::create($this->fields() + [
            'user_id' => $owner->id, 'moderation_status' => 'approved',
            'draft_status' => 'draft', 'visibility_intent' => 'private_draft',
        ]);
        $submission = $this->submit($owner, 1)['submission'];
        self::assertSame('pending', $submission['state']);
        $this->getJson('/api/v1/profile/showcase/publication')->assertJsonPath('publication', null);
        $this->review($this->administrator(), $submission);
        $this->publish($owner, 1, 0);
    }

    public function test_restricted_owner_retains_private_reads_without_new_writes_or_peer_access(): void
    {
        $owner = $this->account();
        $peer = $this->account();
        $this->friends($owner, $peer);
        $draft = $this->upload($owner, 0);
        $this->save($owner, 1, ['photo_ids' => $draft['draft']['photo_ids']]);
        $submission = $this->submit($owner, 2)['submission'];
        $this->review($this->administrator(), $submission);
        $this->publish($owner, 2, 0);
        $owner->forceFill(['moderation_status' => 'restricted'])->save();
        $this->actingAs($owner, 'sanctum')->getJson('/api/v1/profile/showcase/draft')->assertOk();
        $this->getJson('/api/v1/profile/showcase/publication')->assertOk();
        $this->get($draft['draft']['photos'][0]['content_path'])->assertOk();
        $this->putJson('/api/v1/profile/showcase/draft', ['expected_revision' => 2] + $this->fields())->assertForbidden();
        $this->postJson('/api/v1/profile/showcase/publication', ['expected_revision' => 2,
            'publication_revision' => 1, 'confirm_public_display' => true])->assertForbidden();
        $this->actingAs($peer, 'sanctum')->getJson('/api/v1/profile/showcase/'.$owner->id)->assertForbidden();
    }

    private function administrator(): User
    {
        $admin = $this->account('admin');
        config(['app.admin_phones' => [$admin->phone]]);
        return $admin;
    }

    private function fields(array $overrides = []): array
    {
        return array_replace([
            'display_name' => 'Fictional showcase', 'city' => 'Development City',
            'relationship_goal' => 'friendship', 'self_intro' => 'Reviewed introduction',
            'interest_tags' => ['阅读'], 'lifestyle_tags' => ['散步'], 'opener_note' => 'Hello',
            'photo_ids' => [], 'audiences' => ['friends'],
        ], $overrides);
    }

    private function save(User $owner, int $revision, array $fields = []): array
    {
        return $this->actingAs($owner, 'sanctum')->putJson('/api/v1/profile/showcase/draft',
            ['expected_revision' => $revision] + $this->fields($fields))->assertOk()->json();
    }

    private function submit(User $owner, int $revision): array
    {
        return $this->actingAs($owner, 'sanctum')->postJson('/api/v1/profile/showcase/draft/submit-review',
            ['expected_revision' => $revision])->assertOk()->json();
    }

    private function review(User $admin, array $submission, string $result = 'approved', string $reason = 'Fixture review'): void
    {
        $this->actingAs($admin, 'web')->post('/admin/showcase/'.$submission['id'], [
            'expected_revision' => $submission['revision'], 'result' => $result,
            'reason' => $reason, 'confirm' => '1',
        ])->assertRedirect('/admin/showcase/'.$submission['id']);
    }

    private function publish(User $owner, int $draftRevision, int $publicationRevision): array
    {
        return $this->actingAs($owner, 'sanctum')->postJson('/api/v1/profile/showcase/publication', [
            'expected_revision' => $draftRevision, 'publication_revision' => $publicationRevision,
            'confirm_public_display' => true,
        ])->assertOk()->assertJsonPath('publication.publication_status', 'published')->json();
    }

    private function image(string $sentinel = ''): UploadedFile
    {
        $image = imagecreatetruecolor(20, 10);
        ob_start();
        imagepng($image);
        $bytes = ob_get_clean();
        imagedestroy($image);
        return UploadedFile::fake()->createWithContent('private-original.png', $bytes.$sentinel);
    }

    private function upload(User $owner, int $revision, ?string $uploadId = null): array
    {
        return $this->actingAs($owner, 'sanctum')->post('/api/v1/profile/showcase/photos', [
            'photo' => $this->image('private-metadata-sentinel'),
            'expected_revision' => $revision, 'client_upload_id' => $uploadId ?? (string) Str::uuid(),
        ], ['Accept' => 'application/json'])->assertOk()->json();
    }

    private function friends(User $a, User $b): void
    {
        $this->actingAs($b, 'sanctum')->postJson('/api/v1/social/preferences', ['requests_enabled' => true])->assertOk();
        $token = $this->postJson('/api/v1/social/invites', ['purpose' => 'friendship'])->assertCreated()->json('token');
        $id = $this->actingAs($a, 'sanctum')->postJson('/api/v1/social/requests', [
            'purpose' => 'friendship', 'invitation_token' => $token, 'idempotency_key' => (string) Str::uuid(),
        ])->assertCreated()->json('id');
        $this->actingAs($b, 'sanctum')->postJson('/api/v1/social/requests/'.$id.'/accept')->assertOk();
    }

    public function test_web_feedback_resubmission_publication_replacement_and_withdrawal_preserve_snapshots(): void
    {
        $owner = $this->account();
        $peer = $this->account();
        $admin = $this->administrator();
        $this->friends($owner, $peer);
        $this->save($owner, 0);
        $photo = $this->upload($owner, 1);
        $photoId = $photo['draft']['photo_ids'][0];
        $submission = $this->submit($owner, 2)['submission'];
        $this->actingAs($admin, 'web')->get('/admin/showcase/'.$submission['id'])->assertOk()
            ->assertSee('Reviewed introduction')->assertSee('内容版本 2');
        $this->get('/admin/showcase/'.$submission['id'].'/photos/'.$photoId)->assertOk()
            ->assertHeader('Content-Type', 'image/png');
        $this->review($admin, $submission, 'needs_revision', '请补充介绍');
        $this->actingAs($owner, 'sanctum')->getJson('/api/v1/profile/showcase/draft')->assertOk()
            ->assertJsonPath('submission.state', 'needs_revision')->assertJsonPath('submission.feedback', '请补充介绍');
        $this->save($owner, 2, ['self_intro' => 'Revised introduction', 'photo_ids' => [$photoId]]);
        $submission = $this->submit($owner, 3)['submission'];
        $this->review($admin, $submission);
        $this->assertDatabaseCount('user_profile_showcase_publications', 0);
        $this->actingAs($peer, 'sanctum')->getJson('/api/v1/profile/showcase/'.$owner->id)->assertNotFound();
        $first = $this->publish($owner, 3, 0);
        $oldPhotoPath = $first['publication']['public_fields']['photos'][0]['content_path'];
        $this->publish($owner, 3, 0);
        $this->assertDatabaseCount('user_profile_showcase_publication_audits', 1);
        $this->actingAs($peer, 'sanctum')->getJson('/api/v1/profile/showcase/'.$owner->id)->assertOk()
            ->assertJsonPath('publication.public_fields.self_intro', 'Revised introduction');
        $this->get($oldPhotoPath)->assertOk()->assertHeader('Content-Type', 'image/png');
        $this->save($owner, 3, ['self_intro' => 'Private replacement', 'photo_ids' => []]);
        $this->actingAs($peer, 'sanctum')->getJson('/api/v1/profile/showcase/'.$owner->id)->assertOk()
            ->assertJsonPath('publication.public_fields.self_intro', 'Revised introduction');
        $this->get($oldPhotoPath)->assertOk();
        $submission = $this->submit($owner, 4)['submission'];
        $this->review($admin, $submission);
        $this->actingAs($owner, 'sanctum')->postJson('/api/v1/profile/showcase/publication', [
            'expected_revision' => 4, 'publication_revision' => 0, 'confirm_public_display' => true,
        ])->assertConflict();
        $this->publish($owner, 4, 1);
        $this->actingAs($peer, 'sanctum')->getJson('/api/v1/profile/showcase/'.$owner->id)->assertOk()
            ->assertJsonPath('publication.public_fields.self_intro', 'Private replacement');
        $this->get($oldPhotoPath)->assertNotFound();
        $this->actingAs($owner, 'sanctum')->deleteJson('/api/v1/profile/showcase/publication', ['expected_revision' => 2])
            ->assertOk()->assertJsonPath('publication.publication_status', 'withdrawn');
        $this->deleteJson('/api/v1/profile/showcase/publication', ['expected_revision' => 2])->assertOk();
        $this->assertDatabaseCount('user_profile_showcase_publication_audits', 3);
        $this->actingAs($peer, 'sanctum')->getJson('/api/v1/profile/showcase/'.$owner->id)->assertNotFound()
            ->assertJsonPath('error.message', 'showcase_withdrawn');
        $this->get($oldPhotoPath)->assertNotFound();
    }

    public function test_photos_are_normalized_owned_bounded_ordered_and_removed_with_revision_checks(): void
    {
        $owner = $this->account();
        $other = $this->account();
        $uploadId = (string) Str::uuid();
        $first = $this->upload($owner, 0, $uploadId);
        $this->upload($owner, 0, $uploadId);
        $this->assertDatabaseCount('profile_showcase_photos', 1);
        $path = $first['draft']['photos'][0]['content_path'];
        $response = $this->get($path)->assertOk();
        self::assertStringNotContainsString('private-metadata-sentinel', file_get_contents($response->getFile()->getPathname()));
        self::assertStringContainsString('no-store', $response->headers->get('Cache-Control'));
        $asset = MediaAsset::firstOrFail();
        self::assertSame('', $asset->public_url);
        $this->get('/api/v1/media/'.$asset->id.'/content')->assertNotFound();
        $this->post('/api/v1/profile/showcase/photos', [
            'photo' => $this->image('different'), 'expected_revision' => 1, 'client_upload_id' => $uploadId,
        ], ['Accept' => 'application/json'])->assertConflict();
        $this->post('/api/v1/profile/showcase/photos', [
            'photo' => $this->image(), 'expected_revision' => 0, 'client_upload_id' => (string) Str::uuid(),
        ], ['Accept' => 'application/json'])->assertConflict();
        $this->assertDatabaseCount('profile_showcase_photos', 1);
        $this->actingAs($other, 'sanctum')->get($path)->assertNotFound();
        $this->putJson('/api/v1/profile/showcase/draft', ['expected_revision' => 0] +
            $this->fields(['photo_ids' => $first['draft']['photo_ids']]))->assertUnprocessable();
        $this->assertDatabaseMissing('user_profile_showcase_drafts', ['user_id' => $other->id]);
        $latest = $first;
        for ($revision = 1; $revision < 6; $revision++) {
            $latest = $this->upload($owner, $revision);
        }
        $this->post('/api/v1/profile/showcase/photos', [
            'photo' => $this->image(), 'expected_revision' => 6, 'client_upload_id' => (string) Str::uuid(),
        ], ['Accept' => 'application/json'])->assertUnprocessable();
        $this->assertDatabaseCount('profile_showcase_photos', 6);
        $ids = array_reverse($latest['draft']['photo_ids']);
        $this->save($owner, 6, ['photo_ids' => $ids]);
        $this->getJson('/api/v1/profile/showcase/draft')->assertOk()->assertJsonPath('draft.photo_ids', $ids);
        $this->save($owner, 7, ['photo_ids' => []]);
        $this->get($path)->assertNotFound();
        $this->getJson('/api/v1/profile/showcase/draft')->assertOk()->assertJsonPath('draft.photos', []);
    }

    public function test_stale_edits_and_reviews_are_rejected_and_duplicate_submission_has_one_effect(): void
    {
        $owner = $this->account();
        $admin = $this->administrator();
        $this->save($owner, 0);
        $this->save($owner, 0);
        $old = $this->submit($owner, 1)['submission'];
        $this->submit($owner, 1);
        $this->assertDatabaseCount('profile_showcase_submissions', 1);
        $this->save($owner, 1, ['self_intro' => 'New private content']);
        $this->actingAs($owner, 'sanctum')->putJson('/api/v1/profile/showcase/draft',
            ['expected_revision' => 1] + $this->fields(['self_intro' => 'Stale overwrite']))->assertConflict();
        $this->postJson('/api/v1/profile/showcase/draft/submit-review', ['expected_revision' => 1])->assertConflict();
        $this->actingAs($admin, 'web')->post('/admin/showcase/'.$old['id'], [
            'expected_revision' => 1, 'result' => 'approved', 'reason' => 'Stale review', 'confirm' => '1',
        ])->assertConflict();
        $this->assertDatabaseCount('user_profile_showcase_review_audits', 0);
        $current = $this->submit($owner, 2)['submission'];
        $this->review($admin, $current);
        $this->actingAs($admin, 'web')->post('/admin/showcase/'.$current['id'], [
            'expected_revision' => 2, 'result' => 'rejected', 'reason' => 'Duplicate review', 'confirm' => '1',
        ])->assertConflict();
        $this->assertDatabaseCount('user_profile_showcase_review_audits', 1);
        $this->actingAs($owner, 'sanctum')->getJson('/api/v1/profile/showcase/draft')->assertOk()
            ->assertJsonPath('draft.self_intro', 'New private content')->assertJsonPath('submission.state', 'approved');
    }

    public function test_unrelated_accounts_and_current_blocks_cannot_reuse_detail_or_photo_links(): void
    {
        $owner = $this->account();
        $peer = $this->account();
        $stranger = $this->account();
        $admin = $this->administrator();
        $this->friends($owner, $peer);
        $photo = $this->upload($owner, 0);
        $this->save($owner, 1, ['photo_ids' => $photo['draft']['photo_ids']]);
        $submission = $this->submit($owner, 2)['submission'];
        $this->review($admin, $submission);
        $publication = $this->publish($owner, 2, 0);
        $path = $publication['publication']['public_fields']['photos'][0]['content_path'];
        $this->actingAs($peer, 'sanctum')->getJson('/api/v1/profile/showcase/'.$owner->id)->assertOk();
        $this->get($path)->assertOk();
        $this->actingAs($stranger, 'sanctum')->getJson('/api/v1/profile/showcase/'.$owner->id)->assertNotFound();
        $this->get($path)->assertNotFound();
        $this->getJson('/api/v1/profile/showcase/draft')->assertOk()->assertJsonPath('draft', null);
        $this->actingAs($owner, 'sanctum')->postJson('/api/v1/moderation/blocks', ['blocked_user_id' => $peer->id])->assertOk();
        $this->actingAs($peer, 'sanctum')->getJson('/api/v1/profile/showcase/'.$owner->id)->assertNotFound();
        $this->get($path)->assertNotFound();
        $this->actingAs($owner, 'sanctum')->deleteJson('/api/v1/moderation/blocks/'.$peer->id)->assertOk();
        $this->actingAs($peer, 'sanctum')->getJson('/api/v1/profile/showcase/'.$owner->id)->assertNotFound();
        $this->get($path)->assertNotFound();
    }

    public function test_admin_role_and_current_allowlist_are_required_for_snapshot_and_photo_review(): void
    {
        $owner = $this->account();
        $ordinary = $this->account();
        $admin = $this->administrator();
        $photo = $this->upload($owner, 0);
        $this->save($owner, 1, ['photo_ids' => $photo['draft']['photo_ids']]);
        $submission = $this->submit($owner, 2)['submission'];
        $path = '/admin/showcase/'.$submission['id'];
        $photoPath = $path.'/photos/'.$photo['draft']['photo_ids'][0];
        config(['app.admin_phones' => [$ordinary->phone]]);
        $this->actingAs($ordinary, 'web')->get($path)->assertForbidden();
        $this->get($photoPath)->assertForbidden();
        $this->post($path, ['expected_revision' => 2, 'result' => 'approved', 'reason' => 'Forbidden', 'confirm' => '1'])->assertForbidden();
        config(['app.admin_phones' => [$admin->phone]]);
        $this->actingAs($admin, 'web')->get($path)->assertOk();
        $this->get($photoPath)->assertOk();
        config(['app.admin_phones' => []]);
        $this->get($path)->assertForbidden();
        $this->get($photoPath)->assertForbidden();
        $this->assertDatabaseCount('user_profile_showcase_review_audits', 0);
    }

    public function test_operating_application_note_and_actual_web_feedback_persist_without_realname_claim(): void
    {
        $owner = $this->account();
        $owner->forceFill(['verify_status' => 'pending'])->save();
        $admin = $this->administrator();
        $this->actingAs($owner, 'sanctum')->postJson('/api/v1/profile/operating-application', [
            'expected_revision' => 0, 'note' => 'Fictional ordinary application',
        ])->assertOk()->assertJsonPath('application.revision', 1)->assertJsonPath('realname_verified', false);
        $this->postJson('/api/v1/profile/operating-application', [
            'expected_revision' => 0, 'note' => 'Fictional ordinary application',
        ])->assertOk()->assertJsonPath('application.revision', 1);
        $this->actingAs($admin, 'web')->get('/admin/users/'.$owner->id)->assertOk()->assertSee('Fictional ordinary application');
        $this->post('/admin/users/'.$owner->id.'/review', [
            'expected_revision' => $owner->fresh()->verify_revision, 'status' => 'rejected',
            'reason' => 'Please clarify purpose', 'confirm' => '1',
        ])->assertRedirect();
        $this->actingAs($owner, 'sanctum')->getJson('/api/v1/profile/operating-application')->assertOk()
            ->assertJsonPath('application.state', 'rejected')->assertJsonPath('application.feedback', 'Please clarify purpose');
        $revision = (int) DB::table('profile_operating_applications')->where('user_id', $owner->id)->value('revision');
        $this->postJson('/api/v1/profile/operating-application', [
            'expected_revision' => 0, 'note' => 'Stale request',
        ])->assertConflict();
        $this->postJson('/api/v1/profile/operating-application', [
            'expected_revision' => $revision, 'note' => 'Clarified fictional purpose',
        ])->assertOk()->assertJsonPath('application.state', 'pending');
        $this->actingAs($admin, 'web')->post('/admin/users/'.$owner->id.'/review', [
            'expected_revision' => $owner->fresh()->verify_revision, 'status' => 'approved',
            'reason' => 'Development participation approved', 'confirm' => '1',
        ])->assertRedirect();
        $this->actingAs($owner, 'sanctum')->getJson('/api/v1/profile/operating-application')->assertOk()
            ->assertJsonPath('application.state', 'approved')->assertJsonPath('realname_verified', false);
        $this->assertDatabaseCount('profile_operating_applications', 1);
        $this->assertDatabaseHas('users', ['id' => $owner->id, 'verify_status' => 'approved']);
    }

    public function test_storage_failure_preserves_existing_private_draft_and_photo_pointer(): void
    {
        $owner = $this->account();
        $first = $this->upload($owner, 0);
        $before = (array) DB::table('user_profile_showcase_drafts')->where('user_id', $owner->id)->first();
        $this->mock(MediaAssetService::class)->shouldReceive('registerUploaded')->once()
            ->andThrow(new \RuntimeException('synthetic showcase upload failure'));
        $this->actingAs($owner, 'sanctum')->post('/api/v1/profile/showcase/photos', [
            'photo' => $this->image(), 'expected_revision' => 1, 'client_upload_id' => (string) Str::uuid(),
        ], ['Accept' => 'application/json'])->assertStatus(500);
        self::assertSame($before, (array) DB::table('user_profile_showcase_drafts')->where('user_id', $owner->id)->first());
        $this->assertDatabaseCount('profile_showcase_photos', 1);
        $this->get($first['draft']['photos'][0]['content_path'])->assertOk();
    }
}
