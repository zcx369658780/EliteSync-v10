<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\UserAstroProfile;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ProfileBasicRecomputeTest extends TestCase
{
    use RefreshDatabase;

    private function fakePythonAstroRenderByRequest(): void
    {
        Http::fake([
            'http://127.0.0.1:8002/api/v1/profile/astro/render*' => function ($request) {
                $body = method_exists($request, 'data')
                    ? (array) $request->data()
                    : (array) json_decode((string) $request->body(), true);
                $marker = implode('|', [
                    (string) ($body['birthday'] ?? ''),
                    (string) ($body['birth_time'] ?? ''),
                    (string) ($body['birth_place'] ?? ''),
                    (string) ($body['birth_lat'] ?? ''),
                    (string) ($body['birth_lng'] ?? ''),
                    (string) ($body['tz_str'] ?? ''),
                ]);

                return Http::response([
                    'ok' => true,
                    'profile' => [
                        'chart_data' => ['subject' => ['name' => 'EliteSync', 'marker' => $marker]],
                        'planets_data' => [
                            ['key' => 'sun', 'name' => 'Sun', 'sign' => 'Vir', 'house' => '1'],
                            ['key' => 'moon', 'name' => 'Moon', 'sign' => 'Scorpio', 'house' => '11'],
                        ],
                        'houses_data' => [
                            ['index' => 1, 'name' => 'First_House', 'sign' => 'Sagittarius'],
                        ],
                        'aspects_data' => [],
                        'engine_info' => [
                            'engine_name' => 'kerykeion',
                            'engine_version' => '5.12.7',
                            'schema_version' => 'astro_engine_mvp_v1',
                            'chart_kind' => 'natal',
                        ],
                        'metadata' => ['schema_version' => 'astro_engine_mvp_v1'],
                        'generated_at' => '2026-05-26T00:00:00Z',
                    ],
                ], 200);
            },
        ]);
    }

    public function test_save_basic_recomputes_existing_astro_profile_with_new_birth_place(): void
    {
        $user = User::create([
            'phone' => '13800001105',
            'password' => 'secret123',
            'birthday' => '1995-05-12',
            'gender' => 'male',
            'city' => '南阳市',
            'relationship_goal' => 'dating',
        ]);

        UserAstroProfile::create([
            'user_id' => $user->id,
            'birth_time' => '09:30',
            'birth_place' => '河南南阳',
            'birth_lat' => 33.01,
            'birth_lng' => 112.53,
            'sun_sign' => '金牛座',
            'moon_sign' => '天蝎座',
            'asc_sign' => '狮子座',
            'bazi' => '甲子 乙丑 丙寅 丁卯',
            'true_solar_time' => '09:28',
            'da_yun' => [],
            'liu_nian' => [],
            'wu_xing' => [],
            'ziwei' => ['engine' => 'ziwei_seed_estimate', 'display_only' => true],
            'notes' => ['canonical_accuracy:canonical_server'],
            'computed_at' => now()->subDay(),
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/v1/profile/basic', [
            'birthday' => '1996-06-13',
            'birth_time' => '10:45',
            'gender' => 'male',
            'city' => '武汉市',
            'relationship_goal' => 'dating',
            'birth_place' => '湖北省武汉市武昌区八一路299号',
            'birth_lat' => 30.5431,
            'birth_lng' => 114.3628,
        ])->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('astro_profile.birth_place', '湖北省武汉市武昌区八一路299号')
            ->assertJsonPath('astro_profile.birth_time', '10:45')
            ->assertJsonPath('user.birthday', '1996-06-13')
            ->assertJsonPath('user.birth_time', '10:45')
            ->assertJsonPath('user.birth_place', '湖北省武汉市武昌区八一路299号');

        $profile = UserAstroProfile::query()->where('user_id', $user->id)->firstOrFail();
        $this->assertSame('10:45', $profile->birth_time);
        $this->assertSame('湖北省武汉市武昌区八一路299号', $profile->birth_place);
        $this->assertSame(30.5431, (float) $profile->birth_lat);
        $this->assertSame(114.3628, (float) $profile->birth_lng);
        $this->assertNotEmpty($profile->notes);
        $this->assertSame('ziwei_seed_estimate', (string) data_get($profile->ziwei, 'engine'));
        $this->assertSame('approximate_not_validated', (string) data_get($profile->ziwei, 'precision'));
        $this->assertSame('not_validated', (string) data_get($profile->ziwei, 'external_oracle_status'));
        $this->assertTrue((bool) data_get($profile->ziwei, 'display_only'));
        $this->assertSame('excluded_from_core_matching', (string) data_get($profile->ziwei, 'scoring_status'));

        $user->refresh();
        $this->assertSame('1996-06-13', optional($user->birthday)->format('Y-m-d'));
        $this->assertSame('湖北省武汉市武昌区八一路299号', $user->private_birth_place);
        $this->assertSame(30.5431, (float) $user->private_birth_lat);
        $this->assertSame(114.3628, (float) $user->private_birth_lng);
        $this->assertNotEmpty($user->private_ziwei);
        $this->assertSame('ziwei_seed_estimate', (string) data_get($user->private_ziwei, 'engine'));
        $this->assertTrue((bool) data_get($user->private_ziwei, 'display_only'));
        $this->assertNotEmpty($user->private_natal_chart);

        $this->getJson('/api/v1/profile/basic')
            ->assertOk()
            ->assertJsonPath('birth_time', '10:45')
            ->assertJsonPath('birth_place', '湖北省武汉市武昌区八一路299号')
            ->assertJsonPath('birth_lat', 30.5431)
            ->assertJsonPath('birth_lng', 114.3628);
    }

    public function test_save_basic_bootstraps_astro_profile_when_missing(): void
    {
        $user = User::create([
            'phone' => '13800001106',
            'password' => 'secret123',
            'birthday' => '1994-04-18',
            'gender' => 'female',
            'city' => '深圳市',
            'relationship_goal' => 'marriage',
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/v1/profile/basic', [
            'birthday' => '1994-04-19',
            'birth_time' => '08:15',
            'gender' => 'female',
            'city' => '深圳市',
            'relationship_goal' => 'marriage',
            'birth_place' => '广东省深圳市南山区深南大道',
            'birth_lat' => 22.5431,
            'birth_lng' => 113.9304,
        ])->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('astro_profile.birth_place', '广东省深圳市南山区深南大道')
            ->assertJsonPath('astro_profile.birth_time', '08:15')
            ->assertJsonPath('user.birth_time', '08:15')
            ->assertJsonPath('user.birth_place', '广东省深圳市南山区深南大道');

        $profile = UserAstroProfile::query()->where('user_id', $user->id)->firstOrFail();
        $this->assertSame('08:15', $profile->birth_time);
        $this->assertSame('广东省深圳市南山区深南大道', $profile->birth_place);
        $this->assertSame(22.5431, (float) $profile->birth_lat);
        $this->assertSame(113.9304, (float) $profile->birth_lng);
        $this->assertNotEmpty($profile->bazi);

        $user->refresh();
        $this->assertSame('广东省深圳市南山区深南大道', $user->private_birth_place);
        $this->assertNotEmpty($user->private_bazi);
        $this->assertNotEmpty($user->private_ziwei);

        $this->getJson('/api/v1/profile/basic')
            ->assertOk()
            ->assertJsonPath('birth_time', '08:15')
            ->assertJsonPath('birth_place', '广东省深圳市南山区深南大道')
            ->assertJsonPath('birth_lat', 22.5431)
            ->assertJsonPath('birth_lng', 113.9304);
    }

    public function test_save_basic_changes_astro_when_birth_place_changes_with_same_birth_time(): void
    {
        $user = User::create([
            'phone' => '13800001107',
            'password' => 'secret123',
            'birthday' => '1996-06-13',
            'gender' => 'male',
            'city' => '上海市',
            'relationship_goal' => 'dating',
        ]);

        UserAstroProfile::create([
            'user_id' => $user->id,
            'birth_time' => '10:45',
            'birth_place' => '上海市黄浦区人民大道200号',
            'birth_lat' => 31.2304,
            'birth_lng' => 121.4737,
            'sun_sign' => '双子座',
            'moon_sign' => '双鱼座',
            'asc_sign' => '处女座',
            'bazi' => '甲子 乙丑 丙寅 丁卯',
            'true_solar_time' => '10:45',
            'da_yun' => [],
            'liu_nian' => [],
            'wu_xing' => [],
            'ziwei' => ['engine' => 'ziwei_seed_estimate', 'life_palace' => '命宫', 'display_only' => true],
            'notes' => ['canonical_accuracy:canonical_server'],
            'computed_at' => now()->subDay(),
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/v1/profile/basic', [
            'birthday' => '1996-06-13',
            'birth_time' => '10:45',
            'gender' => 'male',
            'city' => '上海市',
            'relationship_goal' => 'dating',
            'birth_place' => '新疆维吾尔自治区乌鲁木齐市天山区人民广场',
            'birth_lat' => 43.8256,
            'birth_lng' => 87.6168,
        ])->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('astro_profile.birth_place', '新疆维吾尔自治区乌鲁木齐市天山区人民广场')
            ->assertJsonPath('astro_profile.birth_time', '10:45')
            ->assertJsonPath('user.birth_time', '10:45')
            ->assertJsonPath('user.birth_place', '新疆维吾尔自治区乌鲁木齐市天山区人民广场');

        $profile = UserAstroProfile::query()->where('user_id', $user->id)->firstOrFail();
        $this->assertSame('10:45', $profile->birth_time);
        $this->assertSame('新疆维吾尔自治区乌鲁木齐市天山区人民广场', $profile->birth_place);
        $this->assertSame(43.8256, (float) $profile->birth_lat);
        $this->assertSame(87.6168, (float) $profile->birth_lng);
        $this->assertNotEmpty($profile->true_solar_time);
        $this->assertNotSame('10:45', $profile->true_solar_time);
        $this->assertNotSame('甲子 乙丑 丙寅 丁卯', $profile->bazi);
        $this->assertNotSame('命宫', data_get($profile->ziwei, 'life_palace'));
        $this->assertNotSame('处女座', $profile->asc_sign);

        $user->refresh();
        $this->assertSame('新疆维吾尔自治区乌鲁木齐市天山区人民广场', $user->private_birth_place);
        $this->assertNotSame('甲子 乙丑 丙寅 丁卯', $user->private_bazi);
        $this->assertNotEmpty($user->private_ziwei);

        $this->getJson('/api/v1/profile/basic')
            ->assertOk()
            ->assertJsonPath('birth_time', '10:45')
            ->assertJsonPath('birth_place', '新疆维吾尔自治区乌鲁木齐市天山区人民广场')
            ->assertJsonPath('birth_lat', 43.8256)
            ->assertJsonPath('birth_lng', 87.6168);
    }

    public function test_save_basic_invalidates_stale_western_natal_chart_cache_before_detail_recompute(): void
    {
        $this->fakePythonAstroRenderByRequest();

        $user = User::create([
            'phone' => '13800001108',
            'password' => 'secret123',
            'birthday' => '1989-09-05',
            'gender' => 'male',
            'city' => '南阳',
            'relationship_goal' => 'dating',
            'private_natal_chart' => [
                'chart_data' => ['subject' => ['name' => 'EliteSync', 'marker' => 'old-10:30-beijing']],
                'planets_data' => [
                    ['key' => 'sun', 'name' => 'Sun', 'sign' => 'Cap', 'house' => 'Eleventh_House'],
                ],
                'houses_data' => [
                    ['index' => 1, 'name' => 'First_House', 'sign' => 'Pis'],
                ],
                'metadata' => [
                    'input_signature' => 'old-signature',
                    'western_natal_policy' => [
                        'engine' => 'kerykeion',
                        'zodiac_mode' => 'kerykeion_default_tropical',
                        'house_system' => 'kerykeion_default',
                        'timezone' => 'Asia/Shanghai',
                        'contract_version' => 'western_natal_v1',
                    ],
                    'provenance' => [
                        'contract_version' => 'western_natal_v1',
                        'house_truth_status' => 'available',
                    ],
                ],
            ],
        ]);

        UserAstroProfile::create([
            'user_id' => $user->id,
            'birth_time' => '14:30',
            'birth_place' => '景泰县人民医院',
            'birth_lat' => 37.1833,
            'birth_lng' => 104.0667,
            'sun_sign' => '摩羯座',
            'moon_sign' => '射手座',
            'asc_sign' => '白羊座',
            'bazi' => '己巳 壬申 戊辰 己未',
            'true_solar_time' => '13:28',
            'da_yun' => [],
            'liu_nian' => [],
            'wu_xing' => [],
            'ziwei' => ['engine' => 'ziwei_seed_estimate', 'display_only' => true],
            'notes' => ['canonical_accuracy:canonical_server'],
            'computed_at' => now()->subDay(),
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/v1/profile/basic', [
            'birthday' => '1989-09-05',
            'birth_time' => '14:30',
            'gender' => 'male',
            'city' => '南阳',
            'relationship_goal' => 'dating',
            'birth_place' => '景泰县人民医院',
        ])->assertOk()
            ->assertJsonPath('astro_profile.birth_time', '14:30')
            ->assertJsonPath('astro_profile.birth_place', '景泰县人民医院')
            ->assertJsonPath('user.birth_time', '14:30')
            ->assertJsonPath('user.birth_place', '景泰县人民医院');

        $user->refresh();
        $this->assertSame(
            '1989-09-05|14:30|景泰县人民医院|37.1833|104.0667|Asia/Shanghai',
            (string) data_get($user->private_natal_chart, 'chart_data.subject.marker')
        );
        $this->assertNotEmpty(data_get($user->private_natal_chart, 'planets_data'));
        $this->assertNotEmpty(data_get($user->private_natal_chart, 'houses_data'));
        $this->assertNotSame('', (string) data_get($user->private_natal_chart, 'metadata.input_signature'));
        $this->assertSame('tropical', data_get($user->private_natal_chart, 'metadata.western_natal_policy.zodiac_mode'));
        $this->assertSame('placidus', data_get($user->private_natal_chart, 'metadata.western_natal_policy.house_system'));
        $this->assertSame('available', data_get($user->private_natal_chart, 'metadata.provenance.house_truth_status'));
        $this->assertSame('not_validated', data_get($user->private_natal_chart, 'metadata.provenance.external_oracle_status'));
        $this->assertSame('legacy_input', data_get($user->private_natal_chart, 'engine'));
        $this->assertSame(37.1833, (float) $user->private_birth_lat);
        $this->assertSame(104.0667, (float) $user->private_birth_lng);

        $this->getJson('/api/v1/profile/astro/summary')
            ->assertOk()
            ->assertJsonPath('profile.birth_time', '14:30')
            ->assertJsonPath('profile.birth_place', '景泰县人民医院')
            ->assertJsonPath('profile.moon_sign', '天蝎座')
            ->assertJsonPath('profile.asc_sign', '射手座')
            ->assertJsonPath('profile.western_summary_source', 'current_natal_chart')
            ->assertJsonPath('profile.western_summary_degraded', false)
            ->assertJsonMissingPath('profile.chart_data');

        $chart = $this->getJson('/api/v1/profile/astro/chart')->assertOk();
        $chart->assertJsonPath('profile.birth_time', '14:30')
            ->assertJsonPath('profile.birth_place', '景泰县人民医院')
            ->assertJsonPath('profile.chart_data.subject.marker', '1989-09-05|14:30|景泰县人民医院|37.1833|104.0667|Asia/Shanghai')
            ->assertJsonPath('profile.metadata.western_natal_policy.zodiac_mode', 'tropical')
            ->assertJsonPath('profile.metadata.western_natal_policy.house_system', 'placidus')
            ->assertJsonPath('profile.metadata.provenance.external_oracle_status', 'not_validated');

        $this->assertNotSame(
            'old-10:30-beijing',
            (string) data_get($chart->json(), 'profile.chart_data.subject.marker')
        );
        $this->assertNotSame('', (string) data_get($chart->json(), 'profile.metadata.input_signature'));

        $user->refresh();
        $this->assertSame(
            '1989-09-05|14:30|景泰县人民医院|37.1833|104.0667|Asia/Shanghai',
            (string) data_get($user->private_natal_chart, 'chart_data.subject.marker')
        );

        $this->getJson('/api/v1/profile/astro/summary')
            ->assertOk()
            ->assertJsonPath('profile.birth_time', '14:30')
            ->assertJsonPath('profile.birth_place', '景泰县人民医院')
            ->assertJsonPath('profile.moon_sign', '天蝎座')
            ->assertJsonPath('profile.asc_sign', '射手座')
            ->assertJsonPath('profile.western_summary_source', 'current_natal_chart')
            ->assertJsonPath('profile.western_summary_degraded', false)
            ->assertJsonMissingPath('profile.chart_data');

        Http::assertSentCount(1);
    }

    public function test_save_basic_marks_western_natal_render_failure_without_fake_chart_cache(): void
    {
        Http::fake([
            'http://127.0.0.1:8002/api/v1/profile/astro/render*' => Http::response('internal render error', 500),
        ]);

        $user = User::create([
            'phone' => '13800001109',
            'password' => 'secret123',
            'birthday' => '1989-09-05',
            'gender' => 'male',
            'city' => '南阳',
            'relationship_goal' => 'dating',
            'private_natal_chart' => [
                'chart_data' => ['subject' => ['name' => 'EliteSync', 'marker' => 'stale']],
                'planets_data' => [
                    ['key' => 'sun', 'name' => 'Sun', 'sign' => 'Cap', 'house' => 'Eleventh_House'],
                ],
                'houses_data' => [
                    ['index' => 1, 'name' => 'First_House', 'sign' => 'Pis'],
                ],
            ],
        ]);

        UserAstroProfile::create([
            'user_id' => $user->id,
            'birth_time' => '14:30',
            'birth_place' => '景泰县人民医院',
            'birth_lat' => 37.1833,
            'birth_lng' => 104.0667,
            'sun_sign' => '处女座',
            'moon_sign' => '射手座',
            'asc_sign' => '白羊座',
            'bazi' => '己巳 壬申 戊辰 己未',
            'true_solar_time' => '13:28',
            'da_yun' => [],
            'liu_nian' => [],
            'wu_xing' => [],
            'ziwei' => ['engine' => 'ziwei_seed_estimate', 'display_only' => true],
            'notes' => ['canonical_accuracy:canonical_server'],
            'computed_at' => now()->subDay(),
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/v1/profile/basic', [
            'birthday' => '1989-09-05',
            'birth_time' => '14:30',
            'gender' => 'male',
            'city' => '南阳',
            'relationship_goal' => 'dating',
            'birth_place' => '景泰县人民医院',
        ])->assertOk()
            ->assertJsonPath('ok', true);

        $user->refresh();
        $this->assertEmpty(data_get($user->private_natal_chart, 'chart_data'));
        $this->assertEmpty(data_get($user->private_natal_chart, 'planets_data'));
        $this->assertEmpty(data_get($user->private_natal_chart, 'houses_data'));
        $this->assertSame('render_failed', data_get($user->private_natal_chart, 'house_truth_status'));
        $this->assertSame('render_failed', data_get($user->private_natal_chart, 'metadata.provenance.house_truth_status'));
        $this->assertSame('not_validated', data_get($user->private_natal_chart, 'external_oracle_status'));
        $this->assertSame('not_validated', data_get($user->private_natal_chart, 'metadata.provenance.external_oracle_status'));
        $this->assertSame('tropical', data_get($user->private_natal_chart, 'western_natal_policy.zodiac_mode'));
        $this->assertSame('placidus', data_get($user->private_natal_chart, 'western_natal_policy.house_system'));
        $this->assertNotSame('', (string) data_get($user->private_natal_chart, 'western_natal_input_signature'));

        Http::assertSentCount(1);
    }
}
