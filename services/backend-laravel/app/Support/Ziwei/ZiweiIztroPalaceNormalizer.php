<?php

namespace App\Support\Ziwei;

class ZiweiIztroPalaceNormalizer
{
    /**
     * @return array<string,string>
     */
    public static function palaceAliases(): array
    {
        return [
            '仆役' => '交友',
            '仆役宫' => '交友宫',
        ];
    }

    /**
     * @return array<int,string>
     */
    public static function strictMainStars(): array
    {
        return [
            '紫微',
            '天机',
            '太阳',
            '武曲',
            '天同',
            '廉贞',
            '天府',
            '太阴',
            '贪狼',
            '巨门',
            '天相',
            '天梁',
            '七杀',
            '破军',
        ];
    }

    public static function normalizePalaceName(string $name): string
    {
        $name = trim($name);

        return self::palaceAliases()[$name] ?? $name;
    }

    /**
     * @param array<int,mixed> $stars
     * @return array<int,string>
     */
    public static function filterStrictMainStars(array $stars): array
    {
        $allowed = array_flip(self::strictMainStars());
        $filtered = [];

        foreach ($stars as $star) {
            $name = self::extractStarName($star);

            if ($name !== null && isset($allowed[$name])) {
                $filtered[] = $name;
            }
        }

        return array_values(array_unique($filtered));
    }

    /**
     * @param array<string,mixed> $palace
     * @return array<string,mixed>
     */
    public static function normalizePalace(array $palace): array
    {
        $mainStars = self::filterStrictMainStars((array) ($palace['majorStars'] ?? $palace['main_stars'] ?? []));
        $palaceName = self::normalizePalaceName((string) ($palace['name'] ?? $palace['palace_name'] ?? ''));

        return [
            'palace_name' => $palaceName,
            'source_palace_name' => (string) ($palace['name'] ?? $palace['palace_name'] ?? ''),
            'branch' => (string) ($palace['earthlyBranch'] ?? $palace['branch'] ?? ''),
            'main_stars' => $mainStars,
            'empty_main_star_status' => $mainStars === []
                ? 'no_14_main_star_in_strict_subset'
                : 'none',
            'diagnostic_auxiliary_stars' => (array) ($palace['minorStars'] ?? $palace['auxiliary_stars'] ?? []),
            'diagnostic_four_transformations' => (array) ($palace['four_transformations'] ?? []),
            'diagnostic_flying_star_capabilities' => (array) ($palace['flying_star_capabilities'] ?? []),
        ];
    }

    private static function extractStarName(mixed $star): ?string
    {
        if (is_string($star)) {
            $name = trim($star);

            return $name === '' ? null : $name;
        }

        if (is_array($star)) {
            $name = $star['name'] ?? $star['star'] ?? null;

            return is_string($name) && trim($name) !== '' ? trim($name) : null;
        }

        return null;
    }
}
