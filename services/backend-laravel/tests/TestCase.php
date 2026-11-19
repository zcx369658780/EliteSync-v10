<?php

namespace Tests;

use App\Models\User;
use App\Services\LifestyleDiscoveryService;
use App\Services\TrustedIdentityService;
use Illuminate\Foundation\Testing\TestCase as BaseTestCase;
use Illuminate\Support\Str;

abstract class TestCase extends BaseTestCase
{
    /** Explicit TEST_ONLY credential for cases exercising signed matching business in memory. */
    protected function authorizeTestParticipation(User $user): void
    {
        config(['journey.test_issuer_enabled' => true,
            'journey.test_issuer_key' => config('journey.test_issuer_key') ?: str_repeat('isolated-participation-fixture-', 2)]);
        $user->forceFill(['is_synthetic' => true])->save();
        $identity = app(TrustedIdentityService::class);
        $identity->register((int) $user->id);
        $identity->issue((int) $user->id, (string) Str::uuid(), 1440);
    }

    /** Explicit preparation for tests whose subject is an enrolled weekly participant. */
    protected function completeLifestyleFixture(int $userId): void
    {
        $service = app(LifestyleDiscoveryService::class);
        $revision = $service->read($userId)['revision'];
        foreach ($service->bank()['scenes'] as $scene) {
            $service->command($userId, ['action' => 'answer', 'expected_revision' => $revision++,
                'questionnaire_version' => 'lifestyle_v1', 'request_key' => (string) Str::uuid(),
                'scene_id' => $scene['id'], 'option_id' => $scene['options'][0]['id']]);
        }
    }

    public function createApplication()
    {
        $app = parent::createApplication();
        // Check effective config before RefreshDatabase traits can migrate.
        // A cached config or app-scoped selector must never reach a local DB.
        if (! $app->environment('testing') || $app['config']->get('database.default') !== 'sqlite'
            || $app['config']->get('database.connections.sqlite.driver') !== 'sqlite'
            || $app['config']->get('database.connections.sqlite.database') !== ':memory:'
            || $app['config']->get('database.connections.sqlite.url')) {
            throw new \RuntimeException('Tests require effective testing / sqlite / :memory: with no database URL; no migrations executed.');
        }

        return $app;
    }
}
