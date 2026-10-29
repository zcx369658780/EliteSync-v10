<?php

namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    public function createApplication()
    {
        $app = parent::createApplication();
        if (getenv('ELITESYNC_TASK_DB_QUALIFICATION')) {
            \Tests\Support\PrivateMariaDbQualification::assertApplication($app);

            return $app;
        }
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
