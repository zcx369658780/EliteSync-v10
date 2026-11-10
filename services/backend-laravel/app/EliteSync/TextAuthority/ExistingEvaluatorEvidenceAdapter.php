<?php

declare(strict_types=1);

namespace App\EliteSync\TextAuthority;

use App\Domain\CommonAuthorityEvidenceContract as Common;
use App\Domain\MessagingConsentConversationLiveGateEvaluator as MC;

/** Maps only issuer-owned local-test records; never accepts client-authored source evidence. */
final class ExistingEvaluatorEvidenceAdapter
{
    public static function connection(array $record): array
    {
        return ['connection_identity' => $record['id'], 'participants' => $record['participants'],
            'protected_use_scope' => 'TEXT_TEST_CONNECTION'];
    }

    public static function consent(array $record): array
    {
        return ['consent_identity' => $record['id'], 'connection_identity' => $record['connection_id'],
            'participants' => $record['participants'], 'requester' => $record['requester'],
            'recipient' => $record['recipient'], 'purpose' => $record['purpose']];
    }

    public static function evidence(array $record, bool $connection, ?string $transitionActor = null): array
    {
        $terminal = in_array($record['state'], $connection
            ? ['CN_CLOSED', 'CN_DECLINED', 'CN_WITHDRAWN', 'CN_EXPIRED']
            : ['MC_DECLINED', 'MC_WITHDRAWN', 'MC_REVOKED'], true);
        $bindings = ['authority_owner' => $record['revision']['authority_owner'],
            'authority_scope' => $record['revision']['authority_scope'],
            'actor' => $transitionActor ?? $record['last_actor'], 'actor_role' => 'LOCAL_TEST_SOURCE_PARTICIPANT',
            'subject' => $connection ? $record['id'] : $record['connection_id'],
            'participants' => $record['participants'], 'audience' => $record['audience'],
            'purpose' => $connection ? 'TEXT_TEST_CONNECTION' : $record['purpose'],
            'aggregate_context' => $record['id'], 'lifecycle_identity' => $record['id'], 'terminal' => $terminal];
        $item = ['participants' => $record['participants'], 'state' => $record['state'],
            'connection_identity' => $connection ? $record['id'] : $record['connection_id'],
            'required_bindings' => $bindings,
            'source_evidence' => Common::evidence($bindings, $record['condition'], $record['revision'],
                $record['current'], $record['fresh'], Common::OUTCOME_COMMITTED)];
        if ($connection) {
            $item['state_evidence_identity'] = 'test-cn-evidence:'.hash('sha256', json_encode($record['revision'], JSON_THROW_ON_ERROR));
        } else {
            $item['consent_identity'] = $record['id'];
            $item['consent_evidence_identity'] = 'test-mc-evidence:'.hash('sha256', json_encode($record['revision'], JSON_THROW_ON_ERROR));
            $item['purpose'] = $record['purpose'];
        }
        return $item;
    }

    public static function transition(array $record, bool $connection, string $actor, string $target, string $intent): array
    {
        $evidence = self::evidence($record, $connection, $actor);
        unset($evidence['state'], $evidence['state_evidence_identity'], $evidence['consent_evidence_identity']);
        return $evidence + ['transition_identity' => $intent, 'from_state' => $record['state'],
            'to_state' => $target, 'expected_state_revision' => $record['revision'], 'actor' => $actor];
    }

    public static function missingConsent(array $connection, string $id, string $purpose): array
    {
        return ['consent_identity' => $id, 'connection_identity' => $connection['id'],
            'participants' => $connection['participants'], 'requester' => $connection['requester'],
            'recipient' => $connection['recipient'], 'purpose' => $purpose];
    }
}
