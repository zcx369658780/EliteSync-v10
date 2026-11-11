<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\MediaAsset;
use App\Services\MediaAssetService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ProfileAvatarApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        config(['restoration.enabled' => true, 'media.disk' => 'v1011_relationship']);
        Storage::fake('v1011_relationship');
    }

    private function users(): array
    {
        return [User::factory()->create(['phone' => '90123457201']), User::factory()->create(['phone' => '90123457202']), User::factory()->create(['phone' => '90123457203'])];
    }

    private function image(string $suffix = ''): UploadedFile
    {
        $im = imagecreatetruecolor(16, 12);
        ob_start(); imagepng($im); $bytes = ob_get_clean(); imagedestroy($im);
        return UploadedFile::fake()->createWithContent('avatar.png', $bytes.$suffix);
    }

    private function upload(User $owner, int $revision = 0, string $suffix = ''): array
    {
        return $this->actingAs($owner, 'sanctum')->post('/api/v1/profile/avatar', ['file' => $this->image($suffix), 'expected_revision' => $revision], ['Accept' => 'application/json'])
            ->assertOk()->assertJsonPath('avatar.owner_user_id', $owner->id)->json();
    }

    private function invite(User $sender, User $recipient): array
    {
        $this->actingAs($recipient, 'sanctum')->postJson('/api/v1/social/preferences', ['requests_enabled' => true])->assertOk();
        $invite = $this->postJson('/api/v1/social/invites', ['purpose' => 'friendship'])->assertCreated()->json();
        $request = $this->actingAs($sender, 'sanctum')->postJson('/api/v1/social/requests', ['purpose' => 'friendship', 'invitation_token' => $invite['token'], 'idempotency_key' => 'avatar-request'])->assertCreated()->json('id');
        return [$invite['id'], $request];
    }

    public function test_upload_is_private_normalized_and_owner_only_without_context(): void
    {
        config(['media.disk' => 'v1009']);
        [$owner, $peer] = $this->users();
        $before = $owner->fresh()->getAttributes();
        $uploaded = $this->upload($owner, 0, 'GPS-private-sentinel');
        $this->getJson('/api/v1/avatars/'.$owner->id)->assertOk()->assertJsonPath('revision', 1);
        $image = $this->get($uploaded['avatar']['content_path'])->assertOk()->assertHeader('Content-Type', 'image/png');
        self::assertStringContainsString('no-store', $image->headers->get('Cache-Control'));
        self::assertStringNotContainsString('GPS-private-sentinel', file_get_contents($image->getFile()->getPathname()));
        self::assertSame($before, $owner->fresh()->getAttributes());
        $asset = MediaAsset::firstOrFail();
        self::assertSame('v1011_relationship', $asset->storage_disk);
        self::assertSame('v1009', config('media.disk'));
        $this->actingAs($peer, 'sanctum')->getJson('/api/v1/avatars/'.$owner->id)->assertNotFound();
        $this->get($uploaded['avatar']['content_path'])->assertNotFound();
        $this->get('/api/v1/media/'.$asset->id.'/content')->assertNotFound();
    }

    public function test_invitation_context_is_current_not_a_permanent_avatar_grant(): void
    {
        [$owner, $peer] = $this->users();
        $uploaded = $this->upload($owner);
        [$invite] = $this->invite($peer, $owner);
        $this->actingAs($peer, 'sanctum')->get($uploaded['avatar']['content_path'])->assertOk();
        $this->actingAs($owner, 'sanctum')->deleteJson('/api/v1/social/invites/'.$invite)->assertOk();
        $this->actingAs($peer, 'sanctum')->get($uploaded['avatar']['content_path'])->assertNotFound();
    }

    public function test_friends_can_view_but_block_and_unblock_do_not_restore_old_authority(): void
    {
        [$owner, $peer] = $this->users();
        $uploaded = $this->upload($owner);
        [, $request] = $this->invite($peer, $owner);
        $this->actingAs($owner, 'sanctum')->postJson('/api/v1/social/requests/'.$request.'/accept')->assertOk();
        $this->actingAs($peer, 'sanctum')->getJson('/api/v1/profile-peers/'.$owner->id)->assertOk()->assertJsonPath('profile.avatar.revision', 1)->assertJsonMissingPath('profile.birthday');
        $this->get($uploaded['avatar']['content_path'])->assertOk();
        $this->actingAs($owner, 'sanctum')->postJson('/api/v1/moderation/blocks', ['blocked_user_id' => $peer->id])->assertOk();
        $this->actingAs($peer, 'sanctum')->get($uploaded['avatar']['content_path'])->assertNotFound();
        $this->actingAs($owner, 'sanctum')->deleteJson('/api/v1/moderation/blocks/'.$peer->id)->assertOk();
        $this->actingAs($peer, 'sanctum')->get($uploaded['avatar']['content_path'])->assertNotFound();
    }

    public function test_replacement_and_removal_invalidate_old_paths_and_stale_revision(): void
    {
        [$owner] = $this->users();
        $first = $this->upload($owner);
        $second = $this->upload($owner, 1);
        $this->get($first['avatar']['content_path'])->assertNotFound();
        $this->get($second['avatar']['content_path'])->assertOk();
        $count = MediaAsset::count();
        $this->post('/api/v1/profile/avatar', ['file' => $this->image(), 'expected_revision' => 0], ['Accept' => 'application/json'])->assertConflict();
        self::assertSame($count, MediaAsset::count());
        $this->deleteJson('/api/v1/profile/avatar', ['expected_revision' => 1])->assertConflict();
        $this->deleteJson('/api/v1/profile/avatar', ['expected_revision' => 2])->assertOk()->assertJsonPath('revision', 3)->assertJsonPath('avatar', null);
        $this->get($second['avatar']['content_path'])->assertNotFound();
        $this->getJson('/api/v1/avatars/'.$owner->id)->assertOk()->assertJsonPath('avatar', null);
    }

    public function test_non_image_and_owner_override_are_rejected_without_asset(): void
    {
        [$owner, $peer] = $this->users();
        $this->actingAs($owner, 'sanctum')->post('/api/v1/profile/avatar', ['file' => UploadedFile::fake()->createWithContent('fake.jpg', 'not an image'), 'expected_revision' => 0], ['Accept' => 'application/json'])->assertUnprocessable();
        $this->post('/api/v1/profile/avatar', ['file' => $this->image(), 'expected_revision' => 0, 'owner_user_id' => $peer->id], ['Accept' => 'application/json'])->assertUnprocessable();
        self::assertSame(0, MediaAsset::count());
    }

    public function test_jpeg_metadata_is_removed_and_oversized_pixels_are_rejected(): void
    {
        [$owner] = $this->users();
        $im = imagecreatetruecolor(20, 10);
        ob_start(); imagejpeg($im); $bytes = ob_get_clean(); imagedestroy($im);
        $metadata = "Exif\0\0GPS-private-sentinel";
        $bytes = substr($bytes, 0, 2)."\xFF\xE1".pack('n', strlen($metadata) + 2).$metadata.substr($bytes, 2);
        $result = $this->actingAs($owner, 'sanctum')->post('/api/v1/profile/avatar', ['file' => UploadedFile::fake()->createWithContent('photo.jpg', $bytes), 'expected_revision' => 0], ['Accept' => 'application/json'])->assertOk()->json();
        $response = $this->get($result['avatar']['content_path'])->assertOk();
        self::assertStringNotContainsString('GPS-private-sentinel', file_get_contents($response->getFile()->getPathname()));
        $im = imagecreatetruecolor(4097, 1);
        ob_start(); imagepng($im); $bytes = ob_get_clean(); imagedestroy($im);
        $this->post('/api/v1/profile/avatar', ['file' => UploadedFile::fake()->createWithContent('wide.png', $bytes), 'expected_revision' => 1], ['Accept' => 'application/json'])->assertUnprocessable();
        self::assertSame(1, MediaAsset::count());
    }

    public function test_authorized_conversation_is_independent_of_friendship_and_invite_expiry(): void
    {
        [$owner, $peer] = $this->users();
        $uploaded = $this->upload($owner);
        [$invite, $request] = $this->invite($peer, $owner);
        $this->actingAs($owner, 'sanctum')->postJson('/api/v1/social/requests/'.$request.'/accept')->assertOk();
        foreach (['connection', 'consent'] as $kind) {
            $this->actingAs($owner, 'sanctum')->postJson('/api/v1/connections/'.$peer->id.'/'.$kind, ['action' => 'request', 'expected_revision' => 0])->assertOk();
            $this->actingAs($peer, 'sanctum')->postJson('/api/v1/connections/'.$owner->id.'/'.$kind, ['action' => 'accept', 'expected_revision' => 1])->assertOk();
        }
        $this->actingAs($owner, 'sanctum')->deleteJson('/api/v1/social/friends/'.$peer->id)->assertOk();
        $this->deleteJson('/api/v1/social/invites/'.$invite)->assertOk();
        $this->actingAs($peer, 'sanctum')->get($uploaded['avatar']['content_path'])->assertOk();
        $current = $this->actingAs($owner, 'sanctum')->getJson('/api/v1/connections/'.$peer->id)->assertOk()->json('consent');
        $this->postJson('/api/v1/connections/'.$peer->id.'/consent', ['action' => 'revoke', 'expected_revision' => $current['revision']])->assertOk();
        $this->actingAs($peer, 'sanctum')->get($uploaded['avatar']['content_path'])->assertNotFound();
    }

    public function test_authentication_and_current_account_status_are_required(): void
    {
        $this->getJson('/api/v1/avatars/1')->assertUnauthorized();
        [$owner] = $this->users();
        $uploaded = $this->upload($owner);
        DB::table('users')->where('id', $owner->id)->update(['disabled' => true]);
        $this->getJson('/api/v1/avatars/'.$owner->id)->assertForbidden();
        $this->get($uploaded['avatar']['content_path'])->assertForbidden();
    }

    public function test_jpeg_orientation_is_applied_to_pixels_before_metadata_is_removed(): void
    {
        [$owner] = $this->users();
        $im = imagecreatetruecolor(20, 10);
        ob_start(); imagejpeg($im); $bytes = ob_get_clean(); imagedestroy($im);
        // Little-endian TIFF IFD0, Orientation=6 (90 degrees clockwise).
        $exif = "Exif\0\0II\x2A\0\x08\0\0\0\x01\0\x12\x01\x03\0\x01\0\0\0\x06\0\0\0\0\0\0\0";
        $bytes = substr($bytes, 0, 2)."\xFF\xE1".pack('n', strlen($exif) + 2).$exif.substr($bytes, 2);
        $result = $this->actingAs($owner, 'sanctum')->post('/api/v1/profile/avatar', ['file' => UploadedFile::fake()->createWithContent('rotated.jpg', $bytes), 'expected_revision' => 0], ['Accept' => 'application/json'])->assertOk()->json();
        $response = $this->get($result['avatar']['content_path'])->assertOk();
        $info = getimagesize($response->getFile()->getPathname());
        self::assertSame([10, 20], [$info[0], $info[1]]);
    }

    public function test_upload_failure_preserves_old_pointer_and_cleans_normalization_temporary_file(): void
    {
        [$owner] = $this->users();
        $old = $this->upload($owner);
        $pointer = (array) DB::table('user_profile_avatars')->where('user_id', $owner->id)->first();
        $temporaryBefore = glob(sys_get_temp_dir().'/elitesync-avatar-*');
        $this->mock(MediaAssetService::class)->shouldReceive('registerUploaded')->once()->andThrow(new \RuntimeException('synthetic upload failure'));
        $this->post('/api/v1/profile/avatar', ['file' => $this->image(), 'expected_revision' => 1], ['Accept' => 'application/json'])->assertStatus(500);
        self::assertSame($pointer, (array) DB::table('user_profile_avatars')->where('user_id', $owner->id)->first());
        self::assertSame($temporaryBefore, glob(sys_get_temp_dir().'/elitesync-avatar-*'));
        $this->get($old['avatar']['content_path'])->assertOk();
    }
}
