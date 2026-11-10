<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\Accounts\AccountClosure;
use App\Services\Accounts\DeviceSessions;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

final class AccountSecurityController extends Controller
{
    public function sessions(Request $request): JsonResponse
    {
        $current = $request->user()->currentAccessToken()?->device_session_id;
        $sessions = DB::table('device_sessions')->where('user_id', $request->user()->id)->whereNull('revoked_at')
            ->get(['id', 'label', 'created_at', 'last_used_at'])->map(fn ($row) => [
                'id' => $row->id, 'label' => $row->label, 'created_at' => $row->created_at,
                'last_used_at' => $row->last_used_at, 'current' => $row->id === $current]);

        return response()->json(['sessions' => $sessions])->header('Cache-Control', 'private, no-store');
    }

    public function revoke(Request $request, string $sessionId, DeviceSessions $sessions): JsonResponse
    {
        $sessions->revoke($request->user(), $sessionId);

        return response()->json(['ok' => true, 'status' => 'SESSION_REVOKED']);
    }

    public function logout(Request $request, DeviceSessions $sessions): JsonResponse
    {
        $token = $request->user()->currentAccessToken();
        abort_unless($token, 401);
        if ($token->device_session_id) {
            $sessions->revoke($request->user(), $token->device_session_id);
        } else {
            $token->delete();
        }

        return response()->json(['ok' => true, 'status' => 'SESSION_REVOKED']);
    }

    public function logoutAll(Request $request, DeviceSessions $sessions): JsonResponse
    {
        $sessions->revokeAll($request->user());

        return response()->json(['ok' => true, 'status' => 'ALL_SESSIONS_REVOKED']);
    }

    public function close(Request $request, AccountClosure $closures): JsonResponse
    {
        $data = $request->validate(['current_password' => 'required|string',
            'confirmation' => 'required|in:CLOSE_MY_ACCOUNT', 'idempotency_key' => 'required|string|min:16|max:100']);

        return response()->json($closures->request($request->user(), $data['current_password'], $data['idempotency_key']), 202);
    }

    public function receipt(Request $request, string $requestId, AccountClosure $closures): JsonResponse
    {
        $data = $request->validate(['receipt_token' => 'required|string|size:64']);

        return response()->json($closures->receipt($requestId, $data['receipt_token']))->header('Cache-Control', 'private, no-store');
    }

    public function recover(Request $request, AccountClosure $closures): JsonResponse
    {
        $data = $request->validate(['phone' => 'required|string|max:32', 'current_password' => 'required|string',
            'idempotency_key' => 'required|string|min:16|max:100']);

        return response()->json($closures->recover($data['phone'], $data['current_password'], $data['idempotency_key']))
            ->header('Cache-Control', 'private, no-store');
    }

    public function identity(): JsonResponse
    {
        return response()->json(['provider' => 'NOT_CONFIGURED', 'status' => 'NOT_VERIFIED']);
    }
}
