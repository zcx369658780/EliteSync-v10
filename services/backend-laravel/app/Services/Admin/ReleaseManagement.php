<?php

namespace App\Services\Admin;

use App\Models\AppReleaseVersion;
use App\Models\User;
use App\Services\Accounts\AdminAccess;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

final class ReleaseManagement
{
    public const KEY = 'releases:android:development';

    public function revision(): int
    {
        return (int) (DB::table('admin_versions')->where('key', self::KEY)->value('revision') ?? 0);
    }

    public function web(int $actor, array $input): AppReleaseVersion
    {
        abort_unless(app(AdminAccess::class)->allows(User::find($actor)), 403);
        $data = Validator::make($input, [
            'action' => 'required|in:upsert,activate,deactivate',
            'id' => 'nullable|integer|min:1',
            'expected_revision' => 'required|integer|min:0',
            'confirm' => 'required|accepted',
            'reason' => 'required|string|max:500',
        ])->validate();
        if (trim($data['reason']) === '') {
            throw ValidationException::withMessages(['reason' => '请填写操作理由。']);
        }
        if ($data['action'] !== 'upsert' && empty($data['id'])) {
            throw ValidationException::withMessages(['id' => '请选择发布记录。']);
        }
        $attributes = $data['action'] === 'upsert' ? $this->validateMetadata($input, true) : [];

        return $this->write('android', 'development', $data['action'], $data['id'] ?? null,
            $attributes, $actor, trim($data['reason']), (int) $data['expected_revision'], 'web');
    }

    public function cli(string $platform, string $channel, array $attributes): AppReleaseVersion
    {
        // Existing CLI channels remain available, under the same serialization and audit.
        $attributes = $this->validateMetadata($attributes, $platform === 'android' && $channel === 'development');

        return $this->write($platform, $channel, 'upsert', null, $attributes, null,
            'CLI release metadata upsert and activation', null, 'cli', true);
    }

    private function validateMetadata(array $input, bool $strict): array
    {
        $data = Validator::make($input, [
            'version_name' => ['required', 'string', 'max:32', 'regex:/^\d+\.\d+\.\d+[a-z]*$/i'],
            'version_code' => 'required|integer|min:1|max:4294967295',
            'min_supported_version_name' => $strict ? ['required', 'string', 'max:32', 'regex:/^\d+\.\d+\.\d+[a-z]*$/i'] : 'required|string|max:32',
            'download_url' => 'required|string|max:512',
            'sha256' => $strict ? ['required', 'regex:/^[a-fA-F0-9]{64}$/'] : 'nullable|string|max:128',
            'changelog' => 'nullable|string|max:20000',
            'force_update' => 'sometimes|boolean',
        ])->validate();
        if ($strict) {
            $parts = parse_url($data['download_url']);
            $scheme = strtolower((string) ($parts['scheme'] ?? ''));
            $host = strtolower((string) ($parts['host'] ?? ''));
            $local = $scheme === 'http' && in_array($host, ['localhost', '127.0.0.1'], true)
                && ($parts['port'] ?? 80) === 8000;
            if (! filter_var($data['download_url'], FILTER_VALIDATE_URL) || (! $local && $scheme !== 'https')
                || $host === '' || isset($parts['user']) || isset($parts['pass'])) {
                throw ValidationException::withMessages(['download_url' => '仅允许 HTTPS 或本地 localhost/127.0.0.1:8000 HTTP 下载地址。']);
            }
            if ($this->compare($data['min_supported_version_name'], $data['version_name']) > 0) {
                throw ValidationException::withMessages(['min_supported_version_name' => '最低支持版本不能高于发布版本。']);
            }
        }
        $data['sha256'] = strtoupper((string) ($data['sha256'] ?? ''));
        $data['changelog'] = (string) ($data['changelog'] ?? '');
        $data['force_update'] = (bool) ($data['force_update'] ?? false);

        return $data;
    }

    private function compare(string $a, string $b): int
    {
        $parse = static function (string $value): array {
            preg_match('/^(\d+)\.(\d+)\.(\d+)([a-z]*)$/i', $value, $m);
            $rank = 0;
            foreach (str_split(strtolower($m[4])) as $char) {
                $rank = $rank * 26 + ord($char) - 96;
            }

            return [(int) $m[1], (int) $m[2], (int) $m[3], $rank];
        };

        return $parse($a) <=> $parse($b);
    }

    private function write(string $platform, string $channel, string $action, ?int $id, array $attributes,
        ?int $actor, string $reason, ?int $expected, string $source, bool $publish = false): AppReleaseVersion
    {
        return DB::transaction(function () use ($platform, $channel, $action, $id, $attributes, $actor, $reason, $expected, $source, $publish) {
            $key = 'releases:'.$platform.':'.$channel;
            DB::table('admin_versions')->insertOrIgnore(['key' => $key, 'revision' => 0]);
            $lock = DB::table('admin_versions')->where('key', $key)->lockForUpdate()->first();
            if ($source === 'web') {
                $trusted = User::query()->whereKey($actor)->lockForUpdate()->first();
                abort_unless(app(AdminAccess::class)->allows($trusted), 403);
            }
            $revision = (int) $lock->revision;
            abort_if($expected !== null && $expected !== $revision, 409, '发布列表已改变，请刷新后重试。');
            $query = AppReleaseVersion::query()->where('platform', $platform)->where('channel', $channel);
            $before = (clone $query)->orderBy('id')->get()->map(fn ($row) => $this->snapshot($row))->all();
            if ($id !== null) {
                $release = (clone $query)->whereKey($id)->lockForUpdate()->firstOrFail();
            } elseif ($source === 'cli') {
                $release = (clone $query)->where('version_code', $attributes['version_code'])->first() ?? new AppReleaseVersion;
            } else {
                $release = new AppReleaseVersion;
            }
            if ($action === 'upsert') {
                $duplicate = (clone $query)->where('version_code', $attributes['version_code']);
                if ($release->exists) {
                    $duplicate->where('id', '!=', $release->id);
                }
                if ($duplicate->exists()) {
                    throw ValidationException::withMessages(['version_code' => '该渠道版本号已存在，请编辑已有记录。']);
                }
                $release->fill($attributes);
                abort_if($source === 'web' && $release->exists && ! $release->isDirty(), 409, '版本元数据未发生变化。');
                if (! $release->exists) {
                    $release->fill(['platform' => $platform, 'channel' => $channel, 'is_active' => false]);
                }
            } else {
                abort_if((bool) $release->is_active === ($action === 'activate'), 409, '该发布已处于目标状态。');
            }
            if ($action === 'activate') {
                $this->validateMetadata($release->attributesToArray(), true);
            }
            if ($publish || $action === 'activate') {
                (clone $query)->when($release->exists, fn ($q) => $q->where('id', '!=', $release->id))
                    ->where('is_active', true)->update(['is_active' => false]);
                $release->is_active = true;
                $release->published_at = now();
            } elseif ($action === 'deactivate') {
                $release->is_active = false;
            }
            $release->save();
            DB::table('admin_versions')->where('key', $key)->update(['revision' => $revision + 1]);
            $after = (clone $query)->orderBy('id')->get()->map(fn ($row) => $this->snapshot($row))->all();
            OperationAudit::record($actor, 'release.'.$source.'.'.$action, 'app_release', $release->id,
                $reason, $expected ?? $revision, ['revision' => $revision, 'releases' => $before],
                ['revision' => $revision + 1, 'releases' => $after]);

            return $release->refresh();
        });
    }

    private function snapshot(AppReleaseVersion $release): array
    {
        return ['changelog_sha256' => hash('sha256', (string) $release->changelog)] + $release->only(['id', 'platform', 'channel', 'version_name', 'version_code',
            'min_supported_version_name', 'download_url', 'sha256', 'force_update', 'is_active', 'published_at']);
    }
}
