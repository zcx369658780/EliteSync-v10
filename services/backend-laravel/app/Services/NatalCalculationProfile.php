<?php

namespace App\Services;

use InvalidArgumentException;

final class NatalCalculationProfile
{
    public function settings(array $requested): array
    {
        $choices = [
            'zodiac_mode' => ['tropical', 'sidereal'],
            'house_system' => ['placidus', 'whole', 'alcabitius'],
            'aspect_mode' => ['major', 'standard', 'extended'],
            'orb_preset' => ['standard', 'tight', 'wide'],
            'point_set' => ['core', 'extended', 'full'],
        ];
        if (array_diff(array_keys($requested), [...array_keys($choices), 'true_solar_time', 'target_year'])) {
            throw new InvalidArgumentException('unsupported_natal_setting');
        }
        $settings = [];
        foreach ($choices as $key => $allowed) {
            $value = $requested[$key] ?? $allowed[0];
            if (! in_array($value, $allowed, true)) {
                throw new InvalidArgumentException('unsupported_'.$key);
            }
            $settings[$key] = $value;
        }
        $solar = $requested['true_solar_time'] ?? false;
        $target = $requested['target_year'] ?? null;
        if (! is_bool($solar) || ($target !== null && (! is_int($target) || $target < 1900 || $target > 2100))) {
            throw new InvalidArgumentException('invalid_solar_or_target_year_setting');
        }

        return [...$settings, 'true_solar_time' => $solar, 'target_year' => $target];
    }

    public function make(array $settings): array
    {
        $profile = json_decode(file_get_contents(resource_path('natal/calculation-profile-registry.json')), true, 512, JSON_THROW_ON_ERROR);
        $paths = ['composer.lock', 'resources/natal/calculation-profile-registry.json',
            'app/Services/NatalInputContext.php', 'app/Services/NatalBaziCalculator.php',
            'app/Services/NatalBaziTimeScale.php', 'app/Services/NatalBaziLuckProjection.php', 'tools/natal/bazi_time.py',
            'app/Services/NatalCalculationProfile.php', 'app/Services/NatalCalculationService.php',
            'app/Services/NatalRuntimeIdentity.php', 'tools/natal/runtime_identity.py', 'config/natal.php',
            'tools/natal/western.py', 'tools/natal/time_context.py', 'tools/natal/lunar_points.py',
            'tools/natal/ziwei.mjs', 'tools/ziwei/iztro-runner/package-lock.json'];
        $paths[] = 'resources/natal/ziwei-upstream-corrections.json';
        foreach ($paths as $path) {
            $profile['source_hashes'][$path] = hash_file('sha256', base_path($path));
        }
        // Include dependency/data manifests when delivered; absence is explicit and
        // changes the signature when a manifest is subsequently installed.
        foreach (['tools/natal/requirements.lock', 'tools/natal/requirements.txt',
            'tools/natal/requirements.windows-cp311.lock', 'resources/natal/dependency-manifest.json',
            'tools/natal/sbom.json', 'tools/natal/SBOM.json'] as $path) {
            $profile['source_hashes'][$path] = is_file(base_path($path))
                ? hash_file('sha256', base_path($path)) : null;
        }
        $profile['runtime_identity'] = app(NatalRuntimeIdentity::class)->make();
        $profile['settings'] = $settings;

        return $profile;
    }
}
