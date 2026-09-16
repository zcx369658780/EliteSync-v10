<?php

namespace App\Domain;

final class MessagingConsentConversationLiveGateEvaluator
{
    public const STATE_NONE = 'MC_NONE';
    public const STATE_PENDING = 'MC_PENDING';
    public const STATE_ACTIVE = 'MC_ACTIVE';
    public const STATE_DECLINED = 'MC_DECLINED';
    public const STATE_WITHDRAWN = 'MC_WITHDRAWN';
    public const STATE_REVOKED = 'MC_REVOKED';

    public const PURPOSE_LIVE_READ = 'CONVERSATION_LIVE_READ';
    public const PURPOSE_LIVE_SEND = 'CONVERSATION_LIVE_SEND';

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
            self::STATE_DECLINED,
            self::STATE_WITHDRAWN,
            self::STATE_REVOKED,
        ];
    }

    /**
     * @param array<string, mixed> $consent
     * @param array<string, mixed> $connection
     * @param list<array<string, mixed>> $connectionEvidence
     * @param list<array<string, mixed>> $consentStateEvidence
     * @param list<array<string, mixed>> $transitionEvidence
     * @return array<string, mixed>
     */
    public static function evaluateTransition(
        array $consent,
        array $connection,
        array $connectionEvidence,
        array $consentStateEvidence,
        array $transitionEvidence,
    ): array {
        $shapeReason = self::consentShapeReason($consent);

        if ($shapeReason !== null) {
            return self::transitionResult($consent, self::DERIVED_UNKNOWN, null, null, [], [$shapeReason]);
        }

        $connectionResult = ProductConnectionStateTransitionEvaluator::evaluateCurrent($connection, $connectionEvidence);

        if (! self::connectionMatchesConsent($connection, $consent) || $connectionResult['classification'] === ProductConnectionStateTransitionEvaluator::DERIVED_UNKNOWN) {
            return self::transitionResult(
                $consent,
                self::DERIVED_UNKNOWN,
                null,
                null,
                ['connection' => $connectionResult['dependency_vector']['current_state'] ?? null],
                ['CONNECTION_CONTEXT_NOT_CURRENT_FRESH_BOUND'],
            );
        }

        $stateResolution = self::resolveConsentEvidence($consent, $consentStateEvidence);

        if ($stateResolution['evidence'] === null) {
            return self::transitionResult(
                $consent,
                self::DERIVED_UNKNOWN,
                null,
                null,
                ['connection' => $connectionResult['dependency_vector']['current_state'] ?? null],
                [$stateResolution['reason']],
            );
        }

        $stateEvidence = $stateResolution['evidence'];
        $currentState = $stateEvidence['state'] ?? null;
        $dependencies = [
            'connection' => $connectionResult['dependency_vector']['current_state'] ?? null,
            'consent_state' => self::consentDependency($stateEvidence),
        ];

        if (! in_array($currentState, self::lifecycleVocabulary(), true)) {
            return self::transitionResult($consent, self::DERIVED_UNKNOWN, null, null, $dependencies, ['INVALID_CONSENT_STATE']);
        }

        if (! self::consentEvidenceIsUsable($consent, $stateEvidence)) {
            return self::transitionResult(
                $consent,
                self::DERIVED_UNKNOWN,
                $currentState,
                null,
                $dependencies,
                ['CONSENT_STATE_NOT_CURRENT_FRESH_BOUND'],
            );
        }

        $transitionResolution = self::resolveTransitionEvidence($consent, $transitionEvidence);

        if ($transitionResolution['evidence'] === null) {
            return self::transitionResult(
                $consent,
                self::DERIVED_UNKNOWN,
                $currentState,
                null,
                $dependencies,
                [$transitionResolution['reason']],
            );
        }

        $transition = $transitionResolution['evidence'];
        $dependencies['transition'] = self::transitionDependency($transition);

        if (! self::transitionEvidenceIsUsable($consent, $transition)) {
            return self::transitionResult(
                $consent,
                self::DERIVED_UNKNOWN,
                $currentState,
                $transition['to_state'] ?? null,
                $dependencies,
                ['CONSENT_TRANSITION_NOT_CURRENT_FRESH_BOUND'],
            );
        }

        $toState = $transition['to_state'] ?? null;
        $actor = $transition['actor'] ?? null;

        if (
            ($transition['from_state'] ?? null) !== $currentState
            || ($transition['expected_state_revision'] ?? null) !== ($stateEvidence['source_evidence']['source_revision'] ?? null)
        ) {
            return self::transitionResult(
                $consent,
                self::DERIVED_UNKNOWN,
                $currentState,
                is_string($toState) ? $toState : null,
                $dependencies,
                ['CONSENT_CURRENT_CONTEXT_MISMATCH'],
            );
        }

        if (! is_string($actor) || ! in_array($actor, $consent['participants'], true)) {
            return self::transitionResult(
                $consent,
                self::DERIVED_UNKNOWN,
                $currentState,
                is_string($toState) ? $toState : null,
                $dependencies,
                ['TRANSITION_ACTOR_NOT_EXACT_PARTICIPANT'],
            );
        }

        if (! in_array($toState, self::lifecycleVocabulary(), true)) {
            return self::transitionResult(
                $consent,
                self::TRANSITION_REJECTED,
                $currentState,
                is_string($toState) ? $toState : null,
                $dependencies,
                ['NON_CANONICAL_OR_FORBIDDEN_TARGET_STATE'],
            );
        }

        if (self::isTerminal($currentState)) {
            return self::transitionResult(
                $consent,
                self::TRANSITION_REJECTED,
                $currentState,
                $toState,
                $dependencies,
                ['TERMINAL_CONSENT_IDENTITY_CANNOT_REOPEN'],
            );
        }

        if (! self::isAllowedTransition($currentState, $toState)) {
            return self::transitionResult(
                $consent,
                self::TRANSITION_REJECTED,
                $currentState,
                $toState,
                $dependencies,
                ['CONSENT_TRANSITION_NOT_ALLOWED'],
            );
        }

        if (
            $currentState === self::STATE_NONE
            && $toState === self::STATE_PENDING
            && $connectionResult['classification'] !== ProductConnectionStateTransitionEvaluator::STATE_ACTIVE
        ) {
            return self::transitionResult(
                $consent,
                self::TRANSITION_REJECTED,
                $currentState,
                $toState,
                $dependencies,
                ['CONSENT_REQUEST_REQUIRES_CURRENT_ACTIVE_CONNECTION'],
            );
        }

        $roleReason = self::transitionRoleReason($consent, $currentState, $toState, $actor);

        if ($roleReason !== null) {
            return self::transitionResult(
                $consent,
                self::TRANSITION_REJECTED,
                $currentState,
                $toState,
                $dependencies,
                [$roleReason],
            );
        }

        return self::transitionResult(
            $consent,
            self::TRANSITION_ADMISSIBLE,
            $currentState,
            $toState,
            $dependencies,
            [],
        );
    }

    /**
     * @param array<string, mixed> $connection
     * @param list<array<string, mixed>> $connectionEvidence
     * @param array<string, mixed> $readConsent
     * @param list<array<string, mixed>> $readConsentEvidence
     * @param array<string, mixed> $sendConsent
     * @param list<array<string, mixed>> $sendConsentEvidence
     * @return array<string, mixed>
     */
    public static function evaluateLiveGates(
        array $connection,
        array $connectionEvidence,
        array $readConsent,
        array $readConsentEvidence,
        array $sendConsent,
        array $sendConsentEvidence,
    ): array {
        $connectionResult = ProductConnectionStateTransitionEvaluator::evaluateCurrent($connection, $connectionEvidence);
        $connectionActive = $connectionResult['classification'] === ProductConnectionStateTransitionEvaluator::STATE_ACTIVE
            && ($connectionResult['connection_active_for_downstream_consideration'] ?? false) === true;
        $read = self::evaluateConsentCurrent($readConsent, $readConsentEvidence, self::PURPOSE_LIVE_READ, $connection);
        $send = self::evaluateConsentCurrent($sendConsent, $sendConsentEvidence, self::PURPOSE_LIVE_SEND, $connection);

        $liveReadAllowed = $connectionActive && $read['state'] === self::STATE_ACTIVE;
        $liveSendAllowed = $connectionActive && $send['state'] === self::STATE_ACTIVE;

        return self::gateResult(
            $connection,
            $readConsent,
            $sendConsent,
            $liveReadAllowed,
            $liveSendAllowed,
            [
                'connection' => $connectionResult['dependency_vector']['current_state'] ?? null,
                'read_consent' => $read['dependency'],
                'send_consent' => $send['dependency'],
            ],
            [
                'connection' => $connectionActive ? [] : ['CURRENT_ACTIVE_CONNECTION_NOT_ESTABLISHED'],
                'read' => $read['reasons'],
                'send' => $send['reasons'],
            ],
        );
    }

    /**
     * @param array<string, mixed> $gateResult
     * @return array<string, mixed>
     */
    public static function invalidateLiveGate(array $gateResult, string $dependencyIdentity, string $relation): array
    {
        if (! in_array($relation, [
            CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
            CommonAuthorityEvidenceContract::INVALIDATION_REVOCATION,
            CommonAuthorityEvidenceContract::INVALIDATION_SUPERSESSION,
        ], true)) {
            return $gateResult;
        }

        $connectionIdentity = $gateResult['dependency_vector']['connection']['state_evidence_identity'] ?? null;
        $readIdentity = $gateResult['dependency_vector']['read_consent']['consent_evidence_identity'] ?? null;
        $sendIdentity = $gateResult['dependency_vector']['send_consent']['consent_evidence_identity'] ?? null;

        if (! in_array($dependencyIdentity, [$connectionIdentity, $readIdentity, $sendIdentity], true)) {
            return $gateResult;
        }

        $invalidated = $gateResult;

        if ($dependencyIdentity === $connectionIdentity) {
            $invalidated['live_read_allowed'] = false;
            $invalidated['live_send_allowed'] = false;
        }

        if ($dependencyIdentity === $readIdentity) {
            $invalidated['live_read_allowed'] = false;
        }

        if ($dependencyIdentity === $sendIdentity) {
            $invalidated['live_send_allowed'] = false;
        }

        $invalidated['invalidation'] = [
            'dependency_identity' => $dependencyIdentity,
            'relation' => $relation,
        ];
        $invalidated['valid_for_live_read'] = $invalidated['live_read_allowed'];
        $invalidated['valid_for_live_send'] = $invalidated['live_send_allowed'];
        $invalidated['connection_lifecycle_reset'] = false;
        $invalidated['consent_lifecycle_reset'] = false;
        $invalidated['connection_reopened'] = false;
        $invalidated['consent_reopened'] = false;

        return $invalidated;
    }

    /** @param array<string, mixed> $consent */
    private static function consentShapeReason(array $consent): ?string
    {
        foreach (['consent_identity', 'connection_identity', 'requester', 'recipient', 'purpose'] as $key) {
            if (! is_string($consent[$key] ?? null) || $consent[$key] === '') {
                return 'CONSENT_BINDING_REQUIRED:'.$key;
            }
        }

        $participants = $consent['participants'] ?? null;

        if (
            ! is_array($participants)
            || count($participants) !== 2
            || count(array_unique($participants)) !== 2
            || ! self::allNonEmptyStrings($participants)
        ) {
            return 'EXACTLY_TWO_CONSENT_PARTICIPANTS_REQUIRED';
        }

        if (
            ! in_array($consent['requester'], $participants, true)
            || ! in_array($consent['recipient'], $participants, true)
            || $consent['requester'] === $consent['recipient']
        ) {
            return 'REQUESTER_RECIPIENT_BINDING_INVALID';
        }

        if (! in_array($consent['purpose'], [self::PURPOSE_LIVE_READ, self::PURPOSE_LIVE_SEND], true)) {
            return 'CONVERSATION_PURPOSE_REQUIRED';
        }

        return null;
    }

    /** @param array<string, mixed> $connection @param array<string, mixed> $consent */
    private static function connectionMatchesConsent(array $connection, array $consent): bool
    {
        return ($connection['connection_identity'] ?? null) === ($consent['connection_identity'] ?? null)
            && self::sameParticipants($connection['participants'] ?? null, $consent['participants'] ?? null);
    }

    /**
     * @param array<string, mixed> $consent
     * @param list<array<string, mixed>> $evidenceSet
     * @return array{evidence: ?array, reason: string}
     */
    private static function resolveConsentEvidence(array $consent, array $evidenceSet): array
    {
        if ($evidenceSet === []) {
            return ['evidence' => null, 'reason' => 'MISSING_CONSENT_EVIDENCE'];
        }

        foreach ($evidenceSet as $evidence) {
            if (($evidence['consent_identity'] ?? null) !== $consent['consent_identity']) {
                return ['evidence' => null, 'reason' => 'CROSS_CONSENT_IDENTITY_EVIDENCE'];
            }

            if (($evidence['connection_identity'] ?? null) !== $consent['connection_identity']) {
                return ['evidence' => null, 'reason' => 'CROSS_CONNECTION_CONSENT_EVIDENCE'];
            }

            if (! self::sameParticipants($evidence['participants'] ?? null, $consent['participants'])) {
                return ['evidence' => null, 'reason' => 'CONSENT_PARTICIPANT_MISMATCH'];
            }
        }

        return self::resolveDuplicates(
            $evidenceSet,
            'consent_evidence_identity',
            'CONFLICTING_CONSENT_EVIDENCE_IDENTITY',
            'INCOMPARABLE_DUPLICATE_CONSENT_EVIDENCE',
            'CONFLICTING_EQUAL_REVISION_CONSENT_EVIDENCE',
            static fn (array $evidence): array => self::consentSemanticSignature($evidence),
        );
    }

    /**
     * @param array<string, mixed> $consent
     * @param list<array<string, mixed>> $evidenceSet
     * @return array{evidence: ?array, reason: string}
     */
    private static function resolveTransitionEvidence(array $consent, array $evidenceSet): array
    {
        if ($evidenceSet === []) {
            return ['evidence' => null, 'reason' => 'MISSING_CONSENT_TRANSITION_EVIDENCE'];
        }

        foreach ($evidenceSet as $evidence) {
            if (($evidence['consent_identity'] ?? null) !== $consent['consent_identity']) {
                return ['evidence' => null, 'reason' => 'CROSS_CONSENT_TRANSITION_EVIDENCE'];
            }

            if (($evidence['connection_identity'] ?? null) !== $consent['connection_identity']) {
                return ['evidence' => null, 'reason' => 'CROSS_CONNECTION_TRANSITION_EVIDENCE'];
            }

            if (! self::sameParticipants($evidence['participants'] ?? null, $consent['participants'])) {
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

    /** @param array<string, mixed> $consent @param array<string, mixed> $evidence */
    private static function consentEvidenceIsUsable(array $consent, array $evidence): bool
    {
        $evaluation = CommonAuthorityEvidenceContract::evaluateProtected(
            $evidence['source_evidence'] ?? [],
            $evidence['required_bindings'] ?? [],
        );

        return $evaluation['satisfied']
            && ($evidence['required_bindings']['subject'] ?? null) === $consent['connection_identity']
            && ($evidence['required_bindings']['aggregate_context'] ?? null) === $consent['consent_identity']
            && ($evidence['required_bindings']['lifecycle_identity'] ?? null) === $consent['consent_identity']
            && ($evidence['required_bindings']['purpose'] ?? null) === $consent['purpose']
            && self::sameParticipants($evidence['required_bindings']['participants'] ?? null, $consent['participants'])
            && ($evidence['required_bindings']['terminal'] ?? null) === self::isTerminal($evidence['state'] ?? '');
    }

    /** @param array<string, mixed> $consent @param array<string, mixed> $evidence */
    private static function transitionEvidenceIsUsable(array $consent, array $evidence): bool
    {
        $evaluation = CommonAuthorityEvidenceContract::evaluateProtected(
            $evidence['source_evidence'] ?? [],
            $evidence['required_bindings'] ?? [],
        );

        return $evaluation['satisfied']
            && ($evidence['required_bindings']['actor'] ?? null) === ($evidence['actor'] ?? null)
            && ($evidence['required_bindings']['subject'] ?? null) === $consent['connection_identity']
            && ($evidence['required_bindings']['aggregate_context'] ?? null) === $consent['consent_identity']
            && ($evidence['required_bindings']['lifecycle_identity'] ?? null) === $consent['consent_identity']
            && ($evidence['required_bindings']['purpose'] ?? null) === $consent['purpose']
            && self::sameParticipants($evidence['required_bindings']['participants'] ?? null, $consent['participants']);
    }

    /**
     * @param array<string, mixed> $consent
     * @param list<array<string, mixed>> $evidenceSet
     * @param array<string, mixed> $connection
     * @return array{state: string, dependency: ?array, reasons: list<string>}
     */
    private static function evaluateConsentCurrent(
        array $consent,
        array $evidenceSet,
        string $requiredPurpose,
        array $connection,
    ): array {
        $shapeReason = self::consentShapeReason($consent);

        if (
            $shapeReason !== null
            || ($consent['purpose'] ?? null) !== $requiredPurpose
            || ! self::connectionMatchesConsent($connection, $consent)
        ) {
            return ['state' => self::DERIVED_UNKNOWN, 'dependency' => null, 'reasons' => ['CONSENT_GATE_CONTEXT_MISMATCH']];
        }

        $resolved = self::resolveConsentEvidence($consent, $evidenceSet);

        if ($resolved['evidence'] === null) {
            return ['state' => self::DERIVED_UNKNOWN, 'dependency' => null, 'reasons' => [$resolved['reason']]];
        }

        $evidence = $resolved['evidence'];
        $dependency = self::consentDependency($evidence);

        if (
            ! in_array($evidence['state'] ?? null, self::lifecycleVocabulary(), true)
            || ! self::consentEvidenceIsUsable($consent, $evidence)
        ) {
            return ['state' => self::DERIVED_UNKNOWN, 'dependency' => $dependency, 'reasons' => ['CONSENT_GATE_EVIDENCE_NOT_CURRENT_FRESH_BOUND']];
        }

        if ($evidence['state'] !== self::STATE_ACTIVE) {
            return ['state' => $evidence['state'], 'dependency' => $dependency, 'reasons' => ['CONSENT_NOT_ACTIVE']];
        }

        return ['state' => self::STATE_ACTIVE, 'dependency' => $dependency, 'reasons' => []];
    }

    private static function transitionRoleReason(array $consent, string $from, string $to, string $actor): ?string
    {
        if ($from === self::STATE_NONE && $to === self::STATE_PENDING && $actor !== $consent['requester']) {
            return 'REQUESTER_BOUND_REQUEST_REQUIRED';
        }

        if ($from === self::STATE_PENDING && in_array($to, [self::STATE_ACTIVE, self::STATE_DECLINED], true) && $actor !== $consent['recipient']) {
            return 'RECIPIENT_BOUND_DECISION_REQUIRED';
        }

        if ($from === self::STATE_PENDING && $to === self::STATE_WITHDRAWN && $actor !== $consent['requester']) {
            return 'REQUESTER_BOUND_WITHDRAWAL_REQUIRED';
        }

        return null;
    }

    private static function isAllowedTransition(string $from, string $to): bool
    {
        return in_array($from.'->'.$to, [
            self::STATE_NONE.'->'.self::STATE_PENDING,
            self::STATE_PENDING.'->'.self::STATE_ACTIVE,
            self::STATE_PENDING.'->'.self::STATE_DECLINED,
            self::STATE_PENDING.'->'.self::STATE_WITHDRAWN,
            self::STATE_ACTIVE.'->'.self::STATE_REVOKED,
        ], true);
    }

    private static function isTerminal(string $state): bool
    {
        return in_array($state, [self::STATE_DECLINED, self::STATE_WITHDRAWN, self::STATE_REVOKED], true);
    }

    /**
     * @param array<string, mixed> $consent
     * @param array<string, mixed> $dependencies
     * @param list<string> $reasons
     * @return array<string, mixed>
     */
    private static function transitionResult(
        array $consent,
        string $classification,
        ?string $currentState,
        ?string $proposedState,
        array $dependencies,
        array $reasons,
    ): array {
        return self::nonAuthorityFields() + [
            'record_kind' => 'MESSAGING_CONSENT_TRANSITION_DERIVATION',
            'classification' => $classification,
            'consent_identity' => $consent['consent_identity'] ?? null,
            'connection_identity' => $consent['connection_identity'] ?? null,
            'participants' => $consent['participants'] ?? [],
            'purpose' => $consent['purpose'] ?? null,
            'current_state' => $currentState,
            'proposed_state' => $proposedState,
            'dependency_vector' => $dependencies,
            'reasons' => $reasons,
            'valid_for_transition' => $classification === self::TRANSITION_ADMISSIBLE,
            'live_read_allowed' => false,
            'live_send_allowed' => false,
        ];
    }

    /**
     * @param array<string, mixed> $connection
     * @param array<string, mixed> $readConsent
     * @param array<string, mixed> $sendConsent
     * @param array<string, mixed> $dependencies
     * @param array<string, list<string>> $reasons
     * @return array<string, mixed>
     */
    private static function gateResult(
        array $connection,
        array $readConsent,
        array $sendConsent,
        bool $liveReadAllowed,
        bool $liveSendAllowed,
        array $dependencies,
        array $reasons,
    ): array {
        return self::nonAuthorityFields() + [
            'record_kind' => 'CONVERSATION_LIVE_GATE_DERIVATION',
            'connection_identity' => $connection['connection_identity'] ?? null,
            'participants' => $connection['participants'] ?? [],
            'read_consent_identity' => $readConsent['consent_identity'] ?? null,
            'send_consent_identity' => $sendConsent['consent_identity'] ?? null,
            'live_read_allowed' => $liveReadAllowed,
            'live_send_allowed' => $liveSendAllowed,
            'valid_for_live_read' => $liveReadAllowed,
            'valid_for_live_send' => $liveSendAllowed,
            'dependency_vector' => $dependencies,
            'reasons' => $reasons,
        ];
    }

    /** @return array<string, false> */
    private static function nonAuthorityFields(): array
    {
        return [
            'source_authority' => false,
            'consent_created' => false,
            'connection_inherited_consent' => false,
            'conversation_content_read' => false,
            'conversation_content_written' => false,
            'message_created' => false,
            'message_sent' => false,
            'unread_count_authority' => false,
            'preview_authority' => false,
            'notification_authority' => false,
            'relationship_authority' => false,
            'home_authority' => false,
            'training_authority' => false,
            'analytics_authority' => false,
            'ads_authority' => false,
            'ranking_computed' => false,
            'compatibility_total_computed' => false,
            'desirability_computed' => false,
            'person_worth_computed' => false,
            'source_evidence_mutated' => false,
            'connection_lifecycle_reset' => false,
            'consent_lifecycle_reset' => false,
            'connection_reopened' => false,
            'consent_reopened' => false,
        ];
    }

    /** @param array<string, mixed> $evidence */
    private static function consentDependency(array $evidence): array
    {
        return [
            'consent_evidence_identity' => $evidence['consent_evidence_identity'] ?? null,
            'consent_identity' => $evidence['consent_identity'] ?? null,
            'connection_identity' => $evidence['connection_identity'] ?? null,
            'purpose' => $evidence['purpose'] ?? null,
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
            'consent_identity' => $evidence['consent_identity'] ?? null,
            'connection_identity' => $evidence['connection_identity'] ?? null,
            'from_state' => $evidence['from_state'] ?? null,
            'to_state' => $evidence['to_state'] ?? null,
            'source_revision' => $evidence['source_evidence']['source_revision'] ?? null,
            'source_condition' => $evidence['source_evidence']['source_condition'] ?? null,
        ];
    }

    /** @param array<string, mixed> $evidence */
    private static function consentSemanticSignature(array $evidence): array
    {
        return [
            'consent_evidence_identity' => $evidence['consent_evidence_identity'] ?? null,
            'consent_identity' => $evidence['consent_identity'] ?? null,
            'connection_identity' => $evidence['connection_identity'] ?? null,
            'participants' => $evidence['participants'] ?? null,
            'purpose' => $evidence['purpose'] ?? null,
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
            'consent_identity' => $evidence['consent_identity'] ?? null,
            'connection_identity' => $evidence['connection_identity'] ?? null,
            'participants' => $evidence['participants'] ?? null,
            'purpose' => $evidence['purpose'] ?? null,
            'actor' => $evidence['actor'] ?? null,
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
