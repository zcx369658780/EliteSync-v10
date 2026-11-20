<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\UserAstroProfile;
use App\Models\UserNatalProfile;
use App\Services\JourneyStore;
use App\Services\NatalProfileView;
use App\Services\PythonAstroRenderService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AstroProfileController extends Controller
{
    public function show(Request $request, NatalProfileView $view): JsonResponse
    {
        $owner = (int) $request->user()->id;
        return DB::transaction(function () use ($owner, $view) {
            app(JourneyStore::class)->users([$owner]);
            $natal = UserNatalProfile::where('user_id', $owner)->lockForUpdate()->first();
            if ($natal) {
                return response()->json(['exists' => true, 'profile' => $view->legacyProjection($natal)])
                    ->header('Cache-Control', 'private, no-store');
            }
            // The old projector reads mutable account facts and can start a new
            // render. Those inputs have no verified basis for that reuse.
            $hasLegacy = UserAstroProfile::where('user_id', $owner)->exists();

            return response()->json(['exists' => false, 'profile' => null,
                'status' => $hasLegacy ? 'LEGAL_BASIS_UNVERIFIED' : 'NO_PRIVATE_CALCULATION'])
                ->header('Cache-Control', 'private, no-store');
        }, 3);
    }

    public function save(): JsonResponse
    {
        return response()->json(['code' => 'LEGAL_BASIS_UNVERIFIED',
            'message' => '旧版排盘缺少具名用途依据。可在独立排盘工具中填写本次输入。'], 409)
            ->header('Cache-Control', 'private, no-store');
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

}
