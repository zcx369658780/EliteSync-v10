<?php

declare(strict_types=1);

namespace App\EliteSync\ConversationQualification;

use App\Domain\CommonAuthorityEvidenceContract as Common;
use App\Domain\MessagingConsentConversationLiveGateEvaluator as MC;
use App\EliteSync\TextAuthority\ExistingEvaluatorEvidenceAdapter as Adapter;
use InvalidArgumentException;
use Throwable;

/** Contract-only consumer. No private callback, mutation, grant or message path exists. */
final class ConversationUsePointQualifier
{
    private const FAMILIES = ['identity', 'connection', 'read_consent', 'send_consent', 'conversation'];
    private bool $entered = false;
    private bool $reentered = false;

    /** Profiles are configured fixture expectations, NOT authentication or source-owner proof. */
    public function __construct(private readonly ConversationQualificationSource $source, private readonly array $profiles) {}

    public function evaluateAtUsePoint(array $request): array
    {
        if ($this->entered) {
            $this->reentered = true;
            return self::result(false, 'SOURCE_REENTRY_REJECTED');
        }
        $this->entered = true;
        $this->reentered = false;
        try {
            self::exactKeys($request, ['actor','peer','session','audience','connection_id','read_consent_id',
                'send_consent_id','conversation_id','purpose','expected_revisions']);
            foreach (['actor','peer','session','audience','connection_id','read_consent_id','send_consent_id','conversation_id'] as $field) {
                if (!is_string($request[$field]) || $request[$field] === '') { throw new InvalidArgumentException('NONEMPTY_CONTEXT_REQUIRED'); }
            }
            if ($request['actor'] === $request['peer'] || $request['read_consent_id'] === $request['send_consent_id']) {
                throw new InvalidArgumentException('INDEPENDENT_PARTICIPANTS_AND_PURPOSES_REQUIRED');
            }
            if (!in_array($request['purpose'], [MC::PURPOSE_LIVE_READ, MC::PURPOSE_LIVE_SEND], true)) {
                throw new InvalidArgumentException('LIVE_PURPOSE_REQUIRED');
            }
            if (!is_array($request['expected_revisions'])) { throw new InvalidArgumentException('EXPECTED_VECTOR_REQUIRED'); }
            self::exactKeys($request['expected_revisions'], self::FAMILIES);
            self::exactKeys($this->profiles, self::FAMILIES);
            // Invalid UTF-8/non-serializable caller input cannot reach the source.
            json_encode($request, JSON_THROW_ON_ERROR);
            $selected = $request['purpose'] === MC::PURPOSE_LIVE_READ ? 'read_consent' : 'send_consent';
            $required = ['identity', 'connection', $selected, 'conversation'];
            try { $bundle = $this->source->readAtUsePoint($request); }
            catch (Throwable) { return self::result(false, 'SOURCE_READ_FAILED'); }
            if ($this->reentered) { return self::result(false, 'SOURCE_REENTRY_REJECTED'); }
            self::exactKeys($bundle, self::FAMILIES);
            $dependencies = [];
            foreach (self::FAMILIES as $family) {
                $entry = $bundle[$family];
                $needed = in_array($family, $required, true);
                $dependencies[$family] = ['required' => $needed, 'verified_for_contract' => false,
                    'source_revision' => null, 'source_condition' => 'UNKNOWN'];
                // The other purpose is independent, not a substitute or required live grant.
                if (!$needed) {
                    // Observe only safe revision/condition metadata; never validate or grant
                    // the other purpose by substituting the selected consent.
                    if (is_array($entry) && is_array($entry['evidence'] ?? null)
                        && is_array($entry['evidence']['source_revision'] ?? null)) {
                        try {
                            $observedRevision = $entry['evidence']['source_revision'];
                            Common::compareSourceRevisions($observedRevision, $observedRevision);
                            $dependencies[$family]['source_revision'] = $observedRevision;
                            if (in_array($entry['evidence']['source_condition'] ?? null,
                                ['PRESENT','ABSENT','UNKNOWN','UNAVAILABLE','STALE','SUPERSEDED','INCOMPARABLE'], true)) {
                                $dependencies[$family]['source_condition'] = $entry['evidence']['source_condition'];
                            }
                        } catch (Throwable) { /* Unknown non-selected metadata is not a grant. */ }
                    }
                    continue;
                }
                $this->validateEntry($family, $entry, $request);
                $dependencies[$family] = ['required' => true, 'verified_for_contract' => true,
                    'source_revision' => $entry['evidence']['source_revision'],
                    'source_condition' => $entry['evidence']['source_condition']];
            }
            $cn = $bundle['connection']['record'];
            $consent = $bundle[$selected]['record'];
            $cnEvidence = Adapter::evidence($cn, true);
            $cnEvidence['source_evidence'] = $bundle['connection']['evidence'];
            $mcEvidence = Adapter::evidence($consent, false);
            $mcEvidence['source_evidence'] = $bundle[$selected]['evidence'];
            $otherId = $selected === 'read_consent' ? $request['send_consent_id'] : $request['read_consent_id'];
            $otherPurpose = $selected === 'read_consent' ? MC::PURPOSE_LIVE_SEND : MC::PURPOSE_LIVE_READ;
            $other = Adapter::missingConsent($cn, $otherId, $otherPurpose);
            $gates = $selected === 'read_consent'
                ? MC::evaluateLiveGates(Adapter::connection($cn), [$cnEvidence], Adapter::consent($consent), [$mcEvidence], $other, [])
                : MC::evaluateLiveGates(Adapter::connection($cn), [$cnEvidence], $other, [], Adapter::consent($consent), [$mcEvidence]);
            if (($gates[$selected === 'read_consent' ? 'live_read_allowed' : 'live_send_allowed'] ?? false) !== true) {
                return self::result(false, 'CN_MC_CONTRACT_NOT_SATISFIED', $dependencies);
            }
            $cv = $bundle['conversation']['record']['state'] ?? null;
            if ($cv !== 'CV_ACTIVE') { return self::result(false, 'CV_LIFECYCLE_RESTRICTION_OR_UNKNOWN', $dependencies); }
            if (($bundle['identity']['record']['active'] ?? null) !== true) {
                return self::result(false, 'IDENTITY_CONTRACT_NOT_CURRENT', $dependencies);
            }
            return self::result(true, 'FICTIONAL_CONTRACT_ONLY_FORMAL_QUALIFICATION_UNKNOWN', $dependencies);
        } catch (InvalidArgumentException $e) {
            return self::result(false, $e->getMessage());
        } catch (Throwable) {
            return self::result(false, 'INVALID_SOURCE_OR_REQUEST_SHAPE');
        } finally {
            $this->entered = false;
            $this->reentered = false;
        }
    }

    private function validateEntry(string $family, mixed $entry, array $request): void
    {
        if (!is_array($entry)) { throw new InvalidArgumentException('SOURCE_NOT_YET_ESTABLISHED:'.$family); }
        self::exactKeys($entry, ['record','evidence','provenance']);
        $profile = $this->profiles[$family];
        if (!is_array($profile)) { throw new InvalidArgumentException('SOURCE_PROFILE_NOT_ESTABLISHED:'.$family); }
        self::exactKeys($profile, ['authority_owner','authority_scope','source_id','lineage']);
        foreach ($profile as $value) {
            if (!is_string($value) || $value === '') { throw new InvalidArgumentException('SOURCE_PROFILE_NOT_ESTABLISHED:'.$family); }
        }
        if (!is_array($entry['record']) || !is_array($entry['evidence']) || !is_array($entry['provenance'])) {
            throw new InvalidArgumentException('SOURCE_ENTRY_SHAPE_REQUIRED:'.$family);
        }
        self::exactKeys($entry['provenance'], ['source_id','session','connection_id','conversation_id']);
        $expectedProvenance = ['source_id' => $profile['source_id'], 'session' => $request['session'],
            'connection_id' => $request['connection_id'], 'conversation_id' => $request['conversation_id']];
        foreach ($expectedProvenance as $key => $value) {
            if ($entry['provenance'][$key] !== $value) { throw new InvalidArgumentException('SOURCE_PROVENANCE_MISMATCH:'.$family); }
        }
        $record = $entry['record']; $evidence = $entry['evidence'];
        $expectedId = match ($family) {
            'identity' => $request['session'], 'connection' => $request['connection_id'],
            'read_consent' => $request['read_consent_id'], 'send_consent' => $request['send_consent_id'],
            'conversation' => $request['conversation_id'],
        };
        $pair = [$request['actor'], $request['peer']]; sort($pair, SORT_STRING);
        if (($record['id'] ?? null) !== $expectedId || ($record['participants'] ?? null) !== $pair
            || ($record['audience'] ?? null) !== $request['audience']) {
            throw new InvalidArgumentException('SOURCE_CONTEXT_MISMATCH:'.$family);
        }
        $revision = $evidence['source_revision'] ?? null;
        $expectedRevision = $request['expected_revisions'][$family];
        if (!is_array($revision) || !is_array($expectedRevision) || !is_array($record['revision'] ?? null)) {
            throw new InvalidArgumentException('SOURCE_REVISION_NOT_CURRENT_OR_COMPARABLE:'.$family);
        }
        Common::compareSourceRevisions($revision, $revision);
        Common::compareSourceRevisions($record['revision'], $record['revision']);
        Common::compareSourceRevisions($expectedRevision, $expectedRevision);
        if ($revision['authority_owner'] !== $profile['authority_owner']
            || $revision['authority_scope'] !== $profile['authority_scope']
            || $revision['lineage'] !== $profile['lineage'] || $revision['aggregate_context'] !== $expectedId
            || Common::compareSourceRevisions($revision, $record['revision']) !== Common::REVISION_EQUAL
            || Common::compareSourceRevisions($revision, $expectedRevision) !== Common::REVISION_EQUAL) {
            throw new InvalidArgumentException('SOURCE_REVISION_NOT_CURRENT_OR_COMPARABLE:'.$family);
        }
        self::exactKeys($evidence, ['record_kind','bindings','source_condition','source_revision','currentness','freshness','authoritative_outcome']);
        if (!is_array($evidence['bindings'])) { throw new InvalidArgumentException('SOURCE_BINDING_SHAPE_REQUIRED:'.$family); }
        // Validate Common's exact shape; this is structural checking, NOT trust manufacture.
        $normalized = Common::evidence($evidence['bindings'], $evidence['source_condition'], $revision,
            $evidence['currentness'], $evidence['freshness'], $evidence['authoritative_outcome']);
        if ($evidence['record_kind'] !== $normalized['record_kind']
            || ($record['condition'] ?? null) !== $evidence['source_condition']
            || ($record['current'] ?? null) !== $evidence['currentness']
            || ($record['fresh'] ?? null) !== $evidence['freshness']
            || $evidence['authoritative_outcome'] !== Common::OUTCOME_COMMITTED) {
            throw new InvalidArgumentException('SOURCE_ENVELOPE_NOT_USABLE:'.$family);
        }
        if (in_array($family, ['connection','read_consent','send_consent'], true)) {
            foreach (['state','last_actor','purpose','condition'] as $field) {
                if (!is_string($record[$field] ?? null) || $record[$field] === '') {
                    throw new InvalidArgumentException('SOURCE_RECORD_SHAPE_REQUIRED:'.$family);
                }
            }
            if (!in_array($record['last_actor'], $pair, true)) { throw new InvalidArgumentException('SOURCE_ACTOR_MISMATCH:'.$family); }
            if ($family === 'connection' && $record['purpose'] !== 'TEXT_TEST_CONNECTION') {
                throw new InvalidArgumentException('CONNECTION_PURPOSE_MISMATCH');
            }
            if (!is_string($record['requester'] ?? null) || !is_string($record['recipient'] ?? null)
                || !in_array($record['requester'], $pair, true) || !in_array($record['recipient'], $pair, true)
                || $record['requester'] === $record['recipient']) {
                throw new InvalidArgumentException('SOURCE_CONSENT_ROLE_MISMATCH:'.$family);
            }
            $bindings = Adapter::evidence($record, $family === 'connection')['required_bindings'];
            if ($family !== 'connection' && (($record['connection_id'] ?? null) !== $request['connection_id']
                || ($record['purpose'] ?? null) !== ($family === 'read_consent' ? MC::PURPOSE_LIVE_READ : MC::PURPOSE_LIVE_SEND))) {
                throw new InvalidArgumentException('CONSENT_PURPOSE_OR_CONNECTION_MISMATCH:'.$family);
            }
        } else {
            $bindings = ['authority_owner' => $profile['authority_owner'], 'authority_scope' => $profile['authority_scope'],
                'actor' => $request['actor'], 'actor_role' => 'FIXTURE_CONTRACT_PARTICIPANT', 'subject' => $request['actor'],
                'participants' => $pair, 'audience' => $request['audience'], 'purpose' => $profile['authority_scope'],
                'aggregate_context' => $expectedId, 'lifecycle_identity' => $expectedId,
                'terminal' => $family === 'conversation' && ($record['state'] ?? null) === 'CV_CLOSED'];
        }
        if (!Common::evaluateProtected($evidence, $bindings)['satisfied']) {
            throw new InvalidArgumentException('SOURCE_BINDING_OR_FRESHNESS_REJECTED:'.$family);
        }
    }

    private static function exactKeys(array $input, array $expected): void
    {
        $keys = array_keys($input); sort($keys); sort($expected);
        if ($keys !== $expected) { throw new InvalidArgumentException('EXACT_SOURCE_OR_REQUEST_SHAPE_REQUIRED'); }
    }

    private static function result(bool $satisfied, string $reason, array $dependencies = []): array
    {
        if ($dependencies === []) {
            foreach (self::FAMILIES as $family) {
                $dependencies[$family] = ['required' => false, 'verified_for_contract' => false,
                    'source_revision' => null, 'source_condition' => 'UNKNOWN'];
            }
        }
        return ['outcome' => $satisfied ? 'CONTRACT_EVALUATED' : 'REJECTED', 'reason' => $reason,
            'contract_satisfied' => $satisfied, 'contract_evaluation_only' => true, 'test_only' => true,
            'source_trust' => 'UNKNOWN', 'formal_qualification' => 'NOT_YET_ESTABLISHED', 'production_authority' => false,
            'live_read_granted' => false, 'live_send_granted' => false, 'conversation_created' => false,
            'message_committed' => false, 'history_allowed' => false, 'mutation_allowed' => false,
            'retention_capability' => false, 'dependency_vector' => $dependencies];
    }
}
