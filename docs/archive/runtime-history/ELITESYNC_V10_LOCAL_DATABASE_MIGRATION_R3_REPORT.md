# EliteSync-v10 Local Database Migration R3 Report

## 1. Database identity

Phase: `Phase 5C-2C-R3 — Local Database Migration Execution`

Pre-execution runtime and connection identity:

- Engine: MariaDB
- Version: `10.11.18-MariaDB-ubu2204`
- Host: `127.0.0.1`
- Port: `43316`
- Database: `elitesync_v10_local`
- Configured username: `elitesync_v10_local`
- Authenticated user: `elitesync_v10_local@%`
- Database container: `elitesync-v10-mariadb-local`
- Database container ID: `d9fad232c2210850293214b2c80f4863c8bdaa7abd92aec245b55fd109f66c28`
- Container state: `running`
- Container health: `healthy`
- Container hostname: `d9fad232c221`
- Proxy: `elitesync-v10-mariadb-loopback-proxy`
- Effective proxy binding: `127.0.0.1:43316`
- Listener count at the expected loopback endpoint: `1`
- Pre-execution application table count: `0`

Laravel effective configuration reported `local / mariadb / 127.0.0.1 / 43316 / elitesync_v10_local / elitesync_v10_local`. The existing machine MySQL endpoint at `localhost:3306` was not used or contacted.

## 2. Command

Executed exactly once from `services/backend-laravel/`:

`php artisan migrate --no-interaction --no-ansi`

No second migration command was executed.

## 3. Result

- Exit status: `0`
- Result: success
- Migration repository creation: `DONE`
- Repository migrations reported `DONE`: `57`

Migration output began with:

```text
INFO  Preparing database.
Creating migration table ... DONE
INFO  Running migrations.
```

The command then reported `DONE` for every migration from:

- first: `0001_01_01_000000_create_users_table`
- last: `2026_08_03_000010_add_idempotency_fields_to_chat_messages_table`

No warning, error, rollback, or failed migration appeared in the command output.

## 4. Applied migrations

- Migration source files: `57`
- Applied migration records: `57`
- Distinct migration batches: `1`
- Batch distribution: batch `1` contains `57` migrations
- Last applied migration: `2026_08_03_000010_add_idempotency_fields_to_chat_messages_table`
- Last applied batch: `1`

The migration source set was frozen before execution and rechecked afterward:

- Pre-execution SHA-256: `06970DD6175E869F8783693981D4E6476AB6A4082849EF862D92B1F886FE1BC1`
- Post-execution SHA-256: `06970DD6175E869F8783693981D4E6476AB6A4082849EF862D92B1F886FE1BC1`
- Post-execution migration-source Git diff: empty

## 5. Schema validation

- Created table count, including Laravel's `migrations` table: `43`
- `migrations` table present: yes
- Applied migration count in `migrations`: `57`
- Schema remained bound to `elitesync_v10_local` on MariaDB `10.11.18-MariaDB-ubu2204`

Created tables:

```text
app_events
app_release_versions
cache
cache_locks
chat_messages
conversations
conversation_match_links
conversation_members
dating_matches
dating_rounds
dating_round_channels
dating_round_user_states
failed_jobs
jobs
job_batches
matching_operation_audits
matching_runs
matching_run_candidates
mbti_attempts
media_assets
media_processing_jobs
message_attachments
migrations
moderation_reports
notifications
password_reset_tokens
personal_access_tokens
questionnaire_answers
questionnaire_attempts
questionnaire_questions
rtc_sessions
rtc_session_events
sessions
status_posts
status_post_likes
users
user_astro_profiles
user_blocks
user_profile_showcase_drafts
user_profile_showcase_publications
user_profile_showcase_publication_audits
user_profile_showcase_review_audits
user_relationship_events
```

This validation proves successful migration of the isolated local schema. It does not claim production-schema parity, application acceptance, seed readiness, or production readiness.

## 6. Safety boundary

- No `migrate:fresh` executed.
- No rollback executed.
- No seed executed.
- No dump or restore executed.
- No database or user was created.
- No migration file was modified.
- No Model, backend source, config source, bootstrap source, or route was modified.
- Protected backend-source Git diff remained empty after execution.
- No `.env`, database file, dump, or runtime artifact was staged or committed.
- Existing unrelated untracked files were preserved.
- No credential value was printed or recorded.

No production database accessed.

No production data used.
