<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ProfileNicknameApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_nickname_only_save_needs_no_birth_inputs_and_cannot_update_other_fields_or_user(): void
    {
        $user = User::create(['phone' => '90123457101', 'password' => 'fixture123', 'name' => '旧昵称', 'city' => '原城市', 'birthday' => null]);
        $other = User::create(['phone' => '90123457102', 'password' => 'fixture123', 'name' => '另一人']);
        $baseline = $user->fresh()->getAttributes();
        Sanctum::actingAs($user);

        $this->postJson('/api/v1/profile/nickname', [
            'name' => '新昵称', 'user_id' => $other->id, 'city' => '不应提交',
            'birthday' => '1990-01-01', 'realname_verified' => true,
        ])->assertOk()->assertJsonPath('ok', true)->assertJsonPath('name', '新昵称');
        $this->getJson('/api/v1/profile/basic')->assertOk()->assertJsonPath('name', '新昵称');
        $actual = $user->fresh()->getAttributes();
        unset($baseline['name'], $baseline['updated_at'], $actual['name'], $actual['updated_at']);
        self::assertSame($baseline, $actual);
        self::assertSame('另一人', $other->fresh()->name);
        self::assertSame(0, $user->astroProfile()->count());
    }

    public function test_blank_or_oversized_nickname_is_rejected_without_change(): void
    {
        $user = User::create(['phone' => '90123457103', 'password' => 'fixture123', 'name' => '保留昵称']);
        Sanctum::actingAs($user);
        foreach (['', '   ', str_repeat('名', 256)] as $name) {
            $this->postJson('/api/v1/profile/nickname', ['name' => $name])->assertUnprocessable();
            self::assertSame('保留昵称', $user->fresh()->name);
        }
    }

    public function test_nickname_requires_authentication(): void
    {
        $this->postJson('/api/v1/profile/nickname', ['name' => '虚构昵称'])->assertUnauthorized();
    }
}
