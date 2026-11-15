<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\AutomationAuthorizationService;
use App\Services\UserStateService;
use Illuminate\Http\Request;

final class UserAutomationController extends Controller
{
    public function state(Request $request, UserStateService $service)
    {
        abort_if($request->query(), 422, 'unknown state query');
        return response()->json($service->read((int) $request->user()->id));
    }

    public function show(Request $request, AutomationAuthorizationService $service)
    {
        return response()->json($service->read((int) $request->user()->id));
    }

    public function update(Request $request, string $scope, AutomationAuthorizationService $service)
    {
        abort_unless($scope === AutomationAuthorizationService::SCOPE, 404);
        abort_if(array_diff(array_keys($request->all()), ['action', 'expected_revision', 'policy_version', 'consent_version', 'request_key', 'expires_at']), 422, 'unknown automation fields');
        $data = $request->validate([
            'action' => 'required|in:grant,pause,resume,revoke', 'expected_revision' => 'required|integer|min:0',
            'policy_version' => 'required|string|max:60', 'consent_version' => 'required|string|max:60',
            'request_key' => 'required|uuid', 'expires_at' => 'sometimes|nullable|date|after:now|prohibited_unless:action,grant',
        ]);
        return response()->json($service->command($request->user(), $data));
    }
}
