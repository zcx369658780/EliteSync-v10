<?php
declare(strict_types=1);
/** TEST-ONLY eligibility binding. The final production service is never subclassed. */
final class MainlineConsentService
{
    public static function install(object $app): void {
        $app->instance('v1015.mainline-e2e.instance-qualified', static function (): bool {
            MainlineEnvironment::connect(MainlineEnvironment::$context);
            return true;
        });
    }
}
