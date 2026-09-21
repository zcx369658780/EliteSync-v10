<?php

namespace Tests\Unit;

use App\Domain\CommonAuthorityEvidenceContract;
use App\Domain\InMemoryLogicalPersistenceRepositoryContract;
use App\Domain\PersistenceBoundaryApplicationInterfaceIntegrationContract;
use App\Domain\ProductConnectionPersistenceApplicationAdapter;
use App\Domain\SqliteInMemoryLogicalPersistenceAdapter;
use InvalidArgumentException;
use PHPUnit\Framework\TestCase;

final class ProductConnectionPersistenceApplicationAdapterTest extends TestCase
{
    public function test_known_current_state_materializes_exact_52_key_usable_result_and_duplicate(): void
    {
        [$adapter] = $this->adapter();
        $request = $this->currentRequest('CN_ACTIVE');
        $original = $request;
        $first = $adapter->evaluateCurrentSynthetic($request);
        $second = $adapter->evaluateCurrentSynthetic($request);

        self::assertSame($original, $request);
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::STORED_NEW, $first['storage_disposition']);
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::EXACT_DUPLICATE, $second['storage_disposition']);
        self::assertTrue($first['materialized_projection_usable']);
        self::assertSame('EXACT_PRODUCT_CONNECTION_CURRENT_STATE_PROJECTION_MATERIALIZED_USABLE', $first['condition']);
        self::assertSame($first['logical_record_identity'], $second['logical_record_identity']);
        self::assertSame($this->resultKeys(), array_keys($first));
        self::assertCount(52, $first);
        self::assertArrayNotHasKey('source_evidence', $first['product_connection_payload']);
        self::assertArrayNotHasKey('required_bindings', $first['product_connection_payload']);
        self::assertSame(13, count($first['product_connection_payload']['current_state_dependency']));
    }

    public function test_missing_and_unusable_current_state_are_exact_but_domain_unusable(): void
    {
        [$adapter] = $this->adapter();
        $missing = $adapter->evaluateCurrentSynthetic([
            'synthetic_dev_test_only' => true,
            'connection' => $this->connection(),
            'state_evidence' => [],
        ]);
        self::assertSame('UNKNOWN', $missing['classification']);
        self::assertFalse($missing['materialized_projection_usable']);
        self::assertSame('PRODUCT_CONNECTION_CURRENT_STATE_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED', $missing['condition']);

        $request = $this->currentRequest('CN_PENDING');
        $request['state_evidence'][0]['source_evidence']['freshness'] = false;
        $unusable = $adapter->evaluateCurrentSynthetic($request);
        self::assertSame(['CURRENT_STATE_NOT_CURRENT_FRESH_BOUND'], $unusable['reason_categories']);
        self::assertFalse($unusable['materialized_projection_usable']);
        self::assertFalse($unusable['product_connection_payload']['current_state_dependency']['freshness']);
    }

    public function test_transition_admissible_unknown_and_three_rejected_categories_are_persisted_exactly(): void
    {
        $cases = [
            [$this->transitionRequest('CN_PENDING', 'CN_ACTIVE'), 'ADMISSIBLE', []],
            [$this->transitionRequest('CN_NONE', 'CN_ACTIVE'), 'REJECTED', ['DIRECT_NONE_TO_ACTIVE_REJECTED']],
            [$this->transitionRequest('CN_ACTIVE', 'CN_PENDING'), 'REJECTED', ['TRANSITION_NOT_ALLOWED']],
            [$this->transitionRequest('CN_CLOSED', 'CN_PENDING'), 'REJECTED', ['TERMINAL_CONNECTION_IDENTITY_CANNOT_REOPEN']],
        ];

        foreach ($cases as [$request, $classification, $reasons]) {
            [$adapter] = $this->adapter();
            $result = $adapter->evaluateTransitionSynthetic($request);
            self::assertSame($classification, $result['classification']);
            self::assertSame($reasons, $result['reason_categories']);
            self::assertSame(15, count($result['product_connection_payload']['transition_dependency']));
            self::assertSame($classification === 'ADMISSIBLE', $result['materialized_projection_usable']);
        }

        [$adapter] = $this->adapter();
        $request = $this->transitionRequest('CN_PENDING', 'CN_ACTIVE');
        $request['transition_evidence'] = [];
        $unknown = $adapter->evaluateTransitionSynthetic($request);
        self::assertSame('UNKNOWN', $unknown['classification']);
        self::assertSame(['MISSING_TRANSITION_EVIDENCE'], $unknown['reason_categories']);
        self::assertFalse($unknown['materialized_projection_usable']);
    }

    public function test_transition_context_and_freshness_failures_reach_domain_semantics(): void
    {
        [$adapter] = $this->adapter();
        $context = $this->transitionRequest('CN_PENDING', 'CN_ACTIVE');
        $context['transition_evidence'][0]['expected_state_revision']['value']++;
        $contextResult = $adapter->evaluateTransitionSynthetic($context);
        self::assertSame(['TRANSITION_CURRENT_CONTEXT_MISMATCH'], $contextResult['reason_categories']);

        [$adapter] = $this->adapter();
        $freshness = $this->transitionRequest('CN_PENDING', 'CN_ACTIVE');
        $freshness['transition_evidence'][0]['source_evidence']['currentness'] = false;
        $freshnessResult = $adapter->evaluateTransitionSynthetic($freshness);
        self::assertSame(['TRANSITION_NOT_CURRENT_FRESH_BOUND'], $freshnessResult['reason_categories']);
        self::assertFalse($freshnessResult['product_connection_payload']['transition_dependency']['currentness']);
    }

    public function test_current_and_transition_dependency_invalidation_are_deterministic(): void
    {
        [$adapter] = $this->adapter();
        $current = $this->currentRequest('CN_ACTIVE') + [
            'dependency_identity' => 'synthetic-state-evidence',
            'relation' => CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
        ];
        $first = $adapter->invalidateCurrentSynthetic($current);
        $second = $adapter->invalidateCurrentSynthetic($current);
        self::assertSame('PRODUCT_CONNECTION_CURRENT_STATE_DEPENDENCY_INVALIDATED_PROJECTION_MATERIALIZED_UNUSABLE', $first['condition']);
        self::assertSame(InMemoryLogicalPersistenceRepositoryContract::EXACT_DUPLICATE, $second['storage_disposition']);
        self::assertSame($first['logical_record_identity'], $second['logical_record_identity']);

        [$adapter] = $this->adapter();
        $transition = $this->transitionRequest('CN_PENDING', 'CN_ACTIVE') + [
            'dependency_identity' => 'synthetic-transition-evidence',
            'relation' => CommonAuthorityEvidenceContract::INVALIDATION_REVOCATION,
        ];
        $result = $adapter->invalidateTransitionSynthetic($transition);
        self::assertSame(['DEPENDENCY_INVALIDATED'], $result['reason_categories']);
        self::assertSame('PRODUCT_CONNECTION_TRANSITION_DEPENDENCY_INVALIDATED_PROJECTION_MATERIALIZED_UNUSABLE', $result['condition']);
        self::assertFalse($result['materialized_projection_usable']);
    }

    public function test_maximal_revision_selection_is_order_invariant_and_recovery_disagreement_fails_closed(): void
    {
        $low = $this->stateEvidence('CN_PENDING', 1);
        $high = $this->stateEvidence('CN_ACTIVE', 2);

        foreach ([[$low, $high], [$high, $low]] as $evidence) {
            [$adapter] = $this->adapter();
            $result = $adapter->evaluateCurrentSynthetic([
                'synthetic_dev_test_only' => true,
                'connection' => $this->connection(),
                'state_evidence' => $evidence,
            ]);
            self::assertSame('CN_ACTIVE', $result['classification']);
            self::assertSame(2, $result['product_connection_payload']['current_state_dependency']['source_revision_value']);
        }

        [$adapter] = $this->adapter();
        $first = $this->stateEvidence('CN_ACTIVE', 2);
        $second = $first;
        $second['source_evidence']['freshness'] = false;
        $conflict = $adapter->evaluateCurrentSynthetic([
            'synthetic_dev_test_only' => true,
            'connection' => $this->connection(),
            'state_evidence' => [$first, $second],
        ]);
        self::assertSame('UNKNOWN', $conflict['classification']);
        self::assertSame(['CONFLICTING_EQUAL_REVISION_STATE_EVIDENCE'], $conflict['reason_categories']);
    }

    public function test_structural_gate_emits_each_exact_diagnostic_and_domain_mismatches_are_not_input_errors(): void
    {
        $cases = [];
        $request = $this->currentRequest('CN_ACTIVE');
        $request['connection']['connection_identity'] = '';
        $cases[] = [$request, 'CONNECTION_IDENTITY_REQUIRED'];
        $request = $this->currentRequest('CN_ACTIVE');
        $request['connection']['participants'] = ['only-one'];
        $cases[] = [$request, 'EXACTLY_TWO_PARTICIPANTS_REQUIRED'];
        $request = $this->currentRequest('CN_ACTIVE');
        $request['connection']['protected_use_scope'] = '';
        $cases[] = [$request, 'PROTECTED_USE_SCOPE_REQUIRED'];
        $request = $this->currentRequest('CN_ACTIVE');
        $request['state_evidence'][0]['extra'] = true;
        $cases[] = [$request, 'INVALID_EVIDENCE_SHAPE'];
        $request = $this->currentRequest('CN_ACTIVE');
        $request['state_evidence'][0]['state'] = 'INVALID';
        $cases[] = [$request, 'INVALID_CONNECTION_STATE'];
        $request = $this->transitionRequest('CN_PENDING', 'CN_ACTIVE');
        $request['transition_evidence'][0]['to_state'] = 'INVALID';
        $cases[] = [$request, 'INVALID_TARGET_STATE'];

        foreach ($cases as $index => [$invalid, $message]) {
            [$adapter] = $this->adapter();

            try {
                if ($index === array_key_last($cases)) {
                    $adapter->evaluateTransitionSynthetic($invalid);
                } else {
                    $adapter->evaluateCurrentSynthetic($invalid);
                }
                self::fail('Expected structural rejection.');
            } catch (InvalidArgumentException $exception) {
                self::assertSame($message, $exception->getMessage());
            }
        }

        [$adapter] = $this->adapter();
        $cross = $this->currentRequest('CN_ACTIVE');
        $cross['state_evidence'][0]['connection_identity'] = 'synthetic-other-connection';
        $result = $adapter->evaluateCurrentSynthetic($cross);
        self::assertSame(['CROSS_CONNECTION_STATE_EVIDENCE'], $result['reason_categories']);
    }

    public function test_generic_projection_invalidation_makes_readback_unusable_without_typed_payload_mutation(): void
    {
        [$adapter, $application] = $this->adapter();
        $request = $this->currentRequest('CN_ACTIVE');
        $first = $adapter->evaluateCurrentSynthetic($request);
        $application->observeInvalidation(
            $first['logical_record_identity'],
            CommonAuthorityEvidenceContract::INVALIDATION_SUPERSESSION,
        );
        $second = $adapter->evaluateCurrentSynthetic($request);

        self::assertFalse($second['materialized_projection_usable']);
        self::assertSame('PRODUCT_CONNECTION_CURRENT_STATE_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED', $second['condition']);
        self::assertFalse($second['product_connection_payload']['invalidation']['invalidated']);
    }

    /** @return array{ProductConnectionPersistenceApplicationAdapter, PersistenceBoundaryApplicationInterfaceIntegrationContract} */
    private function adapter(): array
    {
        $application = new PersistenceBoundaryApplicationInterfaceIntegrationContract(
            new SqliteInMemoryLogicalPersistenceAdapter(),
        );

        return [new ProductConnectionPersistenceApplicationAdapter($application), $application];
    }

    /** @return array<string, mixed> */
    private function connection(): array
    {
        return [
            'connection_identity' => 'synthetic-connection',
            'participants' => ['synthetic-participant-b', 'synthetic-participant-a'],
            'protected_use_scope' => 'SYNTHETIC_PRODUCT_CONNECTION_USE',
        ];
    }

    /** @return array<string, mixed> */
    private function currentRequest(string $state): array
    {
        return [
            'synthetic_dev_test_only' => true,
            'connection' => $this->connection(),
            'state_evidence' => [$this->stateEvidence($state, 1)],
        ];
    }

    /** @return array<string, mixed> */
    private function transitionRequest(string $from, string $to): array
    {
        $state = $this->stateEvidence($from, 1);

        return [
            'synthetic_dev_test_only' => true,
            'connection' => $this->connection(),
            'state_evidence' => [$state],
            'transition_evidence' => [$this->transitionEvidence($from, $to, $state['source_evidence']['source_revision'])],
        ];
    }

    /** @return array<string, mixed> */
    private function stateEvidence(string $state, int $revision): array
    {
        $bindings = $this->bindings($this->terminal($state), 'SYNTHETIC_CURRENT_STATE');

        return [
            'state_evidence_identity' => 'synthetic-state-evidence',
            'connection_identity' => 'synthetic-connection',
            'participants' => ['synthetic-participant-a', 'synthetic-participant-b'],
            'state' => $state,
            'required_bindings' => $bindings,
            'source_evidence' => $this->sourceEvidence($bindings, 'synthetic-state-lineage', $revision),
        ];
    }

    /** @param array<string, mixed> $expectedRevision @return array<string, mixed> */
    private function transitionEvidence(string $from, string $to, array $expectedRevision): array
    {
        $bindings = $this->bindings(false, 'SYNTHETIC_TRANSITION');

        return [
            'transition_identity' => 'synthetic-transition-evidence',
            'connection_identity' => 'synthetic-connection',
            'participants' => ['synthetic-participant-a', 'synthetic-participant-b'],
            'from_state' => $from,
            'to_state' => $to,
            'expected_state_revision' => $expectedRevision,
            'required_bindings' => $bindings,
            'source_evidence' => $this->sourceEvidence($bindings, 'synthetic-transition-lineage', 2),
        ];
    }

    /** @return array<string, mixed> */
    private function bindings(bool $terminal, string $scope): array
    {
        return [
            'authority_owner' => 'SYNTHETIC_SOURCE',
            'authority_scope' => $scope,
            'actor' => 'synthetic-actor',
            'actor_role' => 'SYNTHETIC_REVIEWER',
            'subject' => 'synthetic-connection',
            'participants' => ['synthetic-participant-a', 'synthetic-participant-b'],
            'audience' => 'SYNTHETIC_AUDIENCE',
            'purpose' => 'SYNTHETIC_PRODUCT_CONNECTION_USE',
            'aggregate_context' => 'synthetic-connection',
            'lifecycle_identity' => 'synthetic-connection',
            'terminal' => $terminal,
        ];
    }

    /** @param array<string, mixed> $bindings @return array<string, mixed> */
    private function sourceEvidence(array $bindings, string $lineage, int $revision): array
    {
        return [
            'record_kind' => 'SOURCE_EVIDENCE',
            'bindings' => $bindings,
            'source_condition' => CommonAuthorityEvidenceContract::CONDITION_PRESENT,
            'source_revision' => [
                'authority_owner' => $bindings['authority_owner'],
                'authority_scope' => $bindings['authority_scope'],
                'lineage' => $lineage,
                'aggregate_context' => $bindings['aggregate_context'],
                'value' => $revision,
            ],
            'currentness' => true,
            'freshness' => true,
            'authoritative_outcome' => CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN,
        ];
    }

    private function terminal(string $state): bool
    {
        return in_array($state, ['CN_CLOSED', 'CN_DECLINED', 'CN_WITHDRAWN', 'CN_EXPIRED'], true);
    }

    /** @return list<string> */
    private function resultKeys(): array
    {
        return [
            'record_kind', 'operation', 'fact_class', 'classification', 'reason_categories',
            'product_connection_payload', 'logical_record_identity', 'logical_intent_identity', 'lifecycle_identity',
            'source_projection_lineage', 'derived_correlation_revision', 'storage_disposition',
            'projection_read_disposition', 'binding_classification', 'materialized_projection_usable',
            'authoritative_outcome', 'reconciliation_required', 'invalidation_required', 'revalidation_required',
            'condition', 'synthetic_dev_test_only', 'source_local_revision_only', 'global_revision', 'last_write_wins',
            'last_received_wins', 'transport_disposition', 'http_status', 'source_authority', 'domain_writer_authority',
            'authoritative_mutation_success', 'permission', 'permission_token', 'bearer_capability',
            'transport_execution_authority', 'production_ready', 'deployable', 'real_data_authorized',
            'readiness_authority', 'match_authority', 'connection_authority', 'consent_authority',
            'conversation_authority', 'relationship_authority', 'home_action_authority',
            'notification_delivery_authority', 'launch_authority', 'connection_created', 'connection_activated',
            'match_substituted_for_connection', 'messaging_consent_granted', 'conversation_granted',
            'source_evidence_mutated',
        ];
    }
}
