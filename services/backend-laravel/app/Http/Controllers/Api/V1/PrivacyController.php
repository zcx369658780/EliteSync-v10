<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\SocialPolicy;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

final class PrivacyController extends Controller
{
    private function fields(): array
    {
        return ['birthday' => 'SELF', 'interests' => 'SELF', 'resume' => 'SELF', 'zodiac' => 'SELF'];
    }

    public function show(Request $r)
    {
        $p = DB::table('privacy_preferences')->where('user_id', $r->user()->id)->first();

        return response()->json(['self_profile' => app(SocialPolicy::class)->profile((int)$r->user()->id, (int)$r->user()->id), 'fields' => $p?->fields ? json_decode($p->fields, true) : $this->fields(), 'revision' => (int) ($p->revision ?? 0), 'formal_relationship_available' => true, 'identity' => app(\App\Services\TrustedIdentityService::class)->status((int) $r->user()->id)]);
    }

    public function save(Request $r)
    {
        $rules = ['expected_revision' => 'required|integer|min:0', 'fields' => 'required|array:birthday,interests,resume,zodiac'];
        foreach (array_keys($this->fields()) as $f) {
            $rules['fields.'.$f] = 'required|in:SELF,RELATIONSHIP_SHARED';
        }
        $d = $r->validate($rules);
        DB::transaction(function () use ($r, $d) {
            User::whereKey($r->user()->id)->lockForUpdate()->firstOrFail();
            $p = DB::table('privacy_preferences')->where('user_id', $r->user()->id)->lockForUpdate()->first();
            abort_unless((int) ($p->revision ?? 0) === $d['expected_revision'], 409, 'stale privacy revision');
            DB::table('privacy_preferences')->updateOrInsert(['user_id' => $r->user()->id], ['fields' => json_encode($d['fields']), 'revision' => $d['expected_revision'] + 1, 'created_at' => $p->created_at ?? now(), 'updated_at' => now()]);
        });

        return $this->show($r);
    }

    public function preview(Request $r, SocialPolicy $policy)
    {
        $d = $r->validate(['audience' => 'required|in:self,stranger,friend,partner']);
        $p = $d['audience'] === 'self' ? $policy->profile($r->user()->id, $r->user()->id) : ['public_id' => 'ES-'.$r->user()->id, 'avatar' => null];

        return response()->json(['audience' => $d['audience'], 'projection' => $p, 'formal_relationship_available' => true]);
    }

    public function peer(Request $r, int $id, SocialPolicy $policy)
    {
        $r->validate(['as_friend' => 'prohibited', 'as_partner' => 'prohibited', 'verified' => 'prohibited']);

        return response()->json(['profile' => $policy->profile((int) $r->user()->id, $id)]);
    }
}
