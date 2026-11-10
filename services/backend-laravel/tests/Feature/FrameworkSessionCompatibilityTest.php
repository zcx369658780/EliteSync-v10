<?php

namespace Tests\Feature;

use Tests\TestCase;

class FrameworkSessionCompatibilityTest extends TestCase
{
    public function test_php_serialized_fields_and_configured_cookie_name_are_preserved_in_array_store(): void
    {
        // Laravel13 upgrade guide: changing an existing session to json logs users out.
        // https://laravel.com/framework/docs/13.x/upgrade#session-serialization-configuration
        $this->assertSame('php', config('session.serialization'));
        $cookie = config('session.cookie');

        $session = $this->app->make('session')->driver('array');
        $id = str_repeat('a', 40);
        $payload = ['account_id' => 17, 'confirmed' => false, 'reference' => '0017'];
        $session->getHandler()->write($id, serialize($payload));
        $session->setId($id);
        $session->start();

        $this->assertSame($cookie, $session->getName());
        $this->assertSame(17, $session->get('account_id'));
        $this->assertFalse($session->get('confirmed'));
        $this->assertSame('0017', $session->get('reference'));
    }
}
