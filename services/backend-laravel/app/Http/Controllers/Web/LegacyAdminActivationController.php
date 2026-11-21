<?php

namespace App\Http\Controllers\Web;

use App\Services\Accounts\LegacyAdminRestore;
use DomainException;
use Illuminate\Database\QueryException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rules\Password;
use Symfony\Component\HttpFoundation\Response;

final class LegacyAdminActivationController
{
    public function show(Request $request): Response
    {
        $this->assertAvailable($request);

        return $this->page();
    }

    public function activate(Request $request, LegacyAdminRestore $restore): Response
    {
        $this->assertAvailable($request);
        $input = Validator::make($request->only(['activation_code', 'new_password', 'new_password_confirmation']), [
            'activation_code' => ['required', 'string', 'regex:/^[a-f0-9]{64}$/D'],
            'new_password' => ['required', 'string', 'confirmed', 'different:activation_code', Password::min(12)->letters()->numbers()],
        ]);
        if ($input->fails() || strlen((string) $request->input('new_password')) > 72 || str_contains((string) $request->input('new_password'), "\0")) {
            return $this->page('请检查激活码和新密码。密码至少 12 个字符，包含字母和数字，且两次输入必须相同。', 422);
        }

        try {
            $data = $input->validated();
            if (! $restore->activate($data['activation_code'], $data['new_password'])) {
                return $this->page('激活码无效、已过期或账号当前不可激活。', 422);
            }
        } catch (DomainException) {
            abort(404);
        } catch (QueryException) {
            // Never log the query bindings from the credential transaction.
            return $this->page('暂时无法确认激活结果。请先试用新密码登录，或联系恢复管理员核对。', 503);
        }

        return $this->page(null, 200, true);
    }

    private function assertAvailable(Request $request): void
    {
        abort_unless($request->isSecure() && filled(config('legacy_admin.target')), 404);
    }

    private function page(?string $error = null, int $status = 200, bool $done = false): Response
    {
        return response()->view('admin.legacy-activate', compact('error', 'done'), $status, [
            'Cache-Control' => 'no-store, private',
            'Referrer-Policy' => 'no-referrer',
            'X-Frame-Options' => 'DENY',
        ]);
    }
}
