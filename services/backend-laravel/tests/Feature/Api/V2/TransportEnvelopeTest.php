<?php

namespace Tests\Feature\Api\V2;

use App\Domain\CommonAuthorityEvidenceContract;
use App\Domain\InMemoryLogicalPersistenceRepositoryContract;
use App\Domain\PersistenceBoundaryApplicationInterfaceIntegrationContract;
use App\Domain\SqliteInMemoryLogicalPersistenceAdapter;
use App\Domain\TransportNeutralApplicationRequestResponseContract;
use ReflectionClass;
use Tests\TestCase;

final class TransportEnvelopeTest extends TestCase
{
    private const ENDPOINT = '/api/v2/contracts/application-envelope';

    public function test_exact_v2_route_uses_secure_transport_and_body_only_pass_through(): void
    {
        $selectedRoute = null;
        $v1AliasFound = false;

        foreach ($this->app['router']->getRoutes() as $route) {
            if ($route->uri() === 'api/v2/contracts/application-envelope') {
                $selectedRoute = $route;
            }

            if ($route->uri() === 'api/v1/contracts/application-envelope') {
                $v1AliasFound = true;
            }
        }

        self::assertNotNull($selectedRoute);
        self::assertContains('POST', $selectedRoute->methods());
        self::assertContains('secure.transport', $selectedRoute->middleware());
        self::assertNotContains('auth:sanctum', $selectedRoute->gatherMiddleware());
        self::assertFalse($v1AliasFound);

        config(['security.enforce_https' => true]);
        $adapter = new SqliteInMemoryLogicalPersistenceAdapter();
        $contract = $this->contract($adapter);
        $this->bindContractInstance($contract);
        $request = $this->mutationRequest(
            'SYNTHETIC-HTTP-BODY-ONLY',
            $this->record('SYNTHETIC-HTTP-BODY-ONLY'),
        );

        $this->postJson(self::ENDPOINT, $request)->assertStatus(426);
        self::assertSame(0, $adapter->count());

        $first = $this
            ->withServerVariables(['REMOTE_ADDR' => '192.0.2.10'])
            ->withHeaders([
                'X-Forwarded-Proto' => 'https',
                'X-Synthetic-Actor' => 'SYNTHETIC-HEADER-MUST-NOT-MERGE',
                'User-Agent' => 'SYNTHETIC-USER-AGENT-A',
            ])
            ->postJson(self::ENDPOINT.'?synthetic_query=SYNTHETIC-QUERY-A', $request);
        $second = $this
            ->withServerVariables(['REMOTE_ADDR' => '192.0.2.11'])
            ->withHeaders([
                'X-Forwarded-Proto' => 'https',
                'X-Synthetic-Actor' => 'SYNTHETIC-DIFFERENT-HEADER',
                'User-Agent' => 'SYNTHETIC-USER-AGENT-B',
            ])
            ->postJson(self::ENDPOINT.'?synthetic_query=SYNTHETIC-QUERY-B', $request);

        $first->assertOk()
            ->assertJsonPath('transport_disposition', TransportNeutralApplicationRequestResponseContract::DELIVERED_TO_APPLICATION)
            ->assertJsonPath('request_identity', 'SYNTHETIC-HTTP-BODY-ONLY')
            ->assertJsonPath('authentication_authority', false)
            ->assertJsonPath('permission', false)
            ->assertJsonPath('protected_action_executed', false);
        $second->assertOk();
        self::assertSame($first->json(), $second->json());
        self::assertSame(1, $adapter->count());
        self::assertStringNotContainsString('SYNTHETIC-HEADER-MUST-NOT-MERGE', $first->getContent());
        self::assertStringNotContainsString('SYNTHETIC-QUERY-A', $first->getContent());
        self::assertStringNotContainsString('SYNTHETIC-USER-AGENT-A', $first->getContent());

        $this->postJson('/api/v1/contracts/application-envelope', $request)->assertNotFound();
    }

    public function test_expected_envelope_failures_use_direct_400_responses_not_framework_exception_semantics(): void
    {
        $cases = [
            'malformed envelope' => [
                [
                    'request_identity' => 'SYNTHETIC-MALFORMED',
                    'family' => TransportNeutralApplicationRequestResponseContract::FAMILY_MUTATION_SUBMISSION,
                ],
                TransportNeutralApplicationRequestResponseContract::REQUEST_REJECTED,
                'MALFORMED_REQUEST_ENVELOPE',
            ],
            'unknown top-level field' => [
                [
                    'request_identity' => 'SYNTHETIC-EXTRA',
                    'family' => TransportNeutralApplicationRequestResponseContract::FAMILY_MUTATION_SUBMISSION,
                    'semantic_payload' => ['record' => $this->record('SYNTHETIC-EXTRA')],
                    'synthetic_extra' => 'SYNTHETIC-REJECT',
                ],
                TransportNeutralApplicationRequestResponseContract::REQUEST_REJECTED,
                'UNKNOWN_TOP_LEVEL_FIELD',
            ],
            'malformed family payload' => [
                [
                    'request_identity' => 'SYNTHETIC-BAD-FAMILY-PAYLOAD',
                    'family' => TransportNeutralApplicationRequestResponseContract::FAMILY_PROJECTION_RETRIEVAL,
                    'semantic_payload' => ['record' => $this->record('SYNTHETIC-BAD-FAMILY-PAYLOAD')],
                ],
                TransportNeutralApplicationRequestResponseContract::REQUEST_REJECTED,
                'MALFORMED_FAMILY_PAYLOAD',
            ],
            'unsupported family' => [
                [
                    'request_identity' => 'SYNTHETIC-UNSUPPORTED',
                    'family' => 'SYNTHETIC-UNSUPPORTED-FAMILY',
                    'semantic_payload' => ['synthetic' => 'SYNTHETIC-VALUE'],
                ],
                TransportNeutralApplicationRequestResponseContract::UNKNOWN,
                'UNSUPPORTED_FAMILY',
            ],
        ];

        foreach ($cases as $label => [$request, $disposition, $condition]) {
            $response = $this->postJson(self::ENDPOINT, $request);

            $response->assertStatus(400)
                ->assertJsonPath('transport_disposition', $disposition)
                ->assertJsonPath('bounded_error_condition', $condition)
                ->assertJsonPath('dispatch_count', 0)
                ->assertJsonPath('source_authority', false)
                ->assertJsonPath('authentication_authority', false);
            $json = $response->json();
            self::assertArrayNotHasKey('success', $json, $label);
            self::assertArrayNotHasKey('data', $json, $label);
            self::assertNotContains($response->getStatusCode(), [401, 403, 422], $label);
        }
    }

    public function test_process_local_request_correlation_is_idempotent_and_changed_payload_maps_to_409(): void
    {
        $adapter = new SqliteInMemoryLogicalPersistenceAdapter();
        $contract = $this->contract($adapter);
        $this->bindContractInstance($contract);
        $request = $this->mutationRequest(
            'SYNTHETIC-HTTP-CORRELATION',
            $this->record('SYNTHETIC-HTTP-CORRELATION'),
        );

        $first = $this->postJson(self::ENDPOINT, $request);
        $duplicate = $this->postJson(self::ENDPOINT, $request);
        $changed = $request;
        $changed['semantic_payload']['record']['logical_intent']['semantic_input']['synthetic_action'] = 'SYNTHETIC-CHANGED-ACTION';
        $conflict = $this->postJson(self::ENDPOINT, $changed);

        $first->assertOk()->assertJsonPath('dispatch_count', 1);
        $duplicate->assertOk()->assertJsonPath('dispatch_count', 1);
        self::assertSame($first->json(), $duplicate->json());
        $conflict->assertStatus(409)
            ->assertJsonPath('transport_disposition', TransportNeutralApplicationRequestResponseContract::REQUEST_REJECTED)
            ->assertJsonPath('bounded_error_condition', 'REQUEST_IDENTITY_PAYLOAD_CONFLICT')
            ->assertJsonPath('dispatch_count', 0)
            ->assertJsonPath('request_correlation_compatible', false)
            ->assertJsonPath('source_domain_outcome', null);
        self::assertSame(1, $adapter->count());
    }

    public function test_delivered_domain_conditions_remain_http_200_and_non_authoritative(): void
    {
        foreach ([
            CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN => false,
            CommonAuthorityEvidenceContract::OUTCOME_REJECTED => true,
        ] as $outcome => $sourceCarried) {
            $this->bindContract();
            $response = $this->postJson(self::ENDPOINT, $this->mutationRequest(
                'SYNTHETIC-HTTP-OUTCOME-'.$outcome,
                $this->record('SYNTHETIC-HTTP-OUTCOME-'.$outcome, $outcome, $sourceCarried),
            ));

            $response->assertOk()
                ->assertJsonPath('transport_disposition', TransportNeutralApplicationRequestResponseContract::DELIVERED_TO_APPLICATION)
                ->assertJsonPath('source_domain_outcome', $outcome)
                ->assertJsonPath('transport_disposition_is_domain_outcome', false);
            $this->assertMandatoryNonAuthority($response->json());
            self::assertStringNotContainsString('MUST-NOT-LEAK-SYNTHETIC-PRIVATE', $response->getContent());
        }

        $this->bindContract();
        $missing = $this->postJson(self::ENDPOINT, $this->projectionRequest('SYNTHETIC-HTTP-MISSING'));
        $missing->assertOk()
            ->assertJsonPath('bounded_error_condition', InMemoryLogicalPersistenceRepositoryContract::MISSING)
            ->assertJsonPath('application_semantic_result.resolution', InMemoryLogicalPersistenceRepositoryContract::MISSING);

        foreach ([
            CommonAuthorityEvidenceContract::CONDITION_STALE => InMemoryLogicalPersistenceRepositoryContract::STALE,
            CommonAuthorityEvidenceContract::CONDITION_SUPERSEDED => InMemoryLogicalPersistenceRepositoryContract::SUPERSEDED,
        ] as $sourceCondition => $resolution) {
            $this->bindContract();
            $record = $this->record('SYNTHETIC-HTTP-'.$sourceCondition, condition: $sourceCondition);
            $this->postJson(self::ENDPOINT, $this->mutationRequest(
                'SYNTHETIC-HTTP-STORE-'.$sourceCondition,
                $record,
            ))->assertOk();
            $this->postJson(self::ENDPOINT, $this->projectionRequest('SYNTHETIC-HTTP-PROJECT-'.$sourceCondition))
                ->assertOk()
                ->assertJsonPath('bounded_error_condition', $resolution)
                ->assertJsonPath('application_semantic_result.resolution', $resolution);
        }

        $this->bindContract();
        $invalidatedRecord = $this->record('SYNTHETIC-HTTP-INVALIDATED');
        $this->postJson(self::ENDPOINT, $this->mutationRequest(
            'SYNTHETIC-HTTP-INVALIDATED-STORE',
            $invalidatedRecord,
        ))->assertOk();
        $this->postJson(self::ENDPOINT, [
            'request_identity' => 'SYNTHETIC-HTTP-INVALIDATED-OBSERVE',
            'family' => TransportNeutralApplicationRequestResponseContract::FAMILY_INVALIDATION_OBSERVATION,
            'semantic_payload' => [
                'logical_record_identity' => $invalidatedRecord['logical_record_identity'],
                'relation' => CommonAuthorityEvidenceContract::INVALIDATION_REVOCATION,
            ],
        ])->assertOk()
            ->assertJsonPath('bounded_error_condition', InMemoryLogicalPersistenceRepositoryContract::INVALIDATED)
            ->assertJsonPath('application_semantic_result.lifecycle_reset', false)
            ->assertJsonPath('application_semantic_result.reopened', false);

        $this->bindContract();
        $revalidationRecord = $this->record('SYNTHETIC-HTTP-REVALIDATION');
        $this->postJson(self::ENDPOINT, $this->mutationRequest(
            'SYNTHETIC-HTTP-REVALIDATION-STORE',
            $revalidationRecord,
        ))->assertOk();
        $this->postJson(self::ENDPOINT, $this->revalidationRequest(
            'SYNTHETIC-HTTP-GRANTED',
            $revalidationRecord,
            $revalidationRecord['bindings'],
        ))->assertOk()
            ->assertJsonPath('application_semantic_result.classification', PersistenceBoundaryApplicationInterfaceIntegrationContract::GRANTED)
            ->assertJsonPath('application_semantic_result.descriptive_only', true)
            ->assertJsonPath('application_semantic_result.execution_must_revalidate', true)
            ->assertJsonPath('protected_action_executed', false)
            ->assertJsonPath('bearer_capability', false);

        $wrongBindings = $revalidationRecord['bindings'];
        $wrongBindings['actor_role'] = 'SYNTHETIC-WRONG-ROLE';
        $this->postJson(self::ENDPOINT, $this->revalidationRequest(
            'SYNTHETIC-HTTP-DENIED',
            $revalidationRecord,
            $wrongBindings,
        ))->assertOk()
            ->assertJsonPath('application_semantic_result.classification', PersistenceBoundaryApplicationInterfaceIntegrationContract::DENIED)
            ->assertJsonPath('bounded_error_condition', 'REVALIDATION_DENIED');
    }

    public function test_dispatch_rejection_and_unrecognized_mapping_fail_closed_to_500(): void
    {
        $brokenApplication = (new ReflectionClass(
            PersistenceBoundaryApplicationInterfaceIntegrationContract::class,
        ))->newInstanceWithoutConstructor();
        $brokenContract = new TransportNeutralApplicationRequestResponseContract($brokenApplication);
        $this->bindContractInstance($brokenContract);

        $dispatchFailure = $this->postJson(self::ENDPOINT, $this->mutationRequest(
            'SYNTHETIC-HTTP-DISPATCH-FAILURE',
            $this->record('SYNTHETIC-HTTP-DISPATCH-FAILURE'),
        ));
        $dispatchFailure->assertStatus(500)
            ->assertJsonPath('transport_disposition', TransportNeutralApplicationRequestResponseContract::REQUEST_REJECTED)
            ->assertJsonPath('bounded_error_condition', 'APPLICATION_DISPATCH_REJECTED')
            ->assertJsonPath('source_domain_outcome', null)
            ->assertJsonPath('source_authority', false);

        $contract = $this->contract();
        $this->bindContractInstance($contract);
        $request = $this->mutationRequest(
            'SYNTHETIC-HTTP-UNKNOWN-MAPPING',
            $this->record('SYNTHETIC-HTTP-UNKNOWN-MAPPING'),
        );
        $this->postJson(self::ENDPOINT, $request)->assertOk();

        $reflection = new ReflectionClass($contract);
        $receiptsProperty = $reflection->getProperty('requestReceipts');
        $receipts = $receiptsProperty->getValue($contract);
        $receipts['SYNTHETIC-HTTP-UNKNOWN-MAPPING']['response']['transport_disposition'] = 'SYNTHETIC-UNRECOGNIZED';
        $receipts['SYNTHETIC-HTTP-UNKNOWN-MAPPING']['response']['bounded_error_condition'] = 'SYNTHETIC-UNRECOGNIZED';
        $receiptsProperty->setValue($contract, $receipts);

        $unknownMapping = $this->postJson(self::ENDPOINT, $request);
        $unknownMapping->assertStatus(500)
            ->assertJsonPath('transport_disposition', 'SYNTHETIC-UNRECOGNIZED')
            ->assertJsonPath('bounded_error_condition', 'SYNTHETIC-UNRECOGNIZED')
            ->assertJsonPath('source_authority', false);
        self::assertArrayNotHasKey('success', $unknownMapping->json());
        self::assertArrayNotHasKey('data', $unknownMapping->json());
    }

    public function test_v1_source_slice_and_non_authority_boundaries_remain_unchanged(): void
    {
        $source = file_get_contents(base_path('routes/api.php'));
        self::assertIsString($source);
        $v1Start = strpos($source, "Route::prefix('v1')");
        self::assertNotFalse($v1Start);
        $v1Slice = str_replace("\r\n", "\n", substr($source, $v1Start));

        self::assertSame(
            '986308bc4a5d4978986ca55642753982ffb9a8979af4656623f72d187f680e13',
            hash('sha256', $v1Slice),
        );
        self::assertStringNotContainsString('/contracts/application-envelope', $v1Slice);
        self::assertSame(1, substr_count(
            $source,
            "Route::post('/contracts/application-envelope', TransportEnvelopeController::class);",
        ));
        self::assertStringNotContainsString('auth:sanctum', substr(
            $source,
            strpos($source, "Route::prefix('v2')"),
            $v1Start - strpos($source, "Route::prefix('v2')"),
        ));
    }

    private function bindContract(): TransportNeutralApplicationRequestResponseContract
    {
        $contract = $this->contract();

        return $this->bindContractInstance($contract);
    }

    private function bindContractInstance(
        TransportNeutralApplicationRequestResponseContract $contract,
    ): TransportNeutralApplicationRequestResponseContract {
        $this->app->instance(TransportNeutralApplicationRequestResponseContract::class, $contract);

        foreach ($this->app['router']->getRoutes() as $route) {
            if ($route->uri() === 'api/v2/contracts/application-envelope') {
                $route->flushController();
            }
        }

        return $contract;
    }

    private function contract(
        ?SqliteInMemoryLogicalPersistenceAdapter $adapter = null,
    ): TransportNeutralApplicationRequestResponseContract {
        $adapter ??= new SqliteInMemoryLogicalPersistenceAdapter();

        return new TransportNeutralApplicationRequestResponseContract(
            new PersistenceBoundaryApplicationInterfaceIntegrationContract($adapter),
        );
    }

    /** @param array<string, mixed> $record @return array<string, mixed> */
    private function mutationRequest(string $requestIdentity, array $record): array
    {
        return [
            'request_identity' => $requestIdentity,
            'family' => TransportNeutralApplicationRequestResponseContract::FAMILY_MUTATION_SUBMISSION,
            'semantic_payload' => ['record' => $record],
        ];
    }

    /** @return array<string, mixed> */
    private function projectionRequest(string $requestIdentity): array
    {
        return [
            'request_identity' => $requestIdentity,
            'family' => TransportNeutralApplicationRequestResponseContract::FAMILY_PROJECTION_RETRIEVAL,
            'semantic_payload' => [
                'query' => $this->query(),
                'request_bindings' => $this->projectionBindings(),
            ],
        ];
    }

    /**
     * @param array<string, mixed> $record
     * @param array<string, mixed> $requiredBindings
     * @return array<string, mixed>
     */
    private function revalidationRequest(
        string $requestIdentity,
        array $record,
        array $requiredBindings,
    ): array {
        return [
            'request_identity' => $requestIdentity,
            'family' => TransportNeutralApplicationRequestResponseContract::FAMILY_PROTECTED_REVALIDATION,
            'semantic_payload' => [
                'query' => $this->query(),
                'required_bindings' => $requiredBindings,
                'source_evidence' => CommonAuthorityEvidenceContract::evidence(
                    $record['bindings'],
                    $record['source_condition'],
                    $record['source_revision'],
                    $record['currentness'],
                    $record['freshness'],
                    $record['authoritative_outcome'],
                ),
            ],
        ];
    }

    /** @return array<string, mixed> */
    private function record(
        string $identity,
        string $outcome = CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN,
        bool $sourceCarried = false,
        string $condition = CommonAuthorityEvidenceContract::CONDITION_PRESENT,
    ): array {
        return [
            'logical_record_identity' => $identity,
            'record_family' => 'SYNTHETIC-HTTP-TRANSPORT-FAMILY',
            'bindings' => $this->bindings(),
            'source_revision' => CommonAuthorityEvidenceContract::sourceRevision(
                'SYNTHETIC-AUTHORITY',
                'SYNTHETIC-SCOPE',
                'SYNTHETIC-LINEAGE',
                'SYNTHETIC-CONTEXT',
                1,
            ),
            'source_condition' => $condition,
            'currentness' => true,
            'freshness' => true,
            'logical_intent' => CommonAuthorityEvidenceContract::bindIntent(
                'SYNTHETIC-INTENT-'.$identity,
                [
                    'synthetic_action' => 'SYNTHETIC-ACTION',
                    'synthetic_target' => 'SYNTHETIC-TARGET',
                    'audience' => 'SYNTHETIC-AUDIENCE',
                    'purpose' => 'SYNTHETIC-PURPOSE',
                    'expected_source_revision_relation' => CommonAuthorityEvidenceContract::REVISION_EQUAL,
                ],
            ),
            'authoritative_outcome' => $outcome,
            'authoritative_outcome_metadata' => $sourceCarried
                ? [
                    'outcome_reference' => 'SYNTHETIC-SOURCE-OUTCOME-'.$identity,
                    'source_carried' => true,
                ]
                : null,
            'correction_metadata' => null,
            'projection_metadata' => [
                'projection_identity' => 'SYNTHETIC-PROJECTION-'.$identity,
                'represented_source_revision_value' => 1,
                'lag_classification' => 'CURRENT',
                'projection_currentness' => true,
            ],
            'transport_observation' => 'ACKNOWLEDGED',
            'private_fixture_extensions' => [
                'synthetic_private_note' => 'MUST-NOT-LEAK-SYNTHETIC-PRIVATE',
            ],
        ];
    }

    /** @return array<string, mixed> */
    private function bindings(): array
    {
        return [
            'authority_owner' => 'SYNTHETIC-AUTHORITY',
            'authority_scope' => 'SYNTHETIC-SCOPE',
            'actor' => 'SYNTHETIC-ACTOR',
            'actor_role' => 'SYNTHETIC-ROLE',
            'subject' => 'SYNTHETIC-SUBJECT',
            'participants' => ['SYNTHETIC-PARTICIPANT-A', 'SYNTHETIC-PARTICIPANT-B'],
            'audience' => 'SYNTHETIC-AUDIENCE',
            'purpose' => 'SYNTHETIC-PURPOSE',
            'aggregate_context' => 'SYNTHETIC-CONTEXT',
            'lifecycle_identity' => 'SYNTHETIC-LIFECYCLE',
            'terminal' => false,
        ];
    }

    /** @return array<string, mixed> */
    private function query(): array
    {
        return [
            'record_family' => 'SYNTHETIC-HTTP-TRANSPORT-FAMILY',
            'authority_owner' => 'SYNTHETIC-AUTHORITY',
            'authority_scope' => 'SYNTHETIC-SCOPE',
            'aggregate_context' => 'SYNTHETIC-CONTEXT',
            'lineage' => 'SYNTHETIC-LINEAGE',
        ];
    }

    /** @return array<string, mixed> */
    private function projectionBindings(): array
    {
        return [
            'viewer' => 'SYNTHETIC-VIEWER',
            'subject' => 'SYNTHETIC-SUBJECT',
            'participants' => ['SYNTHETIC-PARTICIPANT-A', 'SYNTHETIC-PARTICIPANT-B'],
            'audience' => 'SYNTHETIC-AUDIENCE',
            'purpose' => 'SYNTHETIC-PURPOSE',
            'aggregate_context' => 'SYNTHETIC-CONTEXT',
        ];
    }

    /** @param array<string, mixed> $response */
    private function assertMandatoryNonAuthority(array $response): void
    {
        foreach ([
            'source_authority',
            'domain_writer_authority',
            'authoritative_mutation_success',
            'permission',
            'permission_token',
            'bearer_capability',
            'protected_action_executed',
            'transport_execution_authority',
            'http_semantics',
            'controller_authority',
            'route_authority',
            'authentication_authority',
            'production_ready',
            'deployable',
            'real_data_authorized',
            'readiness_authority',
            'match_authority',
            'connection_authority',
            'consent_authority',
            'conversation_authority',
            'relationship_authority',
            'home_action_authority',
            'notification_delivery_authority',
            'launch_authority',
        ] as $field) {
            self::assertArrayHasKey($field, $response);
            self::assertFalse($response[$field]);
        }
    }
}
