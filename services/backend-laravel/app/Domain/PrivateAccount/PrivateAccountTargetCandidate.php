<?php

namespace App\Domain\PrivateAccount;

final class PrivateAccountTargetCandidate
{
    private const SOURCE_ORDER = [
        'users.private_birth_place',
        'user_astro_profiles.birth_place',
    ];

    /**
     * Normalize caller-labelled synthetic values only. The label is not proof of real provenance.
     *
     * @param array<string, mixed> $input
     * @return array{nickname: array{value: ?string, selected_source: ?string, missing: bool, conflict: ?string}, birth_place: array{value: ?string, selected_source: ?string, missing: bool, conflict: ?string}}
     */
    public static function normalize(array $input): array
    {
        if (($input['synthetic_only'] ?? null) !== true) {
            throw new \InvalidArgumentException('synthetic input required');
        }

        $accountId = $input['account_id'] ?? null;
        if (! is_string($accountId) || trim($accountId) === '') {
            throw new \InvalidArgumentException('synthetic account identity required');
        }
        if (($input['source_order'] ?? null) !== self::SOURCE_ORDER) {
            throw new \InvalidArgumentException('current local source order required');
        }
        $legacyName = self::sourceValue($input['legacy_name'] ?? null, 'users.name', $accountId);
        $nickname = self::sourceValue($input['explicit_nickname'] ?? null, 'explicit_nickname', $accountId);
        $private = self::sourceValue($input['private_birth_place'] ?? null, self::SOURCE_ORDER[0], $accountId);
        $astro = self::sourceValue($input['astro_birth_place'] ?? null, self::SOURCE_ORDER[1], $accountId);
        $birthPlace = $private ?? $astro;

        return [
            'nickname' => [
                'value' => $nickname,
                'selected_source' => $nickname === null ? null : 'explicit_nickname',
                'missing' => $nickname === null,
                'conflict' => $nickname !== null && $legacyName !== null && $nickname !== $legacyName
                    ? 'different_legacy_name'
                    : null,
            ],
            'birth_place' => [
                'value' => $birthPlace,
                'selected_source' => $private !== null ? self::SOURCE_ORDER[0]
                    : ($astro !== null ? self::SOURCE_ORDER[1] : null),
                'missing' => $birthPlace === null,
                'conflict' => $private !== null && $astro !== null && $private !== $astro
                    ? 'different_non_empty_sources'
                    : null,
            ],
        ];
    }

    private static function optionalText(mixed $value): ?string
    {
        if ($value === null) {
            return null;
        }
        if (! is_string($value)) {
            throw new \InvalidArgumentException('synthetic text must be a string or null');
        }

        $trimmed = trim($value);
        return $trimmed === '' ? null : $trimmed;
    }

    /** @param mixed $candidate */
    private static function sourceValue(mixed $candidate, string $source, string $accountId): ?string
    {
        if (! is_array($candidate)
            || ($candidate['source'] ?? null) !== $source
            || ($candidate['account_id'] ?? null) !== $accountId
            || ! array_key_exists('value', $candidate)) {
            throw new \InvalidArgumentException('synthetic source identity mismatch');
        }

        return self::optionalText($candidate['value']);
    }
}
