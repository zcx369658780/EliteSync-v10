<?php

namespace Tests\Feature;

use App\Models\DatingMatch;
use App\Models\RtcSession;
use App\Models\User;
use App\Services\LiveConsentService;
use App\Services\RtcAuthorityService;
use Illuminate\Database\QueryException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

final class V1009RtcAuthorityTest extends TestCase
{
    use RefreshDatabase;

    private User $a;

    private User $b;

    protected function setUp(): void
    {
        parent::setUp();
        config(['restoration.enabled' => true, 'rtc_guard.enabled' => true, 'rtc_guard.gateway_secret' => str_repeat('g', 40),
            'livekit.enabled' => true, 'livekit.api_key' => 'test', 'livekit.api_secret' => str_repeat('s', 40), 'livekit.url' => 'http://127.0.0.1:7884']);
        $this->a = User::factory()->create(['phone' => '19900000921', 'disabled' => false, 'is_synthetic' => false]);
        $this->b = User::factory()->create(['phone' => '19900000922', 'disabled' => false, 'is_synthetic' => false]);
        DatingMatch::create(['week_tag' => 'v1009', 'user_a' => $this->a->id, 'user_b' => $this->b->id, 'drop_released' => true]);
        Sanctum::actingAs($this->a);
    }

    private function active(): void
    {
        $s = app(LiveConsentService::class);
        $s->transition($this->a->id, $this->b->id, 'connection', 'request', 0);
        $s->transition($this->b->id, $this->a->id, 'connection', 'accept', 1);
        $s->transition($this->a->id, $this->b->id, 'consent', 'request', 0);
        $s->transition($this->b->id, $this->a->id, 'consent', 'accept', 1);
    }

    private function create(): int
    {
        Sanctum::actingAs($this->a);

        return $this->postJson('/api/v1/rtc/calls', ['peer_user_id' => $this->b->id, 'mode' => 'video'])->assertOk()->json('session.id');
    }

    private function accept(int $id): void
    {
        Sanctum::actingAs($this->b);
        $this->postJson('/api/v1/rtc/calls/'.$id.'/accept')->assertOk();
    }

    public function test_match_alone_does_not_grant_rtc(): void
    {
        $this->postJson('/api/v1/rtc/calls', ['peer_user_id' => $this->b->id])->assertForbidden();
    }

    public function test_accepting_a_still_valid_invitation_grants_a_fresh_connection_deadline(): void
    {
        $this->travelTo(now()->startOfSecond());
        $this->active();
        $id = $this->create();
        $invitationDeadline = RtcSession::findOrFail($id)->expires_at->copy();
        $this->travel(29)->seconds();

        $this->accept($id);
        $call = RtcSession::findOrFail($id);
        $this->assertSame('connecting', $call->status);
        $this->assertTrue($call->accepted_at->equalTo(now()));
        $this->assertTrue($call->expires_at->equalTo(now()->addSeconds(30)));
        $this->assertTrue($call->expires_at->greaterThan($invitationDeadline));

        // Keep the caller present independently of the invitation deadline.
        Sanctum::actingAs($this->a);
        $this->postJson('/api/v1/rtc/calls/'.$id.'/heartbeat')->assertOk();
        $this->travel(29)->seconds();
        $this->assertTrue(now()->greaterThan($invitationDeadline));
        $this->postJson('/api/v1/rtc/calls/'.$id.'/connect')->assertOk();
        $this->assertSame('in_call', $call->fresh()->status);
    }

    public function test_an_expired_invitation_cannot_be_accepted_or_revived(): void
    {
        $this->travelTo(now()->startOfSecond());
        $this->active();
        $id = $this->create();
        $invitationDeadline = RtcSession::findOrFail($id)->expires_at->copy();
        $this->travel(31)->seconds();
        Sanctum::actingAs($this->b);

        $this->postJson('/api/v1/rtc/calls/'.$id.'/accept')->assertStatus(409);
        $this->postJson('/api/v1/rtc/calls/'.$id.'/connect')->assertStatus(409);
        $this->getJson('/api/v1/rtc/calls/'.$id.'/livekit')->assertNotFound();
        $call = RtcSession::findOrFail($id);
        $this->assertNull($call->accepted_at);
        $this->assertNull($call->accepted_by_user_id);
        $this->assertTrue($call->expires_at->equalTo($invitationDeadline));
        $this->assertNotContains($call->status, ['connecting', 'in_call']);
        $this->assertFalse($call->events()->where('event_name', 'accepted')->exists());
    }

    public function test_independent_accept_and_current_revisions_guard_join_and_reconnect(): void
    {
        $this->active();
        $id = $this->create();
        $this->getJson('/api/v1/rtc/calls/'.$id.'/livekit')->assertNotFound();
        $this->accept($id);
        $info = $this->getJson('/api/v1/rtc/calls/'.$id.'/livekit')->assertOk()->json('livekit');
        $call = RtcSession::findOrFail($id);
        $this->withHeader('X-RTC-Gateway', str_repeat('g', 40))->postJson('/api/v1/rtc-guard/authorize', ['room' => $info['room_name'], 'identity' => $info['identity']])->assertOk();
        app(LiveConsentService::class)->transition($this->b->id, $this->a->id, 'consent', 'revoke', 2);
        $this->getJson('/api/v1/rtc/calls/'.$id.'/livekit')->assertNotFound();
        $this->postJson('/api/v1/rtc/calls/'.$id.'/heartbeat')->assertNotFound();
        $this->postJson('/api/v1/rtc-guard/authorize', ['room' => $info['room_name'], 'identity' => $info['identity']])->assertNotFound();
        $this->postJson('/api/v1/rtc-guard/sweep')->assertOk()->assertJsonPath('allowed_rooms', []);
        $this->assertSame('ended', $call->fresh()->status);
    }

    public function test_restrict_disabled_and_unknown_environment_fail_closed(): void
    {
        $this->active();
        $id = $this->create();
        $this->accept($id);
        $this->b->update(['moderation_status' => 'restricted']);
        $this->getJson('/api/v1/rtc/calls/'.$id.'/livekit')->assertNotFound();
        $this->b->update(['moderation_status' => 'active', 'disabled' => true]);
        $this->getJson('/api/v1/rtc/calls/'.$id.'/livekit')->assertForbidden();
        $this->b->update(['disabled' => false]);
        config(['rtc_guard.enabled' => false]);
        $this->postJson('/api/v1/rtc/calls', ['peer_user_id' => $this->a->id])->assertNotFound();
    }

    public function test_terminal_room_epoch_is_never_reused(): void
    {
        $this->active();
        $id = $this->create();
        $this->accept($id);
        $first = $this->getJson('/api/v1/rtc/calls/'.$id.'/livekit')->assertOk()->json('livekit');
        $this->postJson('/api/v1/rtc/calls/'.$id.'/end')->assertOk();
        $this->getJson('/api/v1/rtc/calls/'.$id.'/livekit')->assertNotFound();
        $next = $this->create();
        $this->accept($next);
        $second = $this->getJson('/api/v1/rtc/calls/'.$next.'/livekit')->assertOk()->json('livekit');
        $this->assertNotSame($first['room_name'], $second['room_name']);
        $this->assertNotSame($first['identity'], $second['identity']);
        $this->withHeader('X-RTC-Gateway', str_repeat('g', 40))->postJson('/api/v1/rtc-guard/authorize', ['room' => $first['room_name'], 'identity' => $second['identity']])->assertNotFound();
    }

    public function test_old_sweep_snapshot_cannot_overwrite_committed_current_heartbeat(): void
    {
        $this->active();
        $id = $this->create();
        $this->accept($id);
        $this->postJson('/api/v1/rtc/calls/'.$id.'/connect')->assertOk();
        RtcSession::whereKey($id)->update(['initiator_last_seen_at' => now()->subSeconds(31), 'peer_last_seen_at' => now()->subSeconds(31)]);
        $oldSnapshot = RtcSession::findOrFail($id);
        RtcSession::whereKey($id)->update(['initiator_last_seen_at' => now(), 'peer_last_seen_at' => now()]);
        $this->assertTrue(app(RtcAuthorityService::class)->authorized($oldSnapshot, null, true));
        $this->assertSame('in_call', $oldSnapshot->fresh()->status);
        RtcSession::whereKey($id)->update(['initiator_last_seen_at' => now()->subSeconds(31), 'peer_last_seen_at' => now()->subSeconds(31)]);
        $this->getJson('/api/v1/rtc/calls/'.$id.'/livekit')->assertNotFound();
    }

    public function test_expired_busy_attempt_does_not_invalidate_an_active_call(): void
    {
        $this->travelTo(now()->startOfSecond());
        $this->active();
        $id = $this->create();
        $this->accept($id);
        $this->postJson('/api/v1/rtc/calls/'.$id.'/connect')->assertOk();
        $room = RtcSession::findOrFail($id)->room_key;
        $busyId = $this->create();
        $busy = RtcSession::findOrFail($busyId);
        $this->assertSame('busy', $busy->status);
        $this->assertNotSame($room, $busy->room_key);

        // Both participants remain present while the separate busy record expires.
        for ($i = 0; $i < 4; $i++) {
            $this->travel(16)->seconds();
            foreach ([$this->a, $this->b] as $user) {
                Sanctum::actingAs($user);
                $this->postJson('/api/v1/rtc/calls/'.$id.'/heartbeat')->assertOk();
            }
        }
        $this->assertTrue($busy->expires_at->isPast());
        $this->withHeader('X-RTC-Gateway', str_repeat('g', 40))
            ->postJson('/api/v1/rtc-guard/sweep')->assertOk()
            ->assertJsonPath('allowed_rooms', [$room]);
        $this->assertSame('in_call', RtcSession::findOrFail($id)->status);
        $this->assertFalse(RtcSession::findOrFail($id)->events()->where('event_name', 'authority_invalidated')->exists());
        $this->assertSame('busy', $busy->fresh()->status);
        $this->getJson('/api/v1/rtc/calls/'.$busyId.'/livekit')->assertNotFound();
        $this->getJson('/api/v1/rtc/calls/'.$id.'/livekit')->assertOk();
    }

    public function test_authority_exception_propagates_with_only_safe_diagnostic_fields(): void
    {
        $call = new RtcSession;
        $call->id = 123;
        DB::shouldReceive('transaction')->once()->andThrow(new \RuntimeException('private SQL and bearer must never be logged', 1213));
        Log::shouldReceive('warning')->once()->with('rtc_authority_denied', [
            'call_id' => 123, 'reason' => 'exception', 'exception_class' => \RuntimeException::class, 'exception_code' => 1213,
        ]);
        $this->expectException(\RuntimeException::class);
        app(RtcAuthorityService::class)->authorized($call);
    }

    public function test_database_denial_records_safe_sqlstate_and_driver_code_without_sql(): void
    {
        $call = new RtcSession;
        $call->id = 124;
        $pdo = new \PDOException('private driver message');
        $pdo->errorInfo = ['40001', 1213, 'private deadlock SQL'];
        $error = new QueryException('mysql', 'private SQL', ['private binding'], $pdo);
        DB::shouldReceive('transaction')->once()->andThrow($error);
        Log::shouldReceive('warning')->once()->with('rtc_authority_denied', [
            'call_id' => 124, 'reason' => 'exception', 'exception_class' => get_class($error), 'exception_code' => 0,
            'sqlstate' => '40001', 'driver_code' => 1213,
        ]);
        $this->expectException(get_class($error));
        app(RtcAuthorityService::class)->authorized($call);
    }

    public function test_logging_failure_cannot_change_an_authority_denial(): void
    {
        $call = new RtcSession;
        $call->id = 125;
        DB::shouldReceive('transaction')->once()->andThrow(new \RuntimeException('not logged'));
        Log::shouldReceive('warning')->once()->andThrow(new \RuntimeException('log unavailable'));
        $this->expectException(\RuntimeException::class);
        $this->expectExceptionMessage('not logged');
        app(RtcAuthorityService::class)->authorized($call);
    }

    public function test_sweep_check_error_does_not_permanently_invalidate_active_call_or_publish_partial_allowlist(): void
    {
        $this->active();
        $id = $this->create();
        $this->accept($id);
        $this->postJson('/api/v1/rtc/calls/'.$id.'/connect')->assertOk();
        $other = RtcSession::findOrFail($id)->replicate();
        $other->call_key = (string) Str::uuid();
        $other->room_key = 'rtc-'.Str::uuid();
        $other->save();
        $inject = true;
        $reads = 0;
        DB::connection()->beforeExecuting(function ($sql) use (&$inject, &$reads) {
            if ($inject && str_contains($sql, 'rtc_sessions') && str_contains($sql, 'limit 1') && ++$reads === 2) {
                $inject = false;
                throw new \RuntimeException('injected authority read failure');
            }
        });
        $response = $this->withHeader('X-RTC-Gateway', str_repeat('g', 40))->postJson('/api/v1/rtc-guard/sweep');
        $inject = false;
        $response->assertStatus(503)->assertExactJson(['message' => 'RTC authority unavailable']);
        $this->assertSame(2, $reads); // One room was allowed before the second check failed.
        $this->assertArrayNotHasKey('allowed_rooms',$response->json());
        $call = RtcSession::findOrFail($id);
        $this->assertSame('in_call',$call->status);
        $this->assertFalse($call->events()->where('event_name','authority_invalidated')->exists());
    }
}
