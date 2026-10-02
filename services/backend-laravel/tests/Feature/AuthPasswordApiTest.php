<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\UserAstroProfile;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AuthPasswordApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_change_password_success_and_login_with_new_password(): void
    {
        $user = User::create([
            'phone' => '13800000911',
            'password' => 'secret123',
            'private_birth_place' => '广东省深圳市南山区',
            'private_birth_lat' => 22.5431,
            'private_birth_lng' => 114.0579,
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/v1/auth/password', [
            'current_password' => 'secret123',
            'new_password' => 'newpass123',
            'new_password_confirmation' => 'newpass123',
        ])->assertOk()->assertJsonPath('ok', true);

        $this->postJson('/api/v1/auth/login', [
            'phone' => '13800000911',
            'password' => 'newpass123',
        ])->assertOk()
            ->assertJsonPath('user.birth_place', '广东省深圳市南山区')
            ->assertJsonPath('user.private_birth_place', '广东省深圳市南山区')
            ->assertJsonPath('user.birth_lat', 22.5431)
            ->assertJsonPath('user.birth_lng', 114.0579);
    }

    public function test_login_prefers_profile_birth_place_when_private_value_is_blank(): void
    {
        $user = User::create([
            'phone' => '13800000915',
            'password' => 'secret123',
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/v1/profile/basic', [
            'gender' => 'male',
            'city' => '南京市',
            'relationship_goal' => 'dating',
            'birth_place' => '江苏省南京市玄武区',
            'birth_lat' => 32.0603,
            'birth_lng' => 118.7969,
            'birth_time' => '12:00',
        ])->assertOk()
            ->assertJsonPath('user.birth_place', '江苏省南京市玄武区');

        $user->refresh();
        $user->private_birth_place = '';
        $user->save();

        UserAstroProfile::query()->where('user_id', $user->id)->update([
            'birth_place' => '江苏省南京市玄武区',
        ]);

        Sanctum::actingAs($user);
        $this->getJson('/api/v1/profile/basic')
            ->assertOk()
            ->assertJsonPath('birth_place', '江苏省南京市玄武区');

        $this->postJson('/api/v1/auth/login', [
            'phone' => '13800000915',
            'password' => 'secret123',
        ])->assertOk()
            ->assertJsonPath('user.birth_place', '江苏省南京市玄武区')
            ->assertJsonPath('user.private_birth_place', '江苏省南京市玄武区')
            ->assertJsonPath('user.birth_lat', 32.0603)
            ->assertJsonPath('user.birth_lng', 118.7969);
    }

    public function test_login_and_basic_profile_choose_private_birth_place_when_both_sources_conflict(): void
    {
        $user = User::create([
            'phone' => '90123457001',
            'password' => 'synthetic123',
            'private_birth_place' => '虚构主记录地点甲',
        ]);
        UserAstroProfile::create([
            'user_id' => $user->id,
            'birth_time' => '12:00',
            'birth_place' => '虚构资料地点乙',
            'sun_sign' => 'synthetic',
        ]);

        Sanctum::actingAs($user);
        $this->getJson('/api/v1/profile/basic')
            ->assertOk()
            ->assertJsonPath('birth_place', '虚构主记录地点甲');

        $this->postJson('/api/v1/auth/login', [
            'phone' => '90123457001',
            'password' => 'synthetic123',
        ])->assertOk()
            ->assertJsonPath('user.birth_place', '虚构主记录地点甲')
            ->assertJsonPath('user.private_birth_place', '虚构主记录地点甲');
    }

    public function test_login_accepts_runtime_bcrypt_hash_without_rewriting_it_and_rejects_wrong_password(): void
    {
        $password = 'syntheticCorrect123';
        $user = User::create([
            'phone' => '90123457002',
            'password' => 'syntheticBootstrap123',
        ]);
        $externalHash = password_hash($password, PASSWORD_BCRYPT);
        self::assertIsString($externalHash);

        DB::table('users')->where('id', $user->id)->update(['password' => $externalHash]);
        self::assertSame($externalHash, DB::table('users')->where('id', $user->id)->value('password'));

        $tokensBefore = DB::table('personal_access_tokens')->count();
        $wrong = $this->postJson('/api/v1/auth/login', [
            'phone' => '90123457002',
            'password' => 'syntheticWrong123',
        ])->assertStatus(422);
        self::assertArrayNotHasKey('access_token', $wrong->json());
        self::assertSame($tokensBefore, DB::table('personal_access_tokens')->count());

        $correct = $this->postJson('/api/v1/auth/login', [
            'phone' => '90123457002',
            'password' => $password,
        ])->assertOk();
        self::assertNotEmpty($correct->json('access_token'));
        self::assertSame($externalHash, DB::table('users')->where('id', $user->id)->value('password'));
    }

    public function test_login_rejects_truncated_synthetic_hash_without_token_or_rewrite(): void
    {
        $hash = password_hash('syntheticCorrect123', PASSWORD_BCRYPT);
        self::assertIsString($hash);

        $this->assertMalformedHashCannotLogIn(substr($hash, 0, 20), '90123457003');
    }

    public function test_login_rejects_unsupported_synthetic_hash_without_token_or_rewrite(): void
    {
        $this->assertMalformedHashCannotLogIn('synthetic-unsupported-hash-format', '90123457004');
    }

    public function test_disabled_synthetic_account_still_cannot_log_in(): void
    {
        $user = User::create([
            'phone' => '90123457005',
            'password' => 'syntheticCorrect123',
            'disabled' => true,
        ]);
        $tokensBefore = DB::table('personal_access_tokens')->count();

        $response = $this->postJson('/api/v1/auth/login', [
            'phone' => $user->phone,
            'password' => 'syntheticCorrect123',
        ])->assertStatus(403);

        self::assertArrayNotHasKey('access_token', $response->json());
        self::assertSame($tokensBefore, DB::table('personal_access_tokens')->count());
    }

    private function assertMalformedHashCannotLogIn(string $malformedHash, string $phone): void
    {
        $user = User::create([
            'phone' => $phone,
            'password' => 'syntheticBootstrap123',
        ]);
        DB::table('users')->where('id', $user->id)->update(['password' => $malformedHash]);
        self::assertSame($malformedHash, DB::table('users')->where('id', $user->id)->value('password'));
        $tokensBefore = DB::table('personal_access_tokens')->count();

        $response = $this->postJson('/api/v1/auth/login', [
            'phone' => $phone,
            'password' => 'syntheticCorrect123',
        ])->assertStatus(422)->assertJsonPath('error.code', 'validation_error');

        $payload = $response->json();
        self::assertArrayNotHasKey('access_token', $payload);
        self::assertArrayNotHasKey('exception', $payload);
        self::assertArrayNotHasKey('trace', $payload);
        self::assertStringNotContainsString($malformedHash, $response->getContent());
        self::assertStringNotContainsString('Bcrypt algorithm', $response->getContent());
        self::assertSame($tokensBefore, DB::table('personal_access_tokens')->count());
        self::assertSame($malformedHash, DB::table('users')->where('id', $user->id)->value('password'));
    }

    public function test_login_propagates_unrelated_hash_runtime_exception_without_creating_token(): void
    {
        User::create([
            'phone' => '90123457008',
            'password' => 'syntheticBootstrap123',
        ]);
        $tokensBefore = DB::table('personal_access_tokens')->count();
        $originalHasher = Hash::getFacadeRoot();
        Hash::shouldReceive('check')
            ->once()
            ->andThrow(new \RuntimeException('synthetic unrelated hash verifier failure'));
        $this->withoutExceptionHandling();

        $caught = null;
        try {
            $this->postJson('/api/v1/auth/login', [
                'phone' => '90123457008',
                'password' => 'syntheticCorrect123',
            ]);
        } catch (\RuntimeException $exception) {
            $caught = $exception;
        } finally {
            Hash::swap($originalHasher);
        }

        self::assertInstanceOf(\RuntimeException::class, $caught);
        self::assertSame('synthetic unrelated hash verifier failure', $caught->getMessage());
        self::assertSame($tokensBefore, DB::table('personal_access_tokens')->count());
    }

    public function test_change_password_rejects_wrong_current_password(): void
    {
        $user = User::create([
            'phone' => '13800000912',
            'password' => 'secret123',
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/v1/auth/password', [
            'current_password' => 'wrong123',
            'new_password' => 'newpass123',
            'new_password_confirmation' => 'newpass123',
        ])->assertStatus(422)
            ->assertJsonPath('error.code', 'validation_error');
    }

    public function test_change_password_rejects_truncated_synthetic_hash_without_rewriting_it(): void
    {
        $user = User::create([
            'phone' => '90123457006',
            'password' => 'syntheticBootstrap123',
        ]);
        $hash = password_hash('syntheticCorrect123', PASSWORD_BCRYPT);
        self::assertIsString($hash);
        $malformedHash = substr($hash, 0, 20);
        DB::table('users')->where('id', $user->id)->update(['password' => $malformedHash]);
        $user->refresh();
        Sanctum::actingAs($user);

        $response = $this->postJson('/api/v1/auth/password', [
            'current_password' => 'syntheticCorrect123',
            'new_password' => 'syntheticNew123',
            'new_password_confirmation' => 'syntheticNew123',
        ])->assertStatus(422)->assertJsonPath('error.code', 'validation_error');

        $payload = $response->json();
        self::assertArrayNotHasKey('access_token', $payload);
        self::assertArrayNotHasKey('exception', $payload);
        self::assertArrayNotHasKey('trace', $payload);
        self::assertStringNotContainsString($malformedHash, $response->getContent());
        self::assertStringNotContainsString('Bcrypt algorithm', $response->getContent());
        self::assertSame($malformedHash, DB::table('users')->where('id', $user->id)->value('password'));
    }

    public function test_change_password_rejects_weak_new_password(): void
    {
        $user = User::create([
            'phone' => '13800000913',
            'password' => 'secret123',
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/v1/auth/password', [
            'current_password' => 'secret123',
            'new_password' => '12345678',
            'new_password_confirmation' => '12345678',
        ])->assertStatus(422)
            ->assertJsonPath('error.code', 'validation_error');
    }

    public function test_delete_self_only_allows_smoke_accounts(): void
    {
        $smokeUser = User::create([
            'phone' => '90123456789',
            'name' => 'SmokeUser',
            'password' => 'secret123',
        ]);

        Sanctum::actingAs($smokeUser);

        $this->deleteJson('/api/v1/auth/account', [
            'current_password' => 'secret123',
        ])->assertOk()->assertJsonPath('ok', true);

        $this->assertDatabaseMissing('users', [
            'phone' => '90123456789',
        ]);

        $realUser = User::create([
            'phone' => '13800000914',
            'password' => 'secret123',
        ]);

        Sanctum::actingAs($realUser);

        $this->deleteJson('/api/v1/auth/account', [
            'current_password' => 'secret123',
        ])->assertStatus(403);
    }

    public function test_synthetic_delete_rejects_unsupported_hash_without_removing_account_or_token(): void
    {
        $user = User::create([
            'phone' => '90123457007',
            'password' => 'syntheticBootstrap123',
            'is_synthetic' => true,
        ]);
        $tokenId = $user->createToken('synthetic-access')->accessToken->getKey();
        $malformedHash = 'synthetic-unsupported-hash-format';
        DB::table('users')->where('id', $user->id)->update(['password' => $malformedHash]);
        $user->refresh();
        Sanctum::actingAs($user);
        $tokensBefore = DB::table('personal_access_tokens')->count();

        $response = $this->deleteJson('/api/v1/auth/account', [
            'current_password' => 'syntheticCorrect123',
        ])->assertStatus(422)->assertJsonPath('error.code', 'validation_error');

        $payload = $response->json();
        self::assertArrayNotHasKey('exception', $payload);
        self::assertArrayNotHasKey('trace', $payload);
        self::assertStringNotContainsString($malformedHash, $response->getContent());
        self::assertStringNotContainsString('Bcrypt algorithm', $response->getContent());
        self::assertTrue(DB::table('users')->where('id', $user->id)->exists());
        self::assertSame($malformedHash, DB::table('users')->where('id', $user->id)->value('password'));
        self::assertTrue(DB::table('personal_access_tokens')->where('id', $tokenId)->exists());
        self::assertSame($tokensBefore, DB::table('personal_access_tokens')->count());
    }
}
