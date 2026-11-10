# EliteSync v10｜APP-INT-01 Synthetic App Shell Integration Task｜v0.1

Status: `OWNER-AUTHORIZED — REAL APPSHELL + SYNTHETIC SESSION + EXISTING MOCK PROVIDERS + ANDROID RUNTIME VERIFICATION — NO REAL BACKEND / NO AUTHORITY INVENTION`

Date: 2026-09-21 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

Pre-task main:

`3054e8c048df3ab3b4e30dbce12aeadbc46b2341`

APP-RUN-01 is accepted. This task moves from the local visual fixture into the real four-tab application shell.

## Goal

On the Android emulator, launch the real `Home | Progress | Messages | Me` shell using an explicitly synthetic local session and existing mock providers.

The demo must visibly prove:

- Home renders through the real shell;
- Progress opens;
- Connection opens and remains authority-not-established;
- Match entry is still blocked by readiness and routes to Readiness rather than inventing readiness;
- Messages remains fail-closed because Conversation authority is not established;
- Me and Readiness open;
- no production API or RTC request is observed.

No new domain policy, backend endpoint, real auth, Connection writer, messaging consent or production capability is created.

## Fresh execution

Fresh-fetch `origin/main` and require the task-publication authority supplied in the execution prompt.

Read `AGENTS.md` first, then this task.

Create a fresh C-drive worktree so the proven Android build path remains single-volume.

Recommended:

- worktree: `C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-app-int-01-shell`
- branch: `impl/app-int-01-synthetic-app-shell-v0-1`

If the directory exists, use a new numbered sibling. Do not clean/reuse it.

## Fixed source inputs

Verify:

- `AGENTS.md`: `c9a8e192f7647a1613a195655fe9c22c56502ddb`
- `apps/flutter_elitesync_module/lib/main_demo.dart`: `3d983548fbb6e880e04c2c8ec9804523b9e4654c`
- `apps/flutter_elitesync_module/lib/app/app.dart`: `400d7bdf243f4ae7d0e05cc135547d3951dba075`
- `apps/flutter_elitesync_module/lib/app/bootstrap/app_bootstrap.dart`: `8d85959ea355213820881015ea822eeebf1b6007`
- `apps/flutter_elitesync_module/test/android_runtime_bootstrap_test.dart`: `9fa5d2c186394565602c566a2f360ecc8184609e`
- `apps/flutter_elitesync_module/lib/shared/providers/session_provider.dart`: `786444bf0de85f799eb2612fcf65029314a24004`
- `apps/flutter_elitesync_module/lib/shared/providers/navigation_guard_provider.dart`: `49fb97d3dbb9f37e548bec6a842151ead1b36111`
- `apps/flutter_elitesync_module/lib/core/storage/secure_storage_service.dart`: `c2d6c84ac40868c5c854da57936c039c1fd66f03`
- `apps/flutter_elitesync_module/lib/core/storage/local_storage_service.dart`: `6f7e67f4fa65e7c010a4250e78314801a9c44351`
- `apps/flutter_elitesync_module/lib/core/storage/cache_keys.dart`: `b1881756c063b18fe8d403afd592e5368d2499ee`
- `apps/flutter_elitesync_module/lib/shared/models/user_summary.dart`: `70b860a07375368a3c4d2fcc92ee7f51209bcd5f`
- `apps/flutter_elitesync_module/lib/app/router/app_route_names.dart`: `d831a56e7f8a7bb162b25f390128b3c004042e68`
- `apps/flutter_elitesync_module/lib/app/router/app_router.dart`: `25c6ce546a90352aecb48f2f4ed219ecfd1dc8a0`
- `apps/flutter_elitesync_module/lib/features/progress/presentation/pages/progress_page.dart`: `8dd79b804c0d82a52eff5f876918d0f4673b2ed4`
- `apps/flutter_elitesync_module/lib/features/connection/presentation/pages/connection_page.dart`: `71a05388dcb6846c7a0f868a02d98dd47ac3f387`
- `apps/flutter_elitesync_module/lib/features/me/presentation/pages/me_landing_page.dart`: `619987bc7da198c1586c9bf03848ee951211235c`
- `apps/flutter_elitesync_module/lib/features/me/presentation/pages/me_purpose_pages.dart`: `f9e80e073b678d936f6bda46a745785df2f46ab1`
- `apps/flutter_elitesync_module/lib/features/chat/presentation/state/conversation_access_state.dart`: `f75ebffebcd8f361af654a4d9304e10b8c476d06`
- `apps/flutter_elitesync_module/lib/features/chat/presentation/widgets/conversation_access_gate.dart`: `8d927bac0f0e9de5fa2a8813d3e012139e189be8`
- `apps/flutter_elitesync_module/lib/features/home/presentation/providers/home_provider.dart`: `a0a58c72d9bd15cf95fd0b7d02568a2d7217c3c1`
- `apps/flutter_elitesync_module/lib/features/home/data/datasource/home_remote_data_source.dart`: `58eafaf97749207fdce24d04ffe441d1a3d0b0d5`
- `apps/flutter_elitesync_module/lib/features/match/presentation/providers/match_providers.dart`: `e43f3dd7529cd5476cc5de946d5e703537c1eff1`
- `apps/flutter_elitesync_module/pubspec.lock`: `b56c4b2c45bab65106c12e4d75d6c5b34209aeb4`

Do not enumerate the repository or old repository.

## Implementation

Modify only:

1. `apps/flutter_elitesync_module/lib/main_demo.dart`
2. `apps/flutter_elitesync_module/test/android_runtime_bootstrap_test.dart`

Create:

3. `docs/architecture/ELITESYNC_V10_APP_INT_01_SYNTHETIC_APP_SHELL_INTEGRATION_RESULT_V0_1.md`

### Demo bootstrap

Keep all existing safety properties:

- dev flavor;
- app name clearly synthetic/dev;
- `apiBaseUrl=http://127.0.0.1:9/`;
- `useMockData=true`;
- existing mock flags true;
- `useLiveKitRtc=false`;
- no internal admin/match mutation authority.

Change the demo initial route from the visual fixture to:

`AppRouteNames.home`

Before `runEliteSyncApp()`, seed only synthetic local session state using existing storage services:

- secure access token: an unmistakable constant such as `ELITESYNC_SYNTHETIC_DEMO_TOKEN_NOT_AUTHORITY`;
- no real refresh token;
- local last-known profile with a reserved synthetic ID, clearly synthetic phone/name strings, normal user role, no real identifying data;
- mark first-use onboarding as completed for this demo so it does not obscure the shell.

This seed is demo-only. It is not source authority, real authentication, server authorization or production login.

Do not modify `session_provider.dart` or `navigation_guard_provider.dart`.

Because navigation guard intentionally maps authenticated state to readiness UNKNOWN, preserve that behavior. Do not force readiness=ready.

### Tests

Extend the existing demo bootstrap test to prove:

- initial route is `/home`;
- loopback API / mock / RTC properties remain;
- synthetic session constants contain no production credential;
- demo profile is explicitly synthetic;
- onboarding seed status is completed/skipped only for demo convenience.

Prefer small pure constants/helpers in `main_demo.dart` where useful.

## Build/runtime

Use the accepted C-drive build recipe:

1. `flutter pub get --enforce-lockfile`; lockfile must remain unchanged.
2. Run:
   `flutter analyze --no-pub`
3. Run:
   `flutter test --no-pub test/android_runtime_bootstrap_test.dart test/widget_test.dart`

Analyze and test: initial + at most one correction rerun each.

Use a fresh task-local C-drive `GRADLE_USER_HOME`.

Generated `.android/gradle.properties` may use the already proven ignored build flags:

`kotlin.incremental=false`
`kotlin.compiler.execution.strategy=in-process`
`org.gradle.daemon=false`
`target=lib/main_demo.dart`

Direct build:

`.\gradlew.bat :app:assembleDebug --no-daemon --stacktrace --info --console=plain --max-workers=2`

Initial + one retry only for transient official repository/TLS or directly justified generated-host issue.

Install with ADB and launch the generated host. Clearing/uninstalling the previous generated-host package is allowed if necessary for deterministic synthetic state or storage capacity; do not read app-private data.

## Required emulator interactions

After launch, directly verify these real app behaviors:

1. first visible shell is Home with bottom navigation;
2. tap `Progress`;
3. tap `Connection` and confirm authority-not-established presentation; navigate back;
4. tap `Match` and confirm the readiness guard takes the user to Readiness / “准备状态尚未确定” rather than showing a fabricated match;
5. tap `Messages` and confirm “消息权限尚未建立” / protected content remains hidden;
6. tap `Me`, then `Readiness`, and confirm readiness remains unknown;
7. return to Home.

Use GUI interaction or ADB input only on the selected emulator.

Observe PID/logs during the sequence. No production EliteSync API or RTC polling may be observed.

If Home mock provider renders fallback/mock content without network, that is acceptable. A production API request is not.

## Bounded repair

If analyzer/compiler/runtime identifies a concrete build/UI blocker, at most two additional tracked files under the Flutter module may be modified, only to make this exact shell flow function and without changing domain authority or dependency versions.

A visible layout overflow on a required shell screen may be repaired if it materially obstructs interaction. Do not perform broad visual redesign.

Any extra path must be named by observed evidence and recorded.

## Publication

Publish only after the final candidate is analyzed, tested, built, installed and interacted with.

Candidate sole parent = APP-INT-01 task-publication authority.

Normal tracked scope is the two modified files plus one result document; maximum 5 paths with bounded repairs.

Generated host, APK, caches and screenshots stay untracked.

Result document should be concise and record:

- authority/candidate/tree/path blobs;
- versions/device;
- lock/analyze/test/build results;
- synthetic session bootstrap used;
- each required interaction and visible outcome;
- production API/RTC observation;
- bounded repairs;
- remaining blockers.

Success classification:

`APP-INT-01 COMPLETE — REAL FOUR-TAB APPSHELL RUNNING ON ANDROID — SYNTHETIC SESSION BOOTSTRAP ACTIVE — HOME/PROGRESS/MESSAGES/ME INTERACTION VERIFIED — READINESS/MATCH/CONNECTION/CONVERSATION FAIL-CLOSED BOUNDARIES VISIBLE — NO PRODUCTION API/RTC — READY FOR READINESS + MATCH SYNTHETIC STATE INTEGRATION`

Candidate author cannot self-accept or move main.

Then STOP.
