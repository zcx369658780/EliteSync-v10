<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\UserAstroProfile;
use App\Services\Accounts\AccountClosure;
use App\Services\Accounts\DeviceSessions;
use App\Services\ChineseZodiacService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;
use Illuminate\Validation\ValidationException;
use Laravel\Sanctum\PersonalAccessToken;

class AuthController extends Controller
{
    private function normalizeBirthPlace(mixed $value): ?string
    {
        $candidate = trim((string) $value);

        return $candidate !== '' ? $candidate : null;
    }

    private function passwordMatches(?User $user, string $password): bool
    {
        if (! $user) {
            return false;
        }

        try {
            return Hash::check($password, $user->password);
        } catch (\RuntimeException $exception) {
            if ($exception->getMessage() !== 'This password does not use the Bcrypt algorithm.') {
                throw $exception;
            }

            return false;
        }
    }

    private function resolveBirthTime(User $user): ?string
    {
        $profile = UserAstroProfile::query()
            ->where('user_id', (int) $user->id)
            ->first();

        return $profile?->birth_time;
    }

    /**
     * @return array<string, mixed>
     */
    private function userPayload(User $user): array
    {
        $profile = UserAstroProfile::query()
            ->where('user_id', (int) $user->id)
            ->first();

        $birthPlace = $this->normalizeBirthPlace($user->private_birth_place)
            ?? $this->normalizeBirthPlace($profile?->birth_place);
        $birthLat = $user->private_birth_lat ?? $profile?->birth_lat;
        $birthLng = $user->private_birth_lng ?? $profile?->birth_lng;

        return [
            'id' => $user->id,
            'phone' => $user->phone,
            'name' => $user->name,
            'role' => $user->role ?? 'user',
            'birthday' => optional($user->birthday)->format('Y-m-d'),
            'birth_time' => $this->resolveBirthTime($user),
            'zodiac_animal' => $user->zodiac_animal,
            'gender' => $user->gender,
            'city' => $user->city,
            'relationship_goal' => $user->relationship_goal,
            'birth_place' => $birthPlace,
            'private_birth_place' => $birthPlace,
            'birth_lat' => $birthLat,
            'private_birth_lat' => $birthLat,
            'birth_lng' => $birthLng,
            'private_birth_lng' => $birthLng,
            'realname_verified' => false,
            'identity_provider' => 'NOT_CONFIGURED',
            'identity_status' => 'NOT_VERIFIED',
        ];
    }

    public function register(Request $request, ChineseZodiacService $zodiacService): JsonResponse
    {
        $data = $request->validate([
            'phone' => ['required', 'string', 'max:32', 'unique:users,phone'],
            'password' => ['required', 'string', Password::min(8)->letters()->numbers()],
            'name' => ['nullable', 'string', 'max:255'],
            'birthday' => ['nullable', 'date_format:Y-m-d'],
            'realname_verified' => ['sometimes', 'boolean'],
        ]);

        $user = User::create([
            'phone' => $data['phone'],
            'name' => $data['name'] ?? null,
            'birthday' => $data['birthday'] ?? null,
            'zodiac_animal' => $zodiacService->fromBirthdayString($data['birthday'] ?? null),
            'realname_verified' => false,
            'password' => Hash::make($data['password']),
        ]);

        $tokens = app(DeviceSessions::class)->issue($user);

        return response()->json([
            'user' => $this->userPayload($user),
            ...$tokens,
        ], 201);
    }

    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'phone' => ['required', 'string', 'max:32'],
            'password' => ['required', 'string'],
        ]);

        $user = User::where('phone', $data['phone'])->first();
        if (! $this->passwordMatches($user, $data['password'])) {
            throw ValidationException::withMessages([
                'phone' => ['手机号或密码错误。'],
            ]);
        }

        return DB::transaction(function () use ($user) {
            $user = User::query()->lockForUpdate()->findOrFail($user->id);
            if ($user->disabled) {
                return response()->json(['message' => '账号已被禁用。'], 403);
            }

            $tokens = app(DeviceSessions::class)->issue($user);

            return response()->json([
                'user' => $this->userPayload($user),
                ...$tokens,
            ]);
        });
    }

    public function refresh(Request $request): JsonResponse
    {
        $token = $request->user()->currentAccessToken();
        abort_unless($token instanceof PersonalAccessToken, 401);
        $tokens = app(DeviceSessions::class)->refresh($request->user(), $token);

        return response()->json(['user' => $this->userPayload($request->user()->fresh()), ...$tokens]);
    }

    public function changePassword(Request $request): JsonResponse
    {
        $data = $request->validate([
            'current_password' => ['required', 'string'],
            'new_password' => ['required', 'string', 'different:current_password', Password::min(8)->letters()->numbers(), 'confirmed'],
        ]);

        $user = $request->user();
        if (! $this->passwordMatches($user, $data['current_password'])) {
            throw ValidationException::withMessages([
                'current_password' => ['当前密码不正确。'],
            ]);
        }

        $user->password = Hash::make($data['new_password']);
        $user->save();

        return response()->json([
            'ok' => true,
            'message' => '密码已更新',
        ]);
    }

    public function deleteSelf(Request $request): JsonResponse
    {
        return app(AccountSecurityController::class)->close($request, app(AccountClosure::class));
    }
}
