<?php

namespace App\Services\Accounts;

use App\Models\MediaAsset;
use App\Models\User;
use App\Services\MediaCacheService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

final class AccountClosure
{
    private function receiptToken(string $id): string
    {
        abort_unless((string) config('app.key') !== '', 503, 'RECEIPT_KEY_NOT_CONFIGURED');

        return hash_hmac('sha256', 'account-closure:'.$id, (string) config('app.key'));
    }

    public function request(User $actor, string $password, string $key): array
    {
        return DB::transaction(function () use ($actor, $password, $key) {
            $user = User::query()->lockForUpdate()->findOrFail($actor->id);
            abort_unless(($user->role ?? 'user') === 'user', 403, 'ORDINARY_USER_REQUIRED');
            try {
                $matches = Hash::check($password, $user->password);
            } catch (\RuntimeException $error) {
                if ($error->getMessage() !== 'This password does not use the Bcrypt algorithm.') {
                    throw $error;
                }
                $matches = false;
            }
            abort_unless($matches, 422, 'CURRENT_PASSWORD_INVALID');
            $existing = DB::table('account_closures')->where('user_id', $user->id)->first();
            if ($existing) {
                abort_unless(hash_equals($existing->idempotency_key, $key), 409, 'CLOSURE_ALREADY_REQUESTED');

                return ['request_id' => $existing->id, 'receipt_token' => $this->receiptToken($existing->id), 'status' => $existing->status];
            }
            $id = (string) Str::uuid();
            $receipt = $this->receiptToken($id);
            DB::table('account_closures')->insert(['id' => $id, 'user_id' => $user->id,
                'idempotency_key' => $key, 'receipt_hash' => hash('sha256', $receipt), 'status' => 'DELETION_PENDING',
                'attempts' => 0, 'created_at' => now(), 'updated_at' => now()]);
            app(DisableUser::class)->execute((int) $user->id);
            // Voluntary closure revokes capabilities; it is not a new moderation offence.
            DB::table('users')->where('id', $user->id)->update(['account_status' => 'DELETION_PENDING',
                'moderation_status' => $user->moderation_status]);
            DB::table('status_posts')->where('author_user_id', $user->id)->update(['is_deleted' => true, 'deleted_at' => now()]);
            DB::table('user_profile_showcase_publications')->where('user_id', $user->id)->update(['public_display_eligible' => false]);

            return ['request_id' => $id, 'receipt_token' => $receipt, 'status' => 'DELETION_PENDING'];
        });
    }

    public function receipt(string $id, string $token): array
    {
        $row = DB::table('account_closures')->where('id', $id)->first();
        abort_unless($row && hash_equals($row->receipt_hash, hash('sha256', $token)), 404);

        return ['request_id' => $row->id, 'status' => $row->status, 'attempts' => $row->attempts,
            'result' => $row->result ? json_decode($row->result, true) : null];
    }

    public function recover(string $phone, string $password, string $key): array
    {
        // An unknown phone and an incorrect password/key deliberately share one response.
        $user = User::where('phone', $phone)->first();
        $storedHash = $user?->password ?? '$2y$04$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.';
        try {
            $matches = Hash::check($password, $storedHash);
        } catch (\RuntimeException $error) {
            if ($error->getMessage() !== 'This password does not use the Bcrypt algorithm.') {
                throw $error;
            }
            $matches = false;
        }
        $row = $user ? DB::table('account_closures')->where('user_id', $user->id)->first() : null;
        abort_unless($matches && $row && ($user->role ?? 'user') === 'user'
            && hash_equals($row->idempotency_key, $key), 422, 'CLOSURE_RECOVERY_UNAVAILABLE');

        return ['request_id' => $row->id, 'receipt_token' => $this->receiptToken($row->id), 'status' => $row->status];
    }

    public function erasurePermitted(int $id): bool
    {
        $connection = DB::connection();

        return app()->environment('local') && config('account_security.erasure_enabled') === true
            && $connection->getDriverName() === 'mysql'
            && $connection->getDatabaseName() === config('account_security.database')
            && $connection->getConfig('host') === config('account_security.host')
            && (int) $connection->getConfig('port') === (int) config('account_security.port')
            && DB::table('v1011_erasure_members')->where('user_id', $id)
                ->where('dataset', config('account_security.dataset'))->where('provenance', '<>', '')->exists();
    }

    /** Durable pending rows are the queue. A scheduled command may safely call this after restart. */
    public function processPending(int $limit = 25): int
    {
        $ids = DB::table('account_closures')->whereIn('status', ['DELETION_PENDING', 'FAILED_RETRYABLE'])
            ->orderBy('created_at')->limit(max(1, min(100, $limit)))->pluck('id');
        foreach ($ids as $id) {
            $this->process($id);
        }

        return $ids->count();
    }

    public function process(string $id): void
    {
        try {
            DB::transaction(function () use ($id) {
                $row = DB::table('account_closures')->where('id', $id)->lockForUpdate()->first();
                if (! $row || in_array($row->status, ['PRIVATE_DATA_ERASURE_COMPLETE', 'PRODUCTION_RETENTION_POLICY_PENDING'], true)) {
                    return;
                }
                $user = User::query()->lockForUpdate()->findOrFail($row->user_id);
                abort_unless(($user->role ?? 'user') === 'user' && $user->disabled, 409, 'CLOSURE_STATE_CONFLICT');
                $result = ['account' => 'ACCOUNT_CLOSED', 'retained' => ['shared_messages_and_counterpart_records',
                    'safety_disputes_and_audit', 'reported_or_held_status_evidence', 'questionnaire_history_D3', 'backups', 'shared_unregistered_or_held_media']];
                $status = 'PRODUCTION_RETENTION_POLICY_PENDING';
                if ($this->erasurePermitted((int) $user->id)) {
                    $result['cleared'] = $this->erasePrivateData($user);
                    $status = 'PRIVATE_DATA_ERASURE_COMPLETE';
                }
                DB::table('users')->where('id', $user->id)->update(['account_status' => 'ACCOUNT_CLOSED']);
                DB::table('account_closures')->where('id', $id)->update(['status' => $status,
                    'attempts' => $row->attempts + 1, 'result' => json_encode($result), 'completed_at' => now(), 'updated_at' => now()]);
            });
        } catch (\Throwable $error) {
            // Do not leak SQL, private values or secrets into the receipt. All erasure DB changes rolled back.
            DB::table('account_closures')->where('id', $id)->whereNotIn('status', ['PRIVATE_DATA_ERASURE_COMPLETE', 'PRODUCTION_RETENTION_POLICY_PENDING'])
                ->update(['status' => 'FAILED_RETRYABLE', 'attempts' => DB::raw('attempts + 1'),
                    'result' => json_encode(['account' => 'ACCOUNT_CLOSED', 'error' => 'PROCESSING_FAILED']), 'updated_at' => now()]);
        }
    }

    private function erasePrivateData(User $user): array
    {
        $cleared = [];
        foreach (['user_astro_profiles', 'user_natal_profiles', 'user_dynamic_charts', 'mbti_attempts', 'questionnaire_drafts'] as $table) {
            if (Schema::hasTable($table)) {
                $cleared[$table] = DB::table($table)->where('user_id', $user->id)->delete();
            }
        }
        // Preserve audit foreign keys rather than cascading away the review history.
        DB::table('user_profile_showcase_drafts')->where('user_id', $user->id)->update([
            'self_intro' => null, 'interest_tags' => null, 'lifestyle_tags' => null, 'opener_note' => null,
            'public_display_eligible' => false, 'matching_scoring_eligible' => false]);
        DB::table('user_profile_showcase_publications')->where('user_id', $user->id)->update([
            'published_payload' => '{}', 'public_display_eligible' => false, 'matching_scoring_eligible' => false]);
        DB::table('status_posts')->where('author_user_id', $user->id)
            ->whereNotExists(fn ($q) => $q->select(DB::raw(1))->from('moderation_reports')
                ->whereColumn('target_status_post_id', 'status_posts.id'))
            ->whereNotExists(fn ($q) => $q->select(DB::raw(1))->from('v1011_erasure_assets')
                ->whereColumn('asset_id', 'status_posts.cover_media_asset_id')->where('evidence_hold', true))
            ->update([
                'title' => 'Account unavailable', 'body' => '', 'location_name' => null, 'is_deleted' => true]);
        $values = ['name' => null, 'phone' => 'closed:'.substr(hash('sha256', (string) Str::uuid()), 0, 24), 'email' => null,
            'password' => Hash::make(Str::random(64)), 'remember_token' => null, 'realname_verified' => false];
        foreach (['birthday', 'zodiac_animal', 'gender', 'city', 'relationship_goal', 'public_zodiac_sign',
            'public_mbti', 'public_personality', 'private_bazi', 'private_natal_chart', 'private_ziwei',
            'private_birth_place', 'private_birth_lat', 'private_birth_lng'] as $column) {
            if (Schema::hasColumn('users', $column)) {
                $values[$column] = null;
            }
        }
        DB::table('users')->where('id', $user->id)->update($values);
        $cleared['user_profile_and_showcase'] = true;
        $cleared['unheld_unreported_status_content'] = true;
        $this->detachErasablePostCovers((int) $user->id);
        $cleared['unreferenced_registered_media'] = $this->eraseOwnedMedia((int) $user->id);

        return $cleared;
    }

    private function detachErasablePostCovers(int $userId): void
    {
        // A closed user's own redacted post is not an independent counterpart
        // record. Keep held/reported evidence links and all unregistered assets.
        $registered = DB::table('v1011_erasure_assets')->where('user_id', $userId)
            ->where('dataset', config('account_security.dataset'))->where('evidence_hold', false)->lockForUpdate()->get();
        foreach ($registered as $entry) {
            $asset = MediaAsset::whereKey($entry->asset_id)->where('owner_user_id', $userId)->lockForUpdate()->first();
            if (! $asset || $asset->storage_disk !== 'v1011_relationship'
                || ! hash_equals($entry->storage_key, $asset->storage_key)
                || ! hash_equals($entry->sha256, (string) $asset->sha256)) {
                continue;
            }
            $posts = DB::table('status_posts')->where('author_user_id', $userId)
                ->where('cover_media_asset_id', $asset->id)->lockForUpdate()->get(['id']);
            foreach ($posts as $post) {
                if (DB::table('moderation_reports')->where('target_status_post_id', $post->id)->exists()) {
                    continue;
                }
                DB::table('status_posts')->where('id', $post->id)->update(['cover_media_asset_id' => null]);
            }
        }
    }

    private function eraseOwnedMedia(int $userId): int
    {
        $count = 0;
        foreach (DB::table('v1011_erasure_assets')->where('user_id', $userId)->where('dataset', config('account_security.dataset'))->where('evidence_hold', false)->lockForUpdate()->get() as $registered) {
            $asset = MediaAsset::whereKey($registered->asset_id)->where('owner_user_id', $userId)->lockForUpdate()->first();
            if (! $asset || $asset->status === 'deleted') {
                continue;
            }
            if ($asset->storage_disk !== 'v1011_relationship' || ! hash_equals($registered->storage_key, $asset->storage_key) || ! hash_equals($registered->sha256, (string) $asset->sha256)) {
                continue;
            }
            if (DB::table('message_attachments')->where('media_asset_id', $asset->id)->exists()
                || DB::table('status_posts')->where('cover_media_asset_id', $asset->id)->exists()) {
                continue;
            }
            // Do not allow storage adapters to resolve traversal or absolute paths.
            $key = (string) $asset->storage_key;
            abort_if($key === '' || str_starts_with($key, '/') || str_contains($key, '\\') || preg_match('~(^|/)\.\.(/|$)|:~', $key), 409, 'UNSAFE_MEDIA_KEY');
            $disk = Storage::disk('v1011_relationship');
            // Filesystem delete is idempotent if a later database commit fails.
            if ($disk->exists($key)) {
                $root = realpath(storage_path('app/v1011-relationship-private'));
                $base = realpath(base_path());
                $target = realpath($disk->path($key));
                abort_unless($root && $base && $target
                    && str_starts_with(strtolower($root), strtolower($base.DIRECTORY_SEPARATOR))
                    && str_starts_with(strtolower($target), strtolower($root.DIRECTORY_SEPARATOR)), 409, 'MEDIA_ROOT_IDENTITY_CHANGED');
                abort_unless(hash_equals($registered->sha256, hash_file('sha256', $disk->path($key))), 409, 'MEDIA_IDENTITY_CHANGED');
                abort_unless($disk->delete($key), 503, 'MEDIA_DELETE_FAILED');
            }
            app(MediaCacheService::class)->forgetAssetSnapshot((int) $asset->id);
            DB::table('media_processing_jobs')->where('media_asset_id', $asset->id)->update(['payload' => '{}']);
            $asset->forceFill(['status' => 'deleted', 'original_name' => null, 'metadata' => null, 'public_url' => null, 'storage_key' => 'erased/'.$asset->id])->save();
            $count++;
        }

        return $count;
    }
}
