<?php

namespace App\Console\Commands;

use App\Models\UserProfileShowcaseDraft;
use App\Services\ProfileShowcase\InternalManualReviewAction;
use Illuminate\Console\Command;
use InvalidArgumentException;
use RuntimeException;
use Throwable;

class InternalProfileShowcaseReviewCommand extends Command
{
    protected $signature = 'app:internal:profile-showcase-review
        {draft_id : Existing pending private Personal Showcase draft id}
        {result : approved, rejected, needs_revision, or manual_review_required}
        {--actor-type=internal_manual_reviewer : Internal actor type}
        {--actor-id= : Stable internal actor identifier}
        {--actor-user-id= : Optional internal actor user id; must not equal draft owner}
        {--reason-code= : Required bounded reason code}
        {--note= : Optional bounded internal note}
        {--correlation-id= : Optional review operation correlation id}';

    protected $description = 'Internal/test-safe Personal Showcase review harness; no route, UI, provider, publish, or scoring side effects.';

    protected $hidden = true;

    public function handle(InternalManualReviewAction $action): int
    {
        $draft = UserProfileShowcaseDraft::query()->find((int) $this->argument('draft_id'));

        if ($draft === null) {
            $this->error('profile_showcase_review_draft_not_found');

            return self::FAILURE;
        }

        try {
            $audit = $action->apply($draft, [
                'type' => (string) $this->option('actor-type'),
                'id' => (string) $this->option('actor-id'),
                'user_id' => $this->option('actor-user-id') === null || $this->option('actor-user-id') === ''
                    ? null
                    : (int) $this->option('actor-user-id'),
            ], (string) $this->argument('result'), [
                'reason_code' => (string) $this->option('reason-code'),
                'note' => $this->option('note'),
                'correlation_id' => $this->option('correlation-id'),
            ]);
        } catch (InvalidArgumentException|RuntimeException $exception) {
            $this->error($exception->getMessage());

            return self::FAILURE;
        } catch (Throwable) {
            $this->error('profile_showcase_review_command_failed');

            return self::FAILURE;
        }

        $this->line(json_encode([
            'ok' => true,
            'audit_id' => (int) $audit->id,
            'draft_id' => (int) $audit->draft_id,
            'user_id' => (int) $audit->user_id,
            'new_moderation_status' => $audit->new_moderation_status,
            'public_display_eligible' => false,
            'matching_scoring_eligible' => false,
        ], JSON_UNESCAPED_SLASHES));

        return self::SUCCESS;
    }
}
