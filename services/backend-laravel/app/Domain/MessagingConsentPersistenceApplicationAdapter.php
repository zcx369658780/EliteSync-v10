<?php

namespace App\Domain;

use InvalidArgumentException;

/** Synthetic source correlation only. No consent writer or live gate is exposed. */
final class MessagingConsentPersistenceApplicationAdapter
{
    public function __construct(
        private readonly PersistenceBoundaryApplicationInterfaceIntegrationContract $application,
    ) {}

    /** @param array<string, mixed> $request @return array<string, mixed> */
    public function correlateCurrentSynthetic(array $request): array
    {
        $record = $this->record($request);
        if ($record === null) {
            return $this->result('INPUT_NOT_BOUND', null, null, false);
        }

        // This is the sole write. The application boundary's repository validates the record.
        $submission = $this->application->submitAuthoritativeMutation($record);
        $storage = $submission['persistence']['storage_outcome'] ?? null;
        if (! in_array($storage, [
            InMemoryLogicalPersistenceRepositoryContract::STORED_NEW,
            InMemoryLogicalPersistenceRepositoryContract::EXACT_DUPLICATE,
        ], true)) {
            return $this->result('STORAGE_NOT_EXACT_CORRELATION', $record, $storage, false);
        }

        $read = $this->application->retrieveCurrentProjection($this->query($record), $this->viewer($record));
        $exact = $this->exactReadback($read, $record);
        $payload = $record['derived_projection_payload'];
        $sourceUsable = $payload['classification'] !== 'UNKNOWN'
            && $record['source_condition'] === CommonAuthorityEvidenceContract::CONDITION_PRESENT
            && $record['currentness'] === true && $record['freshness'] === true;

        return $this->result($exact && $sourceUsable ? 'EXACT_SOURCE_CORRELATION' : 'CORRELATION_NOT_USABLE',
            $record, $storage, $exact && $sourceUsable);
    }

    /** @param array<string, mixed> $request @return array<string, mixed> */
    public function invalidateCurrentSynthetic(array $request): array
    {
        $record = $this->record($request);
        $identity = $request['dependency_identity'] ?? null;
        $relation = $request['relation'] ?? null;
        if ($record === null || ! is_string($identity) || ! in_array($relation, [
            CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
            CommonAuthorityEvidenceContract::INVALIDATION_REVOCATION,
            CommonAuthorityEvidenceContract::INVALIDATION_SUPERSESSION,
        ], true)) {
            return $this->result('INVALIDATION_TARGET_NOT_BOUND', $record, null, false);
        }

        $payload = $record['derived_projection_payload'];
        $identities = [
            $payload['connection_dependency']['evidence_identity'],
            $payload['consent_state_dependency']['evidence_identity'],
        ];
        if (count(array_filter($identities, static fn (string $item): bool => $item === $identity)) !== 1) {
            return $this->result('INVALIDATION_TARGET_NOT_BOUND', $record, null, false);
        }

        $before = $this->application->retrieveCurrentProjection($this->query($record), $this->viewer($record));
        if (! $this->exactReadback($before, $record)) {
            return $this->result('INVALIDATION_RECORD_NOT_EXACT', $record, null, false);
        }

        $observation = $this->application->observeInvalidation($record['logical_record_identity'], $relation);
        $observed = ($observation['resolution'] ?? null) === InMemoryLogicalPersistenceRepositoryContract::INVALIDATED
            && ($observation['dependent_projection_invalidated'] ?? false) === true;

        return $this->result($observed ? 'EXACT_DEPENDENCY_INVALIDATED' : 'INVALIDATION_UNCONFIRMED', $record, null, false);
    }

    /** @param array<string, mixed> $request @return array<string, mixed>|null */
    private function record(array $request): ?array
    {
        $expected = ['connection', 'connection_evidence', 'consent', 'consent_evidence', 'protected_audience'];
        if (! $this->exactKeys($request, $expected) && ! $this->exactKeys($request, [...$expected, 'dependency_identity', 'relation'])) {
            return null;
        }
        $connection = $request['connection'];
        $consent = $request['consent'];
        $cn = $request['connection_evidence'];
        $mc = $request['consent_evidence'];
        $audience = $request['protected_audience'];
        if (! $this->nonEmpty($audience)
            || ! is_array($connection) || ! is_array($consent) || ! is_array($cn) || ! is_array($mc)
            || ! $this->exactKeys($connection, ['connection_identity', 'participants'])
            || ! $this->exactKeys($consent, ['consent_identity', 'connection_identity', 'participants', 'requester', 'recipient', 'purpose'])
            || ! $this->nonEmpty($connection['connection_identity'] ?? null)
            || ! $this->nonEmpty($consent['consent_identity'] ?? null)
            || ($consent['connection_identity'] ?? null) !== $connection['connection_identity']
            || ! $this->participants($connection['participants'] ?? null)
            || ($consent['participants'] ?? null) !== $connection['participants']
            || ! in_array($consent['requester'] ?? null, $connection['participants'], true)
            || ! in_array($consent['recipient'] ?? null, $connection['participants'], true)
            || $consent['requester'] === $consent['recipient']
            || ! in_array($consent['purpose'] ?? null, ['CONVERSATION_LIVE_READ', 'CONVERSATION_LIVE_SEND'], true)
            || ! $this->validEvidence($cn, $connection, $consent, $audience, true)
            || ! $this->validEvidence($mc, $connection, $consent, $audience, false)) {
            return null;
        }

        $family = InMemoryLogicalPersistenceRepositoryContract::RECORD_FAMILY_MESSAGING_CONSENT;
        $kind = 'MC_CURRENT_STATE';
        $purpose = $consent['purpose'];
        $condition = $cn['source_condition'] === $mc['source_condition']
            ? $cn['source_condition'] : CommonAuthorityEvidenceContract::CONDITION_UNKNOWN;
        $currentness = $this->aggregateBoolean($cn, $mc, 'currentness', $condition);
        $freshness = $this->aggregateBoolean($cn, $mc, 'freshness', $condition);
        $sourceUsable = $cn['state'] === 'CN_ACTIVE'
            && $condition === CommonAuthorityEvidenceContract::CONDITION_PRESENT
            && $currentness === true && $freshness === true
            && $cn['protected_binding_satisfied'] && $mc['protected_binding_satisfied'];
        $terminal = in_array($mc['state'], ['MC_DECLINED', 'MC_WITHDRAWN', 'MC_REVOKED'], true);
        $payload = [
            'schema_marker' => 'mc-source-state-correlation-v1',
            'payload_kind' => $kind,
            'consent_identity' => $consent['consent_identity'],
            'connection_identity' => $connection['connection_identity'],
            'participant_references' => $connection['participants'],
            'requester' => $consent['requester'],
            'recipient' => $consent['recipient'],
            'purpose' => $purpose,
            'classification' => $sourceUsable ? $mc['state'] : 'UNKNOWN',
            'current_state' => $mc['state'],
            'proposed_state' => null,
            'reason_categories' => $sourceUsable ? [] : ['SOURCE_NOT_CURRENT_FRESH'],
            'connection_dependency' => $cn,
            'consent_state_dependency' => $mc,
            'transition_dependency' => null,
            'terminality' => [
                'current_state_terminal' => $terminal,
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
            'subject' => $connection['connection_identity'], 'participants' => $connection['participants'],
            'audience' => 'INTERNAL_APPLICATION_PERSISTENCE', 'purpose' => $purpose,
            'aggregate_context' => $consent['consent_identity'],
            'lifecycle_identity' => $consent['consent_identity'], 'terminal' => $terminal,
        ];
        $intentIdentity = 'mc-intent-v1:'.$this->fingerprint([$kind, $mc['evidence_identity']]);
        $recordIdentity = 'mc-record-v1:'.$this->fingerprint([$family, $kind, $intentIdentity]);
        $revision = [
            'authority_owner' => 'MC_DERIVATION', 'authority_scope' => $scope,
            'lineage' => 'mc-lineage-v1:'.$this->fingerprint([
                $consent['consent_identity'], $purpose, $kind, $mc['source_revision']['lineage'],
            ]),
            'aggregate_context' => $consent['consent_identity'],
            'value' => $mc['source_revision']['value'],
        ];
        $semantic = ['record_family' => $family, 'bindings' => $bindings, 'derived_projection_payload' => $payload];

        return [
            'logical_record_identity' => $recordIdentity, 'record_family' => $family,
            'bindings' => $bindings, 'source_revision' => $revision,
            'source_condition' => $condition, 'currentness' => $currentness, 'freshness' => $freshness,
            'logical_intent' => ['intent_identity' => $intentIdentity, 'semantic_input' => $semantic],
            'authoritative_outcome' => CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN,
            'authoritative_outcome_metadata' => null, 'correction_metadata' => null,
            'projection_metadata' => [
                'projection_identity' => 'mc-projection-v1:'.$this->fingerprint($recordIdentity),
                'represented_source_revision_value' => $revision['value'],
                'lag_classification' => match ($currentness) { true => 'CURRENT', false => 'LAGGED', null => 'UNKNOWN' },
                'projection_currentness' => $currentness,
            ],
            'transport_observation' => 'AMBIGUOUS', 'private_fixture_extensions' => [],
            'derived_projection_payload' => $payload,
        ];
    }

    /** @param array<string, mixed> $evidence @param array<string, mixed> $connection @param array<string, mixed> $consent */
    private function validEvidence(array $evidence, array $connection, array $consent, string $audience, bool $isConnection): bool
    {
        if (! $this->exactKeys($evidence, [
            'evidence_identity', 'required_bindings', 'source_revision', 'state',
            'source_condition', 'currentness', 'freshness', 'protected_binding_satisfied',
        ]) || ! $this->nonEmpty($evidence['evidence_identity'] ?? null)
            || ! is_array($evidence['required_bindings'] ?? null)
            || ! is_array($evidence['source_revision'] ?? null)
            || ! is_bool($evidence['protected_binding_satisfied'] ?? null)) {
            return false;
        }
        try {
            CommonAuthorityEvidenceContract::evidence(
                $evidence['required_bindings'], $evidence['source_condition'], $evidence['source_revision'],
                $evidence['currentness'], $evidence['freshness'],
            );
        } catch (InvalidArgumentException|\TypeError) {
            return false;
        }
        $binding = $evidence['required_bindings'];
        $revision = $evidence['source_revision'];
        $context = $isConnection ? $connection['connection_identity'] : $consent['consent_identity'];
        $states = $isConnection
            ? ['CN_NONE', 'CN_PENDING', 'CN_ACTIVE', 'CN_PAUSED', 'CN_CLOSED', 'CN_DECLINED', 'CN_WITHDRAWN', 'CN_EXPIRED']
            : MessagingConsentConversationLiveGateEvaluator::lifecycleVocabulary();

        return in_array($evidence['state'] ?? null, $states, true)
            && $binding['subject'] === $connection['connection_identity']
            && $binding['participants'] === $connection['participants']
            && $binding['audience'] === $audience
            && $binding['aggregate_context'] === $context
            && $binding['lifecycle_identity'] === $context
            && ($isConnection || $binding['purpose'] === $consent['purpose'])
            && $binding['terminal'] === in_array($evidence['state'], $isConnection
                ? ['CN_CLOSED', 'CN_DECLINED', 'CN_WITHDRAWN', 'CN_EXPIRED']
                : ['MC_DECLINED', 'MC_WITHDRAWN', 'MC_REVOKED'], true)
            && $revision['authority_owner'] === $binding['authority_owner']
            && $revision['authority_scope'] === $binding['authority_scope']
            && $revision['aggregate_context'] === $context;
    }

    /** @param array<string, mixed> $left @param array<string, mixed> $right */
    private function aggregateBoolean(array $left, array $right, string $field, string $condition): ?bool
    {
        if ($left[$field] === false || $right[$field] === false) {
            return false;
        }
        if ($condition !== CommonAuthorityEvidenceContract::CONDITION_PRESENT) {
            return null;
        }
        return $left[$field] === true && $right[$field] === true ? true : null;
    }

    /** @param array<string, mixed> $record @return array<string, mixed> */
    private function query(array $record): array
    {
        return [
            'record_family' => $record['record_family'],
            'authority_owner' => $record['bindings']['authority_owner'],
            'authority_scope' => $record['bindings']['authority_scope'],
            'aggregate_context' => $record['bindings']['aggregate_context'],
            'lineage' => null,
        ];
    }

    /** @param array<string, mixed> $record @return array<string, mixed> */
    private function viewer(array $record): array
    {
        return [
            'viewer' => 'MC_DERIVATION', 'subject' => $record['bindings']['subject'],
            'participants' => $record['bindings']['participants'],
            'audience' => $record['bindings']['audience'],
            'purpose' => $record['bindings']['purpose'],
            'aggregate_context' => $record['bindings']['aggregate_context'],
        ];
    }

    /** @param array<string, mixed> $read @param array<string, mixed> $record */
    private function exactReadback(array $read, array $record): bool
    {
        $projection = $read['projection'] ?? null;
        return ($read['resolution'] ?? null) === InMemoryLogicalPersistenceRepositoryContract::RESOLVED
            && ($read['binding_classification'] ?? null) === 'EXACT'
            && is_array($projection)
            && ($projection['record_family'] ?? null) === $record['record_family']
            && ($projection['logical_record_identity'] ?? null) === $record['logical_record_identity']
            && ($projection['logical_intent_identity'] ?? null) === $record['logical_intent']['intent_identity']
            && ($projection['authority_owner'] ?? null) === 'MC_DERIVATION'
            && ($projection['authority_scope'] ?? null) === $record['bindings']['authority_scope']
            && ($projection['source_revision_lineage'] ?? null) === $record['source_revision']['lineage']
            && ($projection['source_revision_value'] ?? null) === $record['source_revision']['value']
            && ($projection['aggregate_context'] ?? null) === $record['bindings']['aggregate_context']
            && ($projection['participant_references'] ?? null) === $record['bindings']['participants']
            && ($projection['purpose'] ?? null) === $record['bindings']['purpose']
            && ($projection['projection_invalidated'] ?? true) === false
            && ($projection['derived_projection_payload'] ?? null) === $record['derived_projection_payload'];
    }

    /** @return array<string, mixed> */
    private function result(string $condition, ?array $record, mixed $storage, bool $usable): array
    {
        return [
            'record_kind' => 'MC_SYNTHETIC_CURRENT_CORRELATION_RESULT',
            'condition' => $condition,
            'storage_disposition' => $storage,
            'logical_record_identity' => $record['logical_record_identity'] ?? null,
            'intent_identity' => $record['logical_intent']['intent_identity'] ?? null,
            'correlation_usable' => $usable,
            'source_authority' => false,
            'permission' => false,
            'live_read_allowed' => false,
            'live_send_allowed' => false,
            'message_sent' => false,
        ];
    }

    /** @param array<string, mixed> $value @param list<string> $keys */
    private function exactKeys(array $value, array $keys): bool
    {
        $actual = array_keys($value);
        sort($actual);
        sort($keys);
        return $actual === $keys;
    }

    private function nonEmpty(mixed $value): bool
    {
        return is_string($value) && $value !== '';
    }

    private function participants(mixed $value): bool
    {
        return is_array($value) && array_is_list($value) && count($value) === 2
            && $this->nonEmpty($value[0]) && $this->nonEmpty($value[1]) && $value[0] !== $value[1];
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
