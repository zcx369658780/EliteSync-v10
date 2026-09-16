<?php

namespace App\Domain;

final class ProductConnectionStateTransitionEvaluator
{
    public const STATE_NONE = 'CN_NONE';
    public const STATE_PENDING = 'CN_PENDING';
    public const STATE_ACTIVE = 'CN_ACTIVE';
    public const STATE_PAUSED = 'CN_PAUSED';
    public const STATE_CLOSED = 'CN_CLOSED';
    public const STATE_DECLINED = 'CN_DECLINED';
    public const STATE_WITHDRAWN = 'CN_WITHDRAWN';
    public const STATE_EXPIRED = 'CN_EXPIRED';

    public const DERIVED_UNKNOWN = 'UNKNOWN';
    public const TRANSITION_ADMISSIBLE = 'ADMISSIBLE';
    public const TRANSITION_REJECTED = 'REJECTED';

    /** @return list<string> */
    public static function lifecycleVocabulary(): array
    {
        return [
            self::STATE_NONE,
            self::STATE_PENDING,
            self::STATE_ACTIVE,
            self::STATE_PAUSED,
            self::STATE_CLOSED,
            self::STATE_DECLINED,
            self::STATE_WITHDRAWN,
            self::STATE_EXPIRED,
        ];
    }

    /**
     * @param array<string, mixed> $connection
     * @param list<array<string, mixed>> $stateEvidence
     * @return array<string, mixed>
     */
    public static function evaluateCurrent(array $connection, array $stateEvidence): array
    {
        $shapeReason = self::connectionShapeReason($connection);

        if ($shapeReason !== null) {
            return self::currentResult($connection, self::DERIVED_UNKNOWN, [], [$shapeReason]);
        }

        $resolved = self::resolveStateEvidence($connection, $stateEvidence);

        if ($resolved['evidence'] === null) {
            return self::currentResult($connection, self::DERIVED_UNKNOWN, [], [$resolved['reason']]);
        }

        $evidence = $resolved['evidence'];
        $state = $evidence['state'] ?? null;

        if (! in_array($state, self::lifecycleVocabulary(), true)) {
            return self::currentResult(
                $connection,
                self::DERIVED_UNKNOWN,
                [self::stateDependency($evidence)],
                ['INVALID_CONNECTION_STATE'],
            );
        }

        if (! self::stateEvidenceIsUsable($connection, $evidence)) {
            return self::currentResult(
                $connection,
                self::DERIVED_UNKNOWN,
                [self::stateDependency($evidence)],
                ['CURRENT_STATE_NOT_CURRENT_FRESH_BOUND'],
            );
        }

        return self::currentResult($connection, $state, [self::stateDependency($evidence)], []);
    }

    /**
     * @param array<string, mixed> $connection
     * @param list<array<string, mixed>> $stateEvidence
     * @param list<array<string, mixed>> $transitionEvidence
     * @param array<string, mixed>|null $matchResult
     * @return array<string, mixed>
     */
    public static function evaluateTransition(
        array $connection,
        array $stateEvidence,
        array $transitionEvidence,
        ?array $matchResult = null,
    ): array {
        $current = self::evaluateCurrent($connection, $stateEvidence);

        if ($current['classification'] === self::DERIVED_UNKNOWN) {
            return self::transitionResult(
                $connection,
                self::DERIVED_UNKNOWN,
                null,
                null,
                $current['dependency_vector'],
                $current['reasons'],
            );
        }

        $resolved = self::resolveTransitionEvidence($connection, $transitionEvidence);

        if ($resolved['evidence'] === null) {
            return self::transitionResult(
                $connection,
                self::DERIVED_UNKNOWN,
                $current['classification'],
                null,
                $current['dependency_vector'],
                [$resolved['reason']],
            );
        }

        $transition = $resolved['evidence'];
        $dependencies = $current['dependency_vector'];
        $dependencies['transition'] = self::transitionDependency($transition);

        if (! self::transitionEvidenceIsUsable($connection, $transition)) {
            return self::transitionResult(
                $connection,
                self::DERIVED_UNKNOWN,
                $current['classification'],
                $transition['to_state'] ?? null,
                $dependencies,
                ['TRANSITION_NOT_CURRENT_FRESH_BOUND'],
            );
        }

        $fromState = $transition['from_state'] ?? null;
        $toState = $transition['to_state'] ?? null;
        $currentRevision = $current['dependency_vector']['current_state']['source_revision'] ?? null;

        if (
            $fromState !== $current['classification']
            || ($transition['expected_state_revision'] ?? null) !== $currentRevision
        ) {
            return self::transitionResult(
                $connection,
                self::DERIVED_UNKNOWN,
                $current['classification'],
                is_string($toState) ? $toState : null,
                $dependencies,
                ['TRANSITION_CURRENT_CONTEXT_MISMATCH'],
            );
        }

        if (! in_array($toState, self::lifecycleVocabulary(), true)) {
            return self::transitionResult(
                $connection,
                self::DERIVED_UNKNOWN,
                $current['classification'],
                null,
                $dependencies,
                ['INVALID_TARGET_STATE'],
            );
        }

        if (self::isTerminal($current['classification'])) {
            return self::transitionResult(
                $connection,
                self::TRANSITION_REJECTED,
                $current['classification'],
                $toState,
                $dependencies,
                ['TERMINAL_CONNECTION_IDENTITY_CANNOT_REOPEN'],
            );
        }

        if (! self::isAllowedTransition($current['classification'], $toState)) {
            $reason = $current['classification'] === self::STATE_NONE && $toState === self::STATE_ACTIVE
                ? 'DIRECT_NONE_TO_ACTIVE_REJECTED'
                : 'TRANSITION_NOT_ALLOWED';

            return self::transitionResult(
                $connection,
                self::TRANSITION_REJECTED,
                $current['classification'],
                $toState,
                $dependencies,
                [$reason],
            );
        }

        return self::transitionResult(
            $connection,
            self::TRANSITION_ADMISSIBLE,
            $current['classification'],
            $toState,
            $dependencies,
            [],
        );
    }

    /**
     * @param array<string, mixed> $derivedResult
     * @return array<string, mixed>
     */
    public static function invalidate(array $derivedResult, string $dependencyIdentity, string $relation): array
    {
        if (! in_array($relation, [
            CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
            CommonAuthorityEvidenceContract::INVALIDATION_REVOCATION,
            CommonAuthorityEvidenceContract::INVALIDATION_SUPERSESSION,
        ], true)) {
            return $derivedResult;
        }

        $identities = [];
        $currentState = $derivedResult['dependency_vector']['current_state'] ?? null;
        $transition = $derivedResult['dependency_vector']['transition'] ?? null;

        if (is_array($currentState)) {
            $identities[] = $currentState['state_evidence_identity'] ?? null;
        }

        if (is_array($transition)) {
            $identities[] = $transition['transition_identity'] ?? null;
        }

        if (! in_array($dependencyIdentity, $identities, true)) {
            return $derivedResult;
        }

        $invalidated = $derivedResult;
        $invalidated['classification'] = self::DERIVED_UNKNOWN;
        $invalidated['connection_active_for_downstream_consideration'] = false;
        $invalidated['valid_for_protected_use'] = false;
        $invalidated['invalidation'] = [
            'dependency_identity' => $dependencyIdentity,
            'relation' => $relation,
        ];
        $invalidated['lifecycle_reset'] = false;
        $invalidated['connection_reopened'] = false;
        $invalidated['reasons'] = ['DEPENDENCY_INVALIDATED'];

        return $invalidated;
    }

    /** @param array<string, mixed> $connection */
    private static function connectionShapeReason(array $connection): ?string
    {
        $identity = $connection['connection_identity'] ?? null;
        $participants = $connection['participants'] ?? null;
        $scope = $connection['protected_use_scope'] ?? null;

        if (! is_string($identity) || $identity === '') {
            return 'CONNECTION_IDENTITY_REQUIRED';
        }

        if (
            ! is_array($participants)
            || count($participants) !== 2
            || count(array_unique($participants)) !== 2
            || ! self::allNonEmptyStrings($participants)
        ) {
            return 'EXACTLY_TWO_PARTICIPANTS_REQUIRED';
        }

        if (! is_string($scope) || $scope === '') {
            return 'PROTECTED_USE_SCOPE_REQUIRED';
        }

        return null;
    }

    /**
     * @param array<string, mixed> $connection
     * @param list<array<string, mixed>> $evidenceSet
     * @return array{evidence: ?array, reason: string}
     */
    private static function resolveStateEvidence(array $connection, array $evidenceSet): array
    {
        if ($evidenceSet === []) {
            return ['evidence' => null, 'reason' => 'MISSING_CURRENT_STATE_EVIDENCE'];
        }

        foreach ($evidenceSet as $evidence) {
            if (($evidence['connection_identity'] ?? null) !== $connection['connection_identity']) {
                return ['evidence' => null, 'reason' => 'CROSS_CONNECTION_STATE_EVIDENCE'];
            }

            if (! self::sameParticipants($evidence['participants'] ?? null, $connection['participants'])) {
                return ['evidence' => null, 'reason' => 'STATE_PARTICIPANT_MISMATCH'];
            }
        }

        return self::resolveDuplicates(
            $evidenceSet,
            'state_evidence_identity',
            'CONFLICTING_STATE_EVIDENCE_IDENTITY',
            'INCOMPARABLE_DUPLICATE_STATE_EVIDENCE',
            'CONFLICTING_EQUAL_REVISION_STATE_EVIDENCE',
            static fn (array $evidence): array => self::stateSemanticSignature($evidence),
        );
    }

    /**
     * @param array<string, mixed> $connection
     * @param list<array<string, mixed>> $evidenceSet
     * @return array{evidence: ?array, reason: string}
     */
    private static function resolveTransitionEvidence(array $connection, array $evidenceSet): array
    {
        if ($evidenceSet === []) {
            return ['evidence' => null, 'reason' => 'MISSING_TRANSITION_EVIDENCE'];
        }

        foreach ($evidenceSet as $evidence) {
            if (($evidence['connection_identity'] ?? null) !== $connection['connection_identity']) {
                return ['evidence' => null, 'reason' => 'CROSS_CONNECTION_TRANSITION_EVIDENCE'];
            }

            if (! self::sameParticipants($evidence['participants'] ?? null, $connection['participants'])) {
                return ['evidence' => null, 'reason' => 'TRANSITION_PARTICIPANT_MISMATCH'];
            }
        }

        return self::resolveDuplicates(
            $evidenceSet,
            'transition_identity',
            'CONFLICTING_TRANSITION_IDENTITY',
            'INCOMPARABLE_DUPLICATE_TRANSITION_EVIDENCE',
            'CONFLICTING_EQUAL_REVISION_TRANSITION_EVIDENCE',
            static fn (array $evidence): array => self::transitionSemanticSignature($evidence),
        );
    }

    /**
     * @param list<array<string, mixed>> $evidenceSet
     * @param callable(array<string, mixed>): array<string, mixed> $signature
     * @return array{evidence: ?array, reason: string}
     */
    private static function resolveDuplicates(
        array $evidenceSet,
        string $identityKey,
        string $identityReason,
        string $incomparableReason,
        string $conflictReason,
        callable $signature,
    ): array {
        $selected = array_shift($evidenceSet);

        if (! is_array($selected) || ! isset($selected['source_evidence']['source_revision'])) {
            return ['evidence' => null, 'reason' => 'INVALID_EVIDENCE_SHAPE'];
        }

        foreach ($evidenceSet as $candidate) {
            if (
                ($candidate[$identityKey] ?? null) !== ($selected[$identityKey] ?? null)
                || ! isset($candidate['source_evidence']['source_revision'])
            ) {
                return ['evidence' => null, 'reason' => $identityReason];
            }

            $comparison = CommonAuthorityEvidenceContract::compareSourceRevisions(
                $selected['source_evidence']['source_revision'],
                $candidate['source_evidence']['source_revision'],
            );

            if ($comparison === CommonAuthorityEvidenceContract::CONDITION_INCOMPARABLE) {
                return ['evidence' => null, 'reason' => $incomparableReason];
            }

            if ($comparison === CommonAuthorityEvidenceContract::REVISION_OLDER) {
                $selected = $candidate;
                continue;
            }

            if (
                $comparison === CommonAuthorityEvidenceContract::REVISION_EQUAL
                && $signature($selected) !== $signature($candidate)
            ) {
                return ['evidence' => null, 'reason' => $conflictReason];
            }
        }

        return ['evidence' => $selected, 'reason' => ''];
    }

    /**
     * @param array<string, mixed> $connection
     * @param array<string, mixed> $evidence
     */
    private static function stateEvidenceIsUsable(array $connection, array $evidence): bool
    {
        $evaluation = CommonAuthorityEvidenceContract::evaluateProtected(
            $evidence['source_evidence'] ?? [],
            $evidence['required_bindings'] ?? [],
        );

        return $evaluation['satisfied']
            && ($evidence['required_bindings']['subject'] ?? null) === $connection['connection_identity']
            && ($evidence['required_bindings']['aggregate_context'] ?? null) === $connection['connection_identity']
            && ($evidence['required_bindings']['lifecycle_identity'] ?? null) === $connection['connection_identity']
            && self::sameParticipants($evidence['required_bindings']['participants'] ?? null, $connection['participants'])
            && ($evidence['required_bindings']['purpose'] ?? null) === $connection['protected_use_scope']
            && ($evidence['required_bindings']['terminal'] ?? null) === self::isTerminal($evidence['state'] ?? '');
    }

    /**
     * @param array<string, mixed> $connection
     * @param array<string, mixed> $evidence
     */
    private static function transitionEvidenceIsUsable(array $connection, array $evidence): bool
    {
        $evaluation = CommonAuthorityEvidenceContract::evaluateProtected(
            $evidence['source_evidence'] ?? [],
            $evidence['required_bindings'] ?? [],
        );

        return $evaluation['satisfied']
            && ($evidence['required_bindings']['subject'] ?? null) === $connection['connection_identity']
            && ($evidence['required_bindings']['aggregate_context'] ?? null) === $connection['connection_identity']
            && ($evidence['required_bindings']['lifecycle_identity'] ?? null) === $connection['connection_identity']
            && self::sameParticipants($evidence['required_bindings']['participants'] ?? null, $connection['participants'])
            && ($evidence['required_bindings']['purpose'] ?? null) === $connection['protected_use_scope'];
    }

    private static function isAllowedTransition(string $from, string $to): bool
    {
        return in_array($from.'->'.$to, [
            self::STATE_NONE.'->'.self::STATE_PENDING,
            self::STATE_PENDING.'->'.self::STATE_ACTIVE,
            self::STATE_PENDING.'->'.self::STATE_DECLINED,
            self::STATE_PENDING.'->'.self::STATE_WITHDRAWN,
            self::STATE_PENDING.'->'.self::STATE_EXPIRED,
            self::STATE_ACTIVE.'->'.self::STATE_PAUSED,
            self::STATE_ACTIVE.'->'.self::STATE_CLOSED,
            self::STATE_PAUSED.'->'.self::STATE_ACTIVE,
            self::STATE_PAUSED.'->'.self::STATE_CLOSED,
        ], true);
    }

    private static function isTerminal(string $state): bool
    {
        return in_array($state, [
            self::STATE_CLOSED,
            self::STATE_DECLINED,
            self::STATE_WITHDRAWN,
            self::STATE_EXPIRED,
        ], true);
    }

    /**
     * @param array<string, mixed> $connection
     * @param array<string, mixed> $dependencies
     * @param list<string> $reasons
     * @return array<string, mixed>
     */
    private static function currentResult(
        array $connection,
        string $classification,
        array $dependencies,
        array $reasons,
    ): array {
        $active = $classification === self::STATE_ACTIVE;

        return self::baseResult($connection, [
            'record_kind' => 'PRODUCT_CONNECTION_CURRENT_STATE_DERIVATION',
            'classification' => $classification,
            'current_state' => $classification === self::DERIVED_UNKNOWN ? null : $classification,
            'proposed_state' => null,
            'dependency_vector' => ['current_state' => $dependencies[0] ?? null],
            'reasons' => $reasons,
            'connection_active_for_downstream_consideration' => $active,
            'valid_for_protected_use' => $classification !== self::DERIVED_UNKNOWN,
        ]);
    }

    /**
     * @param array<string, mixed> $connection
     * @param array<string, mixed> $dependencies
     * @param list<string> $reasons
     * @return array<string, mixed>
     */
    private static function transitionResult(
        array $connection,
        string $classification,
        ?string $currentState,
        ?string $proposedState,
        array $dependencies,
        array $reasons,
    ): array {
        return self::baseResult($connection, [
            'record_kind' => 'PRODUCT_CONNECTION_TRANSITION_DERIVATION',
            'classification' => $classification,
            'current_state' => $currentState,
            'proposed_state' => $proposedState,
            'dependency_vector' => $dependencies,
            'reasons' => $reasons,
            'connection_active_for_downstream_consideration' => $currentState === self::STATE_ACTIVE,
            'valid_for_protected_use' => $classification === self::TRANSITION_ADMISSIBLE,
        ]);
    }

    /**
     * @param array<string, mixed> $connection
     * @param array<string, mixed> $specific
     * @return array<string, mixed>
     */
    private static function baseResult(array $connection, array $specific): array
    {
        return $specific + [
            'connection_identity' => $connection['connection_identity'] ?? null,
            'participants' => $connection['participants'] ?? [],
            'source_authority' => false,
            'connection_created' => false,
            'connection_activated' => false,
            'match_substituted_for_connection' => false,
            'messaging_consent_granted' => false,
            'conversation_granted' => false,
            'relationship_authority' => false,
            'home_action_authority' => false,
            'notification_authority' => false,
            'launch_authority' => false,
            'bearer_capability' => false,
            'ranking_computed' => false,
            'compatibility_total_computed' => false,
            'desirability_computed' => false,
            'person_worth_computed' => false,
            'source_evidence_mutated' => false,
            'lifecycle_reset' => false,
            'connection_reopened' => false,
        ];
    }

    /** @param array<string, mixed> $evidence */
    private static function stateDependency(array $evidence): array
    {
        return [
            'state_evidence_identity' => $evidence['state_evidence_identity'] ?? null,
            'connection_identity' => $evidence['connection_identity'] ?? null,
            'state' => $evidence['state'] ?? null,
            'source_revision' => $evidence['source_evidence']['source_revision'] ?? null,
            'source_condition' => $evidence['source_evidence']['source_condition'] ?? null,
        ];
    }

    /** @param array<string, mixed> $evidence */
    private static function transitionDependency(array $evidence): array
    {
        return [
            'transition_identity' => $evidence['transition_identity'] ?? null,
            'connection_identity' => $evidence['connection_identity'] ?? null,
            'from_state' => $evidence['from_state'] ?? null,
            'to_state' => $evidence['to_state'] ?? null,
            'source_revision' => $evidence['source_evidence']['source_revision'] ?? null,
            'source_condition' => $evidence['source_evidence']['source_condition'] ?? null,
        ];
    }

    /** @param array<string, mixed> $evidence */
    private static function stateSemanticSignature(array $evidence): array
    {
        return [
            'state_evidence_identity' => $evidence['state_evidence_identity'] ?? null,
            'connection_identity' => $evidence['connection_identity'] ?? null,
            'participants' => $evidence['participants'] ?? null,
            'state' => $evidence['state'] ?? null,
            'required_bindings' => $evidence['required_bindings'] ?? null,
            'source_evidence' => $evidence['source_evidence'] ?? null,
        ];
    }

    /** @param array<string, mixed> $evidence */
    private static function transitionSemanticSignature(array $evidence): array
    {
        return [
            'transition_identity' => $evidence['transition_identity'] ?? null,
            'connection_identity' => $evidence['connection_identity'] ?? null,
            'participants' => $evidence['participants'] ?? null,
            'from_state' => $evidence['from_state'] ?? null,
            'to_state' => $evidence['to_state'] ?? null,
            'expected_state_revision' => $evidence['expected_state_revision'] ?? null,
            'required_bindings' => $evidence['required_bindings'] ?? null,
            'source_evidence' => $evidence['source_evidence'] ?? null,
        ];
    }

    /** @param mixed $left @param mixed $right */
    private static function sameParticipants(mixed $left, mixed $right): bool
    {
        if (! is_array($left) || ! is_array($right) || ! self::allNonEmptyStrings($left) || ! self::allNonEmptyStrings($right)) {
            return false;
        }

        sort($left);
        sort($right);

        return $left === $right;
    }

    /** @param list<mixed> $values */
    private static function allNonEmptyStrings(array $values): bool
    {
        foreach ($values as $value) {
            if (! is_string($value) || $value === '') {
                return false;
            }
        }

        return true;
    }
}
