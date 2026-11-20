<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\JourneyStore;
use App\Services\ProfileReadinessService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ProfileController extends Controller
{
    public function basic(Request $request, ProfileReadinessService $readiness): JsonResponse
    {
        $user = $request->user();
        return response()->json([
            'id' => $user->id,
            'name' => $user->name,
            'phone' => $user->phone,
            'birthday' => optional($user->birthday)->format('Y-m-d'),
            'birth_time' => $user->private_birth_time,
            'zodiac_animal' => $user->zodiac_animal,
            'gender' => $user->gender,
            'city' => $user->city,
            'relationship_goal' => $user->relationship_goal,
            'birth_place' => $user->private_birth_place,
            'birth_lat' => $user->private_birth_lat,
            'birth_lng' => $user->private_birth_lng,
            'moderation_status' => $user->moderation_status ?? 'normal',
            'moderation_note' => $user->moderation_note,
            'realname_verified' => false,
            'profile_readiness' => $readiness->forUser($user),
        ])->header('Cache-Control', 'private, no-store');
    }

    public function saveBasic(Request $request): JsonResponse
    {
        $data = $request->validate([
            'birthday' => ['nullable', 'date_format:Y-m-d'],
            'birth_time' => ['nullable', 'date_format:H:i'],
            'name' => ['nullable', 'string', 'max:255'],
            'gender' => ['required', 'in:male,female'],
            'city' => ['required', 'string', 'max:64'],
            'relationship_goal' => ['required', 'in:marriage,dating,friendship'],
            'birth_place' => ['nullable', 'string', 'max:255'],
            'birth_lat' => ['nullable', 'numeric', 'between:-90,90'],
            'birth_lng' => ['nullable', 'numeric', 'between:-180,180'],
        ]);

        $id = (int) $request->user()->id;
        return DB::transaction(function () use ($id, $data) {
            app(JourneyStore::class)->users([$id]);
            $user = User::whereKey($id)->lockForUpdate()->firstOrFail();
            $user->fill(array_intersect_key($data, array_flip(['birthday', 'name', 'gender', 'city', 'relationship_goal'])));
            foreach (['birth_time', 'birth_place', 'birth_lat', 'birth_lng'] as $field) {
                if (array_key_exists($field, $data)) {
                    $user->setAttribute('private_'.$field, $data[$field]);
                }
            }
            if ($user->isDirty('birthday')) {
                $user->zodiac_animal = null;
            }
            $user->save();

            // Editing account facts does not authorize recalculation of optional tools.
            return response()->json(['ok' => true, 'recomputed_at' => null, 'astro_profile' => null,
                'user' => $user->only(['id', 'name', 'phone', 'gender', 'city', 'relationship_goal',
                    'moderation_status', 'moderation_note', 'zodiac_animal']) + [
                    'birthday' => $user->birthday?->format('Y-m-d'),
                    'birth_time' => $user->private_birth_time,
                    'birth_place' => $user->private_birth_place,
                    'birth_lat' => $user->private_birth_lat,
                    'birth_lng' => $user->private_birth_lng,
                    'realname_verified' => false,
                ],
            ])->header('Cache-Control', 'private, no-store');
        }, 3);
    }

    public function saveNickname(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
        ]);
        $user = $request->user();
        $user->name = trim($data['name']);
        $user->save();

        return response()->json(['ok' => true, 'name' => $user->name]);
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
