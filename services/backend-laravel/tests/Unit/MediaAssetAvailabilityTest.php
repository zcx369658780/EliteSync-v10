<?php

namespace Tests\Unit;

use App\Models\MediaAsset;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class MediaAssetAvailabilityTest extends TestCase
{
    public function test_available_ready_object_preserves_usable_url(): void
    {
        Storage::fake('public');
        Storage::disk('public')->put('media/available.png', 'bytes');
        config(['app.url' => 'http://example.test']);

        $asset = new MediaAsset([
            'storage_disk' => 'public',
            'storage_key' => 'media/available.png',
            'status' => 'ready',
        ]);
        $asset->id = 42;

        $this->assertTrue($asset->isBackingObjectAvailable());
        $this->assertStringEndsWith('/api/v1/media/42/content', $asset->public_url);
    }

    public function test_storage_lookup_exception_fails_closed(): void
    {
        Storage::shouldReceive('disk')->with('broken')->andThrow(new \RuntimeException('lookup failed'));

        $asset = new MediaAsset([
            'storage_disk' => 'broken',
            'storage_key' => 'media/object.png',
            'status' => 'ready',
            'public_url' => 'https://cdn.example.test/media/object.png',
        ]);
        $asset->syncOriginal();

        $this->assertFalse($asset->isBackingObjectAvailable());
        $this->assertSame('', $asset->public_url);
        $this->assertFalse($asset->isDirty());
    }
}
