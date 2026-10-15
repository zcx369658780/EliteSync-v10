<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\LiveConsentService;
use Illuminate\Http\Request;

final class LiveConnectionController extends Controller
{
    public function show(Request $request, int $peerId, LiveConsentService $service)
    {
        return response()->json($service->current((int) $request->user()->id, $peerId));
    }

    public function transition(Request $request, int $peerId, string $kind, LiveConsentService $service)
    {
        $data = $request->validate(['action' => 'required|in:request,accept,decline,withdraw,close,pause,revoke', 'expected_revision' => 'required|integer|min:0']);
        abort_unless(in_array($kind, ['connection', 'consent'], true), 404);

        return response()->json($service->transition((int) $request->user()->id, $peerId, $kind, $data['action'], (int) $data['expected_revision']));
    }
}
