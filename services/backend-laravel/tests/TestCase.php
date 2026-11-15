<?php

namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    /** Explicit preparation for tests whose subject is an enrolled weekly participant. */
    protected function completeLifestyleFixture(int $userId): void
    {
        $service = app(\App\Services\LifestyleDiscoveryService::class);
        $revision = $service->read($userId)['revision'];
        foreach ($service->bank()['scenes'] as $scene) {
            $service->command($userId, ['action' => 'answer', 'expected_revision' => $revision++,
                'questionnaire_version' => 'lifestyle_v1', 'request_key' => (string) \Illuminate\Support\Str::uuid(),
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
