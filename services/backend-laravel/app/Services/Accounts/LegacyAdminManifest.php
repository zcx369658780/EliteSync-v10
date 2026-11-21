<?php

namespace App\Services\Accounts;

use DomainException;

final class LegacyAdminManifest
{
    public static function read(string $path): array
    {
        if (! is_file($path) || is_link($path) || filesize($path) > 65536
            || (DIRECTORY_SEPARATOR === '/' && (fileperms($path) & 0077) !== 0)) {
            throw new DomainException('Manifest must be a bounded private local JSON file.');
        }
        $raw = @file_get_contents($path, length: 65537);
        if ($raw === false || strlen($raw) > 65536 || ! mb_check_encoding($raw, 'UTF-8')) {
            throw new DomainException('Manifest must be a bounded UTF-8 JSON file.');
        }

        $data = json_decode($raw, true, 16, JSON_THROW_ON_ERROR);
        self::keys($data, ['batch', 'source_system', 'snapshot', 'target', 'approval', 'operator', 'candidates'],
            ['authorization', 'signature']);
        foreach (['batch', 'source_system', 'snapshot', 'target', 'approval', 'operator'] as $key) {
            self::reference($data[$key]);
        }

        $candidates = $data['candidates'];
        if (! is_array($candidates) || ! array_is_list($candidates) || count($candidates) < 1 || count($candidates) > 50) {
            throw new DomainException('Provide 1 to 50 approved candidates.');
        }

        $seen = ['candidate' => [], 'legacy_user_id' => [], 'phone' => []];
        $rows = [];
        foreach ($candidates as $row) {
            self::keys($row, ['candidate', 'legacy_user_id', 'phone', 'status', 'role'], ['name', 'holder_proof']);
            self::reference($row['candidate']);
            if (! is_int($row['legacy_user_id']) || $row['legacy_user_id'] < 1
                || ! is_string($row['phone']) || ! preg_match('/^\+?[1-9][0-9]{6,14}$/D', $row['phone'])
                || $row['status'] !== 'enabled' || $row['role'] !== 'admin') {
                throw new DomainException('Candidate needs a verified login identifier, enabled source status and approved admin role.');
            }
            if (array_key_exists('name', $row) && (! is_string($row['name']) || trim($row['name']) === ''
                || mb_strlen($row['name']) > 80 || preg_match('/\p{C}/u', $row['name']))) {
                throw new DomainException('Invalid optional display name.');
            }
            foreach (array_keys($seen) as $key) {
                if (isset($seen[$key][$row[$key]])) {
                    throw new DomainException('Duplicate candidate, old ID or login identifier.');
                }
                $seen[$key][$row[$key]] = true;
            }
            ksort($row);
            $rows[] = $row;
        }
        usort($rows, fn (array $a, array $b) => strcmp($a['candidate'], $b['candidate']));
        $data['candidates'] = $rows;

        return $data;
    }

    private static function reference(mixed $value): void
    {
        if (! is_string($value) || ! preg_match('/^[a-z][a-z0-9._-]{1,63}$/D', $value)) {
            throw new DomainException('Use short governed references for batch, source, approval, operator and candidate.');
        }
    }

    private static function keys(mixed $data, array $required, array $optional = []): void
    {
        if (! is_array($data) || array_diff($required, array_keys($data))
            || array_diff(array_keys($data), [...$required, ...$optional])) {
            throw new DomainException('Missing or disallowed manifest field.');
        }
    }

    public static function fingerprint(array $manifest): string
    {
        // Operator describes the current invocation. Candidate identity and its approval are immutable.
        unset($manifest['operator']);
        ksort($manifest);

        return hash_hmac('sha256', json_encode($manifest, JSON_THROW_ON_ERROR), config('app.key'));
    }
};
