<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\Accounts\AdminAccess;
use App\Services\Accounts\DisableUser;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

final class AdminController extends Controller
{
    public function login()
    {
        return view('admin.login');
    }

    public function authenticate(Request $request, AdminAccess $access)
    {
        $data = $request->validate(['phone' => 'required|string|max:32', 'password' => 'required|string']);
        $user = User::where('phone', $data['phone'])->first();
        if (! $user || ! Hash::check($data['password'], $user->password) || ! $access->allows($user)) {
            return back()->withErrors(['phone' => '账号、密码或管理员权限无效。'])->onlyInput('phone');
        }
        Auth::guard('web')->login($user);
        $request->session()->regenerate();
        return redirect()->route('admin.users');
    }

    public function users(Request $request)
    {
        $q = trim((string) $request->query('q', ''));
        $users = User::query()->select(['id', 'name', 'phone', 'role', 'disabled'])
            ->when($q !== '', fn ($query) => $query->where(function ($filter) use ($q) {
                $filter->where('name', 'like', '%'.$q.'%')->orWhere('phone', 'like', '%'.$q.'%');
                if (ctype_digit($q)) { $filter->orWhere('id', (int) $q); }
            }))->orderBy('id')->paginate(20)->withQueryString();
        return view('admin.users', compact('users', 'q'));
    }

    public function disable(Request $request, int $userId, DisableUser $action)
    {
        $request->validate(['confirm_disable' => 'accepted']);
        $target = User::findOrFail($userId);
        abort_if($target->role !== 'user' || $target->id === $request->user()->id, 403);
        $action->execute($userId);
        return redirect()->route('admin.users')->with('status', '用户 '.$userId.' 已禁用，令牌和持久会话已撤销。');
    }

    public function logout(Request $request)
    {
        Auth::guard('web')->logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect()->route('admin.login');
    }
}
