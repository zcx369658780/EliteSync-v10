<?php

namespace Tests\Feature;

use App\Models\StatusPost;
use App\Models\User;
use Illuminate\Database\Events\QueryExecuted;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use RuntimeException;
use Tests\TestCase;

final class V1008StatusModerationTest extends TestCase
{
    use RefreshDatabase;

    private function user(string $phone, string $role = 'user'): User
    {
        return User::create(['name' => 'Fictional status actor', 'phone' => $phone,
            'password' => 'fixture-password', 'role' => $role, 'disabled' => false]);
    }

    private function makePost(User $author, string $visibility = 'public'): StatusPost
    {
        return StatusPost::create(['author_user_id' => $author->id, 'title' => 'Fictional public title',
            'body' => 'Do not copy this body into admin audit', 'visibility' => $visibility, 'is_deleted' => false]);
    }

    private function payload(): array
    {
        return ['reason' => 'Fixture public content moderation', 'expected_revision' => 0, 'confirm' => true];
    }

    public function test_admin_delete_requires_confirmation_version_reason_and_records_minimal_audit(): void
    {
        $admin = $this->user('19900000871', 'admin');
        $author = $this->user('19900000872');
        config(['app.admin_phones' => [$admin->phone]]);
        $post = $this->makePost($author);
        $url = '/api/v1/status/posts/'.$post->id;
        $this->actingAs($admin, 'sanctum')->deleteJson($url)->assertUnprocessable();
        $this->deleteJson($url, array_replace($this->payload(), ['confirm' => false]))->assertUnprocessable();
        $this->deleteJson($url, array_replace($this->payload(), ['reason' => ' ']))->assertUnprocessable();
        $this->deleteJson($url, array_replace($this->payload(), ['expected_revision' => 1]))->assertConflict();
        $this->assertFalse($post->fresh()->is_deleted);
        $this->assertDatabaseCount('admin_operation_audits', 0);
        $this->deleteJson($url, $this->payload())->assertOk()->assertJsonPath('ok', true)
            ->assertJsonPath('item.is_deleted', true);
        $this->assertDatabaseHas('status_posts', ['id' => $post->id, 'is_deleted' => true,
            'deleted_by_user_id' => $admin->id]);
        $audit = DB::table('admin_operation_audits')->sole();
        $this->assertSame($admin->id, (int) $audit->actor_user_id);
        $this->assertSame('status_post.remove', $audit->action);
        $this->assertSame('status_post', $audit->target_type);
        $this->assertSame((string) $post->id, $audit->target_id);
        $this->assertSame(0, (int) $audit->expected_version);
        $this->assertSame('Fixture public content moderation', $audit->reason);
        $this->assertSame(['is_deleted' => false, 'revision' => 0], json_decode($audit->before_state, true));
        $this->assertSame(['is_deleted' => true, 'revision' => 1, 'deleted_by_user_id' => $admin->id],
            json_decode($audit->after_state, true));
        $this->deleteJson($url, $this->payload())->assertConflict();
        $this->assertDatabaseCount('admin_operation_audits', 1);
    }

    public function test_current_admin_role_and_whitelist_are_both_required(): void
    {
        $admin = $this->user('19900000873', 'admin');
        $author = $this->user('19900000874');
        config(['app.admin_phones' => [$admin->phone]]);
        $post = $this->makePost($author);
        $this->actingAs($admin, 'sanctum');
        // Keep the authenticated object stale to prove the transaction rereads the database role.
        DB::table('users')->where('id', $admin->id)->update(['role' => 'user']);
        $this->deleteJson('/api/v1/status/posts/'.$post->id, $this->payload())->assertForbidden();
        DB::table('users')->where('id', $admin->id)->update(['role' => 'admin']);
        config(['app.admin_phones' => []]);
        $this->deleteJson('/api/v1/status/posts/'.$post->id, $this->payload())->assertForbidden();
        $this->assertFalse($post->fresh()->is_deleted);
        $this->assertDatabaseCount('admin_operation_audits', 0);
    }

    public function test_author_delete_needs_no_management_payload_and_private_posts_are_not_admin_targets(): void
    {
        $admin = $this->user('19900000875', 'admin');
        $author = $this->user('19900000876');
        config(['app.admin_phones' => [$admin->phone]]);
        $post = $this->makePost($author, 'private');
        $this->actingAs($admin, 'sanctum')->deleteJson('/api/v1/status/posts/'.$post->id,
            $this->payload())->assertForbidden();
        $this->actingAs($author, 'sanctum')->deleteJson('/api/v1/status/posts/'.$post->id)->assertOk()
            ->assertJsonPath('item.is_deleted', true);
        $this->assertDatabaseHas('status_posts', ['id' => $post->id, 'deleted_by_user_id' => $author->id]);
        $this->assertDatabaseCount('admin_operation_audits', 0);
    }

    public function test_audit_failure_rolls_back_the_admin_delete(): void
    {
        $admin = $this->user('19900000877', 'admin');
        $author = $this->user('19900000878');
        config(['app.admin_phones' => [$admin->phone]]);
        $post = $this->makePost($author);
        DB::listen(static function (QueryExecuted $query): void {
            if (str_starts_with(strtolower($query->sql), 'insert') && str_contains($query->sql, 'admin_operation_audits')) {
                throw new RuntimeException('fixture audit failure');
            }
        });
        $this->withoutExceptionHandling();
        try {
            $this->actingAs($admin, 'sanctum')->deleteJson('/api/v1/status/posts/'.$post->id, $this->payload());
            $this->fail('Expected the injected audit write failure');
        } catch (RuntimeException $error) {
            $this->assertSame('fixture audit failure', $error->getMessage());
        }
        $this->assertFalse($post->fresh()->is_deleted);
        $this->assertNull($post->fresh()->deleted_by_user_id);
        $this->assertDatabaseCount('admin_operation_audits', 0);
    }
}
