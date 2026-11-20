<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;

final class ObjectDataRequestService
{
    private function objectVersion(int $owner, string $type, string $key): string
    {
        if ($type === 'work') {
            $post = DB::table('status_posts')->where('id', $key)->where('author_user_id', $owner)->lockForUpdate()->first();
            abort_unless($post, 404, 'unavailable');

            return (string) $post->audience_revision.($post->is_deleted ? '-withdrawn' : '-present');
        }
        $comment = DB::table('status_post_comments')->where('id', $key)->where('author_id', $owner)->lockForUpdate()->first();
        abort_unless($comment, 404, 'unavailable');

        return (string) $comment->revision;
    }

    private function testOnly(int $owner): bool
    {
        return app(DataPurposeService::class)->testOnly($owner);
    }

    public function capability(int $owner, string $type, string $key): array
    {
        $version = $this->objectVersion($owner, $type, $key);
        $test = $this->testOnly($owner);
        $record = $test ? DB::table('object_data_requests')->where('user_id', $owner)
            ->where('object_type', $type)->where('object_key', $key)->lockForUpdate()->first() : null;

        return ['object_type' => $type, 'object_version' => $version, 'test_only' => $test,
            'channel' => $test ? 'TEST_ONLY' : 'REQUEST_CHANNEL_UNAVAILABLE',
            'state' => $this->state($record, 'NO_REQUEST'), 'completion_available' => false];
    }

    public function request(int $owner, string $type, string $key, array $data): array
    {
        $capability = $this->capability($owner, $type, $key);
        abort_unless($capability['test_only'], 409, 'REQUEST_CHANNEL_UNAVAILABLE');
        $table = DB::table('object_data_requests')->where('user_id', $owner);
        $byKey = (clone $table)->where('request_key', $data['request_key'])->lockForUpdate()->first();
        if ($byKey) {
            abort_unless($byKey->object_type === $type && $byKey->object_key === $key
                && $byKey->object_version === $data['expected_version'], 409, 'REQUEST_KEY_CONFLICT');

            return $this->result($owner, $type, $key, $data['request_key']);
        }
        abort_unless($capability['object_version'] === $data['expected_version'], 409, 'OBJECT_CHANGED_REFRESH_REQUIRED');
        abort_unless($capability['state'] === 'NO_REQUEST', 409, 'REQUEST_ALREADY_EXISTS');
        DB::table('object_data_requests')->insert([
            'user_id' => $owner, 'object_type' => $type, 'object_key' => $key,
            'object_version' => $data['expected_version'], 'request_key' => $data['request_key'],
            'state' => 'REQUESTED_TEST_ONLY', 'created_at' => now(), 'updated_at' => now(),
        ]);

        return $this->result($owner, $type, $key, $data['request_key']);
    }

    public function result(int $owner, string $type, string $key, string $requestKey): array
    {
        $capability = $this->capability($owner, $type, $key);
        if (! $capability['test_only']) {
            return ['state' => 'REQUEST_CHANNEL_UNAVAILABLE', 'test_only' => false];
        }
        $record = DB::table('object_data_requests')->where('user_id', $owner)->where('request_key', $requestKey)
            ->where('object_type', $type)->where('object_key', $key)->lockForUpdate()->first();

        return ['state' => $this->state($record, 'NOT_APPLIED'), 'test_only' => true];
    }

    private function state(?object $row, string $missing): string
    {
        if (! $row) {
            return $missing;
        }
        return in_array($row->state, ['REQUESTED_TEST_ONLY', 'ACCEPTED_TEST_ONLY', 'PROCESSING_TEST_ONLY'], true)
            ? $row->state : 'UNKNOWN';
    }

    /** The isolated test processor never has a completion transition. */
    public function advanceTestOnly(int $owner, string $requestKey, string $expected): void
    {
        DB::transaction(function () use ($owner, $requestKey, $expected) {
            app(JourneyStore::class)->users([$owner]);
            abort_unless($this->testOnly($owner) && app()->runningInConsole(), 409, 'REQUEST_CHANNEL_UNAVAILABLE');
            $next = match ($expected) {
                'REQUESTED_TEST_ONLY' => 'ACCEPTED_TEST_ONLY',
                'ACCEPTED_TEST_ONLY' => 'PROCESSING_TEST_ONLY',
                default => abort(409, 'COMPLETION_EVIDENCE_UNAVAILABLE'),
            };
            $count = DB::table('object_data_requests')->where('user_id', $owner)->where('request_key', $requestKey)
                ->where('state', $expected)->update(['state' => $next, 'updated_at' => now()]);
            abort_unless($count === 1, 409, 'REQUEST_CHANGED_REFRESH_REQUIRED');
        }, 3);
    }
}
