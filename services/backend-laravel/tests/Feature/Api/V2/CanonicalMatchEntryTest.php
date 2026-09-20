<?php

namespace Tests\Feature\Api\V2;

use App\Domain\CanonicalMatchPersistenceApplicationAdapter;
use App\Domain\CommonAuthorityEvidenceContract;
use App\Domain\PersistenceBoundaryApplicationInterfaceIntegrationContract;
use App\Domain\SqliteInMemoryLogicalPersistenceAdapter;
use App\Domain\TransportNeutralApplicationRequestResponseContract;
use App\Http\Controllers\Api\V2\CanonicalMatch\CanonicalMatchEntryController;
use Illuminate\Http\JsonResponse;
use ReflectionClass;
use Tests\TestCase;

final class CanonicalMatchEntryTest extends TestCase
{
    private const EVALUATION_ENDPOINT = '/api/v2/canonical-match/evaluations';

    private const INVALIDATION_ENDPOINT = '/api/v2/canonical-match/invalidations';

    private const SENTINEL = 'MUST-NOT-LEAK-CANONICAL-MATCH-HTTP-FEATURE';

    public function test_exact_routes_transport_and_non_participating_boundaries_are_preserved(): void
    {
        $evaluationRoute = null;
        $invalidationRoute = null;
        $genericRoute = null;
        $runtimeReadinessRoute = null;
        $v1Aliases = [];

        foreach ($this->app['router']->getRoutes() as $route) {
            $uri = $route->uri();

            if ($uri === 'api/v2/canonical-match/evaluations') {
                $evaluationRoute = $route;
            }

            if ($uri === 'api/v2/canonical-match/invalidations') {
                $invalidationRoute = $route;
            }

            if ($uri === 'api/v2/contracts/application-envelope') {
                $genericRoute = $route;
            }

            if ($uri === 'api/v2/runtime-readiness/evaluations') {
                $runtimeReadinessRoute = $route;
            }

            if (in_array($uri, [
                'api/v1/canonical-match/evaluations',
                'api/v1/canonical-match/invalidations',
            ], true)) {
                $v1Aliases[] = $uri;
            }
        }

        foreach ([$evaluationRoute, $invalidationRoute] as $route) {
            self::assertNotNull($route);
            self::assertContains('POST', $route->methods());
            self::assertContains('secure.transport', $route->middleware());
            self::assertNotContains('auth:sanctum', $route->gatherMiddleware());
        }

        self::assertNotNull($genericRoute);
        self::assertContains('POST', $genericRoute->methods());
        self::assertNotNull($runtimeReadinessRoute);
        self::assertContains('POST', $runtimeReadinessRoute->methods());
        self::assertSame([], $v1Aliases);

        $constants = (new ReflectionClass(
            TransportNeutralApplicationRequestResponseContract::class,
        ))->getConstants();
        $families = array_filter(
            $constants,
            static fn (string $key): bool => str_starts_with($key, 'FAMILY_'),
            ARRAY_FILTER_USE_KEY,
        );
        self::assertCount(5, $families);
        self::assertNotContains('CANONICAL_MATCH', $families);

        $source = file_get_contents(app_path(
            'Http/Controllers/Api/V2/CanonicalMatch/CanonicalMatchEntryController.php',
        ));
        self::assertIsString($source);
        self::assertSame(1, substr_count($source, '->evaluateSynthetic('));
        self::assertSame(1, substr_count($source, '->invalidateSynthetic('));

        foreach ([
            'CanonicalMatchProposalDecisionEvaluator',
            'InMemoryLogicalPersistenceRepositoryContract',
            'SqliteInMemoryLogicalPersistenceAdapter',
            'PersistenceBoundaryApplicationInterfaceIntegrationContract',
            'TransportNeutralApplicationRequestResponseContract',
        ] as $prohibitedDependency) {
            self::assertStringNotContainsString($prohibitedDependency, $source);
        }

        config(['security.enforce_https' => true]);
        $graph = $this->graph();
        $this->bindAdapter($graph['adapter']);

        $response = $this->postJson(self::EVALUATION_ENDPOINT, $this->request());

        $response->assertStatus(426);
        self::assertSame(0, $graph['persistence']->count());
        self::assertStringNotContainsString(self::SENTINEL, $response->getContent());
        self::assertArrayNotHasKey('match_classification', (array) $response->json());
    }

    public function test_ordinary_classifications_and_purpose_mismatch_are_privacy_minimal_200_results(): void
    {
        $cases = [
            ['PENDING', [], 'PENDING'],
            ['MUTUALLY_ACCEPTED', [
                'decisions' => [
                    'synthetic-member-a' => 'ACCEPTED',
                    'synthetic-member-b' => 'ACCEPTED',
                ],
            ], 'MUTUALLY_ACCEPTED'],
            ['DECLINED', [
                'decisions' => [
                    'synthetic-member-a' => 'DECLINED',
                    'synthetic-member-b' => 'PENDING',
                ],
            ], 'DECLINED'],
            ['WITHDRAWN', [
                'decisions' => [
                    'synthetic-member-a' => 'WITHDRAWN',
                    'synthetic-member-b' => 'PENDING',
                ],
            ], 'WITHDRAWN'],
            ['EXPIRED', ['lifecycle' => 'EXPIRED'], 'EXPIRED'],
            ['UNKNOWN', [
                'decisions' => [
                    'synthetic-member-a' => 'DECLINED',
                    'synthetic-member-b' => 'WITHDRAWN',
                ],
            ], 'UNKNOWN'],
        ];

        foreach ($cases as [$label, $options, $classification]) {
            $graph = $this->graph();
            $this->bindAdapter($graph['adapter']);
            $request = $this->request($options);
            $before = $request;
            $response = $this->postJson(self::EVALUATION_ENDPOINT, $request);

            $response->assertOk()
                ->assertJsonPath('match_classification', $classification)
                ->assertJsonPath(
                    'condition',
                    'EXACT_PRIVACY_MINIMAL_CANONICAL_MATCH_PROJECTION_MATERIALIZED',
                )
                ->assertJsonPath('materialized_projection_usable', true)
                ->assertJsonPath('synthetic_dev_test_only', true);
            self::assertSame($before, $request, $label);
            self::assertSame(1, $graph['persistence']->count(), $label);
            $this->assertPrivacyBoundary($response);
        }

        $graph = $this->graph();
        $this->bindAdapter($graph['adapter']);
        $mismatch = $this->request();
        $mismatch['proposal']['required_bindings']['purpose'] = 'SYNTHETIC_OTHER_PURPOSE';
        $mismatch['proposal']['source_evidence']['bindings']['purpose'] = 'SYNTHETIC_OTHER_PURPOSE';
        $before = $mismatch;

        $response = $this->postJson(self::EVALUATION_ENDPOINT, $mismatch);

        $response->assertOk()
            ->assertJsonPath('match_classification', 'UNKNOWN')
            ->assertJsonPath(
                'reason_categories',
                ['PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE'],
            )
            ->assertJsonPath('materialized_projection_usable', false)
            ->assertJsonPath(
                'condition',
                'CANONICAL_MATCH_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED',
            );
        self::assertSame($before, $mismatch);
        self::assertStringNotContainsString('SYNTHETIC_OTHER_PURPOSE', $response->getContent());
        $this->assertPrivacyBoundary($response);
    }

    public function test_invalidation_duplicate_incomparable_and_storage_rejection_remain_http_200(): void
    {
        $graph = $this->graph();
        $this->bindAdapter($graph['adapter']);
        $invalidation = $this->request([
            'decisions' => [
                'synthetic-member-a' => 'ACCEPTED',
                'synthetic-member-b' => 'ACCEPTED',
            ],
        ]);
        $invalidation['invalidation_request'] = [
            'dependency_identity' => 'synthetic-slot-a',
            'relation' => 'REVOCATION',
        ];

        $invalidated = $this->postJson(self::INVALIDATION_ENDPOINT, $invalidation);
        $invalidated->assertOk()
            ->assertJsonPath('match_classification', 'UNKNOWN')
            ->assertJsonPath('reason_categories', ['DEPENDENCY_INVALIDATED'])
            ->assertJsonPath('materialized_projection_usable', false)
            ->assertJsonPath(
                'condition',
                'CANONICAL_MATCH_DEPENDENCY_INVALIDATED_PROJECTION_MATERIALIZED_UNUSABLE',
            );
        $this->assertPrivacyBoundary($invalidated);

        $graph = $this->graph();
        $this->bindAdapter($graph['adapter']);
        $request = $this->request();
        $first = $this->postJson(self::EVALUATION_ENDPOINT, $request);
        $duplicate = $this->postJson(self::EVALUATION_ENDPOINT, $request);
        $first->assertOk();
        $duplicate->assertOk();
        self::assertSame($first->json(), $duplicate->json());
        self::assertSame(1, $graph['persistence']->count());

        $changed = $this->request(['slot_b_revision' => 2]);
        $incomparable = $this->postJson(self::EVALUATION_ENDPOINT, $changed);
        $incomparable->assertOk()
            ->assertJsonPath(
                'condition',
                'EXACT_PRIVACY_MINIMAL_CANONICAL_MATCH_PROJECTION_MATERIALIZED',
            )
            ->assertJsonPath('materialized_projection_usable', true);
        self::assertSame(2, $graph['persistence']->count());
        $this->assertPrivacyBoundary($incomparable);

        $graph = $this->graph();
        $this->bindAdapter($graph['adapter']);
        $terminal = $this->request([
            'decisions' => [
                'synthetic-member-a' => 'ACCEPTED',
                'synthetic-member-b' => 'ACCEPTED',
            ],
        ]);
        $this->postJson(self::EVALUATION_ENDPOINT, $terminal)->assertOk();
        $reopen = $this->postJson(self::EVALUATION_ENDPOINT, $this->request());
        $reopen->assertOk()
            ->assertJsonPath('match_classification', 'PENDING')
            ->assertJsonPath('materialized_projection_usable', false)
            ->assertJsonPath('condition', 'STORAGE_REJECTED_RETRIEVAL_SKIPPED');
        $this->assertPrivacyBoundary($reopen);
    }

    public function test_raw_schema_marker_and_adapter_input_rejections_are_private_400_results(): void
    {
        $graph = $this->graph();
        $this->bindAdapter($graph['adapter']);
        $valid = $this->request();

        $missingTopLevel = $valid;
        unset($missingTopLevel['decision_slot_evidence']);

        $extraTopLevel = $valid;
        $extraTopLevel['unexpected'] = self::SENTINEL;

        $missingMarker = $valid;
        unset($missingMarker['synthetic_fixture']);

        $wrongMarker = $valid;
        $wrongMarker['synthetic_fixture'] = 'WRONG';

        $badProposal = $valid;
        $badProposal['proposal']['unexpected'] = true;

        $badList = $valid;
        $badList['participation_evidence'] = ['member' => $valid['participation_evidence'][0]];

        $badItem = $valid;
        unset($badItem['participation_evidence'][0]['source_evidence']);

        $badSlot = $valid;
        $badSlot['decision_slot_evidence'][0]['decision'] = 'INVALID';

        $badBinding = $valid;
        $badBinding['proposal']['required_bindings']['actor'] = null;

        $badEvidence = $valid;
        $badEvidence['proposal']['source_evidence']['unexpected'] = self::SENTINEL;

        $badRevision = $valid;
        $badRevision['proposal']['source_evidence']['source_revision']['value'] = '1';

        $mismatchedRevision = $valid;
        $mismatchedRevision['proposal']['source_evidence']['source_revision']['authority_owner'] =
            'OTHER_OWNER';

        $cases = [
            [$missingTopLevel, 'INVALID_REQUEST_SCHEMA'],
            [$extraTopLevel, 'INVALID_REQUEST_SCHEMA'],
            [$missingMarker, 'SYNTHETIC_BOUNDARY_REJECTED'],
            [$wrongMarker, 'SYNTHETIC_BOUNDARY_REJECTED'],
            [$badProposal, 'INVALID_REQUEST_SCHEMA'],
            [$badList, 'INVALID_REQUEST_SCHEMA'],
            [$badItem, 'INVALID_REQUEST_SCHEMA'],
            [$badSlot, 'INVALID_REQUEST_SCHEMA'],
            [$badBinding, 'INVALID_REQUEST_SCHEMA'],
            [$badEvidence, 'INVALID_REQUEST_SCHEMA'],
            [$badRevision, 'INVALID_REQUEST_SCHEMA'],
            [$mismatchedRevision, 'INVALID_REQUEST_SCHEMA'],
        ];

        foreach ($cases as [$payload, $code]) {
            $response = $this->postJson(self::EVALUATION_ENDPOINT, $payload);
            $this->assertPrivateError($response, 400, $code);
        }

        $badInvalidation = $valid;
        $badInvalidation['invalidation_request'] = [
            'dependency_identity' => 'synthetic-slot-a',
            'relation' => 'INVALID',
        ];
        $this->assertPrivateError(
            $this->postJson(self::INVALIDATION_ENDPOINT, $badInvalidation),
            400,
            'INVALID_REQUEST_SCHEMA',
        );

        $malformed = $this->call(
            'POST',
            self::EVALUATION_ENDPOINT,
            [],
            [],
            [],
            ['CONTENT_TYPE' => 'application/json'],
            '{"proposal":',
        );
        $this->assertPrivateError($malformed, 400, 'MALFORMED_JSON');

        $nonObject = $this->call(
            'POST',
            self::EVALUATION_ENDPOINT,
            [],
            [],
            [],
            ['CONTENT_TYPE' => 'application/json'],
            '[]',
        );
        $this->assertPrivateError($nonObject, 400, 'INVALID_REQUEST_SCHEMA');

        $collision = $this->request();
        $collision['proposal']['proposal_identity'] = 'synthetic-member-a';
        $this->assertPrivateError(
            $this->postJson(self::EVALUATION_ENDPOINT, $collision),
            400,
            'ADAPTER_INPUT_REJECTED',
        );

        self::assertSame(0, $graph['persistence']->count());
    }

    public function test_headers_query_ip_and_user_agent_do_not_enter_semantic_input(): void
    {
        $graph = $this->graph();
        $this->bindAdapter($graph['adapter']);
        $request = $this->request();
        $before = $request;

        $first = $this
            ->withServerVariables(['REMOTE_ADDR' => '192.0.2.20'])
            ->withHeaders([
                'X-Forwarded-Proto' => 'https',
                'X-Synthetic-Actor' => 'HEADER-A',
                'User-Agent' => 'SYNTHETIC-UA-A',
            ])
            ->postJson(self::EVALUATION_ENDPOINT.'?semantic=SYNTHETIC-QUERY-A', $request);

        $second = $this
            ->withServerVariables(['REMOTE_ADDR' => '192.0.2.21'])
            ->withHeaders([
                'X-Forwarded-Proto' => 'https',
                'X-Synthetic-Actor' => 'HEADER-B',
                'User-Agent' => 'SYNTHETIC-UA-B',
            ])
            ->postJson(self::EVALUATION_ENDPOINT.'?semantic=SYNTHETIC-QUERY-B', $request);

        $first->assertOk();
        $second->assertOk();
        self::assertSame($first->json(), $second->json());
        self::assertSame($before, $request);
        self::assertSame(1, $graph['persistence']->count());

        foreach ([
            'HEADER-A',
            'HEADER-B',
            'SYNTHETIC-UA-A',
            'SYNTHETIC-UA-B',
            'SYNTHETIC-QUERY-A',
            'SYNTHETIC-QUERY-B',
            '192.0.2.20',
            '192.0.2.21',
        ] as $metadata) {
            self::assertStringNotContainsString($metadata, $first->getContent());
            self::assertStringNotContainsString($metadata, $second->getContent());
        }

        $this->assertPrivacyBoundary($first);
        $this->assertPrivacyBoundary($second);
    }

    public function test_unexpected_failure_and_unrecognized_mappings_return_private_500_results(): void
    {
        $brokenAdapter = (new ReflectionClass(
            CanonicalMatchPersistenceApplicationAdapter::class,
        ))->newInstanceWithoutConstructor();
        $this->bindAdapter($brokenAdapter);

        $failure = $this->postJson(self::EVALUATION_ENDPOINT, $this->request());
        $this->assertPrivateError($failure, 500, 'INTERNAL_APPLICATION_FAILURE');

        $graph = $this->graph();
        $controller = new CanonicalMatchEntryController($graph['adapter']);
        $method = (new ReflectionClass($controller))->getMethod('successResponse');
        $valid = $graph['adapter']->evaluateSynthetic($this->request());

        $wrongOperation = $valid;
        $wrongOperation['operation'] = 'INVALIDATE';

        $wrongClassification = $valid;
        $wrongClassification['match_classification'] = 'UNRECOGNIZED';

        $wrongReason = $valid;
        $wrongReason['reason_categories'] = ['UNRECOGNIZED'];

        $wrongCondition = $valid;
        $wrongCondition['condition'] = 'UNRECOGNIZED';

        $inconsistentUsability = $valid;
        $inconsistentUsability['materialized_projection_usable'] = false;

        $evaluationWithInvalidationCondition = $valid;
        $evaluationWithInvalidationCondition['condition'] =
            'CANONICAL_MATCH_DEPENDENCY_INVALIDATED_PROJECTION_MATERIALIZED_UNUSABLE';
        $evaluationWithInvalidationCondition['materialized_projection_usable'] = false;

        $missingKey = $valid;
        unset($missingKey['record_kind']);

        $authorityEscalation = $valid;
        $authorityEscalation['permission'] = true;

        foreach ([
            [$wrongOperation, 'EVALUATE'],
            [$wrongClassification, 'EVALUATE'],
            [$wrongReason, 'EVALUATE'],
            [$wrongCondition, 'EVALUATE'],
            [$inconsistentUsability, 'EVALUATE'],
            [$evaluationWithInvalidationCondition, 'EVALUATE'],
            [$missingKey, 'EVALUATE'],
            [$authorityEscalation, 'EVALUATE'],
            [[...$valid, 'operation' => 'INVALIDATE'], 'INVALIDATE'],
        ] as [$result, $operation]) {
            $response = $method->invoke($controller, $result, $operation);
            self::assertInstanceOf(JsonResponse::class, $response);
            self::assertSame(500, $response->getStatusCode());
            self::assertSame(
                'UNRECOGNIZED_TRANSPORT_MAPPING',
                $response->getData(true)['error']['code'],
            );
            self::assertSame(
                ['error', 'synthetic_dev_test_only'],
                array_keys($response->getData(true)),
            );
            self::assertStringNotContainsString(self::SENTINEL, $response->getContent());
        }
    }

    /**
     * @return array{
     *     persistence: SqliteInMemoryLogicalPersistenceAdapter,
     *     application: PersistenceBoundaryApplicationInterfaceIntegrationContract,
     *     adapter: CanonicalMatchPersistenceApplicationAdapter
     * }
     */
    private function graph(): array
    {
        $persistence = new SqliteInMemoryLogicalPersistenceAdapter();
        $application = new PersistenceBoundaryApplicationInterfaceIntegrationContract($persistence);
        $adapter = new CanonicalMatchPersistenceApplicationAdapter($application);

        return [
            'persistence' => $persistence,
            'application' => $application,
            'adapter' => $adapter,
        ];
    }

    private function bindAdapter(CanonicalMatchPersistenceApplicationAdapter $adapter): void
    {
        $this->app->instance(CanonicalMatchPersistenceApplicationAdapter::class, $adapter);

        foreach ($this->app['router']->getRoutes() as $route) {
            if (in_array($route->uri(), [
                'api/v2/canonical-match/evaluations',
                'api/v2/canonical-match/invalidations',
            ], true)) {
                $route->flushController();
            }
        }
    }

    /** @param array<string, mixed> $options @return array<string, mixed> */
    private function request(array $options = []): array
    {
        $proposalIdentity = 'synthetic-proposal';
        $scope = 'SYNTHETIC_MATCH_REVIEW';
        $participants = ['synthetic-member-b', 'synthetic-member-a'];
        $lifecycle = $options['lifecycle'] ?? 'PENDING';
        $proposalBindings = $this->bindings(
            'PROPOSAL_SOURCE',
            'PROPOSAL_SCOPE',
            'synthetic-subject',
            $participants,
            $scope,
            $proposalIdentity,
            $lifecycle !== 'PENDING',
        );
        $proposal = [
            'proposal_identity' => $proposalIdentity,
            'participants' => $participants,
            'protected_use_scope' => $scope,
            'lifecycle_state' => $lifecycle,
            'at_most_one_unresolved_precondition' => $options['precondition'] ?? true,
            'required_bindings' => $proposalBindings,
            'source_evidence' => $this->evidence($proposalBindings, 'proposal-lineage', 1),
        ];
        $participation = [];
        $slots = [];
        $decisions = $options['decisions'] ?? [
            'synthetic-member-a' => 'PENDING',
            'synthetic-member-b' => 'PENDING',
        ];

        foreach ($participants as $participant) {
            $participationBindings = $this->bindings(
                'PARTICIPATION_SOURCE',
                'PARTICIPATION_SCOPE',
                $participant,
                [$participant],
                $scope,
                $participant,
                false,
            );
            $participation[] = [
                'participant_identity' => $participant,
                'state' => 'ENROLLED',
                'required_bindings' => $participationBindings,
                'source_evidence' => $this->evidence(
                    $participationBindings,
                    'participation-lineage-'.$participant,
                    1,
                ),
            ];
            $suffix = str_ends_with($participant, '-a') ? 'a' : 'b';
            $slotBindings = $this->bindings(
                'SLOT_SOURCE',
                'SLOT_SCOPE',
                $participant,
                [$participant],
                $scope,
                $proposalIdentity,
                false,
            );
            $slots[] = [
                'slot_identity' => 'synthetic-slot-'.$suffix,
                'proposal_identity' => $proposalIdentity,
                'participant_identity' => $participant,
                'protected_use_scope' => $scope,
                'decision' => $decisions[$participant],
                'required_bindings' => $slotBindings,
                'source_evidence' => $this->evidence(
                    $slotBindings,
                    'slot-lineage-'.$suffix,
                    $suffix === 'b' ? ($options['slot_b_revision'] ?? 1) : 1,
                ),
            ];
        }

        return [
            'synthetic_fixture' => CanonicalMatchPersistenceApplicationAdapter::SYNTHETIC_FIXTURE_MARKER,
            'proposal' => $proposal,
            'participation_evidence' => $participation,
            'decision_slot_evidence' => $slots,
        ];
    }

    /** @return array<string, mixed> */
    private function bindings(
        string $owner,
        string $scope,
        string $subject,
        array $participants,
        string $purpose,
        string $context,
        bool $terminal,
    ): array {
        return [
            'authority_owner' => $owner,
            'authority_scope' => $scope,
            'actor' => self::SENTINEL,
            'actor_role' => 'SYNTHETIC_REVIEWER',
            'subject' => $subject,
            'participants' => $participants,
            'audience' => 'SYNTHETIC_AUDIENCE',
            'purpose' => $purpose,
            'aggregate_context' => $context,
            'lifecycle_identity' => 'source-lifecycle-'.$context,
            'terminal' => $terminal,
        ];
    }

    /** @param array<string, mixed> $bindings @return array<string, mixed> */
    private function evidence(array $bindings, string $lineage, int $revision): array
    {
        return CommonAuthorityEvidenceContract::evidence(
            $bindings,
            CommonAuthorityEvidenceContract::CONDITION_PRESENT,
            CommonAuthorityEvidenceContract::sourceRevision(
                $bindings['authority_owner'],
                $bindings['authority_scope'],
                $lineage,
                $bindings['aggregate_context'],
                $revision,
            ),
            true,
            true,
            CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN,
        );
    }

    private function assertPrivateError($response, int $status, string $code): void
    {
        $response->assertStatus($status)
            ->assertJsonPath('error.code', $code)
            ->assertJsonPath(
                'error.message',
                $status === 400
                    ? 'Request rejected by the bounded synthetic Canonical Match HTTP contract.'
                    : 'The bounded synthetic Canonical Match HTTP contract failed closed.',
            )
            ->assertJsonPath('synthetic_dev_test_only', true);
        self::assertSame(['error', 'synthetic_dev_test_only'], array_keys($response->json()));
        self::assertStringNotContainsString(self::SENTINEL, $response->getContent());
        self::assertArrayNotHasKey('match_classification', $response->json());
    }

    private function assertPrivacyBoundary($response): void
    {
        self::assertSame([
            'match_classification',
            'reason_categories',
            'materialized_projection_usable',
            'condition',
            'synthetic_dev_test_only',
        ], array_keys($response->json()));

        foreach ([
            'match_payload',
            'proposal_identity',
            'participant_identity',
            'slot_identity',
            'dependency_identity',
            'logical_record_identity',
            'logical_intent_identity',
            'lifecycle_identity',
            'source_projection_lineage',
            'derived_correlation_revision',
            'storage_disposition',
            'projection_read_disposition',
            'binding_classification',
            'authoritative_outcome',
            'source_evidence',
            'required_bindings',
            'operation',
            'source_authority',
            'match_authority',
            'permission',
            'bearer_capability',
        ] as $field) {
            self::assertArrayNotHasKey($field, $response->json());
        }

        self::assertStringNotContainsString(self::SENTINEL, $response->getContent());
    }
}

