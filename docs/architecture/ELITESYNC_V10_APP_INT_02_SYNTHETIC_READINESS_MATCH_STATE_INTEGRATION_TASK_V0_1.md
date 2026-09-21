# EliteSync v10｜APP-INT-02 Synthetic Readiness + Match State Integration Task｜v0.1

Status: `OWNER-AUTHORIZED — DEMO-ONLY SYNTHETIC READINESS + LOCAL READ-ONLY MATCH PROJECTION — ANDROID RUNTIME VERIFICATION — NO CONNECTION/CONVERSATION AUTHORITY`

Date: 2026-09-21 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

Pre-task main:

`b0d1bb2a67baf809348e08fe9f6cc7aed65ad902`

APP-INT-01 is accepted. The real Android four-tab AppShell is established. This task adds one bounded synthetic state transition for demonstration: Readiness becomes explicitly synthetic-ready so the existing Match guard opens the real Match screen, and Match consumes a local read-only synthetic round projection.

## 1. User-visible exit capability

On Android emulator, the synthetic/dev build must prove:

1. Home/Progress/Messages/Me shell still runs;
2. Readiness page shows an explicit **synthetic development readiness** state, visibly not production/server authority;
3. Progress -> Match opens the real Match page rather than redirecting back to Readiness;
4. Match renders one local synthetic candidate proposal through the existing canonical Match UI;
5. Match exposes no authoritative lifecycle mutation action;
6. Match conversation capability remains all false;
7. Connection remains `NOT YET ESTABLISHED`;
8. Messages remains `NOT YET ESTABLISHED` and private content stays hidden;
9. no production API and no RTC polling is observed.

This is synthetic state integration only. It creates no real readiness source, Match writer, Connection, Conversation or production authority.

## 2. Fresh execution and proven Android recipe

Fresh-fetch `origin/main` and require the task-publication authority supplied in the execution prompt.

Read `AGENTS.md` first, then this task.

Create a fresh C-drive worktree:

`C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-app-int-02-readiness-match`

or a numbered new sibling if it already exists.

Recommended branch:

`impl/app-int-02-synthetic-readiness-match-v0-1`

Use the already proven C-drive generated-host build recipe and a fresh task-local C-drive `GRADLE_USER_HOME`.

## 3. Fixed inputs

Verify these exact blobs at authority:

- `AGENTS.md` — `c9a8e192f7647a1613a195655fe9c22c56502ddb`
- `apps/flutter_elitesync_module/lib/main_demo.dart` — `93d62c853d944b452fa789901b2f82e932a4c8b8`
- `apps/flutter_elitesync_module/lib/app/config/app_env.dart` — `d2784ec5cd3fc43e52dd9c4e657197b1955b7062`
- `apps/flutter_elitesync_module/lib/shared/providers/navigation_guard_provider.dart` — `49fb97d3dbb9f37e548bec6a842151ead1b36111`
- `apps/flutter_elitesync_module/lib/shared/models/navigation_snapshot.dart` — `6f678306a0005a4e7300f7fc5cb6637437eceb98`
- `apps/flutter_elitesync_module/lib/features/me/presentation/pages/me_purpose_pages.dart` — `f9e80e073b678d936f6bda46a745785df2f46ab1`
- `apps/flutter_elitesync_module/lib/features/match/data/datasource/match_remote_data_source.dart` — `62d37db30ccd619d1860e9708e479f2f8e02de38`
- `apps/flutter_elitesync_module/lib/mocks/mock_data/match_mock.dart` — `f17a4d1a599ec7777d934e1928f6f3744c807e37`
- `apps/flutter_elitesync_module/lib/features/match/domain/entities/match_round_projection.dart` — `260b2ee1638c3beb1ce2c23681df0c2b88f07b3a`
- `apps/flutter_elitesync_module/lib/features/match/domain/entities/canonical_match_lifecycle.dart` — `14147cce1716da38dfd2e1fdc0fea7af02d5c51f`
- `apps/flutter_elitesync_module/lib/features/match/presentation/widgets/match_round_contract_view.dart` — `cec5b419a72ac290005e95ea058f748df421bac0`
- `apps/flutter_elitesync_module/lib/features/connection/presentation/pages/connection_page.dart` — `71a05388dcb6846c7a0f868a02d98dd47ac3f387`
- `apps/flutter_elitesync_module/lib/features/chat/presentation/state/conversation_access_state.dart` — `f75ebffebcd8f361af654a4d9304e10b8c476d06`
- `apps/flutter_elitesync_module/lib/features/chat/presentation/widgets/conversation_access_gate.dart` — `8d927bac0f0e9de5fa2a8813d3e012139e189be8`
- `apps/flutter_elitesync_module/lib/core/network/api_client.dart` — `42b4f67493b5a7e168c0c0ed441551989a42ab7a`
- `apps/flutter_elitesync_module/test/android_runtime_bootstrap_test.dart` — `6fc25395267bc909912ad293858a8180fce3ff0b`
- `apps/flutter_elitesync_module/pubspec.lock` — `b56c4b2c45bab65106c12e4d75d6c5b34209aeb4`

No repository enumeration or old repository access.

## 4. Exact normal write set

Modify exactly:

1. `apps/flutter_elitesync_module/lib/app/config/app_env.dart`
2. `apps/flutter_elitesync_module/lib/main_demo.dart`
3. `apps/flutter_elitesync_module/lib/shared/providers/navigation_guard_provider.dart`
4. `apps/flutter_elitesync_module/lib/features/me/presentation/pages/me_purpose_pages.dart`
5. `apps/flutter_elitesync_module/lib/features/match/data/datasource/match_remote_data_source.dart`
6. `apps/flutter_elitesync_module/lib/mocks/mock_data/match_mock.dart`
7. `apps/flutter_elitesync_module/test/android_runtime_bootstrap_test.dart`

Create:

8. `apps/flutter_elitesync_module/test/synthetic_readiness_match_integration_test.dart`
9. `docs/architecture/ELITESYNC_V10_APP_INT_02_SYNTHETIC_READINESS_MATCH_STATE_INTEGRATION_RESULT_V0_1.md`

No other tracked file may change except under Section 9 bounded repair.

## 5. Demo-only synthetic readiness

Add an optional AppEnv flag with a default that leaves all existing production/dev entries unchanged, named clearly as synthetic/demo-only, e.g.:

`useSyntheticReadinessProjection = false`

The APP-INT demo entry sets it to true.

Navigation guard may treat readiness as `ReadinessGuardState.ready` only when:

- session is authenticated;
- environment is dev;
- the explicit synthetic readiness flag is true.

Do not infer readiness from `useMockQuestionnaire`, profile completion, verification UI or Match data.

Prefer a pure helper for this resolution so unit tests can verify:

- unauthenticated remains unauthenticated;
- authenticated production/default remains UNKNOWN;
- authenticated dev + explicit synthetic flag becomes ready.

VerificationStatus / QuestionnaireStatus remain their existing values. This synthetic readiness is not a new authoritative source.

## 6. Visible readiness labeling

When the Readiness page renders `ready` due specifically to the demo synthetic flag, do not display the existing wording “准备状态已由权威来源确认” without qualification.

Render an explicit development-only presentation such as:

- title: `Synthetic 准备状态已建立 · 开发演示`
- body must state that this is a local synthetic projection used only to exercise the Match flow and does not prove server/production readiness authority.

Production/default ready presentation remains unchanged.

## 7. Local read-only Match projection

Extend `MatchMock` with one deterministic synthetic Match-round envelope satisfying the current `MatchRoundProjection.fromJson()` contract.

Use unmistakably synthetic identities/names. Because `MatchRoundProjection` requires positive IDs for revealed result identity, use a clearly reserved high-number range and synthetic labels.

Required projection characteristics:

- `state = revealed`;
- valid `server_now` and `updated_at`;
- valid contract/projection metadata;
- deterministic result with synthetic match/partner identity and headline;
- `conversation_capability.can_create = false`;
- `can_send = false`;
- `can_ws = false`.

Do not add Compatibility total authority or hidden real-user-like data.

Modify `MatchRemoteDataSource.getRoundProjection()`:

- when `useMock == true`, return the local synthetic projection without invoking `apiClient`;
- when false, preserve the existing network behavior byte-for-byte as much as practical.

The existing `CanonicalMatchLifecycleAdapter` must remain unchanged. Its authoritative action set remains empty.

## 8. Tests

### Existing demo test

Extend `android_runtime_bootstrap_test.dart` to assert the new synthetic readiness flag is enabled only for the demo env.

### New synthetic integration unit test

Create `synthetic_readiness_match_integration_test.dart`.

At minimum verify:

1. readiness resolution helper:
   - unauthenticated never becomes ready;
   - authenticated default/prod-equivalent flag false => UNKNOWN;
   - authenticated + dev + explicit synthetic flag => ready;
2. local `MatchRemoteDataSource(useMock: true)` returns a valid projection without requiring a network success;
3. projection state is `revealed`;
4. result identities/headline are explicitly synthetic;
5. all Conversation capability booleans are false;
6. `CanonicalMatchLifecycleAdapter.fromRound()` yields:
   - `targetState = proposalPresented`
   - `condition = roundAvailable`
   - `authoritativeActions.isEmpty == true`.

Using a loopback/unreachable ApiClient in the test is acceptable; the mock branch must return before any network call.

## 9. Bounded repair

If analyzer/compiler/runtime identifies a concrete blocker, at most two additional Flutter module tracked files may be modified.

Allowed only if required for this exact Readiness + Match synthetic flow and if it does not:

- create production readiness authority;
- create Match mutation authority;
- create Connection or Conversation;
- change auth/session/token production semantics;
- change dependency versions.

Record exact evidence/path.

## 10. Validation

Run:

`flutter pub get --enforce-lockfile`

Require lockfile unchanged.

Analyze:

`flutter analyze --no-pub`

Initial + max one correction rerun.

Tests:

`flutter test --no-pub test/android_runtime_bootstrap_test.dart test/synthetic_readiness_match_integration_test.dart test/widget_test.dart`

Initial + max one correction rerun.

Use the proven generated-host flags in ignored `.android/gradle.properties`:

- `kotlin.incremental=false`
- `kotlin.compiler.execution.strategy=in-process`
- `org.gradle.daemon=false`
- `target=lib/main_demo.dart`

Direct Android build:

`.\gradlew.bat :app:assembleDebug --no-daemon --stacktrace --info --console=plain --max-workers=2`

Initial + max one retry for transient official-repository/generated-host issue.

Install APK and cold-launch generated host on the running emulator. Clearing/uninstalling the prior generated-host package is allowed for deterministic synthetic state/storage capacity; do not read app-private data.

## 11. Required Android interaction proof

After final install:

1. Home starts normally in real AppShell;
2. Me -> Readiness shows explicit synthetic-development readiness wording;
3. Progress -> Match now opens the real Match page;
4. Match visibly shows the local synthetic proposal (e.g. “候选提案已呈现” plus synthetic headline/name);
5. no authoritative mutation action is presented as available;
6. Connection still shows `NOT YET ESTABLISHED`;
7. Messages still shows `NOT YET ESTABLISHED` and no private content;
8. return to Home without crash.

Observe PID logs:

- production EliteSync API requests: 0;
- RTC watcher/polling: 0;
- fatal/crash: 0.

If any production API request occurs, treat as blocker.

## 12. Publication

Publish one immutable candidate only after final analyze/tests/build/install/runtime interactions pass.

Candidate sole parent = task-publication authority.

Normal tracked scope = 9 paths from Section 4. Maximum = 11 with bounded repair.

Generated host/caches/APK/screenshots/logs remain untracked.

Result document should compactly record:

- authority/candidate/tree/blobs;
- readiness demo flag and visible label;
- Match synthetic projection summary;
- unit/analyze/build receipts;
- exact Android interactions;
- production API/RTC observations;
- bounded repair if any;
- remaining blockers.

Success classification:

`APP-INT-02 COMPLETE — SYNTHETIC READINESS OPENS REAL MATCH FLOW — LOCAL READ-ONLY MATCH PROJECTION RENDERS IN CANONICAL UI — NO MATCH MUTATION / CONNECTION / CONVERSATION AUTHORITY — ANDROID INTERACTION VERIFIED — NO PRODUCTION API/RTC — READY FOR PRODUCT CONNECTION CLIENT STATE INTEGRATION`

Candidate author cannot self-accept or move main.

Then STOP.
