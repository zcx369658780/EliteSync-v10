<?php

namespace Tests\Feature;

use App\Models\MediaAsset;
use App\Models\User;
use App\Services\LiveConsentService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Symfony\Component\Process\Process;
use Tests\TestCase;

class V1018AudioTest extends TestCase
{
    use RefreshDatabase;
    private array $temporaryFiles = [];
    private User $a;
    private User $b;

    protected function setUp(): void
    {
        parent::setUp();
        config(['restoration.enabled' => true, 'media.disk' => 'v1009', 'media.video.ffprobe_path' => '/ffmpeg/bin/ffprobe']);
        Storage::fake('v1009');
        $this->a = User::factory()->create(['phone' => '19900001881']); $this->b = User::factory()->create(['phone' => '19900001882']);
        DB::table('friendships')->insert(['user_a' => $this->a->id, 'user_b' => $this->b->id,
            'state' => 'ACTIVE', 'revision' => 1, 'created_at' => now(), 'updated_at' => now()]);
        $service = app(LiveConsentService::class);
        foreach ([[$this->a, $this->b, 'connection', 'request', 0], [$this->b, $this->a, 'connection', 'accept', 1],
            [$this->a, $this->b, 'consent', 'request', 0], [$this->b, $this->a, 'consent', 'accept', 1]] as [$a, $b, $kind, $action, $revision]) {
            $service->transition($a->id, $b->id, $kind, $action, $revision);
        }
        Sanctum::actingAs($this->a);
    }

    protected function tearDown(): void
    {
        foreach ($this->temporaryFiles as $path) if (is_file($path)) unlink($path);
        parent::tearDown();
    }

    private function recording(float $seconds): UploadedFile
    {
        $path = sys_get_temp_dir().'/v1018-'.Str::uuid().'.m4a';
        $this->temporaryFiles[] = $path;
        $process = new Process(['/ffmpeg/bin/ffmpeg', '-v', 'error', '-f', 'lavfi', '-i', 'sine=frequency=523:sample_rate=44100',
            '-t', (string) $seconds, '-c:a', 'aac', '-profile:a', 'aac_low', '-ac', '1', '-b:a', '96000', $path]);
        $process->setTimeout(15); $process->mustRun();
        return new UploadedFile($path, 'fixture.m4a', 'audio/mp4', null, true);
    }

    public function test_valid_audio_upload_send_replay_and_private_range_then_revoke(): void
    {
        // Generated codec fixture. The separate Android chain proves actual recording.
        $upload = $this->post('/api/v1/media', ['media_type' => 'audio', 'duration_ms' => 999999, 'file' => $this->recording(2)])
            ->assertOk()->assertJsonPath('asset.status', 'ready')->assertJsonPath('asset.mime_type', 'audio/mp4');
        $id = $upload->json('asset.id');
        $this->assertGreaterThanOrEqual(2000, $upload->json('asset.duration_ms'));
        $this->assertLessThan(2100, $upload->json('asset.duration_ms'));
        $body = ['receiver_id' => $this->b->id, 'attachment_ids' => [$id], 'client_message_id' => (string) Str::uuid()];
        $sent = $this->postJson('/api/v1/messages', $body)->assertOk()->assertJsonPath('message.message_type', 'audio');
        $this->postJson('/api/v1/messages', $body)->assertOk()->assertJsonPath('id', $sent->json('id'))->assertJsonPath('idempotent_replay', true);
        Sanctum::actingAs($this->b);
        $this->get('/api/v1/media/'.$id.'/content', ['Range' => 'bytes=0-15'])->assertStatus(206)->assertHeader('Content-Type', 'audio/mp4');
        app(LiveConsentService::class)->transition($this->b->id, $this->a->id, 'consent', 'revoke', 2);
        $this->get('/api/v1/media/'.$id.'/content', ['Range' => 'bytes=0-15'])->assertNotFound();
        $this->get('/api/v1/media/'.$id.'/content')->assertNotFound();
    }

    public function test_real_duration_bounds_and_forged_content_are_rejected_without_assets(): void
    {
        foreach ([0.2, 60.5] as $duration) {
            $this->post('/api/v1/media', ['media_type' => 'audio', 'duration_ms' => 2000, 'file' => $this->recording($duration)], ['Accept' => 'application/json'])
                ->assertUnprocessable();
        }
        $this->post('/api/v1/media', ['media_type' => 'audio', 'file' => UploadedFile::fake()->createWithContent('fake.m4a', 'invalid media')], ['Accept' => 'application/json'])
            ->assertUnprocessable();
        $this->post('/api/v1/media', ['media_type' => 'audio', 'file' => UploadedFile::fake()->create('large.m4a', 5121, 'audio/mp4')], ['Accept' => 'application/json'])
            ->assertUnprocessable();
        $this->assertSame(0, MediaAsset::count());
    }

    public function test_truncated_recording_must_decode_and_unavailable_verifier_rejects(): void
    {
        $file = $this->recording(2);
        $bytes = file_get_contents($file->getRealPath());
        file_put_contents($file->getRealPath(), substr($bytes, 0, 128));
        $this->post('/api/v1/media', ['media_type' => 'audio', 'file' => $file], ['Accept' => 'application/json'])->assertUnprocessable();
        config(['media.video.ffprobe_path' => '/missing/ffprobe']);
        $this->post('/api/v1/media', ['media_type' => 'audio', 'file' => $this->recording(2)], ['Accept' => 'application/json'])->assertUnprocessable();
        $this->assertSame(0, MediaAsset::count());
    }
}
