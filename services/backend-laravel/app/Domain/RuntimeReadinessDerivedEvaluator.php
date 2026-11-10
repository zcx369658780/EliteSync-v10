<?php

namespace App\Domain;

final class RuntimeReadinessDerivedEvaluator
{
    public const FACT_ELIGIBILITY = 'ELIGIBILITY';
    public const FACT_CHECKLIST = 'CHECKLIST';
    public const FACT_VERIFICATION = 'VERIFICATION';
    public const FACT_EFFECTIVE_READINESS = 'EFFECTIVE_READINESS';
    public const FACT_PRESENTATION = 'PRESENTATION';

    public const SET_KNOWN = 'KNOWN_PREREQUISITE_SET';
    public const SET_UNKNOWN = 'UNKNOWN_PREREQUISITE_SET';

    public const OUTCOME_SATISFIED = 'SATISFIED';
    public const OUTCOME_UNSATISFIED = 'UNSATISFIED';

    public const READINESS_READY = 'READY';
    public const READINESS_NOT_READY = 'NOT_READY';
    public const READINESS_UNKNOWN = 'UNKNOWN';

    /**
     * @param array<string, mixed> $prerequisiteSet
     * @param list<array<string, mixed>> $memberEvidence
     * @return array<string, mixed>
     */
    public static function derive(array $prerequisiteSet, array $memberEvidence): array
    {
        $setDependency = self::setDependency($prerequisiteSet);
        $dependencyVector = [
            'prerequisite_set' => $setDependency,
            'members' => [],
        ];

        if (($prerequisiteSet['state'] ?? null) === self::SET_UNKNOWN) {
            return self::result(
                self::READINESS_UNKNOWN,
                $prerequisiteSet,
                $dependencyVector,
                ['UNKNOWN_PREREQUISITE_SET'],
            );
        }

        if (($prerequisiteSet['state'] ?? null) !== self::SET_KNOWN) {
            return self::result(
                self::READINESS_UNKNOWN,
                $prerequisiteSet,
                $dependencyVector,
                ['INVALID_PREREQUISITE_SET_STATE'],
            );
        }

        $requiredMemberIds = $prerequisiteSet['required_member_ids'] ?? null;

        if (! is_array($requiredMemberIds) || count($requiredMemberIds) !== count(array_unique($requiredMemberIds))) {
            return self::result(
                self::READINESS_UNKNOWN,
                $prerequisiteSet,
                $dependencyVector,
                ['INVALID_EXACT_PREREQUISITE_SET'],
            );
        }

        $setEvaluation = CommonAuthorityEvidenceContract::evaluateProtected(
            $prerequisiteSet['source_evidence'] ?? [],
            $prerequisiteSet['required_bindings'] ?? [],
        );

        if (
            ($prerequisiteSet['protected_use_scope'] ?? null) === null
            || ($prerequisiteSet['required_bindings']['purpose'] ?? null) !== $prerequisiteSet['protected_use_scope']
            || ! $setEvaluation['satisfied']
        ) {
            return self::result(
                self::READINESS_UNKNOWN,
                $prerequisiteSet,
                $dependencyVector,
                ['PREREQUISITE_SET_NOT_CURRENT_FRESH_AUTHORITATIVE'],
            );
        }

        $unknownReasons = [];
        $hasAuthoritativeNegative = false;

        foreach ($requiredMemberIds as $requiredMemberId) {
            if (! is_string($requiredMemberId) || $requiredMemberId === '') {
                $unknownReasons[] = 'INVALID_REQUIRED_MEMBER_ID';
                continue;
            }

            $duplicates = array_values(array_filter(
                $memberEvidence,
                static fn (array $member): bool => ($member['member_identity'] ?? null) === $requiredMemberId,
            ));

            if ($duplicates === []) {
                $unknownReasons[] = 'MISSING_REQUIRED_MEMBER:'.$requiredMemberId;
                continue;
            }

            $resolved = self::resolveDuplicateMemberEvidence($duplicates);

            if ($resolved['member'] === null) {
                $unknownReasons[] = $resolved['reason'].':'.$requiredMemberId;
                continue;
            }

            $member = $resolved['member'];
            $dependencyVector['members'][] = self::memberDependency($member);

            if (! in_array($member['fact_class'] ?? null, [
                self::FACT_ELIGIBILITY,
                self::FACT_CHECKLIST,
                self::FACT_VERIFICATION,
            ], true)) {
                $unknownReasons[] = 'INVALID_MEMBER_FACT_CLASS:'.$requiredMemberId;
                continue;
            }

            if (
                ($member['protected_use_scope'] ?? null) !== $prerequisiteSet['protected_use_scope']
                || ($member['required_bindings']['purpose'] ?? null) !== $prerequisiteSet['protected_use_scope']
            ) {
                $unknownReasons[] = 'PROTECTED_USE_SCOPE_MISMATCH:'.$requiredMemberId;
                continue;
            }

            $memberEvaluation = CommonAuthorityEvidenceContract::evaluateProtected(
                $member['source_evidence'] ?? [],
                $member['required_bindings'] ?? [],
            );

            if (! $memberEvaluation['satisfied']) {
                $condition = $member['source_evidence']['source_condition'] ?? 'MISSING';
                $unknownReasons[] = 'MEMBER_NOT_CURRENT_FRESH_AUTHORITATIVE:'.$requiredMemberId.':'.$condition;
                continue;
            }

            if (($member['prerequisite_outcome'] ?? null) === self::OUTCOME_UNSATISFIED) {
                $hasAuthoritativeNegative = true;
                continue;
            }

            if (($member['prerequisite_outcome'] ?? null) !== self::OUTCOME_SATISFIED) {
                $unknownReasons[] = 'UNKNOWN_MEMBER_OUTCOME:'.$requiredMemberId;
            }
        }

        if ($unknownReasons !== []) {
            return self::result(
                self::READINESS_UNKNOWN,
                $prerequisiteSet,
                $dependencyVector,
                $unknownReasons,
            );
        }

        if ($hasAuthoritativeNegative) {
            return self::result(
                self::READINESS_NOT_READY,
                $prerequisiteSet,
                $dependencyVector,
                ['AUTHORITATIVE_REQUIRED_MEMBER_UNSATISFIED'],
            );
        }

        return self::result(
            self::READINESS_READY,
            $prerequisiteSet,
            $dependencyVector,
            [],
        );
    }

    /**
     * @param array<string, mixed> $derivedResult
     * @return array<string, mixed>
     */
    public static function invalidate(
        array $derivedResult,
        string $dependencyIdentity,
        string $relation,
    ): array {
        if (! in_array($relation, [
            CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
            CommonAuthorityEvidenceContract::INVALIDATION_REVOCATION,
            CommonAuthorityEvidenceContract::INVALIDATION_SUPERSESSION,
        ], true)) {
            return $derivedResult;
        }

        $identities = [$derivedResult['dependency_vector']['prerequisite_set']['set_identity'] ?? null];

        foreach ($derivedResult['dependency_vector']['members'] ?? [] as $member) {
            $identities[] = $member['member_identity'] ?? null;
        }

        if (! in_array($dependencyIdentity, $identities, true)) {
            return $derivedResult;
        }

        $invalidated = $derivedResult;
        $invalidated['classification'] = self::READINESS_UNKNOWN;
        $invalidated['valid_for_protected_use'] = false;
        $invalidated['invalidation'] = [
            'dependency_identity' => $dependencyIdentity,
            'relation' => $relation,
        ];
        $invalidated['reasons'] = ['DEPENDENCY_INVALIDATED'];

        return $invalidated;
    }

    /**
     * @param list<array<string, mixed>> $duplicates
     * @return array{member: ?array, reason: string}
     */
    private static function resolveDuplicateMemberEvidence(array $duplicates): array
    {
        $selected = array_shift($duplicates);

        if (! is_array($selected) || ! isset($selected['source_evidence']['source_revision'])) {
            return ['member' => null, 'reason' => 'INVALID_MEMBER_EVIDENCE'];
        }

        foreach ($duplicates as $candidate) {
            if (! isset($candidate['source_evidence']['source_revision'])) {
                return ['member' => null, 'reason' => 'INVALID_MEMBER_EVIDENCE'];
            }

            $comparison = CommonAuthorityEvidenceContract::compareSourceRevisions(
                $selected['source_evidence']['source_revision'],
                $candidate['source_evidence']['source_revision'],
            );

            if ($comparison === CommonAuthorityEvidenceContract::CONDITION_INCOMPARABLE) {
                return ['member' => null, 'reason' => 'INCOMPARABLE_DUPLICATE_EVIDENCE'];
            }

            if ($comparison === CommonAuthorityEvidenceContract::REVISION_OLDER) {
                $selected = $candidate;
                continue;
            }

            if (
                $comparison === CommonAuthorityEvidenceContract::REVISION_EQUAL
                && self::memberSemanticSignature($selected) !== self::memberSemanticSignature($candidate)
            ) {
                return ['member' => null, 'reason' => 'CONFLICTING_DUPLICATE_EVIDENCE'];
            }
        }

        return ['member' => $selected, 'reason' => ''];
    }

    /**
     * @param array<string, mixed> $member
     * @return array<string, mixed>
     */
    private static function memberSemanticSignature(array $member): array
    {
        return [
            'member_identity' => $member['member_identity'] ?? null,
            'fact_class' => $member['fact_class'] ?? null,
            'protected_use_scope' => $member['protected_use_scope'] ?? null,
            'required_bindings' => $member['required_bindings'] ?? null,
            'source_evidence' => $member['source_evidence'] ?? null,
            'prerequisite_outcome' => $member['prerequisite_outcome'] ?? null,
        ];
    }

    /**
     * @param array<string, mixed> $prerequisiteSet
     * @return array<string, mixed>
     */
    private static function setDependency(array $prerequisiteSet): array
    {
        return [
            'set_identity' => $prerequisiteSet['set_identity'] ?? null,
            'source_revision' => $prerequisiteSet['source_evidence']['source_revision'] ?? null,
            'source_condition' => $prerequisiteSet['source_evidence']['source_condition'] ?? null,
        ];
    }

    /**
     * @param array<string, mixed> $member
     * @return array<string, mixed>
     */
    private static function memberDependency(array $member): array
    {
        return [
            'member_identity' => $member['member_identity'],
            'fact_class' => $member['fact_class'] ?? null,
            'source_revision' => $member['source_evidence']['source_revision'] ?? null,
            'source_condition' => $member['source_evidence']['source_condition'] ?? null,
            'prerequisite_outcome' => $member['prerequisite_outcome'] ?? null,
        ];
    }

    /**
     * @param array<string, mixed> $prerequisiteSet
     * @param array<string, mixed> $dependencyVector
     * @param list<string> $reasons
     * @return array<string, mixed>
     */
    private static function result(
        string $classification,
        array $prerequisiteSet,
        array $dependencyVector,
        array $reasons,
    ): array {
        return [
            'record_kind' => 'RUNTIME_READINESS_DERIVATION',
            'fact_class' => self::FACT_EFFECTIVE_READINESS,
            'classification' => $classification,
            'prerequisite_set_identity' => $prerequisiteSet['set_identity'] ?? null,
            'protected_use_scope' => $prerequisiteSet['protected_use_scope'] ?? null,
            'dependency_vector' => $dependencyVector,
            'reasons' => $reasons,
            'valid_for_protected_use' => $classification !== self::READINESS_UNKNOWN,
            'source_authority' => false,
            'permission' => false,
            'bearer_capability' => false,
            'reusable_protected_action_grant' => false,
            'launch_eligibility' => false,
            'verification_truth' => false,
            'match_authority' => false,
            'connection_authority' => false,
            'consent_authority' => false,
            'conversation_authority' => false,
            'source_evidence_repaired' => false,
            'source_evidence_mutated' => false,
        ];
    }
}
