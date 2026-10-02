<?php

namespace Tests\Unit;

use App\Domain\CommonAuthorityEvidenceContract;
use App\Domain\InMemoryLogicalPersistenceRepositoryContract as Repository;
use App\Domain\SqliteInMemoryLogicalPersistenceAdapter;
use PHPUnit\Framework\TestCase;

final class MessagingConsentPersistenceFamilyTest extends TestCase
{
    public function test_source_carried_current_state_is_stored_with_sqlite_parity_without_permission(): void
    {
        $record = $this->record();
        [$memory, $sqlite] = $this->repositories();
        self::assertSame($memory->store($record), $sqlite->store($record));
        self::assertSame(Repository::EXACT_DUPLICATE, $memory->store($record)['storage_outcome']);
        self::assertSame(Repository::EXACT_DUPLICATE, $sqlite->store($record)['storage_outcome']);
        self::assertSame($memory->readExact($record['logical_record_identity']), $sqlite->readExact($record['logical_record_identity']));
        $projection = $sqlite->privacyMinimalProjection($record['logical_record_identity'])['record'];
        self::assertSame($record['derived_projection_payload'], $projection['derived_projection_payload']);
        self::assertFalse($projection['permission']);
        self::assertFalse($projection['source_authority']);
        self::assertFalse($projection['projection_authority']);
        self::assertFalse($projection['substitute_writer']);
        self::assertSame('UNKNOWN', $projection['authoritative_outcome']);
        self::assertSame($memory->resolveCurrent($this->query($record)), $sqlite->resolveCurrent($this->query($record)));
    }

    public function test_exact_shape_binding_and_context_mutations_are_rejected_by_both_repositories(): void
    {
        $valid = $this->record();
        $bad = [];
        $item = $valid;
        $item['extra'] = true;
        $bad[] = $item;
        $item = $valid;
        unset($item['bindings']['authority_owner']);
        $bad[] = $item;
        $item = $valid;
        $item['bindings']['owner'] = $item['bindings']['authority_owner'];
        unset($item['bindings']['authority_owner']);
        $bad[] = $item;
        $item = $valid;
        $item['source_revision']['value'] = '7';
        $bad[] = $item;
        $item = $valid;
        $item['derived_projection_payload']['extra'] = 1;
        $bad[] = $item;
        $item = $valid;
        $item['derived_projection_payload']['consent_state_dependency']['required_bindings']['purpose'] = 'CONVERSATION_LIVE_SEND';
        $bad[] = $item;
        $item = $valid;
        $item['derived_projection_payload']['participant_references'][1] = 'synthetic-other';
        $bad[] = $item;
        $item = $valid;
        $item['derived_projection_payload']['connection_identity'] = 'synthetic-other-connection';
        $bad[] = $item;
        $item = $valid;
        $item['derived_projection_payload']['requester'] = 'synthetic-participant-b';
        $bad[] = $item;
        $item = $valid;
        $item['derived_projection_payload']['purpose'] = 'CONVERSATION_LIVE_SEND';
        $bad[] = $item;
        $item = $valid;
        $item['derived_projection_payload']['classification'] = 'MC_PAUSED';
        $bad[] = $item;
        $item = $valid;
        $item['derived_projection_payload']['consent_state_dependency'] = null;
        $bad[] = $item;

        foreach ($bad as $record) {
            foreach ($this->repositories() as $repository) {
                self::assertSame(Repository::INVALID_RECORD_REJECTED, $repository->store($record)['storage_outcome']);
            }
        }
    }

    public function test_unknown_stale_and_changed_identity_fail_closed(): void
    {
        foreach ([
            [CommonAuthorityEvidenceContract::CONDITION_UNKNOWN, null, null],
            [CommonAuthorityEvidenceContract::CONDITION_STALE, false, false],
        ] as [$condition, $currentness, $freshness]) {
            $record = $this->record(condition: $condition, currentness: $currentness, freshness: $freshness);
            foreach ($this->repositories() as $repository) {
                $result = $repository->store($record);
                self::assertSame(Repository::STORED_NEW, $result['storage_outcome'], json_encode($result));
                self::assertNotSame(Repository::RESOLVED, $repository->resolveCurrent($this->query($record))['resolution']);
            }
        }

        foreach ($this->repositories() as $repository) {
            self::assertSame(Repository::STORED_NEW, $repository->store($this->record())['storage_outcome']);
            self::assertSame(
                Repository::CHANGED_INPUT_REUSE_REJECTED,
                $repository->store($this->record(state: 'MC_PENDING'))['storage_outcome'],
            );
        }
    }

    public function test_missing_connection_dependency_is_unknown_and_not_current(): void
    {
        $record = $this->record(missingConnection: true);
        foreach ($this->repositories() as $repository) {
            self::assertSame(Repository::STORED_NEW, $repository->store($record)['storage_outcome']);
            self::assertSame(Repository::UNKNOWN, $repository->resolveCurrent($this->query($record))['resolution']);
            self::assertFalse($repository->readExact($record['logical_record_identity'])['record']['permission']);
        }
    }

    public function test_unknown_current_state_cannot_disagree_with_its_source(): void
    {
        $record = $this->record(condition: CommonAuthorityEvidenceContract::CONDITION_UNKNOWN, currentness: null, freshness: null);
        $record['derived_projection_payload']['current_state'] = 'MC_PENDING';
        foreach ($this->repositories() as $repository) {
            self::assertSame(Repository::INVALID_RECORD_REJECTED, $repository->store($record)['storage_outcome']);
        }
    }

    public function test_transition_is_unknown_only_and_cannot_self_report_a_usable_result(): void
    {
        foreach ($this->repositories() as $repository) {
            $unknown = $this->transitionRecord();
            self::assertSame(Repository::STORED_NEW, $repository->store($unknown)['storage_outcome']);
            self::assertFalse($repository->readExact($unknown['logical_record_identity'])['record']['permission']);
        }

        foreach ([
            $this->transitionRecord(classification: 'ADMISSIBLE'),
            $this->transitionRecord(classification: 'REJECTED'),
            $this->transitionRecord(from: 'MC_NONE', to: 'MC_ACTIVE', classification: 'ADMISSIBLE'),
            $this->transitionRecord(from: 'MC_REVOKED', to: 'MC_PENDING', classification: 'ADMISSIBLE'),
            $this->transitionRecord(actor: 'synthetic-outsider'),
            $this->transitionRecord(actor: 'synthetic-participant-b', classification: 'ADMISSIBLE'),
        ] as $record) {
            foreach ($this->repositories() as $repository) {
                self::assertSame(Repository::INVALID_RECORD_REJECTED, $repository->store($record)['storage_outcome']);
            }
        }
    }

    public function test_revision_conflict_out_of_order_incomparable_and_terminal_reopen(): void
    {
        foreach ($this->repositories() as $repository) {
            $newest = $this->record(revision: 9, event: 'event-new');
            self::assertSame(Repository::STORED_NEW, $repository->store($newest)['storage_outcome']);
            self::assertSame(
                Repository::CONFLICTING_EQUAL_REVISION_REJECTED,
                $repository->store($this->record(revision: 9, event: 'event-conflict'))['storage_outcome'],
            );
            self::assertSame(Repository::STORED_NEW, $repository->store($this->record(revision: 8, event: 'event-old'))['storage_outcome']);
            self::assertSame(9, $repository->resolveCurrent($this->query($newest))['record']['source_revision_value']);
            self::assertSame(
                Repository::INCOMPARABLE_COEXISTS,
                $repository->store($this->record(revision: 10, event: 'event-other-lineage', sourceLineage: 'other-lineage'))['storage_outcome'],
            );
            $query = $this->query($newest);
            $query['lineage'] = null;
            self::assertSame(Repository::INCOMPARABLE, $repository->resolveCurrent($query)['resolution']);
        }

        foreach ($this->repositories() as $repository) {
            $terminal = $this->record(state: 'MC_REVOKED', revision: 9, event: 'event-terminal');
            self::assertSame(Repository::STORED_NEW, $repository->store($terminal)['storage_outcome']);
            self::assertSame(
                Repository::INVALID_RECORD_REJECTED,
                $repository->store($this->record(state: 'MC_PENDING', revision: 10, event: 'event-reopen'))['storage_outcome'],
            );
            self::assertSame(
                Repository::INCOMPARABLE_COEXISTS,
                $repository->store($this->record(state: 'MC_PENDING', revision: 1, event: 'event-new-consent', consentIdentity: 'new-consent'))['storage_outcome'],
            );
        }
    }

    public function test_invalidation_preserves_typed_payload_and_transport_is_not_commit(): void
    {
        foreach ($this->repositories() as $repository) {
            $record = $this->record();
            self::assertSame(Repository::STORED_NEW, $repository->store($record)['storage_outcome']);
            $id = $record['logical_record_identity'];
            self::assertSame(
                Repository::INVALIDATED,
                $repository->observeInvalidation($id, CommonAuthorityEvidenceContract::INVALIDATION_SUPERSESSION)['resolution'],
            );
            self::assertSame(Repository::INVALIDATED, $repository->resolveCurrent($this->query($record))['resolution']);
            $projection = $repository->readExact($id)['record'];
            self::assertTrue($projection['projection_invalidated']);
            self::assertSame($record['derived_projection_payload'], $projection['derived_projection_payload']);
            self::assertFalse($projection['permission']);
            self::assertSame('UNKNOWN', $projection['transport_authoritative_outcome']);
        }
    }

    /** @return array{Repository, SqliteInMemoryLogicalPersistenceAdapter} */
    private function repositories(): array
    {
        return [new Repository(), new SqliteInMemoryLogicalPersistenceAdapter()];
    }

    /** @return array<string, mixed> */
    private function record(
        string $state = 'MC_ACTIVE',
        int $revision = 7,
        string $event = 'event-a',
        string $sourceLineage = 'mc-source-lineage',
        string $consentIdentity = 'synthetic-consent',
        string $condition = CommonAuthorityEvidenceContract::CONDITION_PRESENT,
        ?bool $currentness = true,
        ?bool $freshness = true,
        bool $missingConnection = false,
    ): array {
        $family = Repository::RECORD_FAMILY_MESSAGING_CONSENT;
        $purpose = 'CONVERSATION_LIVE_READ';
        $kind = 'MC_CURRENT_STATE';
        $participants = ['synthetic-participant-a', 'synthetic-participant-b'];
        $connection = $this->dependency('CN_ACTIVE', 'synthetic-connection', 'cn-source-lineage', 5, 'cn-event', 'SYNTHETIC_CN', 'SYNTHETIC_CN_USE', $participants);
        $consent = $this->dependency($state, $consentIdentity, $sourceLineage, $revision, $event, 'SYNTHETIC_MC', $purpose, $participants);
        $consent['required_bindings']['subject'] = 'synthetic-connection';
        $consent['source_condition'] = $condition;
        $consent['currentness'] = $currentness;
        $consent['freshness'] = $freshness;
        $payload = [
            'schema_marker' => 'mc-source-state-correlation-v1',
            'payload_kind' => $kind,
            'consent_identity' => $consentIdentity,
            'connection_identity' => 'synthetic-connection',
            'participant_references' => $participants,
            'requester' => $participants[0],
            'recipient' => $participants[1],
            'purpose' => $purpose,
            'classification' => $condition === CommonAuthorityEvidenceContract::CONDITION_PRESENT && $currentness === true && $freshness === true ? $state : 'UNKNOWN',
            'current_state' => $state,
            'proposed_state' => null,
            'reason_categories' => $condition === CommonAuthorityEvidenceContract::CONDITION_PRESENT && $currentness === true && $freshness === true ? [] : ['SOURCE_CONDITION_NOT_PRESENT'],
            'connection_dependency' => $missingConnection ? null : $connection,
            'consent_state_dependency' => $consent,
            'transition_dependency' => null,
            'terminality' => [
                'current_state_terminal' => in_array($state, ['MC_DECLINED', 'MC_WITHDRAWN', 'MC_REVOKED'], true),
                'proposed_state_terminal' => false,
                'terminal_reopen_rejected' => false,
            ],
            'invalidation' => [
                'invalidated' => false, 'relation' => null, 'dependency_identity' => null,
                'lifecycle_reset' => false, 'consent_reopened' => false,
            ],
        ];
        $scope = $family.'|'.$kind.'|'.$purpose;
        $bindings = [
            'authority_owner' => 'MC_DERIVATION', 'authority_scope' => $scope,
            'actor' => 'MC_DERIVATION', 'actor_role' => 'DERIVED_NON_AUTHORITATIVE_CORRELATION',
            'subject' => 'synthetic-connection', 'participants' => $participants,
            'audience' => 'INTERNAL_APPLICATION_PERSISTENCE', 'purpose' => $purpose,
            'aggregate_context' => $consentIdentity, 'lifecycle_identity' => $consentIdentity,
            'terminal' => $payload['terminality']['current_state_terminal'],
        ];
        $intentIdentity = 'mc-intent-v1:'.$this->fingerprint([$kind, $event]);
        $recordIdentity = 'mc-record-v1:'.$this->fingerprint([$family, $kind, $intentIdentity]);
        $sourceRevision = [
            'authority_owner' => 'MC_DERIVATION', 'authority_scope' => $scope,
            'lineage' => 'mc-lineage-v1:'.$this->fingerprint([$consentIdentity, $purpose, $kind, $sourceLineage]),
            'aggregate_context' => $consentIdentity, 'value' => $revision,
        ];
        $semantic = ['record_family' => $family, 'bindings' => $bindings, 'derived_projection_payload' => $payload];
        $projectedCondition = $missingConnection || $condition !== CommonAuthorityEvidenceContract::CONDITION_PRESENT
            ? CommonAuthorityEvidenceContract::CONDITION_UNKNOWN
            : CommonAuthorityEvidenceContract::CONDITION_PRESENT;
        $projectedCurrentness = $missingConnection ? null : $currentness;
        $projectedFreshness = $missingConnection ? null : $freshness;
        if ($missingConnection) {
            $payload['classification'] = 'UNKNOWN';
            $payload['reason_categories'] = ['CONNECTION_CONTEXT_NOT_CURRENT_FRESH_BOUND'];
            $semantic['derived_projection_payload'] = $payload;
        }
        $lag = match ($projectedCurrentness) { true => 'CURRENT', false => 'LAGGED', null => 'UNKNOWN' };

        return [
            'logical_record_identity' => $recordIdentity,
            'record_family' => $family,
            'bindings' => $bindings,
            'source_revision' => $sourceRevision,
            'source_condition' => $projectedCondition,
            'currentness' => $projectedCurrentness,
            'freshness' => $projectedFreshness,
            'logical_intent' => ['intent_identity' => $intentIdentity, 'semantic_input' => $semantic],
            'authoritative_outcome' => 'UNKNOWN',
            'authoritative_outcome_metadata' => null,
            'correction_metadata' => null,
            'projection_metadata' => [
                'projection_identity' => 'mc-projection-v1:'.$this->fingerprint($recordIdentity),
                'represented_source_revision_value' => $revision,
                'lag_classification' => $lag,
                'projection_currentness' => $projectedCurrentness,
            ],
            'transport_observation' => 'AMBIGUOUS',
            'private_fixture_extensions' => [],
            'derived_projection_payload' => $payload,
        ];
    }

    /** @param list<string> $participants @return array<string, mixed> */
    private function dependency(string $state, string $context, string $lineage, int $revision, string $event, string $owner, string $purpose, array $participants): array
    {
        $bindings = [
            'authority_owner' => $owner, 'authority_scope' => $owner.'_SCOPE',
            'actor' => $owner, 'actor_role' => 'SYNTHETIC_SOURCE',
            'subject' => $context, 'participants' => $participants,
            'audience' => 'SYNTHETIC_AUDIENCE', 'purpose' => $purpose,
            'aggregate_context' => $context, 'lifecycle_identity' => $context,
            'terminal' => in_array($state, ['MC_DECLINED', 'MC_WITHDRAWN', 'MC_REVOKED'], true),
        ];

        return [
            'evidence_identity' => $event,
            'required_bindings' => $bindings,
            'source_revision' => [
                'authority_owner' => $owner, 'authority_scope' => $owner.'_SCOPE',
                'lineage' => $lineage, 'aggregate_context' => $context, 'value' => $revision,
            ],
            'state' => $state,
            'source_condition' => 'PRESENT',
            'currentness' => true,
            'freshness' => true,
            'protected_binding_satisfied' => true,
        ];
    }

    /** @return array<string, mixed> */
    private function transitionRecord(
        string $from = 'MC_NONE',
        string $to = 'MC_PENDING',
        string $actor = 'synthetic-participant-a',
        string $classification = 'UNKNOWN',
    ): array {
        $record = $this->record(state: $from, event: 'state-event');
        $payload = $record['derived_projection_payload'];
        $kind = 'MC_TRANSITION';
        $purpose = $payload['purpose'];
        $family = $record['record_family'];
        $consentIdentity = $payload['consent_identity'];
        $sourceLineage = 'mc-transition-lineage';
        $transition = $this->dependency($from, $consentIdentity, $sourceLineage, 8, 'transition-event', 'SYNTHETIC_MC', $purpose, $payload['participant_references']);
        $transition['required_bindings']['subject'] = $payload['connection_identity'];
        $transition['required_bindings']['actor'] = $actor;
        $transition['transition_identity'] = 'transition-event';
        $transition['actor'] = $actor;
        $transition['from_state'] = $from;
        $transition['to_state'] = $to;
        $transition['expected_state_revision'] = $payload['consent_state_dependency']['source_revision'];
        $payload['schema_marker'] = 'mc-transition-derivation-v1';
        $payload['payload_kind'] = $kind;
        $payload['classification'] = $classification;
        $payload['transition_dependency'] = $transition;
        $payload['proposed_state'] = $to;
        $payload['terminality']['proposed_state_terminal'] = in_array($to, ['MC_DECLINED', 'MC_WITHDRAWN', 'MC_REVOKED'], true);
        $payload['reason_categories'] = in_array($from, ['MC_DECLINED', 'MC_WITHDRAWN', 'MC_REVOKED'], true)
            ? ['TERMINAL_CONSENT_IDENTITY_CANNOT_REOPEN'] : [];
        $payload['terminality']['terminal_reopen_rejected'] = $payload['reason_categories'] !== [];
        $record['derived_projection_payload'] = $payload;
        $scope = $family.'|'.$kind.'|'.$purpose;
        $record['bindings']['authority_scope'] = $scope;
        $record['source_revision']['authority_scope'] = $scope;
        $record['source_revision']['lineage'] = 'mc-lineage-v1:'.$this->fingerprint([$consentIdentity, $purpose, $kind, $sourceLineage]);
        $record['source_revision']['value'] = 8;
        $intentIdentity = 'mc-intent-v1:'.$this->fingerprint([$kind, 'transition-event']);
        $record['logical_intent']['intent_identity'] = $intentIdentity;
        $record['logical_intent']['semantic_input'] = [
            'record_family' => $family, 'bindings' => $record['bindings'], 'derived_projection_payload' => $payload,
        ];
        $record['logical_record_identity'] = 'mc-record-v1:'.$this->fingerprint([$family, $kind, $intentIdentity]);
        $record['projection_metadata']['projection_identity'] = 'mc-projection-v1:'.$this->fingerprint($record['logical_record_identity']);
        $record['projection_metadata']['represented_source_revision_value'] = 8;

        return $record;
    }

    /** @param array<string, mixed> $record @return array<string, mixed> */
    private function query(array $record): array
    {
        return [
            'record_family' => $record['record_family'],
            'authority_owner' => $record['bindings']['authority_owner'],
            'authority_scope' => $record['bindings']['authority_scope'],
            'aggregate_context' => $record['bindings']['aggregate_context'],
            'lineage' => $record['source_revision']['lineage'],
        ];
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
            return array_map($this->canonicalize(...), $value);
        }
        ksort($value);
        foreach ($value as $key => $nested) {
            $value[$key] = $this->canonicalize($nested);
        }

        return $value;
    }
}
