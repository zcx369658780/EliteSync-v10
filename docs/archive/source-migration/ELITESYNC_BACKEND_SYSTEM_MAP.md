# EliteSync Backend System Map

## Evidence boundary

This map records facts visible in `zcx369658780/EliteSync` at exact commit `13277df80c3b82f33887ffe110d807ad79b38d8c`, plus the already frozen v10 statement that server remains business truth.

The Owner authorized read-only Alibaba Cloud SSH inspection. `C:\Users\zcxve\.ssh\codexkey` and its `.pub` file form a valid pair but were rejected by the host. The separately inspected `C:\Users\zcxve\.ssh\Codexkey.pem` is a different valid RSA private key and successfully authenticated to the source-configured `root@101.133.161.203`. The existing `known_hosts` file contained ECDSA, ED25519, and RSA entries for that IP, and strict host-key checking was used.

Remote inspection was limited to deployment identity, file/directory names, framework versions, route metadata, service-unit state, process-name matching, safe path metadata, and selected file blob identities. `.env` content, secrets, logs, database contents/schema state, user data, and media objects were not read. No remote state was modified.

## 1. Backend identity

- Source path: `services/backend-laravel`
- Role: canonical Laravel business backend candidate; server remains business truth.
- Composer package type: Laravel project.
- Declared framework constraint: `laravel/framework ^11.31` (Laravel 11 line).
- Declared PHP constraint: `^8.2`; the repository README separately says the locked dependency set requires PHP 8.4+.
- Authentication package: `laravel/sanctum ^4.0`.
- Realtime package: `workerman/workerman ^5.1`.
- Live runtime path: `/opt/elitesync/services/backend-laravel` (present).
- Live host/user: Alibaba Cloud host `101.133.161.203`, authenticated as `root`.
- Live runtime versions: PHP `8.4.18`; `php artisan --version` reports Laravel Framework `11.48.0`.
- Deployment form: copied application tree with no `.git` directory; the release procedure itself was not inspected.
- Live Nginx and PHP 8.4 FPM units are loaded, active, and running.

## 2. Directory structure

The baseline backend root contains:

- `app/` — application code: HTTP controllers and middleware, models, services, jobs, console commands, and providers.
- `bootstrap/` — Laravel application bootstrap and middleware aliases.
- `config/` — authentication, database, cache, queue, filesystems, media, matching, security, and other configuration.
- `database/` — migrations, factories, and seeders.
- `routes/` — `api.php`, `web.php`, and `console.php`.
- `public/` — HTTP document root assets/entrypoint.
- `resources/` — frontend/resource inputs.
- `storage/` — Laravel runtime storage structure.
- `tests/` — feature and unit tests.
- `tools/` — backend-local supporting tools.
- `docker/` — backend-local container material.

Repository-level `infra/` separately contains Compose definitions, an Nginx configuration, and a Workerman systemd service candidate. Their presence does not prove deployment.

The live backend top level contains the expected Laravel application directories and dependency tree, including `app`, `bootstrap`, `config`, `database`, `public`, `resources`, `routes`, `storage`, `tests`, `tools`, and `vendor`. A `.env` file is present but was not read. Live source inventory counts were 27 controller files, 49 service files, 34 model files, 57 migration files, one Job file, and 22 Console Command files.

## 3. API route map

`routes/api.php` defines two API prefixes. All v1 routes are finally wrapped in `secure.transport`; v2 health/readiness/location-contract routes also use `secure.transport`.

Live `php artisan route:list --json` returned 126 total routes. The deployed `routes/api.php` blob does not match the exact baseline blob. The live API surface includes one observed media route not present in the baseline route file: `POST /api/v1/media/{assetId}/process-demo`, handled by `MediaController@processDemo` under Sanctum authentication and media throttling. No endpoint request was made.

### Public or separately guarded endpoints

- `v2/app`: health and readiness; `v2/contracts/location`: location contract.
- `v1/app`: health and version check.
- `v1/media/{assetId}/content`: media content endpoint.
- `v1/auth`: register and login use `throttle:auth`; refresh, password change, and account deletion use `auth:sanctum`.

### Sanctum-authenticated v1 domains

- Questionnaire: questions, replacement, answers, history, legacy submit/draft/reset/progress/profile aliases.
- Telemetry: general events plus match explanation, first-chat entry, and feedback events.
- Profile: basic profile, city, showcase draft/publication, astrology, and MBTI.
- Matching: current match, confirm, history, explanation, and current match round; singular legacy aliases remain.
- Conversations and messages: peer lookup, conversation list/create/read, send/list/read, and a WebSocket stub route.
- Media: list, upload, and metadata lookup.
- Relationships, notifications, RTC calls, moderation, home/discovery/content, status posts, and geo places.
- Admin: users, reports/actions, questionnaire quality, verification, and development matching controls under `admin.phone`.
- Admin matching: round/run inspection and prepare, execute-request, reveal, retry, close, and compensation operations under `matching.operation`.

### Main controllers

- Identity/profile: `AuthController`, `ProfileController`, `AstroProfileController`, `MbtiProfileController`, `QuestionnaireController`, `ProfileShowcaseDraftController`, `ProfileShowcasePublicationController`.
- Matching: `MatchController`, `MatchRoundController`, `AdminMatchingController`.
- Social/chat/media: `ConversationController`, `MessageController`, `MediaController`, `RelationshipController`, `NotificationController`, `RtcController`, `StatusPostController`.
- Safety/operations: `ModerationController`, `AdminController`, `FrontendTelemetryController`, `AppVersionController`.
- Supporting/readiness: `HomeController`, `GeoController`, v2 `AppHealthController`, `AppReadinessController`, and `LocationContractController`.

### Main service groups

- Matching: `MatchingEngineService`, `MatchingRoundService`, `MatchingRunService`, `MatchRoundProjectionService`, `MatchingDebugModeService`, compatibility and feature-extractor services.
- Conversation/realtime: `ConversationDomainService`, `ConversationAtomicSendService`, `ConversationCapabilityService`, `ChatWebsocketAuthorizationService`, `RtcSessionService`, `LiveKitTokenService`.
- Media: `MediaAssetService`, `MediaStorageService`, `MediaUploadPolicy`, `MediaStateMachine`, `MediaCacheService`.
- Profile/personality: `PersonalityProfileService`, `PersonalityCompatibilityService`, `MbtiCompatibilityService`, `ProfileReadinessService`.
- Astrology: Bazi, Western natal/compatibility, Ziwei, lunar/solar-time, rollout/dependency-gate, and Python-render adapter services.
- Notifications/telemetry support: `NotificationService` and `EventLogger`.

## 4. Database model map

The baseline declares MariaDB as the v10 database architecture fact. Repository configuration provides MySQL and MariaDB drivers; its app-scoped default falls back to the `mysql` connection. Actual production driver and schema state were not checked.

### Model domains

- Account/profile: `User`, `UserAstroProfile`, `MbtiAttempt`, showcase draft/publication and their audit models.
- Questionnaire: `QuestionnaireQuestion`, `QuestionnaireAnswer`, `QuestionnaireAttempt`.
- Matching: `DatingMatch`, `DatingRound`, `DatingRoundChannel`, `DatingRoundUserState`, `MatchingRun`, `MatchingRunCandidate`, `MatchingOperationAudit`.
- Conversation/chat: `Conversation`, `ConversationMember`, `ConversationMatchLink`, `ChatMessage`, `MessageAttachment`.
- Media: `MediaAsset`, `MediaProcessingJob`.
- Social/safety: `StatusPost`, `StatusPostLike`, `UserRelationshipEvent`, `UserBlock`, `ModerationReport`.
- RTC/notification/operations: `RtcSession`, `RtcSessionEvent`, `AppNotificationItem`, `AppEvent`, `AppReleaseVersion`.

### Core relationships visible in Eloquent models

- A user has one astrology profile and has many reports, blocks, and status posts.
- A dating match belongs to two users and may have one conversation-match link.
- A dating round has runs and per-user states; a matching run belongs to a round and has candidate users.
- A conversation belongs to its creator, has members, and can link to dating matches; members link users and last-read messages.
- A chat message belongs to sender and receiver users and has message attachments; attachments belong to media assets.
- A media asset belongs to an owner user and has processing records.
- Moderation reports link reporter, target user, and optionally a target message or status post.
- RTC sessions link initiator, peer, accepter, ender, and session events.
- Showcase publications link their source draft and publication audits.

Migrations at the baseline create or evolve users, tokens, questionnaire data, matches/rounds/runs, chat/conversations, media, notifications, relationships, moderation, status posts, RTC, showcase publication/audits, astrology/MBTI data, cache, and jobs tables. This is a source migration inventory, not proof that any deployed database has applied them.

The deployed file tree contains 34 model files and 57 migration files. The selected live `User.php` blob matches the exact baseline. The database itself was not queried, so applied migration state and live relationships remain unverified.

## 5. Authentication and permission model

- `User` is Laravel `Authenticatable` and uses Sanctum `HasApiTokens`; passwords are hidden and cast as hashed.
- Register/login are public throttled endpoints; refresh, password change, account deletion, and the main product API use `auth:sanctum`.
- `User::isAdminRole()` checks whether `role` equals `admin`.
- `admin.phone` requires an authenticated admin-role user whose phone appears in `config('app.admin_phones')`, with source-coded local/development exceptions for specific development matching endpoints.
- `matching.operation` requires the same admin-role/phone check and also requires `matching.foundation.admin_operations_enabled`.
- `secure.transport` can require HTTPS based on `security.enforce_https`, accepting direct secure requests or forwarded-protocol evidence.
- No deployed environment values, effective admin phone list, active tokens, or live permission outcomes were inspected.

The selected deployed `EnsureAdminPhone.php` blob matches the exact baseline. This confirms file identity only; effective configuration and access outcomes remain unverified.

## 6. Admin-related backend capability

The route/controller surface includes:

- User list and disable operations.
- Moderation report list, detail, and action handling.
- Verification queue and verification update.
- Questionnaire quality statistics and low-drop pruning operation.
- Development matching run, release-drop, and matching-debug controls.
- Matching round/run visibility and prepare, execution request, reveal, retry, close, and compensation operations.
- Internal profile-showcase review exists as an Artisan command (`InternalProfileShowcaseReviewCommand`), not as a listed public API route.

These capabilities exist in source, and their route presence was checked separately on the live host. Effective enablement, successful behavior, and production authorization remain unknown.

The corresponding admin and admin-matching routes were present in the live route inventory with Sanctum plus `EnsureAdminPhone` or `EnsureMatchingOperationPermission` middleware. No admin endpoint was invoked, so enablement and authorization outcomes remain unknown.

## 7. Queue, Redis, and worker structure

- Queue default is configured by `QUEUE_CONNECTION`, then `APP_QUEUE_CONNECTION`, with `database` as the source default.
- A Redis queue connection is configured with the `default` queue and a 90-second default retry interval.
- Redis default and cache connections are configured separately; source defaults use databases 0 and 1.
- `ProcessMediaAssetJob` implements `ShouldQueue` and records media-processing state before validating and advancing an asset.
- Composer's development script runs `php artisan queue:listen --tries=1` alongside the app, logs, and Vite.
- `ChatWebsocketServerCommand` starts a Workerman-based chat WebSocket server; repository-level `infra/elitesync-ws.service` is a service definition candidate.
- Live Redis is loaded, active, and running.
- The live host has no loaded Supervisor unit (`LoadState=not-found`); no matching `artisan queue:*` worker process was observed.
- The live `elitesync-ws` systemd unit uses `/opt/elitesync/services/backend-laravel` and starts `artisan chat:ws --host=127.0.0.1 --port=8081`. At inspection it was in `activating/auto-restart`; its most recent process exited with status 1, and no matching `artisan chat:ws` process was observed. Logs were not read, so the failure cause is unknown.
- The deployed `ProcessMediaAssetJob.php` blob matches the exact baseline.

## 8. Storage and media handling

- Laravel filesystem default is `local`; configured disks include private local, public local, S3, and an OSS-compatible S3 disk.
- The public local disk maps to `storage/app/public`; the configured symbolic link maps `public/storage` to that directory.
- `MediaUploadPolicy` selects a configurable disk (source default `public`), limits uploads to 25 MiB by default, accepts image/video MIME prefixes, and uses `chat-media` as the default base path.
- `MediaStorageService` creates user/type/UUID storage keys, writes through Laravel `Storage`, and returns disk, provider, key, and URL metadata. Its source-level provider label is `oss`, even when the selected disk is configurable.
- `ProcessMediaAssetJob` records a processing job, blocks disallowed MIME types, and otherwise advances eligible assets through processing to ready state while updating cache snapshots.
- `v1/media/{assetId}/content` is the content route; upload/list/metadata routes are Sanctum-protected.
- Actual storage disk, OSS bucket, local path, object inventory, access policy, and deployed URLs were not inspected.
- On the live host, `storage` exists with mode `770` and owner/group `www-data:www-data`; `storage/app/public` exists with mode `775` and owner/group `root:root`. `storage/app/private` and `public/storage` were absent at inspection. No stored-file names or contents were read.
- The deployed `MediaStorageService.php` blob matches the exact baseline.

## 9. Known unknowns

- Exact deployed source revision: the application tree has no `.git` directory. Selected blob comparison shows `composer.json`, `composer.lock`, `User.php`, `EnsureAdminPhone.php`, `ProcessMediaAssetJob.php`, and `MediaStorageService.php` match the baseline, while `routes/api.php` does not.
- Origin, authorization, and intended lifecycle of the deployed `process-demo` media route delta.
- Web-server document-root configuration and release mechanism beyond the observed running services and application path.
- Effective environment configuration, without reading or exposing secrets.
- Actual MariaDB schema, applied migration set, table counts, constraints, and data relationships.
- Active queue connection, Redis database selection, retry policy, failed jobs, and the root cause of the Workerman unit's restart loop.
- Effective authentication tokens, admin allowlist, HTTPS enforcement, throttles, and matching-operation enablement.
- Effective media disk/provider, filesystem permissions, OSS configuration, URL access controls, and stored objects.
- Whether all source routes/controllers/services are deployed and reachable.

No refactoring or migration recommendation is made by this system map.
