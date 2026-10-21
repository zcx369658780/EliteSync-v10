<?php
namespace Tests\Feature;

use App\Models\User;
use App\Models\UserBlock;
use App\Services\LiveConsentService;
use App\Services\Accounts\DeviceSessions;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Tests\TestCase;

class V1015MessagingTest extends TestCase
{
    use RefreshDatabase;
    private function pair(): array
    {
        config(['restoration.enabled' => true]);
        $a=User::factory()->create(['phone'=>'19900001541','disabled'=>false,'is_synthetic'=>false]);
        $b=User::factory()->create(['phone'=>'19900001542','disabled'=>false,'is_synthetic'=>false]);
        DB::table('friendships')->insert(['user_a'=>$a->id,'user_b'=>$b->id,'state'=>'ACTIVE','revision'=>1,'created_at'=>now(),'updated_at'=>now()]);
        $s=app(LiveConsentService::class);
        foreach ([[$a,$b,'connection','request',0],[$b,$a,'connection','accept',1],[$a,$b,'consent','request',0],[$b,$a,'consent','accept',1]] as [$actor,$peer,$kind,$action,$revision]) $s->transition($actor->id,$peer->id,$kind,$action,$revision);
        return [$a,$b];
    }
    private function token(User $user): string
    {
        $this->app['auth']->forgetGuards();
        return app(DeviceSessions::class)->issue($user,'V1015',true)['access_token'];
    }
    public function test_replay_is_exactly_once_conflicting_payload_rejected_and_readback_retains_idempotency_identity(): void
    {
        [$a,$b]=$this->pair(); $ta=$this->token($a);
        $body=['receiver_id'=>$b->id,'content'=>'fictional body','client_message_id'=>(string)Str::uuid()];
        $first=$this->withToken($ta)->postJson('/api/v1/messages',$body)->assertOk()->json();
        $this->withToken($ta)->postJson('/api/v1/messages',$body)->assertOk()->assertJsonPath('id',$first['id'])->assertJsonPath('idempotent_replay',true);
        $this->withToken($ta)->postJson('/api/v1/messages',array_replace($body,['content'=>'changed']))->assertConflict();
        $this->assertDatabaseCount('chat_messages',1); $this->assertDatabaseCount('notifications',1);
        $tb=$this->token($b);
        $this->withToken($tb)->getJson('/api/v1/messages?peer_id='.$a->id)->assertOk()->assertJsonPath('items.0.client_message_id',$body['client_message_id']);
    }
    public function test_committed_block_denies_even_same_key_replay_and_private_reader_without_new_side_effects(): void
    {
        [$a,$b]=$this->pair(); $ta=$this->token($a);
        $body=['receiver_id'=>$b->id,'content'=>'fictional body','client_message_id'=>(string)Str::uuid()];
        $this->withToken($ta)->postJson('/api/v1/messages',$body)->assertOk();
        UserBlock::create(['blocker_id'=>$b->id,'blocked_user_id'=>$a->id]);
        $this->withToken($ta)->postJson('/api/v1/messages',$body)->assertNotFound();
        $this->withToken($ta)->getJson('/api/v1/messages?peer_id='.$b->id)->assertNotFound();
        $this->assertDatabaseCount('chat_messages',1); $this->assertDatabaseCount('notifications',1);
    }
}
