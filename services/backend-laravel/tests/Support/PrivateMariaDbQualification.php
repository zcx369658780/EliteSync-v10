<?php
namespace Tests\Support;

/** Keep test callers on the same fail-closed runtime qualification. */
final class PrivateMariaDbQualification
{
    public static function assertConfiguration(array $config, bool $testing): void
    {
        \App\Support\PrivateMariaDbQualification::assertConfiguration($config, $testing);
    }
    public static function assertApplication(\Illuminate\Foundation\Application $app): void
    {
        \App\Support\PrivateMariaDbQualification::assertApplication($app);
    }
}
