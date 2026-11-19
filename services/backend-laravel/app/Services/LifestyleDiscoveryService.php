<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\DB;

final class LifestyleDiscoveryService
{
    public function bank(): array
    {
        return json_decode(file_get_contents(config_path('lifestyle_discovery_v1.json')), true, 512, JSON_THROW_ON_ERROR);
    }

    public function read(int $userId): array
    {
        $bank = $this->bank();
        $row = DB::table('lifestyle_discoveries')->where('user_id', $userId)->when(DB::transactionLevel() > 0, fn ($query) => $query->lockForUpdate())->first();

        return [
            'questionnaire_version' => $row->questionnaire_version ?? $bank['questionnaire_version'],
            'preference_projection_version' => $row->preference_projection_version ?? $bank['preference_projection_version'],
            'answers' => $row ? json_decode($row->answers, true, 512, JSON_THROW_ON_ERROR) : (object) [],
            'derived_preferences' => $row ? json_decode($row->derived_preferences, true, 512, JSON_THROW_ON_ERROR) : (object) [],
            'status' => $row->status ?? 'not_started',
            'revision' => (int) ($row->revision ?? 0),
            'completed_at' => $row->completed_at ?? null,
            'updated_at' => $row->updated_at ?? null,
            'bank' => $bank,
        ];
    }

    public function completed(int $userId, bool $current = false): bool
    {
        return DB::table('lifestyle_discoveries')->where('user_id', $userId)
            ->where('questionnaire_version', $this->bank()['questionnaire_version'])
            ->where('status', 'completed')->whereNotNull('completed_at')
            ->when($current, fn ($query) => $query->lockForUpdate())->first() !== null;
    }

    private function commandHash(array $command): string
    {
        return hash('sha256', json_encode([$command['action'], $command['questionnaire_version'],
            $command['expected_revision'], $command['scene_id'] ?? null, $command['option_id'] ?? null], JSON_THROW_ON_ERROR));
    }

    /** User lock serializes this read with the original command; no mutation or replay. */
    public function commandResult(int $userId, array $command): array
    {
        return DB::transaction(function () use ($userId, $command) {
            app(JourneyStore::class)->users([$userId]);
            $current = $this->read($userId);
            $receipt = DB::table('lifestyle_discovery_commands')->where('user_id', $userId)
                ->where('request_key', $command['request_key'])->lockForUpdate()->first();
            if ($receipt) {
                abort_unless(hash_equals($receipt->request_hash, $this->commandHash($command)), 409, 'lifestyle request key reused');
            }
            $sameVersion = $command['questionnaire_version'] === $this->bank()['questionnaire_version'];
            $status = $receipt ? 'APPLIED' : ($sameVersion && $current['revision'] === $command['expected_revision'] ? 'NOT_APPLIED' : 'CONFLICT');

            return ['command_status' => $status, 'request_key' => $command['request_key'],
                'applied_revision' => $receipt ? (int) $receipt->applied_revision : null, 'current' => $current];
        });
    }

    public function command(int $userId, array $command): array
    {
        $bank = $this->bank();
        abort_unless($command['questionnaire_version'] === $bank['questionnaire_version'], 422, 'unsupported lifestyle version');
        $action = $command['action'];
        $scene = null;
        $option = null;
        if ($action === 'answer') {
            $scene = collect($bank['scenes'])->firstWhere('id', $command['scene_id']);
            $option = collect($scene['options'] ?? [])->firstWhere('id', $command['option_id']);
            abort_unless($scene && $option, 422, 'unknown lifestyle option');
        }
        // Canonical shape prevents client key ordering from changing retry identity.
        $hash = $this->commandHash($command);

        return DB::transaction(function () use ($userId, $command, $action, $bank, $scene, $option, $hash) {
            // Also serializes against sorted User locks held by weekly run writers.
            User::whereKey($userId)->lockForUpdate()->firstOrFail();
            $receipt = DB::table('lifestyle_discovery_commands')->where('user_id', $userId)
                ->where('request_key', $command['request_key'])->lockForUpdate()->first();
            if ($receipt) {
                abort_unless(hash_equals($receipt->request_hash, $hash), 409, 'lifestyle request key reused');

                return $this->read($userId);
            }
            $row = DB::table('lifestyle_discoveries')->where('user_id', $userId)->lockForUpdate()->first();
            $revision = (int) ($row->revision ?? 0);
            abort_unless($revision === $command['expected_revision'], 409, 'lifestyle revision changed');
            $answers = $row ? json_decode($row->answers, true, 512, JSON_THROW_ON_ERROR) : [];
            if ($action === 'reset') {
                $answers = [];
                DB::table('lifestyle_discovery_commands')->where('user_id', $userId)->delete();
            } elseif ($action === 'answer') {
                $answers[$scene['id']] = ['option_id' => $option['id'], 'answer_revision' => $revision + 1];
            }
            $derived = [];
            foreach ($bank['scenes'] as $question) {
                $answer = $answers[$question['id']] ?? null;
                if (! $answer) {
                    continue;
                }
                $selected = collect($question['options'])->firstWhere('id', $answer['option_id']);
                $derived[$question['dimension']] = [
                    'dimension_label' => $question['dimension_label'], 'value' => $selected['value'],
                    'label' => $selected['label'], 'scene_id' => $question['id'],
                    'option_id' => $selected['id'], 'answer_revision' => $answer['answer_revision'],
                    'rule_id' => $selected['rule_id'], 'explanation' => $selected['explanation'],
                ];
            }
            $complete = count($answers) === count($bank['scenes']);
            $status = match (true) {
                $action === 'skip' => 'skipped',
                $complete => 'completed',
                $action === 'reset' => 'not_started',
                default => 'in_progress',
            };
            DB::table('lifestyle_discoveries')->updateOrInsert(['user_id' => $userId], [
                'questionnaire_version' => $bank['questionnaire_version'],
                'preference_projection_version' => $bank['preference_projection_version'],
                'answers' => json_encode((object) $answers, JSON_THROW_ON_ERROR),
                'derived_preferences' => json_encode((object) $derived, JSON_THROW_ON_ERROR),
                'status' => $status, 'revision' => $revision + 1,
                'completed_at' => $status === 'completed' ? ($row->completed_at ?? now()) : null,
                'created_at' => $row->created_at ?? now(), 'updated_at' => now(),
            ]);
            // Audit identity/revision only. Historical private answer snapshots are not retained.
            DB::table('lifestyle_discovery_commands')->insert(['user_id' => $userId,
                'request_key' => $command['request_key'], 'request_hash' => $hash,
                'action' => $action, 'applied_revision' => $revision + 1, 'created_at' => now()]);

            return $this->read($userId);
        });
    }
}
