<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\Http;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class GeoPlacesApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_natal_search_rejects_unverified_baidu_coordinates_even_with_credentials(): void
    {
        Config::set('natal.place_catalog_path', '');
        Config::set('baidu.web_ak', 'test-web-ak');
        Config::set('baidu.web_sk', 'test-web-sk');
        Http::preventStrayRequests();
        Http::fake([
            'https://api.map.baidu.com/api_place_pro/v1/region*' => Http::response([
                'status' => 0,
                'results' => [[
                    'name' => '天安门城楼',
                    'city' => '北京市',
                    'location' => ['lat' => 39.9150865052, 'lng' => 116.4039459198],
                ]],
            ], 200),
        ]);
        $path = '/api/v1/profile/natal/places';
        $input = ['query' => '天安门城楼', 'region' => '北京市'];
        $this->postJson($path, $input)->assertUnauthorized();
        Sanctum::actingAs(User::create(['phone' => '13800001121', 'password' => 'test-password']));
        $this->postJson($path, $input)->assertStatus(503)
            ->assertHeader('Cache-Control', 'no-store, private')
            ->assertJsonMissingPath('coordinate_system')
            ->assertJsonMissingPath('places');
        Http::assertNothingSent();
        $this->assertDatabaseCount('user_natal_profiles', 0);
    }

    public function test_natal_search_without_service_configuration_stops_before_outbound_request(): void
    {
        Config::set('natal.place_catalog_path', '');
        Config::set('baidu.web_ak', '');
        Config::set('baidu.web_sk', '');
        Http::preventStrayRequests();
        Http::fake();
        Sanctum::actingAs(User::create(['phone' => '13800001122', 'password' => 'test-password']));
        $this->postJson('/api/v1/profile/natal/places', ['query' => '公开测试地点', 'region' => '武汉市'])
            ->assertStatus(503);
        Http::assertNothingSent();
    }

    public function test_natal_search_uses_the_local_catalog_without_outbound_requests_or_writes(): void
    {
        $catalog = tempnam(sys_get_temp_dir(), 'natal-places-');
        Config::set('natal.place_catalog_path', $catalog);
        Config::set('baidu.web_ak', 'test-web-ak');
        Config::set('baidu.web_sk', 'test-web-sk');
        Http::preventStrayRequests();
        Http::fake();
        $campus = [
            'label' => '北京协和医院东单院区', 'address' => '帅府园1号', 'province' => '北京市',
            'city' => '北京市', 'area' => '东城区', 'point_kind' => 'campus', 'lat' => 39.91121, 'lng' => 116.40883,
        ];
        $secondCampus = array_replace($campus, [
            'label' => '北京协和医院西单院区', 'address' => '大木仓胡同41号',
            'area' => '西城区', 'lat' => 39.91161, 'lng' => 116.36141,
        ]);
        file_put_contents($catalog, json_encode([
            'schema_version' => 1,
            'source' => 'OpenStreetMap',
            'coordinate_system' => 'WGS84',
            'regions' => [
                '北京市' => ['aliases' => ['北京'], 'places' => [
                    $campus + ['aliases' => ['北京协和医院', '协和东单']],
                    $secondCampus + ['aliases' => ['北京协和医院']],
                ]],
                '武汉市' => ['aliases' => ['武汉'], 'places' => [
                    array_replace($campus, ['city' => '武汉市']) + ['aliases' => ['北京协和医院']],
                ]],
            ],
        ], JSON_THROW_ON_ERROR));

        try {
            $input = ['query' => '北京协和医院', 'region' => '北京'];
            $this->postJson('/api/v1/profile/natal/places', $input)->assertUnauthorized();
            Sanctum::actingAs(User::create(['phone' => '13800001123', 'password' => 'test-password']));
            $this->postJson('/api/v1/profile/natal/places', $input)->assertStatus(503)
                ->assertJsonMissingPath('places');
            $this->travel(2)->seconds();
            $this->withHeader('X-EliteSync-Natal-Places', 'osm-v1')
                ->postJson('/api/v1/profile/natal/places', $input)->assertOk()
                ->assertHeader('Cache-Control', 'no-store, private')
                ->assertExactJson([
                    'coordinate_system' => 'WGS84', 'source' => 'OpenStreetMap', 'coverage' => 'sample',
                    'places' => [$campus, $secondCampus],
                ]);
            Config::set('natal.baidu_lookup_enabled', true);
            $this->travel(2)->seconds();
            $this->withHeader('X-EliteSync-Natal-Places', 'wgs84-v2')
                ->postJson('/api/v1/profile/natal/places', $input + ['allow_baidu' => true])->assertOk()
                ->assertJsonCount(2, 'places');
            Http::assertNothingSent();
            $this->assertDatabaseCount('user_natal_profiles', 0);
        } finally {
            unlink($catalog);
        }
    }

    public function test_natal_search_keeps_unsupported_regions_and_unmatched_names_empty(): void
    {
        $catalog = tempnam(sys_get_temp_dir(), 'natal-places-');
        Config::set('natal.place_catalog_path', $catalog);
        file_put_contents($catalog, json_encode([
            'schema_version' => 1, 'source' => 'OpenStreetMap', 'coordinate_system' => 'WGS84',
            'regions' => ['北京市' => ['aliases' => ['北京'], 'places' => [[
                'label' => '北京市', 'point_kind' => 'city', 'lat' => 39.90571, 'lng' => 116.39129,
            ]]]],
        ], JSON_THROW_ON_ERROR));
        Sanctum::actingAs(User::create(['phone' => '13800001124', 'password' => 'test-password']));

        try {
            $path = '/api/v1/profile/natal/places';
            $this->withHeader('X-EliteSync-Natal-Places', 'osm-v1');
            $this->postJson($path, ['query' => '北京市', 'region' => '广州市'])->assertOk()
                ->assertJsonPath('places', []);
            $this->travel(2)->seconds();
            $this->postJson($path, ['query' => '北京测试医院', 'region' => '北京市'])->assertOk()
                ->assertJsonPath('places', []);
        } finally {
            unlink($catalog);
        }
    }

    public function test_natal_search_rejects_a_catalog_declared_in_a_different_coordinate_system(): void
    {
        $catalog = tempnam(sys_get_temp_dir(), 'natal-places-');
        Config::set('natal.place_catalog_path', $catalog);
        file_put_contents($catalog, json_encode([
            'schema_version' => 1, 'source' => 'OpenStreetMap', 'coordinate_system' => 'BD09LL', 'regions' => [],
        ], JSON_THROW_ON_ERROR));
        Sanctum::actingAs(User::create(['phone' => '13800001125', 'password' => 'test-password']));

        try {
            $this->withHeader('X-EliteSync-Natal-Places', 'osm-v1')
                ->postJson('/api/v1/profile/natal/places', ['query' => '天安门城楼', 'region' => '北京市'])
                ->assertStatus(503)
                ->assertJsonMissingPath('places');
        } finally {
            unlink($catalog);
        }
    }

    public function test_natal_manual_baidu_lookup_uses_one_call_and_only_independent_wgs84(): void
    {
        $catalog = tempnam(sys_get_temp_dir(), 'natal-areas-');
        $credentials = tempnam(sys_get_temp_dir(), 'natal-baidu-');
        file_put_contents($credentials, "BAIDU_WEB_AK=test-web-ak\nBAIDU_WEB_SK=test-web-sk\n");
        Config::set([
            'natal.place_catalog_path' => '',
            'natal.area_catalog_path' => $catalog,
            'natal.baidu_lookup_enabled' => true,
            'natal.baidu_credentials_path' => $credentials,
        ]);
        file_put_contents($catalog, json_encode([
            'schema_version' => 1, 'source' => 'GeoNames', 'coordinate_system' => 'WGS84',
            'cities' => ['广州市' => [
                'province' => '广东省', 'aliases' => ['广州'], 'lat' => 23.37327, 'lng' => 113.51219,
                'districts' => ['越秀区' => ['aliases' => ['越秀'], 'lat' => 23.12528, 'lng' => 113.26528]],
            ]],
        ], JSON_THROW_ON_ERROR));
        Http::preventStrayRequests();
        Http::fake([
            'https://api.map.baidu.com/place/v3/region*' => Http::sequence()->push([
                'status' => 0,
                'results' => [
                    [
                        'name' => '公开样例医院', 'address' => '样例路1号', 'city' => '广州市',
                        'province' => '广东省', 'area' => '越秀区', 'telephone' => 'not-needed',
                        'location' => ['lat' => 23.14, 'lng' => 113.28],
                    ],
                    ['name' => '别的城市', 'city' => '深圳市', 'province' => '广东省', 'area' => '福田区'],
                ],
            ])->pushStatus(503),
        ]);
        $path = '/api/v1/profile/natal/places';
        $input = ['query' => '公开样例医院', 'region' => '广州', 'allow_baidu' => true, 'birthday' => '1990-01-01'];

        try {
            $this->withHeader('X-EliteSync-Natal-Places', 'wgs84-v2')->postJson($path, $input)->assertUnauthorized();
            Sanctum::actingAs(User::create(['phone' => '13800001126', 'password' => 'test-password']));
            $this->postJson($path, array_replace($input, ['allow_baidu' => false]))->assertStatus(503);
            Http::assertNothingSent();
            $this->travel(2)->seconds();
            $this->postJson($path, $input)->assertOk()
                ->assertHeader('Cache-Control', 'no-store, private')
                ->assertJsonPath('coordinate_system', 'WGS84')
                ->assertJsonPath('lookup_provider', 'Baidu')
                ->assertJsonCount(1, 'places')
                ->assertJsonPath('places.0.label', '越秀区')
                ->assertJsonPath('places.0.point_kind', 'district')
                ->assertJsonPath('places.0.source', 'GeoNames')
                ->assertJsonPath('places.0.approximate', true)
                ->assertJsonPath('places.0.matched_name', '公开样例医院')
                ->assertJsonPath('places.0.lat', 23.12528)
                ->assertJsonPath('places.0.lng', 113.26528)
                ->assertJsonMissingPath('places.0.telephone');
            Http::assertSentCount(1);
            Http::assertSent(function ($request) {
                parse_str((string) parse_url($request->url(), PHP_URL_QUERY), $params);

                return $request->method() === 'GET'
                    && array_keys($params) === ['query', 'region', 'region_limit', 'output', 'ak', 'sn']
                    && $params['query'] === '公开样例医院' && $params['region'] === '广州市'
                    && $params['region_limit'] === 'true' && strlen($params['sn']) === 32;
            });
            $this->travel(2)->seconds();
            $this->postJson($path, $input)->assertStatus(503)->assertJsonMissingPath('places');
            Http::assertSentCount(2);
            $this->assertDatabaseCount('user_natal_profiles', 0);
        } finally {
            unlink($catalog);
            unlink($credentials);
        }
    }

    public function test_natal_city_name_search_uses_the_local_wgs84_city_point_without_baidu(): void
    {
        $catalog = tempnam(sys_get_temp_dir(), 'natal-city-');
        $credentials = tempnam(sys_get_temp_dir(), 'natal-baidu-');
        file_put_contents($credentials, "BAIDU_WEB_AK=test-web-ak\nBAIDU_WEB_SK=test-web-sk\n");
        file_put_contents($catalog, json_encode([
            'schema_version' => 1, 'source' => 'GeoNames', 'coordinate_system' => 'WGS84',
            'cities' => ['09:4113' => [
                'name' => '南阳地区', 'province' => '河南省', 'province_aliases' => ['河南'],
                'aliases' => ['南阳', '南阳市'], 'lat' => 32.96029, 'lng' => 112.40864,
                'districts' => [],
            ]],
        ], JSON_THROW_ON_ERROR));
        Config::set([
            'natal.place_catalog_path' => '',
            'natal.area_catalog_path' => $catalog,
            'natal.baidu_lookup_enabled' => true,
            'natal.baidu_credentials_path' => $credentials,
        ]);
        Http::preventStrayRequests();
        Http::fake([
            'https://api.map.baidu.com/place/v3/region*' => Http::response([
                'status' => 0, 'result_type' => 'region_type',
                'results' => [['name' => '南阳市', 'location' => ['lat' => 33.1, 'lng' => 112.6]]],
            ]),
        ]);
        Sanctum::actingAs(User::create(['phone' => '13800001127', 'password' => 'test-password']));

        try {
            $path = '/api/v1/profile/natal/places';
            $this->withHeader('X-EliteSync-Natal-Places', 'wgs84-v2')
                ->postJson($path, ['query' => '南阳', 'region' => '南阳', 'allow_baidu' => true])
                ->assertOk()
                ->assertHeader('Cache-Control', 'no-store, private')
                ->assertJsonPath('coordinate_system', 'WGS84')
                ->assertJsonCount(1, 'places')
                ->assertJsonPath('source', 'GeoNames')
                ->assertJsonMissingPath('lookup_provider')
                ->assertJsonPath('places.0.point_kind', 'city')
                ->assertJsonPath('places.0.approximate', true)
                ->assertJsonPath('places.0.lat', 32.96029)
                ->assertJsonPath('places.0.lng', 112.40864);

            $this->travel(2)->seconds();
            Config::set('natal.baidu_lookup_enabled', false);
            $this->postJson($path, ['query' => '河南南阳市', 'region' => '南阳'])
                ->assertOk()->assertJsonPath('places.0.point_kind', 'city');

            $this->travel(2)->seconds();
            $this->postJson($path, ['query' => '南阳样例医院', 'region' => '南阳'])
                ->assertStatus(503)->assertJsonMissingPath('places');
            Http::assertNothingSent();
            $this->assertDatabaseCount('user_natal_profiles', 0);
        } finally {
            unlink($catalog);
            unlink($credentials);
        }
    }

    public function test_geo_places_search_returns_baidu_suggestions(): void
    {
        Config::set('baidu.web_ak', 'test-web-ak');
        Config::set('baidu.web_sk', 'test-web-sk');

        Http::fake([
            'https://api.map.baidu.com/place/v2/suggestion*' => Http::response([
                'status' => 0,
                'result' => [
                    [
                        'name' => '武汉市',
                        'address' => '湖北省武汉市',
                        'city' => '武汉市',
                        'district' => '',
                        'location' => ['lat' => 30.5928, 'lng' => 114.3055],
                    ],
                    [
                        'name' => '武汉大学',
                        'address' => '湖北省武汉市武昌区八一路299号',
                        'city' => '武汉市',
                        'district' => '武昌区',
                        'location' => ['lat' => 30.5431, 'lng' => 114.3628],
                    ],
                ],
            ], 200),
        ]);

        $user = User::create([
            'phone' => '13800001103',
            'password' => 'secret123',
            'gender' => 'female',
        ]);

        Sanctum::actingAs($user);

        $this->getJson('/api/v1/geo/places?query=%E6%AD%A6%E6%B1%89%E5%A4%A7%E5%AD%A6&region=%E6%AD%A6%E6%B1%89%E5%B8%82')
            ->assertOk()
            ->assertJsonPath('places.0.label', '武汉大学')
            ->assertJsonPath('places.0.city', '武汉市')
            ->assertJsonPath('places.0.district', '武昌区');

        Http::assertSent(function ($request) {
            $url = (string) $request->url();
            parse_str((string) parse_url($url, PHP_URL_QUERY), $query);
            return str_contains($url, '/place/v2/suggestion')
                && ($query['query'] ?? null) === '武汉大学'
                && !empty($query['sn'] ?? null)
                && ($query['ak'] ?? null) === 'test-web-ak';
        });
    }

    public function test_geo_places_search_prefers_exact_match_first(): void
    {
        Config::set('baidu.web_ak', 'test-web-ak');
        Config::set('baidu.web_sk', 'test-web-sk');

        Http::fake([
            'https://api.map.baidu.com/place/v2/suggestion*' => Http::response([
                'status' => 0,
                'result' => [
                    [
                        'name' => '武汉市',
                        'address' => '湖北省武汉市',
                        'city' => '武汉市',
                        'district' => '',
                        'location' => ['lat' => 30.5928, 'lng' => 114.3055],
                    ],
                    [
                        'name' => '武汉大学',
                        'address' => '湖北省武汉市武昌区八一路299号',
                        'city' => '武汉市',
                        'district' => '武昌区',
                        'location' => ['lat' => 30.5431, 'lng' => 114.3628],
                    ],
                ],
            ], 200),
        ]);

        $user = User::create([
            'phone' => '13800001104',
            'password' => 'secret123',
            'gender' => 'female',
        ]);

        Sanctum::actingAs($user);

        $res = $this->getJson('/api/v1/geo/places?query=%E6%AD%A6%E6%B1%89%E5%A4%A7%E5%AD%A6&region=%E6%AD%A6%E6%B1%89%E5%B8%82')
            ->assertOk()
            ->json('places');

        $this->assertSame('武汉大学', $res[0]['label']);
        $this->assertSame('武汉市', $res[1]['label']);
    }

    public function test_geo_places_search_returns_clear_error_when_baidu_service_disabled(): void
    {
        Config::set('baidu.web_ak', 'test-web-ak');
        Config::set('baidu.web_sk', 'test-web-sk');

        Http::fake([
            'https://api.map.baidu.com/place/v2/suggestion*' => Http::response([
                'status' => 240,
                'message' => 'APP 服务被禁用',
            ], 200),
            'https://api.map.baidu.com/place/v2/search*' => Http::response([
                'status' => 240,
                'message' => 'APP 服务被禁用',
            ], 200),
            'https://api.map.baidu.com/geocoding/v3*' => Http::response([
                'status' => 240,
                'message' => 'APP 服务被禁用',
            ], 200),
        ]);

        $user = User::create([
            'phone' => '13800001107',
            'password' => 'secret123',
            'gender' => 'female',
        ]);

        Sanctum::actingAs($user);

        $this->getJson('/api/v1/geo/places?query=%E5%8D%97%E9%98%B3&region=%E5%85%A8%E5%9B%BD')
            ->assertStatus(503)
            ->assertJsonPath('places', [])
            ->assertJsonPath('message', '百度地点服务未启用或已被禁用，请在百度控制台开启 Place/Geocoding 服务');
    }
}
