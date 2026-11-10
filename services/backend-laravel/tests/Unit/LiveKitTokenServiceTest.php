<?php

namespace Tests\Unit;

use App\Models\DatingMatch;
use App\Models\RtcSession;
use App\Models\User;
use App\Services\LiveKitTokenService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;
use Symfony\Component\HttpKernel\Exception\HttpException;

class LiveKitTokenServiceTest extends TestCase
{
    use RefreshDatabase;

    public function test_issue_join_info_returns_signed_payload_for_participant(): void
    {
        $service = new LiveKitTokenService();
        [$caller, $callee, $session] = $this->makeSession();

        config()->set('livekit.enabled', true);
        config()->set('livekit.url', 'wss://rtc.example.test');
        config()->set('livekit.api_key', 'test_key');
        config()->set('livekit.api_secret', 'test_secret');
        config()->set('livekit.ttl_seconds', 600);

        $payload = $service->issueJoinInfo($session, $caller);

        $this->assertSame('wss://rtc.example.test', $payload['url']);
        $this->assertSame('voice', $payload['mode']);
        $this->assertSame(app(\App\Services\RtcAuthorityService::class)->identity($session, $caller->id), $payload['identity']);
        $this->assertSame($session->room_key, $payload['room_name']);
        $this->assertNotEmpty($payload['token']);
        $this->assertSame('通话参与者', $payload['participant_name']);
    }

    public function test_issue_join_info_rejects_when_livekit_is_disabled(): void
    {
        $service = new LiveKitTokenService();
        [, , $session] = $this->makeSession();
        config()->set('livekit.enabled', false);

        $this->expectException(HttpException::class);

        $service->issueJoinInfo($session, User::firstOrFail());
    }

    private function makeSession(): array
    {
        $caller = User::create([
            'phone' => '13800004601',
            'name' => 'Caller',
            'password' => 'secret123',
        ]);
        $callee = User::create([
            'phone' => '13800004602',
            'name' => 'Callee',
            'password' => 'secret123',
        ]);

        DatingMatch::create([
            'week_tag' => now()->utc()->format('Y-\\WW'),
            'user_a' => $caller->id,
            'user_b' => $callee->id,
            'drop_released' => true,
        ]);

        config(['restoration.enabled'=>true,'rtc_guard.enabled'=>true]);
        $authority=app(\App\Services\LiveConsentService::class);
        $authority->transition($caller->id,$callee->id,'connection','request',0);
        $authority->transition($callee->id,$caller->id,'connection','accept',1);
        $authority->transition($caller->id,$callee->id,'consent','request',0);
        $authority->transition($callee->id,$caller->id,'consent','accept',1);
        $session=app(\App\Services\RtcSessionService::class)->createCall($caller->id,$callee->id);
        $session=app(\App\Services\RtcSessionService::class)->acceptCall($session,$callee->id);

        return [$caller, $callee, $session];
    }
}
