<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\UserBlock;
use App\Services\ProfileShowcase\CandidateShowcaseSnapshot;
use App\Services\ProfileShowcase\ShowcaseWorkflow;
use App\Services\TrustedIdentityService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Tests\TestCase;

class V2CandidateSnapshotTest extends TestCase
{
    use RefreshDatabase;

    private int $accountSequence = 0;

    protected function setUp(): void
    {
        parent::setUp();
        config([
            'restoration.enabled' => true,
            'journey.test_issuer_enabled' => true,
            'journey.test_issuer_key' => str_repeat('v2-candidate-snapshot-', 2),
        ]);
    }

    private function account(): User
    {
        $user = User::factory()->create([
            'role' => 'user', 'disabled' => false, 'is_synthetic' => true,
            'account_status' => 'active', 'moderation_status' => 'normal',
            'phone' => '902019'.str_pad((string) ++$this->accountSequence, 5, '0', STR_PAD_LEFT),
        ]);
        app(TrustedIdentityService::class)->register((int) $user->id);
        app(TrustedIdentityService::class)->issue((int) $user->id, 'v2-candidate-'.$user->id);

        return $user->fresh();
    }

    private function administrator(): User
    {
        $admin = User::factory()->create([
            'role' => 'admin', 'disabled' => false,
            'phone' => '9020199'.str_pad((string) ++$this->accountSequence, 4, '0', STR_PAD_LEFT),
        ]);
        config(['app.admin_phones' => [$admin->phone]]);

        return $admin;
    }

    private function friends(User $a, User $b): void
    {
        DB::table('friendships')->insert([
            'user_a' => min($a->id, $b->id), 'user_b' => max($a->id, $b->id),
            'state' => 'ACTIVE', 'revision' => 1, 'created_at' => now(), 'updated_at' => now(),
        ]);
    }

    private function publish(User $owner, string $summary): array
    {
        $workflow = app(ShowcaseWorkflow::class);
        $fields = [
            'display_name' => 'Fixture person', 'city' => 'Fixture city',
            'relationship_goal' => 'friendship', 'self_intro' => $summary,
            'interest_tags' => ['fixture interest'], 'lifestyle_tags' => ['fixture lifestyle'],
            'opener_note' => 'fixture opener', 'photo_ids' => [], 'audiences' => ['friends'],
        ];
        $draftRevision = (int) $workflow->ownerPayload((int) $owner->id)['revision'];
        $draft = $workflow->saveDraft((int) $owner->id, $fields, $draftRevision);
        $submission = $workflow->submit((int) $owner->id, (int) $draft['revision'])['submission'];
        $workflow->review($this->administrator(), (int) $submission['id'], (int) $submission['revision'], 'approved', 'synthetic fixture');
        $publicationRevision = (int) ($workflow->ownerPublication((int) $owner->id)['publication']['revision'] ?? 0);
        $workflow->publish((int) $owner->id, (int) $draft['revision'], $publicationRevision);

        return $workflow->ownerPublication((int) $owner->id)['publication'];
    }

    private function proposal(User $owner, User $viewer): object
    {
        $stamp = ['created_at' => now(), 'updated_at' => now()];
        DB::table('dating_round_channels')->insertOrIgnore(['channel_key' => 'default'] + $stamp);
        $round = DB::table('dating_rounds')->insertGetId([
            'round_key' => (string) Str::uuid(), 'channel_key' => 'default',
            'cadence_key' => (string) Str::uuid(), 'state' => 'revealed',
            'created_by_type' => 'test', 'source' => 'v2-candidate-snapshot-test',
        ] + $stamp);
        $run = DB::table('matching_runs')->insertGetId([
            'round_id' => $round, 'run_key' => (string) Str::uuid(),
            'idempotency_key' => 'v2-candidate-'.$round, 'correlation_id' => (string) Str::uuid(),
            'attempt_no' => 1, 'state' => 'succeeded', 'trigger_source' => 'test', 'actor_type' => 'test',
            'eligibility_cutoff_at' => now(), 'algorithm_version' => 'fixture', 'config_version' => 'fixture',
        ] + $stamp);
        $match = DB::table('dating_matches')->insertGetId([
            'week_tag' => 'v2-candidate-'.$round, 'round_id' => $round, 'matching_run_id' => $run,
            'user_a' => $owner->id, 'user_b' => $viewer->id, 'drop_released' => true,
        ] + $stamp);
        $id = (string) Str::uuid();
        DB::table('match_proposals')->insert([
            'id' => $id, 'dating_match_id' => $match, 'round_id' => $round, 'run_id' => $run,
            'user_a' => $owner->id, 'user_b' => $viewer->id, 'generation_a' => 1, 'generation_b' => 1,
            'state' => 'PENDING', 'revision' => 1, 'decision_a' => 'PENDING', 'decision_b' => 'PENDING',
            'revealed_at' => now(), 'expires_at' => now()->addDay(),
        ] + $stamp);

        return DB::table('match_proposals')->where('id', $id)->first();
    }

    public function test_existing_candidate_keeps_its_original_approved_publication_after_replacement(): void
    {
        $owner = $this->account();
        $viewer = $this->account();
        $this->friends($owner, $viewer);
        $original = $this->publish($owner, 'Original approved summary');
        $proposal = $this->proposal($owner, $viewer);

        $snapshots = app(CandidateShowcaseSnapshot::class);
        $snapshots->capture($proposal);
        $this->publish($owner, 'New approved summary');

        self::assertSame([
            'public_id' => 'ES-'.$owner->id,
            'summary' => 'Original approved summary',
            'interest_tags' => ['fixture interest'],
            'lifestyle_tags' => ['fixture lifestyle'],
            'publication_revision' => $original['revision'],
        ], $snapshots->read($proposal, (int) $viewer->id, (int) $owner->id));
    }

    public function test_uncaptured_or_expired_candidate_fails_closed_without_upgrading(): void
    {
        $owner = $this->account();
        $viewer = $this->account();
        $this->friends($owner, $viewer);
        $this->publish($owner, 'Current approved summary');
        $proposal = $this->proposal($owner, $viewer);
        $snapshots = app(CandidateShowcaseSnapshot::class);

        self::assertNull($snapshots->read($proposal, (int) $viewer->id, (int) $owner->id));
        $snapshots->capture($proposal);
        DB::table('match_proposals')->where('id', $proposal->id)->update(['expires_at' => now()->subSecond()]);
        $proposal = DB::table('match_proposals')->where('id', $proposal->id)->first();
        self::assertNull($snapshots->read($proposal, (int) $viewer->id, (int) $owner->id));
    }

    public function test_current_withdrawal_block_disabled_owner_and_unapproved_source_hide_snapshot(): void
    {
        foreach (['withdrawn', 'blocked', 'disabled', 'unapproved'] as $case) {
            $owner = $this->account();
            $viewer = $this->account();
            $this->friends($owner, $viewer);
            $publication = $this->publish($owner, 'Approved summary');
            $proposal = $this->proposal($owner, $viewer);
            $snapshots = app(CandidateShowcaseSnapshot::class);
            $snapshots->capture($proposal);

            if ($case === 'withdrawn') {
                app(ShowcaseWorkflow::class)->withdraw((int) $owner->id, (int) $publication['revision']);
            } elseif ($case === 'blocked') {
                UserBlock::create(['blocker_id' => $owner->id, 'blocked_user_id' => $viewer->id]);
            } elseif ($case === 'disabled') {
                $owner->update(['disabled' => true]);
            } else {
                $sourceSubmissionId = DB::table('user_profile_showcase_publications')
                    ->where('user_id', $owner->id)->value('source_submission_id');
                DB::table('profile_showcase_submissions')->where('id', $sourceSubmissionId)
                    ->update(['state' => 'pending']);
            }

            self::assertNull($snapshots->read($proposal, (int) $viewer->id, (int) $owner->id), $case);
        }
    }

    public function test_new_candidate_captures_new_publication_version(): void
    {
        $owner = $this->account();
        $viewer = $this->account();
        $this->friends($owner, $viewer);
        $this->publish($owner, 'First approved summary');
        $first = $this->proposal($owner, $viewer);
        $snapshots = app(CandidateShowcaseSnapshot::class);
        $snapshots->capture($first);

        $this->publish($owner, 'Second approved summary');
        $second = $this->proposal($owner, $viewer);
        $snapshots->capture($second);

        self::assertSame('First approved summary', $snapshots->read($first, (int) $viewer->id, (int) $owner->id)['summary']);
        self::assertSame('Second approved summary', $snapshots->read($second, (int) $viewer->id, (int) $owner->id)['summary']);
    }

    public function test_withdrawal_then_republication_does_not_restore_old_candidate_access(): void
    {
        $owner = $this->account();
        $viewer = $this->account();
        $this->friends($owner, $viewer);
        $publication = $this->publish($owner, 'Original approved summary');
        $proposal = $this->proposal($owner, $viewer);
        $snapshots = app(CandidateShowcaseSnapshot::class);
        $snapshots->capture($proposal);

        app(ShowcaseWorkflow::class)->withdraw((int) $owner->id, (int) $publication['revision']);
        $this->publish($owner, 'Republished summary');

        self::assertNull($snapshots->read($proposal, (int) $viewer->id, (int) $owner->id));
    }

    public function test_legacy_match_reads_do_not_project_unbound_or_blocked_content(): void
    {
        $owner = $this->account();
        $viewer = $this->account();
        DB::table('dating_matches')->insert([
            'week_tag' => 'legacy-match-fixture',
            'user_a' => $owner->id, 'user_b' => $viewer->id,
            'drop_released' => true,
            'match_reasons' => json_encode(['fixture_hidden' => 'unbound legacy explanation']),
            'created_at' => now(), 'updated_at' => now(),
        ]);
        $this->actingAs($viewer, 'sanctum')->getJson('/api/v1/match/current')
            ->assertOk()->assertJsonPath('proposal', null)->assertJsonMissingPath('match_reasons');
        $this->getJson('/api/v1/match/history')->assertOk()
            ->assertJsonPath('data', [])->assertJsonPath('total', 0);

        $this->friends($owner, $viewer);
        $this->publish($owner, 'Blocked fixture summary');
        $proposal = $this->proposal($owner, $viewer);
        app(CandidateShowcaseSnapshot::class)->capture($proposal);
        UserBlock::create(['blocker_id' => $owner->id, 'blocked_user_id' => $viewer->id]);

        $this->getJson('/api/v1/match/current')->assertOk()
            ->assertJsonPath('proposal.id', $proposal->id)
            ->assertJsonPath('proposal.showcase', null)
            ->assertJsonPath('proposal.explanation', null)
            ->assertJsonPath('proposal.accept_available', false);
        $this->getJson('/api/v1/match/history')->assertOk()
            ->assertJsonPath('data.0.showcase', null)
            ->assertJsonPath('data.0.explanation', null)
            ->assertJsonPath('data.0.decision_available', false);
    }

    public function test_candidate_snapshot_is_not_readable_by_a_nonparticipant(): void
    {
        $owner = $this->account();
        $viewer = $this->account();
        $outsider = $this->account();
        $this->friends($owner, $viewer);
        $this->publish($owner, 'Approved summary');
        $proposal = $this->proposal($owner, $viewer);
        $snapshots = app(CandidateShowcaseSnapshot::class);
        $snapshots->capture($proposal);

        self::assertNull($snapshots->read($proposal, (int) $outsider->id, (int) $owner->id));
    }
}
