<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\BuddyService;
use Illuminate\Http\Request;

final class BuddyDiscoveryController extends Controller
{
    public function index(Request $request, BuddyService $buddy)
    {
        $data = $request->validate(['city' => 'required|string|min:2|max:40', 'type' => 'required|in:MEAL,STUDY',
            'limit' => 'sometimes|integer|min:1|max:20', 'cursor' => 'nullable|integer|min:1']);
        return response()->json($buddy->discovery((int) $request->user()->id, trim($data['city']), $data['type'],
            $data['limit'] ?? 20, isset($data['cursor']) ? (int) $data['cursor'] : null));
    }

    public function publish(Request $request, string $id, BuddyService $buddy)
    {
        $data = $request->validate(['action' => 'required|in:publish,withdraw', 'revision' => 'required|integer|min:1',
            'idempotency_key' => 'required|string|max:80', 'author_label' => 'required_if:action,publish|nullable|string|min:1|max:40']);
        return response()->json($buddy->publishDiscovery((int) $request->user()->id, $id, $data['action'],
            $data['revision'], $data['idempotency_key'], isset($data['author_label']) ? trim($data['author_label']) : null));
    }

    public function apply(Request $request, int $publication, BuddyService $buddy)
    {
        $data = $request->validate(['generation' => 'required|integer|min:1', 'revision' => 'required|integer|min:1',
            'idempotency_key' => 'required|string|max:80']);
        return response()->json($buddy->applyDiscovery((int) $request->user()->id, $publication,
            $data['generation'], $data['revision'], $data['idempotency_key']));
    }
}
