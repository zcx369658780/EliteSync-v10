<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\NotificationDeliveryService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Laravel\Sanctum\PersonalAccessToken;

final class NotificationPreferencesController extends Controller
{
    public function show(Request $request, NotificationDeliveryService $delivery): JsonResponse
    {
        return response()->json($delivery->preferences((int) $request->user()->id))->header('Cache-Control', 'private, no-store');
    }

    public function update(Request $request, NotificationDeliveryService $delivery): JsonResponse
    {
        $rules = ['categories' => 'sometimes|array:'.implode(',', NotificationDeliveryService::CATEGORIES), 'silent' => 'sometimes|boolean'];
        foreach (NotificationDeliveryService::CATEGORIES as $category) {
            $rules['categories.'.$category] = 'sometimes|boolean';
        }
        $data = $request->validate($rules);

        return response()->json($delivery->updatePreferences((int) $request->user()->id, $data))->header('Cache-Control', 'private, no-store');
    }

    public function register(Request $request, NotificationDeliveryService $delivery): JsonResponse
    {
        $data = $request->validate(['device_id' => 'required|string|max:128', 'transport' => 'required|in:test_only',
            'token' => 'required|string|max:4096', 'permission' => 'required|in:granted,denied']);
        if ($data['permission'] !== 'granted') {
            $delivery->revoke((int) $request->user()->id, $data['device_id']);
            abort(422, 'NOTIFICATION_PERMISSION_REQUIRED');
        }
        $token = $request->user()->currentAccessToken();
        abort_unless($token instanceof PersonalAccessToken && $token->getKey(), 401, 'CURRENT_DEVICE_SESSION_REQUIRED');

        return response()->json($delivery->register($request->user(), $token, $data))->header('Cache-Control', 'private, no-store');
    }

    public function revoke(Request $request, string $deviceId, NotificationDeliveryService $delivery): JsonResponse
    {
        return response()->json($delivery->revoke((int) $request->user()->id, $deviceId))->header('Cache-Control', 'private, no-store');
    }
}
