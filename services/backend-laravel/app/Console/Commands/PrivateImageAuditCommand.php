<?php

namespace App\Console\Commands;

use App\Models\MediaAsset;
use App\Services\SyntheticConnectionScope;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

final class PrivateImageAuditCommand extends Command
{
    protected $signature = 'app:media:audit-private-images {disk : Local private image disk}';

    protected $description = 'Report private image retry objects in the isolated synthetic environment without modifying files or rows';

    private const PREFIX = 'private-image-retry';

    public function handle(SyntheticConnectionScope $scope): int
    {
        $disk = $this->argument('disk');
        $connection = DB::connection();
        $inMemory = app()->environment('testing') && $connection->getDriverName() === 'sqlite'
            && $connection->getDatabaseName() === ':memory:' && ! $connection->getConfig('url');

        if (! in_array($disk, ['v1007', 'v1009', 'v1011_relationship'], true)
            || (! $inMemory && ! $scope->matchesDatabase())) {
            $this->error('A local private image disk and the isolated synthetic environment are required.');

            return self::FAILURE;
        }

        $config = config('filesystems.disks.'.$disk);
        $root = ($config['driver'] ?? null) === 'local' ? realpath($config['root']) : false;
        if ($root === false || ! is_dir($root) || ! is_readable($root)) {
            $this->error('The private disk root is unavailable.');

            return self::FAILURE;
        }
        $root = str_replace('\\', '/', $root);

        $assets = MediaAsset::withTrashed()->where('storage_disk', $disk)
            ->where('storage_key', 'like', self::PREFIX.'/%');
        foreach ((clone $assets)->lazyById() as $asset) {
            $key = $asset->storage_key;
            $file = $this->owner($key) === null ? null : $this->file($root.'/'.$key);
            $linked = $this->hasBusinessLink($asset->id);
            $this->emit([
                'disk' => $disk, 'storage_key' => $key, 'asset_id' => $asset->id,
                'owner_id' => $asset->owner_user_id, 'upload_id' => $asset->client_upload_id,
                'asset_status' => $asset->status, 'asset_error' => $asset->error_code,
                'lifecycle' => $asset->trashed() ? 'SOFT_DELETED' : match ($asset->status) {
                    'pending', 'uploading', 'uploaded', 'processing' => 'IN_PROGRESS',
                    'ready' => 'COMPLETED',
                    'failed', 'blocked' => 'FAILED_OR_BLOCKED',
                    default => 'OTHER',
                },
                'database_sha256' => $asset->sha256,
                'file_present' => $file !== null, 'actual_sha256' => $file,
                'candidate_without_business_link' => $file !== null && ! $linked,
            ]);
        }

        $paths = glob($root.'/'.self::PREFIX.'/*/*', GLOB_NOSORT | GLOB_ERR);
        if ($paths === false) {
            $this->error('The retry directory could not be enumerated.');

            return self::FAILURE;
        }
        foreach ($paths as $path) {
            $key = substr($path, strlen($root) + 1);
            $owner = $this->owner($key);
            if ($owner === null || (clone $assets)->where('storage_key', $key)->exists()) {
                continue;
            }
            $sha = $this->file($path);
            if ($sha === null) {
                continue;
            }
            $pending = str_ends_with($key, '.pending');
            $attempt = $pending ? (clone $assets)->where('storage_key', substr($key, 0, -8))->first() : null;
            $this->emit([
                'disk' => $disk, 'storage_key' => $key, 'asset_id' => $attempt?->id,
                'owner_id' => $owner, 'upload_id' => $attempt?->client_upload_id,
                'asset_status' => $attempt?->status,
                'lifecycle' => $attempt ? 'REGISTERED_PENDING_FILE'
                    : ($pending ? 'UNREGISTERED_PENDING_FILE' : 'UNREGISTERED_FINAL_FILE'),
                'database_sha256' => $attempt?->sha256, 'file_present' => true, 'actual_sha256' => $sha,
                'candidate_without_business_link' => $attempt === null,
            ]);
        }

        return self::SUCCESS;
    }

    private function owner(string $key): ?int
    {
        return preg_match('#\\A'.self::PREFIX.'/([1-9][0-9]*)/[0-9a-f]{64}(?:\\.pending)?\\z#D', $key, $parts)
            ? (int) $parts[1] : null;
    }

    private function file(string $path): ?string
    {
        $resolved = realpath($path);
        if ($resolved === false || str_replace('\\', '/', $resolved) !== $path || ! is_file($resolved)) {
            return null;
        }
        $sha = hash_file('sha256', $resolved);
        if ($sha === false) {
            throw new \RuntimeException('A private object could not be checksummed.');
        }

        return $sha;
    }

    private function hasBusinessLink(int $asset): bool
    {
        return DB::table('message_attachments')->where('media_asset_id', $asset)->exists()
            || DB::table('status_posts')->where('cover_media_asset_id', $asset)->exists()
            || DB::table('user_profile_avatars')->where('media_asset_id', $asset)->exists()
            || DB::table('profile_showcase_photos')->where('media_asset_id', $asset)->exists()
            || DB::table('v1011_erasure_assets')->where('asset_id', $asset)->exists();
    }

    private function emit(array $row): void
    {
        $this->line(json_encode($row, JSON_THROW_ON_ERROR | JSON_UNESCAPED_SLASHES));
    }
}

