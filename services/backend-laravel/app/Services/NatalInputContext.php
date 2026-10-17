<?php

namespace App\Services;

use DateTimeImmutable;
use DateTimeZone;
use InvalidArgumentException;
use JsonException;

/**
 * Validates civil birth input without inventing a birth instant or algorithm output.
 * This class does not write canonical profile data or derive algorithm sex from gender.
 */
final class NatalInputContext
{
    public const VERSION = 'v10.0.10-input-1';

    public function normalize(array $input, array $calculationProfile): array
    {
        foreach (['id', 'version'] as $key) {
            if (! is_string($calculationProfile[$key] ?? null) || trim($calculationProfile[$key]) === '') {
                throw new InvalidArgumentException('calculation_profile_'.$key.'_required');
            }
        }

        $date = $input['civil_date'] ?? null;
        if (! is_string($date) || ! preg_match('/\A(\d{4})-(\d{2})-(\d{2})\z/', $date, $parts)
            || ! checkdate((int) $parts[2], (int) $parts[3], (int) $parts[1])) {
            throw new InvalidArgumentException('invalid_civil_date');
        }
        $timezone = $input['timezone'] ?? null;
        // Numeric offsets and ambiguous abbreviations cannot replace an explicit IANA zone.
        if (! is_string($timezone) || ! in_array($timezone, DateTimeZone::listIdentifiers(DateTimeZone::ALL_WITH_BC), true)) {
            throw new InvalidArgumentException('iana_timezone_required');
        }
        $precision = $input['time_precision'] ?? null;
        if (! in_array($precision, ['unknown', 'minute', 'second'], true)) {
            throw new InvalidArgumentException('invalid_time_precision');
        }
        $time = $input['civil_time'] ?? null;
        $normalizedTime = null;
        $fold = $input['fold'] ?? null;
        $offset = $input['utc_offset_seconds'] ?? null;
        if ($fold !== null && (! is_int($fold) || ! in_array($fold, [0, 1], true))) {
            throw new InvalidArgumentException('invalid_fold');
        }
        if ($offset !== null && (! is_int($offset) || abs($offset) > 86400)) {
            throw new InvalidArgumentException('invalid_utc_offset_seconds');
        }
        if ($precision === 'unknown') {
            if ($time !== null || $fold !== null || $offset !== null) {
                throw new InvalidArgumentException('unknown_time_must_not_supply_time_fold_or_offset');
            }
        } else {
            $pattern = $precision === 'minute' ? '/\A([01]\d|2[0-3]):([0-5]\d)\z/' : '/\A([01]\d|2[0-3]):([0-5]\d):([0-5]\d)\z/';
            if (! is_string($time) || ! preg_match($pattern, $time)) {
                throw new InvalidArgumentException('civil_time_precision_mismatch');
            }
            $normalizedTime = $precision === 'minute' ? $time.':00' : $time;
        }

        $latitude = $this->coordinate($input['latitude'] ?? null, 90, 'latitude');
        $longitude = $this->coordinate($input['longitude'] ?? null, 180, 'longitude');
        if (($latitude === null) !== ($longitude === null)) {
            throw new InvalidArgumentException('coordinates_must_be_provided_together');
        }
        $algorithmSex = $input['algorithm_sex'] ?? 'unknown';
        if (! in_array($algorithmSex, ['male', 'female', 'unknown'], true)) {
            throw new InvalidArgumentException('invalid_algorithm_sex');
        }
        $source = $input['time_source'] ?? 'user_provided';
        $locationLabel = $input['location_label'] ?? null;
        if (! is_string($source) || trim($source) === '' || ($locationLabel !== null && ! is_string($locationLabel))) {
            throw new InvalidArgumentException('invalid_input_provenance');
        }

        $resolved = ['utc' => null, 'utc_offset_seconds' => null, 'fold' => null];
        if ($normalizedTime !== null) {
            $resolved = $this->resolveCivil($date.' '.$normalizedTime, new DateTimeZone($timezone), $fold, $offset);
        }
        $context = [
            'context_version' => self::VERSION,
            'civil_date' => $date,
            'civil_time' => $time,
            'normalized_time' => $normalizedTime,
            'time_precision' => $precision,
            'time_source' => $source,
            'timezone' => $timezone,
            'tzdb_version' => timezone_version_get(),
            ...$resolved,
            'coordinate_system' => 'WGS84',
            'latitude' => $latitude,
            'longitude' => $longitude,
            'location_label' => $locationLabel,
            'algorithm_sex' => $algorithmSex,
            'calculation_profile' => $calculationProfile,
        ];
        try {
            $encoded = json_encode($this->canonical($context), JSON_THROW_ON_ERROR | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        } catch (JsonException $exception) {
            throw new InvalidArgumentException('context_not_json_serializable', 0, $exception);
        }
        $context['input_signature'] = hash('sha256', $encoded);

        return $context;
    }

    private function coordinate(mixed $value, int $limit, string $name): ?float
    {
        if ($value === null) {
            return null;
        }
        if ((! is_int($value) && ! is_float($value)) || ! is_finite((float) $value) || abs($value) > $limit) {
            throw new InvalidArgumentException('invalid_wgs84_'.$name);
        }

        return $value == 0 ? 0.0 : (float) $value;
    }

    /** Enumerate possible UTC instants, then round-trip each against the actual TZ rules. */
    private function resolveCivil(string $civil, DateTimeZone $zone, ?int $fold, ?int $offset): array
    {
        $wall = DateTimeImmutable::createFromFormat('!Y-m-d H:i:s', $civil, new DateTimeZone('UTC'));
        if ($wall === false) {
            throw new InvalidArgumentException('invalid_civil_datetime');
        }
        $wallTimestamp = $wall->getTimestamp();
        $transitions = $zone->getTransitions($wallTimestamp - 3 * 86400, $wallTimestamp + 3 * 86400);
        $offsets = [$zone->getOffset($wall)];
        foreach ($transitions ?: [] as $transition) {
            $offsets[] = $transition['offset'];
        }
        $candidates = [];
        foreach (array_unique($offsets) as $candidateOffset) {
            $utcTimestamp = $wallTimestamp - $candidateOffset;
            $instant = (new DateTimeImmutable('@'.$utcTimestamp))->setTimezone($zone);
            if ($instant->format('Y-m-d H:i:s') === $civil && $instant->getOffset() === $candidateOffset) {
                $candidates[$utcTimestamp] = $candidateOffset;
            }
        }
        ksort($candidates, SORT_NUMERIC);
        $timestamps = array_keys($candidates);
        if ($timestamps === []) {
            throw new InvalidArgumentException('civil_time_in_dst_gap');
        }
        $ambiguous = count($timestamps) > 1;
        if ($ambiguous && $fold === null && $offset === null) {
            throw new InvalidArgumentException('ambiguous_civil_time_requires_fold_or_offset');
        }
        $selected = $fold ?? 0;
        if (! $ambiguous && $fold !== null) {
            throw new InvalidArgumentException('fold_only_valid_for_ambiguous_time');
        }
        if ($offset !== null) {
            $matching = array_search($offset, array_values($candidates), true);
            if ($matching === false) {
                throw new InvalidArgumentException('offset_not_valid_for_civil_time');
            }
            if ($fold !== null && $fold !== $matching) {
                throw new InvalidArgumentException('fold_offset_conflict');
            }
            $selected = $matching;
        }
        $timestamp = $timestamps[$selected];

        return [
            'utc' => (new DateTimeImmutable('@'.$timestamp))->setTimezone(new DateTimeZone('UTC'))->format('Y-m-d\TH:i:s\Z'),
            'utc_offset_seconds' => $candidates[$timestamp],
            'fold' => $ambiguous ? $selected : null,
        ];
    }

    private function canonical(mixed $value): mixed
    {
        if (is_array($value)) {
            if (! array_is_list($value)) {
                ksort($value, SORT_STRING);
            }

            return array_map(fn ($item) => $this->canonical($item), $value);
        }
        if (is_object($value) || is_resource($value)) {
            throw new InvalidArgumentException('context_requires_json_scalar_or_array');
        }

        return $value;
    }
}
