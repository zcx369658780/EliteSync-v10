<?php

namespace App\Domain;

use InvalidArgumentException;

final class NotificationEligibilityPrivacyMinimalPayloadEvaluator
{
    public const ELIGIBLE = 'ELIGIBLE';
    public const INELIGIBLE = 'INELIGIBLE';
    public const UNKNOWN = 'UNKNOWN';

    public const DELIVERY_NOT_ATTEMPTED = 'NOT_ATTEMPTED';
    public const DELIVERY_ATTEMPTED = 'ATTEMPTED';
    public const DELIVERY_DELIVERED = 'DELIVERED';
    public const DELIVERY_FAILED = 'FAILED';
    public const DELIVERY_OPENED = 'OPENED';
    public const DELIVERY_DISMISSED = 'DISMISSED';

    public const AUDIENCE_IN_APP = 'IN_APP';
    public const AUDIENCE_EXTERNAL = 'EXTERNAL';
    public const AUDIENCE_LOCK_SCREEN = 'LOCK_SCREEN';

    public const GENERIC_TITLE_TOKEN = 'GENERIC_NOTIFICATION_TITLE';
    public const GENERIC_BODY_TOKEN = 'GENERIC_NOTIFICATION_BODY';

    private const ALLOWED_CATEGORIES = [
        'RUNTIME_READINESS',
        'CANONICAL_MATCH',
        'PRODUCT_CONNECTION',
        'MESSAGING_CONSENT',
        'CONVERSATION_AVAILABILITY',
        'CALM_HOME',
    ];

    /**
     * @param list<array<string, mixed>> $sourceEventEvidence
     * @param list<array<string, mixed>> $eligibilityEvidence
     * @param array<string, mixed> $context
     * @return array<string, mixed>
     */
    public static function evaluate(
        array $sourceEventEvidence,
        array $eligibilityEvidence,
        array $context,
        string $deliveryObservation = self::DELIVERY_NOT_ATTEMPTED,
    ): array {
        self::assertDeliveryObservation($deliveryObservation);

        $source = self::resolveEvidence($sourceEventEvidence);
        $eligibility = self::resolveEvidence($eligibilityEvidence);
        $classification = self::classify($source, $eligibility, $context);
        $payload = $classification === self::ELIGIBLE
            ? self::payload($source['evidence'], $eligibility['evidence'], $context)
            : null;

        return self::nonAuthorityFields() + [
            'record_kind' => 'NOTIFICATION_ELIGIBILITY_PRIVACY_MINIMAL_PAYLOAD_DERIVATION',
            'eligibility' => $classification,
            'payload' => $payload,
            'source_event_resolution' => $source['status'],
            'eligibility_resolution' => $eligibility['status'],
            'dependency_vector' => self::dependencyVector($source, $eligibility),
            'delivery_observation' => $deliveryObservation,
            'delivery_is_domain_outcome' => false,
            'protected_action_revalidation_required' => $payload !== null,
            'revalidation_authority' => $payload === null ? null : 'FRESH_SOURCE_AUTHORITY',
            'source_domain_lifecycle_changed' => false,
            'deterministic' => true,
            'zero_writer' => true,
        ];
    }

    /**
     * @param array<string, mixed> $derivation
     * @return array<string, mixed>
     */
    public static function invalidate(
        array $derivation,
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

        $identities = array_column($derivation['dependency_vector'] ?? [], 'dependency_identity');

        if (! in_array($dependencyIdentity, $identities, true)) {
            return $derivation;
        }

        $derivation['eligibility'] = self::UNKNOWN;
        $derivation['payload'] = null;
        $derivation['protected_action_revalidation_required'] = false;
        $derivation['revalidation_authority'] = null;
        $derivation['invalidation'] = [
            'dependency_identity' => $dependencyIdentity,
            'relation' => $relation,
            'derived_result_invalidated' => true,
            'source_domain_lifecycle_changed' => false,
            'lifecycle_reset' => false,
            'reopened' => false,
        ];

        return $derivation;
    }

    /**
     * @param array{status: string, evidence: ?array<string, mixed>} $source
     * @param array{status: string, evidence: ?array<string, mixed>} $eligibility
     * @param array<string, mixed> $context
     */
    private static function classify(array $source, array $eligibility, array $context): string
    {
        if ($source['status'] !== 'RESOLVED' || $eligibility['status'] !== 'RESOLVED') {
            return self::UNKNOWN;
        }

        if (! self::validContext($context)) {
            return self::UNKNOWN;
        }

        $sourceCheck = CommonAuthorityEvidenceContract::evaluateProtected(
            $source['evidence'],
            $context['source_required_bindings'],
        );
        $eligibilityCheck = CommonAuthorityEvidenceContract::evaluateProtected(
            $eligibility['evidence'],
            $context['eligibility_required_bindings'],
        );

        if (! $sourceCheck['satisfied'] || ! $eligibilityCheck['satisfied']) {
            return self::UNKNOWN;
        }

        if (
            ($source['evidence']['event_reference'] ?? null) !== $context['event_reference']
            || ($eligibility['evidence']['event_reference'] ?? null) !== $context['event_reference']
            || ($eligibility['evidence']['context_reference'] ?? null) !== $context['context_reference']
        ) {
            return self::UNKNOWN;
        }

        $decision = $eligibility['evidence']['eligibility_classification'] ?? null;

        return in_array($decision, [self::ELIGIBLE, self::INELIGIBLE], true)
            ? $decision
            : self::UNKNOWN;
    }

    /** @param array<string, mixed> $context */
    private static function validContext(array $context): bool
    {
        foreach ([
            'event_reference',
            'context_reference',
            'category',
            'audience',
            'purpose',
            'source_required_bindings',
            'eligibility_required_bindings',
        ] as $key) {
            if (! array_key_exists($key, $context)) {
                return false;
            }
        }

        return is_string($context['event_reference'])
            && $context['event_reference'] !== ''
            && is_string($context['context_reference'])
            && $context['context_reference'] !== ''
            && in_array($context['category'], self::ALLOWED_CATEGORIES, true)
            && in_array($context['audience'], [
                self::AUDIENCE_IN_APP,
                self::AUDIENCE_EXTERNAL,
                self::AUDIENCE_LOCK_SCREEN,
            ], true)
            && is_string($context['purpose'])
            && $context['purpose'] !== ''
            && is_array($context['source_required_bindings'])
            && is_array($context['eligibility_required_bindings'])
            && ($context['eligibility_required_bindings']['audience'] ?? null) === $context['audience']
            && ($context['eligibility_required_bindings']['purpose'] ?? null) === $context['purpose'];
    }

    /**
     * @param array<string, mixed> $source
     * @param array<string, mixed> $eligibility
     * @param array<string, mixed> $context
     * @return array<string, mixed>
     */
    private static function payload(array $source, array $eligibility, array $context): array
    {
        $routeIdentity = $context['route_identity'] ?? null;

        if (! is_string($routeIdentity) || $routeIdentity === '') {
            $routeIdentity = null;
        }

        return [
            'record_kind' => 'PRIVACY_MINIMAL_NOTIFICATION_PAYLOAD',
            'event_reference' => $context['event_reference'],
            'context_reference' => $context['context_reference'],
            'category' => $context['category'],
            'generic_title_token' => self::GENERIC_TITLE_TOKEN,
            'generic_body_token' => self::GENERIC_BODY_TOKEN,
            'route_identity' => $routeIdentity,
            'route_is_locator_only' => true,
            'external_copy_generic' => in_array($context['audience'], [
                self::AUDIENCE_EXTERNAL,
                self::AUDIENCE_LOCK_SCREEN,
            ], true),
            'source_event_dependency_identity' => $source['dependency_identity'],
            'eligibility_dependency_identity' => $eligibility['dependency_identity'],
            'source_authority' => false,
            'permission' => false,
            'bearer_capability' => false,
            'domain_success' => false,
            'consent_authority' => false,
            'connection_authority' => false,
            'conversation_authority' => false,
            'relationship_authority' => false,
            'home_authority' => false,
            'launch_authority' => false,
            'ranking_authority' => false,
            'compatibility_total_authority' => false,
            'person_worth_authority' => false,
        ];
    }

    /**
     * @param list<array<string, mixed>> $candidates
     * @return array{status: string, evidence: ?array<string, mixed>}
     */
    private static function resolveEvidence(array $candidates): array
    {
        if ($candidates === []) {
            return ['status' => 'MISSING', 'evidence' => null];
        }

        $selected = null;

        foreach ($candidates as $candidate) {
            if (! is_array($candidate) || ! isset($candidate['source_revision'])) {
                return ['status' => 'UNKNOWN', 'evidence' => null];
            }

            if ($selected === null) {
                $selected = $candidate;
                continue;
            }

            $comparison = CommonAuthorityEvidenceContract::compareSourceRevisions(
                $selected['source_revision'],
                $candidate['source_revision'],
            );

            if ($comparison === CommonAuthorityEvidenceContract::CONDITION_INCOMPARABLE) {
                return ['status' => 'INCOMPARABLE', 'evidence' => null];
            }

            if ($comparison === CommonAuthorityEvidenceContract::REVISION_EQUAL) {
                if ($selected !== $candidate) {
                    return ['status' => 'CONFLICTING', 'evidence' => null];
                }

                continue;
            }

            if ($comparison === CommonAuthorityEvidenceContract::REVISION_OLDER) {
                $selected = $candidate;
            }
        }

        return ['status' => 'RESOLVED', 'evidence' => $selected];
    }

    /**
     * @param array{status: string, evidence: ?array<string, mixed>} $source
     * @param array{status: string, evidence: ?array<string, mixed>} $eligibility
     * @return list<array<string, mixed>>
     */
    private static function dependencyVector(array $source, array $eligibility): array
    {
        $vector = [];

        foreach (['SOURCE_EVENT' => $source, 'ELIGIBILITY' => $eligibility] as $kind => $resolved) {
            $evidence = $resolved['evidence'];

            if ($resolved['status'] !== 'RESOLVED' || ! is_array($evidence)) {
                continue;
            }

            $vector[] = [
                'kind' => $kind,
                'dependency_identity' => $evidence['dependency_identity'] ?? null,
                'authority_owner' => $evidence['source_revision']['authority_owner'],
                'authority_scope' => $evidence['source_revision']['authority_scope'],
                'lineage' => $evidence['source_revision']['lineage'],
                'aggregate_context' => $evidence['source_revision']['aggregate_context'],
                'source_local_revision' => $evidence['source_revision']['value'],
                'currentness' => $evidence['currentness'] ?? null,
                'freshness' => $evidence['freshness'] ?? null,
            ];
        }

        return $vector;
    }

    private static function assertDeliveryObservation(string $observation): void
    {
        if (! in_array($observation, [
            self::DELIVERY_NOT_ATTEMPTED,
            self::DELIVERY_ATTEMPTED,
            self::DELIVERY_DELIVERED,
            self::DELIVERY_FAILED,
            self::DELIVERY_OPENED,
            self::DELIVERY_DISMISSED,
        ], true)) {
            throw new InvalidArgumentException('Unknown delivery observation.');
        }
    }

    /** @return array<string, false> */
    private static function nonAuthorityFields(): array
    {
        return [
            'source_authority' => false,
            'source_event_created' => false,
            'source_event_mutated' => false,
            'eligibility_written' => false,
            'delivery_written' => false,
            'permission' => false,
            'bearer_capability' => false,
            'domain_success' => false,
            'domain_failure' => false,
            'consent_authority' => false,
            'connection_authority' => false,
            'conversation_authority' => false,
            'relationship_authority' => false,
            'home_authority' => false,
            'launch_authority' => false,
            'ranking_computed' => false,
            'compatibility_total_computed' => false,
            'person_worth_computed' => false,
            'conversation_content_read' => false,
            'private_unread_count_read' => false,
            'safety_evidence_read' => false,
            'credentials_read' => false,
            'device_token_read' => false,
            'provider_payload_created' => false,
            'analytics_authority' => false,
            'training_authority' => false,
            'ads_authority' => false,
        ];
    }
}
