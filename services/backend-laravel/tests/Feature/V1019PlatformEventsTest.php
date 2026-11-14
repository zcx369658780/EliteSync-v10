<?php

namespace Tests\Feature;

use App\Models\User;
use App\Services\PlatformEventService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Tests\TestCase;

/** Isolated synthetic fixtures exercise boundaries, separate from ordinary product evidence. */
final class V1019PlatformEventsTest extends TestCase
{
    use RefreshDatabase;

    private User $admin;
    private PlatformEventService $events;

    protected function setUp(): void
    {
        parent::setUp();
        config(['restoration.enabled'=>true,'app.admin_phones'=>['19900001990']]);
        $this->admin=$this->person('19900001990',['role'=>'admin']);
        $this->events=app(PlatformEventService::class);
    }

    private function person(string $phone,array $extra=[]): User
    {
        return User::factory()->create($extra+['phone'=>$phone,'is_synthetic'=>true,'disabled'=>false,
            'account_status'=>'active','moderation_status'=>'normal']);
    }

    private function event(): string
    {
        $event=$this->events->create($this->admin->id,['title'=>'TEST_ONLY study','city'=>'TEST_ONLY city',
            'venue'=>'TEST_ONLY cafe','capacity'=>2,'start_at'=>now()->addDay(),'end_at'=>now()->addDays(2),
            'idempotency_key'=>(string)Str::uuid(),'reason'=>'TEST_ONLY fixture']);
        // Fixture approval isolates event lifecycle tests from the unchanged budget workflow.
        DB::table('platform_event_budgets')->where('event_id',$event['id'])->update(['state'=>'APPROVED_FOR_DEV_SIMULATION']);
        $this->adminAction($event['id'],'open');
        return $event['id'];
    }

    private function revision(string $id): int
    {
        return (int)DB::table('platform_events')->where('id',$id)->value('revision');
    }

    private function adminAction(string $id,string $action,array $extra=[]): array
    {
        return $this->events->adminAction($this->admin->id,$id,$extra+['action'=>$action,'revision'=>$this->revision($id),
            'idempotency_key'=>(string)Str::uuid(),'reason'=>'TEST_ONLY operation']);
    }

    private function action(User $user,string $id,string $action): array
    {
        return $this->events->action($user->id,$id,['action'=>$action,'revision'=>$this->revision($id),'idempotency_key'=>(string)Str::uuid()]);
    }

    public function test_development_classification_requires_current_admin_and_does_not_create_participation(): void
    {
        $user = $this->person('19900001998', ['is_synthetic' => false]);
        $form = ['user_id' => $user->id, 'reason' => 'Known fictional development account', 'confirm' => 1];
        $this->actingAs($user, 'web')->post('/admin/platform-events/development-participants', $form)->assertForbidden();
        \Illuminate\Support\Facades\Auth::guard('web')->logout();
        $this->admin->update(['password' => \Illuminate\Support\Facades\Hash::make('development-test-password')]);
        $this->post('/admin/login', ['phone' => $this->admin->phone, 'password' => 'development-test-password'])->assertRedirect();
        $this->withCookie(config('session.cookie'), session()->getId())->withCredentials();
        $this->post('/admin/platform-events/development-participants', $form)->assertRedirect('/admin/platform-events');
        $this->assertDatabaseHas('users', ['id' => $user->id, 'is_synthetic' => true]);
        $this->assertDatabaseHas('admin_operation_audits', ['action' => 'platform_event.development_participant', 'target_id' => (string) $user->id]);
        $this->assertDatabaseCount('platform_event_registrations', 0);
        $this->assertDatabaseCount('friendships', 0);
    }

    public function test_bounded_pages_keep_terminal_history_and_notifications_safe(): void
    {
        $user=$this->person('19900001991');
        $ids=[];
        for($i=0;$i<3;$i++){
            $id=$this->event();$ids[]=$id;
            $this->adminAction($id,'invite',['recipient_id'=>$user->id]);
        }
        $this->action($user,$ids[0],'cancel');
        $first=$this->events->listing($user->id,2);
        $this->assertTrue($first['meta']['has_more']);
        $second=$this->events->listing($user->id,2,$first['meta']['next_cursor']);
        $this->assertFalse($second['meta']['has_more']);
        $this->assertCount(3,[...$first['items'],...$first['history'],...$second['items'],...$second['history']]);
        $receipt=$this->events->notificationTarget($user->id,$ids[0]);
        $this->assertSame('CANCELLED_BY_USER',$receipt['registration_state']);
        $this->assertArrayNotHasKey('title',$receipt);
        $this->assertArrayNotHasKey('participants',$receipt);
        $this->assertSame([],$receipt['allowed_actions']);
        $this->actingAs($user, 'sanctum')->getJson('/api/v1/platform-events/'.$ids[0].'/result')->assertOk()
            ->assertJsonPath('registration_state', 'CANCELLED_BY_USER')->assertJsonMissingPath('title')->assertJsonPath('allowed_actions', []);
    }

    public function test_close_complete_cancel_and_revoke_notify_once_per_recipient_event(): void
    {
        $user=$this->person('19900001992');
        $id=$this->event();$this->adminAction($id,'invite',['recipient_id'=>$user->id]);
        $this->action($user,$id,'apply');
        foreach(['close','complete'] as $action){
            $this->adminAction($id,$action);
            $key='platform_event:'.$id.':'.$this->revision($id);
            $this->assertSame(1,DB::table('notifications')->where('user_id',$user->id)->where('source_event_key',$key)->count());
        }
        $other=$this->event();$this->adminAction($other,'invite',['recipient_id'=>$user->id]);
        $grant=DB::table('platform_event_registrations')->where('event_id',$other)->where('user_id',$user->id)->value('grant_id');
        $this->adminAction($other,'revoke',['grant_id'=>$grant]);
        $this->assertSame('CANCELLED_BY_ORGANIZER',$this->events->notificationTarget($user->id,$other)['registration_state']);
        $cancelled=$this->event();$this->adminAction($cancelled,'invite',['recipient_id'=>$user->id]);
        $this->adminAction($cancelled,'cancel');
        $this->assertSame('CANCELLED',$this->events->notificationTarget($user->id,$cancelled)['state']);
    }

    public function test_promotion_skips_ineligible_waiter_and_rejects_skipping_eligible_waiter(): void
    {
        $users=[];foreach(range(1,5) as $i)$users[]=$this->person('1990000180'.$i);
        $id=$this->event();
        foreach($users as $user){$this->adminAction($id,'invite',['recipient_id'=>$user->id]);$this->action($user,$id,'apply');}
        $this->action($users[0],$id,'cancel');
        $registration=fn(User $u)=>DB::table('platform_event_registrations')->where('event_id',$id)->where('user_id',$u->id)->first();
        try{$this->adminAction($id,'promote',['registration_id'=>$registration($users[4])->id]);$this->fail('must preserve eligible order');}
        catch(HttpException $e){$this->assertSame(409,$e->getStatusCode());}
        $users[2]->update(['moderation_status'=>'restricted']);
        $this->adminAction($id,'promote',['registration_id'=>$registration($users[3])->id]);
        $this->assertSame('CONFIRMED',$registration($users[3])->state);
        $this->assertSame('WAITLISTED',$registration($users[4])->state);
        $this->assertSame(2,DB::table('platform_event_registrations')->where('event_id',$id)->whereIn('state',['APPLIED','CONFIRMED'])->count());
    }

    public function test_web_candidates_are_bounded_safe_aliases(): void
    {
        foreach(range(1,22) as $i)$this->person('199000017'.str_pad((string)$i,2,'0',STR_PAD_LEFT));
        $page=$this->events->inviteCandidates($this->admin->id);
        $this->assertCount(20,$page['items']);$this->assertTrue($page['has_more']);
        foreach($page['items'] as $item)$this->assertSame(['id','label'],array_keys($item));
        $next=$this->events->inviteCandidates($this->admin->id,$page['next_cursor']);
        $this->assertCount(2,$next['items']);$this->assertFalse($next['has_more']);
    }
}
