<?php

namespace App\Domain;

use InvalidArgumentException;

final class CoreDomainSemanticIntegrationHarness
{
    public const DOMAIN_READINESS = 'RUNTIME_READINESS';
    public const DOMAIN_MATCH = 'CANONICAL_MATCH';
    public const DOMAIN_CONNECTION = 'PRODUCT_CONNECTION';
    public const DOMAIN_CONVERSATION = 'CONVERSATION_LIVE_ACCESS';
    public const DOMAIN_NOTIFICATION = 'NOTIFICATION';

    /**
     * @param array<string, mixed> $scenario
     * @return array<string, mixed>
     */
    public static function run(array $scenario): array
    {
        $readinessInput = self::input($scenario, 'readiness');
        $matchInput = self::input($scenario, 'match');
        $connectionInput = self::input($scenario, 'connection');
        $conversationInput = self::input($scenario, 'conversation');
        $notificationInput = self::input($scenario, 'notification');

        $readiness = RuntimeReadinessDerivedEvaluator::derive(
            self::arrayValue($readinessInput, 'prerequisite_set'),
            self::arrayValue($readinessInput, 'member_evidence'),
        );
        $match = CanonicalMatchProposalDecisionEvaluator::evaluate(
            self::arrayValue($matchInput, 'proposal'),
            self::arrayValue($matchInput, 'participation_evidence'),
            self::arrayValue($matchInput, 'slot_evidence'),
        );
        $connection = ProductConnectionStateTransitionEvaluator::evaluateCurrent(
            self::arrayValue($connectionInput, 'context'),
            self::arrayValue($connectionInput, 'state_evidence'),
        );
        $conversation = MessagingConsentConversationLiveGateEvaluator::evaluateLiveGates(
            self::arrayValue($connectionInput, 'context'),
            self::arrayValue($connectionInput, 'state_evidence'),
            self::arrayValue($conversationInput, 'read_consent'),
            self::arrayValue($conversationInput, 'read_consent_evidence'),
            self::arrayValue($conversationInput, 'send_consent'),
            self::arrayValue($conversationInput, 'send_consent_evidence'),
        );
        $home = CalmHomeReadOnlyCompositionEvaluator::compose(self::homeInputs(
            $scenario['home'] ?? [],
            $readiness,
            $match,
            $connection,
            $conversation,
        ));
        $notification = NotificationEligibilityPrivacyMinimalPayloadEvaluator::evaluate(
            self::arrayValue($notificationInput, 'source_event_evidence'),
            self::arrayValue($notificationInput, 'eligibility_evidence'),
            self::arrayValue($notificationInput, 'context'),
            is_string($notificationInput['delivery_observation'] ?? null)
                ? $notificationInput['delivery_observation']
                : NotificationEligibilityPrivacyMinimalPayloadEvaluator::DELIVERY_NOT_ATTEMPTED,
        );

        return self::nonAuthorityFields() + [
            'record_kind' => 'CORE_DOMAIN_SEMANTIC_INTEGRATION_HARNESS_RESULT',
            'readiness' => $readiness,
            'match' => $match,
            'connection' => $connection,
            'conversation' => $conversation,
            'home' => $home,
            'notification' => $notification,
            'semantic_guards' => [
                'source_local_revision_only' => true,
                'global_revision' => null,
                'last_received_wins' => false,
                'independent_input_order_creates_authority' => false,
                'cross_domain_substitution' => false,
            ],
            'deterministic' => true,
            'zero_writer' => true,
        ];
    }

    /**
     * @param array<string, mixed> $integrated
     * @return array<string, mixed>
     */
    public static function invalidate(
        array $integrated,
        string $domain,
        string $dependencyIdentity,
        string $relation,
    ): array {
        if (! in_array($relation, [
            CommonAuthorityEvidenceContract::INVALIDATION_CORRECTION,
            CommonAuthorityEvidenceContract::INVALIDATION_REVOCATION,
            CommonAuthorityEvidenceContract::INVALIDATION_SUPERSESSION,
        ], true)) {
            throw new InvalidArgumentException('Unknown invalidation relation.');
        }

        $invalidated = $integrated;

        switch ($domain) {
            case self::DOMAIN_READINESS:
                $invalidated['readiness'] = RuntimeReadinessDerivedEvaluator::invalidate(
                    $integrated['readiness'] ?? [],
                    $dependencyIdentity,
                    $relation,
                );
                $invalidated['home'] = self::invalidateHome(
                    $integrated['home'] ?? [],
                    CalmHomeReadOnlyCompositionEvaluator::DOMAIN_READINESS,
                    $dependencyIdentity,
                    $relation,
                );
                break;

            case self::DOMAIN_MATCH:
                $invalidated['match'] = CanonicalMatchProposalDecisionEvaluator::invalidate(
                    $integrated['match'] ?? [],
                    $dependencyIdentity,
                    $relation,
                );
                $invalidated['home'] = self::invalidateHome(
                    $integrated['home'] ?? [],
                    CalmHomeReadOnlyCompositionEvaluator::DOMAIN_MATCH,
                    $dependencyIdentity,
                    $relation,
                );
                break;

            case self::DOMAIN_CONNECTION:
                $invalidated['connection'] = ProductConnectionStateTransitionEvaluator::invalidate(
                    $integrated['connection'] ?? [],
                    $dependencyIdentity,
                    $relation,
                );
                $invalidated['conversation'] = MessagingConsentConversationLiveGateEvaluator::invalidateLiveGate(
                    $integrated['conversation'] ?? [],
                    $dependencyIdentity,
                    $relation,
                );
                $invalidated['home'] = self::invalidateHome(
                    $integrated['home'] ?? [],
                    CalmHomeReadOnlyCompositionEvaluator::DOMAIN_CONNECTION,
                    $dependencyIdentity,
                    $relation,
                );
                break;

            case self::DOMAIN_CONVERSATION:
                $invalidated['conversation'] = MessagingConsentConversationLiveGateEvaluator::invalidateLiveGate(
                    $integrated['conversation'] ?? [],
                    $dependencyIdentity,
                    $relation,
                );
                $invalidated['home'] = self::invalidateHome(
                    $integrated['home'] ?? [],
                    CalmHomeReadOnlyCompositionEvaluator::DOMAIN_CONVERSATION,
                    $dependencyIdentity,
                    $relation,
                );
                break;

            case self::DOMAIN_NOTIFICATION:
                $invalidated['notification'] = NotificationEligibilityPrivacyMinimalPayloadEvaluator::invalidate(
                    $integrated['notification'] ?? [],
                    $dependencyIdentity,
                    $relation,
                );
                break;

            default:
                throw new InvalidArgumentException('Unknown integration domain.');
        }

        $invalidated['integration_invalidation'] = [
            'domain' => $domain,
            'dependency_identity' => $dependencyIdentity,
            'relation' => $relation,
            'lifecycle_reset' => false,
            'reopened' => false,
            'source_written' => false,
        ];

        return $invalidated;
    }

    /**
     * @param mixed $homeConfiguration
     * @param array<string, mixed> $readiness
     * @param array<string, mixed> $match
     * @param array<string, mixed> $connection
     * @param array<string, mixed> $conversation
     * @return list<array<string, mixed>>
     */
    private static function homeInputs(
        mixed $homeConfiguration,
        array $readiness,
        array $match,
        array $connection,
        array $conversation,
    ): array {
        $configuration = is_array($homeConfiguration) ? $homeConfiguration : [];
        $results = [
            self::DOMAIN_READINESS => $readiness,
            self::DOMAIN_MATCH => $match,
            self::DOMAIN_CONNECTION => $connection,
            self::DOMAIN_CONVERSATION => $conversation,
        ];
        $inputs = [];

        foreach ($results as $domain => $result) {
            $inputs[] = [
                'domain' => $domain,
                'availability' => is_string($configuration['availability'][$domain] ?? null)
                    ? $configuration['availability'][$domain]
                    : CalmHomeReadOnlyCompositionEvaluator::AVAILABILITY_PRESENT,
                'dependency_identity' => is_string($configuration['dependency_identities'][$domain] ?? null)
                    ? $configuration['dependency_identities'][$domain]
                    : null,
                'derived_result' => $result,
                'action_candidates' => is_array($configuration['action_candidates'][$domain] ?? null)
                    ? $configuration['action_candidates'][$domain]
                    : [],
            ];
        }

        return $inputs;
    }

    /** @param array<string, mixed> $scenario @return array<string, mixed> */
    private static function input(array $scenario, string $key): array
    {
        return is_array($scenario[$key] ?? null) ? $scenario[$key] : [];
    }

    /** @param array<string, mixed> $input @return array<mixed> */
    private static function arrayValue(array $input, string $key): array
    {
        return is_array($input[$key] ?? null) ? $input[$key] : [];
    }

    /**
     * @param array<string, mixed> $home
     * @return array<string, mixed>
     */
    private static function invalidateHome(
        array $home,
        string $domain,
        string $dependencyIdentity,
        string $relation,
    ): array {
        return CalmHomeReadOnlyCompositionEvaluator::invalidate(
            $home,
            $domain,
            $dependencyIdentity,
            $relation,
        );
    }

    /** @return array<string, false> */
    private static function nonAuthorityFields(): array
    {
        return [
            'source_authority' => false,
            'source_state_written' => false,
            'source_state_mutated' => false,
            'match_created' => false,
            'connection_created' => false,
            'consent_created' => false,
            'conversation_created' => false,
            'home_action_authority' => false,
            'notification_authority' => false,
            'permission' => false,
            'bearer_capability' => false,
            'domain_success' => false,
            'relationship_authority' => false,
            'launch_authority' => false,
            'persistence_authority' => false,
            'endpoint_authority' => false,
            'transport_authority' => false,
            'provider_authority' => false,
            'client_authority' => false,
            'legal_authority' => false,
            'safety_authority' => false,
            'deployment_authority' => false,
            'production_authority' => false,
            'ranking_computed' => false,
            'compatibility_total_computed' => false,
            'desirability_computed' => false,
            'person_worth_computed' => false,
            'conversation_content_read' => false,
            'message_preview_read' => false,
            'private_unread_count_read' => false,
            'hidden_safety_evidence_read' => false,
            'private_identity_read' => false,
            'credential_read' => false,
            'device_token_read' => false,
            'provider_payload_created' => false,
            'analytics_authority' => false,
            'training_authority' => false,
            'ads_authority' => false,
        ];
    }
}
