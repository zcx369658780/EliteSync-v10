<?php

namespace Tests\Feature;

use App\Models\DatingMatch;
use App\Models\MediaAsset;
use App\Models\User;
use App\Services\PrivateVideoValidator;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

final class V1009PrivateVideoTest extends TestCase
{
    use RefreshDatabase;

    private function probe(array $replace = []): array
    {
        return array_replace_recursive([
            'format' => ['format_name' => 'mov,mp4,m4a,3gp,3g2,mj2', 'duration' => '2.5'],
            'streams' => [['codec_type' => 'video', 'codec_name' => 'h264', 'width' => 320, 'height' => 240]],
        ], $replace);
    }

    private function validator(array $probe): PrivateVideoValidator
    {
        return new class($probe) extends PrivateVideoValidator {
            public function __construct(private array $result) {}
            protected function probe(string $path): array { return $this->result; }
        };
    }

    private function file(string $mime = 'video/mp4', int $size = 1024): UploadedFile
    {
        // Only the ffprobe boundary is synthetic here; real binary/media verification is separate.
        return UploadedFile::fake()->create('clip.mp4', (int) ceil($size / 1024), $mime)->size((int) ceil($size / 1024));
    }

    public function test_h264_without_audio_has_explicit_trusted_metadata(): void
    {
        $result = $this->validator($this->probe())->validate($this->file());
        $this->assertSame(2500, $result['duration_ms']);
        $this->assertSame('h264', $result['metadata']['video_codec']);
        $this->assertFalse($result['metadata']['audio_present']);
        $this->assertNull($result['metadata']['audio_codec']);
    }

    public function test_h264_with_aac_is_accepted(): void
    {
        $probe = $this->probe();
        $probe['streams'][] = ['codec_type' => 'audio', 'codec_name' => 'aac'];
        $this->assertTrue($this->validator($probe)->validate($this->file())['metadata']['audio_present']);
    }

    public function test_invalid_probe_content_is_rejected(): void
    {
        $cases = [
            $this->probe(['format' => ['duration' => '30.01']]),
            $this->probe(['format' => ['duration' => 'NaN']]),
            $this->probe(['format' => ['format_name' => 'matroska']]),
            $this->probe(['streams' => [['codec_name' => 'hevc']]]),
            ['format' => ['duration' => 1, 'format_name' => 'mp4'], 'streams' => []],
        ];
        foreach ($cases as $probe) {
            try {
                $this->validator($probe)->validate($this->file());
                $this->fail('Invalid media accepted');
            } catch (ValidationException $e) {
                $this->assertArrayHasKey('file', $e->errors());
            }
        }
    }

    public function test_wrong_audio_codec_is_rejected(): void
    {
        $probe = $this->probe();
        $probe['streams'][] = ['codec_type' => 'audio', 'codec_name' => 'opus'];
        $this->expectException(ValidationException::class);
        $this->validator($probe)->validate($this->file());
    }

    public function test_oversize_is_rejected_before_probe(): void
    {
        $this->expectException(ValidationException::class);
        $this->validator($this->probe())->validate($this->file('video/mp4', 26 * 1024 * 1024));
    }

    public function test_false_mime_is_rejected(): void
    {
        $this->expectException(ValidationException::class);
        $this->validator($this->probe())->validate($this->file('image/png'));
    }

    public function test_missing_verifier_fails_closed(): void
    {
        config(['media.video.ffprobe_path' => '']);
        $this->expectException(ValidationException::class);
        (new PrivateVideoValidator)->validate($this->file());
    }

    public function test_upload_without_content_verifier_creates_no_ready_asset(): void
    {
        config(['restoration.enabled' => true, 'media.disk' => 'v1009', 'media.video.ffprobe_path' => '']);
        Sanctum::actingAs(User::factory()->create(['phone' => '19900000924', 'disabled' => false, 'is_synthetic' => false]));
        $this->postJson('/api/v1/media', ['media_type' => 'video', 'file' => $this->file(),
            'duration_ms' => 1, 'mime_type' => 'video/mp4'])->assertUnprocessable();
        $this->assertDatabaseCount('media_assets', 0);
    }

    public function test_current_permission_is_checked_for_video_and_range_after_revocation(): void
    {
        config(['restoration.enabled' => true, 'media.disk' => 'v1009']);
        Storage::fake('v1009');
        $a = User::factory()->create(['phone' => '19900000921', 'disabled' => false, 'is_synthetic' => false]);
        $b = User::factory()->create(['phone' => '19900000922', 'disabled' => false, 'is_synthetic' => false]);
        $outsider = User::factory()->create(['phone' => '19900000923', 'disabled' => false, 'is_synthetic' => false]);
        DatingMatch::create(['week_tag' => 'v1009-media', 'user_a' => $a->id, 'user_b' => $b->id, 'drop_released' => true]);
        foreach ([[$a, $b, 'connection', 'request', 0], [$b, $a, 'connection', 'accept', 1],
            [$a, $b, 'consent', 'request', 0], [$b, $a, 'consent', 'accept', 1]] as [$actor, $peer, $kind, $action, $revision]) {
            Sanctum::actingAs($actor);
            $this->postJson('/api/v1/connections/'.$peer->id.'/'.$kind, ['action' => $action, 'expected_revision' => $revision])->assertOk();
        }
        Storage::disk('v1009')->put('private/clip.mp4', 'synthetic-range-bytes');
        $asset = MediaAsset::create(['owner_user_id' => $a->id, 'media_type' => 'video', 'mime_type' => 'video/mp4',
            'storage_disk' => 'v1009', 'storage_provider' => 'local', 'storage_key' => 'private/clip.mp4',
            'status' => 'ready', 'size_bytes' => 21]);
        Sanctum::actingAs($a);
        $this->postJson('/api/v1/messages', ['receiver_id' => $b->id, 'content' => '', 'attachment_ids' => [$asset->id]])->assertOk();
        Sanctum::actingAs($b);
        $this->get('/api/v1/media/'.$asset->id.'/content', ['Range' => 'bytes=0-3'])->assertStatus(206)->assertHeader('Content-Range', 'bytes 0-3/21');
        Sanctum::actingAs($outsider);
        $this->get('/api/v1/media/'.$asset->id.'/content', ['Range' => 'bytes=0-3'])->assertNotFound();
        Sanctum::actingAs($b);
        $this->postJson('/api/v1/connections/'.$a->id.'/consent', ['action' => 'revoke', 'expected_revision' => 2])->assertOk();
        $this->get('/api/v1/media/'.$asset->id.'/content', ['Range' => 'bytes=0-3'])->assertNotFound();
        $this->get('/api/v1/media/'.$asset->id.'/content')->assertNotFound();
    }
}
