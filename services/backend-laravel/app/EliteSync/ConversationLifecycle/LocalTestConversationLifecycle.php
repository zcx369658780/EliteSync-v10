<?php
declare(strict_types=1);
namespace App\EliteSync\ConversationLifecycle;

use App\Domain\CommonAuthorityEvidenceContract as Common;
use App\Domain\MessagingConsentConversationLiveGateEvaluator as MC;
use App\EliteSync\ConversationQualification\ConversationQualificationSource;
use App\EliteSync\ConversationQualification\ConversationUsePointQualifier;
use InvalidArgumentException;
use RuntimeException;
use Throwable;

/** In-memory fictional CV journal. No real identity, issuer, transport or persistence authority. */
final class LocalTestConversationLifecycle implements ConversationQualificationSource
{
    private const OTHER_FAMILIES = ['identity','connection','read_consent','send_consent'];
    private array $store = ['records' => [], 'intents' => [], 'journal' => []];
    private bool $applying = false;
    private bool $poisoned = false;
    private bool $reading = false;
    private bool $readPoisoned = false;
    private bool $failCommit = false;

    public function __construct(
        private readonly ConversationQualificationSource $upstream,
        private readonly array $fourProfiles,
        private readonly array $cvProfile,
    ) {
        self::keys($fourProfiles, self::OTHER_FAMILIES);
        self::keys($cvProfile, ['authority_owner','authority_scope','source_id']);
        foreach ($cvProfile as $value) {
            if (!is_string($value) || $value === '') { throw new InvalidArgumentException('CV_PROFILE_REQUIRED'); }
        }
    }

    /** Fixture control-plane failure injection. It grants no qualification or callback access. */
    public function failNextCommit(): void { $this->failCommit = true; }
    public function record(string $id): ?array { return $this->store['records'][$id] ?? null; }
    public function journal(): array { return $this->store['journal']; }
    public function profilesFor(string $id): array
    {
        return $this->fourProfiles + ['conversation' => $this->cvProfile + ['lineage' => 'fixture-cv:'.$id]];
    }

    public function apply(array $command): array
    {
        if ($this->applying) {
            $this->poisoned = true;
            return self::result('REJECTED', 'REENTRY_REJECTED');
        }
        $this->applying = true; $this->poisoned = false;
        try {
            $this->validateCommand($command);
            $fingerprint = hash('sha256', json_encode(self::canonical($command), JSON_THROW_ON_ERROR));
            $id = $command['conversation_id']; $intent = $command['intent'];
            if (isset($this->store['intents'][$intent])) {
                $old = $this->store['intents'][$intent];
                if ($old['fingerprint'] !== $fingerprint) { throw new InvalidArgumentException('CHANGED_INPUT_INTENT_REJECTED'); }
                // Historical acknowledgement, never a replay of a state update or live capability.
                return self::result('DUPLICATE_RECEIPT', 'HISTORICAL_RECEIPT_ONLY', null,
                    ['historical_state' => $old['state'], 'current_state' => $this->record($id)['state'] ?? null]);
            }
            $existing = $this->record($id);
            if ($existing !== null) {
                $this->assertContext($existing, $command);
                if ($existing['state'] === 'CV_CLOSED') { throw new InvalidArgumentException('CV_TERMINAL'); }
                if (!is_array($command['expected_revision'])
                    || Common::compareSourceRevisions($existing['revision'], $command['expected_revision']) !== Common::REVISION_EQUAL) {
                    throw new InvalidArgumentException('EXPECTED_CV_REVISION_MISMATCH');
                }
                if ($command['generation'] !== $existing['generation']) { throw new InvalidArgumentException('CONSENT_GENERATION_MISMATCH'); }
            } elseif ($command['action'] !== 'REQUEST' || $command['expected_revision'] !== null || $command['generation'] !== 0) {
                throw new InvalidArgumentException('NEW_REQUEST_REQUIRED');
            }
            $pair = [$command['actor'], $command['peer']]; sort($pair, SORT_STRING);
            $candidate = $existing ?? [
                'id' => $id, 'participants' => $pair, 'audience' => $command['audience'],
                'session' => $command['session'], 'connection_id' => $command['connection_id'],
                'read_consent_id' => $command['read_consent_id'], 'send_consent_id' => $command['send_consent_id'],
                'purpose' => $this->cvProfile['authority_scope'], 'state' => 'CV_LOCKED', 'generation' => 0,
                'agreements' => array_fill_keys($pair, false), 'initiator' => $command['actor'],
                'condition' => 'PRESENT', 'current' => true, 'fresh' => true,
            ];
            switch ($command['action']) {
                case 'REQUEST':
                    if ($candidate['state'] !== 'CV_LOCKED') { throw new InvalidArgumentException('REQUEST_REQUIRES_NEW_OR_LOCKED_CV'); }
                    $candidate['generation']++;
                    $candidate['agreements'] = array_fill_keys($pair, false);
                    $candidate['initiator'] = $command['actor'];
                    $candidate['state'] = 'CV_PENDING_CONSENT';
                    break;
                case 'AGREE':
                    if (!in_array($candidate['state'], ['CV_PENDING_CONSENT','CV_PAUSED'], true)) { throw new InvalidArgumentException('CONSENT_WINDOW_REQUIRED'); }
                    if ($command['decision'] === false) {
                        if ($candidate['state'] === 'CV_PENDING_CONSENT') { $candidate['state'] = 'CV_LOCKED'; }
                        $candidate['generation']++;
                        $candidate['agreements'] = array_fill_keys($pair, false);
                    } else {
                        $candidate['agreements'][$command['actor']] = true;
                        if ($candidate['agreements'][$pair[0]] && $candidate['agreements'][$pair[1]]) {
                            $candidate['state'] = 'CV_ACTIVE';
                        }
                    }
                    break;
                case 'PAUSE':
                    if (!in_array($candidate['state'], ['CV_ACTIVE','CV_PAUSED'], true)) { throw new InvalidArgumentException('PAUSE_WINDOW_REQUIRED'); }
                    $candidate['state'] = 'CV_PAUSED'; $candidate['generation']++;
                    $candidate['agreements'] = array_fill_keys($pair, false);
                    break;
                case 'CLOSE':
                    if (!in_array($candidate['state'], ['CV_PENDING_CONSENT','CV_ACTIVE','CV_PAUSED'], true)) {
                        throw new InvalidArgumentException('CLOSE_WINDOW_REQUIRED');
                    }
                    $candidate['state'] = 'CV_CLOSED'; $candidate['generation']++;
                    $candidate['agreements'] = array_fill_keys($pair, false);
                    break;
                case 'WITHDRAW':
                    if ($candidate['state'] !== 'CV_PENDING_CONSENT' || $candidate['initiator'] !== $command['actor']) {
                        throw new InvalidArgumentException('INITIATOR_PENDING_WITHDRAW_REQUIRED');
                    }
                    $candidate['state'] = 'CV_LOCKED'; $candidate['generation']++;
                    $candidate['agreements'] = array_fill_keys($pair, false);
                    break;
            }
            $candidate['last_actor'] = $command['actor'];
            $candidate['revision'] = Common::sourceRevision($this->cvProfile['authority_owner'], $this->cvProfile['authority_scope'],
                'fixture-cv:'.$id, $id, ($existing['revision']['value'] ?? 0) + 1);
            $request = $this->useRequest($command, $candidate['revision']);
            $bundle = $this->readUpstream($request);
            $this->assertIdentity($bundle['identity'], $request);
            $dependencies = [];
            // Opening/positive consent requires current CN and the selected independent MC.
            // Privacy-restricting controls remain available with current participant identity.
            if ($command['action'] === 'REQUEST' || ($command['action'] === 'AGREE' && $command['decision'] === true)) {
                $guardView = $candidate;
                $guardView['state'] = 'CV_ACTIVE';
                $bundle['conversation'] = $this->entry($guardView, $request);
                $qualification = (new ConversationUsePointQualifier(new FrozenQualificationSource($bundle), $this->profilesFor($id)))
                    ->evaluateAtUsePoint($request);
                if ($qualification['contract_satisfied'] !== true) {
                    throw new InvalidArgumentException('CURRENT_SOURCE_CONTRACT_REJECTED:'.$qualification['reason']);
                }
                $dependencies = $qualification['dependency_vector'];
            }
            if ($this->poisoned) { throw new InvalidArgumentException('REENTRY_REJECTED'); }
            // All local state, intent and journal changes live in one unpublished candidate.
            $next = $this->store;
            $next['records'][$id] = $candidate;
            $next['intents'][$intent] = ['fingerprint' => $fingerprint, 'state' => $candidate['state']];
            $next['journal'][] = ['intent' => $intent, 'action' => $command['action'], 'actor' => $command['actor'],
                'conversation_id' => $id, 'generation_before' => $existing['generation'] ?? 0,
                'generation_after' => $candidate['generation'], 'previous_revision' => $existing['revision'] ?? null,
                'revision' => $candidate['revision'], 'state' => $candidate['state'], 'dependencies' => $dependencies];
            json_encode($next, JSON_THROW_ON_ERROR);
            if ($this->failCommit) { $this->failCommit = false; throw new RuntimeException('FIXTURE_COMMIT_FAILURE'); }
            $this->store = $next;
            return self::result('FIXTURE_COMMITTED', 'FICTIONAL_LOCAL_TRANSACTION_ONLY', $candidate);
        } catch (InvalidArgumentException $e) {
            return self::result('REJECTED', $e->getMessage());
        } catch (Throwable) {
            return self::result('REJECTED', 'SOURCE_OR_FIXTURE_TRANSACTION_FAILED');
        } finally {
            $this->applying = false; $this->poisoned = false;
        }
    }

    public function readAtUsePoint(array $context): array
    {
        if ($this->reading) { $this->readPoisoned = true; throw new RuntimeException('SOURCE_READ_REENTRY'); }
        $this->reading = true;
        $this->readPoisoned = false;
        try {
            $bundle = $this->readUpstream($context);
            if ($this->readPoisoned) { throw new RuntimeException('SOURCE_READ_REENTRY'); }
            $record = is_string($context['conversation_id'] ?? null) ? $this->record($context['conversation_id']) : null;
            if ($record !== null) {
                try { $this->assertContext($record, $context); }
                catch (Throwable) { $record = null; }
            }
            $bundle['conversation'] = $record === null ? null : $this->entry($record, $context);
            return $bundle;
        } finally { $this->reading = false; $this->readPoisoned = false; }
    }

    private function readUpstream(array $context): array
    {
        $bundle = $this->upstream->readAtUsePoint($context);
        self::keys($bundle, [...self::OTHER_FAMILIES,'conversation']);
        if ($bundle['conversation'] !== null) { throw new InvalidArgumentException('CV_SOURCE_OWNERSHIP_SEPARATION_REQUIRED'); }
        json_encode($bundle, JSON_THROW_ON_ERROR);
        return $bundle;
    }

    private function validateCommand(array $c): void
    {
        self::keys($c, ['action','intent','actor','peer','session','audience','connection_id','read_consent_id',
            'send_consent_id','conversation_id','purpose','expected_revision','expected_sources','generation','decision']);
        foreach (['action','intent','actor','peer','session','audience','connection_id','read_consent_id','send_consent_id','conversation_id','purpose'] as $key) {
            if (!is_string($c[$key]) || $c[$key] === '') { throw new InvalidArgumentException('NONEMPTY_COMMAND_REQUIRED'); }
        }
        if ($c['actor'] === $c['peer'] || $c['read_consent_id'] === $c['send_consent_id']) { throw new InvalidArgumentException('INDEPENDENT_CONTEXT_REQUIRED'); }
        if (!in_array($c['action'], ['REQUEST','AGREE','PAUSE','CLOSE','WITHDRAW'], true)) { throw new InvalidArgumentException('ACTION_NOT_SUPPORTED'); }
        if (!in_array($c['purpose'], [MC::PURPOSE_LIVE_READ,MC::PURPOSE_LIVE_SEND], true)) { throw new InvalidArgumentException('INDEPENDENT_LIVE_PURPOSE_REQUIRED'); }
        if (!is_array($c['expected_sources']) || !is_int($c['generation']) || $c['generation'] < 0) { throw new InvalidArgumentException('REVISION_AND_GENERATION_REQUIRED'); }
        self::keys($c['expected_sources'], self::OTHER_FAMILIES);
        if (($c['action'] === 'AGREE' && !is_bool($c['decision'])) || ($c['action'] !== 'AGREE' && $c['decision'] !== null)) {
            throw new InvalidArgumentException('EXPLICIT_AGREEMENT_REQUIRED');
        }
        json_encode($c, JSON_THROW_ON_ERROR);
    }

    private function assertContext(array $record, array $context): void
    {
        if (!is_string($context['actor'] ?? null) || !is_string($context['peer'] ?? null)) { throw new InvalidArgumentException('PARTICIPANT_CONTEXT_REQUIRED'); }
        $pair = [$context['actor'], $context['peer']]; sort($pair, SORT_STRING);
        if ($pair !== $record['participants'] || $context['actor'] === $context['peer']) { throw new InvalidArgumentException('CV_PARTICIPANT_MISMATCH'); }
        foreach (['session','audience','connection_id','read_consent_id','send_consent_id'] as $key) {
            if (($context[$key] ?? null) !== $record[$key]) { throw new InvalidArgumentException('CV_CONTEXT_MISMATCH:'.$key); }
        }
    }

    private function useRequest(array $c, array $cvRevision): array
    {
        $request = [];
        foreach (['actor','peer','session','audience','connection_id','read_consent_id','send_consent_id','conversation_id','purpose'] as $key) { $request[$key] = $c[$key]; }
        $request['expected_revisions'] = $c['expected_sources'] + ['conversation' => $cvRevision];
        return $request;
    }

    private function entry(array $record, array $context): array
    {
        $bindings = ['authority_owner' => $this->cvProfile['authority_owner'], 'authority_scope' => $this->cvProfile['authority_scope'],
            'actor' => $context['actor'], 'actor_role' => 'FIXTURE_CONTRACT_PARTICIPANT', 'subject' => $context['actor'],
            'participants' => $record['participants'], 'audience' => $record['audience'], 'purpose' => $record['purpose'],
            'aggregate_context' => $record['id'], 'lifecycle_identity' => $record['id'], 'terminal' => $record['state'] === 'CV_CLOSED'];
        return ['record' => $record, 'evidence' => Common::evidence($bindings, $record['condition'], $record['revision'],
            $record['current'], $record['fresh'], Common::OUTCOME_COMMITTED),
            'provenance' => ['source_id' => $this->cvProfile['source_id'], 'session' => $record['session'],
                'connection_id' => $record['connection_id'], 'conversation_id' => $record['id']]];
    }

    private function assertIdentity(mixed $entry, array $request): void
    {
        if (!is_array($entry)) { throw new InvalidArgumentException('CURRENT_IDENTITY_REQUIRED'); }
        self::keys($entry, ['record','evidence','provenance']);
        $profile = $this->fourProfiles['identity'];
        self::keys($profile, ['authority_owner','authority_scope','source_id','lineage']);
        $record = $entry['record']; $evidence = $entry['evidence'];
        if (!is_array($record) || !is_array($evidence) || !is_array($entry['provenance'])) { throw new InvalidArgumentException('IDENTITY_SHAPE_REQUIRED'); }
        self::keys($entry['provenance'], ['source_id','session','connection_id','conversation_id']);
        foreach (['source_id' => $profile['source_id'], 'session' => $request['session'], 'connection_id' => $request['connection_id'], 'conversation_id' => $request['conversation_id']] as $key => $value) {
            if ($entry['provenance'][$key] !== $value) { throw new InvalidArgumentException('IDENTITY_PROVENANCE_MISMATCH'); }
        }
        $pair = [$request['actor'],$request['peer']]; sort($pair, SORT_STRING);
        if (($record['id'] ?? null) !== $request['session'] || ($record['participants'] ?? null) !== $pair
            || ($record['audience'] ?? null) !== $request['audience'] || ($record['active'] ?? null) !== true) { throw new InvalidArgumentException('IDENTITY_CONTEXT_NOT_CURRENT'); }
        self::keys($evidence, ['record_kind','bindings','source_condition','source_revision','currentness','freshness','authoritative_outcome']);
        $revision = $evidence['source_revision'];
        if (!is_array($revision) || !is_array($record['revision'] ?? null) || !is_array($request['expected_revisions']['identity'])) { throw new InvalidArgumentException('IDENTITY_REVISION_REQUIRED'); }
        Common::compareSourceRevisions($revision, $revision);
        if ($revision['authority_owner'] !== $profile['authority_owner'] || $revision['authority_scope'] !== $profile['authority_scope']
            || $revision['lineage'] !== $profile['lineage'] || $revision['aggregate_context'] !== $request['session']
            || Common::compareSourceRevisions($revision, $record['revision']) !== Common::REVISION_EQUAL
            || Common::compareSourceRevisions($revision, $request['expected_revisions']['identity']) !== Common::REVISION_EQUAL) { throw new InvalidArgumentException('IDENTITY_REVISION_NOT_CURRENT'); }
        $normalized = Common::evidence($evidence['bindings'], $evidence['source_condition'], $revision,
            $evidence['currentness'], $evidence['freshness'], $evidence['authoritative_outcome']);
        if ($evidence['record_kind'] !== $normalized['record_kind'] || ($record['condition'] ?? null) !== $evidence['source_condition']
            || ($record['current'] ?? null) !== $evidence['currentness'] || ($record['fresh'] ?? null) !== $evidence['freshness']
            || $evidence['authoritative_outcome'] !== Common::OUTCOME_COMMITTED) { throw new InvalidArgumentException('IDENTITY_ENVELOPE_REJECTED'); }
        $required = ['authority_owner' => $profile['authority_owner'], 'authority_scope' => $profile['authority_scope'],
            'actor' => $request['actor'], 'actor_role' => 'FIXTURE_CONTRACT_PARTICIPANT', 'subject' => $request['actor'],
            'participants' => $pair, 'audience' => $request['audience'], 'purpose' => $profile['authority_scope'],
            'aggregate_context' => $request['session'], 'lifecycle_identity' => $request['session'], 'terminal' => false];
        if (!Common::evaluateProtected($evidence, $required)['satisfied']) { throw new InvalidArgumentException('IDENTITY_BINDING_REJECTED'); }
    }

    private static function keys(array $value, array $keys): void
    {
        $actual = array_keys($value); sort($actual); sort($keys);
        if ($actual !== $keys) { throw new InvalidArgumentException('EXACT_SHAPE_REQUIRED'); }
    }
    private static function canonical(mixed $value): mixed
    {
        if (!is_array($value)) { return $value; }
        if (!array_is_list($value)) { ksort($value, SORT_STRING); }
        foreach ($value as $key => $child) { $value[$key] = self::canonical($child); }
        return $value;
    }
    private static function result(string $outcome, string $reason, ?array $record = null, array $extra = []): array
    {
        return ['outcome' => $outcome, 'reason' => $reason, 'fixture_applied' => $outcome === 'FIXTURE_COMMITTED',
            'record' => $record, 'contract_evaluation_only' => true, 'test_only' => true, 'source_trust' => 'UNKNOWN',
            'formal_qualification' => 'NOT_YET_ESTABLISHED', 'production_authority' => false,
            'live_read_granted' => false, 'live_send_granted' => false, 'conversation_created' => false,
            'message_committed' => false, 'history_allowed' => false, 'mutation_allowed' => false,
            'retention_capability' => false, 'rights_capability' => false] + $extra;
    }
}
