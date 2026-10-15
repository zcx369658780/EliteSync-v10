<?php
namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\RtcSession;
use App\Services\RtcAuthorityService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

/** Internal gateway credential is independent of user bearer credentials. */
final class RtcGuardController extends Controller
{
    private function guard(Request $r, RtcAuthorityService $authority): void
    {
        $secret = (string)config('rtc_guard.gateway_secret');
        abort_unless(strlen($secret) >= 32 && hash_equals($secret, (string)$r->header('X-RTC-Gateway')) && $authority->enabled(), 404);
    }

    public function authorize(Request $r, RtcAuthorityService $authority)
    {
        $this->guard($r, $authority);
        $data = $r->validate(['room'=>['required','string','max:100'],'identity'=>['required','string','max:100']]);
        return DB::transaction(function () use ($data, $authority) {
            $call = RtcSession::where('room_key', $data['room'])->lockForUpdate()->first();
            abort_unless($call && $authority->authorized($call, null, true), 404);
            $identities = [$authority->identity($call, (int)$call->initiator_user_id), $authority->identity($call, (int)$call->peer_user_id)];
            abort_unless(in_array($data['identity'], $identities, true), 404);
            return response()->json(['allowed'=>true,'call_id'=>$call->id]);
        });
    }

    public function sweep(Request $r, RtcAuthorityService $authority)
    {
        $this->guard($r, $authority);
        $allowed = [];
        foreach (RtcSession::whereIn('status', ['calling','ringing','connecting','in_call'])->get() as $call) {
            if (!$authority->authorized($call) || !$call->expires_at?->isFuture()) {
                $authority->invalidate($call, 'authority_or_call_expired');
            } elseif (in_array($call->status, ['connecting','in_call'], true) && $call->accepted_at) {
                $allowed[] = $call->room_key;
            }
        }
        return response()->json(['allowed_rooms'=>$allowed]);
    }

    public function audit(Request $r, RtcAuthorityService $authority)
    {
        $this->guard($r, $authority);
        $data = $r->validate(['room'=>['required','string','max:100'],'event'=>['required','in:sfu_removed,sfu_remove_failed'],'attempt'=>['required','integer','min:1','max:20']]);
        $call = RtcSession::where('room_key', $data['room'])->first();
        abort_unless($call, 404);
        $call->events()->create(['event_name'=>$data['event'],'payload'=>['attempt'=>$data['attempt']]]);
        return response()->json(['ok'=>true]);
    }
}
