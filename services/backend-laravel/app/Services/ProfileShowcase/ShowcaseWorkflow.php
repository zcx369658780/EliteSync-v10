<?php

namespace App\Services\ProfileShowcase;

use App\Models\MediaAsset;
use App\Models\User;
use App\Models\UserProfileShowcaseDraft;
use App\Models\UserProfileShowcasePublication;
use App\Models\UserProfileShowcasePublicationAudit;
use App\Services\Admin\UserGovernance;
use App\Services\FormalRelationshipService;
use App\Services\JourneyStore;
use App\Services\LiveConsentService;
use App\Services\PrivateProfileImageService;
use App\Services\SocialPolicy;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

final class ShowcaseWorkflow
{
    public const FIELDS = ['display_name', 'city', 'relationship_goal', 'self_intro', 'interest_tags', 'lifestyle_tags', 'opener_note', 'photo_ids', 'audiences'];

    public function snapshot(UserProfileShowcaseDraft $draft): array
    {
        $payload = $draft->only(self::FIELDS);
        foreach (['interest_tags', 'lifestyle_tags', 'photo_ids', 'audiences'] as $field) {
            $payload[$field] = array_values($payload[$field] ?? []);
        }
        return $payload;
    }

    private function draft(int $owner): ?UserProfileShowcaseDraft
    {
        return UserProfileShowcaseDraft::where('user_id', $owner)->lockForUpdate()->first();
    }

    private function submission(?UserProfileShowcaseDraft $draft): ?object
    {
        return $draft ? DB::table('profile_showcase_submissions')->where('draft_id', $draft->id)->latest('id')->first() : null;
    }

    public function ownerPayload(int $owner, string $label = 'private_draft'): array
    {
        return DB::transaction(function () use ($owner, $label) {
            app(JourneyStore::class)->users([$owner], true);
            $draft = $this->draft($owner);
            $submission = $this->submission($draft);
            $visible = $draft && $draft->draft_status !== 'cleared';
            $moderationStatus = in_array($draft?->moderation_status, ['not_submitted', 'pending', 'approved', 'rejected', 'needs_revision', 'manual_review_required'], true)
                ? $draft->moderation_status : ($draft ? 'error' : 'not_submitted');
            return [
                'ok' => true,
                'draft' => $visible ? $this->snapshot($draft) + [
                    'id' => $draft->id, 'revision' => $draft->revision,
                    'moderation_status' => $moderationStatus,
                    'draft_status' => 'draft', 'visibility_intent' => 'private_draft',
                    'source_type' => 'user_confirmed', 'public_display_eligible' => false,
                    'matching_scoring_eligible' => false, 'updated_at' => $draft->updated_at?->toIso8601String(),
                    'photos' => $this->photoReferences($owner, $draft->photo_ids ?? []),
                ] : null,
                'revision' => (int) ($draft?->revision ?? 0),
                'submission' => $submission ? $this->submissionPayload($submission) : null,
                'copy_state' => ['save_label' => $label, 'moderation_status' => $moderationStatus,
                    'public_display_eligible' => false, 'matching_scoring_eligible' => false],
            ];
        });
    }

    private function submissionPayload(object $submission): array
    {
        return ['id' => $submission->id, 'revision' => (int) $submission->content_revision,
            'state' => $submission->state, 'feedback' => $submission->reason,
            'snapshot' => json_decode($submission->snapshot, true), 'reviewed_at' => $submission->reviewed_at];
    }

    public function saveDraft(int $owner, array $data, int $expected): array
    {
        return DB::transaction(function () use ($owner, $data, $expected) {
            app(JourneyStore::class)->users([$owner]);
            $draft = $this->draft($owner);
            $fields = [];
            foreach (self::FIELDS as $field) {
                if (in_array($field, ['interest_tags', 'lifestyle_tags'], true)) {
                    $fields[$field] = array_values(array_unique(array_filter(array_map('trim', $data[$field] ?? []))));
                } elseif (in_array($field, ['photo_ids', 'audiences'], true)) {
                    $fields[$field] = array_values($data[$field] ?? []);
                } else {
                    $fields[$field] = trim((string) ($data[$field] ?? '')) ?: null;
                }
            }
            $this->validatePhotos($owner, $fields['photo_ids']);
            $same = $draft && $draft->draft_status !== 'cleared' && $this->snapshot($draft) === $fields;
            // A reply lost after a completed save can safely read the same version.
            if ($same && in_array($expected, [$draft->revision, $draft->revision - 1], true)) {
                return $this->ownerPayload($owner, 'saved_private_draft');
            }
            abort_unless((int) ($draft?->revision ?? 0) === $expected, 409, 'SHOWCASE_CHANGED_REFRESH_REQUIRED');
            $draft ??= new UserProfileShowcaseDraft(['user_id' => $owner]);
            $draft->fill($fields + ['revision' => $expected + 1, 'draft_status' => 'draft',
                'moderation_status' => 'not_submitted', 'visibility_intent' => 'private_draft',
                'source_type' => 'user_confirmed', 'public_display_eligible' => false, 'matching_scoring_eligible' => false])->save();
            return $this->ownerPayload($owner, 'saved_private_draft');
        });
    }

    public function clearDraft(int $owner, int $expected): array
    {
        return DB::transaction(function () use ($owner, $expected) {
            app(JourneyStore::class)->users([$owner]);
            $draft = $this->draft($owner);
            if ($draft && $draft->draft_status === 'cleared' && in_array($expected, [$draft->revision, $draft->revision - 1], true)) {
                return $this->ownerPayload($owner, 'cleared_private_draft');
            }
            abort_unless((int) ($draft?->revision ?? 0) === $expected, 409, 'SHOWCASE_CHANGED_REFRESH_REQUIRED');
            if ($draft) {
                $draft->fill(['self_intro' => null, 'display_name' => null, 'city' => null, 'relationship_goal' => null,
                    'interest_tags' => [], 'lifestyle_tags' => [], 'opener_note' => null, 'photo_ids' => [], 'audiences' => [],
                    'revision' => $expected + 1, 'draft_status' => 'cleared', 'moderation_status' => 'not_submitted'])->save();
            }
            return $this->ownerPayload($owner, 'cleared_private_draft');
        });
    }

    public function submit(int $owner, int $expected): array
    {
        return DB::transaction(function () use ($owner, $expected) {
            app(JourneyStore::class)->users([$owner]);
            $draft = $this->draft($owner);
            abort_unless($draft && $draft->draft_status !== 'cleared', 422, 'private_draft_required');
            abort_unless($draft->revision === $expected, 409, 'SHOWCASE_CHANGED_REFRESH_REQUIRED');
            abort_unless(count($draft->audiences ?? []) > 0, 422, '请选择展示范围。');
            $this->validatePhotos($owner, $draft->photo_ids ?? []);
            $existing = DB::table('profile_showcase_submissions')->where('draft_id', $draft->id)->where('content_revision', $expected)->first();
            if (! $existing) {
                DB::table('profile_showcase_submissions')->insert(['user_id' => $owner, 'draft_id' => $draft->id,
                    'content_revision' => $expected, 'snapshot' => json_encode($this->snapshot($draft), JSON_THROW_ON_ERROR),
                    'state' => 'pending', 'created_at' => now(), 'updated_at' => now()]);
                $draft->update(['moderation_status' => 'pending']);
            }
            return $this->ownerPayload($owner, 'submitted_for_review_pending');
        });
    }

    public function review(User $actor, int $submissionId, int $expected, string $result, string $reason): void
    {
        $hint = DB::table('profile_showcase_submissions')->where('id', $submissionId)->first();
        abort_unless($hint, 404);
        DB::transaction(function () use ($actor, $hint, $expected, $result, $reason) {
            app(UserGovernance::class)->target($actor, (int) $hint->user_id);
            $draft = $this->draft((int) $hint->user_id);
            $submission = DB::table('profile_showcase_submissions')->where('id', $hint->id)->lockForUpdate()->first();
            abort_unless($draft && $draft->revision === $expected && (int) $submission->content_revision === $expected
                && $submission->state === 'pending', 409, '审核内容已变化，请重新读取。');
            app(InternalManualReviewAction::class)->apply($draft,
                ['type' => 'web_admin', 'id' => (string) $actor->id, 'user_id' => $actor->id], $result,
                ['reason_code' => 'web_review', 'note' => mb_substr($reason, 0, 240), 'expected_revision' => $expected]);
            DB::table('profile_showcase_submissions')->where('id', $submission->id)->update([
                'state' => $result, 'reviewer_id' => $actor->id, 'reason' => $reason, 'reviewed_at' => now(), 'updated_at' => now()]);
        });
    }

    public function publicationPayload(?UserProfileShowcasePublication $publication): array
    {
        return ['ok' => true, 'publication' => $publication ? [
            'id' => $publication->id, 'revision' => $publication->revision,
            'publication_status' => $publication->publication_status, 'source_revision' => $publication->source_revision,
            'source_draft_id' => $publication->source_draft_id, 'moderation_status' => 'approved',
            'public_display_eligible' => (bool) $publication->public_display_eligible, 'matching_scoring_eligible' => false,
            'public_fields' => $this->decorateSnapshot((int) $publication->user_id, $publication->published_payload ?? [], $publication->revision),
            'published_at' => $publication->published_at?->toIso8601String(), 'updated_at' => $publication->updated_at?->toIso8601String(),
        ] : null, 'copy_state' => ['publication_status' => $publication?->publication_status ?? 'not_published',
            'public_display_eligible' => (bool) $publication?->public_display_eligible, 'matching_scoring_eligible' => false]];
    }

    public function ownerPublication(int $owner): array
    {
        return DB::transaction(function () use ($owner) {
            app(JourneyStore::class)->users([$owner], true);
            return $this->publicationPayload(UserProfileShowcasePublication::where('user_id', $owner)->first());
        });
    }

    public function publish(int $owner, int $draftRevision, int $publicationRevision): array
    {
        return DB::transaction(function () use ($owner, $draftRevision, $publicationRevision) {
            app(JourneyStore::class)->users([$owner]);
            $draft = $this->draft($owner);
            abort_unless($draft && $draft->revision === $draftRevision && $draft->moderation_status === 'approved', 409, '请先完成当前版本审核。');
            $submission = $this->submission($draft);
            abort_unless($submission && (int) $submission->content_revision === $draftRevision && $submission->state === 'approved', 409, '当前内容尚未审核通过。');
            $publication = UserProfileShowcasePublication::where('user_id', $owner)->lockForUpdate()->first();
            if ($publication && $publication->publication_status === 'published' && $publication->source_submission_id === (int) $submission->id) {
                return $this->publicationPayload($publication);
            }
            abort_unless((int) ($publication?->revision ?? 0) === $publicationRevision, 409, '发布状态已变化，请刷新。');
            $snapshot = json_decode($submission->snapshot, true, 512, JSON_THROW_ON_ERROR);
            $this->validatePhotos($owner, $snapshot['photo_ids'] ?? []);
            $before = $publication?->publication_status ?? 'not_published';
            $publication ??= new UserProfileShowcasePublication(['user_id' => $owner]);
            $publication->fill(['source_draft_id' => $draft->id, 'source_draft_updated_at' => $draft->updated_at,
                'source_revision' => $draftRevision, 'source_submission_id' => $submission->id, 'source_moderation_status' => 'approved',
                'published_payload' => $snapshot, 'revision' => $publicationRevision + 1, 'publication_status' => 'published',
                'public_display_eligible' => true, 'matching_scoring_eligible' => false, 'published_at' => now()])->save();
            $this->publicationAudit($publication, $owner, 'owner_publish_confirmed', $before, 'published');
            return $this->publicationPayload($publication);
        });
    }

    public function withdraw(int $owner, int $expected): array
    {
        return DB::transaction(function () use ($owner, $expected) {
            app(JourneyStore::class)->users([$owner]);
            $publication = UserProfileShowcasePublication::where('user_id', $owner)->lockForUpdate()->first();
            abort_unless($publication, 404);
            if ($publication->publication_status === 'withdrawn' && in_array($expected, [$publication->revision, $publication->revision - 1], true)) {
                return $this->publicationPayload($publication);
            }
            abort_unless($publication->revision === $expected, 409, '发布状态已变化，请刷新。');
            $publication->update(['revision' => $expected + 1, 'publication_status' => 'withdrawn', 'public_display_eligible' => false]);
            $this->publicationAudit($publication, $owner, 'owner_withdraw', 'published', 'withdrawn');
            return $this->publicationPayload($publication);
        });
    }

    private function publicationAudit(UserProfileShowcasePublication $publication, int $owner, string $action, string $before, string $after): void
    {
        UserProfileShowcasePublicationAudit::create(['publication_id' => $publication->id, 'user_id' => $owner,
            'source_draft_id' => $publication->source_draft_id, 'actor_type' => 'draft_owner', 'actor_id' => (string) $owner,
            'action' => $action, 'previous_publication_status' => $before, 'new_publication_status' => $after]);
    }

    private function canView(int $viewer, int $owner, array $audiences): bool
    {
        if ($viewer === $owner) return true;
        $policy = app(SocialPolicy::class);
        if (! $policy->pairAllowed($viewer, $owner)) return false;
        return (in_array('friends', $audiences, true) && (bool) $policy->friendship($viewer, $owner))
            || (in_array('contacts', $audiences, true) && ((bool) app(LiveConsentService::class)->match($viewer, $owner, true)
                || (app(LiveConsentService::class)->gates($viewer, $owner)['live_read_allowed'] ?? false)))
            || (in_array('relationship', $audiences, true) && app(FormalRelationshipService::class)->sharingAllowed($viewer, $owner));
    }

    private function requirePublication(int $viewer, int $owner): UserProfileShowcasePublication
    {
        app(JourneyStore::class)->users([$viewer, $owner]);
        $publication = UserProfileShowcasePublication::where('user_id', $owner)->lockForUpdate()->first();
        // Check current context before exposing whether a publication exists.
        abort_unless($this->canView($viewer, $owner, ['friends', 'contacts', 'relationship']), 404, 'showcase_unavailable');
        abort_unless($publication, 404, 'showcase_not_published');
        abort_if($publication->publication_status === 'withdrawn', 404, 'showcase_withdrawn');
        $audiences = $publication->published_payload['audiences'] ?? [];
        abort_unless($this->canView($viewer, $owner, $audiences), 404, 'showcase_unavailable');
        abort_unless($publication->publication_status === 'published' && $publication->public_display_eligible, 404, 'showcase_not_published');
        return $publication;
    }

    public function detail(int $viewer, int $owner): array
    {
        return DB::transaction(function () use ($viewer, $owner) {
            $publication = $this->requirePublication($viewer, $owner);
            return ['ok' => true, 'owner_id' => $owner, 'public_id' => 'ES-'.$owner] + $this->publicationPayload($publication);
        });
    }

    private function photoReferences(int $owner, array $ids, ?int $revision = null): array
    {
        return array_map(fn ($id) => ['id' => (int) $id, 'content_path' => '/api/v1/profile/showcase/'.$owner.'/photos/'.$id
            .($revision === null ? '' : '?publication_revision='.$revision)], $ids);
    }

    private function decorateSnapshot(int $owner, array $snapshot, int $revision): array
    {
        $safe = array_intersect_key($snapshot, array_flip(self::FIELDS));
        $safe['photos'] = $this->photoReferences($owner, $snapshot['photo_ids'] ?? [], $revision);
        return $safe;
    }

    private function validatePhotos(int $owner, array $ids): void
    {
        abort_if(count($ids) > 6 || count($ids) !== count(array_unique($ids)), 422, '最多选择6张不同的照片。');
        foreach ($ids as $id) {
            $photo = DB::table('profile_showcase_photos')->where('id', $id)->where('user_id', $owner)->first();
            $asset = $photo ? MediaAsset::find($photo->media_asset_id) : null;
            abort_unless($asset && $asset->owner_user_id === $owner && $asset->storage_disk === 'v1016_showcase'
                && $asset->isBackingObjectAvailable(), 422, '展示照片不可用，请重新选择。');
        }
    }

    public function uploadPhoto(User $owner, UploadedFile $input, int $expected, string $uploadId): array
    {
        $hash = hash_file('sha256', $input->getPathname());
        $existing = DB::transaction(function () use ($owner, $expected, $uploadId, $hash) {
            app(JourneyStore::class)->users([(int) $owner->id]);
            $old = DB::table('profile_showcase_photos')->where('user_id', $owner->id)->where('client_upload_id', $uploadId)->first();
            if ($old) {
                abort_unless(hash_equals($old->input_hash, $hash), 409, 'upload_id_conflict');
                return $old;
            }
            $draft = $this->draft((int) $owner->id);
            abort_unless((int) ($draft?->revision ?? 0) === $expected, 409, 'SHOWCASE_CHANGED_REFRESH_REQUIRED');
            abort_if(count($draft?->photo_ids ?? []) >= 6, 422, '最多6张展示照片。');
            return null;
        });
        if ($existing) return $this->ownerPayload((int) $owner->id, 'photo_uploaded');
        $asset = app(PrivateProfileImageService::class)->store($owner, $input, 'profile_showcase', 'v1016_showcase', 1024);
        return DB::transaction(function () use ($owner, $expected, $uploadId, $hash, $asset) {
            app(JourneyStore::class)->users([(int) $owner->id]);
            $duplicate = DB::table('profile_showcase_photos')->where('user_id', $owner->id)->where('client_upload_id', $uploadId)->first();
            if ($duplicate) {
                abort_unless(hash_equals($duplicate->input_hash, $hash), 409, 'upload_id_conflict');
                return $this->ownerPayload((int) $owner->id, 'photo_uploaded');
            }
            $draft = $this->draft((int) $owner->id);
            abort_unless((int) ($draft?->revision ?? 0) === $expected, 409, 'SHOWCASE_CHANGED_REFRESH_REQUIRED');
            abort_if(count($draft?->photo_ids ?? []) >= 6, 422, '最多6张展示照片。');
            $id = DB::table('profile_showcase_photos')->insertGetId(['user_id' => $owner->id, 'media_asset_id' => $asset->id,
                'client_upload_id' => $uploadId, 'input_hash' => $hash, 'created_at' => now(), 'updated_at' => now()]);
            $fields = $draft ? $this->snapshot($draft) : [];
            $fields['photo_ids'] = [...($draft?->photo_ids ?? []), $id];
            return $this->saveDraft((int) $owner->id, $fields, $expected);
        });
    }

    public function photoContent(int $viewer, int $owner, int $photoId, int $publicationRevision)
    {
        return DB::transaction(function () use ($viewer, $owner, $photoId, $publicationRevision) {
            app(JourneyStore::class)->users([$viewer, $owner], $viewer === $owner);
            if ($viewer === $owner) {
                $draft = $this->draft($owner);
                $publication = UserProfileShowcasePublication::where('user_id', $owner)->first();
                $ids = array_merge($draft?->photo_ids ?? [], $publication?->published_payload['photo_ids'] ?? []);
            } else {
                $publication = $this->requirePublication($viewer, $owner);
                abort_unless($publication->revision === $publicationRevision, 404, 'unavailable');
                $ids = $publication->published_payload['photo_ids'] ?? [];
            }
            abort_unless(in_array($photoId, array_map('intval', $ids), true), 404, 'unavailable');
            $photo = DB::table('profile_showcase_photos')->where('id', $photoId)->where('user_id', $owner)->first();
            $asset = $photo ? MediaAsset::whereKey($photo->media_asset_id)->where('owner_user_id', $owner)->first() : null;
            abort_unless($asset && $asset->storage_disk === 'v1016_showcase' && $asset->isBackingObjectAvailable(), 404, 'unavailable');
            return response()->file(Storage::disk('v1016_showcase')->path($asset->storage_key),
                ['Content-Type' => 'image/png', 'Cache-Control' => 'private, no-store', 'Vary' => 'Authorization, Cookie', 'X-Content-Type-Options' => 'nosniff']);
        });
    }
}
