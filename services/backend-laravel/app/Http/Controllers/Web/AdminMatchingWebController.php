<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Api\V1\AdminMatchingController;
use App\Http\Controllers\Controller;
use App\Models\DatingRound;
use App\Models\DatingRoundChannel;
use App\Models\MatchingOperationAudit;
use App\Models\MatchingRun;
use App\Models\User;
use App\Services\Accounts\AdminAccess;
use App\Services\Admin\OperationAudit;
use App\Services\CurrentQuestionnaire;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

final class AdminMatchingWebController extends Controller
{
    public function index()
    {
        return view('admin.matching', ['rounds' => DatingRound::with('activeRun')->latest('id')->paginate(20), 'channelRevision' => (int) (DatingRoundChannel::where('channel_key', 'default')->value('state_version') ?? 1), 'runs' => MatchingRun::latest('id')->limit(30)->get(), 'journeyAudits' => DB::table('journey_audits')->latest('id')->limit(30)->get(['id','aggregate_id','action','created_at'])]);
    }

    public function action(Request $r)
    {
        $d = $r->validate(['operation' => 'required|in:prepare,executionRequest,reveal,retry,close', 'round_key' => 'nullable|uuid', 'idempotency_key' => 'required|string|max:120', 'confirm' => 'required|accepted', 'reason_code' => 'required|string|max:64']);
        $key = $d['round_key'] ?? null;
        $r->headers->set('Idempotency-Key', $d['idempotency_key']);
        if (in_array($d['operation'], ['reveal', 'close'], true)) {
            $r->headers->set('X-Matching-Confirmation', 'confirm:'.$key.':'.$d['operation']);
        }
        $call = fn () => app()->call([app(AdminMatchingController::class), $d['operation']], array_filter(['request' => $r, 'roundKey' => $key], fn ($v) => $v !== null));
        $response = DB::transaction(function () use ($r, $key, $call) {
            app(CurrentQuestionnaire::class)->lock();
            $administrator = User::whereKey($r->user()->id)->lockForUpdate()->first();
            abort_unless(app(AdminAccess::class)->allows($administrator), 403);
            $lock = 'matching-operations';
            DB::table('admin_versions')->insertOrIgnore(['key' => $lock, 'revision' => 0]);
            DB::table('admin_versions')->where('key', $lock)->lockForUpdate()->first();
            try {
                if ($key) {
                    $round = DatingRound::where('round_key', $key)->lockForUpdate()->firstOrFail();
                    $idem = $r->header('Idempotency-Key');
                    $replay = MatchingOperationAudit::where('round_id', $round->id)->where('idempotency_key', $idem)->exists();
                    abort_unless($replay || (int) $r->input('state_version', -1) === (int) $round->state_version, 409, 'stale state version');
                }$response = $call();
                if ($response->getStatusCode() >= 400) {
                    throw new HttpResponseException($response);
                }if ($response->getStatusCode() < 300) {
                    OperationAudit::record($r->user()->id, 'matching.'.$r->input('operation'), 'round', $key ?? 'new', (string) $r->input('reason_code'), (int) $r->input('state_version'), [], ['status' => $response->getStatusCode()]);
                }

return $response;
            } catch (\DomainException|\InvalidArgumentException $e) {
                abort(409, $e->getMessage());
            }
        });
        if ($response->getStatusCode() >= 300) {
            return response('操作未完成：'.e($response->getContent()), $response->getStatusCode());
        }

        return redirect()->route('admin.matching')->with('status','操作已持久保存；pending不代表执行完毕，请查看run终态与worker。');
    }
}
