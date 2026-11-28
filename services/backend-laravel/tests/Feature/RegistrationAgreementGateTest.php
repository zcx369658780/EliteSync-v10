<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

final class RegistrationAgreementGateTest extends TestCase
{
    use RefreshDatabase;

    public function test_unverified_agreement_blocks_registration_even_if_the_client_claims_acceptance(): void
    {
        $phone = '19900118001';
        $this->postJson('/api/v1/auth/register', [
            'phone' => $phone,
            'password' => 'FictionalExample9',
            'agreement_accepted' => true,
            'agreement_version' => 'unverified',
        ])->assertForbidden()
            ->assertJsonPath('code', 'REGISTRATION_AGREEMENT_UNAVAILABLE')
            ->assertJsonMissingPath('access_token')
            ->assertJsonMissingPath('refresh_token');

        $this->assertDatabaseMissing('users', ['phone' => $phone]);
    }
}
