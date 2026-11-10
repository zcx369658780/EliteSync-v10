<?php

namespace Tests\Feature;

use App\Models\MediaAsset;
use App\Models\ChatMessage;
use App\Models\MessageAttachment;
use App\Models\User;
use App\Services\Admin\UserGovernance;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

/**
 * Endpoint/side-effect regression coverage. SQLite does not reproduce MariaDB
 * REPEATABLE READ snapshots or lock waits; the separate concurrency harness does.
 */
class V1011R1AuthorizationTest extends TestCase
{
    use RefreshDatabase;

    private const PRIVATE_BODY = 'R1 fictional private body must not escape';
    private const PRIVATE_BYTES = 'R1 fictional private image bytes';

    private function fixture(): array
    {
        config(['restoration.enabled' => true]);
        Storage::fake('v1011_relationship');
        $owner = User::factory()->create(['phone' => fake()->unique()->numerify('138########'), 'role' => 'user', 'account_type' => 'normal', 'disabled' => false]);
        $viewer = User::factory()->create(['phone' => fake()->unique()->numerify('138########'), 'role' => 'user', 'account_type' => 'normal', 'disabled' => false]);
        DB::table('friendships')->insert([
            'user_a' => min($owner->id, $viewer->id),
            'user_b' => max($owner->id, $viewer->id),
            'state' => 'ACTIVE', 'revision' => 1,
            'created_at' => now(), 'updated_at' => now(),
        ]);
        $asset = MediaAsset::create([
            'owner_user_id' => $owner->id, 'media_type' => 'image',
            'storage_provider' => 'local', 'storage_disk' => 'v1011_relationship',
            'storage_key' => 'r1/'.$owner->id.'/cover.jpg',
            'original_name' => 'cover.jpg', 'mime_type' => 'image/jpeg',
            'size_bytes' => strlen(self::PRIVATE_BYTES), 'status' => 'ready',
            'public_url' => null, 'uploaded_at' => now(), 'processed_at' => now(),
        ]);
        Storage::disk('v1011_relationship')->put($asset->storage_key, self::PRIVATE_BYTES);
        $postId = $this->actingAs($owner, 'sanctum')->postJson('/api/v1/status/posts', [
            'title' => 'R1 fictional private title', 'body' => self::PRIVATE_BODY,
            'audience' => 'FRIENDS', 'cover_media_asset_id' => $asset->id,
        ])->assertCreated()->json('item.id');

        return [$owner, $viewer, $asset, (int) $postId];
    }

    private function revoke(string $kind, User $owner, User $viewer, int $postId): void
    {
        $this->actingAs($owner, 'sanctum');
        match ($kind) {
            'SELF' => $this->putJson("/api/v1/status/posts/$postId/audience", ['audience' => 'SELF'])->assertOk(),
            'unfriend' => $this->deleteJson("/api/v1/social/friends/{$viewer->id}")->assertOk(),
            'block' => $this->postJson('/api/v1/moderation/blocks', ['blocked_user_id' => $viewer->id])->assertOk(),
        };
    }

    private function effects(int $postId): array
    {
        return [
            'likes' => DB::table('status_post_likes')->where('status_post_id', $postId)->orderBy('id')->get()->toJson(),
            'events' => DB::table('app_events')->count(),
            'notifications' => DB::table('notifications')->count(),
        ];
    }

    public function test_authorized_cover_like_and_unlike_still_succeed(): void
    {
        [$owner, $viewer, $asset, $postId] = $this->fixture();
        $this->actingAs($viewer, 'sanctum');
        $image = $this->get('/api/v1/media/'.$asset->id.'/content')->assertOk();
        $this->assertSame(self::PRIVATE_BYTES, file_get_contents($image->baseResponse->getFile()->getPathname()));
        $this->postJson("/api/v1/status/posts/$postId/likes")->assertOk()
            ->assertJsonPath('item.body', self::PRIVATE_BODY)->assertJsonPath('item.liked_by_viewer', true);
        $this->assertDatabaseHas('status_post_likes', ['status_post_id' => $postId, 'user_id' => $viewer->id]);
        $this->assertDatabaseHas('notifications', ['user_id' => $owner->id, 'kind' => 'status_like']);
        $this->deleteJson("/api/v1/status/posts/$postId/likes")->assertOk()->assertJsonPath('item.liked_by_viewer', false);
        $this->assertDatabaseMissing('status_post_likes', ['status_post_id' => $postId, 'user_id' => $viewer->id]);
    }

    public function test_each_committed_revocation_denies_cover_without_private_bytes(): void
    {
        foreach (['SELF', 'unfriend', 'block'] as $kind) {
            [$owner, $viewer, $asset, $postId] = $this->fixture();
            $this->revoke($kind, $owner, $viewer, $postId);
            $before = $this->effects($postId);
            $response = $this->actingAs($viewer, 'sanctum')->get('/api/v1/media/'.$asset->id.'/content')->assertNotFound();
            $this->assertStringNotContainsString(self::PRIVATE_BYTES, $response->getContent());
            $this->assertSame($before, $this->effects($postId), $kind);
        }
    }

    public function test_each_committed_revocation_denies_like_without_side_effects_or_body(): void
    {
        $this->assertRevokedInteraction(false);
    }

    public function test_each_committed_revocation_denies_unlike_without_side_effects_or_body(): void
    {
        $this->assertRevokedInteraction(true);
    }

    private function assertRevokedInteraction(bool $unlike): void
    {
        foreach (['SELF', 'unfriend', 'block'] as $kind) {
            [$owner, $viewer, $asset, $postId] = $this->fixture();
            if ($unlike) {
                $this->actingAs($viewer, 'sanctum')->postJson("/api/v1/status/posts/$postId/likes")->assertOk();
            }
            $this->revoke($kind, $owner, $viewer, $postId);
            $before = $this->effects($postId);
            $this->actingAs($viewer, 'sanctum');
            $response = ($unlike ? $this->deleteJson("/api/v1/status/posts/$postId/likes")
                : $this->postJson("/api/v1/status/posts/$postId/likes"))->assertNotFound();
            $response->assertJsonMissingPath('item');
            $this->assertStringNotContainsString(self::PRIVATE_BODY, $response->getContent());
            $this->assertSame($before, $this->effects($postId), $kind.($unlike ? ' unlike' : ' like'));
        }
    }

    public function test_owner_delete_revokes_cover_and_interactions(): void
    {
        [$owner, $viewer, $asset, $postId] = $this->fixture();
        $this->actingAs($owner, 'sanctum')->deleteJson("/api/v1/status/posts/$postId")->assertOk();
        $this->assertDatabaseHas('status_posts', ['id' => $postId, 'is_deleted' => true, 'deleted_by_user_id' => $owner->id]);
        $before = $this->effects($postId);
        $this->actingAs($viewer, 'sanctum')->get('/api/v1/media/'.$asset->id.'/content')->assertNotFound();
        $this->postJson("/api/v1/status/posts/$postId/likes")->assertNotFound()->assertJsonMissingPath('item');
        $this->deleteJson("/api/v1/status/posts/$postId/likes")->assertNotFound()->assertJsonMissingPath('item');
        $this->assertSame($before, $this->effects($postId));
    }

    /** Deterministic same-connection identity mutation, not a concurrency proof. */
    private function changeBeforeCoordinatedUsers(string $candidateTable, callable $change): object
    {
        $state = (object) ['candidate_seen' => false, 'fired' => false];
        DB::listen(function ($query) use ($candidateTable, $state) {
            $sql = str_replace(['"', '`'], '', strtolower($query->sql));
            if (str_starts_with($sql, 'select ') && str_contains($sql, 'from '.$candidateTable.' ')) {
                $state->candidate_seen = true;
            }
        });
        DB::connection()->beforeExecuting(function ($sql) use ($state, $change) {
            $sql = str_replace(['"', '`'], '', strtolower($sql));
            if ($state->candidate_seen && ! $state->fired && str_starts_with($sql, 'select * from users ')
                && str_contains($sql, 'order by id asc')) {
                // Disarm before issuing SQL from the hook to avoid recursion.
                $state->fired = true;
                $change();
            }
        });

        return $state;
    }

    public function test_cover_owner_changed_after_candidate_discovery_fails_closed(): void
    {
        [$owner, $viewer, $asset, $postId] = $this->fixture();
        $before = $this->effects($postId);
        $hook = $this->changeBeforeCoordinatedUsers('chat_messages', function () use ($asset, $viewer) {
            DB::table('media_assets')->where('id', $asset->id)->update(['owner_user_id' => $viewer->id]);
        });
        $response = $this->actingAs($viewer, 'sanctum')->get('/api/v1/media/'.$asset->id.'/content')->assertNotFound();
        $this->assertTrue($hook->fired, 'Identity mutation must actually run after discovery.');
        $this->assertStringNotContainsString(self::PRIVATE_BYTES, $response->getContent());
        $this->assertSame($before, $this->effects($postId));
    }

    public function test_like_and_unlike_recheck_candidate_author_before_any_effect(): void
    {
        foreach ([false, true] as $unlike) {
            [$owner, $viewer, $asset, $postId] = $this->fixture();
            if ($unlike) {
                $this->actingAs($viewer, 'sanctum')->postJson("/api/v1/status/posts/$postId/likes")->assertOk();
            }
            $before = $this->effects($postId);
            $hook = $this->changeBeforeCoordinatedUsers('status_posts', function () use ($postId, $viewer) {
                DB::table('status_posts')->where('id', $postId)->update(['author_user_id' => $viewer->id]);
            });
            $this->actingAs($viewer, 'sanctum');
            $response = ($unlike ? $this->deleteJson("/api/v1/status/posts/$postId/likes")
                : $this->postJson("/api/v1/status/posts/$postId/likes"))->assertNotFound();
            $this->assertTrue($hook->fired, 'Author mutation must actually run after discovery.');
            $response->assertJsonMissingPath('item');
            $this->assertStringNotContainsString(self::PRIVATE_BODY, $response->getContent());
            $this->assertSame($before, $this->effects($postId));
        }
    }

    public function test_new_attachment_participant_after_discovery_requires_a_new_request(): void
    {
        [$owner, $viewer, $asset, $postId] = $this->fixture();
        $third = User::factory()->create(['phone' => fake()->unique()->numerify('138########')]);
        $before = $this->effects($postId);
        $hook = $this->changeBeforeCoordinatedUsers('chat_messages', function () use ($owner, $third, $asset) {
            $message = ChatMessage::create([
                'room_id' => 'r1-identity-fixture', 'sender_id' => $owner->id,
                'receiver_id' => $third->id, 'content' => 'R1 fictional attachment',
            ]);
            MessageAttachment::create(['message_id' => $message->id, 'media_asset_id' => $asset->id]);
        });
        // FRIENDS cover access would otherwise remain valid: the denial must
        // come from the newly discovered, unlocked attachment participant.
        $response = $this->actingAs($viewer, 'sanctum')->get('/api/v1/media/'.$asset->id.'/content')->assertNotFound();
        $this->assertTrue($hook->fired, 'Attachment mutation must actually run after discovery.');
        $this->assertStringNotContainsString(self::PRIVATE_BYTES, $response->getContent());
        $this->assertSame($before, $this->effects($postId));
    }

    public function test_owner_delete_coordinates_user_then_post_then_write_in_one_transaction(): void
    {
        [$owner, $viewer, $asset, $postId] = $this->fixture();
        $baselineLevel = DB::connection()->transactionLevel();
        $queries = [];
        DB::listen(function ($query) use (&$queries, $baselineLevel) {
            if ($query->connection->transactionLevel() > $baselineLevel) {
                $queries[] = str_replace(['"', '`'], '', strtolower($query->sql));
            }
        });
        $this->actingAs($owner, 'sanctum')->deleteJson("/api/v1/status/posts/$postId")->assertOk();
        $userIndex = $postIndex = $writeIndex = null;
        foreach ($queries as $index => $sql) {
            if ($userIndex === null && str_starts_with($sql, 'select * from users ')) {
                $userIndex = $index;
            }
            if ($postIndex === null && str_starts_with($sql, 'select * from status_posts ')) {
                $postIndex = $index;
            }
            if ($writeIndex === null && str_starts_with($sql, 'update status_posts ')) {
                $writeIndex = $index;
            }
        }
        // SQLite omits FOR UPDATE; assert transaction and execution order here.
        // Actual locking behavior remains the MariaDB harness's responsibility.
        $this->assertNotNull($userIndex, 'Coordinated user read must occur inside the delete transaction.');
        $this->assertNotNull($postIndex, 'Post must be re-read inside that transaction.');
        $this->assertNotNull($writeIndex);
        $this->assertTrue($userIndex < $postIndex && $postIndex < $writeIndex);
    }

    public function test_governance_and_admin_post_delete_coordinate_lower_owner_id_in_same_order(): void
    {
        [$owner, $viewer, $asset, $postId] = $this->fixture();
        $admin = User::factory()->create([
            'phone' => fake()->unique()->numerify('138########'),
            'role' => 'admin', 'account_type' => 'normal', 'disabled' => false,
        ]);
        $this->assertTrue($owner->id < $admin->id, 'Fixture must expose the actor-first lock inversion.');
        config(['app.admin_phones' => [$admin->phone]]);
        // Existing public posts remain within the explicit admin deletion flow.
        DB::table('status_posts')->where('id', $postId)->update(['visibility' => 'public']);

        $baselineLevel = DB::connection()->transactionLevel();
        $phase = 'target';
        $queries = ['target' => [], 'destroy' => []];
        DB::listen(function ($query) use (&$queries, &$phase, $baselineLevel) {
            $sql = str_replace(['"', '`'], '', strtolower($query->sql));
            if ($query->connection->transactionLevel() > $baselineLevel
                && str_starts_with($sql, 'select * from users ')) {
                $queries[$phase][] = ['sql' => $sql, 'bindings' => $query->bindings];
            }
        });
        $target = DB::transaction(fn () => app(UserGovernance::class)->target($admin, $owner->id));
        $this->assertSame($owner->id, $target->id);

        $phase = 'destroy';
        $this->actingAs($admin, 'sanctum')->deleteJson("/api/v1/status/posts/$postId", [
            'reason' => 'R1 fictional ordered-lock moderation',
            'expected_revision' => 0, 'confirm' => true,
        ])->assertOk();
        foreach (['target', 'destroy'] as $operation) {
            $this->assertCount(1, $queries[$operation], $operation.' must coordinate users in one ordered query.');
            $query = $queries[$operation][0];
            $this->assertStringContainsString('where id in (', $query['sql'], $operation);
            $this->assertStringContainsString('order by id asc', $query['sql'], $operation);
            $ids = array_map('intval', $query['bindings']);
            sort($ids);
            $this->assertSame([(int) $owner->id, (int) $admin->id], $ids, $operation);
        }
        $this->assertDatabaseHas('status_posts', [
            'id' => $postId, 'is_deleted' => true, 'deleted_by_user_id' => $admin->id,
        ]);
        $this->assertDatabaseHas('admin_operation_audits', [
            'actor_user_id' => $admin->id, 'action' => 'status_post.remove',
            'target_type' => 'status_post', 'target_id' => (string) $postId,
            'reason' => 'R1 fictional ordered-lock moderation', 'expected_version' => 0,
        ]);
        // SQL shape/order only: SQLite does not prove FOR UPDATE or lock waits.
    }
}
