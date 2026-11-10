<?php

namespace Tests\Feature\Api\V2;

use App\Domain\PersistenceBoundaryApplicationInterfaceIntegrationContract;
use App\Domain\RuntimeReadinessPersistenceApplicationAdapter;
use App\Domain\SqliteInMemoryLogicalPersistenceAdapter;
use App\Domain\TransportNeutralApplicationRequestResponseContract;
use App\Http\Controllers\Api\V2\RuntimeReadiness\RuntimeReadinessEvaluationController;
use Illuminate\Http\JsonResponse;
use ReflectionClass;
use Tests\TestCase;

final class RuntimeReadinessEvaluationTest extends TestCase
{
    private const ENDPOINT = '/api/v2/runtime-readiness/evaluations';
    private const SENTINEL = 'MUST-NOT-LEAK-RR03-PRIVATE-HTTP-FEATURE';

    public function test_exact_route_and_ip13f_boundaries_are_preserved_and_insecure_transport_stops_dispatch(): void
    {
        $selectedRoute = null;
        $genericRoute = null;
        $v1AliasFound = false;

        foreach ($this->app['router']->getRoutes() as $route) {
            if ($route->uri() === 'api/v2/runtime-readiness/evaluations') {
                $selectedRoute = $route;
            }

            if ($route->uri() === 'api/v2/contracts/application-envelope') {
                $genericRoute = $route;
            }

            if ($route->uri() === 'api/v1/runtime-readiness/evaluations') {
                $v1AliasFound = true;
            }
        }

        self::assertNotNull($selectedRoute);
        self::assertContains('POST', $selectedRoute->methods());
        self::assertContains('secure.transport', $selectedRoute->middleware());
        self::assertNotContains('auth:sanctum', $selectedRoute->gatherMiddleware());
        self::assertNotNull($genericRoute);
        self::assertContains('POST', $genericRoute->methods());
        self::assertFalse($v1AliasFound);

        $constants = (new ReflectionClass(
            TransportNeutralApplicationRequestResponseContract::class,
        ))->getConstants();
        $families = array_filter(
            $constants,
            static fn (string $key): bool => str_starts_with($key, 'FAMILY_'),
            ARRAY_FILTER_USE_KEY,
        );
        self::assertCount(5, $families);
        self::assertNotContains('RUNTIME_READINESS', $families);

        $controllerSource = file_get_contents(app_path(
            'Http/Controllers/Api/V2/RuntimeReadiness/RuntimeReadinessEvaluationController.php',
        ));
        self::assertIsString($controllerSource);
        self::assertSame(1, substr_count($controllerSource, '->evaluateSynthetic('));
        self::assertStringNotContainsString(
            'TransportNeutralApplicationRequestResponseContract',
            $controllerSource,
        );

        config(['security.enforce_https' => true]);
        $graph = $this->graph();
        $this->bindAdapter($graph['adapter']);

        $response = $this->postJson(self::ENDPOINT, $this->requestFor('READY'));

        $response->assertStatus(426);
        self::assertSame(0, $graph['persistence']->count());
        self::assertStringNotContainsString(self::SENTINEL, $response->getContent());
        self::assertArrayNotHasKey('readiness_classification', (array) $response->json());
    }

    public function test_ready_not_ready_and_unknown_remain_domain_only_privacy_minimal_200_results(): void
    {
        foreach (['READY', 'NOT_READY', 'UNKNOWN'] as $classification) {
            $graph = $this->graph();
            $this->bindAdapter($graph['adapter']);
            $request = $this->requestFor($classification);
            $unchanged = $request;
            $materializedProjectionUsable = $classification !== 'UNKNOWN';
            $condition = $classification === 'UNKNOWN'
                ? 'RR03_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED'
                : 'EXACT_PRIVACY_MINIMAL_RR03_PROJECTION_MATERIALIZED';

            $response = $this
                ->withServerVariables(['REMOTE_ADDR' => '192.0.2.10'])
                ->withHeaders([
                    'X-Forwarded-Proto' => 'https',
                    'X-Synthetic-Actor' => 'SYNTHETIC-HEADER-MUST-NOT-MERGE',
                    'User-Agent' => 'SYNTHETIC-USER-AGENT-A',
                ])
                ->postJson(self::ENDPOINT.'?synthetic_query=SYNTHETIC-QUERY-A', $request);

            $response->assertOk()
                ->assertJsonPath('readiness_classification', $classification)
                ->assertJsonPath('materialized_projection_usable', $materializedProjectionUsable)
                ->assertJsonPath('condition', $condition)
                ->assertJsonPath('synthetic_dev_test_only', true);

            $json = $response->json();
            self::assertSame([
                'readiness_classification',
                'reason_categories',
                'materialized_projection_usable',
                'condition',
                'synthetic_dev_test_only',
            ], array_keys($json));
            self::assertIsArray($json['reason_categories']);

            if ($classification === 'UNKNOWN') {
                self::assertSame(['UNKNOWN_PREREQUISITE_SET'], $json['reason_categories']);
            }

            self::assertSame($unchanged, $request);
            self::assertSame(1, $graph['persistence']->count());
            $this->assertPrivacyBoundary($response);

            if ($classification === 'READY') {
                $sameSemanticRequest = $this
                    ->withServerVariables(['REMOTE_ADDR' => '192.0.2.11'])
                    ->withHeaders([
                        'X-Forwarded-Proto' => 'https',
                        'X-Synthetic-Actor' => 'SYNTHETIC-DIFFERENT-HEADER',
                        'User-Agent' => 'SYNTHETIC-USER-AGENT-B',
                    ])
                    ->postJson(
                        self::ENDPOINT.'?synthetic_query=SYNTHETIC-QUERY-B',
                        $request,
                    );

                $sameSemanticRequest->assertOk();
                self::assertSame($json, $sameSemanticRequest->json());
                self::assertSame(1, $graph['persistence']->count());
            }
        }
    }

    public function test_legacy_request_state_shorthand_fails_schema_validation_before_dispatch(): void
    {
        $graph = $this->graph();
        $this->bindAdapter($graph['adapter']);

        foreach (['KNOWN', 'UNKNOWN'] as $legacyState) {
            $request = $this->requestFor('READY');
            $request['prerequisite_set']['state'] = $legacyState;

            $response = $this->postJson(self::ENDPOINT, $request);

            $response->assertStatus(400)
                ->assertJsonPath('error.code', 'INVALID_REQUEST_SCHEMA')
                ->assertJsonPath(
                    'error.message',
                    'Request rejected by the bounded synthetic Runtime Readiness HTTP contract.',
                )
                ->assertJsonPath('synthetic_dev_test_only', true);
            self::assertSame(['error', 'synthetic_dev_test_only'], array_keys($response->json()));
            self::assertStringNotContainsString(self::SENTINEL, $response->getContent());
            self::assertSame(0, $graph['persistence']->count());
        }
    }

    public function test_request_allowlist_marker_and_nested_schema_fail_closed_before_dispatch(): void
    {
        $graph = $this->graph();
        $this->bindAdapter($graph['adapter']);
        $valid = $this->requestFor('READY');

        $missingTopLevel = $valid;
        unset($missingTopLevel['member_evidence']);

        $extraTopLevel = $valid;
        $extraTopLevel['synthetic_extra'] = self::SENTINEL;

        $missingMarker = $valid;
        unset($missingMarker['prerequisite_set']['synthetic_fixture']);

        $wrongMemberMarker = $valid;
        $wrongMemberMarker['member_evidence'][0]['synthetic_fixture'] = 'WRONG';

        $badRevision = $valid;
        $badRevision['member_evidence'][0]['source_evidence']['source_revision']['value'] = '1';

        $badBinding = $valid;
        $badBinding['member_evidence'][0]['required_bindings']['actor'] = null;

        $badExtension = $valid;
        $badExtension['prerequisite_set']['private_fixture_extensions']['raw_fixture'] = 'PRIVATE';

        $notAList = $valid;
        $notAList['member_evidence'] = ['member' => $valid['member_evidence'][0]];

        $cases = [
            [$missingTopLevel, 'INVALID_REQUEST_SCHEMA'],
            [$extraTopLevel, 'INVALID_REQUEST_SCHEMA'],
            [$missingMarker, 'SYNTHETIC_BOUNDARY_REJECTED'],
            [$wrongMemberMarker, 'SYNTHETIC_BOUNDARY_REJECTED'],
            [$badRevision, 'INVALID_REQUEST_SCHEMA'],
            [$badBinding, 'INVALID_REQUEST_SCHEMA'],
            [$badExtension, 'INVALID_REQUEST_SCHEMA'],
            [$notAList, 'INVALID_REQUEST_SCHEMA'],
        ];

        foreach ($cases as [$payload, $code]) {
            $response = $this->postJson(self::ENDPOINT, $payload);

            $response->assertStatus(400)
                ->assertJsonPath('error.code', $code)
                ->assertJsonPath(
                    'error.message',
                    'Request rejected by the bounded synthetic Runtime Readiness HTTP contract.',
                )
                ->assertJsonPath('synthetic_dev_test_only', true);
            self::assertSame(['error', 'synthetic_dev_test_only'], array_keys($response->json()));
            self::assertStringNotContainsString(self::SENTINEL, $response->getContent());
        }

        $malformed = $this->call(
            'POST',
            self::ENDPOINT,
            [],
            [],
            [],
            ['CONTENT_TYPE' => 'application/json'],
            '{"prerequisite_set":',
        );
        $malformed->assertStatus(400)
            ->assertJsonPath('error.code', 'MALFORMED_JSON')
            ->assertJsonPath('synthetic_dev_test_only', true);
        self::assertStringNotContainsString(self::SENTINEL, $malformed->getContent());

        self::assertSame(0, $graph['persistence']->count());
    }

    public function test_storage_and_readback_degradation_preserve_classification_and_hide_internal_causes(): void
    {
        $graph = $this->graph();
        $controller = new RuntimeReadinessEvaluationController($graph['adapter']);
        $method = (new ReflectionClass($controller))->getMethod('successResponse');

        $storageRejected = $this->syntheticAdapterResult(
            'READY',
            false,
            'STORAGE_REJECTED_RETRIEVAL_SKIPPED',
        );
        $storageRejected['storage_disposition'] = 'SYNTHETIC-REJECTED';
        $storageResponse = $method->invoke($controller, $storageRejected);

        self::assertInstanceOf(JsonResponse::class, $storageResponse);
        self::assertSame(200, $storageResponse->getStatusCode());
        self::assertSame('READY', $storageResponse->getData(true)['readiness_classification']);
        self::assertFalse($storageResponse->getData(true)['materialized_projection_usable']);
        self::assertArrayNotHasKey('storage_disposition', $storageResponse->getData(true));

        foreach ([
            'MISSING',
            'STALE',
            'SUPERSEDED',
            'INCOMPARABLE',
            'INVALIDATED',
            'BINDING_MISMATCH',
            'PAYLOAD_MISMATCH',
        ] as $internalCause) {
            $result = $this->syntheticAdapterResult(
                'NOT_READY',
                false,
                'RR03_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED',
            );
            $result['projection_read_disposition'] = $internalCause;
            $result['logical_record_identity'] = self::SENTINEL;

            $response = $method->invoke($controller, $result);
            self::assertInstanceOf(JsonResponse::class, $response);
            self::assertSame(200, $response->getStatusCode());
            $json = $response->getData(true);
            self::assertSame('NOT_READY', $json['readiness_classification']);
            self::assertFalse($json['materialized_projection_usable']);
            self::assertSame(
                'RR03_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED',
                $json['condition'],
            );
            self::assertArrayNotHasKey('projection_read_disposition', $json);
            self::assertArrayNotHasKey('logical_record_identity', $json);
            self::assertStringNotContainsString(self::SENTINEL, $response->getContent());
        }
    }

    public function test_unexpected_application_failure_and_unrecognized_mapping_return_private_500_errors(): void
    {
        $brokenAdapter = (new ReflectionClass(
            RuntimeReadinessPersistenceApplicationAdapter::class,
        ))->newInstanceWithoutConstructor();
        $this->bindAdapter($brokenAdapter);

        $failure = $this->postJson(self::ENDPOINT, $this->requestFor('READY'));
        $failure->assertStatus(500)
            ->assertJsonPath('error.code', 'INTERNAL_APPLICATION_FAILURE')
            ->assertJsonPath('synthetic_dev_test_only', true);
        self::assertSame(['error', 'synthetic_dev_test_only'], array_keys($failure->json()));
        self::assertArrayNotHasKey('readiness_classification', $failure->json());
        self::assertStringNotContainsString(self::SENTINEL, $failure->getContent());

        $graph = $this->graph();
        $controller = new RuntimeReadinessEvaluationController($graph['adapter']);
        $method = (new ReflectionClass($controller))->getMethod('successResponse');
        $unrecognized = $this->syntheticAdapterResult(
            'SYNTHETIC-UNRECOGNIZED',
            true,
            'EXACT_PRIVACY_MINIMAL_RR03_PROJECTION_MATERIALIZED',
        );
        $mappingFailure = $method->invoke($controller, $unrecognized);

        self::assertInstanceOf(JsonResponse::class, $mappingFailure);
        self::assertSame(500, $mappingFailure->getStatusCode());
        self::assertSame(
            'UNRECOGNIZED_TRANSPORT_MAPPING',
            $mappingFailure->getData(true)['error']['code'],
        );
        self::assertArrayNotHasKey(
            'readiness_classification',
            $mappingFailure->getData(true),
        );
        self::assertStringNotContainsString(
            self::SENTINEL,
            $mappingFailure->getContent(),
        );
    }

    /**
     * @return array{
     *     persistence: SqliteInMemoryLogicalPersistenceAdapter,
     *     application: PersistenceBoundaryApplicationInterfaceIntegrationContract,
     *     adapter: RuntimeReadinessPersistenceApplicationAdapter
     * }
     */
    private function graph(): array
    {
        $persistence = new SqliteInMemoryLogicalPersistenceAdapter();
        $application = new PersistenceBoundaryApplicationInterfaceIntegrationContract($persistence);
        $adapter = new RuntimeReadinessPersistenceApplicationAdapter($application);

        return [
            'persistence' => $persistence,
            'application' => $application,
            'adapter' => $adapter,
        ];
    }

    private function bindAdapter(
        RuntimeReadinessPersistenceApplicationAdapter $adapter,
    ): void {
        $this->app->instance(RuntimeReadinessPersistenceApplicationAdapter::class, $adapter);

        foreach ($this->app['router']->getRoutes() as $route) {
            if ($route->uri() === 'api/v2/runtime-readiness/evaluations') {
                $route->flushController();
            }
        }
    }

    /** @return array<string, mixed> */
    private function requestFor(string $classification): array
    {
        $scope = 'SYNTHETIC-RUNTIME-READINESS-PURPOSE';
        $prerequisiteBindings = $this->bindings('SET', $scope);
        $memberBindings = $prerequisiteBindings;
        $memberOutcome = $classification === 'NOT_READY' ? 'UNSATISFIED' : 'SATISFIED';

        return [
            'prerequisite_set' => [
                'synthetic_fixture' => RuntimeReadinessPersistenceApplicationAdapter::SYNTHETIC_FIXTURE_MARKER,
                'state' => $classification === 'UNKNOWN'
                    ? 'UNKNOWN_PREREQUISITE_SET'
                    : 'KNOWN_PREREQUISITE_SET',
                'set_identity' => 'SYNTHETIC-PREREQUISITE-SET',
                'required_member_ids' => ['synthetic-member-a'],
                'protected_use_scope' => $scope,
                'required_bindings' => $prerequisiteBindings,
                'source_evidence' => $this->sourceEvidence(
                    $prerequisiteBindings,
                    'SYNTHETIC-SET-LINEAGE',
                    1,
                ),
                'private_fixture_extensions' => ['raw_fixture' => self::SENTINEL.'-SET'],
            ],
            'member_evidence' => [[
                'synthetic_fixture' => RuntimeReadinessPersistenceApplicationAdapter::SYNTHETIC_FIXTURE_MARKER,
                'member_identity' => 'synthetic-member-a',
                'fact_class' => 'ELIGIBILITY',
                'protected_use_scope' => $scope,
                'required_bindings' => $memberBindings,
                'source_evidence' => $this->sourceEvidence(
                    $memberBindings,
                    'SYNTHETIC-MEMBER-A-LINEAGE',
                    1,
                ),
                'prerequisite_outcome' => $classification === 'UNKNOWN' ? null : $memberOutcome,
                'private_fixture_extensions' => ['raw_fixture' => self::SENTINEL.'-MEMBER'],
            ]],
        ];
    }

    /** @return array<string, mixed> */
    private function bindings(string $suffix, string $purpose): array
    {
        return [
            'authority_owner' => 'SYNTHETIC-AUTHORITY-'.$suffix,
            'authority_scope' => 'SYNTHETIC-SCOPE-'.$suffix,
            'actor' => 'SYNTHETIC-ACTOR',
            'actor_role' => 'SYNTHETIC-ROLE',
            'subject' => 'SYNTHETIC-SUBJECT',
            'participants' => ['SYNTHETIC-PARTICIPANT-A', 'SYNTHETIC-PARTICIPANT-B'],
            'audience' => 'SYNTHETIC-AUDIENCE',
            'purpose' => $purpose,
            'aggregate_context' => 'SYNTHETIC-CONTEXT',
            'lifecycle_identity' => 'SYNTHETIC-LIFECYCLE-'.$suffix,
            'terminal' => false,
        ];
    }

    /**
     * @param array<string, mixed> $bindings
     * @return array<string, mixed>
     */
    private function sourceEvidence(array $bindings, string $lineage, int $value): array
    {
        return [
            'record_kind' => 'SOURCE_EVIDENCE',
            'bindings' => $bindings,
            'source_condition' => 'PRESENT',
            'source_revision' => [
                'authority_owner' => $bindings['authority_owner'],
                'authority_scope' => $bindings['authority_scope'],
                'lineage' => $lineage,
                'aggregate_context' => $bindings['aggregate_context'],
                'value' => $value,
            ],
            'currentness' => true,
            'freshness' => true,
            'authoritative_outcome' => 'COMMITTED',
        ];
    }

    /** @return array<string, mixed> */
    private function syntheticAdapterResult(
        string $classification,
        bool $usable,
        string $condition,
    ): array {
        return [
            'readiness_classification' => $classification,
            'rr03_payload' => ['reason_categories' => []],
            'materialized_projection_usable' => $usable,
            'condition' => $condition,
            'synthetic_dev_test_only' => true,
        ];
    }

    private function assertPrivacyBoundary($response): void
    {
        $content = $response->getContent();

        self::assertStringNotContainsString(self::SENTINEL, $content);
        self::assertStringNotContainsString('SYNTHETIC-HEADER-MUST-NOT-MERGE', $content);
        self::assertStringNotContainsString('SYNTHETIC-QUERY-A', $content);

        foreach ([
            'rr03_payload',
            'logical_record_identity',
            'logical_intent_identity',
            'source_projection_lineage',
            'lifecycle_identity',
            'source_revision',
            'storage_disposition',
            'projection_read_disposition',
            'authoritative_outcome',
            'reconciliation_required',
            'invalidation_required',
            'revalidation_required',
            'permission',
            'permission_token',
            'authentication_authority',
            'source_authority',
            'production_ready',
            'deployable',
            'real_data_authorized',
        ] as $field) {
            self::assertArrayNotHasKey($field, $response->json());
        }
    }
}
