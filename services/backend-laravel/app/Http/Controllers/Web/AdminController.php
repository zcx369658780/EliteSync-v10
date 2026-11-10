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
        app(\App\Services\PlatformAccess::class)->recordAdminSession((int)$user->id,$request->session()->getId());
        return redirect()->route('admin.users');
    }

    public function users(Request $request)
    {
        $q = trim((string) $request->query('q', ''));
        $users = User::query()->select(['id', 'name', 'phone', 'role', 'disabled', 'moderation_status','verify_status','admin_revision'])
            ->when($q !== '', fn ($query) => $query->where(function ($filter) use ($q) {
                $filter->where('name', 'like', '%'.$q.'%')->orWhere('phone', 'like', '%'.$q.'%');
                if (ctype_digit($q)) { $filter->orWhere('id', (int) $q); }
            }))->when($request->filled('verify_status'), fn($query)=>$query->where('verify_status',$request->query('verify_status')))
            ->when($request->filled('moderation_status'),fn($query)=>$query->where('moderation_status',$request->query('moderation_status')))->orderBy('id')->paginate(20)->withQueryString();
        return view('admin.users', compact('users', 'q'));
    }

    public function disable(Request $request, int $userId, DisableUser $action)
    {
        $data=$request->validate(['confirm_disable' => 'accepted|required','expected_revision'=>'required|integer|min:0','reason'=>'required|string|max:1000']);
        $target = User::findOrFail($userId);
        abort_if($target->role !== 'user' || $target->id === $request->user()->id, 403);
        app(\App\Services\Admin\UserGovernance::class)->punish($request->user(),$userId,'banned',$data['reason'],(int)$data['expected_revision']);
        return redirect()->route('admin.users')->with('status', '用户 '.$userId.' 已禁用，令牌和持久会话已撤销。');
    }

    public function logout(Request $request)
    {
        if ($request->user()) app(\App\Services\PlatformAccess::class)->revokeAdminSession((int)$request->user()->id,$request->session()->getId());
        Auth::guard('web')->logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect()->route('admin.login');
    }
}
