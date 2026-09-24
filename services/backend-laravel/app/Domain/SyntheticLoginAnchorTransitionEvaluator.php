<?php

namespace App\Domain;

/**
 * Pure synthetic/dev-test transition over caller-declared evidence only.
 * This class does not verify a server source or grant authentication or access.
 */
final class SyntheticLoginAnchorTransitionEvaluator
{
    public const INTERACTIVE_LOGIN = 'INTERACTIVE_LOGIN';

    /**
     * @param array<string, mixed>|null $currentAnchor
     * @param array<string, mixed> $event
     * @param array<string, mixed> $context
     * @return array<string, mixed>
     */
    public static function evaluate(?array $currentAnchor, array $event, array $context): array
    {
        if (! self::hasIdentity($context)) {
            return self::result(false, 'INVALID_CONTEXT', null);
        }

        if ($currentAnchor !== null && ! self::validAnchor($currentAnchor, $context)) {
            return self::result(false, 'INVALID_CURRENT_ANCHOR', null);
        }

        if (($event['kind'] ?? null) !== self::INTERACTIVE_LOGIN) {
            return self::result(false, 'NON_INTERACTIVE_EVENT', $currentAnchor);
        }

        if (($event['source_confirmed'] ?? null) !== true) {
            return self::result(false, 'SOURCE_NOT_CONFIRMED', $currentAnchor);
        }

        if (! self::hasIdentity($event)) {
            return self::result(false, 'MISSING_EVENT_IDENTITY', $currentAnchor);
        }

        if ($event['account_id'] !== $context['account_id'] || $event['device_id'] !== $context['device_id']) {
            return self::result(false, 'IDENTITY_MISMATCH', $currentAnchor);
        }

        if (! self::validSequence($event['sequence'] ?? null)) {
            return self::result(false, 'INVALID_SEQUENCE', $currentAnchor);
        }

        if (! self::validTime($event['t0_epoch_seconds'] ?? null)) {
            return self::result(false, 'INVALID_T0', $currentAnchor);
        }

        if ($currentAnchor !== null) {
            if ($event['sequence'] === $currentAnchor['sequence']) {
                return self::result(false, 'REPLAYED_EVENT', $currentAnchor);
            }

            if ($event['sequence'] < $currentAnchor['sequence']) {
                return self::result(false, 'OUT_OF_ORDER_EVENT', $currentAnchor);
            }

            if ($event['t0_epoch_seconds'] < $currentAnchor['t0_epoch_seconds']) {
                return self::result(false, 'T0_MOVED_BACKWARD', $currentAnchor);
            }
        }

        return self::result(true, 'INTERACTIVE_LOGIN_CANDIDATE', [
            'account_id' => $event['account_id'],
            'device_id' => $event['device_id'],
            'sequence' => $event['sequence'],
            't0_epoch_seconds' => $event['t0_epoch_seconds'],
            'source_confirmed' => true,
        ]);
    }

    /** @param array<string, mixed> $value */
    private static function hasIdentity(array $value): bool
    {
        return isset($value['account_id'], $value['device_id'])
            && is_string($value['account_id'])
            && $value['account_id'] !== ''
            && is_string($value['device_id'])
            && $value['device_id'] !== '';
    }

    /**
     * @param array<string, mixed> $anchor
     * @param array<string, mixed> $context
     */
    private static function validAnchor(array $anchor, array $context): bool
    {
        return self::hasIdentity($anchor)
            && $anchor['account_id'] === $context['account_id']
            && $anchor['device_id'] === $context['device_id']
            && ($anchor['source_confirmed'] ?? null) === true
            && self::validSequence($anchor['sequence'] ?? null)
            && self::validTime($anchor['t0_epoch_seconds'] ?? null);
    }

    private static function validSequence(mixed $sequence): bool
    {
        return is_int($sequence) && $sequence > 0;
    }

    private static function validTime(mixed $time): bool
    {
        return is_int($time) && $time >= 0;
    }

    /**
     * @param array<string, mixed>|null $proposedAnchor
     * @return array<string, mixed>
     */
    private static function result(bool $candidate, string $reason, ?array $proposedAnchor): array
    {
        return [
            'record_kind' => 'SYNTHETIC_LOGIN_ANCHOR_TRANSITION_CANDIDATE',
            'can_form_candidate' => $candidate,
            'reason' => $reason,
            'proposed_anchor' => $proposedAnchor,
            'caller_claims_only' => true,
            'server_source_verified' => false,
            'authentication_grant' => false,
            'offline_read_grant' => false,
            'online_read_grant' => false,
            'send_grant' => false,
            'zero_writer' => true,
        ];
    }
}
