<?php

namespace Tests\Unit;

use App\Domain\CommonAuthorityEvidenceContract;
use App\Domain\InMemoryLogicalPersistenceRepositoryContract;
use App\Domain\SqliteInMemoryLogicalPersistenceAdapter;
use PHPUnit\Framework\TestCase;

final class ProductConnectionPersistenceFamilyTest extends TestCase
{
    public function test_current_state_family_has_reference_sqlite_parity_and_retains_exact_payload(): void
    {
        foreach ([$this->currentRecord('CN_ACTIVE'), $this->missingCurrentRecord(), $this->unusableCurrentRecord()] as $record) {
            [$reference, $sqlite] = $this->repositories();
            $referenceResult = $reference->store($record);
            $sqliteResult = $sqlite->store($record);

            self::assertSame(InMemoryLogicalPersistenceRepositoryContract::STORED_NEW, $referenceResult['storage_outcome']);
            self::assertSame($referenceResult, $sqliteResult);
            self::assertSame($reference->readExact($record['logical_record_identity']), $sqlite->readExact($record['logical_record_identity']));
            self::assertSame(
                $record['derived_projection_payload'],
                $reference->privacyMinimalProjection($record['logical_record_identity'])['record']['derived_projection_payload'],
            );
        }
    }

    public function test_transition_matrix_accepts_unknown_admissible_and_all_rejected_categories(): void
    {
        $records = [
            $this->transitionRecord('UNKNOWN', 'CN_PENDING', null, ['MISSING_TRANSITION_EVIDENCE']),
            $this->transitionRecord('UNKNOWN', 'CN_PENDING', 'CN_ACTIVE', ['TRANSITION_NOT_CURRENT_FRESH_BOUND'], false),
            $this->transitionRecord('UNKNOWN', 'CN_PENDING', 'CN_ACTIVE', ['TRANSITION_CURRENT_CONTEXT_MISMATCH'], true, true),
            $this->transitionRecord('ADMISSIBLE', 'CN_PENDING', 'CN_ACTIVE', []),
            $this->transitionRecord('REJECTED', 'CN_NONE', 'CN_ACTIVE', ['DIRECT_NONE_TO_ACTIVE_REJECTED']),
            $this->transitionRecord('REJECTED', 'CN_ACTIVE', 'CN_PENDING', ['TRANSITION_NOT_ALLOWED']),
            $this->transitionRecord('REJECTED', 'CN_CLOSED', 'CN_PENDING', ['TERMINAL_CONNECTION_IDENTITY_CANNOT_REOPEN']),
        ];

        foreach ($records as $record) {
            foreach ($this->repositories() as $repository) {
                self::assertSame(
                    InMemoryLogicalPersistenceRepositoryContract::STORED_NEW,
                    $repository->store($record)['storage_outcome'],
                );
            }
        }
    }

    public function test_dependency_invalidation_is_typed_and_generic_overlay_does_not_mutate_it(): void
    {
        $ordinary = $this->currentRecord('CN_ACTIVE');
        $payload = $ordinary['derived_projection_payload'];
        $payload['classification'] = 'UNKNOWN';
        $payload['reason_categories'] = ['DEPENDENCY_INVALIDATED'];
        $payload['connection_active_for_downstream_consideration'] = false;
        $payload['valid_for_protected_use'] = false;
        $payload['invalidation'] = [
            'invalidated' => true,
            'relation' => CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
            'dependency_identity' => 'synthetic-state-evidence',
            'lifecycle_reset' => false,
            'connection_reopened' => false,
        ];
        $invalidated = $this->record($payload);

        foreach ($this->repositories() as $repository) {
            self::assertSame(InMemoryLogicalPersistenceRepositoryContract::STORED_NEW, $repository->store($invalidated)['storage_outcome']);
            $typedPayload = $repository->readExact($invalidated['logical_record_identity'])['record']['derived_projection_payload'];
            self::assertTrue($typedPayload['invalidation']['invalidated']);

            $overlay = $repository->observeInvalidation(
                $invalidated['logical_record_identity'],
                CommonAuthorityEvidenceContract::INVALIDATION_REVOCATION,
            );
            self::assertSame(InMemoryLogicalPersistenceRepositoryContract::INVALIDATED, $overlay['resolution']);
            self::assertTrue($overlay['record']['projection_invalidated']);
            self::assertSame($typedPayload, $overlay['record']['derived_projection_payload']);
        }
    }

    public function test_malformed_keys_dependencies_reasons_context_and_identities_are_rejected(): void
    {
        $valid = $this->transitionRecord('ADMISSIBLE', 'CN_PENDING', 'CN_ACTIVE', []);
        $mutations = [];

        $wrongPayloadKey = $valid;
        $wrongPayloadKey['derived_projection_payload']['extra'] = true;
        $mutations[] = $wrongPayloadKey;

        $wrongDependencyKey = $valid;
        unset($wrongDependencyKey['derived_projection_payload']['current_state_dependency']['freshness']);
        $mutations[] = $wrongDependencyKey;

        $wrongReason = $valid;
        $wrongReason['derived_projection_payload']['reason_categories'] = ['INVALID_CONNECTION_STATE'];
        $mutations[] = $wrongReason;

        $wrongExpectedRevision = $valid;
        $wrongExpectedRevision['derived_projection_payload']['transition_dependency']['expected_state_revision']['extra'] = 1;
        $mutations[] = $wrongExpectedRevision;

        $identityCollision = $valid;
        $identityCollision['derived_projection_payload']['transition_dependency']['transition_identity'] = 'synthetic-state-evidence';
        $mutations[] = $identityCollision;

        $wrongDigest = $valid;
        $wrongDigest['logical_record_identity'] .= '-changed';
        $mutations[] = $wrongDigest;

        foreach ($mutations as $record) {
            foreach ($this->repositories() as $repository) {
                self::assertSame(
                    InMemoryLogicalPersistenceRepositoryContract::INVALID_RECORD_REJECTED,
                    $repository->store($record)['storage_outcome'],
                );
            }
        }
    }

    public function test_duplicate_incomparable_terminal_and_proposed_terminal_lifecycle_rules(): void
    {
        foreach ($this->repositories() as $repository) {
            $ordinary = $this->currentRecord('CN_ACTIVE');
            self::assertSame(InMemoryLogicalPersistenceRepositoryContract::STORED_NEW, $repository->store($ordinary)['storage_outcome']);
            self::assertSame(InMemoryLogicalPersistenceRepositoryContract::EXACT_DUPLICATE, $repository->store($ordinary)['storage_outcome']);

            $changed = $this->currentRecord('CN_PAUSED');
            self::assertSame(InMemoryLogicalPersistenceRepositoryContract::INCOMPARABLE_COEXISTS, $repository->store($changed)['storage_outcome']);

            $terminal = $this->currentRecord('CN_CLOSED');
            self::assertSame(InMemoryLogicalPersistenceRepositoryContract::INCOMPARABLE_COEXISTS, $repository->store($terminal)['storage_outcome']);
            self::assertSame(
                InMemoryLogicalPersistenceRepositoryContract::INVALID_RECORD_REJECTED,
                $repository->store($this->currentRecord('CN_PENDING'))['storage_outcome'],
            );
        }

        foreach ($this->repositories() as $repository) {
            $proposedTerminal = $this->transitionRecord('ADMISSIBLE', 'CN_ACTIVE', 'CN_CLOSED', []);
            self::assertFalse($proposedTerminal['bindings']['terminal']);
            self::assertSame(InMemoryLogicalPersistenceRepositoryContract::STORED_NEW, $repository->store($proposedTerminal)['storage_outcome']);
        }
    }

    /** @return array{InMemoryLogicalPersistenceRepositoryContract, SqliteInMemoryLogicalPersistenceAdapter} */
    private function repositories(): array
    {
        return [new InMemoryLogicalPersistenceRepositoryContract(), new SqliteInMemoryLogicalPersistenceAdapter()];
    }

    /** @return array<string, mixed> */
    private function currentRecord(string $state): array
    {
        $dependency = $this->currentDependency($state);

        return $this->record([
            'payload_kind' => 'PRODUCT_CONNECTION_CURRENT_STATE',
            'derived_fact_class' => 'PRODUCT_CONNECTION_CURRENT_STATE_DERIVATION',
            'connection_identity' => 'synthetic-connection',
            'participant_references' => ['synthetic-participant-a', 'synthetic-participant-b'],
            'protected_use_scope' => 'SYNTHETIC_PRODUCT_CONNECTION_USE',
            'classification' => $state,
            'current_state' => $state,
            'reason_categories' => [],
            'current_state_dependency' => $dependency,
            'connection_active_for_downstream_consideration' => $state === 'CN_ACTIVE',
            'valid_for_protected_use' => true,
            'terminality' => ['current_state_terminal' => $this->terminal($state)],
            'invalidation' => $this->ordinaryInvalidation(),
        ]);
    }

    /** @return array<string, mixed> */
    private function missingCurrentRecord(): array
    {
        return $this->record([
            'payload_kind' => 'PRODUCT_CONNECTION_CURRENT_STATE',
            'derived_fact_class' => 'PRODUCT_CONNECTION_CURRENT_STATE_DERIVATION',
            'connection_identity' => 'synthetic-connection',
            'participant_references' => ['synthetic-participant-a', 'synthetic-participant-b'],
            'protected_use_scope' => 'SYNTHETIC_PRODUCT_CONNECTION_USE',
            'classification' => 'UNKNOWN',
            'current_state' => null,
            'reason_categories' => ['MISSING_CURRENT_STATE_EVIDENCE'],
            'current_state_dependency' => null,
            'connection_active_for_downstream_consideration' => false,
            'valid_for_protected_use' => false,
            'terminality' => ['current_state_terminal' => false],
            'invalidation' => $this->ordinaryInvalidation(),
        ]);
    }

    /** @return array<string, mixed> */
    private function unusableCurrentRecord(): array
    {
        $dependency = $this->currentDependency('CN_PENDING');
        $dependency['currentness'] = false;

        return $this->record([
            'payload_kind' => 'PRODUCT_CONNECTION_CURRENT_STATE',
            'derived_fact_class' => 'PRODUCT_CONNECTION_CURRENT_STATE_DERIVATION',
            'connection_identity' => 'synthetic-connection',
            'participant_references' => ['synthetic-participant-a', 'synthetic-participant-b'],
            'protected_use_scope' => 'SYNTHETIC_PRODUCT_CONNECTION_USE',
            'classification' => 'UNKNOWN',
            'current_state' => null,
            'reason_categories' => ['CURRENT_STATE_NOT_CURRENT_FRESH_BOUND'],
            'current_state_dependency' => $dependency,
            'connection_active_for_downstream_consideration' => false,
            'valid_for_protected_use' => false,
            'terminality' => ['current_state_terminal' => false],
            'invalidation' => $this->ordinaryInvalidation(),
        ]);
    }

    /** @return array<string, mixed> */
    private function transitionRecord(
        string $classification,
        string $from,
        ?string $to,
        array $reasons,
        bool $transitionUsable = true,
        bool $contextMismatch = false,
    ): array {
        $current = $this->currentDependency($from);
        $transition = $to === null ? null : $this->transitionDependency($from, $to, $current);

        if ($transition !== null && ! $transitionUsable) {
            $transition['freshness'] = false;
        }

        if ($transition !== null && $contextMismatch) {
            $transition['expected_state_revision']['value']++;
        }

        $aggregateCurrentness = $transition === null ? null : true;
        $aggregateFreshness = $transition === null ? null : ($transition['freshness'] ? true : false);

        return $this->record([
            'payload_kind' => 'PRODUCT_CONNECTION_TRANSITION',
            'derived_fact_class' => 'PRODUCT_CONNECTION_TRANSITION_DERIVATION',
            'connection_identity' => 'synthetic-connection',
            'participant_references' => ['synthetic-participant-a', 'synthetic-participant-b'],
            'protected_use_scope' => 'SYNTHETIC_PRODUCT_CONNECTION_USE',
            'classification' => $classification,
            'current_state' => $from,
            'proposed_state' => $to,
            'reason_categories' => $reasons,
            'current_state_dependency' => $current,
            'transition_dependency' => $transition,
            'connection_active_for_downstream_consideration' => $from === 'CN_ACTIVE',
            'valid_for_protected_use' => $classification === 'ADMISSIBLE',
            'terminality' => [
                'current_state_terminal' => $this->terminal($from),
                'proposed_state_terminal' => $to !== null && $this->terminal($to),
                'terminal_reopen_rejected' => $reasons === ['TERMINAL_CONNECTION_IDENTITY_CANNOT_REOPEN'],
            ],
            'invalidation' => $this->ordinaryInvalidation(),
        ], $aggregateCurrentness, $aggregateFreshness);
    }

    /** @return array<string, mixed> */
    private function currentDependency(string $state): array
    {
        return [
            'dependency_type' => 'CURRENT_STATE_EVIDENCE',
            'state_evidence_identity' => 'synthetic-state-evidence',
            'connection_identity' => 'synthetic-connection',
            'state' => $state,
            'authority_owner' => 'SYNTHETIC_SOURCE',
            'authority_scope' => 'SYNTHETIC_CURRENT_STATE',
            'aggregate_context' => 'synthetic-connection',
            'source_lineage' => 'synthetic-state-lineage',
            'source_revision_value' => 7,
            'source_condition' => CommonAuthorityEvidenceContract::CONDITION_PRESENT,
            'protected_binding_satisfied' => true,
            'currentness' => true,
            'freshness' => true,
        ];
    }

    /** @param array<string, mixed> $current @return array<string, mixed> */
    private function transitionDependency(string $from, string $to, array $current): array
    {
        return [
            'dependency_type' => 'TRANSITION_EVIDENCE',
            'transition_identity' => 'synthetic-transition-evidence',
            'connection_identity' => 'synthetic-connection',
            'from_state' => $from,
            'to_state' => $to,
            'expected_state_revision' => [
                'authority_owner' => $current['authority_owner'],
                'authority_scope' => $current['authority_scope'],
                'lineage' => $current['source_lineage'],
                'aggregate_context' => $current['aggregate_context'],
                'value' => $current['source_revision_value'],
            ],
            'authority_owner' => 'SYNTHETIC_SOURCE',
            'authority_scope' => 'SYNTHETIC_TRANSITION',
            'aggregate_context' => 'synthetic-connection',
            'source_lineage' => 'synthetic-transition-lineage',
            'source_revision_value' => 9,
            'source_condition' => CommonAuthorityEvidenceContract::CONDITION_PRESENT,
            'protected_binding_satisfied' => true,
            'currentness' => true,
            'freshness' => true,
        ];
    }

    /** @return array<string, mixed> */
    private function ordinaryInvalidation(): array
    {
        return [
            'invalidated' => false,
            'relation' => null,
            'dependency_identity' => null,
            'lifecycle_reset' => false,
            'connection_reopened' => false,
        ];
    }

    /** @param array<string, mixed> $payload @return array<string, mixed> */
    private function record(array $payload, ?bool $currentness = null, ?bool $freshness = null): array
    {
        $participants = $payload['participant_references'];
        $scope = $payload['derived_fact_class'].'|'.$payload['protected_use_scope'];
        $lifecycleBasis = [
            'record_family' => InMemoryLogicalPersistenceRepositoryContract::RECORD_FAMILY_PRODUCT_CONNECTION,
            'authority_owner' => 'PRODUCT_CONNECTION_DERIVATION',
            'actor' => 'PRODUCT_CONNECTION_DERIVATION',
            'actor_role' => 'DERIVED_NON_AUTHORITATIVE_CORRELATION',
            'connection_identity' => $payload['connection_identity'],
            'protected_use_scope' => $payload['protected_use_scope'],
            'subject' => $payload['connection_identity'],
            'participants' => $participants,
            'audience' => 'INTERNAL_APPLICATION_PERSISTENCE',
            'purpose' => $payload['protected_use_scope'],
            'aggregate_context' => $payload['connection_identity'],
        ];
        $bindings = [
            'authority_owner' => 'PRODUCT_CONNECTION_DERIVATION',
            'authority_scope' => $scope,
            'actor' => 'PRODUCT_CONNECTION_DERIVATION',
            'actor_role' => 'DERIVED_NON_AUTHORITATIVE_CORRELATION',
            'subject' => $payload['connection_identity'],
            'participants' => $participants,
            'audience' => 'INTERNAL_APPLICATION_PERSISTENCE',
            'purpose' => $payload['protected_use_scope'],
            'aggregate_context' => $payload['connection_identity'],
            'lifecycle_identity' => 'product-connection-lifecycle-v1:'.$this->digest($lifecycleBasis),
            'terminal' => $payload['terminality']['current_state_terminal'],
        ];
        $schema = $payload['payload_kind'] === 'PRODUCT_CONNECTION_CURRENT_STATE'
            ? 'product-connection-current-state-derived-projection-v1'
            : 'product-connection-transition-derived-projection-v1';
        $semantic = [
            'record_family' => InMemoryLogicalPersistenceRepositoryContract::RECORD_FAMILY_PRODUCT_CONNECTION,
            'derived_fact_class' => $payload['derived_fact_class'],
            'bindings' => $bindings,
            'derived_projection_payload' => $payload,
            'schema_marker' => $schema,
        ];
        $digest = $this->digest($semantic);

        if (func_num_args() === 1) {
            $dependencies = array_values(array_filter([
                $payload['current_state_dependency'] ?? null,
                $payload['transition_dependency'] ?? null,
            ], static fn (mixed $dependency): bool => is_array($dependency)));
            $currentness = $dependencies === [] ? null : $this->aggregate($dependencies, 'currentness');
            $freshness = $dependencies === [] ? null : $this->aggregate($dependencies, 'freshness');
        }

        return [
            'logical_record_identity' => 'product-connection-record-v1:'.$digest,
            'record_family' => InMemoryLogicalPersistenceRepositoryContract::RECORD_FAMILY_PRODUCT_CONNECTION,
            'bindings' => $bindings,
            'source_revision' => [
                'authority_owner' => 'PRODUCT_CONNECTION_DERIVATION',
                'authority_scope' => $scope,
                'lineage' => 'product-connection-lineage-v1:'.$digest,
                'aggregate_context' => $payload['connection_identity'],
                'value' => 0,
            ],
            'source_condition' => CommonAuthorityEvidenceContract::CONDITION_PRESENT,
            'currentness' => $currentness,
            'freshness' => $freshness,
            'logical_intent' => [
                'intent_identity' => 'product-connection-intent-v1:'.$digest,
                'semantic_input' => $semantic,
            ],
            'authoritative_outcome' => CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN,
            'authoritative_outcome_metadata' => null,
            'correction_metadata' => null,
            'projection_metadata' => [
                'projection_identity' => 'product-connection-projection-v1:'.$digest,
                'represented_source_revision_value' => 0,
                'lag_classification' => match ($currentness) { true => 'CURRENT', false => 'LAGGED', null => 'UNKNOWN' },
                'projection_currentness' => $currentness,
            ],
            'transport_observation' => 'AMBIGUOUS',
            'private_fixture_extensions' => [],
            'derived_projection_payload' => $payload,
        ];
    }

    /** @param list<array<string, mixed>> $dependencies */
    private function aggregate(array $dependencies, string $field): ?bool
    {
        $values = array_column($dependencies, $field);

        if (in_array(false, $values, true)) {
            return false;
        }

        return in_array(null, $values, true) ? null : true;
    }

    private function terminal(string $state): bool
    {
        return in_array($state, ['CN_CLOSED', 'CN_DECLINED', 'CN_WITHDRAWN', 'CN_EXPIRED'], true);
    }

    private function digest(mixed $value): string
    {
        return hash('sha256', serialize($this->canonicalize($value)));
    }

    private function canonicalize(mixed $value): mixed
    {
        if (! is_array($value)) {
            return $value;
        }

        if (array_is_list($value)) {
            return array_map($this->canonicalize(...), $value);
        }

        ksort($value);

        foreach ($value as $key => $nested) {
            $value[$key] = $this->canonicalize($nested);
        }

        return $value;
    }
}
