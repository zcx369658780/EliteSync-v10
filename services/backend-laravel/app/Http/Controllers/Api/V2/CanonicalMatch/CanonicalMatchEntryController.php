<?php

namespace App\Http\Controllers\Api\V2\CanonicalMatch;

use App\Domain\CanonicalMatchPersistenceApplicationAdapter;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use InvalidArgumentException;
use JsonException;
use stdClass;
use Throwable;

final class CanonicalMatchEntryController extends Controller
{
    private const EVALUATION_KEYS = [
        'decision_slot_evidence',
        'participation_evidence',
        'proposal',
        'synthetic_fixture',
    ];

    private const INVALIDATION_KEYS = [
        'decision_slot_evidence',
        'invalidation_request',
        'participation_evidence',
        'proposal',
        'synthetic_fixture',
    ];

    private const PROPOSAL_KEYS = [
        'at_most_one_unresolved_precondition',
        'lifecycle_state',
        'participants',
        'proposal_identity',
        'protected_use_scope',
        'required_bindings',
        'source_evidence',
    ];

    private const PARTICIPATION_KEYS = [
        'participant_identity',
        'required_bindings',
        'source_evidence',
        'state',
    ];

    private const SLOT_KEYS = [
        'decision',
        'participant_identity',
        'proposal_identity',
        'protected_use_scope',
        'required_bindings',
        'slot_identity',
        'source_evidence',
    ];

    private const BINDING_KEYS = [
        'actor',
        'actor_role',
        'aggregate_context',
        'audience',
        'authority_owner',
        'authority_scope',
        'lifecycle_identity',
        'participants',
        'purpose',
        'subject',
        'terminal',
    ];

    private const SOURCE_EVIDENCE_KEYS = [
        'authoritative_outcome',
        'bindings',
        'currentness',
        'freshness',
        'record_kind',
        'source_condition',
        'source_revision',
    ];

    private const SOURCE_REVISION_KEYS = [
        'aggregate_context',
        'authority_owner',
        'authority_scope',
        'lineage',
        'value',
    ];

    private const RESULT_KEYS = [
        'authoritative_outcome',
        'bearer_capability',
        'binding_classification',
        'condition',
        'connection_authority',
        'consent_authority',
        'conversation_authority',
        'derived_correlation_revision',
        'global_revision',
        'home_action_authority',
        'http_status',
        'invalidation_required',
        'last_received_wins',
        'last_write_wins',
        'launch_authority',
        'lifecycle_identity',
        'logical_intent_identity',
        'logical_record_identity',
        'match_authority',
        'match_classification',
        'match_payload',
        'materialized_projection_usable',
        'notification_delivery_authority',
        'operation',
        'permission',
        'production_ready',
        'projection_read_disposition',
        'real_data_authorized',
        'reason_categories',
        'reconciliation_required',
        'record_kind',
        'relationship_authority',
        'revalidation_required',
        'source_authority',
        'source_local_revision_only',
        'source_projection_lineage',
        'storage_disposition',
        'synthetic_dev_test_only',
        'transport_disposition',
    ];

    private const CLASSIFICATIONS = [
        'PENDING',
        'MUTUALLY_ACCEPTED',
        'DECLINED',
        'WITHDRAWN',
        'EXPIRED',
        'UNKNOWN',
    ];

    private const REASON_CATEGORIES = [
        'PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE',
        'UNRESOLVED_PROPOSAL_PRECONDITION_NOT_ESTABLISHED',
        'INVALID_PARTICIPATION_EVIDENCE_SET',
        'MISSING_PARTICIPATION',
        'PARTICIPATION_NOT_USABLE',
        'PARTICIPATION_PREVENTS_ACCEPTANCE',
        'CROSS_PROPOSAL_SLOT',
        'WRONG_PARTICIPANT_SLOT',
        'MISSING_DECISION_SLOT',
        'CONFLICTING_SLOT_IDENTITY',
        'INCOMPARABLE_DUPLICATE_SLOT',
        'CONFLICTING_EQUAL_REVISION_SLOT',
        'DECISION_SLOT_NOT_CURRENT_FRESH_BOUND',
        'CONFLICTING_TERMINAL_SLOT_DECISIONS',
        'DEPENDENCY_INVALIDATED',
    ];

    private const CONDITIONS = [
        'EXACT_PRIVACY_MINIMAL_CANONICAL_MATCH_PROJECTION_MATERIALIZED',
        'CANONICAL_MATCH_DEPENDENCY_INVALIDATED_PROJECTION_MATERIALIZED_UNUSABLE',
        'STORAGE_REJECTED_RETRIEVAL_SKIPPED',
        'CANONICAL_MATCH_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED',
    ];

    private const FALSE_RESULT_FIELDS = [
        'global_revision',
        'last_write_wins',
        'last_received_wins',
        'source_authority',
        'match_authority',
        'connection_authority',
        'consent_authority',
        'conversation_authority',
        'relationship_authority',
        'home_action_authority',
        'notification_delivery_authority',
        'launch_authority',
        'permission',
        'bearer_capability',
        'production_ready',
        'real_data_authorized',
    ];

    private const REJECTION_MESSAGE =
        'Request rejected by the bounded synthetic Canonical Match HTTP contract.';

    private const FAILURE_MESSAGE =
        'The bounded synthetic Canonical Match HTTP contract failed closed.';

    public function __construct(
        private readonly CanonicalMatchPersistenceApplicationAdapter $adapter,
    ) {}

    public function evaluate(Request $request): JsonResponse
    {
        return $this->process($request, false);
    }

    public function invalidate(Request $request): JsonResponse
    {
        return $this->process($request, true);
    }

    private function process(Request $request, bool $invalidation): JsonResponse
    {
        try {
            $decodedObject = json_decode($request->getContent(), false, 512, JSON_THROW_ON_ERROR);
        } catch (JsonException) {
            return $this->errorResponse('MALFORMED_JSON', 400);
        }

        if (! ($decodedObject instanceof stdClass)
            || ! $this->validTopLevelStructure($decodedObject, $invalidation)) {
            return $this->errorResponse('INVALID_REQUEST_SCHEMA', 400);
        }

        if (($decodedObject->synthetic_fixture ?? null)
            !== CanonicalMatchPersistenceApplicationAdapter::SYNTHETIC_FIXTURE_MARKER) {
            return $this->errorResponse('SYNTHETIC_BOUNDARY_REJECTED', 400);
        }

        $decoded = $this->normalizeJson($decodedObject);

        if (! $this->validRequest($decoded, $invalidation)) {
            return $this->errorResponse('INVALID_REQUEST_SCHEMA', 400);
        }

        try {
            $result = $invalidation
                ? $this->adapter->invalidateSynthetic($decoded)
                : $this->adapter->evaluateSynthetic($decoded);
        } catch (InvalidArgumentException) {
            return $this->errorResponse('ADAPTER_INPUT_REJECTED', 400);
        } catch (Throwable) {
            return $this->errorResponse('INTERNAL_APPLICATION_FAILURE', 500);
        }

        return $this->successResponse($result, $invalidation ? 'INVALIDATE' : 'EVALUATE');
    }

    private function validTopLevelStructure(stdClass $decoded, bool $invalidation): bool
    {
        $expected = $invalidation ? self::INVALIDATION_KEYS : self::EVALUATION_KEYS;
        $actual = array_keys(get_object_vars($decoded));

        if (array_diff($actual, $expected) !== []) {
            return false;
        }

        foreach (array_diff($expected, ['synthetic_fixture']) as $required) {
            if (! property_exists($decoded, $required)) {
                return false;
            }
        }

        return $decoded->proposal instanceof stdClass
            && is_array($decoded->participation_evidence)
            && is_array($decoded->decision_slot_evidence)
            && (! $invalidation || $decoded->invalidation_request instanceof stdClass);
    }

    /** @param array<string, mixed> $request */
    private function validRequest(array $request, bool $invalidation): bool
    {
        $expected = $invalidation ? self::INVALIDATION_KEYS : self::EVALUATION_KEYS;

        if (! $this->hasExactObjectKeys($request, $expected)
            || ! $this->validProposal($request['proposal'])
            || ! $this->validParticipationEvidence($request['participation_evidence'])
            || ! $this->validDecisionSlotEvidence($request['decision_slot_evidence'])) {
            return false;
        }

        return ! $invalidation || $this->validInvalidationRequest($request['invalidation_request']);
    }

    private function validProposal(mixed $proposal): bool
    {
        if (! $this->hasExactObjectKeys($proposal, self::PROPOSAL_KEYS)
            || ! $this->nonEmptyString($proposal['proposal_identity'])
            || ! is_array($proposal['participants'])
            || ! array_is_list($proposal['participants'])
            || count($proposal['participants']) !== 2
            || count(array_unique($proposal['participants'], SORT_STRING)) !== 2
            || ! $this->allNonEmptyStrings($proposal['participants'])
            || ! $this->nonEmptyString($proposal['protected_use_scope'])
            || ! in_array($proposal['lifecycle_state'], [
                'PENDING',
                'MUTUALLY_ACCEPTED',
                'DECLINED',
                'WITHDRAWN',
                'EXPIRED',
            ], true)
            || ! is_bool($proposal['at_most_one_unresolved_precondition'])) {
            return false;
        }

        return $this->validEvidenceContainer(
            $proposal['required_bindings'],
            $proposal['source_evidence'],
        );
    }

    private function validParticipationEvidence(mixed $evidence): bool
    {
        if (! is_array($evidence) || ! array_is_list($evidence)) {
            return false;
        }

        foreach ($evidence as $item) {
            if (! $this->hasExactObjectKeys($item, self::PARTICIPATION_KEYS)
                || ! $this->nonEmptyString($item['participant_identity'])
                || ! in_array($item['state'], [
                    'NOT_ENROLLED',
                    'ENROLLED',
                    'PAUSED',
                    'WITHDRAWN',
                ], true)
                || ! $this->validEvidenceContainer(
                    $item['required_bindings'],
                    $item['source_evidence'],
                )) {
                return false;
            }
        }

        return true;
    }

    private function validDecisionSlotEvidence(mixed $evidence): bool
    {
        if (! is_array($evidence) || ! array_is_list($evidence)) {
            return false;
        }

        foreach ($evidence as $item) {
            if (! $this->hasExactObjectKeys($item, self::SLOT_KEYS)
                || ! $this->nonEmptyString($item['slot_identity'])
                || ! $this->nonEmptyString($item['proposal_identity'])
                || ! $this->nonEmptyString($item['participant_identity'])
                || ! $this->nonEmptyString($item['protected_use_scope'])
                || ! in_array($item['decision'], [
                    'PENDING',
                    'ACCEPTED',
                    'DECLINED',
                    'WITHDRAWN',
                ], true)
                || ! $this->validEvidenceContainer(
                    $item['required_bindings'],
                    $item['source_evidence'],
                )) {
                return false;
            }
        }

        return true;
    }

    private function validInvalidationRequest(mixed $request): bool
    {
        return $this->hasExactObjectKeys($request, ['dependency_identity', 'relation'])
            && $this->nonEmptyString($request['dependency_identity'])
            && in_array($request['relation'], [
                'CORRECTION',
                'REVOCATION',
                'SUPERSESSION',
            ], true);
    }

    private function validEvidenceContainer(mixed $requiredBindings, mixed $sourceEvidence): bool
    {
        if (! $this->validBindings($requiredBindings)
            || ! $this->hasExactObjectKeys($sourceEvidence, self::SOURCE_EVIDENCE_KEYS)
            || ($sourceEvidence['record_kind'] ?? null) !== 'SOURCE_EVIDENCE'
            || ! $this->validBindings($sourceEvidence['bindings'] ?? null)
            || ! in_array($sourceEvidence['source_condition'] ?? null, [
                'PRESENT',
                'ABSENT',
                'UNKNOWN',
                'UNAVAILABLE',
                'STALE',
                'SUPERSEDED',
                'INCOMPARABLE',
            ], true)
            || ! $this->booleanOrNull($sourceEvidence['currentness'] ?? null)
            || ! $this->booleanOrNull($sourceEvidence['freshness'] ?? null)
            || ! in_array($sourceEvidence['authoritative_outcome'] ?? null, [
                'COMMITTED',
                'REJECTED',
                'UNKNOWN',
            ], true)) {
            return false;
        }

        return $this->validSourceRevision(
            $sourceEvidence['source_revision'] ?? null,
            $requiredBindings,
            $sourceEvidence['bindings'],
        );
    }

    private function validBindings(mixed $bindings): bool
    {
        if (! $this->hasExactObjectKeys($bindings, self::BINDING_KEYS)
            || ! is_array($bindings['participants'])
            || ! array_is_list($bindings['participants'])
            || ! $this->allNonEmptyStrings($bindings['participants'])
            || ! is_bool($bindings['terminal'])) {
            return false;
        }

        foreach ([
            'authority_owner',
            'authority_scope',
            'actor',
            'actor_role',
            'subject',
            'audience',
            'purpose',
            'aggregate_context',
            'lifecycle_identity',
        ] as $key) {
            if (! $this->nonEmptyString($bindings[$key])) {
                return false;
            }
        }

        return true;
    }

    /**
     * @param array<string, mixed> $requiredBindings
     * @param array<string, mixed> $sourceBindings
     */
    private function validSourceRevision(
        mixed $revision,
        array $requiredBindings,
        array $sourceBindings,
    ): bool {
        if (! $this->hasExactObjectKeys($revision, self::SOURCE_REVISION_KEYS)
            || ! $this->nonEmptyString($revision['authority_owner'])
            || ! $this->nonEmptyString($revision['authority_scope'])
            || ! $this->nonEmptyString($revision['lineage'])
            || ! $this->nonEmptyString($revision['aggregate_context'])
            || ! is_int($revision['value'])
            || $revision['value'] < 0) {
            return false;
        }

        foreach ([$requiredBindings, $sourceBindings] as $bindings) {
            if ($revision['authority_owner'] !== $bindings['authority_owner']
                || $revision['authority_scope'] !== $bindings['authority_scope']
                || $revision['aggregate_context'] !== $bindings['aggregate_context']) {
                return false;
            }
        }

        return true;
    }

    /** @param array<string, mixed> $result */
    private function successResponse(array $result, string $expectedOperation): JsonResponse
    {
        $classification = $result['match_classification'] ?? null;
        $reasons = $result['reason_categories'] ?? null;
        $usable = $result['materialized_projection_usable'] ?? null;
        $condition = $result['condition'] ?? null;

        if (! $this->hasExactObjectKeys($result, self::RESULT_KEYS)
            || ($result['record_kind'] ?? null)
                !== 'CANONICAL_MATCH_PERSISTENCE_APPLICATION_ADAPTER_RESULT'
            || ($result['operation'] ?? null) !== $expectedOperation
            || ! in_array($classification, self::CLASSIFICATIONS, true)
            || ! is_array($reasons)
            || ! array_is_list($reasons)
            || count($reasons) !== count(array_unique($reasons, SORT_STRING))
            || array_values(array_intersect(self::REASON_CATEGORIES, $reasons)) !== $reasons
            || ! is_bool($usable)
            || ! in_array($condition, self::CONDITIONS, true)
            || ($result['synthetic_dev_test_only'] ?? null) !== true
            || ($result['source_local_revision_only'] ?? null) !== true
            || $result['transport_disposition'] !== null
            || $result['http_status'] !== null
            || ($condition === self::CONDITIONS[0]) !== $usable) {
            return $this->errorResponse('UNRECOGNIZED_TRANSPORT_MAPPING', 500);
        }

        foreach (self::FALSE_RESULT_FIELDS as $field) {
            if (($result[$field] ?? null) !== false) {
                return $this->errorResponse('UNRECOGNIZED_TRANSPORT_MAPPING', 500);
            }
        }

        if (($expectedOperation === 'EVALUATE' && $condition === self::CONDITIONS[1])
            || ($expectedOperation === 'INVALIDATE' && $condition === self::CONDITIONS[0])) {
            return $this->errorResponse('UNRECOGNIZED_TRANSPORT_MAPPING', 500);
        }

        return response()->json([
            'match_classification' => $classification,
            'reason_categories' => $reasons,
            'materialized_projection_usable' => $usable,
            'condition' => $condition,
            'synthetic_dev_test_only' => true,
        ], 200);
    }

    private function errorResponse(string $code, int $status): JsonResponse
    {
        return response()->json([
            'error' => [
                'code' => $code,
                'message' => $status === 400 ? self::REJECTION_MESSAGE : self::FAILURE_MESSAGE,
            ],
            'synthetic_dev_test_only' => true,
        ], $status);
    }

    private function hasExactObjectKeys(mixed $value, array $expected): bool
    {
        if (! is_array($value) || array_is_list($value)) {
            return false;
        }

        $keys = array_keys($value);
        sort($keys);
        sort($expected);

        return $keys === $expected;
    }

    /** @param list<mixed> $values */
    private function allNonEmptyStrings(array $values): bool
    {
        foreach ($values as $value) {
            if (! $this->nonEmptyString($value)) {
                return false;
            }
        }

        return true;
    }

    private function nonEmptyString(mixed $value): bool
    {
        return is_string($value) && $value !== '';
    }

    private function booleanOrNull(mixed $value): bool
    {
        return is_bool($value) || $value === null;
    }

    private function normalizeJson(mixed $value): mixed
    {
        if ($value instanceof stdClass) {
            $normalized = [];

            foreach (get_object_vars($value) as $key => $nested) {
                $normalized[$key] = $this->normalizeJson($nested);
            }

            return $normalized;
        }

        if (is_array($value)) {
            return array_map($this->normalizeJson(...), $value);
        }

        return $value;
    }
}