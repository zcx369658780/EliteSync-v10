<?php

namespace App\Services;

use App\Models\User;
use Carbon\CarbonImmutable;
use Illuminate\Support\Facades\DB;

final class UserStateService
{
    public function read(int $userId): array
    {
        $user = User::findOrFail($userId);
        $readiness = app(ProfileReadinessService::class)->forUser($user);
        $input = app(MatchingInputService::class)->read($user);
        $lifestyle = app(LifestyleDiscoveryService::class)->read($userId);
        $participation = app(SlowDatingService::class)->participation($userId);
        $participationRow = DB::table('matching_participations')->where('user_id', $userId)->first();
        $privacy = DB::table('privacy_preferences')->where('user_id', $userId)->first();
        $notifications = app(NotificationDeliveryService::class)->preferences($userId);
        $notificationTime = DB::table('notification_preferences')->where('user_id', $userId)->value('updated_at');
        $fields = $privacy?->fields ? json_decode($privacy->fields, true, 512, JSON_THROW_ON_ERROR) : [];
        $eligibility = $readiness['matching_eligibility'];
        $actions = [];
        if ($lifestyle['status'] !== 'completed') { $actions[] = ['code' => 'complete_lifestyle']; }
        if (! $eligibility['eligible']) { $actions[] = ['code' => 'review_preparation']; }
        $actions[] = ['code' => 'view_journey'];

        return ['contract_version' => 'user_state_v1', 'subject_user_id' => $userId,
            'generated_at' => now()->utc()->toISOString(), 'domains' => [
                'account' => ['code' => ! $user->disabled && $user->account_status === 'active' ? 'AVAILABLE' : 'UNAVAILABLE',
                    'source_revision' => null, 'source_updated_at' => $user->updated_at?->toISOString()],
                'profile' => ['code' => $input['confirmed'] ? 'CONFIRMED_INPUTS' : 'NEEDS_CONFIRMATION',
                    'has_display_name' => filled($user->name), 'source_revision' => $input['revision'],
                    'source_updated_at' => $user->updated_at?->toISOString(), 'showcase' => $readiness['showcase']],
                'lifestyle' => ['code' => $lifestyle['status'], 'source_revision' => $lifestyle['revision'],
                    'source_updated_at' => $lifestyle['updated_at'], 'questionnaire_version' => $lifestyle['questionnaire_version'],
                    'answered_count' => count((array) $lifestyle['answers']), 'scene_count' => count($lifestyle['bank']['scenes']),
                    'completed_at' => $lifestyle['completed_at']],
                'readiness' => $eligibility + ['code' => $eligibility['reason_code'],
                    'source_revision' => $readiness['matching_input_revision'],
                    'source_updated_at' => DB::table('questionnaire_answers')->where('user_id', $userId)->max('updated_at'),
                    'questionnaire_revision' => DB::table('admin_versions')->where('key', 'questionnaire')->value('revision'),
                    'account_source_updated_at' => $user->updated_at?->toISOString(),
                    'operational_review' => ['code' => $readiness['operational_review']['status'],
                        'source_revision' => $readiness['operational_review']['revision']]],
                'participation' => ['code' => $participation['state'], 'source_revision' => $participation['revision'],
                    'generation' => $participation['generation'], 'source_updated_at' => $participationRow->updated_at ?? null,
                    'delegated' => (bool) ($participationRow->automation_authorization_id ?? null)],
                'round' => app(MatchRoundProjectionService::class)->readOnlySummary($userId),
                'proposal' => $this->proposalSummary($userId),
                'privacy' => ['code' => $privacy ? 'CONFIGURED' : 'DEFAULTS',
                    'source_revision' => (int) ($privacy->revision ?? 0), 'source_updated_at' => $privacy->updated_at ?? null,
                    'requests_revision' => (int) ($privacy->requests_revision ?? 0),
                    'requests_enabled' => (bool) ($privacy->requests_enabled ?? false),
                    'shared_field_count' => count(array_filter($fields, fn ($value) => in_array($value, ['RELATIONSHIP_SHARED', 'FRIENDS'], true)))],
                'notifications' => ['code' => $notificationTime ? 'CONFIGURED' : 'DEFAULTS',
                    'source_revision' => null, 'source_updated_at' => $notificationTime,
                    'categories' => $notifications['categories'], 'silent' => $notifications['silent']],
                'automation' => app(AutomationAuthorizationService::class)->read($userId),
            ], 'next_actions' => $actions];
    }

    private function proposalSummary(int $userId): array
    {
        $id = DB::table('match_proposal_slots')->where('user_id', $userId)->value('proposal_id');
        $proposal = DB::table('match_proposals')->where(fn ($query) => $query->where('user_a', $userId)->orWhere('user_b', $userId))
            ->when($id, fn ($query) => $query->where('id', $id))->orderByDesc('created_at')->orderByDesc('id')->first();
        if (! $proposal) { return ['code' => 'NONE', 'source_revision' => 0, 'source_updated_at' => null]; }
        $stale = in_array($proposal->state, ['PENDING', 'ACCEPTED_BY_ONE'], true)
            && CarbonImmutable::parse($proposal->expires_at)->lte(now());
        return ['code' => $stale ? 'RECONCILIATION_REQUIRED' : $proposal->state,
            'recorded_code' => $proposal->state, 'proposal_id' => $proposal->id,
            'source_revision' => $proposal->revision, 'source_updated_at' => $proposal->updated_at,
            'expires_at' => $proposal->expires_at, 'requires_reconciliation' => $stale];
    }
}
