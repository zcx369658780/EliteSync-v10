<?php

namespace App\Domain;

final class CalmHomeReadOnlyCompositionEvaluator
{
    public const SECTION_CURRENT_STATE = 'CURRENT_STATE';
    public const SECTION_NEXT_DECISION = 'NEXT_DECISION';
    public const SECTION_OPTIONAL_SUPPORT = 'OPTIONAL_SUPPORT';

    public const DOMAIN_READINESS = 'RUNTIME_READINESS';
    public const DOMAIN_MATCH = 'CANONICAL_MATCH';
    public const DOMAIN_CONNECTION = 'PRODUCT_CONNECTION';
    public const DOMAIN_CONVERSATION = 'CONVERSATION_LIVE_ACCESS';

    public const ACTION_COMPLETE_READINESS = 'COMPLETE_READINESS_DECISION';
    public const ACTION_RESPOND_MATCH = 'RESPOND_TO_MATCH_DECISION';
    public const ACTION_RESPOND_CONNECTION = 'RESPOND_TO_CONNECTION_DECISION';
    public const ACTION_OPEN_CONVERSATION = 'OPEN_LIVE_CONVERSATION';

    public const AVAILABILITY_PRESENT = 'PRESENT';
    public const AVAILABILITY_UNKNOWN = 'UNKNOWN';
    public const AVAILABILITY_UNAVAILABLE = 'UNAVAILABLE';
    public const AVAILABILITY_STALE = 'STALE';
    public const AVAILABILITY_SUPERSEDED = 'SUPERSEDED';
    public const AVAILABILITY_INCOMPARABLE = 'INCOMPARABLE';
    public const AVAILABILITY_CONFLICTING = 'CONFLICTING';
    public const AVAILABILITY_INVALIDATED = 'INVALIDATED';

    /**
     * @param list<array<string, mixed>> $domainInputs
     * @return array<string, mixed>
     */
    public static function compose(array $domainInputs): array
    {
        $fragments = [];
        $domainConflicts = [];
        $candidateOccurrences = [];

        foreach ($domainInputs as $input) {
            $domain = $input['domain'] ?? null;

            if (! is_string($domain) || ! in_array($domain, self::domains(), true)) {
                continue;
            }

            $fragment = self::projectFragment($domain, $input);

            if (isset($fragments[$domain]) && $fragments[$domain] !== $fragment) {
                $domainConflicts[$domain] = true;
                $fragments[$domain] = self::conflictingFragment($domain);
            } elseif (! isset($fragments[$domain])) {
                $fragments[$domain] = $fragment;
            }

            if (($fragment['availability'] ?? null) !== self::AVAILABILITY_PRESENT) {
                continue;
            }

            foreach ($input['action_candidates'] ?? [] as $candidate) {
                if (! is_array($candidate)) {
                    continue;
                }

                $normalized = self::normalizeCandidate($domain, $fragment, $candidate);

                if ($normalized !== null) {
                    $candidateOccurrences[] = $normalized;
                }
            }
        }

        foreach (self::domains() as $domain) {
            if (! isset($fragments[$domain])) {
                $fragments[$domain] = self::unavailableFragment($domain, self::AVAILABILITY_UNKNOWN, null);
            }
        }

        if ($domainConflicts !== []) {
            $candidateOccurrences = array_values(array_filter(
                $candidateOccurrences,
                static fn (array $candidate): bool => ! isset($domainConflicts[$candidate['source_domain']]),
            ));
        }

        ksort($fragments);
        $decision = self::resolveDecision($candidateOccurrences);
        $unavailableDomains = [];

        foreach ($fragments as $domain => $fragment) {
            if (($fragment['availability'] ?? null) !== self::AVAILABILITY_PRESENT) {
                $unavailableDomains[] = $domain;
            }
        }

        sort($unavailableDomains);

        return self::nonAuthorityFields() + [
            'record_kind' => 'CALM_HOME_READ_ONLY_COMPOSITION',
            'sections' => [
                self::SECTION_CURRENT_STATE => [
                    'fragments' => $fragments,
                ],
                self::SECTION_NEXT_DECISION => $decision,
                self::SECTION_OPTIONAL_SUPPORT => [
                    'unavailable_domains' => $unavailableDomains,
                    'action_conflicts' => $decision['conflicting_action_identities'],
                ],
            ],
        ];
    }

    /**
     * @param array<string, mixed> $composition
     * @return array<string, mixed>
     */
    public static function invalidate(
        array $composition,
        string $domain,
        string $dependencyIdentity,
        string $relation,
    ): array {
        if (! in_array($relation, [
            CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
            CommonAuthorityEvidenceContract::INVALIDATION_REVOCATION,
            CommonAuthorityEvidenceContract::INVALIDATION_SUPERSESSION,
        ], true)) {
            return $composition;
        }

        $fragment = $composition['sections'][self::SECTION_CURRENT_STATE]['fragments'][$domain] ?? null;

        if (! is_array($fragment) || ($fragment['dependency_identity'] ?? null) !== $dependencyIdentity) {
            return $composition;
        }

        $invalidated = $composition;
        $invalidated['sections'][self::SECTION_CURRENT_STATE]['fragments'][$domain] = [
            'domain' => $domain,
            'availability' => self::AVAILABILITY_INVALIDATED,
            'dependency_identity' => $dependencyIdentity,
            'classification' => self::AVAILABILITY_UNKNOWN,
        ];

        $remainingCandidates = array_values(array_filter(
            $composition['sections'][self::SECTION_NEXT_DECISION]['valid_candidates'] ?? [],
            static fn (array $candidate): bool => ! (
                ($candidate['source_domain'] ?? null) === $domain
                && ($candidate['dependency_identity'] ?? null) === $dependencyIdentity
            ),
        ));
        $decision = self::resolveDecision($remainingCandidates);
        $invalidated['sections'][self::SECTION_NEXT_DECISION] = $decision;

        $unavailable = $invalidated['sections'][self::SECTION_OPTIONAL_SUPPORT]['unavailable_domains'] ?? [];
        $unavailable[] = $domain;
        $unavailable = array_values(array_unique($unavailable));
        sort($unavailable);
        $invalidated['sections'][self::SECTION_OPTIONAL_SUPPORT]['unavailable_domains'] = $unavailable;
        $invalidated['sections'][self::SECTION_OPTIONAL_SUPPORT]['action_conflicts'] = $decision['conflicting_action_identities'];
        $invalidated['sections'][self::SECTION_OPTIONAL_SUPPORT]['invalidation'] = [
            'domain' => $domain,
            'dependency_identity' => $dependencyIdentity,
            'relation' => $relation,
        ];
        $invalidated['source_state_written'] = false;

        return $invalidated;
    }

    /** @return list<string> */
    private static function domains(): array
    {
        return [
            self::DOMAIN_READINESS,
            self::DOMAIN_MATCH,
            self::DOMAIN_CONNECTION,
            self::DOMAIN_CONVERSATION,
        ];
    }

    /**
     * @param array<string, mixed> $input
     * @return array<string, mixed>
     */
    private static function projectFragment(string $domain, array $input): array
    {
        $availability = $input['availability'] ?? self::AVAILABILITY_UNKNOWN;
        $dependencyIdentity = is_string($input['dependency_identity'] ?? null)
            ? $input['dependency_identity']
            : null;

        if (! in_array($availability, self::sourceAvailabilities(), true)) {
            $availability = self::AVAILABILITY_UNKNOWN;
        }

        if ($availability !== self::AVAILABILITY_PRESENT || ! is_array($input['derived_result'] ?? null)) {
            return self::unavailableFragment($domain, $availability, $dependencyIdentity);
        }

        $result = $input['derived_result'];

        return match ($domain) {
            self::DOMAIN_READINESS => self::readinessFragment($dependencyIdentity, $result),
            self::DOMAIN_MATCH => self::matchFragment($dependencyIdentity, $result),
            self::DOMAIN_CONNECTION => self::connectionFragment($dependencyIdentity, $result),
            self::DOMAIN_CONVERSATION => self::conversationFragment($dependencyIdentity, $result),
        };
    }

    /** @return list<string> */
    private static function sourceAvailabilities(): array
    {
        return [
            self::AVAILABILITY_PRESENT,
            self::AVAILABILITY_UNKNOWN,
            self::AVAILABILITY_UNAVAILABLE,
            self::AVAILABILITY_STALE,
            self::AVAILABILITY_SUPERSEDED,
            self::AVAILABILITY_INCOMPARABLE,
        ];
    }

    /** @param array<string, mixed> $result @return array<string, mixed> */
    private static function readinessFragment(?string $dependencyIdentity, array $result): array
    {
        if (
            ($result['record_kind'] ?? null) !== 'RUNTIME_READINESS_DERIVATION'
            || ! in_array($result['classification'] ?? null, ['READY', 'NOT_READY'], true)
            || ($result['valid_for_protected_use'] ?? null) !== true
        ) {
            return self::unavailableFragment(self::DOMAIN_READINESS, self::AVAILABILITY_UNKNOWN, $dependencyIdentity);
        }

        return [
            'domain' => self::DOMAIN_READINESS,
            'availability' => self::AVAILABILITY_PRESENT,
            'dependency_identity' => $dependencyIdentity,
            'classification' => $result['classification'],
            'context_identity' => $result['prerequisite_set_identity'] ?? null,
        ];
    }

    /** @param array<string, mixed> $result @return array<string, mixed> */
    private static function matchFragment(?string $dependencyIdentity, array $result): array
    {
        if (
            ($result['record_kind'] ?? null) !== 'CANONICAL_MATCH_PROPOSAL_DECISION_DERIVATION'
            || ! in_array($result['classification'] ?? null, ['PENDING', 'MUTUALLY_ACCEPTED', 'DECLINED', 'WITHDRAWN', 'EXPIRED'], true)
            || ($result['valid_for_protected_use'] ?? null) !== true
        ) {
            return self::unavailableFragment(self::DOMAIN_MATCH, self::AVAILABILITY_UNKNOWN, $dependencyIdentity);
        }

        return [
            'domain' => self::DOMAIN_MATCH,
            'availability' => self::AVAILABILITY_PRESENT,
            'dependency_identity' => $dependencyIdentity,
            'classification' => $result['classification'],
            'context_identity' => $result['proposal_identity'] ?? null,
        ];
    }

    /** @param array<string, mixed> $result @return array<string, mixed> */
    private static function connectionFragment(?string $dependencyIdentity, array $result): array
    {
        if (
            ($result['record_kind'] ?? null) !== 'PRODUCT_CONNECTION_CURRENT_STATE_DERIVATION'
            || ! in_array($result['classification'] ?? null, ProductConnectionStateTransitionEvaluator::lifecycleVocabulary(), true)
            || ($result['current_state'] ?? null) !== $result['classification']
            || ($result['valid_for_protected_use'] ?? null) !== true
        ) {
            return self::unavailableFragment(self::DOMAIN_CONNECTION, self::AVAILABILITY_UNKNOWN, $dependencyIdentity);
        }

        return [
            'domain' => self::DOMAIN_CONNECTION,
            'availability' => self::AVAILABILITY_PRESENT,
            'dependency_identity' => $dependencyIdentity,
            'classification' => $result['classification'],
            'context_identity' => $result['connection_identity'] ?? null,
            'active_for_downstream_consideration' => ($result['connection_active_for_downstream_consideration'] ?? false) === true,
        ];
    }

    /** @param array<string, mixed> $result @return array<string, mixed> */
    private static function conversationFragment(?string $dependencyIdentity, array $result): array
    {
        $readAllowed = ($result['live_read_allowed'] ?? false) === true;
        $sendAllowed = ($result['live_send_allowed'] ?? false) === true;

        if (
            ($result['record_kind'] ?? null) !== 'CONVERSATION_LIVE_GATE_DERIVATION'
            || ($readAllowed && ($result['valid_for_live_read'] ?? null) !== true)
            || ($sendAllowed && ($result['valid_for_live_send'] ?? null) !== true)
        ) {
            return self::unavailableFragment(self::DOMAIN_CONVERSATION, self::AVAILABILITY_UNKNOWN, $dependencyIdentity);
        }

        return [
            'domain' => self::DOMAIN_CONVERSATION,
            'availability' => self::AVAILABILITY_PRESENT,
            'dependency_identity' => $dependencyIdentity,
            'classification' => 'LIVE_GATE_EVALUATED',
            'context_identity' => $result['connection_identity'] ?? null,
            'live_read_allowed' => $readAllowed,
            'live_send_allowed' => $sendAllowed,
        ];
    }

    /** @return array<string, mixed> */
    private static function unavailableFragment(string $domain, string $availability, ?string $dependencyIdentity): array
    {
        return [
            'domain' => $domain,
            'availability' => $availability,
            'dependency_identity' => $dependencyIdentity,
            'classification' => self::AVAILABILITY_UNKNOWN,
        ];
    }

    /** @return array<string, mixed> */
    private static function conflictingFragment(string $domain): array
    {
        return [
            'domain' => $domain,
            'availability' => self::AVAILABILITY_CONFLICTING,
            'dependency_identity' => null,
            'classification' => self::AVAILABILITY_UNKNOWN,
        ];
    }

    /**
     * @param array<string, mixed> $fragment
     * @param array<string, mixed> $candidate
     * @return array<string, mixed>|null
     */
    private static function normalizeCandidate(string $domain, array $fragment, array $candidate): ?array
    {
        if (($candidate['currently_valid'] ?? null) !== true) {
            return null;
        }

        $identity = $candidate['action_identity'] ?? null;
        $category = $candidate['category'] ?? null;
        $payload = $candidate['semantic_payload'] ?? null;

        if (! is_string($identity) || $identity === '' || ! is_string($category) || ! is_array($payload)) {
            return null;
        }

        $payloadKeys = array_keys($payload);
        sort($payloadKeys);

        if ($payloadKeys !== ['context_identity', 'presentation_variant']) {
            return null;
        }

        if (
            ! is_string($payload['context_identity'] ?? null)
            || $payload['context_identity'] === ''
            || ! in_array($payload['presentation_variant'] ?? null, ['STANDARD', 'COMPACT'], true)
            || $payload['context_identity'] !== ($fragment['context_identity'] ?? null)
        ) {
            return null;
        }

        if (! self::candidateSupportedByFragment($domain, $category, $fragment)) {
            return null;
        }

        return [
            'action_identity' => $identity,
            'category' => $category,
            'source_domain' => $domain,
            'dependency_identity' => $fragment['dependency_identity'],
            'semantic_payload' => [
                'context_identity' => $payload['context_identity'],
                'presentation_variant' => $payload['presentation_variant'],
            ],
            'permission' => false,
            'bearer_capability' => false,
            'write_command' => false,
        ];
    }

    /** @param array<string, mixed> $fragment */
    private static function candidateSupportedByFragment(string $domain, string $category, array $fragment): bool
    {
        return match ($domain) {
            self::DOMAIN_READINESS => $category === self::ACTION_COMPLETE_READINESS
                && $fragment['classification'] === 'NOT_READY',
            self::DOMAIN_MATCH => $category === self::ACTION_RESPOND_MATCH
                && $fragment['classification'] === 'PENDING',
            self::DOMAIN_CONNECTION => $category === self::ACTION_RESPOND_CONNECTION
                && $fragment['classification'] === ProductConnectionStateTransitionEvaluator::STATE_PENDING,
            self::DOMAIN_CONVERSATION => $category === self::ACTION_OPEN_CONVERSATION
                && (($fragment['live_read_allowed'] ?? false) || ($fragment['live_send_allowed'] ?? false)),
        };
    }

    /**
     * @param list<array<string, mixed>> $candidateOccurrences
     * @return array<string, mixed>
     */
    private static function resolveDecision(array $candidateOccurrences): array
    {
        $byIdentity = [];
        $conflicts = [];

        foreach ($candidateOccurrences as $candidate) {
            $identity = $candidate['action_identity'];

            if (! isset($byIdentity[$identity])) {
                $byIdentity[$identity] = $candidate;
                continue;
            }

            if ($byIdentity[$identity] !== $candidate) {
                $conflicts[$identity] = true;
                unset($byIdentity[$identity]);
            }
        }

        foreach (array_keys($conflicts) as $identity) {
            unset($byIdentity[$identity]);
        }

        ksort($byIdentity);
        $candidates = array_values($byIdentity);
        $conflictIdentities = array_keys($conflicts);
        sort($conflictIdentities);
        $primary = null;

        if ($conflictIdentities !== []) {
            $resolution = 'CONFLICTING_ACTION_IDENTITY_FAIL_CLOSED';
        } elseif (count($candidates) === 0) {
            $resolution = 'NO_VALID_CANDIDATE';
        } elseif (count($candidates) === 1) {
            $resolution = 'EXACTLY_ONE_VALID_CANDIDATE';
            $primary = $candidates[0];
        } else {
            $resolution = 'NO_ACCEPTED_PRECEDENCE_MULTI_CANDIDATE';
        }

        return [
            'primary_action' => $primary,
            'valid_candidate_count' => count($candidates),
            'valid_candidates' => $candidates,
            'conflicting_action_identities' => $conflictIdentities,
            'resolution' => $resolution,
            'precedence_applied' => false,
            'ranking_applied' => false,
        ];
    }

    /** @return array<string, false> */
    private static function nonAuthorityFields(): array
    {
        return [
            'source_authority' => false,
            'source_state_written' => false,
            'source_state_mutated' => false,
            'readiness_written' => false,
            'match_created' => false,
            'connection_created' => false,
            'consent_created' => false,
            'conversation_created' => false,
            'conversation_content_read' => false,
            'conversation_content_exposed' => false,
            'launch_authority' => false,
            'permission' => false,
            'bearer_capability' => false,
            'relationship_authority' => false,
            'notification_authority' => false,
            'ranking_computed' => false,
            'compatibility_total_computed' => false,
            'desirability_computed' => false,
            'person_worth_computed' => false,
            'telemetry_read' => false,
            'analytics_authority' => false,
            'training_authority' => false,
            'ads_authority' => false,
        ];
    }
}
