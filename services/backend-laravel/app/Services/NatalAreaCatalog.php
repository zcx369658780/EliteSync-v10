<?php

namespace App\Services;

class NatalAreaCatalog
{
    public function city(string $name): ?array
    {
        $path = config('natal.area_catalog_path');
        if (! is_string($path) || $path === '' || ! is_file($path)) {
            return null;
        }

        $raw = @file_get_contents($path, false, null, 0, 4 * 1024 * 1024 + 1);
        if ($raw === false || strlen($raw) > 4 * 1024 * 1024) {
            return null;
        }

        $data = json_decode($raw, true);
        if (($data['schema_version'] ?? null) !== 1 || ($data['source'] ?? null) !== 'GeoNames'
            || ($data['coordinate_system'] ?? null) !== 'WGS84' || ! is_array($data['cities'] ?? null)) {
            return null;
        }

        $matches = [];
        foreach ($data['cities'] as $key => $city) {
            if (! is_array($city) || ! is_string($city['province'] ?? null) || ! $this->hasCoordinates($city)) {
                continue;
            }

            $label = $city['name'] ?? $key;
            if (! is_string($label) || $label === '') {
                continue;
            }
            $city['name'] = $label;
            $aliases = $this->aliases($label, $city['aliases'] ?? []);
            $provinceAliases = $this->aliases($city['province'], $city['province_aliases'] ?? []);
            $matched = $this->matches($name, $aliases);
            foreach ($provinceAliases as $province) {
                $matched = $matched || $this->matches($name, array_map(fn (string $alias) => $province.$alias, $aliases));
            }
            if ($matched) {
                $matches[] = $city;
            }
        }

        return count($matches) === 1 ? $matches[0] : null;
    }

    public function includes(array $city, array $hit): bool
    {
        return $this->matches($hit['city'] ?? null, $this->aliases($city['name'], $city['aliases'] ?? []))
            && (! isset($hit['province']) || $hit['province'] === ''
                || $this->matches($hit['province'], $this->aliases($city['province'], $city['province_aliases'] ?? [])));
    }

    public function representative(array $city, mixed $district): array
    {
        $matches = [];
        $districts = $city['districts'] ?? [];
        foreach (is_array($districts) ? $districts : [] as $key => $record) {
            if (! is_array($record) || ! $this->hasCoordinates($record)) {
                continue;
            }
            $label = $record['name'] ?? $key;
            if (is_string($label) && $this->matches($district, $this->aliases($label, $record['aliases'] ?? []))) {
                $matches[] = $record + ['name' => $label];
            }
        }
        $county = count($matches) === 1 ? $matches[0] : null;
        $point = $county ?? $city;

        return [
            'label' => $point['name'],
            'address' => '',
            'province' => $city['province'],
            'city' => $city['name'],
            'area' => $county['name'] ?? '',
            'point_kind' => $county === null ? 'city' : 'district',
            'lat' => $point['lat'],
            'lng' => $point['lng'],
            'source' => 'GeoNames',
            'approximate' => true,
        ];
    }

    private function aliases(string $label, mixed $aliases): array
    {
        return [$label, ...array_filter(is_array($aliases) ? $aliases : [], 'is_string')];
    }

    private function matches(mixed $name, array $aliases): bool
    {
        if (! is_string($name) || ($key = $this->normalize($name)) === '') {
            return false;
        }

        return in_array($key, array_map($this->normalize(...), $aliases), true);
    }

    private function normalize(string $value): string
    {
        return preg_replace('/[^\p{L}\p{N}]+/u', '', mb_strtolower($value)) ?? '';
    }

    private function hasCoordinates(array $entry): bool
    {
        $lat = $entry['lat'] ?? null;
        $lng = $entry['lng'] ?? null;

        return (is_float($lat) || is_int($lat)) && is_finite((float) $lat) && abs($lat) <= 90
            && (is_float($lng) || is_int($lng)) && is_finite((float) $lng) && abs($lng) <= 180;
    }
}
