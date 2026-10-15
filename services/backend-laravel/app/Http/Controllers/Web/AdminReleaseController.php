<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\AppReleaseVersion;
use App\Services\Accounts\AdminAccess;
use App\Services\Admin\ReleaseManagement;
use Illuminate\Http\Request;

final class AdminReleaseController extends Controller
{
    public function index(Request $request, ReleaseManagement $service, AdminAccess $access)
    {
        abort_unless($access->allows($request->user()), 403);
        $revision = $service->revision();
        $releases = AppReleaseVersion::query()->where('platform', 'android')->where('channel', 'development')
            ->orderByDesc('version_code')->paginate(20);
        $editing = $request->query('edit') ? AppReleaseVersion::query()->where('platform', 'android')
            ->where('channel', 'development')->findOrFail($request->query('edit')) : null;
        return view('admin.releases', ['releases' => $releases, 'editing' => $editing, 'revision' => $revision]);
    }

    public function store(Request $request, ReleaseManagement $service, AdminAccess $access)
    {
        abort_unless($access->allows($request->user()), 403);
        $service->web((int) $request->user()->id, $request->all());
        return redirect('/admin/releases')->with('status', '开发渠道发布元数据已保存。');
    }
}

