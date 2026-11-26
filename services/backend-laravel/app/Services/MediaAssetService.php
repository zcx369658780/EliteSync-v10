<?php

namespace App\Services;

use App\Jobs\ProcessMediaAssetJob;
use App\Models\MediaAsset;
use App\Models\MediaProcessingJob;
use App\Models\User;
use App\Services\Accounts\AccountClosure;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use RuntimeException;
use Throwable;

class MediaAssetService
{
    public function registerDraft(User $user, array $data): MediaAsset
    {
        $disk = (string) config('media.disk', 'public');
        $provider = $this->providerFromDisk($disk);
        $storageKey = $data['storage_key'] ?? $this->draftStorageKey((int) $user->id, (string) ($data['media_type'] ?? 'file'));

        $asset = MediaAsset::query()->create([
            'owner_user_id' => $user->id,
            'media_type' => (string) ($data['media_type'] ?? 'file'),
            'storage_provider' => $provider,
            'storage_disk' => $disk,
            'storage_key' => $storageKey,
            'original_name' => $data['original_name'] ?? null,
            'mime_type' => $data['mime_type'] ?? null,
            'size_bytes' => (int) ($data['size_bytes'] ?? 0),
            'width' => $data['width'] ?? null,
            'height' => $data['height'] ?? null,
            'duration_ms' => $data['duration_ms'] ?? null,
            'sha256' => $data['sha256'] ?? null,
            'status' => ! empty($data['public_url']) ? 'uploaded' : 'pending',
            'public_url' => $data['public_url'] ?? null,
            'metadata' => $data['metadata'] ?? null,
            'uploaded_at' => ! empty($data['public_url']) ? now() : null,
        ]);

        MediaProcessingJob::query()->create([
            'media_asset_id' => $asset->id,
            'job_type' => 'register',
            'status' => 'queued',
            'attempt_count' => 0,
            'max_attempts' => 3,
            'locked_at' => null,
            'processed_at' => null,
            'payload' => [
                'storage_key' => $storageKey,
                'disk' => $disk,
            ],
        ]);

        return $asset;
    }

    public function registerPrivateImageRetry(User $actor, UploadedFile $file, array $data, string $disk): MediaAsset
    {
        $uploadId = strtolower($data['client_upload_id']);
        $sha256 = hash_file('sha256', $file->getPathname());
        if ($sha256 === false) {
            throw new RuntimeException('Private image could not be read');
        }

        return DB::transaction(function () use ($actor, $file, $data, $disk, $uploadId, $sha256) {
            $owner = User::query()->lockForUpdate()->findOrFail($actor->id);
            abort_if($owner->disabled || $owner->account_status !== 'active', 403, 'ACCOUNT_UNAVAILABLE');
            app(\App\Services\Accounts\DeviceSessions::class)->assertCurrentCredential($actor);
            $previous = MediaAsset::withTrashed()
                ->where('owner_user_id', $owner->id)
                ->where('client_upload_id', $uploadId)
                ->lockForUpdate()
                ->first();
            if ($previous) {
                abort_if($previous->trashed() || $previous->storage_disk !== $disk ||
                    $previous->media_type !== 'image' || $previous->sha256 !== $sha256, 409, 'Upload attempt conflicts');
                if (in_array($previous->error_code, ['mime_not_allowed', 'upload_too_large'], true)) {
                    return $previous;
                }
                abort_if(in_array($previous->status, ['uploading', 'uploaded', 'processing'], true), 503, 'Upload attempt is processing');
                abort_unless($previous->status === 'ready', 409, 'Upload attempt is unavailable');
                $filesystem = Storage::disk($disk);
                // Local storage can report false while a mount is unavailable.
                // Keep the attempt retryable without minting another asset.
                abort_unless($filesystem->exists($previous->storage_key), 503, 'Upload object unavailable');
                $storedHash = $filesystem->checksum($previous->storage_key, ['checksum_algo' => 'sha256']);
                if ($storedHash === false) {
                    throw new RuntimeException('Private image checksum unavailable');
                }
                abort_unless($storedHash === $sha256, 409, 'Upload attempt conflicts');

                return $previous;
            }

            // The owner lock spans the outer HTTP transaction. Keep the object
            // recoverable by this attempt even if its database write rolls back.
            $key = sprintf('private-image-retry/%d/%s', $owner->id, hash('sha256', $uploadId));

            return $this->registerUploaded($owner, $file, array_replace($data, [
                'storage_key' => $key,
                'client_upload_id' => $uploadId,
                'sha256' => $sha256,
            ]));
        });
    }

    public function registerUploaded(User $user, UploadedFile $file, array $data = [], ?MediaStorageService $storage = null): MediaAsset
    {
        $policy = app(MediaUploadPolicy::class);
        $storage ??= app(MediaStorageService::class);
        $mimeType = strtolower(trim((string) ($data['mime_type'] ?? $file->getMimeType() ?? '')));
        $sizeBytes = (int) ($data['size_bytes'] ?? $file->getSize() ?? 0);
        $mediaType = (string) ($data['media_type'] ?? $this->mediaTypeFromMime($mimeType));
        $originalName = (string) ($data['original_name'] ?? $file->getClientOriginalName() ?? $file->getFilename() ?? 'upload.bin');
        $storageKey = $data['storage_key'] ?? $storage->buildUploadStorageKey((int) $user->id, $mediaType, $originalName);

        $asset = MediaAsset::query()->create([
            'owner_user_id' => $user->id,
            'client_upload_id' => $data['client_upload_id'] ?? null,
            'media_type' => $mediaType,
            'storage_provider' => $storage->provider(),
            'storage_disk' => $storage->disk(),
            'storage_key' => $storageKey,
            'original_name' => $originalName,
            'mime_type' => $mimeType !== '' ? $mimeType : null,
            'size_bytes' => max(0, $sizeBytes),
            'width' => $data['width'] ?? null,
            'height' => $data['height'] ?? null,
            'duration_ms' => $data['duration_ms'] ?? null,
            'sha256' => $data['sha256'] ?? null,
            'status' => 'uploading',
            'public_url' => null,
            'metadata' => $data['metadata'] ?? null,
            'uploaded_at' => null,
        ]);

        if (! $policy->isAllowedMime($asset->mime_type)) {
            $asset->forceFill([
                'status' => 'blocked',
                'error_code' => 'mime_not_allowed',
                'error_message' => 'mime type is not allowed by media policy',
            ])->save();

            return $asset->refresh();
        }

        if (! $policy->isAllowedSize($asset->size_bytes)) {
            $asset->forceFill([
                'status' => 'failed',
                'error_code' => 'upload_too_large',
                'error_message' => 'file size is larger than the configured upload limit',
            ])->save();

            return $asset->refresh();
        }

        try {
            $stored = $asset->client_upload_id === null
                ? $storage->storeUploadedFile($file, $asset->storage_key)
                : $this->storeRetryableImage($storage, $file, $asset->storage_key, $data['sha256']);

            $realPath = $file->getRealPath();

            $asset->forceFill([
                'storage_disk' => $stored['disk'],
                'storage_provider' => $stored['provider'],
                'storage_key' => $stored['storage_key'],
                'public_url' => $stored['public_url'],
                'status' => 'uploaded',
                'uploaded_at' => now(),
                'sha256' => $data['sha256'] ?? ($realPath ? hash_file('sha256', $realPath) : null),
            ])->save();
        } catch (Throwable $e) {
            $asset->forceFill([
                'status' => 'failed',
                'error_code' => 'storage_write_failed',
                'error_message' => $e->getMessage(),
            ])->save();

            throw $e;
        }

        MediaProcessingJob::query()->create([
            'media_asset_id' => $asset->id,
            'job_type' => 'register',
            'status' => 'queued',
            'attempt_count' => 0,
            'max_attempts' => 3,
            'locked_at' => null,
            'processed_at' => null,
            'payload' => [
                'storage_key' => $asset->storage_key,
                'disk' => $asset->storage_disk,
            ],
        ]);

        try {
            ProcessMediaAssetJob::dispatchSync($asset->id);
        } catch (Throwable $e) {
            $asset->forceFill([
                'status' => 'failed',
                'error_code' => 'processing_failed',
                'error_message' => $e->getMessage(),
            ])->save();

            throw $e;
        }

        if (in_array($asset->storage_disk, ['v1007', 'v1009', 'v1011_relationship'], true)) {
            $asset->forceFill(['public_url' => rtrim((string) config('app.url'), '/').'/api/v1/media/'.$asset->id.'/content'])->save();
        }
        if ($asset->storage_disk === 'v1011_relationship' && app(AccountClosure::class)->erasurePermitted((int) $user->id)) {
            DB::table('v1011_erasure_assets')->insertOrIgnore(['asset_id' => $asset->id, 'user_id' => $user->id, 'dataset' => config('account_security.dataset'), 'storage_key' => $asset->storage_key, 'sha256' => $asset->sha256, 'evidence_hold' => false, 'registered_at' => now()]);
        }

        return $asset->refresh();
    }

    private function storeRetryableImage(MediaStorageService $storage, UploadedFile $file, string $key, string $sha256): array
    {
        $disk = Storage::disk($storage->disk());
        if (! $disk->exists($key)) {
            // The private disks are local. Rename the verified temporary file
            // into place so an interrupted write cannot replace committed bytes.
            $temporary = $key.'.pending';
            $storage->storeUploadedFile($file, $temporary);
            if ($disk->checksum($temporary, ['checksum_algo' => 'sha256']) !== $sha256
                || ! $disk->move($temporary, $key)) {
                throw new RuntimeException('Private image could not be finalized');
            }
        }
        abort_unless($disk->checksum($key, ['checksum_algo' => 'sha256']) === $sha256, 409, 'Upload attempt conflicts');

        return ['disk' => $storage->disk(), 'provider' => 'local', 'storage_key' => $key, 'public_url' => null];
    }

    public function providerFromDisk(string $disk): string
    {
        return 'oss';
    }

    public function mediaTypeFromMime(?string $mime): string
    {
        $mime = strtolower(trim((string) $mime));
        if (str_starts_with($mime, 'image/')) {
            return 'image';
        }
        if (str_starts_with($mime, 'video/')) {
            return 'video';
        }
        if (str_starts_with($mime, 'audio/')) {
            return 'audio';
        }

        return 'file';
    }

    public function draftStorageKey(int $userId, string $mediaType): string
    {
        $safeType = preg_replace('/[^a-z0-9_-]+/i', '-', strtolower($mediaType)) ?: 'file';

        return sprintf(
            '%s/%d/%s/%s',
            rtrim((string) config('media.public_base_path', 'chat-media'), '/'),
            $userId,
            $safeType,
            (string) Str::uuid()
        );
    }
}
