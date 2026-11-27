<?php

namespace Tests\Feature;

use App\Models\MediaAsset;
use App\Models\StatusPost;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Tests\TestCase;

final class PrivateImageAuditTest extends TestCase
{
    use RefreshDatabase;

    public function test_reports_rows_and_files_without_rewriting_either(): void
    {
        $owner = User::factory()->create(['phone' => (string) Str::uuid()]);
        $disk = Storage::fake('v1011_relationship');
        config(['filesystems.disks.v1011_relationship.root' => $disk->path('')]);

        $stored = [];
        foreach (['ready', 'processing', 'failed'] as $state) {
            $upload = (string) Str::uuid();
            $key = "private-image-retry/$owner->id/".hash('sha256', $upload);
            $asset = MediaAsset::create([
                'owner_user_id' => $owner->id, 'client_upload_id' => $upload,
                'media_type' => 'image', 'storage_provider' => 'local',
                'storage_disk' => 'v1011_relationship', 'storage_key' => $key,
                'status' => $state, 'size_bytes' => 4, 'sha256' => hash('sha256', 'data'),
            ]);
            if ($state === 'ready') {
                $disk->put($key, 'data');
            }
            $stored[$state] = $asset;
        }
        $rolledBack = "private-image-retry/$owner->id/".hash('sha256', 'rolled back');
        $pending = $rolledBack.'.pending';
        $disk->put($rolledBack, 'orphan');
        $disk->put($pending, 'unfinalized');
        $inProgress = $stored['processing']->storage_key.'.pending';
        $disk->put($inProgress, 'partial');
        StatusPost::create(['author_user_id' => $owner->id, 'title' => 'Sample', 'body' => 'Sample',
            'cover_media_asset_id' => $stored['ready']->id, 'visibility' => 'private']);

        $this->assertSame(0, Artisan::call('app:media:audit-private-images', ['disk' => 'v1011_relationship']));
        $rows = collect(explode("\n", trim(Artisan::output())))
            ->map(fn ($line) => json_decode($line, true, 512, JSON_THROW_ON_ERROR))->keyBy('storage_key');
        $ready = $rows[$stored['ready']->storage_key];
        $this->assertSame('COMPLETED', $ready['lifecycle']);
        $this->assertSame($owner->id, $ready['owner_id']);
        $this->assertSame($stored['ready']->client_upload_id, $ready['upload_id']);
        $this->assertSame(hash('sha256', 'data'), $ready['actual_sha256']);
        $this->assertFalse($ready['candidate_without_business_link']);
        $this->assertSame('IN_PROGRESS', $rows[$stored['processing']->storage_key]['lifecycle']);
        $this->assertFalse($rows[$stored['processing']->storage_key]['file_present']);
        $this->assertSame('FAILED_OR_BLOCKED', $rows[$stored['failed']->storage_key]['lifecycle']);
        $this->assertSame('UNREGISTERED_FINAL_FILE', $rows[$rolledBack]['lifecycle']);
        $this->assertSame('UNREGISTERED_PENDING_FILE', $rows[$pending]['lifecycle']);
        $this->assertNull($rows[$rolledBack]['upload_id']);
        $this->assertTrue($rows[$rolledBack]['candidate_without_business_link']);
        $this->assertSame('REGISTERED_PENDING_FILE', $rows[$inProgress]['lifecycle']);
        $this->assertSame($stored['processing']->client_upload_id, $rows[$inProgress]['upload_id']);
        $this->assertFalse($rows[$inProgress]['candidate_without_business_link']);
        $this->assertSame(6, $rows->count());
        $this->assertDatabaseCount('media_assets', 3);
        $disk->assertExists([$stored['ready']->storage_key, $rolledBack, $pending]);
    }

    public function test_rejects_disks_outside_the_private_image_scope(): void
    {
        $this->artisan('app:media:audit-private-images', ['disk' => 'public'])->assertFailed();
    }
}

