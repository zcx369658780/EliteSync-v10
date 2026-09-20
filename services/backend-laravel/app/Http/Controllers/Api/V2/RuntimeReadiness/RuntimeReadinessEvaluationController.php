<?php

namespace App\Http\Controllers\Api\V2\RuntimeReadiness;

use App\Domain\RuntimeReadinessPersistenceApplicationAdapter;
use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use InvalidArgumentException;
use JsonException;
use stdClass;
use Throwable;

final class RuntimeReadinessEvaluationController extends Controller
{
    private const TOP_LEVEL_KEYS = ['member_evidence', 'prerequisite_set'];

    private const PREREQUISITE_SET_KEYS = [
        'private_fixture_extensions',
        'protected_use_scope',
        'required_bindings',
        'required_member_ids',
        'set_identity',
        'source_evidence',
        'state',
        'synthetic_fixture',
    ];

    private const MEMBER_KEYS = [
        'fact_class',
        'member_identity',
        'prerequisite_outcome',
        'private_fixture_extensions',
        'protected_use_scope',
        'required_bindings',
        'source_evidence',
        'synthetic_fixture',
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

    private const SOURCE_CONDITIONS = [
        'PRESENT',
        'ABSENT',
        'UNKNOWN',
        'UNAVAILABLE',
        'STALE',
        'SUPERSEDED',
        'INCOMPARABLE',
    ];

    private const REASON_CATEGORIES = [
        'UNKNOWN_PREREQUISITE_SET',
        'INVALID_PREREQUISITE_SET',
        'PREREQUISITE_SET_UNUSABLE',
        'MISSING_REQUIRED_MEMBER',
        'INVALID_REQUIRED_MEMBER',
        'INCOMPARABLE_DUPLICATE_EVIDENCE',
        'CONFLICTING_DUPLICATE_EVIDENCE',
        'INVALID_MEMBER_FACT_CLASS',
        'PROTECTED_USE_SCOPE_MISMATCH',
        'MEMBER_UNUSABLE',
        'UNKNOWN_MEMBER_OUTCOME',
        'AUTHORITATIVE_REQUIRED_MEMBER_UNSATISFIED',
        'DEPENDENCY_INVALIDATED',
    ];

    private const CONDITIONS = [
        'EXACT_PRIVACY_MINIMAL_RR03_PROJECTION_MATERIALIZED',
        'STORAGE_REJECTED_RETRIEVAL_SKIPPED',
        'RR03_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED',
    ];

    private const REJECTION_MESSAGE =
        'Request rejected by the bounded synthetic Runtime Readiness HTTP contract.';

    private const FAILURE_MESSAGE =
        'The bounded synthetic Runtime Readiness HTTP contract failed closed.';

    public function __construct(
        private readonly RuntimeReadinessPersistenceApplicationAdapter $adapter,
    ) {}

    public function __invoke(Request $request): JsonResponse
    {
        try {
            $decodedObject = json_decode($request->getContent(), false, 512, JSON_THROW_ON_ERROR);
        } catch (JsonException) {
            return $this->errorResponse('MALFORMED_JSON', 400);
        }

        if (! ($decodedObject instanceof stdClass)
            || ! $this->hasExactObjectKeys(
                $this->normalizeJson($decodedObject),
                self::TOP_LEVEL_KEYS,
            )
            || ! ($decodedObject->prerequisite_set instanceof stdClass)
            || ! is_array($decodedObject->member_evidence)) {
            return $this->errorResponse('INVALID_REQUEST_SCHEMA', 400);
        }

        if (($decodedObject->prerequisite_set->synthetic_fixture ?? null)
                !== RuntimeReadinessPersistenceApplicationAdapter::SYNTHETIC_FIXTURE_MARKER) {
            return $this->errorResponse('SYNTHETIC_BOUNDARY_REJECTED', 400);
        }

        foreach ($decodedObject->member_evidence as $member) {
            if ($member instanceof stdClass
                && ($member->synthetic_fixture ?? null)
                    !== RuntimeReadinessPersistenceApplicationAdapter::SYNTHETIC_FIXTURE_MARKER) {
                return $this->errorResponse('SYNTHETIC_BOUNDARY_REJECTED', 400);
            }
        }

        $decoded = $this->normalizeJson($decodedObject);
        $prerequisiteSet = $decoded['prerequisite_set'];
        $memberEvidence = $decoded['member_evidence'];

        if (! $this->validPrerequisiteSet($prerequisiteSet)
            || ! $this->validMemberEvidence($memberEvidence, $prerequisiteSet['protected_use_scope'])) {
            return $this->errorResponse('INVALID_REQUEST_SCHEMA', 400);
        }

        try {
            $result = $this->adapter->evaluateSynthetic($prerequisiteSet, $memberEvidence);
        } catch (InvalidArgumentException) {
            return $this->errorResponse('SYNTHETIC_BOUNDARY_REJECTED', 400);
        } catch (Throwable) {
            return $this->errorResponse('INTERNAL_APPLICATION_FAILURE', 500);
        }

        return $this->successResponse($result);
    }

    /** @param array<string, mixed> $prerequisiteSet */
    private function validPrerequisiteSet(array $prerequisiteSet): bool
    {
        if (! $this->hasExactObjectKeys($prerequisiteSet, self::PREREQUISITE_SET_KEYS)
            || ! in_array($prerequisiteSet['state'], ['KNOWN', 'UNKNOWN'], true)
            || ! ($prerequisiteSet['set_identity'] === null
                || $this->nonEmptyString($prerequisiteSet['set_identity']))
            || ! $this->nonEmptyString($prerequisiteSet['protected_use_scope'])
            || ! is_array($prerequisiteSet['required_member_ids'])
            || ! array_is_list($prerequisiteSet['required_member_ids'])) {
            return false;
        }

        foreach ($prerequisiteSet['required_member_ids'] as $identity) {
            if (! $this->nonEmptyString($identity)) {
                return false;
            }
        }

        if (count($prerequisiteSet['required_member_ids'])
            !== count(array_unique($prerequisiteSet['required_member_ids'], SORT_STRING))) {
            return false;
        }

        return $this->validEvidenceContainer(
            $prerequisiteSet['required_bindings'] ?? null,
            $prerequisiteSet['source_evidence'] ?? null,
        ) && $this->validFixtureExtensions($prerequisiteSet['private_fixture_extensions'] ?? null);
    }

    /**
     * @param list<mixed> $memberEvidence
     */
    private function validMemberEvidence(array $memberEvidence, string $protectedUseScope): bool
    {
        foreach ($memberEvidence as $member) {
            if (! $this->hasExactObjectKeys($member, self::MEMBER_KEYS)
                || ! $this->nonEmptyString($member['member_identity'])
                || ! in_array($member['fact_class'], ['ELIGIBILITY', 'CHECKLIST', 'VERIFICATION'], true)
                || $member['protected_use_scope'] !== $protectedUseScope
                || ! in_array($member['prerequisite_outcome'], ['SATISFIED', 'UNSATISFIED', null], true)
                || ! $this->validEvidenceContainer(
                    $member['required_bindings'],
                    $member['source_evidence'],
                )
                || ($member['required_bindings']['purpose'] ?? null) !== $protectedUseScope
                || ! $this->validFixtureExtensions($member['private_fixture_extensions'])) {
                return false;
            }
        }

        return true;
    }

    private function validEvidenceContainer(mixed $requiredBindings, mixed $sourceEvidence): bool
    {
        if (! $this->validBindings($requiredBindings)
            || ! $this->hasExactObjectKeys($sourceEvidence, self::SOURCE_EVIDENCE_KEYS)
            || ($sourceEvidence['record_kind'] ?? null) !== 'SOURCE_EVIDENCE'
            || ! $this->validBindings($sourceEvidence['bindings'] ?? null)
            || $this->canonicalize($requiredBindings)
                !== $this->canonicalize($sourceEvidence['bindings'])
            || ! in_array($sourceEvidence['source_condition'] ?? null, self::SOURCE_CONDITIONS, true)
            || ! $this->validSourceRevision(
                $sourceEvidence['source_revision'] ?? null,
                $sourceEvidence['bindings'],
            )
            || ! $this->booleanOrNull($sourceEvidence['currentness'] ?? null)
            || ! $this->booleanOrNull($sourceEvidence['freshness'] ?? null)
            || ! in_array(
                $sourceEvidence['authoritative_outcome'] ?? null,
                ['COMMITTED', 'REJECTED', 'UNKNOWN'],
                true,
            )) {
            return false;
        }

        return true;
    }

    private function validBindings(mixed $bindings): bool
    {
        if (! $this->hasExactObjectKeys($bindings, self::BINDING_KEYS)
            || ! is_array($bindings['participants'])
            || ! array_is_list($bindings['participants'])
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

        foreach ($bindings['participants'] as $participant) {
            if (! $this->nonEmptyString($participant)) {
                return false;
            }
        }

        return true;
    }

    /** @param array<string, mixed> $bindings */
    private function validSourceRevision(mixed $revision, array $bindings): bool
    {
        return $this->hasExactObjectKeys($revision, self::SOURCE_REVISION_KEYS)
            && $this->nonEmptyString($revision['authority_owner'])
            && $this->nonEmptyString($revision['authority_scope'])
            && $this->nonEmptyString($revision['lineage'])
            && $this->nonEmptyString($revision['aggregate_context'])
            && is_int($revision['value'])
            && $revision['value'] >= 0
            && $revision['authority_owner'] === $bindings['authority_owner']
            && $revision['authority_scope'] === $bindings['authority_scope']
            && $revision['aggregate_context'] === $bindings['aggregate_context'];
    }

    private function validFixtureExtensions(mixed $extensions): bool
    {
        return $this->hasExactObjectKeys($extensions, ['raw_fixture'])
            && is_string($extensions['raw_fixture'])
            && str_starts_with($extensions['raw_fixture'], 'MUST-NOT-LEAK-RR03-PRIVATE');
    }

    /** @param array<string, mixed> $result */
    private function successResponse(array $result): JsonResponse
    {
        $classification = $result['readiness_classification'] ?? null;
        $reasons = $result['rr03_payload']['reason_categories'] ?? null;
        $usable = $result['materialized_projection_usable'] ?? null;
        $condition = $result['condition'] ?? null;
        $syntheticOnly = $result['synthetic_dev_test_only'] ?? null;

        if (! in_array($classification, ['READY', 'NOT_READY', 'UNKNOWN'], true)
            || ! is_array($reasons)
            || ! array_is_list($reasons)
            || count($reasons) !== count(array_unique($reasons, SORT_STRING))
            || ! is_bool($usable)
            || ! in_array($condition, self::CONDITIONS, true)
            || $syntheticOnly !== true
            || ($condition === 'EXACT_PRIVACY_MINIMAL_RR03_PROJECTION_MATERIALIZED') !== $usable) {
            return $this->errorResponse('UNRECOGNIZED_TRANSPORT_MAPPING', 500);
        }

        foreach ($reasons as $reason) {
            if (! is_string($reason) || ! in_array($reason, self::REASON_CATEGORIES, true)) {
                return $this->errorResponse('UNRECOGNIZED_TRANSPORT_MAPPING', 500);
            }
        }

        return response()->json([
            'readiness_classification' => $classification,
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
