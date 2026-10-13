<?php
declare(strict_types=1);

namespace EliteSyncQualificationDiagnosticFixture;

use App\EliteSync\ConversationLifecycle\LocalTestConversationLifecycle as Lifecycle;
use App\EliteSync\ConversationQualification\ConversationUsePointQualifier as Qualifier;
use App\EliteSync\TextAuthority\ExistingEvaluatorEvidenceAdapter as Adapter;
use EliteSyncConversationLifecycleFixture\FixtureFourFamilySource as Fixture;
use RuntimeException;

/** Fictional test control plane only. No framework, transport, grant or message writer. */
final class DiagnosticScenarioFactory
{
    public const CONTEXT_ID = 'fiction-session-pair:cn-a:cv-a';
    private int $checks = 0;

    /** Each expectation is checked against the actual qualifier, never used as its input. */
    public static function expectations(): array
    {
        return [
            'pending_single_party' => ['REJECTED', 'CV_LIFECYCLE_RESTRICTION_OR_UNKNOWN'],
            'contract_satisfied' => ['CONTRACT_EVALUATED', 'FICTIONAL_CONTRACT_ONLY_FORMAL_QUALIFICATION_UNKNOWN'],
            'connection_paused' => ['REJECTED', 'CN_MC_CONTRACT_NOT_SATISFIED'],
            'connection_closed' => ['REJECTED', 'CN_MC_CONTRACT_NOT_SATISFIED'],
            'conversation_paused' => ['REJECTED', 'CV_LIFECYCLE_RESTRICTION_OR_UNKNOWN'],
            'conversation_closed' => ['REJECTED', 'CV_LIFECYCLE_RESTRICTION_OR_UNKNOWN'],
            'consent_revoked' => ['REJECTED', 'CN_MC_CONTRACT_NOT_SATISFIED'],
            'stale' => ['REJECTED', 'SOURCE_BINDING_OR_FRESHNESS_REJECTED:identity'],
            'revision_mismatch' => ['REJECTED', 'SOURCE_REVISION_NOT_CURRENT_OR_COMPARABLE:identity'],
            'source_error' => ['UNAVAILABLE', 'SOURCE_READ_FAILED'],
            'source_missing' => ['UNAVAILABLE', 'SOURCE_NOT_YET_ESTABLISHED:identity'],
            'cross_context' => ['REJECTED', 'SOURCE_PROVENANCE_MISMATCH:identity'],
        ];
    }

    /** Returns serializable output and test receipts; does not write files. */
    public function generate(): array
    {
        $records = [];
        $receipts = [];
        foreach (self::expectations() as $id => [$expectedOutcome, $expectedReason]) {
            $startChecks = $this->checks;
            $source = new Fixture();
            $lifecycle = new Lifecycle($source, Fixture::profiles(), [
                'authority_owner' => 'FIXTURE_CV_AUTHORITY',
                'authority_scope' => 'FIXTURE_CV_LIFECYCLE_ACCESS',
                'source_id' => 'fixture-cv',
            ]);
            $trace = [];
            $trace[] = $this->apply($source, $lifecycle, 'REQUEST', 0, 0);
            $trace[] = $this->apply($source, $lifecycle, 'AGREE', 1, 1, 'fiction-a', true);
            $revision = 2;
            if ($id !== 'pending_single_party') {
                $trace[] = $this->apply($source, $lifecycle, 'AGREE', 2, 1, 'fiction-b', true);
                $revision = 3;
            }
            if (in_array($id, ['conversation_paused', 'conversation_closed'], true)) {
                $trace[] = $this->apply($source, $lifecycle,
                    $id === 'conversation_paused' ? 'PAUSE' : 'CLOSE', 3, 1);
                $revision = 4;
            }
            // Explicit fixture setup, performed before reads, never inferred from a caller.
            $source->configure('fiction-a', 'cv-a');
            $bundle = $source->snapshot();
            if (in_array($id, ['connection_paused', 'connection_closed', 'consent_revoked'], true)) {
                $family = $id === 'consent_revoked' ? 'send_consent' : 'connection';
                $bundle[$family]['record']['state'] = match ($id) {
                    'connection_paused' => 'CN_PAUSED',
                    'connection_closed' => 'CN_CLOSED',
                    default => 'MC_REVOKED',
                };
                if ($id === 'connection_paused') {
                    $bundle[$family]['record']['paused_by'] = 'fiction-a';
                }
                $bundle[$family]['evidence'] = Adapter::evidence(
                    $bundle[$family]['record'], $family === 'connection')['source_evidence'];
            }
            if ($id === 'stale') {
                $bundle['identity']['record']['condition'] = 'STALE';
                $bundle['identity']['evidence']['source_condition'] = 'STALE';
            }
            if ($id === 'source_missing') { $bundle['identity'] = null; }
            $source->setBundle($bundle);
            $source->throwOnRead($id === 'source_error');
            $request = self::request($revision);
            if ($id === 'revision_mismatch') { $request['expected_revisions']['identity']['value'] = 6; }
            if ($id === 'cross_context') { $request['session'] = 'fiction-other-session'; }

            $journalBefore = $lifecycle->journal();
            $recordBefore = $lifecycle->record('cv-a');
            $upstreamBefore = $source->snapshot();
            $readsBefore = $source->callCount();
            $sourceReadFailed = false;
            try {
                $observedBundle = $lifecycle->readAtUsePoint($request);
                $this->same(['identity', 'connection', 'read_consent', 'send_consent', 'conversation'],
                    array_keys($observedBundle), $id.': five-family read');
            } catch (RuntimeException $error) {
                $sourceReadFailed = true;
                $this->same('FICTIONAL_SOURCE_READ_FAILED', $error->getMessage(), $id.': fixture read exception');
            }
            $this->same($id === 'source_error', $sourceReadFailed, $id.': explicit read failure');
            $actual = (new Qualifier($lifecycle, $lifecycle->profilesFor('cv-a')))->evaluateAtUsePoint($request);
            $this->assertContractOnly($actual, false, $id.': qualifier');
            $this->same($expectedReason, $actual['reason'], $id.': actual reason');
            $this->same($expectedOutcome === 'CONTRACT_EVALUATED', $actual['contract_satisfied'], $id.': contract result');
            $this->same($expectedOutcome === 'CONTRACT_EVALUATED' ? 'CONTRACT_EVALUATED' : 'REJECTED',
                $actual['outcome'], $id.': raw qualifier outcome');
            $this->same($journalBefore, $lifecycle->journal(), $id.': read/qualifier journal unchanged');
            $this->same($recordBefore, $lifecycle->record('cv-a'), $id.': read/qualifier record unchanged');
            $this->same($upstreamBefore, $source->snapshot(), $id.': upstream unchanged');
            $this->same(2, $source->callCount() - $readsBefore, $id.': actual explicit and qualifier source reads');

            $outcome = $actual['contract_satisfied'] ? 'CONTRACT_EVALUATED'
                : (in_array($actual['reason'], ['SOURCE_READ_FAILED', 'SOURCE_NOT_YET_ESTABLISHED:identity'], true)
                    ? 'UNAVAILABLE' : 'REJECTED');
            $this->same($expectedOutcome, $outcome, $id.': diagnostic mapping');
            $records[] = ['scenario_id' => $id, 'context_id' => self::CONTEXT_ID,
                'diagnostic_outcome' => $outcome, 'reason_codes' => [$actual['reason']],
                'permission' => false, 'live_grant' => false, 'read_allowed' => false, 'send_allowed' => false];
            $receipts[] = ['scenario_id' => $id, 'checks_passed' => $this->checks - $startChecks,
                'lifecycle_trace' => $trace, 'request' => $request, 'qualifier_result' => $actual,
                'source_reads_during_use_point' => $source->callCount() - $readsBefore,
                'journal_unchanged_by_use_point' => true, 'upstream_unchanged_by_use_point' => true];
        }
        return ['envelope' => ['schema_version' => 'elitesync.qualification-diagnostic.v1',
            'kind' => 'QUALIFICATION_DIAGNOSTIC', 'synthetic_dev_test_only' => true, 'diagnostic_only' => true,
            'permission' => false, 'live_grant' => false, 'read_allowed' => false, 'send_allowed' => false,
            'records' => $records],
            'receipt' => ['status' => 'PASS', 'scenarios_passed' => count($records), 'checks_passed' => $this->checks,
                'scope' => 'FICTIONAL_CONTRACT_DIAGNOSTIC_ONLY', 'scenarios' => $receipts]];
    }

    private function apply(Fixture $source, Lifecycle $lifecycle, string $action, int $revision,
        int $generation, string $actor = 'fiction-a', ?bool $decision = null): array
    {
        $source->configure($actor, 'cv-a');
        $before = $source->snapshot();
        $command = ['action' => $action, 'intent' => 'fiction-'.$action.'-'.$revision,
            'actor' => $actor, 'peer' => $actor === 'fiction-a' ? 'fiction-b' : 'fiction-a',
            'session' => 'session-pair', 'audience' => 'fixture-audience', 'connection_id' => 'cn-a',
            'read_consent_id' => 'read-a', 'send_consent_id' => 'send-a', 'conversation_id' => 'cv-a',
            'purpose' => 'CONVERSATION_LIVE_SEND',
            'expected_revision' => $revision === 0 ? null : self::cvRevision($revision),
            'expected_sources' => self::dependencies(), 'generation' => $generation, 'decision' => $decision];
        $actual = $lifecycle->apply($command);
        $this->same('FIXTURE_COMMITTED', $actual['outcome'], 'actual lifecycle '.$action);
        $this->same(true, $actual['fixture_applied'], 'fixture-only journal allowed');
        $this->assertContractOnly($actual, true, 'lifecycle '.$action);
        $this->same($before, $source->snapshot(), 'lifecycle never mutates upstream');
        $this->same($revision + 1, count($lifecycle->journal()), 'one fixture journal entry per apply');
        $this->same(match ($action) {
            'REQUEST' => 'CV_PENDING_CONSENT', 'PAUSE' => 'CV_PAUSED', 'CLOSE' => 'CV_CLOSED',
            default => $actor === 'fiction-b' ? 'CV_ACTIVE' : 'CV_PENDING_CONSENT',
        }, $actual['record']['state'], 'actual two-party lifecycle transition');
        return ['command' => $command, 'result' => $actual];
    }

    private function assertContractOnly(array $actual, bool $lifecycle, string $label): void
    {
        foreach (['contract_evaluation_only', 'test_only'] as $field) { $this->same(true, $actual[$field] ?? null, $label.': '.$field); }
        $this->same('UNKNOWN', $actual['source_trust'] ?? null, $label.': no trust manufacture');
        $this->same('NOT_YET_ESTABLISHED', $actual['formal_qualification'] ?? null, $label.': no formal qualification');
        $fields = ['production_authority', 'live_read_granted', 'live_send_granted', 'conversation_created',
            'message_committed', 'history_allowed', 'mutation_allowed', 'retention_capability'];
        if ($lifecycle) { $fields[] = 'rights_capability'; }
        foreach ($fields as $field) { $this->same(false, $actual[$field] ?? null, $label.': '.$field); }
    }

    private function same(mixed $expected, mixed $actual, string $label): void
    {
        if ($expected !== $actual) { throw new RuntimeException('DIAGNOSTIC_ASSERTION_FAILED: '.$label); }
        $this->checks++;
    }

    private static function dependencies(): array
    {
        $revisions = [];
        foreach (Fixture::ids() as $family => $id) { $revisions[$family] = Fixture::revision($family); }
        return $revisions;
    }

    private static function cvRevision(int $value): array
    {
        return ['authority_owner' => 'FIXTURE_CV_AUTHORITY', 'authority_scope' => 'FIXTURE_CV_LIFECYCLE_ACCESS',
            'lineage' => 'fixture-cv:cv-a', 'aggregate_context' => 'cv-a', 'value' => $value];
    }

    private static function request(int $revision): array
    {
        return ['actor' => 'fiction-a', 'peer' => 'fiction-b', 'session' => 'session-pair',
            'audience' => 'fixture-audience', 'connection_id' => 'cn-a', 'read_consent_id' => 'read-a',
            'send_consent_id' => 'send-a', 'conversation_id' => 'cv-a', 'purpose' => 'CONVERSATION_LIVE_SEND',
            'expected_revisions' => self::dependencies() + ['conversation' => self::cvRevision($revision)]];
    }
}
