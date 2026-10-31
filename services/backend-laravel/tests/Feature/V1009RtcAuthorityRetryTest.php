<?php
namespace Tests\Feature;

use App\Models\DatingMatch;
use App\Models\RtcSession;
use App\Models\User;
use App\Services\LiveConsentService;
use App\Services\RtcAuthorityService;
use App\Services\RtcSessionService;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;
use Laravel\Sanctum\Sanctum;

final class V1009RtcAuthorityRetryTest extends TestCase
{
    use \Tests\Support\CreatesAcceptedMainMatch;
    // No wrapping test transaction: exercise Laravel's real outermost retry.
    protected function setUp(): void
    {
        parent::setUp();
        // Project migrations deliberately reject down(); destroy only this
        // ephemeral in-memory schema by discarding the test application.
        $this->assertSame('testing',app()->environment());
        $this->assertSame('sqlite',DB::connection()->getDriverName());
        $this->assertSame(':memory:',DB::connection()->getDatabaseName());
        $this->artisan('migrate:fresh',['--force'=>true])->assertExitCode(0);
    }

    private function activeCall(): RtcSession
    {
        config(['restoration.enabled'=>true,'rtc_guard.enabled'=>true]);
        $a=User::factory()->create(['phone'=>'19900000931','disabled'=>false,'is_synthetic'=>false]);
        $b=User::factory()->create(['phone'=>'19900000932','disabled'=>false,'is_synthetic'=>false]);
        $this->createAcceptedMatchContext($a, $b);
        $consent=app(LiveConsentService::class);
        foreach ([[$a,$b,'connection','request',0],[$b,$a,'connection','accept',1],
            [$a,$b,'consent','request',0],[$b,$a,'consent','accept',1]] as [$actor,$peer,$kind,$action,$revision]) {
            $consent->transition($actor->id,$peer->id,$kind,$action,$revision);
        }
        $service=app(RtcSessionService::class);
        $call=$service->createCall($a->id,$b->id);
        $call=$service->acceptCall($call,$b->id);
        return $service->connectCall($call,$a->id);
    }

    public function test_outermost_authority_check_retries_deadlock_then_reads_current_call(): void
    {
        $call=$this->activeCall();$attempts=0;
        $this->assertSame(0,DB::transactionLevel());
        DB::connection()->beforeExecuting(function ($sql) use (&$attempts) {
            if (str_contains($sql,'rtc_sessions') && str_contains($sql,'limit 1') && ++$attempts<=2) {
                throw new \PDOException('Deadlock found when trying to get lock');
            }
        });
        $this->assertTrue(app(RtcAuthorityService::class)->authorized($call,null,true));
        $this->assertSame(3,$attempts);
        $this->assertSame('in_call',$call->status);
        $this->assertSame(0,DB::transactionLevel());
    }

    public function test_deadlock_budget_exhaustion_does_not_return_a_false_revocation(): void
    {
        $call=$this->activeCall();$attempts=0;
        DB::connection()->beforeExecuting(function ($sql) use (&$attempts) {
            if (str_contains($sql,'rtc_sessions') && str_contains($sql,'limit 1')) {
                $attempts++;
                throw new \PDOException('Deadlock found when trying to get lock');
            }
        });
        try {
            app(RtcAuthorityService::class)->authorized($call,null,true);
            $this->fail('Exhausted authority checks must propagate uncertainty');
        } catch (\PDOException) {
            $this->assertSame(3,$attempts);
            $this->assertSame(0,DB::transactionLevel());
        }
    }

    public function test_nonconcurrency_error_is_not_retried(): void
    {
        $call=$this->activeCall();$attempts=0;
        DB::connection()->beforeExecuting(function ($sql) use (&$attempts) {
            if (str_contains($sql,'rtc_sessions') && str_contains($sql,'limit 1')) {
                $attempts++;
                throw new \RuntimeException('injected unavailable database');
            }
        });
        try {
            app(RtcAuthorityService::class)->authorized($call,null,true);
            $this->fail('Nonconcurrency errors must propagate');
        } catch (\RuntimeException) {
            $this->assertSame(1,$attempts);
            $this->assertSame(0,DB::transactionLevel());
        }
    }

    public function test_http_deadlock_retries_the_whole_request_before_success(): void
    {
        $call=$this->activeCall();$attempts=0;
        Sanctum::actingAs(User::findOrFail($call->initiator_user_id));
        config(['app.debug'=>true]);
        DB::connection()->beforeExecuting(function ($sql) use (&$attempts) {
            if (DB::transactionLevel()===1 && str_contains($sql,'rtc_sessions') && str_contains($sql,'limit 1') && ++$attempts<=2) {
                throw new \Illuminate\Database\QueryException('sqlite','private SQL',['private binding'],
                    new \PDOException('Deadlock found when trying to get lock'));
            }
        });
        $this->getJson('/api/v1/rtc/calls/'.$call->id)->assertOk();
        $this->assertSame(3,$attempts);
        $this->assertSame(0,DB::transactionLevel());
    }

    public function test_http_exhausted_deadlock_returns_generic_503_even_with_debug_enabled(): void
    {
        $call=$this->activeCall();$attempts=0;
        Sanctum::actingAs(User::findOrFail($call->initiator_user_id));
        config(['app.debug'=>true]);
        DB::connection()->beforeExecuting(function ($sql) use (&$attempts) {
            if (str_contains($sql,'rtc_sessions') && str_contains($sql,'limit 1')) {
                $attempts++;
                throw new \Illuminate\Database\QueryException('sqlite','private SQL',['private binding'],
                    new \PDOException('Deadlock found when trying to get lock'));
            }
        });
        $this->getJson('/api/v1/rtc/calls/'.$call->id)->assertStatus(503)
            ->assertExactJson(['message'=>'RTC authority unavailable']);
        $this->assertSame(3,$attempts);
        $this->assertSame(0,DB::transactionLevel());
    }
    public function test_http_raw_pdo_error_rolls_back_partial_write_and_returns_generic_503(): void
    {
        $call=$this->activeCall();$attempts=0;
        Sanctum::actingAs(User::findOrFail($call->initiator_user_id));
        config(['app.debug'=>true]);
        \Illuminate\Support\Facades\Route::middleware(['api','auth:sanctum',\App\Http\Middleware\RtcTransaction::class])
            ->post('/api/v1009-test/raw-pdo',function () use ($call,&$attempts) {
                $attempts++;
                DB::table('rtc_sessions')->where('id',$call->id)->update(['failure_code'=>'raw_pdo_partial']);
                throw new \PDOException('private unavailable driver diagnostic');
            });
        $response=$this->postJson('/api/v1009-test/raw-pdo');
        $this->assertNull($call->fresh()->failure_code,'Rendered database error must not commit earlier writes');
        $response->assertStatus(503)->assertExactJson(['message'=>'RTC authority unavailable']);
        $this->assertSame(1,$attempts);
        $this->assertSame(0,DB::transactionLevel());
    }

    public function test_http_raw_pdo_begin_failure_returns_generic_503_without_retry(): void
    {
        $call=$this->activeCall();$attempts=0;
        Sanctum::actingAs(User::findOrFail($call->initiator_user_id));
        config(['app.debug'=>true]);
        DB::connection()->beforeStartingTransaction(function () use (&$attempts) {
            $attempts++;
            throw new \PDOException('private begin unavailable');
        });
        $this->getJson('/api/v1/rtc/calls/'.$call->id)->assertStatus(503)
            ->assertExactJson(['message'=>'RTC authority unavailable']);
        $this->assertSame(1,$attempts);
        $this->assertSame(0,DB::transactionLevel());
    }

}
