<?php

namespace App\Services\Accounts;

use App\Models\User;
use Closure;
use DomainException;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

final class LegacyAdminRestore
{
    public function __construct(private LegacyAdminTarget $target) {}

    public function preview(array $manifest): array
    {
        $this->checkManifest($manifest);
        $batch = $this->batch($manifest);
        if ($batch) {
            return $this->states($manifest['batch']);
        }

        return collect($manifest['candidates'])->mapWithKeys(fn (array $row) => [
            $row['candidate'] => $this->conflict($manifest, $row) ?? 'ready',
        ])->all();
    }

    public function apply(array $manifest): array
    {
        $this->checkManifest($manifest, write: true);

        return DB::transaction(function () use ($manifest) {
            $created = DB::table('legacy_admin_batches')->insertOrIgnore([
                'id' => $manifest['batch'],
                'source_system' => $manifest['source_system'],
                'snapshot' => $manifest['snapshot'],
                'target' => $manifest['target'],
                'approval' => $manifest['approval'],
                'manifest_hash' => LegacyAdminManifest::fingerprint($manifest),
                'created_at' => now(),
            ]);
            $batch = $this->batch($manifest, lock: true);
            if ($batch->rolled_back_at !== null) {
                throw new DomainException('Rolled-back batch cannot be restored again.');
            }
            if (! $created) {
                return $this->states($manifest['batch']);
            }
            foreach ($manifest['candidates'] as $row) {
                if ($this->conflict($manifest, $row) !== null) {
                    throw new DomainException('Batch has a conflict or missing allowlist approval. Run dry-run.');
                }
                $synthetic = $manifest['target'] === 'local-v2-function';
                $user = User::create([
                    'phone' => $row['phone'],
                    'name' => $row['name'] ?? null,
                    'password' => bin2hex(random_bytes(32)),
                    'role' => 'user',
                    'disabled' => true,
                    'account_status' => 'disabled',
                    'account_type' => $synthetic ? 'test' : 'normal',
                    'is_synthetic' => $synthetic,
                    'exclude_from_metrics' => true,
                    'is_match_eligible' => false,
                    'is_square_visible' => false,
                    'visibility_scope' => 'hidden',
                    'verify_status' => 'pending',
                    'realname_verified' => false,
                ]);
                if ((int) $user->id === $row['legacy_user_id']) {
                    throw new DomainException('Generated ID coincides with its old ID. Batch stopped.');
                }
                $mapping = DB::table('legacy_admin_mappings')->insertGetId([
                    'batch_id' => $manifest['batch'],
                    'source_system' => $manifest['source_system'],
                    'legacy_user_id' => $row['legacy_user_id'],
                    'user_id' => $user->id,
                    'candidate' => $row['candidate'],
                    'phone_fingerprint' => $this->phoneFingerprint($row['phone']),
                    'state' => 'pending',
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
                $this->audit($manifest['batch'], $mapping, $manifest['operator'], 'staged',
                    array_values(array_intersect(['phone', 'name', 'status', 'role'], array_keys($row))));
            }

            return $this->states($manifest['batch']);
        });
    }

    public function issue(array $manifest, string $candidate, Closure $deliver): void
    {
        $this->checkManifest($manifest, write: true);

        DB::transaction(function () use ($manifest, $candidate, $deliver) {
            $batch = $this->batch($manifest, lock: true);
            $mapping = DB::table('legacy_admin_mappings')->where('batch_id', $manifest['batch'])
                ->where('candidate', $candidate)->lockForUpdate()->first();
            if (! $batch || $batch->rolled_back_at !== null || ! $mapping || $mapping->state !== 'pending') {
                throw new DomainException('Candidate is not pending in an active restoration batch.');
            }
            $user = User::whereKey($mapping->user_id)->lockForUpdate()->firstOrFail();
            if (! $this->pendingAndAllowed($user, $mapping)) {
                throw new DomainException('Candidate no longer meets the staged-account or allowlist conditions.');
            }
            $expires = now()->addMinutes(30);
            $secret = bin2hex(random_bytes(32));
            DB::table('legacy_admin_mappings')->where('id', $mapping->id)->update([
                'activation_hash' => hash('sha256', $secret),
                'activation_expires_at' => $expires,
                'updated_at' => now(),
            ]);
            $this->audit($batch->id, (int) $mapping->id, $manifest['operator'], 'issued');
            // Delivery failure rolls back this rotation. A file left by a failed commit holds an invalid code.
            $deliver($secret, $expires);
        });
    }

    public function activate(#[\SensitiveParameter] string $secret, #[\SensitiveParameter] string $password): bool
    {
        $this->target->assert((string) config('legacy_admin.target'));
        if (! preg_match('/^[a-f0-9]{64}$/D', $secret)) {
            return false;
        }

        return DB::transaction(function () use ($secret, $password) {
            $mapping = DB::table('legacy_admin_mappings')->where('activation_hash', hash('sha256', $secret))->lockForUpdate()->first();
            if (! $mapping || $mapping->state !== 'pending' || ! $mapping->activation_expires_at
                || now()->gte(Carbon::parse($mapping->activation_expires_at))) {
                return false;
            }
            $batch = DB::table('legacy_admin_batches')->where('id', $mapping->batch_id)->first();
            if ($batch->target !== config('legacy_admin.target') || $batch->approval !== config('legacy_admin.approval')
                || $batch->rolled_back_at !== null) {
                return false;
            }
            $user = User::whereKey($mapping->user_id)->lockForUpdate()->firstOrFail();
            if (! $this->pendingAndAllowed($user, $mapping)) {
                return false;
            }
            $user->forceFill([
                'password' => $password,
                'role' => 'admin',
                'disabled' => false,
                'account_status' => 'active',
            ])->save();
            DB::table('legacy_admin_mappings')->where('id', $mapping->id)->update([
                'state' => 'active', 'activation_hash' => null, 'activation_expires_at' => null, 'updated_at' => now(),
            ]);
            $this->audit($batch->id, (int) $mapping->id, 'holder', 'activated');

            return true;
        });
    }

    public function rollback(array $manifest): array
    {
        $this->checkManifest($manifest, write: true);

        return DB::transaction(function () use ($manifest) {
            $batch = $this->batch($manifest, lock: true);
            if (! $batch) {
                throw new DomainException('No matching batch to roll back.');
            }
            if ($batch->rolled_back_at === null) {
                $rows = DB::table('legacy_admin_mappings')->where('batch_id', $batch->id)->orderBy('id')->lockForUpdate()->get();
                foreach ($rows as $row) {
                    $user = User::whereKey($row->user_id)->lockForUpdate()->firstOrFail();
                    $user->forceFill([
                        'role' => 'user',
                        'disabled' => true,
                        'account_status' => 'disabled',
                        'remember_token' => null,
                        'is_match_eligible' => false,
                        'is_square_visible' => false,
                        'visibility_scope' => 'hidden',
                    ])->save();
                    app(DeviceSessions::class)->revokeAll($user);
                    DB::table('platform_admin_sessions')->where('user_id', $user->id)->whereNull('revoked_at')
                        ->update(['revoked_at' => now(), 'updated_at' => now()]);
                    DB::table('legacy_admin_mappings')->where('id', $row->id)->update([
                        'state' => 'rolled_back', 'activation_hash' => null, 'activation_expires_at' => null, 'updated_at' => now(),
                    ]);
                    $this->audit($batch->id, (int) $row->id, $manifest['operator'], 'rolled_back');
                }
                DB::table('legacy_admin_batches')->where('id', $batch->id)->update(['rolled_back_at' => now()]);
            }

            return $this->states($batch->id);
        });
    }

    private function checkManifest(array $manifest, bool $write = false): void
    {
        $this->target->assert($manifest['target'], $write ? $manifest['approval'] : null);
        if ($manifest['target'] === 'local-v2-function') {
            foreach ($manifest['candidates'] as $row) {
                if (! preg_match('/^\+120255501[0-9]{2}$/D', $row['phone'])) {
                    throw new DomainException('The local function target accepts only fictional 202-555-01xx identifiers.');
                }
            }
        }
    }

    private function conflict(array $manifest, array $row): ?string
    {
        if (DB::table('legacy_admin_mappings')->where('source_system', $manifest['source_system'])
            ->where('legacy_user_id', $row['legacy_user_id'])->exists()) {
            return 'legacy_id_already_mapped';
        }
        if (User::where('phone', $row['phone'])->exists()) {
            return 'login_identifier_conflict';
        }

        return in_array($row['phone'], config('app.admin_phones', []), true) ? null : 'allowlist_missing';
    }

    private function pendingAndAllowed(User $user, object $mapping): bool
    {
        return $user->disabled && $user->role === 'user' && $user->account_status === 'disabled'
            && $user->moderation_status === 'normal' && ! $user->realname_verified
            && hash_equals($mapping->phone_fingerprint, $this->phoneFingerprint((string) $user->phone))
            && in_array((string) $user->phone, config('app.admin_phones', []), true);
    }

    private function phoneFingerprint(string $phone): string
    {
        return hash_hmac('sha256', 'legacy-admin-phone:'.$phone, config('app.key'));
    }

    private function batch(array $manifest, bool $lock = false): ?object
    {
        $query = DB::table('legacy_admin_batches')->where('id', $manifest['batch']);
        $batch = ($lock ? $query->lockForUpdate() : $query)->first();
        if ($batch && ! hash_equals($batch->manifest_hash, LegacyAdminManifest::fingerprint($manifest))) {
            throw new DomainException('Batch ID already has a different approved manifest.');
        }

        return $batch;
    }

    private function states(string $batch): array
    {
        return DB::table('legacy_admin_mappings')->where('batch_id', $batch)->orderBy('candidate')
            ->pluck('state', 'candidate')->all();
    }

    private function audit(string $batch, int $mapping, string $actor, string $action, ?array $fields = null): void
    {
        DB::table('legacy_admin_restore_audits')->insert([
            'batch_id' => $batch,
            'mapping_id' => $mapping,
            'actor' => $actor,
            'action' => $action,
            'fields' => $fields === null ? null : json_encode($fields, JSON_THROW_ON_ERROR),
            'created_at' => now(),
        ]);
    }
}
