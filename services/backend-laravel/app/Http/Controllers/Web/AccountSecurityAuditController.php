<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Services\Accounts\AdminAccess;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

final class AccountSecurityAuditController extends Controller
{
    public function __invoke(Request $request)
    {
        abort_unless(app(AdminAccess::class)->allows($request->user()), 403);
        $closures = DB::table('account_closures')->orderByDesc('created_at')
            ->paginate(20, ['id', 'user_id', 'status', 'attempts', 'result', 'created_at', 'updated_at']);
        $closures->getCollection()->transform(function ($row) {
            $result = json_decode($row->result ?? '{}', true) ?: [];
            $row->retained_categories = array_values(array_filter($result['retained'] ?? [], 'is_string'));
            unset($row->result);

            return $row;
        });
        $requests = DB::table('social_requests')->orderByDesc('updated_at')->limit(30)
            ->get(['id', 'sender_id', 'recipient_id', 'purpose', 'state', 'created_at', 'updated_at']);

        return response()->view('admin.account-security', compact('closures', 'requests'))
            ->header('Cache-Control', 'private, no-store');
    }
}
