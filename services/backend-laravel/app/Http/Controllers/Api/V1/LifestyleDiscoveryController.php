<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\LifestyleDiscoveryService;
use Illuminate\Http\Request;

final class LifestyleDiscoveryController extends Controller
{
    public function show(Request $request, LifestyleDiscoveryService $service)
    {
        return response()->json($service->read((int) $request->user()->id));
    }

    public function update(Request $request, LifestyleDiscoveryService $service)
    {
        return response()->json($service->command((int) $request->user()->id, $this->commandData($request)));
    }

    public function commandResult(Request $request, LifestyleDiscoveryService $service)
    {
        return response()->json($service->commandResult((int) $request->user()->id, $this->commandData($request)));
    }

    private function commandData(Request $request): array
    {
        $allowed = ['action', 'expected_revision', 'questionnaire_version', 'request_key', 'scene_id', 'option_id'];
        abort_if(array_diff(array_keys($request->all()), $allowed), 422, 'unknown lifestyle fields');
        $data = $request->validate([
            'action' => 'required|in:start,answer,skip,reset',
            'expected_revision' => 'required|integer|min:0',
            'questionnaire_version' => 'required|string|max:40',
            'request_key' => 'required|uuid',
            'scene_id' => 'required_if:action,answer|prohibited_unless:action,answer|string|max:50',
            'option_id' => 'required_if:action,answer|prohibited_unless:action,answer|string|max:50',
        ]);
        $data['expected_revision'] = (int) $data['expected_revision'];

        return $data;
    }
}
