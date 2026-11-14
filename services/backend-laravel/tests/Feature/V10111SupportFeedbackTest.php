<?php

namespace Tests\Feature;

use App\Models\SupportFeedback;
use App\Models\User;
use App\Services\Accounts\DeviceSessions;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Tests\TestCase;

final class V10111SupportFeedbackTest extends TestCase
{
    use RefreshDatabase;

    private function user(string $phone = '19900111201', string $role = 'user'): User
    {
        return User::create(['phone' => $phone, 'password' => 'Fictional123', 'role' => $role]);
    }

    private function body(): array
    {
        return ['request_key' => (string) Str::uuid(), 'source' => 'settings',
            'category' => 'bug_report', 'content' => 'Fictional feedback <script>alert(1)</script>'];
    }

    private function authenticate(User $user): void
    {
        $this->app['auth']->forgetGuards();
        $this->withToken(app(DeviceSessions::class)->issue($user, 'fictional', true)['access_token']);
    }

    public function test_owner_receipt_is_persistent_private_and_request_key_is_immutable(): void
    {
        $owner = $this->user();
        $this->authenticate($owner);
        $body = $this->body() + ['user_id' => 99999, 'status' => 'CLOSED'];
        $id = $this->postJson('/api/v1/support/feedback', $body)->assertCreated()
            ->assertJsonPath('feedback.status', 'OPEN')->assertJsonMissingPath('feedback.request_key')->json('feedback.id');
        $this->postJson('/api/v1/support/feedback', $body)->assertOk()->assertJsonPath('feedback.id', $id);
        $this->assertDatabaseCount('support_feedback', 1);
        $this->assertDatabaseHas('support_feedback', ['id' => $id, 'user_id' => $owner->id]);
        $body['content'] = 'Different fictional content';
        $this->postJson('/api/v1/support/feedback', $body)->assertConflict();
        $this->getJson('/api/v1/support/feedback/'.$id)->assertOk()->assertJsonPath('feedback.revision', 1)
            ->assertHeader('Cache-Control', 'no-store, private');
        $this->authenticate($this->user('19900111202'));
        $this->getJson('/api/v1/support/feedback/'.$id)->assertNotFound();
        $this->getJson('/api/v1/support/feedback')->assertOk()->assertJsonCount(0, 'items');
    }

    public function test_admin_classification_status_and_public_reply_return_without_internal_material(): void
    {
        $owner = $this->user();
        $this->authenticate($owner);
        $id = $this->postJson('/api/v1/support/feedback', $this->body())->assertCreated()->json('feedback.id');
        $admin = $this->user('19900111299', 'admin');
        config(['app.admin_phones' => [$admin->phone]]);
        $this->actingAs($admin, 'web')->get('/admin/support-feedback/'.$id)->assertOk()
            ->assertDontSee('<script>alert(1)</script>', false)->assertSee('&lt;script&gt;', false);
        $update = ['expected_revision' => 1, 'request_key' => (string) Str::uuid(),
            'category' => 'profile_data', 'status' => 'IN_REVIEW', 'public_reply' => 'Fictional public reply',
            'internal_note' => 'PRIVATE_INTERNAL_NOTE', 'confirm' => 1];
        $this->post('/admin/support-feedback/'.$id, $update)->assertRedirect('/admin/support-feedback/'.$id);
        $this->post('/admin/support-feedback/'.$id, $update)->assertRedirect();
        $this->assertDatabaseCount('support_feedback_updates', 1);
        $this->assertDatabaseHas('support_feedback', ['id' => $id, 'revision' => 2, 'status' => 'IN_REVIEW']);
        $update['request_key'] = (string) Str::uuid();
        $this->post('/admin/support-feedback/'.$id, $update)->assertConflict();
        $this->app['auth']->forgetGuards();
        $this->authenticate($owner);
        $this->getJson('/api/v1/support/feedback/'.$id)->assertOk()
            ->assertJsonPath('feedback.public_reply', 'Fictional public reply')
            ->assertJsonPath('feedback.category', 'profile_data')->assertJsonPath('feedback.revision', 2)
            ->assertJsonMissingPath('feedback.updates.0.actor_user_id')
            ->assertJsonMissingPath('feedback.updates.0.internal_note')->assertDontSee('PRIVATE_INTERNAL_NOTE');
    }

    public function test_admin_access_is_required_and_disabled_or_invalid_submissions_are_rejected(): void
    {
        $owner = $this->user();
        $this->actingAs($owner, 'web')->get('/admin/support-feedback')->assertForbidden();
        $this->app['auth']->forgetGuards();
        $this->authenticate($owner);
        $body = $this->body();
        $body['content'] = '   ';
        $this->postJson('/api/v1/support/feedback', $body)->assertUnprocessable();
        $body = $this->body();
        $body['category'] = 'security_case_access';
        $this->postJson('/api/v1/support/feedback', $body)->assertUnprocessable();
        $owner->forceFill(['disabled' => true])->save();
        $this->postJson('/api/v1/support/feedback', $this->body())->assertForbidden();
        $this->assertDatabaseCount('support_feedback', 0);
    }

    public function test_history_has_a_bounded_owner_cursor_and_omits_body_and_hashes(): void
    {
        $owner = $this->user();
        $this->authenticate($owner);
        for ($index = 0; $index < 22; $index++) {
            SupportFeedback::create(['user_id' => $owner->id, 'request_key' => (string) Str::uuid(),
                'request_hash' => str_repeat('a', 64), 'source' => 'settings', 'category' => 'bug_report',
                'content' => 'Fictional pagination fixture', 'status' => 'OPEN', 'revision' => 1]);
        }
        $page = $this->getJson('/api/v1/support/feedback')->assertOk()->assertJsonCount(20, 'items')
            ->assertJsonMissingPath('items.0.content')->assertJsonMissingPath('items.0.request_hash');
        $this->getJson('/api/v1/support/feedback?before_id='.$page->json('next_before_id'))->assertOk()
            ->assertJsonCount(2, 'items')->assertJsonPath('next_before_id', null);
        $this->getJson('/api/v1/support/feedback?before_id=-1')->assertUnprocessable();
    }
}
