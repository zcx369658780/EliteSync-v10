<?php

namespace App\Domain;

final class TransportNeutralApplicationRequestResponseContract
{
    public const FAMILY_MUTATION_SUBMISSION = 'AUTHORITATIVE_MUTATION_SUBMISSION';
    public const FAMILY_OUTCOME_RECONCILIATION = 'AUTHORITATIVE_OUTCOME_RECONCILIATION';
    public const FAMILY_PROJECTION_RETRIEVAL = 'CURRENT_PROJECTION_RETRIEVAL';
    public const FAMILY_PROTECTED_REVALIDATION = 'PROTECTED_ACTION_REVALIDATION';
    public const FAMILY_INVALIDATION_OBSERVATION = 'INVALIDATION_OBSERVATION';

    public const DELIVERED_TO_APPLICATION = 'DELIVERED_TO_APPLICATION';
    public const REQUEST_REJECTED = 'REQUEST_REJECTED';
    public const UNKNOWN = 'UNKNOWN';

    private const FAMILIES = [
        self::FAMILY_MUTATION_SUBMISSION,
        self::FAMILY_OUTCOME_RECONCILIATION,
        self::FAMILY_PROJECTION_RETRIEVAL,
        self::FAMILY_PROTECTED_REVALIDATION,
        self::FAMILY_INVALIDATION_OBSERVATION,
    ];

    /** @var array<string, array{fingerprint: string, response: array<string, mixed>}> */
    private array $requestReceipts = [];

    public function __construct(
        private readonly PersistenceBoundaryApplicationInterfaceIntegrationContract $application,
    ) {}

    /**
     * @param array<string, mixed> $request
     * @return array<string, mixed>
     */
    public function handle(array $request): array
    {
        $shapeError = $this->requestShapeError($request);

        if ($shapeError !== null) {
            return $this->rejectedEnvelope(
                $this->boundedString($request['request_identity'] ?? null),
                $this->boundedString($request['family'] ?? null),
                self::REQUEST_REJECTED,
                $shapeError,
            );
        }

        $requestIdentity = $request['request_identity'];
        $family = $request['family'];
        $payload = $request['semantic_payload'];

        if (! in_array($family, self::FAMILIES, true)) {
            return $this->rejectedEnvelope(
                $requestIdentity,
                $family,
                self::UNKNOWN,
                'UNSUPPORTED_FAMILY',
            );
        }

        if (! $this->validFamilyPayload($family, $payload)) {
            return $this->rejectedEnvelope(
                $requestIdentity,
                $family,
                self::REQUEST_REJECTED,
                'MALFORMED_FAMILY_PAYLOAD',
            );
        }

        $fingerprint = $this->fingerprint([
            'family' => $family,
            'semantic_payload' => $payload,
        ]);
        $registered = $this->requestReceipts[$requestIdentity] ?? null;

        if ($registered !== null) {
            if ($registered['fingerprint'] !== $fingerprint) {
                return $this->rejectedEnvelope(
                    $requestIdentity,
                    $family,
                    self::REQUEST_REJECTED,
                    'REQUEST_IDENTITY_PAYLOAD_CONFLICT',
                    false,
                );
            }

            return $registered['response'];
        }

        try {
            $applicationResult = $this->dispatch($family, $payload);
            $response = $this->deliveredEnvelope($requestIdentity, $family, $applicationResult);
        } catch (\Throwable) {
            $response = $this->rejectedEnvelope(
                $requestIdentity,
                $family,
                self::REQUEST_REJECTED,
                'APPLICATION_DISPATCH_REJECTED',
                true,
            );
        }

        $this->requestReceipts[$requestIdentity] = [
            'fingerprint' => $fingerprint,
            'response' => $response,
        ];

        return $response;
    }

    /**
     * @param array<string, mixed> $request
     */
    private function requestShapeError(array $request): ?string
    {
        $allowed = ['request_identity', 'family', 'semantic_payload'];
        $keys = array_keys($request);

        if (array_diff($keys, $allowed) !== []) {
            return 'UNKNOWN_TOP_LEVEL_FIELD';
        }

        sort($keys);
        sort($allowed);

        if ($keys !== $allowed) {
            return 'MALFORMED_REQUEST_ENVELOPE';
        }

        if (! is_string($request['request_identity']) || $request['request_identity'] === '') {
            return 'MALFORMED_REQUEST_ENVELOPE';
        }

        if (! is_string($request['family']) || $request['family'] === '') {
            return 'MALFORMED_REQUEST_ENVELOPE';
        }

        if (! is_array($request['semantic_payload']) || $request['semantic_payload'] === []) {
            return 'MALFORMED_REQUEST_ENVELOPE';
        }

        return null;
    }

    /** @param array<string, mixed> $payload */
    private function validFamilyPayload(string $family, array $payload): bool
    {
        $expectedKeys = match ($family) {
            self::FAMILY_MUTATION_SUBMISSION => ['record'],
            self::FAMILY_OUTCOME_RECONCILIATION => ['expected_intent', 'logical_record_identity'],
            self::FAMILY_PROJECTION_RETRIEVAL => ['query', 'request_bindings'],
            self::FAMILY_PROTECTED_REVALIDATION => ['query', 'required_bindings', 'source_evidence'],
            self::FAMILY_INVALIDATION_OBSERVATION => ['logical_record_identity', 'relation'],
            default => [],
        };
        $keys = array_keys($payload);
        sort($keys);
        sort($expectedKeys);

        if ($keys !== $expectedKeys) {
            return false;
        }

        return match ($family) {
            self::FAMILY_MUTATION_SUBMISSION => is_array($payload['record']) && $payload['record'] !== [],
            self::FAMILY_OUTCOME_RECONCILIATION => $this->nonEmptyString($payload['logical_record_identity'])
                && is_array($payload['expected_intent'])
                && $payload['expected_intent'] !== [],
            self::FAMILY_PROJECTION_RETRIEVAL => is_array($payload['query'])
                && $payload['query'] !== []
                && is_array($payload['request_bindings'])
                && $payload['request_bindings'] !== [],
            self::FAMILY_PROTECTED_REVALIDATION => is_array($payload['query'])
                && $payload['query'] !== []
                && is_array($payload['required_bindings'])
                && $payload['required_bindings'] !== []
                && is_array($payload['source_evidence'])
                && $payload['source_evidence'] !== [],
            self::FAMILY_INVALIDATION_OBSERVATION => $this->nonEmptyString($payload['logical_record_identity'])
                && $this->nonEmptyString($payload['relation']),
            default => false,
        };
    }

    /**
     * @param array<string, mixed> $payload
     * @return array<string, mixed>
     */
    private function dispatch(string $family, array $payload): array
    {
        return match ($family) {
            self::FAMILY_MUTATION_SUBMISSION => $this->application->submitAuthoritativeMutation(
                $payload['record'],
            ),
            self::FAMILY_OUTCOME_RECONCILIATION => $this->application->reconcileAuthoritativeOutcome(
                $payload['logical_record_identity'],
                $payload['expected_intent'],
            ),
            self::FAMILY_PROJECTION_RETRIEVAL => $this->application->retrieveCurrentProjection(
                $payload['query'],
                $payload['request_bindings'],
            ),
            self::FAMILY_PROTECTED_REVALIDATION => $this->application->revalidateProtectedAction(
                $payload['query'],
                $payload['required_bindings'],
                $payload['source_evidence'],
            ),
            self::FAMILY_INVALIDATION_OBSERVATION => $this->application->observeInvalidation(
                $payload['logical_record_identity'],
                $payload['relation'],
            ),
        };
    }

    /**
     * @param array<string, mixed> $applicationResult
     * @return array<string, mixed>
     */
    private function deliveredEnvelope(
        string $requestIdentity,
        string $family,
        array $applicationResult,
    ): array {
        $condition = $this->applicationCondition($family, $applicationResult);
        $sourceOutcome = $applicationResult['authoritative_outcome'] ?? null;

        if (! in_array($sourceOutcome, [
            CommonAuthorityEvidenceContract::OUTCOME_COMMITTED,
            CommonAuthorityEvidenceContract::OUTCOME_REJECTED,
            CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN,
        ], true)) {
            $sourceOutcome = null;
        }

        return array_merge(self::nonAuthorityFields(), [
            'record_kind' => 'TRANSPORT_NEUTRAL_APPLICATION_RESPONSE_ENVELOPE',
            'request_identity' => $requestIdentity,
            'family' => $family,
            'transport_disposition' => self::DELIVERED_TO_APPLICATION,
            'application_semantic_result' => $applicationResult,
            'source_domain_outcome' => $sourceOutcome,
            'bounded_error_condition' => $condition,
            'reconciliation_required' => ($applicationResult['reconciliation_required'] ?? false) === true,
            'revalidation_required' => in_array($family, [
                self::FAMILY_PROJECTION_RETRIEVAL,
                self::FAMILY_PROTECTED_REVALIDATION,
                self::FAMILY_INVALIDATION_OBSERVATION,
            ], true),
            'privacy_minimal_explanation' => is_string($applicationResult['explanation_category'] ?? null)
                ? $applicationResult['explanation_category']
                : 'BOUNDED_CONDITION_'.$condition,
            'request_correlation_compatible' => true,
            'dispatch_count' => 1,
            'transport_disposition_is_domain_outcome' => false,
            'request_identity_is_permission' => false,
            'response_is_bearer_capability' => false,
            'global_revision' => false,
            'timestamp_authority' => false,
            'request_order_authority' => false,
            'arrival_order_authority' => false,
            'last_write_wins' => false,
            'last_received_wins' => false,
        ]);
    }

    /** @param array<string, mixed> $applicationResult */
    private function applicationCondition(string $family, array $applicationResult): string
    {
        return match ($family) {
            self::FAMILY_MUTATION_SUBMISSION => $this->mutationCondition($applicationResult),
            self::FAMILY_OUTCOME_RECONCILIATION => ($applicationResult['intent_binding'] ?? null) === 'MISMATCH'
                ? 'RECONCILIATION_INTENT_MISMATCH'
                : $this->outcomeOrResolutionCondition($applicationResult),
            self::FAMILY_PROJECTION_RETRIEVAL => ($applicationResult['binding_classification'] ?? null) === 'MISMATCH'
                ? 'PROJECTION_BINDING_MISMATCH'
                : $this->resolutionCondition($applicationResult['resolution'] ?? null),
            self::FAMILY_PROTECTED_REVALIDATION => match ($applicationResult['classification'] ?? null) {
                PersistenceBoundaryApplicationInterfaceIntegrationContract::GRANTED => 'NONE',
                PersistenceBoundaryApplicationInterfaceIntegrationContract::DENIED => 'REVALIDATION_DENIED',
                default => 'REVALIDATION_UNKNOWN',
            },
            self::FAMILY_INVALIDATION_OBSERVATION => $this->resolutionCondition(
                $applicationResult['resolution'] ?? null,
            ),
            default => self::UNKNOWN,
        };
    }

    /** @param array<string, mixed> $applicationResult */
    private function mutationCondition(array $applicationResult): string
    {
        $persistence = is_array($applicationResult['persistence'] ?? null)
            ? $applicationResult['persistence']
            : [];
        $storageOutcome = $persistence['storage_outcome'] ?? null;

        if (($persistence['stored'] ?? false) !== true
            && $storageOutcome !== InMemoryLogicalPersistenceRepositoryContract::EXACT_DUPLICATE) {
            return 'PERSISTENCE_APPLICATION_REJECTION';
        }

        return match ($applicationResult['authoritative_outcome'] ?? null) {
            CommonAuthorityEvidenceContract::OUTCOME_COMMITTED => 'NONE',
            CommonAuthorityEvidenceContract::OUTCOME_REJECTED => 'SOURCE_CARRIED_REJECTED_OUTCOME',
            default => CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN,
        };
    }

    /** @param array<string, mixed> $applicationResult */
    private function outcomeOrResolutionCondition(array $applicationResult): string
    {
        $resolution = $applicationResult['persistence_resolution'] ?? null;

        if ($resolution !== InMemoryLogicalPersistenceRepositoryContract::FOUND) {
            return $this->resolutionCondition($resolution);
        }

        return match ($applicationResult['authoritative_outcome'] ?? null) {
            CommonAuthorityEvidenceContract::OUTCOME_COMMITTED => 'NONE',
            CommonAuthorityEvidenceContract::OUTCOME_REJECTED => 'SOURCE_CARRIED_REJECTED_OUTCOME',
            default => CommonAuthorityEvidenceContract::OUTCOME_UNKNOWN,
        };
    }

    private function resolutionCondition(mixed $resolution): string
    {
        return in_array($resolution, [
            InMemoryLogicalPersistenceRepositoryContract::MISSING,
            InMemoryLogicalPersistenceRepositoryContract::UNKNOWN,
            InMemoryLogicalPersistenceRepositoryContract::ABSENT,
            InMemoryLogicalPersistenceRepositoryContract::UNAVAILABLE,
            InMemoryLogicalPersistenceRepositoryContract::STALE,
            InMemoryLogicalPersistenceRepositoryContract::SUPERSEDED,
            InMemoryLogicalPersistenceRepositoryContract::INCOMPARABLE,
            InMemoryLogicalPersistenceRepositoryContract::INVALIDATED,
        ], true)
            ? $resolution
            : 'NONE';
    }

    /** @return array<string, mixed> */
    private function rejectedEnvelope(
        ?string $requestIdentity,
        ?string $family,
        string $disposition,
        string $condition,
        bool $dispatched = false,
        bool $correlationCompatible = false,
    ): array {
        return array_merge(self::nonAuthorityFields(), [
            'record_kind' => 'TRANSPORT_NEUTRAL_APPLICATION_RESPONSE_ENVELOPE',
            'request_identity' => $requestIdentity,
            'family' => $family,
            'transport_disposition' => $disposition,
            'application_semantic_result' => null,
            'source_domain_outcome' => null,
            'bounded_error_condition' => $condition,
            'reconciliation_required' => false,
            'revalidation_required' => false,
            'privacy_minimal_explanation' => $condition,
            'request_correlation_compatible' => $correlationCompatible,
            'dispatch_count' => $dispatched ? 1 : 0,
            'transport_disposition_is_domain_outcome' => false,
            'request_identity_is_permission' => false,
            'response_is_bearer_capability' => false,
            'global_revision' => false,
            'timestamp_authority' => false,
            'request_order_authority' => false,
            'arrival_order_authority' => false,
            'last_write_wins' => false,
            'last_received_wins' => false,
        ]);
    }

    /** @return array<string, false> */
    private static function nonAuthorityFields(): array
    {
        return [
            'source_authority' => false,
            'domain_writer_authority' => false,
            'authoritative_mutation_success' => false,
            'permission' => false,
            'permission_token' => false,
            'bearer_capability' => false,
            'protected_action_executed' => false,
            'transport_execution_authority' => false,
            'http_semantics' => false,
            'controller_authority' => false,
            'route_authority' => false,
            'authentication_authority' => false,
            'production_ready' => false,
            'deployable' => false,
            'real_data_authorized' => false,
            'readiness_authority' => false,
            'match_authority' => false,
            'connection_authority' => false,
            'consent_authority' => false,
            'conversation_authority' => false,
            'relationship_authority' => false,
            'home_action_authority' => false,
            'notification_delivery_authority' => false,
            'launch_authority' => false,
        ];
    }

    private function nonEmptyString(mixed $value): bool
    {
        return is_string($value) && $value !== '';
    }

    private function boundedString(mixed $value): ?string
    {
        return is_string($value) && $value !== '' ? $value : null;
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
