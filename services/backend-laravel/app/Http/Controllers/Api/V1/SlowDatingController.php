<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\FormalRelationshipService;
use App\Services\JourneyStore;
use App\Services\SlowDatingService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

final class SlowDatingController extends Controller
{
    public function show(Request $r, SlowDatingService $s) { return response()->json($s->journey((int) $r->user()->id)); }
    public function participate(Request $r, SlowDatingService $s)
    {
        $d = $r->validate(['action' => 'required|in:draft,opt_in,pause,exit', 'revision' => 'required|integer|min:0', 'intent' => 'present|nullable|string|max:1000']);
        return response()->json($s->participate((int) $r->user()->id, $d['action'], $d['revision'], $d['intent'] ?? ''));
    }
    public function decision(Request $r, string $id, SlowDatingService $s)
    {
        $d = $r->validate(['action' => 'required|in:accept,decline,withdraw', 'revision' => 'required|integer|min:1', 'idempotency_key' => 'required|string|max:100']);
        return response()->json($s->decision((int) $r->user()->id, $id, $d['action'], $d['revision'], $d['idempotency_key']));
    }
    public function relationships(Request $r, FormalRelationshipService $s) { return response()->json($s->listing((int) $r->user()->id)); }
    public function requestRelationship(Request $r, FormalRelationshipService $s)
    {
        $d = $r->validate(['peer_id' => 'required|integer|min:1', 'idempotency_key' => 'required|string|max:100', 'verified' => 'prohibited', 'test_only' => 'prohibited', 'actor_id' => 'prohibited', 'requester_id' => 'prohibited']);
        return response()->json($s->request((int) $r->user()->id, $d['peer_id'], $d['idempotency_key']));
    }
    public function relationshipAction(Request $r, string $id, FormalRelationshipService $s)
    {
        $d = $r->validate(['action' => 'required|in:confirm,decline,withdraw,pause,end,resume', 'revision' => 'required|integer|min:1', 'idempotency_key' => 'required|string|max:100', 'verified' => 'prohibited', 'credential' => 'prohibited']);
        return response()->json($s->action((int) $r->user()->id, $id, $d['action'], $d['revision'], $d['idempotency_key']));
    }
    public function saveResume(Request $r)
    {
        $d = $r->validate(['resume' => 'present|nullable|string|max:1000']);
        DB::transaction(function () use ($r, $d) {
            app(JourneyStore::class)->users([(int) $r->user()->id]);
            User::whereKey($r->user()->id)->update(['relationship_resume' => $d['resume']]);
        });
        return response()->json(['saved' => true]);
    }
}
