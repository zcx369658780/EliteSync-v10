<?php

namespace App\Services\Accounts;

use DateTimeImmutable;
use DateTimeZone;
use DomainException;

final class LegacyAdminApproval
{
    private const REQUIRED_FIELDS = ['legacy_user_id', 'phone', 'role', 'status'];
    private const MAX_AGE = 7 * 86400;

    public function verify(array $manifest, bool $rollback): ?DateTimeImmutable
    {
        if (! isset($manifest['authorization'], $manifest['signature'])) {
            if ($manifest['target'] !== 'local-v2-function'
                || array_key_exists('authorization', $manifest) || array_key_exists('signature', $manifest)) {
                throw new DomainException('An independently signed Owner authorization is required.');
            }

            return null;
        }

        $auth = $manifest['authorization'];
        if (! $this->hasKeys($auth, ['fields', 'issued_at', 'expires_at', 'target_binding'])
            || $manifest['approval'] !== config('legacy_admin.approval')
            || $manifest['operator'] !== config('legacy_admin.operator')
            || $this->json($auth['target_binding']) !== $this->json(LegacyAdminTarget::binding())
            || ! in_array($auth['fields'], [self::REQUIRED_FIELDS, ['legacy_user_id', 'name', 'phone', 'role', 'status']], true)) {
            throw new DomainException('Owner authorization scope does not match this target or operator.');
        }
        $public = $this->decode(config('legacy_admin.owner_public_key'), 32);
        $signature = $this->decode($manifest['signature'], 64);
        if (! function_exists('sodium_crypto_sign_verify_detached')
            || ! sodium_crypto_sign_verify_detached($signature, self::message($manifest), $public)) {
            throw new DomainException('Owner authorization signature could not be verified.');
        }

        $issued = $this->time($auth['issued_at']);
        $expires = $this->time($auth['expires_at']);
        $now = now()->timestamp;
        if ($issued->getTimestamp() > $now || $expires <= $issued
            || $expires->getTimestamp() - $issued->getTimestamp() > self::MAX_AGE
            || (! $rollback && $expires->getTimestamp() <= $now)) {
            throw new DomainException('Owner authorization time window is invalid or expired.');
        }

        $deadline = $expires;
        foreach ($manifest['candidates'] as $candidate) {
            $proof = $candidate['holder_proof'] ?? null;
            if (! $this->hasKeys($proof, ['holder_ref', 'old_allowlist_ref', 'verified_by', 'verified_at', 'expires_at',
                'controls_original_phone', 'old_allowlist_match', 'approved_duty'])
                || $proof['controls_original_phone'] !== true || $proof['old_allowlist_match'] !== true
                || (isset($candidate['name']) && ! in_array('name', $auth['fields'], true))) {
                throw new DomainException('Candidate has incomplete holder or legacy allowlist evidence.');
            }
            foreach (['holder_ref', 'old_allowlist_ref', 'verified_by', 'approved_duty'] as $key) {
                if (! is_string($proof[$key]) || ! preg_match('/^[a-z][a-z0-9._-]{1,63}$/D', $proof[$key])) {
                    throw new DomainException('Candidate proof requires private evidence and duty references.');
                }
            }
            $checked = $this->time($proof['verified_at']);
            $valid = $this->time($proof['expires_at']);
            if ($checked > $issued || $valid <= $issued
                || $valid->getTimestamp() - $checked->getTimestamp() > self::MAX_AGE
                || (! $rollback && $valid->getTimestamp() <= $now)) {
                throw new DomainException('Candidate holder or legacy allowlist evidence is stale.');
            }
            $deadline = min($deadline, $valid);
        }

        return $deadline;
    }

    public static function message(array $manifest): string
    {
        unset($manifest['signature']);

        return "EliteSync legacy admin authorization v1\n".self::json($manifest);
    }

    private static function json(mixed $value): string
    {
        return json_encode(self::canonical($value), JSON_THROW_ON_ERROR | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
    }

    private static function canonical(mixed $value): mixed
    {
        if (! is_array($value)) {
            return $value;
        }
        if (! array_is_list($value)) {
            ksort($value, SORT_STRING);
        }

        return array_map(self::canonical(...), $value);
    }

    private function hasKeys(mixed $value, array $keys): bool
    {
        return is_array($value) && count($value) === count($keys) && ! array_diff($keys, array_keys($value));
    }

    private function decode(mixed $encoded, int $length): string
    {
        $bytes = is_string($encoded) ? base64_decode($encoded, true) : false;
        if ($bytes === false || strlen($bytes) !== $length || base64_encode($bytes) !== $encoded) {
            throw new DomainException('Owner authorization key or signature is invalid.');
        }

        return $bytes;
    }

    private function time(mixed $value): DateTimeImmutable
    {
        $time = is_string($value)
            ? DateTimeImmutable::createFromFormat('!Y-m-d\TH:i:s\Z', $value, new DateTimeZone('UTC')) : false;
        if (! $time || $time->format('Y-m-d\TH:i:s\Z') !== $value) {
            throw new DomainException('Authorization timestamps must be exact UTC seconds.');
        }

        return $time;
    }
}
