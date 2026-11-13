<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\UserBlock;
use App\Models\UserProfileShowcaseDraft;
use App\Models\UserProfileShowcasePublication;
use App\Services\TrustedIdentityService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Testing\TestResponse;
use PHPUnit\Framework\Attributes\DataProvider;
use Tests\TestCase;

/** Isolated permission fixtures exercise the actual journey/decision HTTP kernel. */
class ShowcaseJourneyAudienceTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        config(['restoration.enabled' => true, 'journey.test_issuer_enabled' => true,
            'journey.test_issuer_key' => str_repeat('fixture-showcase-', 3)]);
    }

    private function subjects(): array
    {
        return [User::factory()->create(['phone' => 'r1-showcase-owner']),
            User::factory()->create(['phone' => 'r1-showcase-viewer'])];
    }

    private function publication(User $owner, array $audiences): UserProfileShowcasePublication
    {
        $payload = ['self_intro' => 'Published fixture introduction', 'interest_tags' => ['fixture reading'],
            'lifestyle_tags' => ['fixture walking'], 'audiences' => $audiences];
        $draft = UserProfileShowcaseDraft::create(['user_id' => $owner->id] + $payload);
        return UserProfileShowcasePublication::create(['user_id' => $owner->id, 'source_draft_id' => $draft->id,
            'source_moderation_status' => 'approved', 'published_payload' => $payload,
            'publication_status' => 'published', 'public_display_eligible' => true,
            'matching_scoring_eligible' => false, 'revision' => 1, 'published_at' => now()]);
    }

    private function proposal(User $owner, User $viewer, bool $mutual = true): string
    {
        // v10.1.7 adds explicit private-input confirmation to the pending-proposal fixture.
        config(['questionnaire.required_answer_count' => 1]);
        $question = \App\Models\QuestionnaireQuestion::firstOrCreate(['question_key' => 'r1-current-input'],
            ['category' => 'lifestyle', 'content' => 'Fixture', 'question_type' => 'single_choice',
                'options' => [['option_id' => 'A']], 'enabled' => true, 'version' => 1]);
        foreach ([$owner, $viewer] as $index => $user) {
            $user->forceFill(['verify_status' => 'approved'])->save();
            \App\Models\QuestionnaireAnswer::create(['user_id' => $user->id, 'questionnaire_question_id' => $question->id,
                'answer_payload' => ['selected_answer' => ['A']], 'version' => 1]);
            app(\App\Services\MatchingInputService::class)->save($user->id, [
                'revision' => 0, 'confirm' => true, 'birthday' => '1995-01-01',
                'gender' => $index === 0 ? 'male' : 'female', 'city_key' => 'fixture_city',
                'relationship_goal' => 'marriage', 'age_mode' => 'adult_any', 'region_mode' => 'same_city',
            ]);
        }
        $stamp = ['created_at' => now(), 'updated_at' => now()];
        DB::table('dating_round_channels')->insertOrIgnore(['channel_key' => 'default'] + $stamp);
        $round = DB::table('dating_rounds')->insertGetId(['round_key' => (string) Str::uuid(),
            'channel_key' => 'default', 'cadence_key' => (string) Str::uuid(), 'state' => 'revealed',
            'created_by_type' => 'test', 'source' => 'v1016-r1-permission-fixture'] + $stamp);
        $run = DB::table('matching_runs')->insertGetId(['round_id' => $round, 'run_key' => (string) Str::uuid(),
            'idempotency_key' => 'showcase-fixture-'.$round, 'correlation_id' => (string) Str::uuid(), 'attempt_no' => 1,
            'state' => 'succeeded', 'trigger_source' => 'test', 'actor_type' => 'test',
            'eligibility_cutoff_at' => now(), 'algorithm_version' => 'fixture', 'config_version' => 'fixture'] + $stamp);
        $match = DB::table('dating_matches')->insertGetId(['week_tag' => 'v1016-r1-fixture', 'round_id' => $round,
            'matching_run_id' => $run, 'user_a' => $owner->id, 'user_b' => $viewer->id, 'drop_released' => true] + $stamp);
        $id = (string) Str::uuid();
        DB::table('match_proposals')->insert(['id' => $id, 'dating_match_id' => $match, 'round_id' => $round,
            'run_id' => $run, 'user_a' => $owner->id, 'user_b' => $viewer->id, 'generation_a' => 1, 'generation_b' => 1,
            'state' => $mutual ? 'MUTUALLY_ACCEPTED' : 'PENDING', 'revision' => 1,
            'decision_a' => $mutual ? 'ACCEPTED' : 'PENDING', 'decision_b' => $mutual ? 'ACCEPTED' : 'PENDING',
            'revealed_at' => now(), 'expires_at' => now()->addHours(24)] + $stamp);
        DB::table('dating_round_channels')->where('channel_key', 'default')->update(['active_round_id' => $round]);
        foreach ([$owner, $viewer] as $user) {
            DB::table('dating_round_user_states')->insert(['round_id' => $round, 'user_id' => $user->id,
                'state' => 'revealed', 'dating_match_id' => $match] + $stamp);
            DB::table('matching_participations')->insert(['user_id' => $user->id, 'state' => 'ACTIVE',
                'generation' => 1, 'revision' => 1, 'opted_in_at' => now()] + $stamp);
            if (! $mutual) DB::table('match_proposal_slots')->insert(['user_id' => $user->id, 'proposal_id' => $id]);
        }
        return $id;
    }

    private function journey(User $viewer): TestResponse
    {
        return $this->actingAs($viewer, 'sanctum')->getJson('/api/v1/journey')->assertOk();
    }

    private function accept(User $actor, string $id, int $revision, string $key): TestResponse
    {
        return $this->actingAs($actor, 'sanctum')->postJson('/api/v1/journey/proposals/'.$id.'/decision',
            ['action' => 'accept', 'revision' => $revision, 'idempotency_key' => $key])->assertOk();
    }

    private function friends(User $a, User $b): void
    {
        DB::table('friendships')->insert(['user_a' => min($a->id, $b->id), 'user_b' => max($a->id, $b->id),
            'state' => 'ACTIVE', 'revision' => 1, 'created_at' => now(), 'updated_at' => now()]);
    }

    public static function restrictedAudiences(): array
    {
        return ['friends journey' => ['friends', 'journey'], 'friends decision' => ['friends', 'decision'],
            'relationship journey' => ['relationship', 'journey'], 'relationship decision' => ['relationship', 'decision']];
    }

    #[DataProvider('restrictedAudiences')]
    public function test_valid_match_does_not_grant_unselected_audience(string $audience, string $consumer): void
    {
        [$owner, $viewer] = $this->subjects();
        $this->publication($owner, [$audience]);
        $id = $this->proposal($owner, $viewer, $consumer === 'journey');
        self::assertSame(0, DB::table('friendships')->count());
        self::assertSame(0, DB::table('formal_relationships')->count());
        if ($consumer === 'decision') {
            $this->accept($owner, $id, 1, 'owner-accept')->assertJsonPath('state', 'ACCEPTED_BY_ONE');
            $this->accept($viewer, $id, 2, 'viewer-accept')->assertJsonPath('state', 'MUTUALLY_ACCEPTED')
                ->assertJsonPath('showcase', null)->assertJsonPath('connection_eligible', true);
        } else {
            $this->journey($viewer)->assertJsonPath('proposal.id', $id)->assertJsonPath('proposal.state', 'MUTUALLY_ACCEPTED')
                ->assertJsonPath('proposal.showcase', null)->assertJsonPath('proposal.connection_eligible', true);
        }
        $this->journey($viewer)->assertJsonPath('round.state', 'revealed')->assertJsonPath('proposal.showcase', null);
        $this->getJson('/api/v1/profile/showcase/'.$owner->id)->assertNotFound();
    }

    public function test_proposal_without_showcase_authority_can_still_be_declined(): void
    {
        [$owner, $viewer] = $this->subjects();
        $this->publication($owner, ['relationship']);
        $id = $this->proposal($owner, $viewer, false);
        $this->journey($viewer)->assertJsonPath('proposal.showcase', null)->assertJsonPath('proposal.decision_available', true)
            ->assertJsonPath('round.state', 'revealed');
        $this->actingAs($viewer, 'sanctum')->postJson('/api/v1/journey/proposals/'.$id.'/decision',
            ['action' => 'decline', 'revision' => 1, 'idempotency_key' => 'decline-hidden'])->assertOk()
            ->assertJsonPath('state', 'DECLINED')->assertJsonPath('showcase', null);
    }

    public function test_current_friends_and_contacts_receive_only_published_fields(): void
    {
        [$owner, $viewer] = $this->subjects();
        $publication = $this->publication($owner, ['friends']);
        $id = $this->proposal($owner, $viewer, false);
        $this->friends($owner, $viewer);
        UserProfileShowcaseDraft::where('user_id', $owner->id)->update(['self_intro' => 'Private new draft']);
        $this->journey($viewer)->assertJsonPath('proposal.showcase.summary', 'Published fixture introduction')
            ->assertJsonPath('proposal.showcase.interest_tags.0', 'fixture reading')->assertJsonPath('round.state', 'revealed');
        $this->getJson('/api/v1/profile/showcase/'.$owner->id)->assertOk()
            ->assertJsonPath('publication.public_fields.self_intro', 'Published fixture introduction');
        $this->accept($owner, $id, 1, 'owner-accept');
        $this->accept($viewer, $id, 2, 'viewer-accept')->assertJsonPath('showcase.summary', 'Published fixture introduction');
        $publication->update(['published_payload' => array_replace($publication->published_payload, ['audiences' => ['contacts']])]);
        DB::table('friendships')->update(['state' => 'REVOKED']);
        $this->journey($viewer)->assertJsonPath('proposal.showcase.summary', 'Published fixture introduction');
        $this->getJson('/api/v1/profile/showcase/'.$owner->id)->assertOk();
    }

    public function test_replay_rechecks_audience_withdrawal_and_friendship_without_duplicate_decisions(): void
    {
        [$owner, $viewer] = $this->subjects();
        $publication = $this->publication($owner, ['contacts']);
        $id = $this->proposal($owner, $viewer, false);
        $this->accept($owner, $id, 1, 'owner-accept');
        $this->accept($viewer, $id, 2, 'viewer-accept')->assertJsonPath('showcase.summary', 'Published fixture introduction');
        $counts = [DB::table('journey_commands')->count(), DB::table('journey_audits')->count()];
        $publication->update(['published_payload' => array_replace($publication->published_payload, ['audiences' => ['friends']])]);
        $this->accept($viewer, $id, 2, 'viewer-accept')->assertJsonPath('showcase', null)->assertJsonPath('state', 'MUTUALLY_ACCEPTED');
        $this->friends($owner, $viewer);
        $this->accept($viewer, $id, 2, 'viewer-accept')->assertJsonPath('showcase.summary', 'Published fixture introduction');
        $publication->update(['publication_status' => 'withdrawn']);
        $this->accept($viewer, $id, 2, 'viewer-accept')->assertJsonPath('showcase', null);
        $publication->update(['publication_status' => 'published']);
        DB::table('friendships')->update(['state' => 'REVOKED']);
        $this->accept($viewer, $id, 2, 'viewer-accept')->assertJsonPath('showcase', null);
        self::assertSame($counts, [DB::table('journey_commands')->count(), DB::table('journey_audits')->count()]);
    }

    public function test_formal_audience_uses_current_confirmed_relationship_sharing(): void
    {
        [$owner, $viewer] = $this->subjects();
        foreach ([$owner, $viewer] as $user) {
            $user->update(['is_synthetic' => true]);
            app(TrustedIdentityService::class)->register($user->id);
            app(TrustedIdentityService::class)->issue($user->id, 'showcase-identity-'.$user->id);
        }
        $this->friends($owner, $viewer);
        $this->actingAs($owner, 'sanctum')->postJson('/api/v1/social/preferences', ['requests_enabled' => true])->assertOk();
        $relationship = $this->actingAs($viewer, 'sanctum')->postJson('/api/v1/formal-relationships',
            ['peer_id' => $owner->id, 'idempotency_key' => 'relationship-fixture'])->assertOk()->json();
        foreach ([$owner, $viewer] as $user) {
            $relationship = $this->actingAs($user, 'sanctum')->postJson('/api/v1/formal-relationships/'.$relationship['id'].'/actions',
                ['action' => 'confirm', 'revision' => $relationship['revision'], 'idempotency_key' => 'confirm-'.$user->id])->assertOk()->json();
        }
        self::assertSame('ACTIVE', $relationship['state']);
        $this->publication($owner, ['relationship']);
        $this->proposal($owner, $viewer);
        $this->journey($viewer)->assertJsonPath('proposal.showcase.summary', 'Published fixture introduction');
        $this->getJson('/api/v1/profile/showcase/'.$owner->id)->assertOk();
        $this->actingAs($owner, 'sanctum')->postJson('/api/v1/formal-relationships/'.$relationship['id'].'/actions',
            ['action' => 'pause', 'revision' => $relationship['revision'], 'idempotency_key' => 'pause-sharing'])->assertOk();
        $this->journey($viewer)->assertJsonPath('proposal.showcase', null)->assertJsonPath('round.state', 'revealed');
        $this->getJson('/api/v1/profile/showcase/'.$owner->id)->assertNotFound();
    }

    public function test_missing_explicit_audience_and_withdrawn_publication_stay_hidden(): void
    {
        [$owner, $viewer] = $this->subjects();
        $publication = $this->publication($owner, []);
        $this->proposal($owner, $viewer);
        $this->journey($viewer)->assertJsonPath('proposal.showcase', null)->assertJsonPath('round.state', 'revealed');
        $legacyPayload = $publication->published_payload;
        unset($legacyPayload['audiences']);
        $publication->update(['published_payload' => $legacyPayload]);
        $this->journey($viewer)->assertJsonPath('proposal.showcase', null);
        $publication->update(['published_payload' => array_replace($publication->published_payload, ['audiences' => ['contacts']]),
            'publication_status' => 'withdrawn']);
        $this->journey($viewer)->assertJsonPath('proposal.showcase', null)->assertJsonPath('round.state', 'revealed');
    }

    public function test_block_account_restriction_and_proposal_generation_invalidate_current_summary(): void
    {
        [$owner, $viewer] = $this->subjects();
        $this->publication($owner, ['contacts']);
        $this->proposal($owner, $viewer);
        $this->journey($viewer)->assertJsonPath('proposal.showcase.summary', 'Published fixture introduction');
        $owner->update(['moderation_status' => 'restricted']);
        $this->journey($viewer)->assertJsonPath('proposal.showcase', null);
        $owner->update(['moderation_status' => 'normal']);
        $block = UserBlock::create(['blocker_id' => $owner->id, 'blocked_user_id' => $viewer->id]);
        $this->journey($viewer)->assertJsonPath('proposal.showcase', null);
        $block->delete();
        DB::table('matching_participations')->where('user_id', $owner->id)->update(['generation' => 2]);
        $this->journey($viewer)->assertJsonPath('proposal.showcase', null)->assertJsonPath('proposal.connection_eligible', false);
    }
}
