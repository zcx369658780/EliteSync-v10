<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\UserAstroProfile;
use App\Services\BaziCanonicalService;
use App\Services\BirthLocationSolarTimeService;
use App\Services\PythonAstroRenderService;
use App\Services\UserAstroMirrorService;
use App\Services\WesternNatalCanonicalService;
use App\Services\ZiweiCanonicalService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AstroProfileController extends Controller
{
    private const WESTERN_NATAL_CONTRACT_VERSION = 'western_natal_v1';
    private const WESTERN_NATAL_ENGINE = 'kerykeion';
    private const WESTERN_NATAL_ZODIAC_MODE = 'tropical';
    private const WESTERN_NATAL_HOUSE_SYSTEM = 'placidus';

    public function showSummary(
        Request $request,
        BirthLocationSolarTimeService $locationResolver,
        BaziCanonicalService $canonical,
        PythonAstroRenderService $pythonAstro
    ): JsonResponse {
        return $this->showInternal($request, $locationResolver, $canonical, $pythonAstro, false);
    }

    public function showChart(
        Request $request,
        BirthLocationSolarTimeService $locationResolver,
        BaziCanonicalService $canonical,
        PythonAstroRenderService $pythonAstro
    ): JsonResponse {
        return $this->showInternal($request, $locationResolver, $canonical, $pythonAstro, true);
    }

    public function show(
        Request $request,
        BirthLocationSolarTimeService $locationResolver,
        BaziCanonicalService $canonical,
        PythonAstroRenderService $pythonAstro
    ): JsonResponse {
        return $this->showInternal(
            $request,
            $locationResolver,
            $canonical,
            $pythonAstro,
            $request->boolean('include_chart', true)
        );
    }

    private function showInternal(
        Request $request,
        BirthLocationSolarTimeService $locationResolver,
        BaziCanonicalService $canonical,
        PythonAstroRenderService $pythonAstro,
        bool $includeChart
    ): JsonResponse {
        $routeMode = $this->normalizeRouteMode((string) $request->query('route_mode', 'standard'));
        $user = $request->user();
        $profile = UserAstroProfile::query()
            ->where('user_id', (int) $user->id)
            ->first();

        if (! $profile) {
            return response()->json([
                'exists' => false,
                'profile' => null,
            ]);
        }

        $profile->loadMissing('user');

        $profileData = $this->formatProfile($profile, $locationResolver);
        $profileData['bazi_details'] = $this->buildBaziDetailsForDisplay($profile, $locationResolver, $canonical);

        return response()->json([
            'exists' => true,
            'profile' => $includeChart
                ? $this->appendPythonNatalChart($profileData, $profile, $pythonAstro, $routeMode)
                : $this->withRouteContext(
                    $this->withCurrentWesternNatalSummarySigns($profileData, $profile, $pythonAstro, $routeMode),
                    $routeMode
                ),
        ]);
    }

    public function save(
        Request $request,
        UserAstroMirrorService $mirror,
        BaziCanonicalService $canonical,
        WesternNatalCanonicalService $westernCanonical,
        ZiweiCanonicalService $ziweiCanonical,
        BirthLocationSolarTimeService $locationResolver,
        PythonAstroRenderService $pythonAstro
    ): JsonResponse {
        $user = $request->user();
        $profile = UserAstroProfile::query()
            ->where('user_id', (int) $user->id)
            ->first();
        $data = $request->validate([
            'birth_time' => ['required', 'regex:/^\d{2}:\d{2}$/'],
            'birth_place' => ['nullable', 'string', 'max:255'],
            'birth_lat' => ['nullable', 'numeric', 'between:-90,90'],
            'birth_lng' => ['nullable', 'numeric', 'between:-180,180'],
            'sun_sign' => ['nullable', 'string', 'max:32'],
            'moon_sign' => ['nullable', 'string', 'max:32'],
            'asc_sign' => ['nullable', 'string', 'max:32'],
            'bazi' => ['nullable', 'string', 'max:128'],
            'true_solar_time' => ['nullable', 'string', 'max:32'],
            'da_yun' => ['nullable', 'array'],
            'da_yun.*.index' => ['required_with:da_yun', 'integer', 'min:0'],
            'da_yun.*.gan_zhi' => ['required_with:da_yun', 'string', 'max:16'],
            'da_yun.*.start_year' => ['required_with:da_yun', 'integer'],
            'da_yun.*.end_year' => ['required_with:da_yun', 'integer'],
            'da_yun.*.start_age' => ['required_with:da_yun', 'integer', 'min:0'],
            'da_yun.*.end_age' => ['required_with:da_yun', 'integer', 'min:0'],
            'liu_nian' => ['nullable', 'array'],
            'liu_nian.*.year' => ['required_with:liu_nian', 'integer'],
            'liu_nian.*.age' => ['required_with:liu_nian', 'integer', 'min:0'],
            'liu_nian.*.gan_zhi' => ['required_with:liu_nian', 'string', 'max:16'],
            'wu_xing' => ['nullable', 'array'],
            'wu_xing.木' => ['nullable', 'integer', 'min:0'],
            'wu_xing.火' => ['nullable', 'integer', 'min:0'],
            'wu_xing.土' => ['nullable', 'integer', 'min:0'],
            'wu_xing.金' => ['nullable', 'integer', 'min:0'],
            'wu_xing.水' => ['nullable', 'integer', 'min:0'],
            'notes' => ['nullable', 'array'],
            'notes.*' => ['string', 'max:255'],
        ]);

        $locationContext = $locationResolver->resolve([
            'birthday' => $user->birthday ? optional($user->birthday)->format('Y-m-d') : '',
            'birth_time' => $data['birth_time'],
            'birth_place' => $data['birth_place'] ?? $profile?->birth_place ?? '',
            'birth_lat' => $data['birth_lat'] ?? $profile?->birth_lat,
            'birth_lng' => $data['birth_lng'] ?? $profile?->birth_lng,
        ]);

        $canonicalPayload = $data;
        $canonicalPayload['birthday'] = $locationContext['effective_birthday'] ?: ($user->birthday
            ? optional($user->birthday)->format('Y-m-d')
            : '');
        $canonicalPayload['birth_time'] = $data['birth_time'];
        $canonicalPayload['true_solar_time'] = $locationContext['true_solar_time'] ?: $data['birth_time'];
        $canonicalPayload['gender'] = (string) ($user->gender ?? '');
        $canonicalPayload['user_id'] = (int) $user->id;
        $canonicalPayload['platform'] = (string) ($request->header('X-Platform', 'android'));
        $canonicalPayload['profile_version'] = (int) $request->input('profile_version', 0);
        $canonicalPayload['location_shift_minutes'] = (int) ($locationContext['location_shift_minutes'] ?? 0);
        $canonicalPayload['longitude_offset_minutes'] = (int) ($locationContext['longitude_offset_minutes'] ?? 0);
        $canonicalPayload['equation_of_time_minutes'] = (int) ($locationContext['equation_of_time_minutes'] ?? 0);
        $canonicalPayload['location_source'] = (string) ($locationContext['location_source'] ?? '');
        $canonicalPayload['position_signature'] = (string) ($locationContext['position_signature'] ?? '');
        $canonicalPayload['notes'] = array_values(array_filter(array_merge(
            (array) ($data['notes'] ?? []),
            [
                'location_source:'.(string) ($locationContext['location_source'] ?? 'unknown'),
                'location_shift_minutes:'.(string) ($locationContext['location_shift_minutes'] ?? 0),
            ]
        )));
        $normalized = $canonical->canonicalize($canonicalPayload);
        $ziwei = $ziweiCanonical->canonicalize($canonicalPayload);
        $westernPayload = array_merge($canonicalPayload, [
            'sun_sign' => (string) ($normalized['sun_sign'] ?? ''),
            'moon_sign' => $normalized['moon_sign'] ?? ($data['moon_sign'] ?? null),
            'asc_sign' => $normalized['asc_sign'] ?? ($data['asc_sign'] ?? null),
        ]);
        $western = $westernCanonical->compute($westernPayload);
        $notes = array_values(array_filter(array_merge(
            (array) ($data['notes'] ?? []),
            (array) ($normalized['notes'] ?? []),
            [
                'canonical_accuracy:'.(string) ($normalized['accuracy'] ?? 'legacy_estimate'),
                'canonical_confidence:'.(string) round((float) ($normalized['confidence'] ?? 0.6), 2),
                'western_engine:'.(string) ($western['engine'] ?? 'legacy_input'),
                'western_precision:'.(string) ($western['precision'] ?? 'legacy_estimate'),
                'western_confidence:'.(string) round((float) ($western['confidence'] ?? 0.6), 2),
                'western_degraded:'.((bool) ($western['degraded'] ?? false) ? '1' : '0'),
                'western_degrade_reason:'.(string) ($western['degrade_reason'] ?? ''),
                'western_rollout_enabled:'.((bool) ($western['rollout_enabled'] ?? false) ? '1' : '0'),
                'western_rollout_reason:'.(string) ($western['rollout_reason'] ?? ''),
                'ziwei_engine:'.(string) data_get($ziwei, 'ziwei.engine', 'ziwei_seed_estimate'),
                'ziwei_precision:'.(string) data_get($ziwei, 'ziwei.precision', 'approximate_not_validated'),
                'ziwei_confidence:'.(string) round((float) ($ziwei['confidence'] ?? 0.6), 2),
                'ziwei_external_oracle_status:'.(string) data_get($ziwei, 'ziwei.external_oracle_status', 'not_validated'),
                'ziwei_display_only:'.((bool) data_get($ziwei, 'ziwei.display_only', true) ? '1' : '0'),
                'ziwei_scoring_status:'.(string) data_get($ziwei, 'ziwei.scoring_status', 'excluded_from_core_matching'),
            ]
        )));

        $profile = UserAstroProfile::query()->updateOrCreate(
            ['user_id' => (int) $user->id],
            [
                'birth_time' => $data['birth_time'],
                'birth_place' => $data['birth_place'] ?? null,
                'birth_lat' => $data['birth_lat'] ?? null,
                'birth_lng' => $data['birth_lng'] ?? null,
                'sun_sign' => (string) ($western['sun_sign'] ?? $normalized['sun_sign'] ?? $data['sun_sign'] ?? ''),
                'moon_sign' => $western['moon_sign'] ?? $normalized['moon_sign'] ?? ($data['moon_sign'] ?? null),
                'asc_sign' => $western['asc_sign'] ?? $normalized['asc_sign'] ?? ($data['asc_sign'] ?? null),
                'bazi' => $normalized['bazi'] ?? ($data['bazi'] ?? null),
                'true_solar_time' => $normalized['true_solar_time'] ?? ($data['true_solar_time'] ?? null),
                'da_yun' => (array) ($normalized['da_yun'] ?? ($data['da_yun'] ?? [])),
                'liu_nian' => (array) ($normalized['liu_nian'] ?? ($data['liu_nian'] ?? [])),
                'wu_xing' => (array) ($normalized['wu_xing'] ?? ($data['wu_xing'] ?? [])),
                'ziwei' => (array) ($ziwei['ziwei'] ?? []),
                'notes' => $notes,
                'computed_at' => now(),
            ]
        );

        // Single direction mirror: canonical source is user_astro_profiles.
        $mirror->syncFromAstroProfile($user, $profile);
        $profile->loadMissing('user');

        $profilePayload = $this->appendPythonNatalChart(
            array_merge(
                $this->formatProfile($profile, $locationResolver),
                ['bazi_details' => (array) ($normalized['bazi_details'] ?? [])]
            ),
            $profile,
            $pythonAstro,
            'standard'
        );

        return response()->json([
            'ok' => true,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'phone' => $user->phone,
                'birthday' => optional($user->birthday)->format('Y-m-d'),
                'birth_time' => $profile->birth_time,
                'zodiac_animal' => $user->zodiac_animal,
                'gender' => $user->gender,
                'city' => $user->city,
                'relationship_goal' => $user->relationship_goal,
                'birth_place' => $user->private_birth_place,
                'birth_lat' => $user->private_birth_lat,
                'birth_lng' => $user->private_birth_lng,
                'realname_verified' => (bool) $user->realname_verified,
            ],
            'profile' => $profilePayload,
        ]);
    }

    public function pair(Request $request, PythonAstroRenderService $pythonAstro): JsonResponse
    {
        $data = $request->validate([
            'pair_mode' => ['nullable', 'in:synastry,comparison'],
            'route_mode' => ['nullable', 'in:standard,classical,modern'],
            'first.name' => ['nullable', 'string', 'max:80'],
            'first.birthday' => ['required', 'regex:/^\d{4}-\d{2}-\d{2}$/'],
            'first.birth_time' => ['required', 'regex:/^\d{2}:\d{2}$/'],
            'first.birth_place' => ['nullable', 'string', 'max:255'],
            'first.birth_lat' => ['nullable', 'numeric', 'between:-90,90'],
            'first.birth_lng' => ['nullable', 'numeric', 'between:-180,180'],
            'first.tz_str' => ['nullable', 'string', 'max:64'],
            'first.nation' => ['nullable', 'string', 'max:8'],
            'second.name' => ['nullable', 'string', 'max:80'],
            'second.birthday' => ['required', 'regex:/^\d{4}-\d{2}-\d{2}$/'],
            'second.birth_time' => ['required', 'regex:/^\d{2}:\d{2}$/'],
            'second.birth_place' => ['nullable', 'string', 'max:255'],
            'second.birth_lat' => ['nullable', 'numeric', 'between:-90,90'],
            'second.birth_lng' => ['nullable', 'numeric', 'between:-180,180'],
            'second.tz_str' => ['nullable', 'string', 'max:64'],
            'second.nation' => ['nullable', 'string', 'max:8'],
        ]);

        $profile = $pythonAstro->request('/pair', [
            'first' => $this->normalizeSubjectPayload($data['first']),
            'second' => $this->normalizeSubjectPayload($data['second']),
            'pair_mode' => (string) ($data['pair_mode'] ?? 'synastry'),
            'route_mode' => $this->normalizeRouteMode((string) ($data['route_mode'] ?? 'standard')),
        ]);

        if (! is_array($profile)) {
            return response()->json(['message' => 'astro service unavailable'], 503);
        }

        return response()->json([
            'ok' => true,
            'profile' => $profile,
        ]);
    }

    public function transit(Request $request, PythonAstroRenderService $pythonAstro): JsonResponse
    {
        $data = $request->validate([
            'route_mode' => ['nullable', 'in:standard,classical,modern'],
            'natal.name' => ['nullable', 'string', 'max:80'],
            'natal.birthday' => ['required', 'regex:/^\d{4}-\d{2}-\d{2}$/'],
            'natal.birth_time' => ['required', 'regex:/^\d{2}:\d{2}$/'],
            'natal.birth_place' => ['nullable', 'string', 'max:255'],
            'natal.birth_lat' => ['nullable', 'numeric', 'between:-90,90'],
            'natal.birth_lng' => ['nullable', 'numeric', 'between:-180,180'],
            'natal.tz_str' => ['nullable', 'string', 'max:64'],
            'natal.nation' => ['nullable', 'string', 'max:8'],
            'transit.name' => ['nullable', 'string', 'max:80'],
            'transit.birthday' => ['required', 'regex:/^\d{4}-\d{2}-\d{2}$/'],
            'transit.birth_time' => ['required', 'regex:/^\d{2}:\d{2}$/'],
            'transit.birth_place' => ['nullable', 'string', 'max:255'],
            'transit.birth_lat' => ['nullable', 'numeric', 'between:-90,90'],
            'transit.birth_lng' => ['nullable', 'numeric', 'between:-180,180'],
            'transit.tz_str' => ['nullable', 'string', 'max:64'],
            'transit.nation' => ['nullable', 'string', 'max:8'],
        ]);

        $profile = $pythonAstro->request('/transit', [
            'natal' => $this->normalizeSubjectPayload($data['natal']),
            'transit' => $this->normalizeSubjectPayload($data['transit']),
            'route_mode' => $this->normalizeRouteMode((string) ($data['route_mode'] ?? 'standard')),
        ]);

        if (! is_array($profile)) {
            return response()->json(['message' => 'astro service unavailable'], 503);
        }

        return response()->json([
            'ok' => true,
            'profile' => $profile,
        ]);
    }

    public function returnChart(Request $request, PythonAstroRenderService $pythonAstro): JsonResponse
    {
        $data = $request->validate([
            'route_mode' => ['nullable', 'in:standard,classical,modern'],
            'return_year' => ['required', 'integer', 'min:1900', 'max:2100'],
            'return_type' => ['nullable', 'in:Lunar,Solar'],
            'natal.name' => ['nullable', 'string', 'max:80'],
            'natal.birthday' => ['required', 'regex:/^\d{4}-\d{2}-\d{2}$/'],
            'natal.birth_time' => ['required', 'regex:/^\d{2}:\d{2}$/'],
            'natal.birth_place' => ['nullable', 'string', 'max:255'],
            'natal.birth_lat' => ['nullable', 'numeric', 'between:-90,90'],
            'natal.birth_lng' => ['nullable', 'numeric', 'between:-180,180'],
            'natal.tz_str' => ['nullable', 'string', 'max:64'],
            'natal.nation' => ['nullable', 'string', 'max:8'],
            'return_place' => ['nullable', 'string', 'max:255'],
            'return_lat' => ['nullable', 'numeric', 'between:-90,90'],
            'return_lng' => ['nullable', 'numeric', 'between:-180,180'],
            'return_tz_str' => ['nullable', 'string', 'max:64'],
            'return_nation' => ['nullable', 'string', 'max:8'],
        ]);

        $profile = $pythonAstro->request('/return', [
            'natal' => $this->normalizeSubjectPayload($data['natal']),
            'return_year' => (int) $data['return_year'],
            'return_type' => (string) ($data['return_type'] ?? 'Lunar'),
            'route_mode' => $this->normalizeRouteMode((string) ($data['route_mode'] ?? 'standard')),
            'return_place' => $data['return_place'] ?? null,
            'return_lat' => $data['return_lat'] ?? null,
            'return_lng' => $data['return_lng'] ?? null,
            'return_tz_str' => $data['return_tz_str'] ?? null,
            'return_nation' => $data['return_nation'] ?? null,
        ]);

        if (! is_array($profile)) {
            return response()->json(['message' => 'astro service unavailable'], 503);
        }

        return response()->json([
            'ok' => true,
            'profile' => $profile,
        ]);
    }

    /**
     * @param array<string,mixed> $profileData
     * @return array<string,mixed>
     */
    private function appendPythonNatalChart(
        array $profileData,
        UserAstroProfile $profile,
        PythonAstroRenderService $pythonAstro,
        string $routeMode = 'standard'
    ): array
    {
        $routeMode = $this->normalizeRouteMode($routeMode);
        $cached = [];
        $user = $profile->user;
        if ($user && is_array($user->private_natal_chart ?? null)) {
            $cached = (array) $user->private_natal_chart;
            unset($cached['natal_chart_svg']);
        }

        $payload = [
            'name' => (string) ($user?->name ?: $user?->nickname ?: 'EliteSync'),
            'birthday' => (string) ($user?->birthday ? optional($user->birthday)->format('Y-m-d') : ($profile->birthday ?? '')),
            'birth_time' => (string) ($profile->birth_time ?? ''),
            'birth_place' => (string) ($profile->birth_place ?? ''),
            'birth_lat' => $profile->birth_lat,
            'birth_lng' => $profile->birth_lng,
            'tz_str' => (string) ($profile->tz_str ?? 'Asia/Shanghai'),
            'route_mode' => $routeMode,
        ];
        $policy = $this->westernNatalPolicy($payload);
        $signature = $this->westernNatalInputSignature($payload, $policy);

        if ($this->canReuseWesternNatalChart($cached, $signature, $policy)) {
            return $this->withWesternNatalSummarySigns(
                array_merge($profileData, $this->withRouteContext($cached, $routeMode)),
                $cached
            );
        }

        $rendered = $pythonAstro->render($payload);
        if (is_array($rendered) && ! empty($rendered)) {
            $rendered = $this->withRouteContext($rendered, $routeMode);
            $rendered = $this->withWesternNatalProvenance($rendered, $payload, $signature, $policy);
            if ($user) {
                $user->forceFill(['private_natal_chart' => array_merge($cached, $rendered)])->save();
            }
            return $this->withWesternNatalSummarySigns(array_merge($profileData, $rendered), $rendered);
        }

        return array_merge(
            $profileData,
            $this->withWesternNatalFallbackMetadata($routeMode, $payload, $signature, $policy)
        );
    }

    /**
     * @param array<string,mixed> $payload
     * @return array<string,mixed>
     */
    private function withRouteContext(array $payload, string $routeMode): array
    {
        $payload['route_mode'] = $routeMode;
        if (! isset($payload['metadata']) || ! is_array($payload['metadata'])) {
            $payload['metadata'] = [];
        }

        $metadata = (array) $payload['metadata'];
        $routeContext = is_array($metadata['route_context'] ?? null)
            ? (array) $metadata['route_context']
            : [];
        $metadata['route_context'] = array_merge($routeContext, [
            'route_mode' => $routeMode,
            'route_preset' => $routeMode,
            'source' => 'display_only',
        ]);

        $fieldRoles = is_array($metadata['field_roles'] ?? null)
            ? (array) $metadata['field_roles']
            : [];
        $displayOnly = array_values(array_unique(array_merge(
            array_map('strval', (array) ($fieldRoles['display_only'] ?? [])),
            ['route_mode']
        )));
        $fieldRoles['display_only'] = $displayOnly;
        $metadata['field_roles'] = $fieldRoles;
        $payload['metadata'] = $metadata;

        return $payload;
    }

    /**
     * @param array<string,mixed> $payload
     * @return array<string,mixed>
     */
    private function westernNatalPolicy(array $payload): array
    {
        return [
            'engine' => self::WESTERN_NATAL_ENGINE,
            'zodiac_mode' => self::WESTERN_NATAL_ZODIAC_MODE,
            'house_system' => self::WESTERN_NATAL_HOUSE_SYSTEM,
            'timezone' => $this->normalizeWesternNatalTimezone($payload['tz_str'] ?? null),
            'coordinates' => [
                'lat' => $this->normalizeWesternNatalCoordinate($payload['birth_lat'] ?? null),
                'lng' => $this->normalizeWesternNatalCoordinate($payload['birth_lng'] ?? null),
            ],
            'uses_true_solar_time' => false,
            'contract_version' => self::WESTERN_NATAL_CONTRACT_VERSION,
        ];
    }

    /**
     * @param array<string,mixed> $payload
     * @param array<string,mixed> $policy
     * @return array{value:string,fields:array<string,mixed>}
     */
    private function westernNatalInputSignature(array $payload, array $policy): array
    {
        $fields = [
            'birth_date' => trim((string) ($payload['birthday'] ?? '')),
            'birth_time' => trim((string) ($payload['birth_time'] ?? '')),
            'birth_place' => trim((string) ($payload['birth_place'] ?? '')),
            'birth_lat' => $this->normalizeWesternNatalCoordinate($payload['birth_lat'] ?? null),
            'birth_lng' => $this->normalizeWesternNatalCoordinate($payload['birth_lng'] ?? null),
            'timezone' => (string) ($policy['timezone'] ?? 'Asia/Shanghai'),
            'zodiac_mode' => (string) ($policy['zodiac_mode'] ?? self::WESTERN_NATAL_ZODIAC_MODE),
            'house_system' => (string) ($policy['house_system'] ?? self::WESTERN_NATAL_HOUSE_SYSTEM),
            'engine' => (string) ($policy['engine'] ?? self::WESTERN_NATAL_ENGINE),
            'contract_version' => (string) ($policy['contract_version'] ?? self::WESTERN_NATAL_CONTRACT_VERSION),
        ];
        ksort($fields);
        $raw = json_encode($fields, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_PRESERVE_ZERO_FRACTION);

        return [
            'value' => hash('sha256', is_string($raw) ? $raw : ''),
            'fields' => $fields,
        ];
    }

    /**
     * @param array<string,mixed> $cached
     * @param array{value:string,fields:array<string,mixed>} $signature
     * @param array<string,mixed> $policy
     */
    private function canReuseWesternNatalChart(array $cached, array $signature, array $policy): bool
    {
        if (empty($cached['chart_data'])) {
            return false;
        }
        if (empty($cached['planets_data']) || ! is_array($cached['planets_data'])) {
            return false;
        }
        if (empty($cached['houses_data']) || ! is_array($cached['houses_data'])) {
            return false;
        }
        if (! is_array($cached['metadata'] ?? null)) {
            return false;
        }

        $metadata = (array) $cached['metadata'];
        if ((string) ($metadata['input_signature'] ?? '') !== $signature['value']) {
            return false;
        }
        if (! is_array($metadata['western_natal_policy'] ?? null) || ! is_array($metadata['provenance'] ?? null)) {
            return false;
        }

        $cachedPolicy = (array) $metadata['western_natal_policy'];
        foreach (['engine', 'zodiac_mode', 'house_system', 'timezone', 'contract_version'] as $key) {
            if ((string) ($cachedPolicy[$key] ?? '') !== (string) ($policy[$key] ?? '')) {
                return false;
            }
        }

        $cachedCoords = is_array($cachedPolicy['coordinates'] ?? null) ? (array) $cachedPolicy['coordinates'] : [];
        $currentCoords = is_array($policy['coordinates'] ?? null) ? (array) $policy['coordinates'] : [];
        if ($this->normalizeWesternNatalCoordinate($cachedCoords['lat'] ?? null) !== $this->normalizeWesternNatalCoordinate($currentCoords['lat'] ?? null)) {
            return false;
        }
        if ($this->normalizeWesternNatalCoordinate($cachedCoords['lng'] ?? null) !== $this->normalizeWesternNatalCoordinate($currentCoords['lng'] ?? null)) {
            return false;
        }

        $provenance = (array) $metadata['provenance'];
        if ((string) ($provenance['contract_version'] ?? '') !== self::WESTERN_NATAL_CONTRACT_VERSION) {
            return false;
        }
        if ((string) ($provenance['house_truth_status'] ?? '') !== 'available') {
            return false;
        }

        return true;
    }

    /**
     * @param array<string,mixed> $profileData
     * @return array<string,mixed>
     */
    private function withCurrentWesternNatalSummarySigns(
        array $profileData,
        UserAstroProfile $profile,
        PythonAstroRenderService $pythonAstro,
        string $routeMode = 'standard'
    ): array
    {
        $user = $profile->user;
        $cached = ($user && is_array($user->private_natal_chart ?? null))
            ? (array) $user->private_natal_chart
            : [];

        $payload = [
            'name' => (string) ($user?->name ?: $user?->nickname ?: 'EliteSync'),
            'birthday' => (string) ($user?->birthday ? optional($user->birthday)->format('Y-m-d') : ($profile->birthday ?? '')),
            'birth_time' => (string) ($profile->birth_time ?? ''),
            'birth_place' => (string) ($profile->birth_place ?? ''),
            'birth_lat' => $profile->birth_lat,
            'birth_lng' => $profile->birth_lng,
            'tz_str' => (string) ($profile->tz_str ?? 'Asia/Shanghai'),
            'route_mode' => 'standard',
        ];
        $policy = $this->westernNatalPolicy($payload);
        $signature = $this->westernNatalInputSignature($payload, $policy);

        if ($this->canReuseWesternNatalChart($cached, $signature, $policy)) {
            return $this->withWesternNatalSummarySigns($profileData, $cached);
        }

        $rendered = $pythonAstro->render($payload);
        if (is_array($rendered) && ! empty($rendered)) {
            $rendered = $this->withRouteContext($rendered, $this->normalizeRouteMode($routeMode));
            $rendered = $this->withWesternNatalProvenance($rendered, $payload, $signature, $policy);
            if ($user) {
                $user->forceFill(['private_natal_chart' => array_merge($cached, $rendered)])->save();
            }

            return $this->withWesternNatalSummarySigns($profileData, $rendered, 'rebuilt_natal_chart');
        }

        return array_merge($profileData, [
            'western_summary_source' => 'legacy_summary_only',
            'western_summary_degraded' => true,
            'western_summary_degrade_reason' => 'current_natal_chart_unavailable',
        ]);
    }

    /**
     * @param array<string,mixed> $profileData
     * @param array<string,mixed> $chart
     * @return array<string,mixed>
     */
    private function withWesternNatalSummarySigns(
        array $profileData,
        array $chart,
        string $source = 'current_natal_chart'
    ): array
    {
        if (! $this->hasReusableWesternNatalHouseTruth($chart)) {
            return array_merge($profileData, [
                'western_summary_source' => 'legacy_summary_only',
                'western_summary_degraded' => true,
                'western_summary_degrade_reason' => 'current_natal_chart_not_house_truth',
            ]);
        }

        $signs = $this->westernNatalSummarySignsFromChart($chart);
        if (empty($signs['moon_sign']) || empty($signs['asc_sign'])) {
            return array_merge($profileData, [
                'western_summary_source' => 'legacy_summary_only',
                'western_summary_degraded' => true,
                'western_summary_degrade_reason' => 'current_natal_chart_summary_signs_incomplete',
            ]);
        }

        foreach (['sun_sign', 'moon_sign', 'asc_sign'] as $key) {
            if (! empty($signs[$key])) {
                $profileData[$key] = $signs[$key];
            }
        }

        return array_merge($profileData, [
            'western_summary_source' => $source,
            'western_summary_degraded' => false,
            'western_summary_degrade_reason' => null,
        ]);
    }

    /**
     * @param array<string,mixed> $chart
     */
    private function hasReusableWesternNatalHouseTruth(array $chart): bool
    {
        if (empty($chart['planets_data']) || ! is_array($chart['planets_data'])) {
            return false;
        }
        if (empty($chart['houses_data']) || ! is_array($chart['houses_data'])) {
            return false;
        }

        return (string) data_get($chart, 'metadata.provenance.house_truth_status') === 'available';
    }

    /**
     * @param array<string,mixed> $chart
     * @return array{sun_sign?:string,moon_sign?:string,asc_sign?:string}
     */
    private function westernNatalSummarySignsFromChart(array $chart): array
    {
        $signs = [];

        foreach ((array) ($chart['planets_data'] ?? []) as $row) {
            if (! is_array($row)) {
                continue;
            }
            $planet = strtolower(trim((string) ($row['key'] ?? $row['name'] ?? '')));
            $name = strtolower(trim((string) ($row['name'] ?? '')));
            $sign = $this->westernNatalSummarySignLabel($row['sign'] ?? null);
            if ($sign === '') {
                continue;
            }
            if ($planet === 'sun' || $name === 'sun' || $name === '太阳') {
                $signs['sun_sign'] = $sign;
            }
            if ($planet === 'moon' || $name === 'moon' || $name === '月亮') {
                $signs['moon_sign'] = $sign;
            }
        }

        foreach ((array) ($chart['houses_data'] ?? []) as $row) {
            if (! is_array($row)) {
                continue;
            }
            $index = (string) ($row['index'] ?? '');
            $name = strtolower(trim((string) ($row['name'] ?? '')));
            if ($index !== '1' && $name !== 'first_house' && $name !== '1宫') {
                continue;
            }
            $sign = $this->westernNatalSummarySignLabel($row['sign'] ?? null);
            if ($sign !== '') {
                $signs['asc_sign'] = $sign;
                break;
            }
        }

        return $signs;
    }

    private function westernNatalSummarySignLabel(mixed $value): string
    {
        $sign = trim((string) $value);
        if ($sign === '') {
            return '';
        }

        $map = [
            'aries' => '白羊座',
            'ari' => '白羊座',
            'taurus' => '金牛座',
            'tau' => '金牛座',
            'gemini' => '双子座',
            'gem' => '双子座',
            'cancer' => '巨蟹座',
            'can' => '巨蟹座',
            'leo' => '狮子座',
            'virgo' => '处女座',
            'vir' => '处女座',
            'libra' => '天秤座',
            'lib' => '天秤座',
            'scorpio' => '天蝎座',
            'sco' => '天蝎座',
            'sagittarius' => '射手座',
            'sag' => '射手座',
            'capricorn' => '摩羯座',
            'cap' => '摩羯座',
            'aquarius' => '水瓶座',
            'aqu' => '水瓶座',
            'pisces' => '双鱼座',
            'pis' => '双鱼座',
        ];

        return $map[strtolower($sign)] ?? $sign;
    }

    /**
     * @param array<string,mixed> $rendered
     * @param array<string,mixed> $payload
     * @param array{value:string,fields:array<string,mixed>} $signature
     * @param array<string,mixed> $policy
     * @return array<string,mixed>
     */
    private function withWesternNatalProvenance(array $rendered, array $payload, array $signature, array $policy): array
    {
        $generatedAt = trim((string) ($rendered['generated_at'] ?? '')) ?: now()->toIso8601String();
        $engineVersion = (string) (data_get($rendered, 'engine_info.engine_version')
            ?? data_get($rendered, 'metadata.engine_version')
            ?? 'unknown');
        $houseTruthStatus = $this->westernNatalHouseTruthStatus($payload);

        $metadata = is_array($rendered['metadata'] ?? null) ? (array) $rendered['metadata'] : [];
        $metadata['input_signature'] = $signature['value'];
        $metadata['input_signature_fields'] = $signature['fields'];
        $metadata['western_natal_policy'] = array_merge($policy, ['engine_version' => $engineVersion]);
        $metadata['provenance'] = [
            'source' => 'python_kerykeion',
            'engine' => self::WESTERN_NATAL_ENGINE,
            'engine_version' => $engineVersion,
            'contract_version' => self::WESTERN_NATAL_CONTRACT_VERSION,
            'zodiac_mode' => self::WESTERN_NATAL_ZODIAC_MODE,
            'house_system' => self::WESTERN_NATAL_HOUSE_SYSTEM,
            'timezone' => (string) $policy['timezone'],
            'coordinates' => $policy['coordinates'],
            'uses_true_solar_time' => false,
            'generated_at' => $generatedAt,
            'house_truth_status' => $houseTruthStatus,
            'external_oracle_status' => 'not_validated',
        ];

        $fieldRoles = is_array($metadata['field_roles'] ?? null) ? (array) $metadata['field_roles'] : [];
        $fieldRoles['derived'] = $this->mergeUniqueStrings((array) ($fieldRoles['derived'] ?? []), [
            'western_natal_input_signature',
            'western_natal_policy',
            'house_truth_status',
        ]);
        $fieldRoles['canonical'] = $this->mergeUniqueStrings((array) ($fieldRoles['canonical'] ?? []), [
            'birthday',
            'birth_time',
            'birth_place',
            'birth_lat',
            'birth_lng',
            'tz_str',
        ]);
        $metadata['field_roles'] = $fieldRoles;

        $rendered['metadata'] = $metadata;
        $rendered['western_natal_policy'] = $metadata['western_natal_policy'];
        $rendered['western_natal_input_signature'] = $signature['value'];
        $rendered['house_truth_status'] = $houseTruthStatus;
        $rendered['external_oracle_status'] = 'not_validated';
        $rendered['generated_at'] = $generatedAt;

        return $rendered;
    }

    /**
     * @param array<string,mixed> $payload
     * @param array{value:string,fields:array<string,mixed>} $signature
     * @param array<string,mixed> $policy
     * @return array<string,mixed>
     */
    private function withWesternNatalFallbackMetadata(string $routeMode, array $payload, array $signature, array $policy): array
    {
        return $this->withRouteContext([
            'house_truth_status' => 'not_house_truth',
            'western_natal_input_signature' => $signature['value'],
            'western_natal_policy' => $policy,
            'western_natal_degraded' => true,
            'western_natal_degrade_reason' => 'python_render_unavailable',
            'metadata' => [
                'input_signature' => $signature['value'],
                'input_signature_fields' => $signature['fields'],
                'western_natal_policy' => $policy,
                'provenance' => [
                    'source' => 'legacy_summary_only',
                    'engine' => self::WESTERN_NATAL_ENGINE,
                    'contract_version' => self::WESTERN_NATAL_CONTRACT_VERSION,
                    'zodiac_mode' => self::WESTERN_NATAL_ZODIAC_MODE,
                    'house_system' => self::WESTERN_NATAL_HOUSE_SYSTEM,
                    'timezone' => (string) $policy['timezone'],
                    'coordinates' => $policy['coordinates'],
                    'uses_true_solar_time' => false,
                    'generated_at' => now()->toIso8601String(),
                    'house_truth_status' => 'not_house_truth',
                    'degraded' => true,
                    'degrade_reason' => 'python_render_unavailable',
                    'external_oracle_status' => 'not_validated',
                ],
                'field_roles' => [
                    'canonical' => ['birthday', 'birth_time', 'birth_place', 'birth_lat', 'birth_lng', 'tz_str'],
                    'display_only' => ['route_mode'],
                ],
            ],
        ], $routeMode);
    }

    private function westernNatalHouseTruthStatus(array $payload): string
    {
        return $this->normalizeWesternNatalCoordinate($payload['birth_lat'] ?? null) !== null
            && $this->normalizeWesternNatalCoordinate($payload['birth_lng'] ?? null) !== null
            ? 'available'
            : 'needs_coordinates';
    }

    private function normalizeWesternNatalTimezone(mixed $value): string
    {
        $candidate = trim((string) ($value ?? ''));
        return $candidate !== '' ? $candidate : 'Asia/Shanghai';
    }

    private function normalizeWesternNatalCoordinate(mixed $value): ?float
    {
        if ($value === null || $value === '') {
            return null;
        }
        return round((float) $value, 7);
    }

    /**
     * @param array<int,mixed> $base
     * @param array<int,string> $additions
     * @return array<int,string>
     */
    private function mergeUniqueStrings(array $base, array $additions): array
    {
        $merged = [];
        foreach (array_merge($base, $additions) as $value) {
            $string = (string) $value;
            if ($string === '' || in_array($string, $merged, true)) {
                continue;
            }
            $merged[] = $string;
        }
        return $merged;
    }

    private function normalizeRouteMode(string $routeMode): string
    {
        $mode = strtolower(trim($routeMode));
        return in_array($mode, ['standard', 'classical', 'modern'], true)
            ? $mode
            : 'standard';
    }

    /**
     * @param array<string,mixed> $subject
     * @return array<string,mixed>
     */
    private function normalizeSubjectPayload(array $subject): array
    {
        return [
            'name' => (string) ($subject['name'] ?? ''),
            'birthday' => (string) ($subject['birthday'] ?? ''),
            'birth_time' => (string) ($subject['birth_time'] ?? ''),
            'birth_place' => $subject['birth_place'] ?? null,
            'birth_lat' => $subject['birth_lat'] ?? null,
            'birth_lng' => $subject['birth_lng'] ?? null,
            'tz_str' => (string) ($subject['tz_str'] ?? 'Asia/Shanghai'),
            'nation' => (string) ($subject['nation'] ?? 'CN'),
        ];
    }

    /**
     * @return array<string,mixed>
     */
    private function formatProfile(UserAstroProfile $profile, BirthLocationSolarTimeService $locationResolver): array
    {
        $notes = (array) ($profile->notes ?? []);
        $accuracy = null;
        $confidence = null;
        $westernEngine = null;
        $westernPrecision = null;
        $westernConfidence = null;
        $westernDegraded = null;
        $westernDegradeReason = null;
        $westernRolloutEnabled = null;
        $westernRolloutReason = null;
        foreach ($notes as $n) {
            $s = (string) $n;
            if (str_starts_with($s, 'canonical_accuracy:')) {
                $accuracy = substr($s, strlen('canonical_accuracy:'));
            }
            if (str_starts_with($s, 'canonical_confidence:')) {
                $confidence = (float) substr($s, strlen('canonical_confidence:'));
            }
            if (str_starts_with($s, 'western_engine:')) {
                $westernEngine = substr($s, strlen('western_engine:'));
            }
            if (str_starts_with($s, 'western_precision:')) {
                $westernPrecision = substr($s, strlen('western_precision:'));
            }
            if (str_starts_with($s, 'western_confidence:')) {
                $westernConfidence = (float) substr($s, strlen('western_confidence:'));
            }
            if (str_starts_with($s, 'western_degraded:')) {
                $westernDegraded = substr($s, strlen('western_degraded:')) === '1';
            }
            if (str_starts_with($s, 'western_degrade_reason:')) {
                $westernDegradeReason = substr($s, strlen('western_degrade_reason:'));
            }
            if (str_starts_with($s, 'western_rollout_enabled:')) {
                $westernRolloutEnabled = substr($s, strlen('western_rollout_enabled:')) === '1';
            }
            if (str_starts_with($s, 'western_rollout_reason:')) {
                $westernRolloutReason = substr($s, strlen('western_rollout_reason:'));
            }
        }

        $locationContext = $locationResolver->resolve([
            'birthday' => $profile->user?->birthday ? optional($profile->user->birthday)->format('Y-m-d') : '',
            'birth_time' => (string) ($profile->birth_time ?? ''),
            'birth_place' => (string) ($profile->birth_place ?? ''),
            'birth_lat' => $profile->birth_lat,
            'birth_lng' => $profile->birth_lng,
        ]);

        return [
            'birthday' => $profile->user?->birthday ? optional($profile->user->birthday)->format('Y-m-d') : '',
            'birth_time' => $profile->birth_time,
            'birth_place' => $profile->birth_place,
            'birth_lat' => $profile->birth_lat,
            'birth_lng' => $profile->birth_lng,
            'sun_sign' => $profile->sun_sign,
            'moon_sign' => $profile->moon_sign,
            'asc_sign' => $profile->asc_sign,
            'bazi' => $profile->bazi,
            'bazi_details' => [],
            'true_solar_time' => $profile->true_solar_time,
            'location_shift_minutes' => $locationContext['location_shift_minutes'] ?? 0,
            'longitude_offset_minutes' => $locationContext['longitude_offset_minutes'] ?? 0,
            'equation_of_time_minutes' => $locationContext['equation_of_time_minutes'] ?? 0,
            'position_signature' => $locationContext['position_signature'] ?? '',
            'location_source' => $locationContext['location_source'] ?? '',
            'da_yun' => $profile->da_yun ?? [],
            'liu_nian' => $profile->liu_nian ?? [],
            'wu_xing' => $profile->wu_xing ?? [],
            'ziwei' => $profile->ziwei ?? [],
            'notes' => $notes,
            'accuracy' => $accuracy,
            'confidence' => $confidence,
            'western_engine' => $westernEngine,
            'western_precision' => $westernPrecision,
            'western_confidence' => $westernConfidence,
            'western_degraded' => $westernDegraded,
            'western_degrade_reason' => $westernDegradeReason,
            'western_rollout_enabled' => $westernRolloutEnabled,
            'western_rollout_reason' => $westernRolloutReason,
            'computed_at' => optional($profile->computed_at)->toIso8601String(),
        ];
    }

    /**
     * @return array<string,mixed>
     */
    private function buildBaziDetailsForDisplay(
        UserAstroProfile $profile,
        BirthLocationSolarTimeService $locationResolver,
        BaziCanonicalService $canonical
    ): array {
        $user = $profile->user;
        $locationContext = $locationResolver->resolve([
            'birthday' => $user?->birthday ? optional($user->birthday)->format('Y-m-d') : '',
            'birth_time' => (string) ($profile->birth_time ?? ''),
            'birth_place' => (string) ($profile->birth_place ?? ''),
            'birth_lat' => $profile->birth_lat,
            'birth_lng' => $profile->birth_lng,
        ]);

        $payload = [
            'birthday' => $locationContext['effective_birthday'] ?: ($user?->birthday ? optional($user->birthday)->format('Y-m-d') : ''),
            'birth_time' => (string) ($profile->birth_time ?? ''),
            'true_solar_time' => (string) ($profile->true_solar_time ?: ($locationContext['true_solar_time'] ?? $profile->birth_time ?? '')),
            'gender' => (string) ($user?->gender ?? ''),
            'birth_place' => (string) ($profile->birth_place ?? ''),
            'birth_lat' => $profile->birth_lat,
            'birth_lng' => $profile->birth_lng,
            'notes' => (array) ($profile->notes ?? []),
        ];

        $normalized = $canonical->canonicalize($payload);
        return (array) ($normalized['bazi_details'] ?? []);
    }
}
