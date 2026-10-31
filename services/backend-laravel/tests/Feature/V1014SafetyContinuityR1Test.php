<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Http\Middleware\PreventRequestForgery as ValidateCsrfToken;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Testing\TestResponse;
use Tests\TestCase;

/** Synthetic Feature coverage only; real MariaDB/APP/Web evidence is collected separately. */
final class V1014SafetyContinuityR1Test extends TestCase
{
    use RefreshDatabase;

    private const PASSWORD = 'TEST_ONLY-platform-password';

    private User $adminUser;

    /** @return array{User,User,User,User} */
    private function people(): array
    {
        config(['restoration.enabled' => true, 'app.admin_phones' => ['19900001400']]);
        $this->adminUser = User::factory()->create([
            'phone' => '19900001400', 'role' => 'admin', 'is_synthetic' => true,
            'disabled' => false, 'account_status' => 'active', 'moderation_status' => 'normal',
            'password' => Hash::make(self::PASSWORD),
        ]);
        $users = [];
        foreach (['A', 'B', 'C', 'D'] as $i => $name) {
            $users[] = User::factory()->create([
                'phone' => '1990000140'.($i + 1), 'name' => 'TEST_ONLY '.$name,
                'role' => 'user', 'is_synthetic' => true, 'disabled' => false,
                'account_status' => 'active', 'moderation_status' => 'normal',
            ]);
        }

        return $users;
    }

    private function loginAdmin(): void
    {
        $this->post('/admin/login', ['phone' => $this->adminUser->phone, 'password' => self::PASSWORD])
            ->assertRedirect(route('admin.users'));
        $this->assertDatabaseHas('platform_admin_sessions', ['user_id' => $this->adminUser->id, 'revoked_at' => null]);
        // Feature requests do not retain a browser cookie jar automatically, and
        // JSON requests omit cookies unless explicitly made with credentials.
        $this->withCookie(config('session.cookie'), session()->getId())->withCredentials();
    }

    private function createDraft(int $capacity = 2, array $extra = []): string
    {
        $before = DB::table('platform_events')->count();
        $data = array_merge([
            'title' => 'TEST_ONLY shared study', 'city' => 'TEST_ONLY city', 'venue' => 'TEST_ONLY cafe',
            'capacity' => $capacity, 'start_at' => now()->addHour()->toIso8601String(),
            'end_at' => now()->addHours(2)->toIso8601String(),
            'idempotency_key' => (string) Str::uuid(), 'reason' => 'TEST_ONLY synthetic draft creation', 'confirm' => true,
        ], $extra);
        $this->postJson('/admin/platform-events', $data)->assertRedirect('/admin/platform-events');
        $this->assertSame($before + 1, DB::table('platform_events')->count());

        return (string) DB::table('platform_event_commands')->where('actor_id', $this->adminUser->id)
            ->where('idempotency_key', $data['idempotency_key'])->value('event_id');
    }

    private function event(string $id): object
    {
        $event = DB::table('platform_events')->where('id', $id)->first();
        $this->assertNotNull($event);

        return $event;
    }

    private function adminAction(string $id, string $action, array $extra = []): TestResponse
    {
        return $this->postJson('/admin/platform-events/'.$id.'/actions', array_merge([
            'action' => $action, 'revision' => (int) $this->event($id)->revision,
            'idempotency_key' => (string) Str::uuid(), 'reason' => 'TEST_ONLY explicit event operation', 'confirm' => true,
        ], $extra));
    }

    private function openEvent(int $capacity = 2,array $extra=[]): string
    {
        $id = $this->createDraft($capacity,$extra);
        foreach (['DRAFT', 'REVIEWED', 'APPROVED_FOR_DEV_SIMULATION'] as $state) {
            $budget = DB::table('platform_event_budgets')->where('event_id', $id)->first();
            $this->adminAction($id, 'budget', [
                'budget_revision' => (int) $budget->revision, 'budget_state' => $state,
                'venue_cost' => 1000, 'materials_cost' => 250, 'travel_cost' => 0,
            ])->assertRedirect('/admin/platform-events');
        }
        $this->adminAction($id, 'open')->assertRedirect('/admin/platform-events');
        $this->assertSame('OPEN', $this->event($id)->state);

        return $id;
    }

    private function invite(string $id, User ...$users): void
    {
        foreach ($users as $user) {
            $this->adminAction($id, 'invite', ['recipient_id' => $user->id])->assertRedirect('/admin/platform-events');
        }
    }

    private function userAction(User $user, string $id, string $action, array $extra = []): TestResponse
    {
        return $this->actingAs($user, 'sanctum')->postJson('/api/v1/platform-events/'.$id.'/actions', array_merge([
            'action' => $action, 'revision' => (int) $this->event($id)->revision,
            'idempotency_key' => (string) Str::uuid(),
        ], $extra));
    }

    private function registration(string $eventId, User $user): object
    {
        $row = DB::table('platform_event_registrations')->where('event_id', $eventId)->where('user_id', $user->id)->first();
        $this->assertNotNull($row);

        return $row;
    }

    private function makeReport(User $reporter, User $subject, string $eventId, string $category = 'CONDUCT'): array
    {
        return $this->actingAs($reporter, 'sanctum')->postJson('/api/v1/platform-events/'.$eventId.'/reports', [
            'target_registration_id' => $this->registration($eventId, $subject)->id,
            'category' => $category, 'statement' => 'TEST_ONLY synthetic claimant statement for manual investigation',
            'idempotency_key' => (string) Str::uuid(),
        ])->assertCreated()->json();
    }

    private function caseRow(string $id): object
    {
        $case = DB::table('safety_cases')->where('id', $id)->first();
        $this->assertNotNull($case);

        return $case;
    }

    private function evidence(string $id): TestResponse
    {
        return $this->getJson('/admin/safety-cases/'.$id.'/evidence?'.http_build_query([
            'reason' => 'TEST_ONLY necessary sealed historical fact investigation',
        ]));
    }

    private function decide(string $id, string $action, array $extra = []): TestResponse
    {
        return $this->postJson('/admin/safety-cases/'.$id.'/decisions', array_merge([
            'action' => $action, 'revision' => (int) $this->caseRow($id)->revision,
            'reason' => 'TEST_ONLY explicit human decision with recorded limits', 'confirm' => true,
        ], $extra));
    }

    private function reportBody(string $eventId, User $subject, string $key): array
    {
        return [
            'target_registration_id' => $this->registration($eventId, $subject)->id,
            'category' => 'CONDUCT',
            'statement' => 'TEST_ONLY historical allegation requiring independent investigation',
            'idempotency_key' => $key,
        ];
    }

    private function participate(string $id, User ...$users): void
    {
        $this->invite($id, ...$users);
        foreach ($users as $user) {
            $this->userAction($user, $id, 'apply')->assertOk();
            $audit = DB::table('platform_event_audits')->where('event_id', $id)
                ->where('actor_id', $user->id)->where('action', 'apply')->first();
            $this->assertNotNull($audit);
            $facts = json_decode($audit->facts, true, 512, JSON_THROW_ON_ERROR);
            $this->assertSame($this->registration($id, $user)->id, $facts['registration_id']);
            $this->assertContains($facts['registration_state'], ['APPLIED', 'WAITLISTED']);
        }
    }

    private function contexts(User $actor): array
    {
        return $this->actingAs($actor, 'sanctum')->getJson('/api/v1/platform-events')
            ->assertOk()->assertJsonStructure(['report_contexts'])->json('report_contexts');
    }

    private function assertMinimal(array $value): void
    {
        $forbidden = ['title', 'venue', 'city', 'profile', 'media', 'media_url', 'avatar',
            'phone', 'name', 'user_id', 'reporter_id', 'subject_id', 'claim', 'statement'];
        foreach ($value as $key => $child) {
            $this->assertNotContains((string) $key, $forbidden, 'Private field leaked: '.$key);
            if (is_array($child)) {
                $this->assertMinimal($child);
            }
        }
    }

    public function test_cancelled_participant_gets_only_audited_co_participants_in_minimal_report_context(): void
    {
        [$a, $b, $invited, $stranger] = $this->people();
        $this->loginAdmin();
        $id = $this->openEvent(3);
        $this->participate($id, $a, $b);
        $this->invite($id, $invited);
        $this->userAction($a, $id, 'cancel')->assertOk();
        $this->actingAs($a, 'sanctum')->getJson('/api/v1/platform-events/'.$id)->assertNotFound();

        $contexts = $this->contexts($a);
        $this->assertCount(1, $contexts);
        $this->assertSame($id, $contexts[0]['id']);
        $this->assertMinimal($contexts);
        $participants = $contexts[0]['participants'];
        $this->assertCount(1, $participants);
        $this->assertSame($this->registration($id, $b)->id, $participants[0]['registration_id']);
        $this->assertEqualsCanonicalizing(['registration_id', 'label'], array_keys($participants[0]));
        $this->assertNotEmpty($participants[0]['label']);
        $this->assertSame([], $this->contexts($invited));
        $this->assertSame([], $this->contexts($stranger));
    }

    public function test_current_rows_cannot_forge_participation_and_non_overlapping_history_is_not_a_peer(): void
    {
        [$a, $b, $invited, $late] = $this->people();
        $this->loginAdmin();
        $id = $this->openEvent(4);
        $this->participate($id, $a, $b);
        $this->invite($id, $invited, $late);
        // A forged current row has no immutable successful apply receipt.
        DB::table('platform_event_registrations')->where('id', $this->registration($id, $invited)->id)
            ->update(['state' => 'APPLIED', 'revision' => 2]);
        $this->userAction($a, $id, 'cancel')->assertOk();
        $this->travel(1)->minutes();
        $this->userAction($late, $id, 'apply')->assertOk();
        $contexts = $this->contexts($a);
        $this->assertCount(1, $contexts);
        $this->assertSame([$this->registration($id, $b)->id], array_column($contexts[0]['participants'], 'registration_id'));
        foreach ([$invited, $late] as $invalidTarget) {
            $this->actingAs($a, 'sanctum')->postJson('/api/v1/platform-events/'.$id.'/reports',
                $this->reportBody($id, $invalidTarget, (string) Str::uuid()))->assertNotFound();
        }
        $this->actingAs($invited, 'sanctum')->postJson('/api/v1/platform-events/'.$id.'/reports',
            $this->reportBody($id, $b, 'forged-reporter'))->assertNotFound();
        $this->assertDatabaseCount('safety_cases', 0);
        $this->travelBack();
    }

    public function test_historical_report_and_own_case_survive_block_without_reviving_activity_access(): void
    {
        [$a, $b, $stranger] = $this->people();
        $this->loginAdmin();
        $id = $this->openEvent();
        $this->participate($id, $a, $b);
        $this->actingAs($a, 'sanctum')->postJson('/api/v1/moderation/blocks', [
            'blocked_user_id' => $b->id, 'reason_code' => 'TEST_ONLY',
        ])->assertOk();
        $this->getJson('/api/v1/platform-events/'.$id)->assertNotFound();
        $this->assertSame($id, $this->contexts($a)[0]['id']);
        $case = $this->postJson('/api/v1/platform-events/'.$id.'/reports', $this->reportBody($id, $b, 'after-block'))
            ->assertCreated()->assertJsonPath('state', 'OPEN')->assertJsonPath('role', 'reporter')->json();
        $this->assertMinimal($case);
        $own = $this->getJson('/api/v1/safety/own/'.$case['id'])->assertOk()->assertJsonPath('id', $case['id'])->json();
        $this->assertMinimal($own);
        $items = $this->getJson('/api/v1/safety/own')->assertOk()->json('items');
        $this->assertContains($case['id'], array_column($items, 'id'));
        $this->assertMinimal($items);
        $this->actingAs($stranger, 'sanctum')->getJson('/api/v1/safety/own/'.$case['id'])->assertNotFound();
        $this->actingAs($a, 'sanctum')->deleteJson('/api/v1/moderation/blocks/'.$b->id)->assertOk();
        $this->getJson('/api/v1/platform-events/'.$id)->assertNotFound();
        $this->assertDatabaseCount('admin_sanctions', 0);
    }

    public function test_historical_report_rejects_cross_event_and_forged_pointer_and_preserves_idempotency(): void
    {
        [$a, $b, $c] = $this->people();
        $this->loginAdmin();
        $one = $this->openEvent();
        $two = $this->openEvent();
        $this->participate($one, $a, $b);
        $this->participate($two, $c);
        $this->userAction($a, $one, 'cancel')->assertOk();
        $body = $this->reportBody($one, $b, 'historical-once');
        $endpoint = '/api/v1/platform-events/'.$one.'/reports';
        $this->actingAs($a, 'sanctum')->postJson($endpoint, array_merge($body, [
            'target_registration_id' => $this->registration($two, $c)->id,
        ]))->assertNotFound();
        $this->postJson($endpoint, array_merge($body, ['target_registration_id' => (string) Str::uuid()]))->assertNotFound();
        $this->postJson($endpoint, $body + ['source_fact' => ['registration_state' => 'CONFIRMED']])->assertUnprocessable();
        $this->actingAs($c, 'sanctum')->postJson($endpoint, $body)->assertNotFound();
        $this->assertDatabaseCount('safety_cases', 0);
        $case = $this->actingAs($a, 'sanctum')->postJson($endpoint, $body)->assertCreated()->json();
        $counts = [];
        foreach (['safety_cases', 'safety_case_evidence', 'moderation_reports', 'notifications'] as $table) {
            $counts[$table] = DB::table($table)->count();
        }
        $this->postJson($endpoint, $body)->assertSuccessful()->assertJsonPath('id', $case['id']);
        $this->postJson($endpoint, array_merge($body, ['statement' => 'TEST_ONLY changed allegation under a reused key']))->assertStatus(409);
        foreach ($counts as $table => $count) {
            $this->assertSame($count, DB::table($table)->count(), $table.' must not duplicate');
        }
    }

    public function test_report_window_uses_earlier_withdrawal_or_event_end_and_is_not_reset_by_later_exit(): void
    {
        [$a, $b] = $this->people();
        $this->loginAdmin();
        $id = $this->openEvent();
        $this->participate($id, $a, $b);
        $this->userAction($a, $id, 'cancel')->assertOk();
        $this->travel(6)->days();
        $this->assertCount(1, $this->contexts($a));
        $this->travel(1)->days();
        $this->travel(1)->seconds();
        $this->assertSame([], $this->contexts($a));
        $this->actingAs($a, 'sanctum')->postJson('/api/v1/platform-events/'.$id.'/reports',
            $this->reportBody($id, $b, 'withdrawal-expired'))->assertNotFound();
        $this->travelBack();

        $ended = $this->openEvent();
        $this->participate($ended, $a, $b);
        $end = \Illuminate\Support\Carbon::parse($this->event($ended)->end_at);
        $this->travelTo($end->copy()->addDays(6));
        $this->actingAs($a, 'sanctum')->getJson('/api/v1/platform-events/'.$ended)->assertNotFound();
        $this->assertCount(1, array_filter($this->contexts($a),fn($c)=>$c['id']===$ended));
        $this->travelTo($end->copy()->addDays(7)->addSecond());
        $this->assertSame([], $this->contexts($a));
        $this->actingAs($a, 'sanctum')->postJson('/api/v1/platform-events/'.$ended.'/reports',
            $this->reportBody($ended, $b, 'event-end-expired'))->assertNotFound();
        $this->assertDatabaseCount('safety_cases', 0);
        $this->travelBack();
    }

    public function test_sealed_historical_facts_survive_exit_but_never_return_live_event_or_profile_and_expire(): void
    {
        [$a, $b] = $this->people();
        $this->loginAdmin();
        $id = $this->openEvent();
        $this->participate($id, $a, $b);
        $case = $this->makeReport($a, $b, $id);
        $rows = DB::table('safety_case_evidence')->where('case_id', $case['id'])->get();
        $this->assertCount(2, $rows);
        foreach ($rows as $row) {
            $this->assertNotEmpty($row->source_fact);
            $this->assertMatchesRegularExpression('/^[a-f0-9]{64}$/', $row->fact_hash);
            $retention = \Illuminate\Support\Carbon::parse($row->retain_until);
            $this->assertEquals(30, (int) \Illuminate\Support\Carbon::parse($row->created_at)->diffInDays($retention));
        }
        $sealed = $rows->toJson();
        $this->actingAs($a, 'sanctum')->postJson('/api/v1/moderation/blocks', [
            'blocked_user_id' => $b->id, 'reason_code' => 'TEST_ONLY',
        ])->assertOk();
        $this->getJson('/api/v1/platform-events/'.$id)->assertNotFound();
        $result = $this->evidence($case['id'])->assertOk()->assertJsonCount(2, 'evidence')->json('evidence');
        $this->assertMinimal($result);
        foreach ($result as $fact) {
            $this->assertContains('CASE_INVESTIGATION_ONLY', [$fact['purpose'] ?? null, $fact['scope'] ?? null]);
        }
        $this->assertSame($sealed, DB::table('safety_case_evidence')->where('case_id', $case['id'])->get()->toJson());
        $this->travel(31)->days();
        $views = DB::table('admin_operation_audits')->where('action', 'safety.evidence.view')->count();
        $this->evidence($case['id'])->assertOk()->assertJsonPath('evidence.0.status','CURRENT_SOURCE_UNAVAILABLE')
            ->assertJsonMissingPath('evidence.0.source_id')->assertJsonMissingPath('evidence.0.historical_fact');
        $this->assertSame($views+1, DB::table('admin_operation_audits')->where('action', 'safety.evidence.view')->count());
        $this->travelBack();
    }

    public function test_two_historical_claims_allow_named_investigation_but_not_snapshot_based_finding_or_restriction(): void
    {
        [$a, $b, $subject] = $this->people();
        $this->loginAdmin();
        $id = $this->openEvent(3);
        $this->participate($id, $a, $b, $subject);
        $first = $this->makeReport($a, $subject, $id);
        $second = $this->makeReport($b, $subject, $id);
        $this->userAction($a, $id, 'cancel')->assertOk();
        $this->userAction($b, $id, 'cancel')->assertOk();
        $this->decide($first['id'], 'triage')->assertRedirect('/admin/platform-events');
        $this->decide($first['id'], 'investigate')->assertRedirect('/admin/platform-events');
        $this->evidence($first['id'])->assertOk();
        $this->evidence($second['id'])->assertOk();
        $before = DB::table('safety_case_decisions')->count();
        $this->decide($first['id'], 'substantiate', [
            'corroborating_case_id' => $second['id'], 'evidence_checked' => true,
            'manual_finding' => 'TEST_ONLY two allegations and a participation snapshot do not prove conduct.',
        ])->assertUnprocessable();
        $this->assertSame($before, DB::table('safety_case_decisions')->count());
        $this->assertSame('INVESTIGATING', $this->caseRow($first['id'])->state);
        $this->decide($first['id'], 'restrict', ['user_revision' => (int) $subject->fresh()->admin_revision])->assertStatus(409);
        $this->assertDatabaseCount('admin_sanctions', 0);
        $this->assertSame('normal', $subject->fresh()->moderation_status);
        $this->decide($first['id'], 'dismiss')->assertRedirect('/admin/platform-events');
        $this->assertDatabaseHas('safety_case_decisions', [
            'case_id' => $first['id'], 'action' => 'DISMISS',
            'reason' => 'TEST_ONLY explicit human decision with recorded limits',
        ]);
    }

    public function test_unrelated_block_does_not_end_other_participants_history_or_late_co_participation(): void
    {
        [$a,$b,$c,$d]=$this->people();$this->loginAdmin();
        $id=$this->openEvent(4,['end_at'=>now()->addDays(20)->toIso8601String()]);
        $this->participate($id,$a,$b,$c,$d);
        $this->actingAs($c,'sanctum')->postJson('/api/v1/moderation/blocks',['blocked_user_id'=>$d->id,'reason_code'=>'TEST_ONLY'])->assertOk();
        $this->travel(8)->days();
        $contexts=$this->contexts($a);$this->assertCount(1,$contexts);
        $this->assertContains($this->registration($id,$b)->id,array_column($contexts[0]['participants'],'registration_id'));
        $late=User::factory()->create(['phone'=>'19900001409','name'=>'TEST_ONLY late participant','is_synthetic'=>true,'role'=>'user','disabled'=>false,'account_status'=>'active','moderation_status'=>'normal']);
        $this->participate($id,$late);
        $contexts=$this->contexts($a);
        $this->assertContains($this->registration($id,$late)->id,array_column($contexts[0]['participants'],'registration_id'));
        $this->actingAs($a,'sanctum')->postJson('/api/v1/platform-events/'.$id.'/reports',$this->reportBody($id,$b,'unrelated-block'))->assertCreated();
        $this->travelBack();
    }

    public function test_legacy_exact_hash_seals_old_states_and_tampered_or_cross_case_seals_reveal_no_source(): void
    {
        [$a,$b]=$this->people();$this->loginAdmin();$id=$this->openEvent();$this->participate($id,$a,$b);
        $old=$this->makeReport($a,$b,$id);
        foreach([$a,$b] as $u)$this->adminAction($id,'confirm',['registration_id'=>$this->registration($id,$u)->id])->assertRedirect('/admin/platform-events');
        $this->userAction($a,$id,'attendance')->assertOk();$selfReported=$this->makeReport($a,$b,$id);
        foreach([$old,$selfReported] as $case){
            DB::table('safety_case_evidence')->where('case_id',$case['id'])->update(['source_fact'=>null,'fact_hash'=>null,'retain_until'=>null]);
            $hashes=DB::table('safety_case_evidence')->where('case_id',$case['id'])->orderBy('id')->pluck('source_hash')->all();
            $sources=$this->evidence($case['id'])->assertOk()->json('evidence');
            $expectedIds=[$this->registration($id,$a)->id,$this->registration($id,$b)->id];$actualIds=array_column($sources,'source_id');
            sort($expectedIds);sort($actualIds);$this->assertSame($expectedIds,$actualIds);
            foreach($sources as $source){
                $this->assertSame('HISTORICAL_AUTHORIZED_FACT',$source['status']);
                $this->assertSame($case['id'],$source['historical_fact']['case_id']);
                $this->assertSame($case['id']===$old['id']?'APPLIED':'CONFIRMED',$source['historical_fact']['state']);
            }
            if($case['id']===$selfReported['id']){
                $r=$this->registration($id,$a);$this->assertSame('SELF_REPORTED',$r->attendance);
                $expected=hash('sha256',json_encode([$r->id,$r->event_id,(int)$r->user_id,$r->state,(int)$r->revision,$r->attendance],JSON_THROW_ON_ERROR));
                $ownSource=array_values(array_filter($sources,fn($s)=>$s['source_id']===$r->id))[0];
                $this->assertSame($expected,$ownSource['hash']);
            }
            $this->assertSame($hashes,DB::table('safety_case_evidence')->where('case_id',$case['id'])->orderBy('id')->pluck('source_hash')->all());
            $this->assertNotNull(DB::table('safety_case_evidence')->where('case_id',$case['id'])->value('fact_hash'));
        }
        $row=DB::table('safety_case_evidence')->where('case_id',$old['id'])->first();
        DB::table('safety_case_evidence')->where('id',$row->id)->update(['source_fact'=>'{"tampered":true}']);
        $sources=$this->evidence($old['id'])->assertOk()->json('evidence');
        $invalid=array_values(array_filter($sources,fn($s)=>$s['status']==='CURRENT_SOURCE_UNAVAILABLE'));
        $this->assertCount(1,$invalid);$this->assertArrayNotHasKey('source_id',$invalid[0]);
        DB::table('safety_case_evidence')->where('case_id',$selfReported['id'])->update(['source_fact'=>$row->source_fact,'fact_hash'=>$row->fact_hash]);
        $sources=$this->evidence($selfReported['id'])->assertOk()->json('evidence');
        foreach($sources as $source){$this->assertFalse($source['current_available']);$this->assertArrayNotHasKey('historical_fact',$source);}
        $this->assertDatabaseCount('admin_sanctions',0);
    }

    public function test_historical_evidence_rechecks_reason_role_session_revision_and_legacy_hash(): void
    {
        [$a, $b] = $this->people();
        $this->loginAdmin();
        $id = $this->openEvent();
        $this->participate($id, $a, $b);
        $case = $this->makeReport($a, $b, $id);
        $this->userAction($a, $id, 'cancel')->assertOk();
        $this->getJson('/admin/safety-cases/'.$case['id'].'/evidence')->assertUnprocessable();
        $this->decide($case['id'], 'triage', ['revision' => 99])->assertStatus(409);
        $this->adminUser->forceFill(['role' => 'user'])->save();
        $this->evidence($case['id'])->assertForbidden();
        $this->decide($case['id'], 'triage')->assertForbidden();
        $this->adminUser->forceFill(['role' => 'admin'])->save();
        // Corruption/legacy fixture: a historical grant must not bless an unverifiable old hash.
        DB::table('safety_case_evidence')->where('case_id', $case['id'])->update([
            'source_fact' => null, 'fact_hash' => null, 'source_hash' => str_repeat('0', 64),
        ]);
        $views = DB::table('admin_operation_audits')->where('action', 'safety.evidence.view')->count();
        $this->evidence($case['id'])->assertOk()->assertJsonPath('evidence.0.status','CURRENT_SOURCE_UNAVAILABLE')
            ->assertJsonMissingPath('evidence.0.source_id')->assertJsonMissingPath('evidence.0.historical_fact');
        $this->assertSame($views+1, DB::table('admin_operation_audits')->where('action', 'safety.evidence.view')->count());
        $this->app->bind(ValidateCsrfToken::class,
            fn ($app) => new EnforcedV1014R1Csrf($app, $app['encrypter']));
        $this->decide($case['id'], 'triage')->assertStatus(419);
        $this->withHeader('X-CSRF-TOKEN', session()->token());
        DB::table('platform_admin_sessions')->where('user_id', $this->adminUser->id)->update(['revoked_at' => now()]);
        $this->evidence($case['id'])->assertUnauthorized();
        $this->decide($case['id'], 'triage')->assertUnauthorized();
        $this->assertDatabaseCount('safety_case_decisions', 0);
        $this->assertDatabaseCount('admin_sanctions', 0);
    }
}

/** Exercise the existing Web CSRF middleware rather than Laravel's test bypass. */
final class EnforcedV1014R1Csrf extends ValidateCsrfToken
{
    protected function runningUnitTests(): bool
    {
        return false;
    }
}
