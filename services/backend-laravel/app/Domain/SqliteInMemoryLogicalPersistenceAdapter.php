<?php

namespace App\Domain;

use InvalidArgumentException;
use PDO;

final class SqliteInMemoryLogicalPersistenceAdapter
{
    private const DSN = 'sqlite::memory:';

    private PDO $pdo;

    public function __construct()
    {
        $this->pdo = new PDO(self::DSN, null, null, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_STRINGIFY_FETCHES => false,
        ]);

        $this->pdo->exec(<<<'SQL'
            CREATE TABLE logical_records (
                logical_record_identity TEXT PRIMARY KEY,
                record_family TEXT NOT NULL,
                authority_owner TEXT NOT NULL,
                authority_scope TEXT NOT NULL,
                aggregate_context TEXT NOT NULL,
                source_lineage TEXT NOT NULL,
                source_revision_value INTEGER NOT NULL,
                lifecycle_identity TEXT NOT NULL,
                terminal INTEGER NOT NULL,
                intent_identity TEXT NOT NULL,
                input_fingerprint TEXT NOT NULL,
                intent_fingerprint TEXT NOT NULL,
                payload TEXT NOT NULL
            )
            SQL);

        $this->pdo->exec(<<<'SQL'
            CREATE TABLE logical_invalidations (
                logical_record_identity TEXT PRIMARY KEY,
                relation TEXT NOT NULL
            )
            SQL);
    }

    /**
     * @param array<string, mixed> $record
     * @return array<string, mixed>
     */
    public function store(array $record): array
    {
        $validator = new InMemoryLogicalPersistenceRepositoryContract();
        $validation = $validator->store($record);

        if (($validation['storage_outcome'] ?? null) !== InMemoryLogicalPersistenceRepositoryContract::STORED_NEW) {
            return $validation;
        }

        if (($record['record_family'] ?? null) !== InMemoryLogicalPersistenceRepositoryContract::RECORD_FAMILY_RR03) {
            unset($record['derived_projection_payload']);
        }

        $identity = $record['logical_record_identity'];
        $inputFingerprint = $this->fingerprint($record);
        $intentIdentity = $record['logical_intent']['intent_identity'];
        $intentFingerprint = $this->fingerprint([
            'record_family' => $record['record_family'],
            'bindings' => $record['bindings'],
            'source_revision' => $record['source_revision'],
            'logical_intent_semantic_input' => $record['logical_intent']['semantic_input'],
        ]);

        $existing = $this->rowForIdentity($identity);

        if ($existing !== null) {
            if ($existing['input_fingerprint'] === $inputFingerprint) {
                return $this->storageResult(
                    InMemoryLogicalPersistenceRepositoryContract::EXACT_DUPLICATE,
                    false,
                    'EXACT_LOGICAL_IDENTITY_AND_SEMANTIC_INPUT',
                    $identity,
                    true,
                );
            }

            $existingRecord = $this->decode($existing['payload']);

            if (($existingRecord['logical_intent']['intent_identity'] ?? null) === $intentIdentity) {
                return $this->storageResult(
                    InMemoryLogicalPersistenceRepositoryContract::CHANGED_INPUT_REUSE_REJECTED,
                    false,
                    'LOGICAL_IDENTITY_REUSED_WITH_CHANGED_SEMANTIC_INPUT',
                    $identity,
                );
            }

            return $this->storageResult(
                InMemoryLogicalPersistenceRepositoryContract::INVALID_RECORD_REJECTED,
                false,
                'LOGICAL_RECORD_IDENTITY_REUSE_REJECTED',
                $identity,
            );
        }

        $intentStatement = $this->pdo->prepare(<<<'SQL'
            SELECT logical_record_identity, intent_fingerprint
            FROM logical_records
            WHERE intent_identity = :intent_identity
            LIMIT 1
            SQL);
        $intentStatement->execute(['intent_identity' => $intentIdentity]);
        $registeredIntent = $intentStatement->fetch();

        if (is_array($registeredIntent)) {
            if ($registeredIntent['intent_fingerprint'] !== $intentFingerprint) {
                return $this->storageResult(
                    InMemoryLogicalPersistenceRepositoryContract::CHANGED_INPUT_REUSE_REJECTED,
                    false,
                    'IMMUTABLE_INTENT_CHANGED_INPUT',
                    $identity,
                );
            }

            return $this->storageResult(
                InMemoryLogicalPersistenceRepositoryContract::INVALID_RECORD_REJECTED,
                false,
                'INTENT_IDENTITY_REUSED_FOR_DIFFERENT_LOGICAL_RECORD',
                $identity,
            );
        }

        if (($record['bindings']['terminal'] ?? null) !== true) {
            $terminalStatement = $this->pdo->prepare(<<<'SQL'
                SELECT 1
                FROM logical_records
                WHERE lifecycle_identity = :lifecycle_identity AND terminal = 1
                LIMIT 1
                SQL);
            $terminalStatement->execute([
                'lifecycle_identity' => $record['bindings']['lifecycle_identity'],
            ]);

            if ($terminalStatement->fetchColumn() !== false) {
                return $this->storageResult(
                    InMemoryLogicalPersistenceRepositoryContract::INVALID_RECORD_REJECTED,
                    false,
                    'TERMINAL_IDENTITY_REOPEN_REJECTED',
                    $identity,
                );
            }
        }

        $familyStatement = $this->pdo->prepare(<<<'SQL'
            SELECT payload
            FROM logical_records
            WHERE record_family = :record_family
            SQL);
        $familyStatement->execute(['record_family' => $record['record_family']]);
        $incomparableExists = false;

        while (($row = $familyStatement->fetch()) !== false) {
            $stored = $this->decode($row['payload']);
            $comparison = CommonAuthorityEvidenceContract::compareSourceRevisions(
                $stored['source_revision'],
                $record['source_revision'],
            );

            if ($comparison === CommonAuthorityEvidenceContract::REVISION_EQUAL) {
                return $this->storageResult(
                    InMemoryLogicalPersistenceRepositoryContract::CONFLICTING_EQUAL_REVISION_REJECTED,
                    false,
                    'EQUAL_SOURCE_LOCAL_REVISION_WITH_CONFLICTING_RECORD',
                    $identity,
                );
            }

            if ($comparison === CommonAuthorityEvidenceContract::CONDITION_INCOMPARABLE) {
                $incomparableExists = true;
            }
        }

        $insert = $this->pdo->prepare(<<<'SQL'
            INSERT INTO logical_records (
                logical_record_identity,
                record_family,
                authority_owner,
                authority_scope,
                aggregate_context,
                source_lineage,
                source_revision_value,
                lifecycle_identity,
                terminal,
                intent_identity,
                input_fingerprint,
                intent_fingerprint,
                payload
            ) VALUES (
                :logical_record_identity,
                :record_family,
                :authority_owner,
                :authority_scope,
                :aggregate_context,
                :source_lineage,
                :source_revision_value,
                :lifecycle_identity,
                :terminal,
                :intent_identity,
                :input_fingerprint,
                :intent_fingerprint,
                :payload
            )
            SQL);
        $insert->execute([
            'logical_record_identity' => $identity,
            'record_family' => $record['record_family'],
            'authority_owner' => $record['bindings']['authority_owner'],
            'authority_scope' => $record['bindings']['authority_scope'],
            'aggregate_context' => $record['bindings']['aggregate_context'],
            'source_lineage' => $record['source_revision']['lineage'],
            'source_revision_value' => $record['source_revision']['value'],
            'lifecycle_identity' => $record['bindings']['lifecycle_identity'],
            'terminal' => $record['bindings']['terminal'] ? 1 : 0,
            'intent_identity' => $intentIdentity,
            'input_fingerprint' => $inputFingerprint,
            'intent_fingerprint' => $intentFingerprint,
            'payload' => $this->encode($record),
        ]);

        return $this->storageResult(
            $incomparableExists
                ? InMemoryLogicalPersistenceRepositoryContract::INCOMPARABLE_COEXISTS
                : InMemoryLogicalPersistenceRepositoryContract::STORED_NEW,
            true,
            $incomparableExists
                ? 'INCOMPARABLE_SOURCE_LOCAL_RECORDS_RETAINED'
                : 'NEW_LOGICAL_RECORD_STORED',
            $identity,
        );
    }

    /** @return array<string, mixed> */
    public function readExact(string $logicalRecordIdentity): array
    {
        $row = $this->rowForIdentity($logicalRecordIdentity);

        if ($row === null) {
            return $this->readResult(
                InMemoryLogicalPersistenceRepositoryContract::MISSING,
                null,
                'LOGICAL_RECORD_IDENTITY_NOT_FOUND',
            );
        }

        return $this->readResult(
            InMemoryLogicalPersistenceRepositoryContract::FOUND,
            $this->project($this->decode($row['payload'])),
            'EXACT_LOGICAL_RECORD_IDENTITY_FOUND',
        );
    }

    /**
     * @param array<string, mixed> $query
     * @return array<string, mixed>
     */
    public function resolveCurrent(array $query): array
    {
        if (! $this->validQuery($query, false)) {
            return $this->resolutionResult(
                InMemoryLogicalPersistenceRepositoryContract::UNKNOWN,
                null,
                'INVALID_EXACT_CONTEXT_QUERY',
            );
        }

        $candidates = $this->recordsForContext($query);

        if ($candidates === []) {
            return $this->resolutionResult(
                InMemoryLogicalPersistenceRepositoryContract::MISSING,
                null,
                'EXACT_LOGICAL_CONTEXT_NOT_FOUND',
            );
        }

        $lineage = $query['lineage'];

        if ($lineage === null) {
            $lineages = array_values(array_unique(array_map(
                static fn (array $record): string => $record['source_revision']['lineage'],
                $candidates,
            )));

            if (count($lineages) !== 1) {
                return $this->resolutionResult(
                    InMemoryLogicalPersistenceRepositoryContract::INCOMPARABLE,
                    null,
                    'MULTIPLE_INCOMPARABLE_LINEAGES_REQUIRE_EXACT_LINEAGE',
                );
            }

            $lineage = $lineages[0];
        }

        $candidates = array_values(array_filter(
            $candidates,
            static fn (array $record): bool => $record['source_revision']['lineage'] === $lineage,
        ));

        if ($candidates === []) {
            return $this->resolutionResult(
                InMemoryLogicalPersistenceRepositoryContract::MISSING,
                null,
                'EXACT_SOURCE_LOCAL_LINEAGE_NOT_FOUND',
            );
        }

        $this->sortBySourceRevision($candidates);
        $selected = $candidates[array_key_last($candidates)];
        $projection = $this->project($selected);

        if ($this->invalidationRelation($selected['logical_record_identity']) !== null) {
            return $this->resolutionResult(
                InMemoryLogicalPersistenceRepositoryContract::INVALIDATED,
                $projection,
                'DEPENDENCY_OR_PROJECTION_INVALIDATED',
            );
        }

        $conditionResolution = match ($selected['source_condition']) {
            CommonAuthorityEvidenceContract::CONDITION_PRESENT => null,
            CommonAuthorityEvidenceContract::CONDITION_ABSENT => InMemoryLogicalPersistenceRepositoryContract::ABSENT,
            CommonAuthorityEvidenceContract::CONDITION_UNKNOWN => InMemoryLogicalPersistenceRepositoryContract::UNKNOWN,
            CommonAuthorityEvidenceContract::CONDITION_UNAVAILABLE => InMemoryLogicalPersistenceRepositoryContract::UNAVAILABLE,
            CommonAuthorityEvidenceContract::CONDITION_STALE => InMemoryLogicalPersistenceRepositoryContract::STALE,
            CommonAuthorityEvidenceContract::CONDITION_SUPERSEDED => InMemoryLogicalPersistenceRepositoryContract::SUPERSEDED,
            CommonAuthorityEvidenceContract::CONDITION_INCOMPARABLE => InMemoryLogicalPersistenceRepositoryContract::INCOMPARABLE,
        };

        if ($conditionResolution !== null) {
            return $this->resolutionResult(
                $conditionResolution,
                $projection,
                'SOURCE_CONDITION_'.$selected['source_condition'],
            );
        }

        if ($selected['currentness'] !== true) {
            return $this->resolutionResult(
                InMemoryLogicalPersistenceRepositoryContract::UNKNOWN,
                $projection,
                'SOURCE_CURRENTNESS_NOT_ESTABLISHED',
            );
        }

        if ($selected['freshness'] !== true) {
            return $this->resolutionResult(
                InMemoryLogicalPersistenceRepositoryContract::STALE,
                $projection,
                'SOURCE_FRESHNESS_NOT_ESTABLISHED',
            );
        }

        return $this->resolutionResult(
            InMemoryLogicalPersistenceRepositoryContract::RESOLVED,
            $projection,
            'EXACT_COMPARABLE_RECORD_RESOLVED',
        );
    }

    /**
     * @param array<string, mixed> $query
     * @return array<string, mixed>
     */
    public function readHistory(array $query): array
    {
        if (! $this->validQuery($query, true)) {
            return array_merge($this->readResult(
                InMemoryLogicalPersistenceRepositoryContract::UNKNOWN,
                null,
                'INVALID_EXACT_LINEAGE_QUERY',
            ), ['records' => []]);
        }

        $records = array_values(array_filter(
            $this->recordsForContext($query),
            static fn (array $record): bool => $record['source_revision']['lineage'] === $query['lineage'],
        ));
        $this->sortBySourceRevision($records);

        if ($records === []) {
            return array_merge($this->readResult(
                InMemoryLogicalPersistenceRepositoryContract::MISSING,
                null,
                'EXACT_SOURCE_LOCAL_HISTORY_NOT_FOUND',
            ), ['records' => []]);
        }

        return array_merge($this->readResult(
            InMemoryLogicalPersistenceRepositoryContract::RESOLVED,
            null,
            'EXACT_SOURCE_LOCAL_HISTORY_RESOLVED',
        ), [
            'records' => array_map(fn (array $record): array => $this->project($record), $records),
        ]);
    }

    /** @return array<string, mixed> */
    public function observeInvalidation(string $logicalRecordIdentity, string $relation): array
    {
        $row = $this->rowForIdentity($logicalRecordIdentity);

        if ($row === null) {
            return $this->readResult(
                InMemoryLogicalPersistenceRepositoryContract::MISSING,
                null,
                'INVALIDATION_TARGET_NOT_FOUND',
            );
        }

        $record = $this->decode($row['payload']);

        try {
            $invalidation = CommonAuthorityEvidenceContract::invalidate(
                CommonAuthorityEvidenceContract::evidence(
                    $record['bindings'],
                    $record['source_condition'],
                    $record['source_revision'],
                    $record['currentness'],
                    $record['freshness'],
                    $record['authoritative_outcome'],
                ),
                $relation,
            );
        } catch (InvalidArgumentException) {
            return $this->readResult(
                InMemoryLogicalPersistenceRepositoryContract::UNKNOWN,
                null,
                'INVALID_INVALIDATION_RELATION',
            );
        }

        $statement = $this->pdo->prepare(<<<'SQL'
            INSERT INTO logical_invalidations (logical_record_identity, relation)
            VALUES (:logical_record_identity, :relation)
            ON CONFLICT(logical_record_identity) DO UPDATE SET relation = excluded.relation
            SQL);
        $statement->execute([
            'logical_record_identity' => $logicalRecordIdentity,
            'relation' => $relation,
        ]);

        return $this->readResult(
            InMemoryLogicalPersistenceRepositoryContract::INVALIDATED,
            $this->project($record),
            'DEPENDENT_PROJECTION_INVALIDATED_WITHOUT_LIFECYCLE_RESET',
        );
    }

    /** @return array<string, mixed> */
    public function privacyMinimalProjection(string $logicalRecordIdentity): array
    {
        $row = $this->rowForIdentity($logicalRecordIdentity);

        if ($row === null) {
            return $this->readResult(
                InMemoryLogicalPersistenceRepositoryContract::MISSING,
                null,
                'PROJECTION_SOURCE_NOT_FOUND',
            );
        }

        return $this->readResult(
            InMemoryLogicalPersistenceRepositoryContract::FOUND,
            $this->project($this->decode($row['payload'])),
            'PRIVACY_MINIMAL_NON_AUTHORITATIVE_PROJECTION',
        );
    }

    public function count(): int
    {
        return (int) $this->pdo->query('SELECT COUNT(*) FROM logical_records')->fetchColumn();
    }

    /** @return array<string, mixed> */
    public function physicalBoundaryFacts(): array
    {
        $statement = $this->pdo->query(<<<'SQL'
            SELECT name
            FROM sqlite_master
            WHERE type = 'table' AND name IN ('logical_records', 'logical_invalidations')
            ORDER BY name
            SQL);
        $tables = $statement->fetchAll(PDO::FETCH_COLUMN);

        return array_merge(self::nonAuthorityFields(), [
            'dsn' => self::DSN,
            'driver' => $this->pdo->getAttribute(PDO::ATTR_DRIVER_NAME),
            'disposable_tables' => $tables,
            'schema_initialized' => $tables === ['logical_invalidations', 'logical_records'],
            'record_count' => $this->count(),
            'persistent_database' => false,
            'rowid_exposed' => false,
            'insertion_order_authority' => false,
            'sql_execution_order_authority' => false,
            'sql_success_is_domain_success' => false,
            'row_presence_is_source_authority' => false,
            'table_existence_is_authority' => false,
            'global_revision' => false,
            'last_write_wins' => false,
            'last_received_wins' => false,
            'production_ready' => false,
            'durability_established' => false,
            'transactional' => false,
            'concurrent_safe' => false,
            'deployable' => false,
        ]);
    }

    /** @return array<string, mixed>|null */
    private function rowForIdentity(string $logicalRecordIdentity): ?array
    {
        $statement = $this->pdo->prepare(<<<'SQL'
            SELECT input_fingerprint, payload
            FROM logical_records
            WHERE logical_record_identity = :logical_record_identity
            SQL);
        $statement->execute(['logical_record_identity' => $logicalRecordIdentity]);
        $row = $statement->fetch();

        return is_array($row) ? $row : null;
    }

    /**
     * @param array<string, mixed> $query
     * @return list<array<string, mixed>>
     */
    private function recordsForContext(array $query): array
    {
        $statement = $this->pdo->prepare(<<<'SQL'
            SELECT payload
            FROM logical_records
            WHERE record_family = :record_family
              AND authority_owner = :authority_owner
              AND authority_scope = :authority_scope
              AND aggregate_context = :aggregate_context
            SQL);
        $statement->execute([
            'record_family' => $query['record_family'],
            'authority_owner' => $query['authority_owner'],
            'authority_scope' => $query['authority_scope'],
            'aggregate_context' => $query['aggregate_context'],
        ]);

        return array_map(
            fn (array $row): array => $this->decode($row['payload']),
            $statement->fetchAll(),
        );
    }

    /** @param list<array<string, mixed>> $records */
    private function sortBySourceRevision(array &$records): void
    {
        usort($records, static function (array $left, array $right): int {
            $revisionOrder = $left['source_revision']['value'] <=> $right['source_revision']['value'];

            return $revisionOrder !== 0
                ? $revisionOrder
                : $left['logical_record_identity'] <=> $right['logical_record_identity'];
        });
    }

    private function invalidationRelation(string $logicalRecordIdentity): ?string
    {
        $statement = $this->pdo->prepare(<<<'SQL'
            SELECT relation
            FROM logical_invalidations
            WHERE logical_record_identity = :logical_record_identity
            SQL);
        $statement->execute(['logical_record_identity' => $logicalRecordIdentity]);
        $relation = $statement->fetchColumn();

        return is_string($relation) ? $relation : null;
    }

    /** @param array<string, mixed> $record @return array<string, mixed> */
    private function project(array $record): array
    {
        $authoritativeMetadata = $record['authoritative_outcome_metadata'];
        $correctionMetadata = $record['correction_metadata'];
        $invalidationRelation = $this->invalidationRelation($record['logical_record_identity']);
        $derivedPayload = $record['derived_projection_payload'] ?? null;

        if ($derivedPayload !== null && $invalidationRelation !== null) {
            $derivedPayload['invalidation'] = [
                'invalidated' => true,
                'relation' => $invalidationRelation,
                'dependency_identity' => $record['logical_record_identity'],
            ];
        }

        return [
            'record_kind' => 'PRIVACY_MINIMAL_LOGICAL_PERSISTENCE_PROJECTION',
            'logical_record_identity' => $record['logical_record_identity'],
            'record_family' => $record['record_family'],
            'authority_owner' => $record['bindings']['authority_owner'],
            'authority_scope' => $record['bindings']['authority_scope'],
            'subject_reference' => $record['bindings']['subject'],
            'participant_references' => $record['bindings']['participants'],
            'audience' => $record['bindings']['audience'],
            'purpose' => $record['bindings']['purpose'],
            'aggregate_context' => $record['bindings']['aggregate_context'],
            'lifecycle_identity' => $record['bindings']['lifecycle_identity'],
            'terminal' => $record['bindings']['terminal'],
            'source_condition' => $record['source_condition'],
            'source_revision_lineage' => $record['source_revision']['lineage'],
            'source_revision_value' => $record['source_revision']['value'],
            'currentness' => $record['currentness'],
            'freshness' => $record['freshness'],
            'logical_intent_identity' => $record['logical_intent']['intent_identity'],
            'authoritative_outcome' => $record['authoritative_outcome'],
            'authoritative_outcome_source_carried' => ($authoritativeMetadata['source_carried'] ?? false) === true,
            'authoritative_outcome_reference' => $authoritativeMetadata['outcome_reference'] ?? null,
            'correction_relation' => $correctionMetadata['relation'] ?? null,
            'displaced_record_identity' => $correctionMetadata['displaced_record_identity'] ?? null,
            'projection_identity' => $record['projection_metadata']['projection_identity'],
            'represented_source_revision_value' => $record['projection_metadata']['represented_source_revision_value'],
            'projection_lag' => $record['projection_metadata']['lag_classification'],
            'projection_currentness' => $record['projection_metadata']['projection_currentness'],
            'projection_invalidated' => $invalidationRelation !== null,
            'invalidation_relation' => $invalidationRelation,
            'lifecycle_reset' => false,
            'reopened' => false,
            'new_aggregate_created' => false,
            'transition_synthesized' => false,
            'transport_observation' => $record['transport_observation'],
            'transport_authoritative_outcome' => CommonAuthorityEvidenceContract::outcomeAfterTransport(
                $record['transport_observation'],
            ),
            ...($derivedPayload === null ? [] : ['derived_projection_payload' => $derivedPayload]),
            'transport_is_domain_outcome' => false,
            'source_authority' => false,
            'projection_authority' => false,
            'permission' => false,
            'bearer_capability' => false,
            'domain_success' => false,
            'substitute_writer' => false,
        ];
    }

    /** @param array<string, mixed> $query */
    private function validQuery(array $query, bool $lineageRequired): bool
    {
        $required = ['record_family', 'authority_owner', 'authority_scope', 'aggregate_context', 'lineage'];
        $keys = array_keys($query);
        sort($keys);
        sort($required);

        if ($keys !== $required) {
            return false;
        }

        foreach (['record_family', 'authority_owner', 'authority_scope', 'aggregate_context'] as $key) {
            if (! is_string($query[$key]) || $query[$key] === '') {
                return false;
            }
        }

        if ($lineageRequired) {
            return is_string($query['lineage']) && $query['lineage'] !== '';
        }

        return $query['lineage'] === null || (is_string($query['lineage']) && $query['lineage'] !== '');
    }

    /** @return array<string, mixed> */
    private function storageResult(
        string $outcome,
        bool $stored,
        string $reason,
        ?string $identity = null,
        bool $idempotent = false,
    ): array {
        return array_merge(self::nonAuthorityFields(), [
            'record_kind' => 'LOGICAL_PERSISTENCE_STORAGE_DISPOSITION',
            'storage_outcome' => $outcome,
            'logical_record_identity' => $identity,
            'stored' => $stored,
            'idempotent_correlation' => $idempotent,
            'reason' => $reason,
        ]);
    }

    /** @param array<string, mixed>|null $record @return array<string, mixed> */
    private function readResult(string $resolution, ?array $record, string $reason): array
    {
        return array_merge(self::nonAuthorityFields(), [
            'record_kind' => 'LOGICAL_PERSISTENCE_READ_DISPOSITION',
            'resolution' => $resolution,
            'record' => $record,
            'reason' => $reason,
        ]);
    }

    /** @param array<string, mixed>|null $record @return array<string, mixed> */
    private function resolutionResult(string $resolution, ?array $record, string $reason): array
    {
        return array_merge($this->readResult($resolution, $record, $reason), [
            'source_local_revision_only' => true,
            'last_write_wins' => false,
            'last_received_wins' => false,
        ]);
    }

    /** @return array<string, false> */
    private static function nonAuthorityFields(): array
    {
        return [
            'source_authority' => false,
            'authoritative_mutation_success' => false,
            'readiness_authority' => false,
            'match_authority' => false,
            'connection_authority' => false,
            'consent_authority' => false,
            'conversation_authority' => false,
            'relationship_authority' => false,
            'home_action_authority' => false,
            'notification_delivery_authority' => false,
            'launch_authority' => false,
            'permission' => false,
            'bearer_capability' => false,
            'success' => false,
            'domain_success' => false,
            'sql_selected' => false,
            'nosql_selected' => false,
            'sqlite_selected' => false,
            'eloquent_selected' => false,
            'schema_selected' => false,
            'database_connection_selected' => false,
            'filesystem_persistence_selected' => false,
            'cache_selected' => false,
            'transaction_semantics' => false,
            'lock_semantics' => false,
            'cas_semantics' => false,
            'isolation_semantics' => false,
            'queue_semantics' => false,
            'api_semantics' => false,
        ];
    }

    /** @param array<string, mixed> $value */
    private function encode(array $value): string
    {
        return json_encode($value, JSON_THROW_ON_ERROR);
    }

    /** @return array<string, mixed> */
    private function decode(string $value): array
    {
        return json_decode($value, true, 512, JSON_THROW_ON_ERROR);
    }

    private function fingerprint(mixed $value): string
    {
        return hash('sha256', serialize($this->canonicalize($value)));
    }

    private function canonicalize(mixed $value): mixed
    {
        if (! is_array($value)) {
            return $value;
        }

        if (array_is_list($value)) {
            return array_map(fn (mixed $item): mixed => $this->canonicalize($item), $value);
        }

        ksort($value);

        foreach ($value as $key => $item) {
            $value[$key] = $this->canonicalize($item);
        }

        return $value;
    }
}
