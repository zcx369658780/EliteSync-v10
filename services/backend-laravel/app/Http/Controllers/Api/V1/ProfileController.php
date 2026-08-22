<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\UserAstroProfile;
use App\Services\ChineseZodiacService;
use App\Services\BaziCanonicalService;
use App\Services\BirthLocationSolarTimeService;
use App\Services\PythonAstroRenderService;
use App\Services\ProfileReadinessService;
use App\Services\UserAstroMirrorService;
use App\Services\WesternNatalCanonicalService;
use App\Services\ZiweiCanonicalService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    private const WESTERN_NATAL_ENGINE = 'kerykeion';
    private const WESTERN_NATAL_ZODIAC_MODE = 'tropical';
    private const WESTERN_NATAL_HOUSE_SYSTEM = 'placidus';
    private const WESTERN_NATAL_CONTRACT_VERSION = 'western_natal_v1';

    private function normalizeBirthPlace(mixed $value): ?string
    {
        $candidate = trim((string) $value);
        return $candidate !== '' ? $candidate : null;
    }

    private function normalizeBirthTime(mixed $value): ?string
    {
        $candidate = trim((string) $value);
        if ($candidate === '') {
            return null;
        }

        return preg_match('/^\d{2}:\d{2}$/', $candidate) ? $candidate : null;
    }

    /**
     * @return array{profile:UserAstroProfile,user:object,bazi_details:array<string,mixed>}
     */
    private function recomputeAstroFromBasicProfile(
        object $user,
        ?UserAstroProfile $profile,
        Request $request,
        BirthLocationSolarTimeService $locationResolver,
        BaziCanonicalService $canonical,
        WesternNatalCanonicalService $westernCanonical,
        ZiweiCanonicalService $ziweiCanonical
    ): array {
        $existingProfile = $profile ?? new UserAstroProfile(['user_id' => (int) $user->id]);
        $derivedBirthTime = $this->normalizeBirthTime($request->input('birth_time'))
            ?? $this->normalizeBirthTime($existingProfile->birth_time)
            ?? $this->normalizeBirthTime(data_get($user, 'private_natal_chart.true_solar_time'))
            ?? '12:00';
        $resolvedBirthPlace = $this->normalizeBirthPlace($user->private_birth_place)
            ?? $this->normalizeBirthPlace($existingProfile->birth_place);
        $existingBirthPlace = $this->normalizeBirthPlace($existingProfile->birth_place);
        $birthPlaceChanged = $request->has('birth_place')
            && $this->normalizeBirthPlace($request->input('birth_place')) !== $existingBirthPlace;
        $birthLat = $user->private_birth_lat ?? (! $birthPlaceChanged ? $existingProfile->birth_lat : null);
        $birthLng = $user->private_birth_lng ?? (! $birthPlaceChanged ? $existingProfile->birth_lng : null);
        $locationContext = $locationResolver->resolve([
            'birthday' => $user->birthday ? optional($user->birthday)->format('Y-m-d') : '',
            'birth_time' => $derivedBirthTime,
            'birth_place' => $resolvedBirthPlace ?? '',
            'birth_lat' => $birthLat,
            'birth_lng' => $birthLng,
        ]);

        $canonicalPayload = [
            'birthday' => $locationContext['effective_birthday'] ?: ($user->birthday ? optional($user->birthday)->format('Y-m-d') : ''),
            'gender' => (string) ($user->gender ?? ''),
            'birth_time' => $derivedBirthTime,
            'true_solar_time' => $locationContext['true_solar_time'] ?: $derivedBirthTime,
            'birth_place' => $resolvedBirthPlace ?? '',
            'birth_lat' => $birthLat,
            'birth_lng' => $birthLng,
            'location_shift_minutes' => (int) ($locationContext['location_shift_minutes'] ?? 0),
            'longitude_offset_minutes' => (int) ($locationContext['longitude_offset_minutes'] ?? 0),
            'equation_of_time_minutes' => (int) ($locationContext['equation_of_time_minutes'] ?? 0),
            'location_source' => (string) ($locationContext['location_source'] ?? ''),
            'position_signature' => (string) ($locationContext['position_signature'] ?? ''),
            'da_yun' => (array) ($existingProfile->da_yun ?? []),
            'liu_nian' => (array) ($existingProfile->liu_nian ?? []),
            'wu_xing' => (array) ($existingProfile->wu_xing ?? []),
            'notes' => array_values(array_filter(array_merge(
                (array) ($existingProfile->notes ?? []),
                [
                    'recomputed_from_basic_profile',
                    'location_source:'.(string) ($locationContext['location_source'] ?? 'unknown'),
                    'location_shift_minutes:'.(string) ($locationContext['location_shift_minutes'] ?? 0),
                ]
            ))),
            'user_id' => (int) $user->id,
            'platform' => (string) $request->header('X-Platform', 'android'),
            'profile_version' => (int) $request->input('profile_version', 0),
        ];

        $normalized = $canonical->canonicalize($canonicalPayload);
        $ziwei = $ziweiCanonical->canonicalize($canonicalPayload);
        $westernPayload = array_merge($canonicalPayload, [
            'sun_sign' => (string) ($normalized['sun_sign'] ?? ($existingProfile->sun_sign ?? '')),
            'moon_sign' => (string) ($existingProfile->moon_sign ?? ''),
            'asc_sign' => (string) ($existingProfile->asc_sign ?? ''),
        ]);
        $western = $westernCanonical->compute($westernPayload);
        $notes = array_values(array_filter(array_merge(
            (array) ($existingProfile->notes ?? []),
            (array) ($normalized['notes'] ?? []),
            [
                'canonical_accuracy:'.(string) ($normalized['accuracy'] ?? 'legacy_estimate'),
                'canonical_confidence:'.(string) round((float) ($normalized['confidence'] ?? 0.6), 2),
                'western_engine:'.(string) ($western['engine'] ?? 'legacy_input'),
                'western_precision:'.(string) ($western['precision'] ?? 'legacy_estimate'),
                'western_confidence:'.(string) round((float) ($western['confidence'] ?? 0.6), 2),
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
                'birth_time' => $derivedBirthTime,
                'birth_place' => $canonicalPayload['birth_place'] ?: null,
                'birth_lat' => $canonicalPayload['birth_lat'],
                'birth_lng' => $canonicalPayload['birth_lng'],
                'sun_sign' => (string) ($western['sun_sign'] ?? $normalized['sun_sign'] ?? $existingProfile->sun_sign ?? ''),
                'moon_sign' => $western['moon_sign'] ?? $normalized['moon_sign'] ?? $existingProfile->moon_sign,
                'asc_sign' => $western['asc_sign'] ?? $normalized['asc_sign'] ?? $existingProfile->asc_sign,
                'bazi' => $normalized['bazi'] ?? $existingProfile->bazi,
                'true_solar_time' => $normalized['true_solar_time'] ?? $existingProfile->true_solar_time,
                'da_yun' => (array) ($normalized['da_yun'] ?? $existingProfile->da_yun ?? []),
                'liu_nian' => (array) ($normalized['liu_nian'] ?? $existingProfile->liu_nian ?? []),
                'wu_xing' => (array) ($normalized['wu_xing'] ?? $existingProfile->wu_xing ?? []),
                'ziwei' => (array) ($ziwei['ziwei'] ?? $existingProfile->ziwei ?? []),
                'notes' => $notes,
                'computed_at' => now(),
            ]
        );

        return [
            'profile' => $profile,
            'user' => $user,
            'bazi_details' => (array) ($normalized['bazi_details'] ?? []),
        ];
    }

    private function persistWesternNatalRenderCache(
        object $user,
        UserAstroProfile $profile,
        PythonAstroRenderService $pythonAstro
    ): void {
        $payload = [
            'name' => (string) ($user->name ?: $user->nickname ?: 'EliteSync'),
            'birthday' => (string) ($user->birthday ? optional($user->birthday)->format('Y-m-d') : ''),
            'birth_time' => (string) ($profile->birth_time ?? ''),
            'birth_place' => (string) ($profile->birth_place ?? ''),
            'birth_lat' => $profile->birth_lat,
            'birth_lng' => $profile->birth_lng,
            'tz_str' => (string) ($profile->tz_str ?? 'Asia/Shanghai'),
            'route_mode' => 'standard',
        ];

        $policy = $this->westernNatalPolicy($payload);
        $signature = $this->westernNatalInputSignature($payload, $policy);
        $rendered = $pythonAstro->render($payload);
        if (! is_array($rendered) || empty($rendered)) {
            $this->persistWesternNatalRenderFailureMarker($user, $payload, $signature, $policy, 'render_failed');
            return;
        }

        $rendered = $this->withWesternNatalRouteContext($rendered);
        $rendered = $this->withWesternNatalProvenance($rendered, $payload, $signature, $policy);
        if (! $this->hasPersistableWesternNatalHouseTruth($rendered)) {
            $this->persistWesternNatalRenderFailureMarker(
                $user,
                $payload,
                $signature,
                $policy,
                (string) ($rendered['house_truth_status'] ?? data_get($rendered, 'metadata.provenance.house_truth_status') ?? 'not_house_truth')
            );
            return;
        }

        $existingChart = is_array($user->private_natal_chart ?? null)
            ? (array) $user->private_natal_chart
            : [];
        unset($existingChart['natal_chart_svg']);

        $user->forceFill([
            'private_natal_chart' => array_merge($existingChart, $rendered),
        ])->save();
    }

    /**
     * @param array<string,mixed> $payload
     * @param array{value:string,fields:array<string,mixed>} $signature
     * @param array<string,mixed> $policy
     */
    private function persistWesternNatalRenderFailureMarker(
        object $user,
        array $payload,
        array $signature,
        array $policy,
        string $houseTruthStatus
    ): void {
        $status = trim($houseTruthStatus) !== '' ? trim($houseTruthStatus) : 'not_house_truth';
        $generatedAt = now()->toIso8601String();
        $metadata = [
            'input_signature' => $signature['value'],
            'input_signature_fields' => $signature['fields'],
            'western_natal_policy' => $policy,
            'provenance' => [
                'source' => 'laravel_profile_basic_recompute',
                'engine' => self::WESTERN_NATAL_ENGINE,
                'contract_version' => self::WESTERN_NATAL_CONTRACT_VERSION,
                'zodiac_mode' => self::WESTERN_NATAL_ZODIAC_MODE,
                'house_system' => self::WESTERN_NATAL_HOUSE_SYSTEM,
                'timezone' => (string) ($policy['timezone'] ?? 'Asia/Shanghai'),
                'coordinates' => $policy['coordinates'] ?? ['lat' => null, 'lng' => null],
                'uses_true_solar_time' => false,
                'generated_at' => $generatedAt,
                'house_truth_status' => $status,
                'external_oracle_status' => 'not_validated',
            ],
            'field_roles' => [
                'display_only' => [
                    'metadata',
                    'western_natal_policy',
                    'western_natal_input_signature',
                    'house_truth_status',
                    'external_oracle_status',
                    'generated_at',
                    'route_mode',
                ],
            ],
        ];
        $existingChart = is_array($user->private_natal_chart ?? null)
            ? (array) $user->private_natal_chart
            : [];
        foreach ([
            'natal_chart_svg',
            'chart_data',
            'planets_data',
            'houses_data',
            'aspects_data',
            'engine_info',
        ] as $key) {
            unset($existingChart[$key]);
        }

        $user->forceFill([
            'private_natal_chart' => array_merge($existingChart, [
                'metadata' => $metadata,
                'western_natal_policy' => $policy,
                'western_natal_input_signature' => $signature['value'],
                'house_truth_status' => $status,
                'external_oracle_status' => 'not_validated',
                'generated_at' => $generatedAt,
                'route_mode' => 'standard',
            ]),
        ])->save();
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
     * @param array<string,mixed> $rendered
     * @return array<string,mixed>
     */
    private function withWesternNatalRouteContext(array $rendered): array
    {
        $rendered['route_mode'] = 'standard';
        $metadata = is_array($rendered['metadata'] ?? null) ? (array) $rendered['metadata'] : [];
        $routeContext = is_array($metadata['route_context'] ?? null) ? (array) $metadata['route_context'] : [];
        $metadata['route_context'] = array_merge($routeContext, [
            'route_mode' => 'standard',
            'route_preset' => 'standard',
            'source' => 'display_only',
        ]);
        $rendered['metadata'] = $metadata;

        return $rendered;
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
        $houseTruthStatus = $this->westernNatalHouseTruthStatus($payload, $rendered);

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
            'chart_data',
            'planets_data',
            'houses_data',
            'western_natal_input_signature',
            'western_natal_policy',
            'house_truth_status',
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
     * @param array<string,mixed> $rendered
     */
    private function westernNatalHouseTruthStatus(array $payload, array $rendered): string
    {
        $hasCoordinates = $this->normalizeWesternNatalCoordinate($payload['birth_lat'] ?? null) !== null
            && $this->normalizeWesternNatalCoordinate($payload['birth_lng'] ?? null) !== null;
        if (! $hasCoordinates) {
            return 'needs_coordinates';
        }
        if (empty($rendered['chart_data']) || empty($rendered['planets_data']) || empty($rendered['houses_data'])) {
            return 'not_house_truth';
        }
        if ((string) ($rendered['engine'] ?? '') === 'legacy_input'
            || (string) ($rendered['precision'] ?? '') === 'legacy_estimate') {
            return 'not_house_truth';
        }

        return 'available';
    }

    /**
     * @param array<string,mixed> $rendered
     */
    private function hasPersistableWesternNatalHouseTruth(array $rendered): bool
    {
        return ! empty($rendered['chart_data'])
            && ! empty($rendered['planets_data'])
            && is_array($rendered['planets_data'])
            && ! empty($rendered['houses_data'])
            && is_array($rendered['houses_data'])
            && (string) data_get($rendered, 'metadata.provenance.house_truth_status') === 'available';
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
        if (! is_numeric($value)) {
            return null;
        }
        $coordinate = (float) $value;

        return round($coordinate, 6);
    }

    /**
     * @param array<int,string> $current
     * @param array<int,string> $next
     * @return array<int,string>
     */
    private function mergeUniqueStrings(array $current, array $next): array
    {
        return array_values(array_unique(array_filter(array_map('strval', array_merge($current, $next)))));
    }

    /**
     * @return array<string, mixed>
     */
    private function astroProfileSnapshot(UserAstroProfile $profile, array $baziDetails = []): array
    {
        return [
            'birth_time' => $profile->birth_time,
            'birth_place' => $profile->birth_place,
            'birth_lat' => $profile->birth_lat,
            'birth_lng' => $profile->birth_lng,
            'sun_sign' => $profile->sun_sign,
            'moon_sign' => $profile->moon_sign,
            'asc_sign' => $profile->asc_sign,
            'bazi' => $profile->bazi,
            'bazi_details' => $baziDetails,
            'true_solar_time' => $profile->true_solar_time,
            'da_yun' => $profile->da_yun ?? [],
            'liu_nian' => $profile->liu_nian ?? [],
            'wu_xing' => $profile->wu_xing ?? [],
            'ziwei' => $profile->ziwei ?? [],
            'notes' => $profile->notes ?? [],
            'computed_at' => optional($profile->computed_at)->toIso8601String(),
        ];
    }

    public function basic(Request $request, ProfileReadinessService $readiness): JsonResponse
    {
        $user = $request->user();
        $profile = UserAstroProfile::query()
            ->where('user_id', (int) $user->id)
            ->first();

        return response()->json([
            'id' => $user->id,
            'name' => $user->name,
            'phone' => $user->phone,
            'birthday' => optional($user->birthday)->format('Y-m-d'),
            'birth_time' => $profile?->birth_time,
            'zodiac_animal' => $user->zodiac_animal,
            'gender' => $user->gender,
            'city' => $user->city,
            'relationship_goal' => $user->relationship_goal,
            'birth_place' => $this->normalizeBirthPlace($user->private_birth_place)
                ?? $this->normalizeBirthPlace($profile?->birth_place),
            'birth_lat' => $user->private_birth_lat,
            'birth_lng' => $user->private_birth_lng,
            'moderation_status' => $user->moderation_status ?? 'normal',
            'moderation_note' => $user->moderation_note,
            'realname_verified' => (bool) $user->realname_verified,
            'profile_readiness' => $readiness->forUser($user),
        ]);
    }

    public function saveBasic(
        Request $request,
        ChineseZodiacService $zodiacService,
        UserAstroMirrorService $mirror,
        BaziCanonicalService $canonical,
        WesternNatalCanonicalService $westernCanonical,
        ZiweiCanonicalService $ziweiCanonical,
        BirthLocationSolarTimeService $locationResolver,
        PythonAstroRenderService $pythonAstro
    ): JsonResponse
    {
        $data = $request->validate([
            'birthday' => ['nullable', 'date_format:Y-m-d'],
            'birth_time' => ['nullable', 'regex:/^\d{2}:\d{2}$/'],
            'name' => ['nullable', 'string', 'max:255'],
            'gender' => ['required', 'in:male,female'],
            'city' => ['required', 'string', 'max:64'],
            'relationship_goal' => ['required', 'in:marriage,dating,friendship'],
            'birth_place' => ['nullable', 'string', 'max:255'],
            'birth_lat' => ['nullable', 'numeric', 'between:-90,90'],
            'birth_lng' => ['nullable', 'numeric', 'between:-180,180'],
        ]);

        $user = $request->user();
        if (array_key_exists('birthday', $data)) {
            $user->birthday = $data['birthday'] ?: null;
            $user->zodiac_animal = $zodiacService->fromBirthdayString($data['birthday'] ?? null);
        }
        if (array_key_exists('name', $data)) {
            $user->name = $data['name'] ?: null;
        }
        $user->gender = $data['gender'];
        $user->city = $data['city'];
        $user->relationship_goal = $data['relationship_goal'];
        $user->private_birth_place = $this->normalizeBirthPlace($data['birth_place'] ?? null);
        $user->private_birth_lat = $data['birth_lat'] ?? null;
        $user->private_birth_lng = $data['birth_lng'] ?? null;
        $user->save();

        $profile = UserAstroProfile::query()->where('user_id', (int) $user->id)->first();
        $computed = $this->recomputeAstroFromBasicProfile(
            $user,
            $profile,
            $request,
            $locationResolver,
            $canonical,
            $westernCanonical,
            $ziweiCanonical
        );
        $mirror->syncFromAstroProfile($user, $computed['profile']);
        $this->persistWesternNatalRenderCache($user, $computed['profile'], $pythonAstro);

        return response()->json([
            'ok' => true,
            'recomputed_at' => optional($computed['profile']->computed_at)->toIso8601String(),
            'astro_profile' => $this->astroProfileSnapshot(
                $computed['profile'],
                (array) ($computed['bazi_details'] ?? [])
            ),
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'phone' => $user->phone,
                'birthday' => optional($user->birthday)->format('Y-m-d'),
                'birth_time' => $computed['profile']->birth_time,
                'zodiac_animal' => $user->zodiac_animal,
                'gender' => $user->gender,
                'city' => $user->city,
                'relationship_goal' => $user->relationship_goal,
                'birth_place' => $this->normalizeBirthPlace($user->private_birth_place),
                'birth_lat' => $user->private_birth_lat,
                'birth_lng' => $user->private_birth_lng,
                'moderation_status' => $user->moderation_status ?? 'normal',
                'moderation_note' => $user->moderation_note,
                'realname_verified' => (bool) $user->realname_verified,
            ],
        ]);
    }

    public function saveCity(Request $request): JsonResponse
    {
        $data = $request->validate([
            'city' => ['required', 'string', 'max:64'],
        ]);

        $user = $request->user();
        $user->city = trim((string) $data['city']);
        $user->save();

        return response()->json([
            'ok' => true,
            'city' => $user->city,
        ]);
    }
}
