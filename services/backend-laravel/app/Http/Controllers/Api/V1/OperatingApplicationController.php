<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\CurrentQuestionnaire;
use App\Services\JourneyStore;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

final class OperatingApplicationController extends Controller
{
    public function show(Request $request)
    {
        return response()->json(DB::transaction(function () use ($request) {
            app(JourneyStore::class)->users([(int) $request->user()->id]);
            return $this->payload((int) $request->user()->id);
        }))->header('Cache-Control', 'private, no-store');
    }

    public function store(Request $request)
    {
        $data = $request->validate(['note' => 'required|string|max:500', 'expected_revision' => 'required|integer|min:0']);
        return response()->json(DB::transaction(function () use ($request, $data) {
            // Match the existing review lock order.
            app(CurrentQuestionnaire::class)->lock();
            $id = (int) $request->user()->id;
            app(JourneyStore::class)->users([$id]);
            $old = DB::table('profile_operating_applications')->where('user_id', $id)->lockForUpdate()->first();
            $note = trim($data['note']);
            abort_unless($note !== '', 422, '请填写申请说明。');
            if ($old && $old->state === 'pending' && $old->note === $note
                && in_array((int) $data['expected_revision'], [(int) $old->revision, (int) $old->revision - 1], true)) {
                return $this->payload($id);
            }
            abort_unless((int) ($old->revision ?? 0) === (int) $data['expected_revision'], 409, '申请状态已变化，请刷新。');
            $user = \App\Models\User::findOrFail($id);
            abort_if($user->verify_status === 'approved', 409, '当前运营资格已通过。');
            DB::table('profile_operating_applications')->updateOrInsert(['user_id' => $id], [
                'revision' => (int) ($old->revision ?? 0) + 1, 'state' => 'pending', 'note' => $note,
                'feedback' => null, 'reviewer_id' => null, 'created_at' => $old->created_at ?? now(), 'updated_at' => now(),
            ]);
            $user->forceFill(['verify_status' => 'pending', 'verify_reason' => null,
                'verify_revision' => (int) $user->verify_revision + 1])->save();
            return $this->payload($id);
        }))->header('Cache-Control', 'private, no-store');
    }

    private function payload(int $id): array
    {
        $row = DB::table('profile_operating_applications')->where('user_id', $id)->first();
        return ['ok' => true, 'application' => $row ? [
            'revision' => (int) $row->revision, 'state' => $row->state, 'note' => $row->note,
            'feedback' => $row->feedback, 'updated_at' => $row->updated_at,
        ] : null, 'revision' => (int) ($row->revision ?? 0), 'realname_verified' => false];
    }
}
