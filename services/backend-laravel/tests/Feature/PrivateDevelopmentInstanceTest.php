<?php
namespace Tests\Feature;
use App\Services\LiveConsentService;
use Tests\TestCase;
final class PrivateDevelopmentInstanceTest extends TestCase
{
    public function test_private_local_instance_requires_an_explicit_server_owned_true_qualifier(): void
    {
        config(['restoration.enabled'=>true]);
        $this->app['env']='local';
        $this->app->instance('restoration.private-instance-qualified', static fn()=>true);
        $this->assertTrue(app(LiveConsentService::class)->enabled());
        foreach ([false, 1, 'true', null] as $value) {
            $this->app->instance('restoration.private-instance-qualified', static fn()=>$value);
            $this->assertFalse(app(LiveConsentService::class)->enabled());
        }
    }
    public function test_instance_qualifier_never_enables_production_or_disabled_restoration(): void
    {
        $this->app->instance('restoration.private-instance-qualified', static fn()=>true);
        config(['restoration.enabled'=>true]);$this->app['env']='production';
        $this->assertFalse(app(LiveConsentService::class)->enabled());
        $this->app['env']='local';config(['restoration.enabled'=>false]);
        $this->assertFalse(app(LiveConsentService::class)->enabled());
    }
}
