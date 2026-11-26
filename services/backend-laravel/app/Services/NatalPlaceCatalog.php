<?php

namespace App\Services;

class NatalPlaceCatalog
{
    public function search(string $query, string $region): ?array
    {
        $path = config('natal.place_catalog_path');
        if (! is_string($path) || $path === '' || ! is_file($path)) {
            return null;
        }

        $json = @file_get_contents($path, false, null, 0, 4 * 1024 * 1024 + 1);
        if ($json === false || strlen($json) > 4 * 1024 * 1024) {
            return null;
        }

        $catalog = json_decode($json, true);
        if (($catalog['schema_version'] ?? null) !== 1
            || ($catalog['source'] ?? null) !== 'OpenStreetMap'
            || ($catalog['coordinate_system'] ?? null) !== 'WGS84'
            || ! is_array($catalog['regions'] ?? null)) {
            return null;
        }

        $query = $this->normalize($query);
        $region = $this->normalize($region);
        if (mb_strlen($query) < 2 || $region === '') {
            return [];
        }

        foreach ($catalog['regions'] as $city => $entry) {
            $aliases = $entry['aliases'] ?? [];
            if (! is_string($city) || ! is_array($aliases)
                || ! in_array($region, array_map($this->normalize(...), [$city, ...$aliases]), true)) {
                continue;
            }

            $places = $entry['places'] ?? [];

            return is_array($places) ? $this->matches($query, $places) : null;
        }

        return [];
    }

    private function matches(string $query, array $places): array
    {
        $matches = [];
        foreach ($places as $place) {
            if (! is_array($place)) {
                continue;
            }
            $label = $place['label'] ?? null;
            $lat = $place['lat'] ?? null;
            $lng = $place['lng'] ?? null;
            $pointKind = $place['point_kind'] ?? null;
            if (! is_string($label) || trim($label) === ''
                || (! is_float($lat) && ! is_int($lat)) || ! is_finite((float) $lat) || abs($lat) > 90
                || (! is_float($lng) && ! is_int($lng)) || ! is_finite((float) $lng) || abs($lng) > 180
                || ! in_array($pointKind, ['campus', 'landmark', 'district', 'city'], true)) {
                continue;
            }

            $primary = $this->normalize($label);
            $aliases = $place['aliases'] ?? [];
            $aliases = is_array($aliases) ? array_map($this->normalize(...), $aliases) : [];
            $score = match (true) {
                $query === $primary => 0,
                in_array($query, $aliases, true) => 1,
                str_starts_with($primary, $query) => 2,
                count(array_filter($aliases, fn (string $alias) => str_starts_with($alias, $query))) > 0 => 3,
                default => null,
            };
            if ($score === null) {
                continue;
            }

            $matches[] = [
                'score' => $score,
                'place' => [
                    'label' => $label,
                    'address' => $place['address'] ?? '',
                    'province' => $place['province'] ?? '',
                    'city' => $place['city'] ?? '',
                    'area' => $place['area'] ?? '',
                    'point_kind' => $pointKind,
                    'lat' => $lat,
                    'lng' => $lng,
                ],
            ];
        }

        usort($matches, static fn (array $a, array $b) => [$a['score'], $a['place']['label']] <=> [$b['score'], $b['place']['label']]);

        return array_column(array_slice($matches, 0, 10), 'place');
    }

    private function normalize(mixed $value): string
    {
        return is_string($value)
            ? preg_replace('/[^\p{L}\p{N}]+/u', '', mb_strtolower($value)) ?? ''
            : '';
    }
}
