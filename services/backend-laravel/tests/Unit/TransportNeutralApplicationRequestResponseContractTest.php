<?php

namespace Tests\Unit;

use App\Domain\CommonAuthorityEvidenceContract;
use App\Domain\InMemoryLogicalPersistenceRepositoryContract;
use App\Domain\PersistenceBoundaryApplicationInterfaceIntegrationContract;
use App\Domain\SqliteInMemoryLogicalPersistenceAdapter;
use App\Domain\TransportNeutralApplicationRequestResponseContract;
use PHPUnit\Framework\TestCase;

final class TransportNeutralApplicationRequestResponseContractTest extends TestCase
{
    public function testMalformedExtraFieldAndUnsupportedFamilyFailClosedWithoutDispatch(): void
    {
        $contract = $this->contract();

        $malformed = $contract->handle([
            'request_identity' => 'SYNTHETIC-REQUEST-MALFORMED',
            'family' => TransportNeutralApplicationRequestResponseContract::FAMILY_MUTATION_SUBMISSION,
        ]);
        $extra = $contract->handle([
            'request_identity' => 'SYNTHETIC-REQUEST-EXTRA',
            'family' => TransportNeutralApplicationRequestResponseContract::FAMILY_MUTATION_SUBMISSION,
            'semantic_payload' => ['record' => $this->record('SYNTHETIC-EXTRA')],
            'unexpected_transport_field' => 'SYNTHETIC-MUST-BE-REJECTED',
        ]);
        $unsupported = $contract->handle([
            'request_identity' => 'SYNTHETIC-REQUEST-UNSUPPORTED',
            'family' => 'SYNTHETIC-UNSUPPORTED-FAMILY',
            'semantic_payload' => ['synthetic' => 'SYNTHETIC-VALUE'],
        ]);

        self::assertSame(TransportNeutralApplicationRequestResponseContract::REQUEST_REJECTED, $malformed['transport_disposition']);
        self::assertSame('MALFORMED_REQUEST_ENVELOPE', $malformed['bounded_error_condition']);
        self::assertSame(0, $malformed['dispatch_count']);
        self::assertNull($malformed['application_semantic_result']);
        self::assertSame(TransportNeutralApplicationRequestResponseContract::REQUEST_REJECTED, $extra['transport_disposition']);
        self::assertSame('UNKNOWN_TOP_LEVEL_FIELD', $extra['bounded_error_condition']);
        self::assertSame(0, $extra['dispatch_count']);
        self::assertSame(TransportNeutralApplicationRequestResponseContract::UNKNOWN, $unsupported['transport_disposition']);
        self::assertSame('UNSUPPORTED_FAMILY', $unsupported['bounded_error_condition']);
        self::assertSame(0, $unsupported['dispatch_count']);
        $this->assertMandatoryNonAuthority($malformed);
        $this->assertMandatoryNonAuthority($extra);
        $this->assertMandatoryNonAuthority($unsupported);
    }

    public function testMutationDispatchesOnceAndExactRequestCorrelationReturnsDeterministicCachedEnvelope(): void
    {
        $adapter = new SqliteInMemoryLogicalPersistenceAdapter();
        $contract = $this->contract($adapter);
        $request = $this->mutationRequest('SYNTHETIC-REQUEST-MUTATION', $this->record('SYNTHETIC-RECORD-MUTATION'));
        $unchangedInput = $request;

        $first = $contract->handle($request);
        $duplicate = $contract->handle($request);

        self::assertSame($unchangedInput, $request);
        self::assertSame($first, $duplicate);
        self::assertSame(TransportNeutralApplicationRequestResponseContract::DELIVERED_TO_APPLICATION, $first['transport_disposition']);
        self::assertSame(TransportNeutralApplicationRequestResponseContract::FAMILY_MUTATION_SUBMISSION, $first['family']);
        self::assertSame('SYNTHETIC-REQUEST-MUTATION', $first['request_identity']);
        self::assertSame(1, $first['dispatch_count']);
        self::assertTrue($first['request_correlation_compatible']);
        self::assertSame(1, $adapter->count());
        self::assertSame(CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN, $first['source_domain_outcome']);
        self::assertSame(CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN, $first['application_semantic_result']['authoritative_outcome']);
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::STORED_NEW, $first['application_semantic_result']['persistence']['storage_outcome']);
        self::assertTrue($first['reconciliation_required']);
        self::assertFalse($first['transport_disposition_is_domain_outcome']);
        $this->assertMandatoryNonAuthority($first);
    }

    public function testChangedPayloadUnderSameRequestIdentityFailsBeforeSecondDispatch(): void
    {
        $adapter = new SqliteInMemoryLogicalPersistenceAdapter();
        $contract = $this->contract($adapter);
        $record = $this->record('SYNTHETIC-RECORD-CORRELATION');
        $contract->handle($this->mutationRequest('SYNTHETIC-REQUEST-CORRELATION', $record));
        $record['logical_intent']['semantic_input']['synthetic_action'] = 'SYNTHETIC-CHANGED-ACTION';

        $conflict = $contract->handle($this->mutationRequest('SYNTHETIC-REQUEST-CORRELATION', $record));

        self::assertSame(TransportNeutralApplicationRequestResponseContract::REQUEST_REJECTED, $conflict['transport_disposition']);
        self::assertSame('REQUEST_IDENTITY_PAYLOAD_CONFLICT', $conflict['bounded_error_condition']);
        self::assertSame(0, $conflict['dispatch_count']);
        self::assertNull($conflict['application_semantic_result']);
        self::assertFalse($conflict['request_correlation_compatible']);
        self::assertSame(1, $adapter->count());
        $this->assertMandatoryNonAuthority($conflict);
    }

    public function testSourceCarriedCommittedAndRejectedRemainNonAuthoritativeTransportEvidence(): void
    {
        foreach ([
            CommonAuthorityEvidenceContract::OUTCOME_COMMITTED,
            CommonAuthorityEvidenceContract::OUTCOME_REJECTED,
        ] as $outcome) {
            $contract = $this->contract();
            $response = $contract->handle($this->mutationRequest(
                'SYNTHETIC-REQUEST-'.$outcome,
                $this->record('SYNTHETIC-RECORD-'.$outcome, $outcome, true),
            ));

            self::assertSame(TransportNeutralApplicationRequestResponseContract::DELIVERED_TO_APPLICATION, $response['transport_disposition']);
            self::assertSame($outcome, $response['source_domain_outcome']);
            self::assertSame($outcome, $response['application_semantic_result']['authoritative_outcome']);
            self::assertFalse($response['source_authority']);
            self::assertFalse($response['domain_writer_authority']);
            self::assertFalse($response['authoritative_mutation_success']);
            self::assertFalse($response['transport_disposition_is_domain_outcome']);
            $this->assertMandatoryNonAuthority($response);
        }
    }

    public function testReconciliationIsReadOnlyAndPreservesIntentMismatch(): void
    {
        $adapter = new SqliteInMemoryLogicalPersistenceAdapter();
        $contract = $this->contract($adapter);
        $record = $this->record(
            'SYNTHETIC-RECORD-RECONCILIATION',
            CommonAuthorityEvidenceContract::OUTCOME_COMMITTED,
            true,
        );
        $contract->handle($this->mutationRequest('SYNTHETIC-REQUEST-SUBMIT-FOR-RECONCILIATION', $record));
        $before = $adapter->count();

        $exact = $contract->handle([
            'request_identity' => 'SYNTHETIC-REQUEST-RECONCILE-EXACT',
            'family' => TransportNeutralApplicationRequestResponseContract::FAMILY_OUTCOME_RECONCILIATION,
            'semantic_payload' => [
                'logical_record_identity' => $record['logical_record_identity'],
                'expected_intent' => $record['logical_intent'],
            ],
        ]);
        $changedIntent = $record['logical_intent'];
        $changedIntent['semantic_input']['synthetic_action'] = 'SYNTHETIC-CHANGED-RECONCILIATION';
        $mismatch = $contract->handle([
            'request_identity' => 'SYNTHETIC-REQUEST-RECONCILE-MISMATCH',
            'family' => TransportNeutralApplicationRequestResponseContract::FAMILY_OUTCOME_RECONCILIATION,
            'semantic_payload' => [
                'logical_record_identity' => $record['logical_record_identity'],
                'expected_intent' => $changedIntent,
            ],
        ]);

        self::assertSame($before, $adapter->count());
        self::assertSame(1, $exact['dispatch_count']);
        self::assertSame('EXACT', $exact['application_semantic_result']['intent_binding']);
        self::assertSame(CommonAuthorityEvidenceContract::OUTCOME_COMMITTED, $exact['source_domain_outcome']);
        self::assertFalse($exact['application_semantic_result']['mutation_replayed']);
        self::assertFalse($exact['application_semantic_result']['mutation_resubmitted']);
        self::assertSame('MISMATCH', $mismatch['application_semantic_result']['intent_binding']);
        self::assertSame('RECONCILIATION_INTENT_MISMATCH', $mismatch['bounded_error_condition']);
        self::assertSame(CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN, $mismatch['source_domain_outcome']);
        self::assertSame($before, $adapter->count());
        $this->assertMandatoryNonAuthority($exact);
        $this->assertMandatoryNonAuthority($mismatch);
    }

    public function testProjectionPreservesAllConditionsAndNeverLeaksPrivateFixtureMaterial(): void
    {
        $conditions = [
            CommonAuthorityEvidenceContract::CONDITION_UNKNOWN => InMemoryLogicalPersistenceRepositoryContract::UNKNOWN,
            CommonAuthorityEvidenceContract::CONDITION_ABSENT => InMemoryLogicalPersistenceRepositoryContract::ABSENT,
            CommonAuthorityEvidenceContract::CONDITION_UNAVAILABLE => InMemoryLogicalPersistenceRepositoryContract::UNAVAILABLE,
            CommonAuthorityEvidenceContract::CONDITION_STALE => InMemoryLogicalPersistenceRepositoryContract::STALE,
            CommonAuthorityEvidenceContract::CONDITION_SUPERSEDED => InMemoryLogicalPersistenceRepositoryContract::SUPERSEDED,
            CommonAuthorityEvidenceContract::CONDITION_INCOMPARABLE => InMemoryLogicalPersistenceRepositoryContract::INCOMPARABLE,
        ];

        foreach ($conditions as $condition => $resolution) {
            $contract = $this->contract();
            $contract->handle($this->mutationRequest(
                'SYNTHETIC-REQUEST-STORE-'.$condition,
                $this->record('SYNTHETIC-RECORD-'.$condition, condition: $condition),
            ));
            $response = $contract->handle($this->projectionRequest('SYNTHETIC-REQUEST-PROJECTION-'.$condition));

            self::assertSame($resolution, $response['application_semantic_result']['resolution']);
            self::assertSame($resolution, $response['bounded_error_condition']);
            self::assertTrue($response['application_semantic_result']['read_only']);
            self::assertTrue($response['application_semantic_result']['privacy_minimal']);
            self::assertFalse($response['application_semantic_result']['projection_is_permission']);
            self::assertStringNotContainsString('MUST-NOT-LEAK-SYNTHETIC-PRIVATE', serialize($response));
            $this->assertMandatoryNonAuthority($response);
        }

        $missing = $this->contract()->handle($this->projectionRequest('SYNTHETIC-REQUEST-PROJECTION-MISSING'));
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::MISSING, $missing['bounded_error_condition']);
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::MISSING, $missing['application_semantic_result']['resolution']);

        $bindingContract = $this->contract();
        $bindingContract->handle($this->mutationRequest(
            'SYNTHETIC-REQUEST-BINDING-STORE',
            $this->record('SYNTHETIC-RECORD-BINDING'),
        ));
        $wrong = $this->projectionRequest('SYNTHETIC-REQUEST-PROJECTION-WRONG-BINDING');
        $wrong['semantic_payload']['request_bindings']['audience'] = 'SYNTHETIC-WRONG-AUDIENCE';
        $bindingMismatch = $bindingContract->handle($wrong);
        self::assertSame('PROJECTION_BINDING_MISMATCH', $bindingMismatch['bounded_error_condition']);
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::UNKNOWN, $bindingMismatch['application_semantic_result']['resolution']);
        self::assertNull($bindingMismatch['application_semantic_result']['projection']);
    }

    public function testRevalidationPreservesGrantedDeniedAndUnknownWithoutExecutingAction(): void
    {
        $contract = $this->contract();
        $record = $this->record('SYNTHETIC-RECORD-REVALIDATION');
        $contract->handle($this->mutationRequest('SYNTHETIC-REQUEST-REVALIDATION-STORE', $record));

        $granted = $contract->handle($this->revalidationRequest(
            'SYNTHETIC-REQUEST-REVALIDATION-GRANTED',
            $record,
            $record['bindings'],
        ));
        $wrongBindings = $record['bindings'];
        $wrongBindings['actor_role'] = 'SYNTHETIC-WRONG-ROLE';
        $denied = $contract->handle($this->revalidationRequest(
            'SYNTHETIC-REQUEST-REVALIDATION-DENIED',
            $record,
            $wrongBindings,
        ));
        $missingContract = $this->contract();
        $unknown = $missingContract->handle($this->revalidationRequest(
            'SYNTHETIC-REQUEST-REVALIDATION-UNKNOWN',
            $record,
            $record['bindings'],
        ));

        self::assertSame(PersistenceBoundaryApplicationInterfaceIntegrationContract::GRANTED, $granted['application_semantic_result']['classification']);
        self::assertSame('NONE', $granted['bounded_error_condition']);
        self::assertTrue($granted['revalidation_required']);
        self::assertTrue($granted['application_semantic_result']['execution_must_revalidate']);
        self::assertFalse($granted['protected_action_executed']);
        self::assertFalse($granted['bearer_capability']);
        self::assertSame(PersistenceBoundaryApplicationInterfaceIntegrationContract::DENIED, $denied['application_semantic_result']['classification']);
        self::assertSame('REVALIDATION_DENIED', $denied['bounded_error_condition']);
        self::assertSame(PersistenceBoundaryApplicationInterfaceIntegrationContract::UNKNOWN, $unknown['application_semantic_result']['classification']);
        self::assertSame('REVALIDATION_UNKNOWN', $unknown['bounded_error_condition']);
        $this->assertMandatoryNonAuthority($granted);
        $this->assertMandatoryNonAuthority($denied);
        $this->assertMandatoryNonAuthority($unknown);
    }

    public function testInvalidationPreservesRelationWithoutLifecycleOrOrderingAuthority(): void
    {
        foreach ([
            CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
            CommonAuthorityEvidenceContract::INVALIDATION_REVOCATION,
            CommonAuthorityEvidenceContract::INVALIDATION_SUPERSESSION,
        ] as $relation) {
            $contract = $this->contract();
            $record = $this->record('SYNTHETIC-RECORD-'.$relation);
            $contract->handle($this->mutationRequest('SYNTHETIC-REQUEST-STORE-'.$relation, $record));
            $response = $contract->handle([
                'request_identity' => 'SYNTHETIC-REQUEST-INVALIDATE-'.$relation,
                'family' => TransportNeutralApplicationRequestResponseContract::FAMILY_INVALIDATION_OBSERVATION,
                'semantic_payload' => [
                    'logical_record_identity' => $record['logical_record_identity'],
                    'relation' => $relation,
                ],
            ]);

            self::assertSame(1, $response['dispatch_count']);
            self::assertSame($relation, $response['application_semantic_result']['relation']);
            self::assertSame(InMemoryLogicalPersistenceRepositoryContract::INVALIDATED, $response['bounded_error_condition']);
            self::assertFalse($response['application_semantic_result']['lifecycle_reset']);
            self::assertFalse($response['application_semantic_result']['reopened']);
            self::assertFalse($response['application_semantic_result']['new_aggregate_created']);
            self::assertFalse($response['application_semantic_result']['transition_synthesized']);
            self::assertFalse($response['application_semantic_result']['global_ordering']);
            self::assertFalse($response['global_revision']);
            self::assertFalse($response['request_order_authority']);
            self::assertFalse($response['arrival_order_authority']);
            $this->assertMandatoryNonAuthority($response);
        }
    }

    public function testFiveFamiliesUseExactPayloadShapesAndEveryResponseHasNoHttpOrAuthoritySemantics(): void
    {
        $contract = $this->contract();
        $record = $this->record('SYNTHETIC-RECORD-FIVE-FAMILIES');
        $mutation = $contract->handle($this->mutationRequest('SYNTHETIC-REQUEST-FAMILY-MUTATION', $record));
        $responses = [
            $mutation,
            $contract->handle([
                'request_identity' => 'SYNTHETIC-REQUEST-FAMILY-RECONCILIATION',
                'family' => TransportNeutralApplicationRequestResponseContract::FAMILY_OUTCOME_RECONCILIATION,
                'semantic_payload' => [
                    'logical_record_identity' => $record['logical_record_identity'],
                    'expected_intent' => $record['logical_intent'],
                ],
            ]),
            $contract->handle($this->projectionRequest('SYNTHETIC-REQUEST-FAMILY-PROJECTION')),
            $contract->handle($this->revalidationRequest(
                'SYNTHETIC-REQUEST-FAMILY-REVALIDATION',
                $record,
                $record['bindings'],
            )),
            $contract->handle([
                'request_identity' => 'SYNTHETIC-REQUEST-FAMILY-INVALIDATION',
                'family' => TransportNeutralApplicationRequestResponseContract::FAMILY_INVALIDATION_OBSERVATION,
                'semantic_payload' => [
                    'logical_record_identity' => $record['logical_record_identity'],
                    'relation' => CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
                ],
            ]),
        ];

        self::assertSame([
            TransportNeutralApplicationRequestResponseContract::FAMILY_MUTATION_SUBMISSION,
            TransportNeutralApplicationRequestResponseContract::FAMILY_OUTCOME_RECONCILIATION,
            TransportNeutralApplicationRequestResponseContract::FAMILY_PROJECTION_RETRIEVAL,
            TransportNeutralApplicationRequestResponseContract::FAMILY_PROTECTED_REVALIDATION,
            TransportNeutralApplicationRequestResponseContract::FAMILY_INVALIDATION_OBSERVATION,
        ], array_column($responses, 'family'));

        foreach ($responses as $response) {
            self::assertSame(TransportNeutralApplicationRequestResponseContract::DELIVERED_TO_APPLICATION, $response['transport_disposition']);
            self::assertSame(1, $response['dispatch_count']);
            self::assertArrayNotHasKey('http_status', $response);
            self::assertArrayNotHasKey('route', $response);
            self::assertArrayNotHasKey('controller', $response);
            self::assertFalse($response['http_semantics']);
            $this->assertMandatoryNonAuthority($response);
        }

        $badPayload = $contract->handle([
            'request_identity' => 'SYNTHETIC-REQUEST-BAD-PAYLOAD',
            'family' => TransportNeutralApplicationRequestResponseContract::FAMILY_PROJECTION_RETRIEVAL,
            'semantic_payload' => [
                'query' => $this->query(),
                'request_bindings' => $this->projectionBindings(),
                'unknown_family_field' => 'SYNTHETIC-REJECT',
            ],
        ]);
        self::assertSame(TransportNeutralApplicationRequestResponseContract::REQUEST_REJECTED, $badPayload['transport_disposition']);
        self::assertSame('MALFORMED_FAMILY_PAYLOAD', $badPayload['bounded_error_condition']);
        self::assertSame(0, $badPayload['dispatch_count']);
    }

    private function contract(?SqliteInMemoryLogicalPersistenceAdapter $adapter = null): TransportNeutralApplicationRequestResponseContract
    {
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
    private function revalidationRequest(string $requestIdentity, array $record, array $requiredBindings): array
    {
        return [
            'request_identity' => $requestIdentity,
            'family' => TransportNeutralApplicationRequestResponseContract::FAMILY_PROTECTED_REVALIDATION,
            'semantic_payload' => [
                'query' => $this->query(),
                'required_bindings' => $requiredBindings,
                'source_evidence' => $this->evidence($record),
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
            'record_family' => 'SYNTHETIC-TRANSPORT-NEUTRAL-FAMILY',
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
                ? ['outcome_reference' => 'SYNTHETIC-SOURCE-OUTCOME-'.$identity, 'source_carried' => true]
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
            'record_family' => 'SYNTHETIC-TRANSPORT-NEUTRAL-FAMILY',
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

    /** @param array<string, mixed> $record @return array<string, mixed> */
    private function evidence(array $record): array
    {
        return CommonAuthorityEvidenceContract::evidence(
            $record['bindings'],
            $record['source_condition'],
            $record['source_revision'],
            $record['currentness'],
            $record['freshness'],
            $record['authoritative_outcome'],
        );
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
