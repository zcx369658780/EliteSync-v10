<?php

namespace Tests\Feature;

use App\Models\DatingMatch;
use App\Models\MediaAsset;
use App\Models\User;
use App\Services\LiveConsentService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

final class V1007PrivateMediaTest extends TestCase
{
    use RefreshDatabase;

    private User $sender;

    private User $recipient;

    private const PNG = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a2ioAAAAASUVORK5CYII=';

    protected function setUp(): void
    {
        parent::setUp();
        config(['restoration.enabled' => true, 'media.disk' => 'v1007']);
        // Keep the real throttle middleware, with a distinct fixture identity/IP per test run.
        $identity = random_int(1000000, 2000000);
        $this->withServerVariables(['REMOTE_ADDR' => '127.'.random_int(1, 254).'.'.random_int(1, 254).'.'.random_int(1, 254)]);
        Storage::fake('v1007');
        $this->sender = User::factory()->create(['id' => $identity, 'phone' => '19900000751', 'disabled' => false, 'is_synthetic' => false]);
        $this->recipient = User::factory()->create(['phone' => '19900000752', 'disabled' => false, 'is_synthetic' => false]);
        // A bare legacy match is not a current accepted proposal; use an active friendship.
        \Illuminate\Support\Facades\DB::table('friendships')->insert(['user_a'=>min($this->sender->id,$this->recipient->id), 'user_b'=>max($this->sender->id,$this->recipient->id), 'state'=>'ACTIVE', 'revision'=>1, 'created_at'=>now(), 'updated_at'=>now()]);
        $service = app(LiveConsentService::class);
        $service->transition($this->sender->id, $this->recipient->id, 'connection', 'request', 0);
        $service->transition($this->recipient->id, $this->sender->id, 'connection', 'accept', 1);
        $service->transition($this->sender->id, $this->recipient->id, 'consent', 'request', 0);
        $service->transition($this->recipient->id, $this->sender->id, 'consent', 'accept', 1);
        Sanctum::actingAs($this->sender);
    }

    private function image(): UploadedFile
    {
        return UploadedFile::fake()->createWithContent('fixture.png', base64_decode(self::PNG));
    }

    private function upload(): MediaAsset
    {
        $response = $this->post('/api/v1/media', ['media_type' => 'image', 'file' => $this->image()], ['Accept' => 'application/json'])->assertOk();

        return MediaAsset::findOrFail($response->json('asset.id'));
    }

    public function test_private_attachment_download_requires_current_participant_consent(): void
    {
        $asset = $this->upload();
        $path = '/api/v1/media/'.$asset->id.'/content';
        $this->assertSame($path, parse_url($asset->public_url, PHP_URL_PATH));
        $sent = $this->postJson('/api/v1/messages', [
            'receiver_id' => $this->recipient->id, 'content' => 'private fixture', 'attachment_ids' => [$asset->id],
        ])->assertOk();
        $this->assertSame($path, parse_url($sent->json('message.attachments.0.media_asset.public_url'), PHP_URL_PATH));
        Sanctum::actingAs($this->recipient);
        $download = $this->get($path)->assertOk();
        $this->assertSame(base64_decode(self::PNG), file_get_contents($download->baseResponse->getFile()->getPathname()));
        $third = User::factory()->create(['phone' => '19900000753', 'disabled' => false]);
        Sanctum::actingAs($third);
        $this->get($path)->assertNotFound();
        auth('sanctum')->forgetUser();
        auth('web')->forgetUser();
        $this->app['auth']->forgetGuards();
        // Anonymous requests are rejected by the authenticated route before asset lookup.
        $this->get($path)->assertUnauthorized();
        app(LiveConsentService::class)->transition($this->recipient->id, $this->sender->id, 'consent', 'revoke', 2);
        Sanctum::actingAs($this->recipient);
        $this->get($path)->assertNotFound();
        $this->assertStringContainsString('private', $download->headers->get('Cache-Control'));
        $this->assertStringContainsString('no-store', $download->headers->get('Cache-Control'));
    }

    public function test_client_alias_or_overwrite_fields_are_rejected_with_and_without_file(): void
    {
        $asset = $this->upload();
        $before = $asset->getRawOriginal();
        $bytes = Storage::disk('v1007')->get($asset->storage_key);
        foreach (['storage_key' => $asset->storage_key, 'public_url' => $asset->public_url] as $field => $value) {
            foreach ([false, true] as $withFile) {
                $payload = ['media_type' => 'image', $field => $value];
                if ($withFile) {
                    $payload['file'] = $this->image();
                }
                $this->post('/api/v1/media', $payload, ['Accept' => 'application/json'])->assertUnprocessable();
                $this->assertSame($before, $asset->fresh()->getRawOriginal());
                $this->assertSame($bytes, Storage::disk('v1007')->get($asset->storage_key));
                $this->assertDatabaseCount('media_assets', 1);
            }
        }
    }

    public function test_public_disk_asset_cannot_be_injected_as_live_attachment(): void
    {
        Storage::fake('public');
        Storage::disk('public')->put('injected.png', base64_decode(self::PNG));
        $asset = MediaAsset::create([
            'owner_user_id' => $this->sender->id, 'media_type' => 'image', 'storage_provider' => 'local',
            'storage_disk' => 'public', 'storage_key' => 'injected.png', 'status' => 'uploaded',
            'mime_type' => 'image/png', 'size_bytes' => strlen(base64_decode(self::PNG)),
        ]);
        $this->postJson('/api/v1/messages', [
            'receiver_id' => $this->recipient->id, 'content' => 'denied', 'attachment_ids' => [$asset->id],
        ])->assertUnprocessable();
        $this->assertDatabaseCount('chat_messages', 0);
    }

    public function test_upload_fails_closed_without_private_disk_configuration(): void
    {
        config(['media.disk' => 'public']);
        $this->post('/api/v1/media', ['media_type' => 'image', 'file' => $this->image()], ['Accept' => 'application/json'])->assertUnprocessable();
        $this->assertDatabaseCount('media_assets', 0);
    }
}
