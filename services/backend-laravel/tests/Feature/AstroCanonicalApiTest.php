<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\UserAstroProfile;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AstroCanonicalApiTest extends TestCase
{
    use RefreshDatabase;

    private function fakePythonAstroService(): void
    {
        Http::fake([
            'http://127.0.0.1:8002/api/v1/profile/astro/render*' => Http::response([
                'ok' => true,
                'profile' => [
                    'chart_data' => ['subject' => ['name' => 'EliteSync']],
                    'planets_data' => [
                        ['key' => 'sun', 'name' => '太阳', 'sign' => '狮子座', 'house' => '1'],
                    ],
                    'houses_data' => [
                        ['index' => 1, 'name' => '1宫', 'sign' => '白羊座'],
                        ['index' => 2, 'name' => '2宫', 'sign' => '金牛座'],
                        ['index' => 3, 'name' => '3宫', 'sign' => '双子座'],
                        ['index' => 4, 'name' => '4宫', 'sign' => '巨蟹座'],
                        ['index' => 5, 'name' => '5宫', 'sign' => '狮子座'],
                        ['index' => 6, 'name' => '6宫', 'sign' => '处女座'],
                        ['index' => 7, 'name' => '7宫', 'sign' => '天秤座'],
                        ['index' => 8, 'name' => '8宫', 'sign' => '天蝎座'],
                        ['index' => 9, 'name' => '9宫', 'sign' => '射手座'],
                        ['index' => 10, 'name' => '10宫', 'sign' => '摩羯座'],
                        ['index' => 11, 'name' => '11宫', 'sign' => '水瓶座'],
                        ['index' => 12, 'name' => '12宫', 'sign' => '双鱼座'],
                    ],
                    'aspects_data' => [
                        ['p1_name' => '太阳', 'p2_name' => '月亮', 'aspect' => '合相'],
                    ],
                    'route_mode' => 'standard',
                    'engine_info' => [
                        'engine_name' => 'kerykeion',
                        'engine_version' => '5.12.7',
                        'schema_version' => 'astro_engine_mvp_v1',
                        'chart_kind' => 'natal',
                    ],
                    'metadata' => [
                        'schema_version' => 'astro_engine_mvp_v1',
                        'engine_name' => 'kerykeion',
                        'engine_version' => '5.12.7',
                        'chart_kind' => 'natal',
                        'field_roles' => [
                            'canonical' => ['birthday', 'birth_time', 'birth_place', 'birth_lat', 'birth_lng', 'tz_str'],
                            'derived' => ['chart_data', 'planets_data', 'houses_data', 'aspects_data', 'generated_at'],
                            'display_only' => ['route_mode'],
                        ],
                        'route_context' => [
                            'route_mode' => 'standard',
                            'route_preset' => 'standard',
                            'source' => 'display_only',
                        ],
                    ],
                    'generated_at' => '2026-04-02T00:00:00Z',
                ],
            ], 200),
            'http://127.0.0.1:8002/api/v1/profile/astro/pair*' => Http::response([
                'ok' => true,
                'profile' => [
                    'chart_data' => [
                        'chart_type' => 'Synastry',
                        'first_subject' => ['name' => 'Alice'],
                        'second_subject' => ['name' => 'Bob'],
                        'aspects' => [
                            ['p1_name' => 'Sun', 'p2_name' => 'Moon', 'aspect' => 'trine'],
                        ],
                        'relationship_score' => [
                            'score_value' => 12,
                            'score_description' => 'Important',
                        ],
                    ],
                    'primary_subject' => ['name' => 'Alice', 'city' => '北京', 'nation' => 'CN'],
                    'secondary_subject' => ['name' => 'Bob', 'city' => '上海', 'nation' => 'CN'],
                    'primary_planets_data' => [['key' => 'sun', 'name' => '太阳', 'sign' => '狮子座']],
                    'primary_houses_data' => [['index' => 1, 'name' => '1宫', 'sign' => '白羊座']],
                    'secondary_planets_data' => [['key' => 'sun', 'name' => '太阳', 'sign' => '天秤座']],
                    'secondary_houses_data' => [['index' => 1, 'name' => '1宫', 'sign' => '天秤座']],
                    'aspects_data' => [
                        ['p1_name' => 'Sun', 'p2_name' => 'Moon', 'aspect' => 'trine'],
                    ],
                    'house_comparison' => ['shared_signs' => 3],
                    'relationship_score' => ['score_value' => 12, 'score_description' => 'Important'],
                    'pair_mode' => 'synastry',
                    'advanced_mode' => 'pair',
                    'advanced_summary' => [
                        'advanced_mode' => 'pair',
                        'pair_mode' => 'synastry',
                        'aspects_count' => 1,
                    ],
                    'route_mode' => 'standard',
                    'engine_info' => [
                        'engine_name' => 'kerykeion',
                        'engine_version' => '5.12.7',
                        'schema_version' => 'astro_engine_mvp_v1',
                        'chart_kind' => 'synastry',
                        'advanced_mode' => 'pair',
                    ],
                    'metadata' => [
                        'schema_version' => 'astro_engine_mvp_v1',
                        'engine_name' => 'kerykeion',
                        'engine_version' => '5.12.7',
                        'chart_kind' => 'synastry',
                        'route_context' => [
                            'route_mode' => 'standard',
                            'route_preset' => 'standard',
                            'source' => 'display_only',
                        ],
                        'advanced_context' => [
                            'mode' => 'pair',
                            'pair_mode' => 'synastry',
                            'source' => 'derived_only',
                            'scope' => 'preview',
                        ],
                    ],
                    'generated_at' => '2026-04-02T00:00:00Z',
                ],
            ], 200),
            'http://127.0.0.1:8002/api/v1/profile/astro/transit*' => Http::response([
                'ok' => true,
                'profile' => [
                    'chart_data' => [
                        'chart_type' => 'Transit',
                        'first_subject' => ['name' => 'Natal'],
                        'second_subject' => ['name' => 'Transit'],
                        'aspects' => [
                            ['p1_name' => 'Sun', 'p2_name' => 'Saturn', 'aspect' => 'square'],
                        ],
                    ],
                    'primary_subject' => ['name' => 'Natal', 'city' => '北京', 'nation' => 'CN'],
                    'secondary_subject' => ['name' => 'Transit', 'city' => '北京', 'nation' => 'CN'],
                    'primary_planets_data' => [['key' => 'sun', 'name' => '太阳', 'sign' => '狮子座']],
                    'secondary_planets_data' => [['key' => 'sun', 'name' => '太阳', 'sign' => '处女座']],
                    'primary_houses_data' => [['index' => 1, 'name' => '1宫', 'sign' => '白羊座']],
                    'secondary_houses_data' => [['index' => 1, 'name' => '1宫', 'sign' => '天蝎座']],
                    'aspects_data' => [
                        ['p1_name' => 'Sun', 'p2_name' => 'Saturn', 'aspect' => 'square'],
                    ],
                    'advanced_mode' => 'transit',
                    'advanced_summary' => [
                        'advanced_mode' => 'transit',
                        'aspects_count' => 1,
                    ],
                    'route_mode' => 'modern',
                    'engine_info' => [
                        'engine_name' => 'kerykeion',
                        'engine_version' => '5.12.7',
                        'schema_version' => 'astro_engine_mvp_v1',
                        'chart_kind' => 'transit',
                        'advanced_mode' => 'transit',
                    ],
                    'metadata' => [
                        'schema_version' => 'astro_engine_mvp_v1',
                        'engine_name' => 'kerykeion',
                        'engine_version' => '5.12.7',
                        'chart_kind' => 'transit',
                        'route_context' => [
                            'route_mode' => 'modern',
                            'route_preset' => 'modern',
                            'source' => 'display_only',
                        ],
                        'advanced_context' => [
                            'mode' => 'transit',
                            'source' => 'derived_only',
                            'scope' => 'preview',
                        ],
                    ],
                    'generated_at' => '2026-04-02T00:00:00Z',
                ],
            ], 200),
            'http://127.0.0.1:8002/api/v1/profile/astro/return*' => Http::response([
                'ok' => true,
                'profile' => [
                    'chart_data' => [
                        'chart_type' => 'DualReturnChart',
                        'first_subject' => ['name' => 'Natal'],
                        'second_subject' => ['name' => 'Natal Lunar Return'],
                        'aspects' => [
                            ['p1_name' => 'Sun', 'p2_name' => 'Moon', 'aspect' => 'conjunction'],
                        ],
                    ],
                    'primary_subject' => ['name' => 'Natal', 'city' => '北京', 'nation' => 'CN'],
                    'secondary_subject' => ['name' => 'Natal Lunar Return', 'city' => '北京', 'nation' => 'CN'],
                    'primary_planets_data' => [['key' => 'sun', 'name' => '太阳', 'sign' => '狮子座']],
                    'secondary_planets_data' => [['key' => 'sun', 'name' => '太阳', 'sign' => '巨蟹座']],
                    'primary_houses_data' => [['index' => 1, 'name' => '1宫', 'sign' => '白羊座']],
                    'secondary_houses_data' => [['index' => 1, 'name' => '1宫', 'sign' => '摩羯座']],
                    'aspects_data' => [
                        ['p1_name' => 'Sun', 'p2_name' => 'Moon', 'aspect' => 'conjunction'],
                    ],
                    'advanced_mode' => 'return',
                    'advanced_summary' => [
                        'advanced_mode' => 'return',
                        'return_type' => 'Lunar',
                        'return_year' => 2026,
                        'aspects_count' => 1,
                    ],
                    'route_mode' => 'classical',
                    'engine_info' => [
                        'engine_name' => 'kerykeion',
                        'engine_version' => '5.12.7',
                        'schema_version' => 'astro_engine_mvp_v1',
                        'chart_kind' => 'return',
                        'advanced_mode' => 'return',
                    ],
                    'metadata' => [
                        'schema_version' => 'astro_engine_mvp_v1',
                        'engine_name' => 'kerykeion',
                        'engine_version' => '5.12.7',
                        'chart_kind' => 'return',
                        'route_context' => [
                            'route_mode' => 'classical',
                            'route_preset' => 'classical',
                            'source' => 'display_only',
                        ],
                        'advanced_context' => [
                            'mode' => 'return',
                            'return_type' => 'Lunar',
                            'return_year' => 2026,
                            'source' => 'derived_only',
                            'scope' => 'preview',
                        ],
                    ],
                    'generated_at' => '2026-04-02T00:00:00Z',
                ],
            ], 200),
        ]);
    }

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
                    'profile' => $this->fakeNatalChartProfile($marker),
                ], 200);
            },
        ]);
    }

    /**
     * @return array<string,mixed>
     */
    private function fakeNatalChartProfile(string $marker): array
    {
        return [
            'chart_data' => [
                'subject' => [
                    'name' => 'EliteSync',
                    'marker' => $marker,
                ],
            ],
            'planets_data' => [
                ['key' => 'sun', 'name' => '太阳', 'sign' => '狮子座', 'house' => '1'],
            ],
            'houses_data' => [
                ['index' => 1, 'name' => '1宫', 'sign' => '白羊座'],
            ],
            'aspects_data' => [],
            'paid_report_v1' => [
                'version' => 'western_natal_paid_report_v1',
                'scope' => 'selected_western_natal_placidus_fields',
                'house_system' => 'placidus',
                'zodiac_mode' => 'tropical',
                'matching_scoring_status' => 'excluded_from_core_matching',
                'field_status_taxonomy' => [
                    'core_planets' => 'accepted_selected_fields_only',
                    'angles' => 'accepted_selected_fields_only',
                    'house_cusps' => 'accepted_selected_fields_only',
                    'optional_points' => 'reference_only',
                    'mean_node' => 'not_in_paid_report_v1',
                    'matching_scoring' => 'excluded_from_core_matching',
                ],
                'fixture_basis' => [
                    'source' => 'Astro.com / Astrodienst A/B/C field-summary fixtures',
                    'house_system' => 'placidus',
                    'zodiac_type' => 'tropical_inferred_from_astrodienst',
                    'raw_artifacts_committed' => false,
                ],
                'non_claims' => [
                    'full_western_natal_correctness',
                    'matching_scoring_ready',
                ],
            ],
            'route_mode' => 'standard',
            'engine_info' => [
                'engine_name' => 'kerykeion',
                'engine_version' => '5.12.7',
                'schema_version' => 'astro_engine_mvp_v1',
                'chart_kind' => 'natal',
            ],
            'metadata' => [
                'schema_version' => 'astro_engine_mvp_v1',
                'engine_name' => 'kerykeion',
                'engine_version' => '5.12.7',
                'chart_kind' => 'natal',
                'field_roles' => [
                    'canonical' => ['birthday', 'birth_time', 'birth_place', 'birth_lat', 'birth_lng', 'tz_str'],
                    'derived' => ['chart_data', 'planets_data', 'houses_data', 'aspects_data', 'generated_at'],
                    'display_only' => ['route_mode'],
                ],
            ],
            'generated_at' => '2026-04-02T00:00:00Z',
        ];
    }

    public function test_astro_save_uses_server_canonical_engine_without_client_sun_sign(): void
    {
        $this->fakePythonAstroService();

        $user = User::create([
            'phone' => '13800001101',
            'password' => 'secret123',
            'birthday' => '1996-08-18',
            'gender' => 'male',
        ]);

        Sanctum::actingAs($user);

        $res = $this->postJson('/api/v1/profile/astro', [
            'birth_time' => '10:30',
            'birth_place' => '河南南阳',
            'birth_lat' => 33.01,
            'birth_lng' => 112.53,
            // intentionally omit sun_sign to verify server-side canonical generation
            'moon_sign' => '天蝎座',
            'asc_sign' => '狮子座',
        ])->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('profile.birth_time', '10:30')
            ->assertJsonPath('profile.sun_sign', '狮子座')
            ->assertJsonPath('profile.accuracy', 'canonical_server')
            ->assertJsonPath('profile.western_engine', 'legacy_input')
            ->assertJsonPath('profile.western_precision', 'legacy_estimate');

        $this->assertNotSame('10:30', (string) data_get($res->json(), 'profile.true_solar_time'));
        $this->assertNotEmpty(data_get($res->json(), 'profile.true_solar_time'));
        $this->assertSame('河南南阳', data_get($res->json(), 'profile.birth_place'));
        $this->assertNotNull(data_get($res->json(), 'profile.location_shift_minutes'));
        $this->assertNotNull(data_get($res->json(), 'profile.longitude_offset_minutes'));
        $this->assertNotNull(data_get($res->json(), 'profile.equation_of_time_minutes'));
        $this->assertNotEmpty((string) data_get($res->json(), 'profile.position_signature'));

        $this->assertArrayHasKey('chart_data', data_get($res->json(), 'profile'));
        $this->assertSame('standard', data_get($res->json(), 'profile.route_mode'));
        $this->assertSame('kerykeion', data_get($res->json(), 'profile.engine_info.engine_name'));
        $this->assertSame('astro_engine_mvp_v1', data_get($res->json(), 'profile.metadata.schema_version'));
        $this->assertArrayNotHasKey('natal_chart_svg', data_get($res->json(), 'profile'));

        $user->refresh();
        $this->assertNotEmpty($user->private_bazi);
        $this->assertNotEmpty($user->zodiac_animal);
        $this->assertSame('狮子座', $user->public_zodiac_sign);
        $this->assertIsArray($user->private_ziwei);
        $this->assertNotEmpty($user->private_ziwei);
    }

    public function test_bazi_hidden_stems_contract_uses_lunar_php_canonical_source(): void
    {
        $this->fakePythonAstroService();

        $user = User::create([
            'phone' => '13800001109',
            'password' => 'secret123',
            'birthday' => '1989-09-05',
            'gender' => 'male',
        ]);

        Sanctum::actingAs($user);

        $res = $this->postJson('/api/v1/profile/astro', [
            'birth_time' => '14:30',
            'birth_place' => '',
            'moon_sign' => '双鱼座',
            'asc_sign' => '摩羯座',
        ])->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('profile.bazi', '己巳 壬申 戊辰 己未');

        $profile = (array) data_get($res->json(), 'profile', []);
        $pillars = (array) data_get($profile, 'bazi_details.pillars', []);

        $this->assertCount(4, $pillars);
        $this->assertSame('己巳', data_get($pillars, '0.gan_zhi'));
        $this->assertSame('己', data_get($pillars, '0.gan'));
        $this->assertSame('巳', data_get($pillars, '0.zhi'));
        $this->assertSame(['丙', '庚', '戊'], data_get($pillars, '0.hidden_stems'));

        $this->assertSame('壬申', data_get($pillars, '1.gan_zhi'));
        $this->assertSame(['庚', '壬', '戊'], data_get($pillars, '1.hidden_stems'));

        $this->assertSame('戊辰', data_get($pillars, '2.gan_zhi'));
        $this->assertSame(['戊', '乙', '癸'], data_get($pillars, '2.hidden_stems'));

        $this->assertSame('己未', data_get($pillars, '3.gan_zhi'));
        $this->assertSame(['己', '丁', '乙'], data_get($pillars, '3.hidden_stems'));

        $this->assertArrayHasKey('bazi', $profile);
        $this->assertArrayHasKey('da_yun', $profile);
        $this->assertArrayHasKey('liu_nian', $profile);
        $this->assertArrayHasKey('wu_xing', $profile);

        Http::preventStrayRequests();

        $summary = $this->getJson('/api/v1/profile/astro/summary')
            ->assertOk()
            ->assertJsonPath('exists', true)
            ->assertJsonPath('profile.bazi', '己巳 壬申 戊辰 己未');

        $this->assertSame(['丙', '庚', '戊'], data_get($summary->json(), 'profile.bazi_details.pillars.0.hidden_stems'));
        $this->assertSame(['戊', '乙', '癸'], data_get($summary->json(), 'profile.bazi_details.pillars.2.hidden_stems'));
    }

    public function test_cece_p0_ziwei_payload_is_preserved_by_profile_astro_api(): void
    {
        $this->fakePythonAstroService();

        $user = User::create([
            'phone' => '13800001110',
            'password' => 'secret123',
            'birthday' => '1989-09-05',
            'gender' => 'male',
        ]);

        Sanctum::actingAs($user);

        $res = $this->postJson('/api/v1/profile/astro', [
            'birth_time' => '14:30',
            'birth_place' => '白银市景泰县',
            'moon_sign' => '天蝎座',
            'asc_sign' => '射手座',
        ])->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('profile.ziwei.oracle_source', 'cece')
            ->assertJsonPath('profile.ziwei.rule_mouthpiece', 'cece_p0')
            ->assertJsonPath('profile.ziwei.validation_status', 'p0_fixture_supported')
            ->assertJsonPath('profile.ziwei.external_oracle_status', 'not_validated')
            ->assertJsonPath('profile.ziwei.display_only', true)
            ->assertJsonPath('profile.ziwei.scoring_status', 'excluded_from_core_matching')
            ->assertJsonPath('profile.ziwei.flying_star_status.status', 'insufficient_oracle')
            ->assertJsonPath('profile.ziwei.flying_star_status.implementation', 'not_implemented');

        $profile = (array) data_get($res->json(), 'profile', []);
        $ziwei = (array) data_get($profile, 'ziwei', []);

        $this->assertSame('1989-09-05 13:30', data_get($ziwei, 'input_policy.chart_beijing_time'));
        $this->assertSame('未', data_get($ziwei, 'input_policy.time_branch'));
        $this->assertSame('命宫', data_get($ziwei, 'life_palace'));
        $this->assertSame('福德宫', data_get($ziwei, 'body_palace'));
        $this->assertSame('辰', data_get($ziwei, 'body_palace_detail.branch'));
        $this->assertSame('寅', data_get($ziwei, 'life_palace_detail.branch'));
        $this->assertSame(['紫微', '天府'], data_get($ziwei, 'life_palace_detail.main_stars'));
        $this->assertSame(['紫微', '天府'], data_get($this->palaceByName($ziwei, '命宫'), 'main_stars'));
        $this->assertSame('紫微', data_get($this->palaceByName($ziwei, '命宫'), 'main_star'));
        $this->assertSame(['廉贞', '天相'], data_get($this->palaceByName($ziwei, '官禄宫'), 'main_stars'));
        $this->assertSame('寅', data_get($this->palaceByName($ziwei, '命宫'), 'branch'));
        $this->assertSame('庙', data_get($this->palaceByName($ziwei, '官禄宫'), 'star_status_map.天相'));
        $this->assertSame([
            $this->acceptedSihuaRow('化禄', '武曲', '财帛宫', '甲戌'),
            $this->acceptedSihuaRow('化权', '贪狼', '福德宫', '戊辰'),
            $this->acceptedSihuaRow('化科', '天梁', '交友宫', '辛未'),
            $this->acceptedSihuaRow('化忌', '文曲', '子女宫', '乙亥'),
        ], data_get($ziwei, 'four_transformations'));

        $encoded = json_encode($ziwei, JSON_UNESCAPED_UNICODE) ?: '';
        $this->assertStringNotContainsString('已验证', $encoded);
        $this->assertStringNotContainsString('精准', $encoded);
        $this->assertStringNotContainsString('标准紫微地盘', $encoded);

        Http::preventStrayRequests();

        $summary = $this->getJson('/api/v1/profile/astro/summary')
            ->assertOk()
            ->assertJsonPath('exists', true)
            ->assertJsonPath('profile.ziwei.oracle_source', 'cece')
            ->assertJsonPath('profile.ziwei.scoring_status', 'excluded_from_core_matching');

        $summaryZiwei = (array) data_get($summary->json(), 'profile.ziwei', []);
        $this->assertSame(['紫微', '天府'], data_get($this->palaceByName($summaryZiwei, '命宫'), 'main_stars'));
        $this->assertSame('insufficient_oracle', data_get($summary->json(), 'profile.ziwei.flying_star_status.status'));
    }

    public function test_astro_save_changes_bazi_ziwei_and_western_when_birth_place_changes(): void
    {
        $this->fakePythonAstroService();

        $user = User::create([
            'phone' => '13800001103',
            'password' => 'secret123',
            'birthday' => '1996-08-18',
            'gender' => 'male',
        ]);

        Sanctum::actingAs($user);

        $first = $this->postJson('/api/v1/profile/astro', [
            'birth_time' => '10:30',
            'birth_place' => '北京市海淀区中关村',
            'birth_lat' => 39.98,
            'birth_lng' => 116.31,
            'moon_sign' => '天蝎座',
            'asc_sign' => '狮子座',
        ])->assertOk();

        $firstProfile = (array) data_get($first->json(), 'profile', []);
        $this->assertNotEmpty($firstProfile);

        $second = $this->postJson('/api/v1/profile/astro', [
            'birth_time' => '10:30',
            'birth_place' => '新疆维吾尔自治区乌鲁木齐市天山区',
            'birth_lat' => 43.8256,
            'birth_lng' => 87.6168,
            'moon_sign' => '天蝎座',
            'asc_sign' => '狮子座',
        ])->assertOk();

        $secondProfile = (array) data_get($second->json(), 'profile', []);
        $this->assertNotEmpty($secondProfile);

        $this->assertNotSame(
            (string) ($firstProfile['true_solar_time'] ?? ''),
            (string) ($secondProfile['true_solar_time'] ?? '')
        );
        $this->assertNotSame(
            (string) ($firstProfile['bazi'] ?? ''),
            (string) ($secondProfile['bazi'] ?? '')
        );
        $this->assertNotSame(
            (string) data_get($firstProfile, 'ziwei.life_palace', ''),
            (string) data_get($secondProfile, 'ziwei.life_palace', '')
        );
        $this->assertNotSame(
            (string) ($firstProfile['moon_sign'] ?? ''),
            (string) ($secondProfile['moon_sign'] ?? '')
        );
        $this->assertNotSame(
            (string) ($firstProfile['asc_sign'] ?? ''),
            (string) ($secondProfile['asc_sign'] ?? '')
        );
        $this->assertNotSame(
            (int) ($firstProfile['location_shift_minutes'] ?? 0),
            (int) ($secondProfile['location_shift_minutes'] ?? 0)
        );
        $this->assertNotSame(
            (string) ($firstProfile['position_signature'] ?? ''),
            (string) ($secondProfile['position_signature'] ?? '')
        );
        $this->assertArrayHasKey('chart_data', data_get($second->json(), 'profile'));
    }

    public function test_astro_save_falls_back_when_user_birthday_missing(): void
    {
        $this->fakePythonAstroService();

        $user = User::create([
            'phone' => '13800001102',
            'password' => 'secret123',
            'gender' => 'female',
        ]);

        Sanctum::actingAs($user);

        $res = $this->postJson('/api/v1/profile/astro', [
            'birth_time' => '08:15',
            'sun_sign' => '双鱼座',
            'bazi' => '甲子 乙丑 丙寅 丁卯',
        ])->assertOk()
            ->assertJsonPath('ok', true);

        $notes = (array) data_get($res->json(), 'profile.notes', []);
        $this->assertTrue(
            collect($notes)->contains(fn ($n) => str_contains((string) $n, 'canonical_fallback')),
            'fallback marker should exist in notes'
        );
    }

    public function test_astro_summary_endpoint_returns_profile_without_svg_payload(): void
    {
        $this->fakePythonAstroService();

        $user = User::create([
            'phone' => '13800001104',
            'password' => 'secret123',
            'birthday' => '1996-08-18',
            'gender' => 'female',
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/v1/profile/astro', [
            'birth_time' => '09:20',
            'birth_place' => '河南南阳',
            'birth_lat' => 33.01,
            'birth_lng' => 112.53,
            'moon_sign' => '金牛座',
            'asc_sign' => '白羊座',
        ])->assertOk();

        Http::preventStrayRequests();

        $summary = $this->getJson('/api/v1/profile/astro/summary?route_mode=classical')
            ->assertOk()
            ->assertJsonPath('exists', true)
            ->assertJsonMissingPath('profile.natal_chart_svg')
            ->assertJsonPath('profile.birthday', '1996-08-18')
            ->assertJsonPath('profile.birth_place', '河南南阳')
            ->assertJsonPath('profile.accuracy', 'canonical_server');
        $this->assertSame('classical', data_get($summary->json(), 'profile.route_mode'));
    }

    public function test_astro_summary_prefers_current_natal_chart_signs_over_stale_legacy_summary(): void
    {
        Http::fake([
            'http://127.0.0.1:8002/api/v1/profile/astro/render*' => Http::response([
                'ok' => true,
                'profile' => [
                    'chart_data' => ['subject' => ['name' => 'EliteSync', 'marker' => 'current-jingtai-14:30']],
                    'planets_data' => [
                        ['key' => 'sun', 'name' => 'Sun', 'sign' => 'Virgo', 'house' => '9'],
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
            ], 200),
        ]);

        $user = User::create([
            'phone' => '13800001119',
            'password' => 'secret123',
            'birthday' => '1989-09-05',
            'gender' => 'male',
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
            'notes' => ['canonical_accuracy:canonical_server'],
            'computed_at' => now()->subDay(),
        ]);
        Sanctum::actingAs($user);

        $this->getJson('/api/v1/profile/astro/chart')
            ->assertOk()
            ->assertJsonPath('profile.sun_sign', '处女座')
            ->assertJsonPath('profile.moon_sign', '天蝎座')
            ->assertJsonPath('profile.asc_sign', '射手座');

        Http::preventStrayRequests();

        $this->getJson('/api/v1/profile/astro/summary')
            ->assertOk()
            ->assertJsonPath('profile.sun_sign', '处女座')
            ->assertJsonPath('profile.moon_sign', '天蝎座')
            ->assertJsonPath('profile.asc_sign', '射手座')
            ->assertJsonPath('profile.western_summary_source', 'current_natal_chart')
            ->assertJsonPath('profile.western_summary_degraded', false)
            ->assertJsonMissingPath('profile.chart_data');

        Http::assertSentCount(1);
    }

    public function test_astro_chart_endpoint_returns_chart_data_payload(): void
    {
        $this->fakePythonAstroService();

        $user = User::create([
            'phone' => '13800001105',
            'password' => 'secret123',
            'birthday' => '1992-06-16',
            'gender' => 'male',
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/v1/profile/astro', [
            'birth_time' => '11:10',
            'birth_place' => '北京市朝阳区',
            'birth_lat' => 39.9219,
            'birth_lng' => 116.4436,
            'moon_sign' => '天秤座',
            'asc_sign' => '双子座',
        ])->assertOk();

        $this->getJson('/api/v1/profile/astro/chart?route_mode=modern')
            ->assertOk()
            ->assertJsonPath('exists', true)
            ->assertJsonPath('profile.birthday', '1992-06-16')
            ->assertJsonPath('profile.birth_place', '北京市朝阳区')
            ->assertJsonPath('profile.chart_data.subject.name', 'EliteSync')
            ->assertJsonPath('profile.engine_info.schema_version', 'astro_engine_mvp_v1')
            ->assertJsonPath('profile.route_mode', 'modern')
            ->assertJsonPath('profile.metadata.route_context.route_mode', 'modern')
            ->assertJsonPath('profile.metadata.western_natal_policy.zodiac_mode', 'tropical')
            ->assertJsonPath('profile.metadata.western_natal_policy.house_system', 'placidus')
            ->assertJsonPath('profile.metadata.provenance.external_oracle_status', 'not_validated')
            ->assertJsonMissingPath('profile.natal_chart_svg');

        Http::assertSentCount(1);
    }

    public function test_astro_chart_cache_reuses_matching_western_natal_signature(): void
    {
        $this->fakePythonAstroRenderByRequest();

        $user = User::create([
            'phone' => '13800001115',
            'password' => 'secret123',
            'birthday' => '1992-06-16',
            'gender' => 'male',
        ]);
        Sanctum::actingAs($user);

        $first = $this->postJson('/api/v1/profile/astro', [
            'birth_time' => '11:10',
            'birth_place' => '北京市朝阳区',
            'birth_lat' => 39.9219,
            'birth_lng' => 116.4436,
            'moon_sign' => '天秤座',
            'asc_sign' => '双子座',
        ])->assertOk();

        $firstMarker = (string) data_get($first->json(), 'profile.chart_data.subject.marker');
        $firstSignature = (string) data_get($first->json(), 'profile.metadata.input_signature');
        $this->assertNotSame('', $firstMarker);
        $this->assertNotSame('', $firstSignature);

        $second = $this->getJson('/api/v1/profile/astro/chart?route_mode=modern')
            ->assertOk()
            ->assertJsonPath('profile.route_mode', 'modern')
            ->assertJsonPath('profile.metadata.route_context.route_mode', 'modern')
            ->assertJsonPath('profile.metadata.provenance.source', 'python_kerykeion')
            ->assertJsonPath('profile.metadata.western_natal_policy.zodiac_mode', 'tropical')
            ->assertJsonPath('profile.metadata.western_natal_policy.house_system', 'placidus')
            ->assertJsonPath('profile.metadata.provenance.house_truth_status', 'available')
            ->assertJsonPath('profile.paid_report_v1.version', 'western_natal_paid_report_v1')
            ->assertJsonPath('profile.paid_report_v1.house_system', 'placidus')
            ->assertJsonPath('profile.paid_report_v1.matching_scoring_status', 'excluded_from_core_matching')
            ->assertJsonPath('profile.paid_report_v1.field_status_taxonomy.mean_node', 'not_in_paid_report_v1');

        $this->assertSame($firstMarker, (string) data_get($second->json(), 'profile.chart_data.subject.marker'));
        $this->assertSame($firstSignature, (string) data_get($second->json(), 'profile.metadata.input_signature'));
        Http::assertSentCount(1);
    }

    public function test_astro_chart_cache_recomputes_when_house_system_policy_changes_to_placidus(): void
    {
        $this->fakePythonAstroRenderByRequest();

        $user = User::create([
            'phone' => '13800001119',
            'password' => 'secret123',
            'birthday' => '1992-06-16',
            'gender' => 'male',
        ]);
        Sanctum::actingAs($user);

        $first = $this->postJson('/api/v1/profile/astro', [
            'birth_time' => '11:10',
            'birth_place' => '北京市朝阳区',
            'birth_lat' => 39.9219,
            'birth_lng' => 116.4436,
            'moon_sign' => '天秤座',
            'asc_sign' => '双子座',
        ])->assertOk()
            ->assertJsonPath('profile.metadata.western_natal_policy.house_system', 'placidus');

        $signature = (string) data_get($first->json(), 'profile.metadata.input_signature');
        $this->assertNotSame('', $signature);

        $user->forceFill([
            'private_natal_chart' => [
                'chart_data' => ['subject' => ['name' => 'EliteSync', 'marker' => 'old-policy-cache']],
                'metadata' => [
                    'input_signature' => $signature,
                    'western_natal_policy' => [
                        'engine' => 'kerykeion',
                        'zodiac_mode' => 'kerykeion_default_tropical',
                        'house_system' => 'kerykeion_default',
                        'timezone' => 'Asia/Shanghai',
                        'coordinates' => ['lat' => 39.9219, 'lng' => 116.4436],
                        'contract_version' => 'western_natal_v1',
                    ],
                    'provenance' => [
                        'contract_version' => 'western_natal_v1',
                        'house_truth_status' => 'available',
                    ],
                ],
            ],
        ])->save();

        $second = $this->getJson('/api/v1/profile/astro/chart?route_mode=modern')
            ->assertOk()
            ->assertJsonPath('profile.metadata.western_natal_policy.house_system', 'placidus');

        $this->assertNotSame(
            'old-policy-cache',
            (string) data_get($second->json(), 'profile.chart_data.subject.marker')
        );
        Http::assertSentCount(2);
    }

    public function test_astro_chart_cache_rejects_legacy_not_house_truth_cache_even_with_matching_signature(): void
    {
        $this->fakePythonAstroRenderByRequest();

        $user = User::create([
            'phone' => '13800001120',
            'password' => 'secret123',
            'birthday' => '1992-06-16',
            'gender' => 'male',
        ]);
        Sanctum::actingAs($user);

        $first = $this->postJson('/api/v1/profile/astro', [
            'birth_time' => '11:10',
            'birth_place' => '北京市朝阳区',
            'birth_lat' => 39.9219,
            'birth_lng' => 116.4436,
            'moon_sign' => '天秤座',
            'asc_sign' => '双子座',
        ])->assertOk();

        $signature = (string) data_get($first->json(), 'profile.metadata.input_signature');
        $this->assertNotSame('', $signature);

        $user->forceFill([
            'private_natal_chart' => [
                'chart_data' => ['subject' => ['name' => 'EliteSync', 'marker' => 'legacy-not-house-truth']],
                'planets_data' => [
                    ['key' => 'sun', 'name' => 'Sun', 'sign' => 'Cap', 'house' => null],
                ],
                'houses_data' => [
                    ['index' => 1, 'name' => 'First_House', 'sign' => 'Pisces'],
                ],
                'engine' => 'legacy_input',
                'precision' => 'legacy_estimate',
                'metadata' => [
                    'input_signature' => $signature,
                    'western_natal_policy' => [
                        'engine' => 'kerykeion',
                        'zodiac_mode' => 'tropical',
                        'house_system' => 'placidus',
                        'timezone' => 'Asia/Shanghai',
                        'coordinates' => ['lat' => 39.9219, 'lng' => 116.4436],
                        'contract_version' => 'western_natal_v1',
                    ],
                    'provenance' => [
                        'source' => 'legacy_summary_only',
                        'contract_version' => 'western_natal_v1',
                        'house_truth_status' => 'not_house_truth',
                        'external_oracle_status' => 'not_validated',
                    ],
                ],
            ],
        ])->save();

        $second = $this->getJson('/api/v1/profile/astro/chart')
            ->assertOk()
            ->assertJsonPath('profile.metadata.western_natal_policy.house_system', 'placidus')
            ->assertJsonPath('profile.metadata.provenance.house_truth_status', 'available')
            ->assertJsonPath('profile.metadata.provenance.external_oracle_status', 'not_validated');

        $this->assertNotSame(
            'legacy-not-house-truth',
            (string) data_get($second->json(), 'profile.chart_data.subject.marker')
        );
        Http::assertSentCount(2);
    }

    public function test_astro_chart_cache_recomputes_when_birth_input_signature_changes(): void
    {
        $this->fakePythonAstroRenderByRequest();

        $user = User::create([
            'phone' => '13800001116',
            'password' => 'secret123',
            'birthday' => '1992-06-16',
            'gender' => 'male',
        ]);
        Sanctum::actingAs($user);

        $first = $this->postJson('/api/v1/profile/astro', [
            'birth_time' => '11:10',
            'birth_place' => '北京市朝阳区',
            'birth_lat' => 39.9219,
            'birth_lng' => 116.4436,
            'moon_sign' => '天秤座',
            'asc_sign' => '双子座',
        ])->assertOk();

        $second = $this->postJson('/api/v1/profile/astro', [
            'birth_time' => '11:35',
            'birth_place' => '上海市黄浦区',
            'birth_lat' => 31.2304,
            'birth_lng' => 121.4737,
            'moon_sign' => '天秤座',
            'asc_sign' => '双子座',
        ])->assertOk();

        $this->assertNotSame(
            (string) data_get($first->json(), 'profile.chart_data.subject.marker'),
            (string) data_get($second->json(), 'profile.chart_data.subject.marker')
        );
        $this->assertNotSame(
            (string) data_get($first->json(), 'profile.metadata.input_signature'),
            (string) data_get($second->json(), 'profile.metadata.input_signature')
        );

        $user->refresh();
        $this->assertSame(
            (string) data_get($second->json(), 'profile.chart_data.subject.marker'),
            (string) data_get($user->private_natal_chart, 'chart_data.subject.marker')
        );
        Http::assertSentCount(2);
    }

    public function test_astro_chart_old_cache_without_signature_forces_recompute(): void
    {
        $this->fakePythonAstroRenderByRequest();

        $user = User::create([
            'phone' => '13800001117',
            'password' => 'secret123',
            'birthday' => '1992-06-16',
            'gender' => 'male',
            'private_natal_chart' => [
                'chart_data' => ['subject' => ['name' => 'EliteSync', 'marker' => 'old-cache']],
                'metadata' => ['schema_version' => 'astro_engine_mvp_v1'],
            ],
        ]);
        UserAstroProfile::create([
            'user_id' => $user->id,
            'birth_time' => '11:10',
            'birth_place' => '北京市朝阳区',
            'birth_lat' => 39.9219,
            'birth_lng' => 116.4436,
            'sun_sign' => '双子座',
            'moon_sign' => '天秤座',
            'asc_sign' => '双子座',
        ]);
        Sanctum::actingAs($user);

        $res = $this->getJson('/api/v1/profile/astro/chart')->assertOk();

        $this->assertNotSame('old-cache', (string) data_get($res->json(), 'profile.chart_data.subject.marker'));
        $this->assertNotSame('', (string) data_get($res->json(), 'profile.metadata.input_signature'));
        $this->assertSame('python_kerykeion', data_get($res->json(), 'profile.metadata.provenance.source'));
        Http::assertSentCount(1);
    }

    public function test_astro_chart_python_fallback_does_not_claim_house_truth(): void
    {
        Http::fake([
            'http://127.0.0.1:8002/api/v1/profile/astro/render*' => Http::response(['ok' => false], 503),
        ]);

        $user = User::create([
            'phone' => '13800001118',
            'password' => 'secret123',
            'birthday' => '1992-06-16',
            'gender' => 'male',
            'private_natal_chart' => [
                'chart_data' => ['subject' => ['name' => 'EliteSync', 'marker' => 'stale']],
                'metadata' => ['schema_version' => 'astro_engine_mvp_v1'],
            ],
        ]);
        UserAstroProfile::create([
            'user_id' => $user->id,
            'birth_time' => '11:10',
            'birth_place' => '北京市朝阳区',
            'birth_lat' => 39.9219,
            'birth_lng' => 116.4436,
            'sun_sign' => '双子座',
            'moon_sign' => '天秤座',
            'asc_sign' => '双子座',
        ]);
        Sanctum::actingAs($user);

        $this->getJson('/api/v1/profile/astro/chart')
            ->assertOk()
            ->assertJsonPath('profile.house_truth_status', 'not_house_truth')
            ->assertJsonPath('profile.metadata.provenance.source', 'legacy_summary_only')
            ->assertJsonPath('profile.metadata.provenance.degraded', true)
            ->assertJsonMissingPath('profile.planets_data')
            ->assertJsonMissingPath('profile.chart_data');

        Http::assertSentCount(1);
    }

    public function test_astro_pair_endpoint_returns_advanced_context(): void
    {
        $this->fakePythonAstroService();

        $user = User::create([
            'phone' => '13800001106',
            'password' => 'secret123',
            'birthday' => '1992-06-16',
            'gender' => 'female',
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/v1/profile/astro/pair', [
            'pair_mode' => 'synastry',
            'route_mode' => 'standard',
            'first' => [
                'name' => 'Alice',
                'birthday' => '1990-01-01',
                'birth_time' => '12:30',
                'birth_place' => '北京',
                'birth_lat' => 39.9042,
                'birth_lng' => 116.4074,
                'tz_str' => 'Asia/Shanghai',
                'nation' => 'CN',
            ],
            'second' => [
                'name' => 'Bob',
                'birthday' => '1992-06-15',
                'birth_time' => '14:30',
                'birth_place' => '上海',
                'birth_lat' => 31.2304,
                'birth_lng' => 121.4737,
                'tz_str' => 'Asia/Shanghai',
                'nation' => 'CN',
            ],
        ])->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('profile.advanced_mode', 'pair')
            ->assertJsonPath('profile.pair_mode', 'synastry')
            ->assertJsonPath('profile.engine_info.chart_kind', 'synastry')
            ->assertJsonPath('profile.metadata.advanced_context.mode', 'pair')
            ->assertJsonPath('profile.metadata.advanced_context.pair_mode', 'synastry')
            ->assertJsonPath('profile.primary_subject.name', 'Alice')
            ->assertJsonPath('profile.secondary_subject.name', 'Bob');
    }

    public function test_astro_transit_endpoint_returns_advanced_context(): void
    {
        $this->fakePythonAstroService();

        $user = User::create([
            'phone' => '13800001107',
            'password' => 'secret123',
            'birthday' => '1992-06-16',
            'gender' => 'male',
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/v1/profile/astro/transit', [
            'route_mode' => 'modern',
            'natal' => [
                'name' => 'Natal',
                'birthday' => '1990-01-01',
                'birth_time' => '12:30',
                'birth_place' => '北京',
                'birth_lat' => 39.9042,
                'birth_lng' => 116.4074,
                'tz_str' => 'Asia/Shanghai',
                'nation' => 'CN',
            ],
            'transit' => [
                'name' => 'Transit',
                'birthday' => '2026-04-12',
                'birth_time' => '08:00',
                'birth_place' => '北京',
                'birth_lat' => 39.9042,
                'birth_lng' => 116.4074,
                'tz_str' => 'Asia/Shanghai',
                'nation' => 'CN',
            ],
        ])->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('profile.advanced_mode', 'transit')
            ->assertJsonPath('profile.engine_info.chart_kind', 'transit')
            ->assertJsonPath('profile.metadata.advanced_context.mode', 'transit')
            ->assertJsonPath('profile.primary_subject.name', 'Natal')
            ->assertJsonPath('profile.secondary_subject.name', 'Transit');
    }

    public function test_astro_return_endpoint_returns_advanced_context(): void
    {
        $this->fakePythonAstroService();

        $user = User::create([
            'phone' => '13800001108',
            'password' => 'secret123',
            'birthday' => '1992-06-16',
            'gender' => 'female',
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/v1/profile/astro/return', [
            'route_mode' => 'classical',
            'return_year' => 2026,
            'return_type' => 'Lunar',
            'natal' => [
                'name' => 'Natal',
                'birthday' => '1990-01-01',
                'birth_time' => '12:30',
                'birth_place' => '北京',
                'birth_lat' => 39.9042,
                'birth_lng' => 116.4074,
                'tz_str' => 'Asia/Shanghai',
                'nation' => 'CN',
            ],
        ])->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('profile.advanced_mode', 'return')
            ->assertJsonPath('profile.engine_info.chart_kind', 'return')
            ->assertJsonPath('profile.metadata.advanced_context.mode', 'return')
            ->assertJsonPath('profile.metadata.advanced_context.return_type', 'Lunar')
            ->assertJsonPath('profile.metadata.advanced_context.return_year', 2026)
            ->assertJsonPath('profile.primary_subject.name', 'Natal')
            ->assertJsonPath('profile.secondary_subject.name', 'Natal Lunar Return');
    }

    /**
     * @param array<string,mixed> $ziwei
     * @return array<string,mixed>
     */
    private function palaceByName(array $ziwei, string $name): array
    {
        foreach ((array) ($ziwei['palaces'] ?? []) as $palace) {
            $palace = (array) $palace;
            if (($palace['name'] ?? null) === $name || ($palace['palace_name'] ?? null) === $name) {
                return $palace;
            }
        }

        $this->fail("Missing palace {$name}");
    }

    /**
     * @return array<string,mixed>
     */
    private function acceptedSihuaRow(string $transform, string $star, string $palace, string $branch): array
    {
        return [
            'transform' => $transform,
            'star' => $star,
            'palace' => $palace,
            'branch' => $branch,
            'status' => 'accepted_oracle',
            'source_app' => 'wenmo_tianji_pro',
            'evidence_source' => '6.3d_wenmo_screenshots',
            'adjudication_source' => '6.3e_gpt_advisor_visual_adjudication',
            'display_only' => true,
            'matching_policy' => 'display_only_no_matching_scoring',
        ];
    }
}
