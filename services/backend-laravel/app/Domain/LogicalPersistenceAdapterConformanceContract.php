<?php

namespace App\Domain;

final class LogicalPersistenceAdapterConformanceContract
{
    public const CONFORMANT = 'CONFORMANT';
    public const NON_CONFORMANT = 'NON_CONFORMANT';
    public const UNKNOWN = 'UNKNOWN';

    public const OPERATION_STORE = 'STORE';
    public const OPERATION_READ_EXACT = 'READ_EXACT';
    public const OPERATION_RESOLVE_CURRENT = 'RESOLVE_CURRENT';
    public const OPERATION_READ_HISTORY = 'READ_HISTORY';
    public const OPERATION_OBSERVE_INVALIDATION = 'OBSERVE_INVALIDATION';
    public const OPERATION_PRIVACY_MINIMAL_PROJECTION = 'PRIVACY_MINIMAL_PROJECTION';

    private const OPERATIONS = [
        self::OPERATION_STORE,
        self::OPERATION_READ_EXACT,
        self::OPERATION_RESOLVE_CURRENT,
        self::OPERATION_READ_HISTORY,
        self::OPERATION_OBSERVE_INVALIDATION,
        self::OPERATION_PRIVACY_MINIMAL_PROJECTION,
    ];

    private const PRIVATE_KEYS = [
        'conversation_content',
        'message_content',
        'message_preview',
        'message_draft',
        'hidden_safety_evidence',
        'private_identity',
        'private_profile',
        'credential',
        'credentials',
        'password',
        'access_token',
        'refresh_token',
        'device_token',
        'provider_payload',
        'compatibility_score',
        'desirability_score',
        'person_worth',
        'analytics_signal',
        'training_signal',
        'advertising_signal',
    ];

    /**
     * Compare a future adapter result with one accepted reference result.
     *
     * This is semantic evidence classification only. It performs no persistence
     * and grants no source, domain, runtime, production, or deployment authority.
     *
     * @param array<string, mixed> $reference
     * @param array<string, mixed> $candidate
     * @return array<string, mixed>
     */
    public static function evaluate(string $operationFamily, array $reference, array $candidate): array
    {
        if (! in_array($operationFamily, self::OPERATIONS, true)) {
            return self::result(self::UNKNOWN, $operationFamily, false, false, 'UNKNOWN_OPERATION_FAMILY');
        }

        if (! self::hasRequiredReferenceShape($operationFamily, $reference)) {
            return self::result(self::UNKNOWN, $operationFamily, false, false, 'INCOMPLETE_REFERENCE_EVIDENCE');
        }

        if (! self::containsReferenceShape($reference, $candidate)) {
            return self::result(self::UNKNOWN, $operationFamily, false, false, 'INCOMPLETE_CANDIDATE_EVIDENCE');
        }

        if (self::containsProhibitedPrivateMaterial($candidate)) {
            return self::result(self::NON_CONFORMANT, $operationFamily, true, false, 'PROHIBITED_PRIVATE_MATERIAL');
        }

        if (self::introducesForbiddenAuthority($candidate)) {
            return self::result(self::NON_CONFORMANT, $operationFamily, true, false, 'SYNTHESIZED_AUTHORITY_OR_SUCCESS');
        }

        if (self::introducesGlobalOrArrivalOrdering($candidate)) {
            return self::result(self::NON_CONFORMANT, $operationFamily, true, false, 'GLOBAL_OR_ARRIVAL_ORDERING_INTRODUCED');
        }

        if (self::inventsSourceCarriedOutcome($reference, $candidate)) {
            return self::result(self::NON_CONFORMANT, $operationFamily, true, false, 'AUTHORITATIVE_OUTCOME_INVENTED');
        }

        if (self::canonicalize($reference) !== self::canonicalize($candidate)) {
            return self::result(self::NON_CONFORMANT, $operationFamily, true, false, 'REFERENCE_SEMANTICS_CHANGED');
        }

        return self::result(self::CONFORMANT, $operationFamily, true, true, 'EXACT_REFERENCE_SEMANTICS_PRESERVED');
    }

    /** @param array<string, mixed> $reference */
    private static function hasRequiredReferenceShape(string $operationFamily, array $reference): bool
    {
        if ($reference === [] || ! array_key_exists('record_kind', $reference)) {
            return false;
        }

        $required = match ($operationFamily) {
            self::OPERATION_STORE => ['storage_outcome', 'stored', 'idempotent_correlation'],
            self::OPERATION_READ_HISTORY => ['resolution', 'records'],
            self::OPERATION_RESOLVE_CURRENT => [
                'resolution',
                'record',
                'source_local_revision_only',
                'last_write_wins',
                'last_received_wins',
            ],
            default => ['resolution', 'record'],
        };

        foreach ($required as $key) {
            if (! array_key_exists($key, $reference)) {
                return false;
            }
        }

        return true;
    }

    private static function containsReferenceShape(mixed $reference, mixed $candidate): bool
    {
        if (! is_array($reference)) {
            return true;
        }

        if (! is_array($candidate) || array_is_list($reference) !== array_is_list($candidate)) {
            return false;
        }

        if (array_is_list($reference)) {
            if (count($reference) !== count($candidate)) {
                return false;
            }

            foreach ($reference as $index => $value) {
                if (! self::containsReferenceShape($value, $candidate[$index])) {
                    return false;
                }
            }

            return true;
        }

        foreach ($reference as $key => $value) {
            if (! array_key_exists($key, $candidate)
                || ! self::containsReferenceShape($value, $candidate[$key])) {
                return false;
            }
        }

        return true;
    }

    private static function containsProhibitedPrivateMaterial(mixed $value): bool
    {
        if (is_string($value)) {
            return str_contains($value, 'MUST-NOT-LEAK');
        }

        if (! is_array($value)) {
            return false;
        }

        foreach ($value as $key => $nested) {
            if ((is_string($key) && in_array(strtolower($key), self::PRIVATE_KEYS, true))
                || self::containsProhibitedPrivateMaterial($nested)) {
                return true;
            }
        }

        return false;
    }

    /** @param array<string, mixed> $candidate */
    private static function introducesForbiddenAuthority(array $candidate): bool
    {
        $forbiddenTrueFields = [
            'source_authority',
            'authoritative_mutation_success',
            'permission',
            'bearer_capability',
            'success',
            'domain_success',
            'readiness_authority',
            'match_authority',
            'connection_authority',
            'consent_authority',
            'conversation_authority',
            'relationship_authority',
            'home_action_authority',
            'notification_delivery_authority',
            'launch_authority',
            'production_ready',
            'durability_established',
            'transactional',
            'concurrent_safe',
            'deployable',
            'transport_is_domain_outcome',
        ];

        return self::containsTrueField($candidate, $forbiddenTrueFields);
    }

    /** @param array<string, mixed> $candidate */
    private static function introducesGlobalOrArrivalOrdering(array $candidate): bool
    {
        if (self::containsKey($candidate, 'global_revision')) {
            return true;
        }

        return self::containsTrueField($candidate, ['last_write_wins', 'last_received_wins']);
    }

    /** @param array<string, mixed> $reference @param array<string, mixed> $candidate */
    private static function inventsSourceCarriedOutcome(array $reference, array $candidate): bool
    {
        $referenceCarried = self::fieldValues($reference, 'authoritative_outcome_source_carried');
        $candidateCarried = self::fieldValues($candidate, 'authoritative_outcome_source_carried');

        return in_array(true, $candidateCarried, true) && ! in_array(true, $referenceCarried, true);
    }

    /** @param array<mixed> $value @param list<string> $fields */
    private static function containsTrueField(array $value, array $fields): bool
    {
        foreach ($value as $key => $nested) {
            if (is_string($key) && in_array($key, $fields, true) && $nested === true) {
                return true;
            }

            if (is_array($nested) && self::containsTrueField($nested, $fields)) {
                return true;
            }
        }

        return false;
    }

    /** @param array<mixed> $value */
    private static function containsKey(array $value, string $needle): bool
    {
        foreach ($value as $key => $nested) {
            if ($key === $needle || (is_array($nested) && self::containsKey($nested, $needle))) {
                return true;
            }
        }

        return false;
    }

    /** @param array<mixed> $value @return list<mixed> */
    private static function fieldValues(array $value, string $needle): array
    {
        $found = [];

        foreach ($value as $key => $nested) {
            if ($key === $needle) {
                $found[] = $nested;
            }

            if (is_array($nested)) {
                array_push($found, ...self::fieldValues($nested, $needle));
            }
        }

        return $found;
    }

    private static function canonicalize(mixed $value): mixed
    {
        if (! is_array($value)) {
            return $value;
        }

        if (array_is_list($value)) {
            return array_map(self::canonicalize(...), $value);
        }

        ksort($value);

        foreach ($value as $key => $nested) {
            $value[$key] = self::canonicalize($nested);
        }

        return $value;
    }

    /** @return array<string, mixed> */
    private static function result(
        string $classification,
        string $operationFamily,
        bool $comparisonComplete,
        bool $semanticEquivalence,
        string $reason,
    ): array {
        return [
            'classification' => $classification,
            'operation_family' => $operationFamily,
            'comparison_complete' => $comparisonComplete,
            'semantic_equivalence' => $semanticEquivalence,
            'reason' => $reason,
            'source_authority' => false,
            'authoritative_mutation_success' => false,
            'permission' => false,
            'bearer_capability' => false,
            'domain_success' => false,
            'readiness_authority' => false,
            'match_authority' => false,
            'connection_authority' => false,
            'consent_authority' => false,
            'conversation_authority' => false,
            'relationship_authority' => false,
            'home_action_authority' => false,
            'notification_delivery_authority' => false,
            'launch_authority' => false,
            'production_ready' => false,
            'durability_established' => false,
            'transactional' => false,
            'concurrent_safe' => false,
            'deployable' => false,
        ];
    }
}
