<?php

namespace App\Domain;

final class CanonicalMatchProposalDecisionEvaluator
{
    public const PARTICIPATION_NOT_ENROLLED = 'NOT_ENROLLED';
    public const PARTICIPATION_ENROLLED = 'ENROLLED';
    public const PARTICIPATION_PAUSED = 'PAUSED';
    public const PARTICIPATION_WITHDRAWN = 'WITHDRAWN';

    public const PROPOSAL_PENDING = 'PENDING';
    public const PROPOSAL_MUTUALLY_ACCEPTED = 'MUTUALLY_ACCEPTED';
    public const PROPOSAL_DECLINED = 'DECLINED';
    public const PROPOSAL_WITHDRAWN = 'WITHDRAWN';
    public const PROPOSAL_EXPIRED = 'EXPIRED';

    public const DERIVED_UNKNOWN = 'UNKNOWN';

    public const SLOT_PENDING = 'PENDING';
    public const SLOT_ACCEPTED = 'ACCEPTED';
    public const SLOT_DECLINED = 'DECLINED';
    public const SLOT_WITHDRAWN = 'WITHDRAWN';

    /**
     * @param array<string, mixed> $proposal
     * @param list<array<string, mixed>> $participationEvidence
     * @param list<array<string, mixed>> $slotEvidence
     * @return array<string, mixed>
     */
    public static function evaluate(
        array $proposal,
        array $participationEvidence,
        array $slotEvidence,
    ): array {
        $dependencies = [
            'proposal' => self::proposalDependency($proposal),
            'participation' => [],
            'decision_slots' => [],
        ];

        $participants = $proposal['participants'] ?? null;

        if (
            ! is_array($participants)
            || count($participants) !== 2
            || count(array_unique($participants)) !== 2
            || ! self::allNonEmptyStrings($participants)
        ) {
            return self::result($proposal, self::DERIVED_UNKNOWN, $dependencies, ['EXACTLY_TWO_PARTICIPANTS_REQUIRED']);
        }

        $proposalIdentity = $proposal['proposal_identity'] ?? null;
        $protectedUseScope = $proposal['protected_use_scope'] ?? null;
        $proposalState = $proposal['lifecycle_state'] ?? null;

        if (
            ! is_string($proposalIdentity)
            || $proposalIdentity === ''
            || ! is_string($protectedUseScope)
            || $protectedUseScope === ''
            || ! in_array($proposalState, self::proposalLifecycleVocabulary(), true)
        ) {
            return self::result($proposal, self::DERIVED_UNKNOWN, $dependencies, ['INVALID_PROPOSAL_SHAPE']);
        }

        $proposalEvaluation = CommonAuthorityEvidenceContract::evaluateProtected(
            $proposal['source_evidence'] ?? [],
            $proposal['required_bindings'] ?? [],
        );
        $proposalTerminal = $proposalState !== self::PROPOSAL_PENDING;

        if (
            ! $proposalEvaluation['satisfied']
            || ($proposal['required_bindings']['purpose'] ?? null) !== $protectedUseScope
            || ($proposal['required_bindings']['aggregate_context'] ?? null) !== $proposalIdentity
            || ($proposal['required_bindings']['participants'] ?? null) !== $participants
            || ($proposal['required_bindings']['terminal'] ?? null) !== $proposalTerminal
        ) {
            return self::result($proposal, self::DERIVED_UNKNOWN, $dependencies, ['PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE']);
        }

        if ($proposalTerminal) {
            return self::result($proposal, $proposalState, $dependencies, []);
        }

        if (($proposal['at_most_one_unresolved_precondition'] ?? null) !== true) {
            return self::result($proposal, self::DERIVED_UNKNOWN, $dependencies, ['UNRESOLVED_PROPOSAL_PRECONDITION_NOT_ESTABLISHED']);
        }

        $participationByParticipant = [];

        foreach ($participationEvidence as $participation) {
            $participantIdentity = $participation['participant_identity'] ?? null;

            if (! in_array($participantIdentity, $participants, true) || isset($participationByParticipant[$participantIdentity])) {
                return self::result($proposal, self::DERIVED_UNKNOWN, $dependencies, ['INVALID_PARTICIPATION_EVIDENCE_SET']);
            }

            $participationByParticipant[$participantIdentity] = $participation;
        }

        foreach ($participants as $participantIdentity) {
            if (! isset($participationByParticipant[$participantIdentity])) {
                return self::result($proposal, self::DERIVED_UNKNOWN, $dependencies, ['MISSING_PARTICIPATION:'.$participantIdentity]);
            }

            $participation = $participationByParticipant[$participantIdentity];
            $dependencies['participation'][] = self::participationDependency($participation);
            $participationEvaluation = CommonAuthorityEvidenceContract::evaluateProtected(
                $participation['source_evidence'] ?? [],
                $participation['required_bindings'] ?? [],
            );

            if (
                ! $participationEvaluation['satisfied']
                || ($participation['required_bindings']['subject'] ?? null) !== $participantIdentity
                || ($participation['required_bindings']['purpose'] ?? null) !== $protectedUseScope
            ) {
                return self::result($proposal, self::DERIVED_UNKNOWN, $dependencies, ['PARTICIPATION_NOT_USABLE:'.$participantIdentity]);
            }

            if (($participation['state'] ?? null) !== self::PARTICIPATION_ENROLLED) {
                return self::result($proposal, self::DERIVED_UNKNOWN, $dependencies, ['PARTICIPATION_PREVENTS_ACCEPTANCE:'.$participantIdentity]);
            }
        }

        foreach ($slotEvidence as $slot) {
            if (($slot['proposal_identity'] ?? null) !== $proposalIdentity) {
                return self::result($proposal, self::DERIVED_UNKNOWN, $dependencies, ['CROSS_PROPOSAL_SLOT']);
            }

            if (! in_array($slot['participant_identity'] ?? null, $participants, true)) {
                return self::result($proposal, self::DERIVED_UNKNOWN, $dependencies, ['WRONG_PARTICIPANT_SLOT']);
            }
        }

        $selectedSlots = [];

        foreach ($participants as $participantIdentity) {
            $duplicates = array_values(array_filter(
                $slotEvidence,
                static fn (array $slot): bool => ($slot['participant_identity'] ?? null) === $participantIdentity,
            ));

            if ($duplicates === []) {
                return self::result($proposal, self::DERIVED_UNKNOWN, $dependencies, ['MISSING_DECISION_SLOT:'.$participantIdentity]);
            }

            $resolved = self::resolveDuplicateSlotEvidence($duplicates);

            if ($resolved['slot'] === null) {
                return self::result($proposal, self::DERIVED_UNKNOWN, $dependencies, [$resolved['reason'].':'.$participantIdentity]);
            }

            $slot = $resolved['slot'];
            $selectedSlots[] = $slot;
            $dependencies['decision_slots'][] = self::slotDependency($slot);

            $slotEvaluation = CommonAuthorityEvidenceContract::evaluateProtected(
                $slot['source_evidence'] ?? [],
                $slot['required_bindings'] ?? [],
            );

            if (
                ! $slotEvaluation['satisfied']
                || ($slot['required_bindings']['subject'] ?? null) !== $participantIdentity
                || ($slot['required_bindings']['participants'] ?? null) !== [$participantIdentity]
                || ($slot['required_bindings']['purpose'] ?? null) !== $protectedUseScope
                || ($slot['required_bindings']['aggregate_context'] ?? null) !== $proposalIdentity
            ) {
                $condition = $slot['source_evidence']['source_condition'] ?? 'MISSING';

                return self::result(
                    $proposal,
                    self::DERIVED_UNKNOWN,
                    $dependencies,
                    ['DECISION_SLOT_NOT_CURRENT_FRESH_BOUND:'.$participantIdentity.':'.$condition],
                );
            }

            if (! in_array($slot['decision'] ?? null, [
                self::SLOT_PENDING,
                self::SLOT_ACCEPTED,
                self::SLOT_DECLINED,
                self::SLOT_WITHDRAWN,
            ], true)) {
                return self::result($proposal, self::DERIVED_UNKNOWN, $dependencies, ['INVALID_SLOT_DECISION:'.$participantIdentity]);
            }
        }

        $decisions = array_column($selectedSlots, 'decision');

        if (in_array(self::SLOT_DECLINED, $decisions, true) && in_array(self::SLOT_WITHDRAWN, $decisions, true)) {
            return self::result($proposal, self::DERIVED_UNKNOWN, $dependencies, ['CONFLICTING_TERMINAL_SLOT_DECISIONS']);
        }

        if (in_array(self::SLOT_WITHDRAWN, $decisions, true)) {
            return self::result($proposal, self::PROPOSAL_WITHDRAWN, $dependencies, []);
        }

        if (in_array(self::SLOT_DECLINED, $decisions, true)) {
            return self::result($proposal, self::PROPOSAL_DECLINED, $dependencies, []);
        }

        if (count(array_filter($decisions, static fn (string $decision): bool => $decision === self::SLOT_ACCEPTED)) === 2) {
            return self::result($proposal, self::PROPOSAL_MUTUALLY_ACCEPTED, $dependencies, []);
        }

        return self::result($proposal, self::PROPOSAL_PENDING, $dependencies, []);
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

        $dependencyIdentities = [$derivedResult['dependency_vector']['proposal']['proposal_identity'] ?? null];

        foreach ($derivedResult['dependency_vector']['participation'] ?? [] as $participation) {
            $dependencyIdentities[] = $participation['participant_identity'] ?? null;
        }

        foreach ($derivedResult['dependency_vector']['decision_slots'] ?? [] as $slot) {
            $dependencyIdentities[] = $slot['slot_identity'] ?? null;
        }

        if (! in_array($dependencyIdentity, $dependencyIdentities, true)) {
            return $derivedResult;
        }

        $invalidated = $derivedResult;
        $invalidated['classification'] = self::DERIVED_UNKNOWN;
        $invalidated['valid_for_protected_use'] = false;
        $invalidated['invalidation'] = [
            'dependency_identity' => $dependencyIdentity,
            'relation' => $relation,
        ];
        $invalidated['lifecycle_reset'] = false;
        $invalidated['proposal_reopened'] = false;
        $invalidated['reasons'] = ['DEPENDENCY_INVALIDATED'];

        return $invalidated;
    }

    /** @return list<string> */
    public static function participationVocabulary(): array
    {
        return [
            self::PARTICIPATION_NOT_ENROLLED,
            self::PARTICIPATION_ENROLLED,
            self::PARTICIPATION_PAUSED,
            self::PARTICIPATION_WITHDRAWN,
        ];
    }

    /** @return list<string> */
    public static function proposalLifecycleVocabulary(): array
    {
        return [
            self::PROPOSAL_PENDING,
            self::PROPOSAL_MUTUALLY_ACCEPTED,
            self::PROPOSAL_DECLINED,
            self::PROPOSAL_WITHDRAWN,
            self::PROPOSAL_EXPIRED,
        ];
    }

    /**
     * @param list<array<string, mixed>> $duplicates
     * @return array{slot: ?array, reason: string}
     */
    private static function resolveDuplicateSlotEvidence(array $duplicates): array
    {
        $selected = array_shift($duplicates);

        if (! is_array($selected) || ! isset($selected['source_evidence']['source_revision'])) {
            return ['slot' => null, 'reason' => 'INVALID_SLOT_EVIDENCE'];
        }

        foreach ($duplicates as $candidate) {
            if (
                ($candidate['slot_identity'] ?? null) !== ($selected['slot_identity'] ?? null)
                || ! isset($candidate['source_evidence']['source_revision'])
            ) {
                return ['slot' => null, 'reason' => 'CONFLICTING_SLOT_IDENTITY'];
            }

            $comparison = CommonAuthorityEvidenceContract::compareSourceRevisions(
                $selected['source_evidence']['source_revision'],
                $candidate['source_evidence']['source_revision'],
            );

            if ($comparison === CommonAuthorityEvidenceContract::CONDITION_INCOMPARABLE) {
                return ['slot' => null, 'reason' => 'INCOMPARABLE_DUPLICATE_SLOT'];
            }

            if ($comparison === CommonAuthorityEvidenceContract::REVISION_OLDER) {
                $selected = $candidate;
                continue;
            }

            if (
                $comparison === CommonAuthorityEvidenceContract::REVISION_EQUAL
                && self::slotSemanticSignature($selected) !== self::slotSemanticSignature($candidate)
            ) {
                return ['slot' => null, 'reason' => 'CONFLICTING_EQUAL_REVISION_SLOT'];
            }
        }

        return ['slot' => $selected, 'reason' => ''];
    }

    /** @param array<string, mixed> $slot */
    private static function slotSemanticSignature(array $slot): array
    {
        return [
            'slot_identity' => $slot['slot_identity'] ?? null,
            'proposal_identity' => $slot['proposal_identity'] ?? null,
            'participant_identity' => $slot['participant_identity'] ?? null,
            'protected_use_scope' => $slot['protected_use_scope'] ?? null,
            'decision' => $slot['decision'] ?? null,
            'required_bindings' => $slot['required_bindings'] ?? null,
            'source_evidence' => $slot['source_evidence'] ?? null,
        ];
    }

    /** @param array<string, mixed> $proposal */
    private static function proposalDependency(array $proposal): array
    {
        return [
            'proposal_identity' => $proposal['proposal_identity'] ?? null,
            'lifecycle_state' => $proposal['lifecycle_state'] ?? null,
            'source_revision' => $proposal['source_evidence']['source_revision'] ?? null,
            'source_condition' => $proposal['source_evidence']['source_condition'] ?? null,
        ];
    }

    /** @param array<string, mixed> $participation */
    private static function participationDependency(array $participation): array
    {
        return [
            'participant_identity' => $participation['participant_identity'] ?? null,
            'state' => $participation['state'] ?? null,
            'source_revision' => $participation['source_evidence']['source_revision'] ?? null,
            'source_condition' => $participation['source_evidence']['source_condition'] ?? null,
        ];
    }

    /** @param array<string, mixed> $slot */
    private static function slotDependency(array $slot): array
    {
        return [
            'slot_identity' => $slot['slot_identity'] ?? null,
            'proposal_identity' => $slot['proposal_identity'] ?? null,
            'participant_identity' => $slot['participant_identity'] ?? null,
            'decision' => $slot['decision'] ?? null,
            'source_revision' => $slot['source_evidence']['source_revision'] ?? null,
            'source_condition' => $slot['source_evidence']['source_condition'] ?? null,
        ];
    }

    /**
     * @param array<string, mixed> $proposal
     * @param array<string, mixed> $dependencies
     * @param list<string> $reasons
     * @return array<string, mixed>
     */
    private static function result(array $proposal, string $classification, array $dependencies, array $reasons): array
    {
        return [
            'record_kind' => 'CANONICAL_MATCH_PROPOSAL_DECISION_DERIVATION',
            'classification' => $classification,
            'proposal_identity' => $proposal['proposal_identity'] ?? null,
            'participants' => $proposal['participants'] ?? [],
            'dependency_vector' => $dependencies,
            'reasons' => $reasons,
            'valid_for_protected_use' => $classification !== self::DERIVED_UNKNOWN,
            'source_authority' => false,
            'permission' => false,
            'bearer_capability' => false,
            'product_connection_created' => false,
            'messaging_consent_authority' => false,
            'conversation_authority' => false,
            'relationship_authority' => false,
            'home_authority' => false,
            'notification_authority' => false,
            'launch_eligibility' => false,
            'ranking_computed' => false,
            'compatibility_total_computed' => false,
            'person_worth_inferred' => false,
            'source_evidence_mutated' => false,
            'lifecycle_reset' => false,
            'proposal_reopened' => false,
        ];
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
