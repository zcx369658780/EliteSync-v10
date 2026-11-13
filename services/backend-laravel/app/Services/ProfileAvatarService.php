<?php

namespace App\Services;

use App\Models\MediaAsset;
use App\Models\User;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

/** Avatar references are projections, never bearer grants or public storage URLs. */
final class ProfileAvatarService
{
    public function authorizeLocked(int $viewer, int $owner): void
    {
        app(JourneyStore::class)->users([$viewer, $owner]);
        if ($viewer === $owner) return;
        abort_unless($this->contextAllowedLocked($viewer, $owner), 404, 'unavailable');
    }

    private function contextAllowedLocked(int $viewer, int $owner): bool
    {
        $policy = app(SocialPolicy::class);
        $context = $policy->friendship($viewer, $owner)
            || app(FormalRelationshipService::class)->sharingAllowed($viewer, $owner)
            || app(LiveConsentService::class)->match($viewer, $owner, true)
            || (app(LiveConsentService::class)->gates($viewer, $owner)['live_read_allowed'] ?? false);
        if (! $context) {
            // A bound invitation is temporary. Historical accepted requests and
            // a copied invitation token cannot independently keep an avatar visible.
            $requests = DB::table('social_requests')->where('pair_key', min($viewer, $owner).':'.max($viewer, $owner))
                ->whereIn('state', ['PENDING', 'ACCEPTED'])->where('expires_at', '>', now())->lockForUpdate()->get();
            foreach ($requests as $request) {
                if (! $request->invitation_id) continue;
                $invite = DB::table('social_invitations')->where('id', $request->invitation_id)
                    ->where('recipient_id', $request->recipient_id)->where('sender_id', $request->sender_id)
                    ->where('purpose', $request->purpose)->whereNull('revoked_at')->where('expires_at', '>', now())->lockForUpdate()->first();
                if ($invite) { $context = true; break; }
            }
        }
        return (bool) $context;
    }

    /** Existing profile access must not be widened or rejected by avatar absence. */
    public function profileReferenceLocked(int $viewer, int $owner): ?array
    {
        return $viewer === $owner || $this->contextAllowedLocked($viewer, $owner)
            ? $this->referenceLocked($owner)['avatar'] : null;
    }

    public function referenceLocked(int $owner): array
    {
        $row = DB::table('user_profile_avatars')->where('user_id', $owner)->lockForUpdate()->first();
        $revision = (int) ($row->revision ?? 0);
        $asset = $row?->media_asset_id ? MediaAsset::whereKey($row->media_asset_id)->where('owner_user_id', $owner)->lockForUpdate()->first() : null;
        $present = $asset && $asset->storage_disk === 'v1011_relationship' && $asset->isBackingObjectAvailable();

        return ['revision' => $revision, 'avatar' => $present ? [
            'owner_user_id' => $owner, 'revision' => $revision,
            'content_path' => '/api/v1/avatars/'.$owner.'/'.$revision,
        ] : null];
    }

    public function show(int $viewer, int $owner): array
    {
        return DB::transaction(function () use ($viewer, $owner) {
            $this->authorizeLocked($viewer, $owner);
            return $this->referenceLocked($owner);
        });
    }

    private function requireRevisionLocked(int $owner, int $expected): ?object
    {
        app(JourneyStore::class)->users([$owner]);
        $row = DB::table('user_profile_avatars')->where('user_id', $owner)->lockForUpdate()->first();
        abort_unless((int) ($row->revision ?? 0) === $expected, 409, 'AVATAR_CHANGED_REFRESH_REQUIRED');
        return $row;
    }

    public function replace(User $owner, UploadedFile $input, int $expected): array
    {
        abort_unless(app(LiveConsentService::class)->enabled(), 503, 'private avatar storage unavailable');
        DB::transaction(fn () => $this->requireRevisionLocked((int) $owner->id, $expected));
        $asset = app(PrivateProfileImageService::class)->store($owner, $input, 'profile_avatar', 'v1011_relationship');
        // Storage registration is independent: a failed concurrent pointer swap
        // leaves only the owner's unlinked private media, never an invalid pointer.
        return DB::transaction(function () use ($owner, $expected, $asset) {
            $old = $this->requireRevisionLocked((int) $owner->id, $expected);
            DB::table('user_profile_avatars')->updateOrInsert(['user_id' => $owner->id], [
                'media_asset_id' => $asset->id, 'revision' => $expected + 1,
                'created_at' => $old->created_at ?? now(), 'updated_at' => now(),
            ]);
            return $this->referenceLocked((int) $owner->id);
        });
    }

    public function remove(int $owner, int $expected): array
    {
        return DB::transaction(function () use ($owner, $expected) {
            $old = $this->requireRevisionLocked($owner, $expected);
            DB::table('user_profile_avatars')->updateOrInsert(['user_id' => $owner], [
                'media_asset_id' => null, 'revision' => $expected + 1,
                'created_at' => $old->created_at ?? now(), 'updated_at' => now(),
            ]);
            return $this->referenceLocked($owner);
        });
    }

    public function content(int $viewer, int $owner, int $revision)
    {
        return DB::transaction(function () use ($viewer, $owner, $revision) {
            $this->authorizeLocked($viewer, $owner);
            $ref = $this->referenceLocked($owner);
            abort_unless($ref['avatar'] && $ref['revision'] === $revision, 404, 'unavailable');
            $id = DB::table('user_profile_avatars')->where('user_id', $owner)->value('media_asset_id');
            $asset = MediaAsset::whereKey($id)->where('owner_user_id', $owner)->lockForUpdate()->firstOrFail();
            return response()->file(Storage::disk('v1011_relationship')->path($asset->storage_key), [
                'Content-Type' => 'image/png', 'Cache-Control' => 'private, no-store',
                'X-Content-Type-Options' => 'nosniff',
            ]);
        });
    }
}
