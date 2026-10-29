<?php

namespace Tests\Feature;

use App\Services\ConversationAtomicSendService;
use Illuminate\Foundation\Application;
use Illuminate\Validation\Factory;
use Tests\TestCase;

/** Test source only in the migration task; requires separately qualified Laravel 12. */
final class Laravel12CompatibilityTest extends TestCase
{
    public function test_framework_and_private_storage_remain_explicit(): void
    {
        $this->assertSame(12, (int) explode('.', Application::VERSION)[0]);
        $this->assertSame(storage_path('app/private'), config('filesystems.disks.local.root'));
        foreach (['v1007', 'v1009', 'v1011_relationship'] as $disk) {
            $this->assertSame('local', config("filesystems.disks.$disk.driver"));
            $this->assertTrue(config("filesystems.disks.$disk.throw"));
        }
    }

    public function test_required_message_dependencies_are_resolved(): void
    {
        // Laravel 12 respects nullable constructor defaults. Security services must
        // remain mandatory dependencies, without nullable/default fallbacks.
        $constructor = new \ReflectionMethod(ConversationAtomicSendService::class, '__construct');
        foreach ($constructor->getParameters() as $parameter) {
            $this->assertFalse($parameter->isDefaultValueAvailable());
            $this->assertFalse($parameter->allowsNull());
        }
        $this->assertInstanceOf(ConversationAtomicSendService::class, app(ConversationAtomicSendService::class));
    }

    public function test_svg_does_not_gain_image_permission_on_upgrade(): void
    {
        $file = \Illuminate\Http\UploadedFile::fake()->createWithContent('private.svg', '<svg xmlns="http://www.w3.org/2000/svg"/>');
        $validator = app(Factory::class)->make(['image' => $file], ['image' => ['required', 'image']]);
        $this->assertTrue($validator->fails());
    }
}
