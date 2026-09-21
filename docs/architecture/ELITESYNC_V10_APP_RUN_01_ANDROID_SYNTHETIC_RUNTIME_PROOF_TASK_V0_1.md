# EliteSync v10｜APP-RUN-01 Android Synthetic Runtime Proof Task｜v0.1

Status: `OWNER-AUTHORIZED — ANDROID EMULATOR DIRECT EXECUTION — MINIMAL SYNTHETIC DEMO BOOTSTRAP + ANALYZE/TEST/RUN — ONE CANDIDATE / ONE INDEPENDENT REVIEW`

Date: 2026-09-21 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

Frozen execution authority before this task commit:

`3a26769c9643a8289835e1b656f96a3cf711c1c6`

Owner has explicitly authorized Codex to operate the already-open Android Studio and Android emulator for this task.

This task begins the app-delivery lane. Its goal is not another architecture review; its goal is to prove that the current Flutter module can be materialized and visibly run on one Android emulator using only clearly synthetic/dev data and no real backend/user authority.

## 1. Exit capability

A successful delivery must prove all of the following for one exact candidate:

1. the checked-in Flutter lockfile can be materialized without changing dependency versions;
2. the module analyzes sufficiently to build the demo entry;
3. targeted Flutter tests for the demo/bootstrap pass;
4. a generated Flutter-module Android host is created only in ignored/generated locations;
5. the app launches on one already-running Android emulator;
6. the first visible frame is a deliberate local synthetic/dev surface, not a production login/backend-dependent flow;
7. Codex directly observes and interacts with the emulator enough to prove the launched surface is responsive;
8. no real account, credential, private data, production API, LiveKit/RTC polling, or real backend request is intentionally used.

This is the first platform runtime proof, not full MVP integration.

## 2. Fresh-base gate

Before work:

1. fresh-fetch `origin/main`;
2. require it to equal the exact task-publication commit supplied in the execution prompt;
3. read that authority's `AGENTS.md` FIRST;
4. read this task;
5. create a fresh isolated implementation branch/worktree from exactly that authority;
6. verify create-only paths in Section 6 are absent;
7. verify all fixed source blobs in Section 4;
8. use only the already-running Android emulator returned by Flutter/ADB; do not boot or use a physical device unless Owner separately requests it.

If authority/source blobs differ, STOP.

Recommended branch:

`impl/app-run-01-android-synthetic-runtime-proof-v0-1`

Recommended worktree:

`D:\EliteSync-v10-app-run-01-android-runtime-v0-1`

If that path already exists or is unsafe, choose a new sibling path and report it; do not clean/reset an existing worktree.

## 3. Runtime/privacy boundary

The runtime proof must be local synthetic/dev only.

Do not:

- log into a real EliteSync account;
- type or read real credentials/tokens;
- use real/private participant data;
- call the production EliteSync backend intentionally;
- enable LiveKit/RTC;
- inspect private Conversation data;
- perform telemetry/analytics/measurement;
- deploy or publish to any store;
- modify production auth/session/token policy.

Any demo entry must use a loopback/unreachable local API base such as `http://127.0.0.1:9/` so accidental network-backed provider use fails locally instead of reaching production.

If runtime logs show an outbound request toward the existing production API base, stop interaction, record it as a blocker, and correct only within this task's authorized bootstrap/runtime scope before retrying.

## 4. Exact fixed read set

Read only these repository files unless a compiler/analyzer/test failure identifies an additional file under the bounded repair rule in Section 7:

- `AGENTS.md` — blob `c9a8e192f7647a1613a195655fe9c22c56502ddb`
- this task
- `apps/flutter_elitesync_module/pubspec.yaml` — `1b807ccdcced1e3166fd6e5378865ecb5bba4708`
- `apps/flutter_elitesync_module/pubspec.lock` — `b56c4b2c45bab65106c12e4d75d6c5b34209aeb4`
- `apps/flutter_elitesync_module/.metadata` — `cc507644250f1d2715da7323c3116ebf33ff31d8`
- `apps/flutter_elitesync_module/.gitignore` — `5f448afb104bb897175df7373c8f6d835dd115bc`
- `apps/flutter_elitesync_module/analysis_options.yaml` — `a5744c1cfbe77ae2daba29c74156c617b5f09b77`
- `apps/flutter_elitesync_module/lib/main.dart` — `607b51186540bd0eb1998c1997472a05447d9a3d`
- `apps/flutter_elitesync_module/lib/main_prod.dart` — `86c7bde6387379921c3450df8523f5b28f0ea95c`
- `apps/flutter_elitesync_module/lib/main_dev.dart` — `746c80cfdd881b495dcd42045e3cd7021be72920`
- `apps/flutter_elitesync_module/lib/app/config/app_env.dart` — `d2784ec5cd3fc43e52dd9c4e657197b1955b7062`
- `apps/flutter_elitesync_module/lib/app/config/app_flavor.dart` — `5ab4f0ef191b6d2467718f45f2f3d11723f05f86`
- `apps/flutter_elitesync_module/lib/app/bootstrap/app_bootstrap.dart` — `bc74a0dd5bac9515d9c3a565602b4dc0b915d654`
- `apps/flutter_elitesync_module/lib/app/app.dart` — `2a07c20f2c484e3609c64a5e7f64baa3cbe53014`
- `apps/flutter_elitesync_module/lib/app/router/app_route_names.dart` — `d831a56e7f8a7bb162b25f390128b3c004042e68`
- `apps/flutter_elitesync_module/lib/app/router/app_router.dart` — `25c6ce546a90352aecb48f2f4ed219ecfd1dc8a0`
- `apps/flutter_elitesync_module/lib/app/router/rtc_invite_coordinator.dart` — `4a8741c21a774e0c0815f1ba7aca36e0b39b5f5e`
- `apps/flutter_elitesync_module/lib/shared/providers/session_provider.dart` — `786444bf0de85f799eb2612fcf65029314a24004`
- `apps/flutter_elitesync_module/lib/shared/providers/navigation_guard_provider.dart` — `49fb97d3dbb9f37e548bec6a842151ead1b36111`
- `apps/flutter_elitesync_module/lib/shared/providers/app_providers.dart` — `c1228beb511341ccff4219ade67ec0e70fbc0c04`
- `apps/flutter_elitesync_module/test/widget_test.dart` — `5c6cb37c0280c41bdd0edabb39d2ecb2f56b465c`

No old repository access.

## 5. Required implementation

### 5.1 Add a dedicated synthetic Android/demo entry

Create:

`apps/flutter_elitesync_module/lib/main_demo.dart`

It must:

- use `AppFlavor.dev`;
- visibly remain a debug/dev build;
- use an app name clearly identifying the build as synthetic/dev;
- set `apiBaseUrl` to a loopback/unreachable local address, not the production URL;
- set `useLiveKitRtc = false`;
- set `useMockData = true`;
- set all existing per-domain `useMock*` switches true unless a specific flag is proven unsafe;
- disable admin/match-round internal mutation features unless needed for this visual proof;
- set initial route exactly to `AppRouteNames.localOnlyVisualFixture`;
- contain no secret, token or real user identifier;
- not alter `main.dart` or `main_prod.dart`.

The entry exists only for development/runtime proof and must not become the production default entry.

### 5.2 Honor the existing RTC feature gate

The current bootstrap and app widget unconditionally watch `rtcInviteBootstrapProvider`. Modify only:

- `apps/flutter_elitesync_module/lib/app/bootstrap/app_bootstrap.dart`
- `apps/flutter_elitesync_module/lib/app/app.dart`

so that RTC invite bootstrap is watched only when `AppEnv.useLiveKitRtc === true`.

Production behavior remains unchanged because existing production entry uses `useLiveKitRtc=true`.

The demo entry must therefore not start the RTC invite polling/provider chain.

Do not change RTC domain semantics or network/provider implementation itself.

### 5.3 Add one focused test

Create:

`apps/flutter_elitesync_module/test/android_runtime_bootstrap_test.dart`

At minimum verify the demo AppEnv or exposed demo-config helper has:

- dev flavor;
- synthetic/dev app identity;
- loopback API base;
- all intended mock flags;
- LiveKit/RTC disabled;
- initial route `/debug/8-1-visual-fixture`.

If a small pure helper is useful for testability, expose it from `main_demo.dart`.

Do not introduce test-only production authority.

## 6. Normal tracked write set

Normal candidate scope is exactly:

1. create `apps/flutter_elitesync_module/lib/main_demo.dart`
2. modify `apps/flutter_elitesync_module/lib/app/bootstrap/app_bootstrap.dart`
3. modify `apps/flutter_elitesync_module/lib/app/app.dart`
4. create `apps/flutter_elitesync_module/test/android_runtime_bootstrap_test.dart`
5. create `docs/architecture/ELITESYNC_V10_APP_RUN_01_ANDROID_SYNTHETIC_RUNTIME_PROOF_RESULT_V0_1.md`

Generated/ignored local paths such as `.dart_tool/`, `.android/`, `build/`, Gradle caches and emulator state must not be committed.

## 7. Bounded build-compatibility repair budget

To avoid stopping for every ordinary compiler/tooling incompatibility, Codex may additionally modify **at most two** compiler/analyzer/runtime-error-identified tracked files under:

- `apps/flutter_elitesync_module/lib/`
- `apps/flutter_elitesync_module/test/`

only when all of the following hold:

- the exact failing file is named by analyzer/compiler/runtime evidence from this task;
- the fix is required to analyze/build/launch the same synthetic demo;
- the fix does not alter Product Connection/Match/Conversation/Relationship authority, data purpose, consent policy, route authority, auth/session/token semantics, backend API contract, or production behavior;
- no dependency version change is required.

Record each extra path, error evidence, and fix in the result.

Maximum final tracked candidate scope: 7 paths including result.

If a fix would exceed these limits or change product/domain semantics, STOP with the exact blocker instead of creating a new design task.

## 8. Tooling and dependency acquisition

From `apps/flutter_elitesync_module`, Codex may use the local installed Flutter/Android toolchain and Android Studio/emulator.

Allowed observations:

- `flutter --version`
- `dart --version`
- `flutter doctor -v`
- `flutter devices`
- `adb devices` if needed to identify the already-running emulator only

Dependency acquisition:

Run:

`flutter pub get --enforce-lockfile`

Network is authorized **only** for dependency/artifact acquisition required by the checked-in Flutter/Dart lockfile and the generated Android debug host using standard Flutter/Dart/Android repositories. No dependency upgrade is authorized.

If `pubspec.lock` would change, STOP and report; do not accept a new resolution.

During Android build, standard Gradle/Flutter artifact retrieval required by the generated module host is allowed. Do not edit repository dependency versions, Android SDK versions, Gradle versions or global toolchain configuration.

If the required Android SDK/platform/JDK/Flutter SDK itself is missing or incompatible and would require an IDE/SDK upgrade or license acceptance, STOP and report the exact missing component rather than upgrading the machine.

## 9. Validation sequence and budgets

Perform all planned source edits before the first hard validation where possible.

### A. Analyze

Run once initially:

`flutter analyze --no-pub`

If it reports only warnings/deprecations unrelated to build, record them.

If it reports errors caused by authorized files, fix within Section 6/7 and rerun at most once.

Maximum analyze executions: 2.

### B. Targeted tests

Run:

`flutter test --no-pub test/android_runtime_bootstrap_test.dart test/widget_test.dart`

Initial + at most one correction rerun.

Maximum targeted-test executions: 2.

### C. Android runtime

Choose the already-running Android emulator reported by `flutter devices`.

Run the demo entry:

`flutter run --debug --no-pub -t lib/main_demo.dart -d <EXACT_EMULATOR_ID>`

The generated `.android/` host is permitted and must remain untracked/ignored.

Runtime attempts: initial + at most one correction retry.

Maximum `flutter run` launches: 2.

A run is successful only after Codex observes:

- Android app process launched;
- Flutter renders a visible first frame;
- the local visual fixture appears instead of production login/backend flow;
- no intentional production API request or RTC polling starts;
- at least one emulator interaction (tap/scroll/back as appropriate) produces a visible response without crash.

Codex may operate Android Studio and the emulator GUI directly. If GUI automation is insufficient, it may use ADB only against the selected emulator for input/screenshot/log observation. Do not read app-private data through ADB.

After proof, terminate `flutter run` normally.

**Once the final candidate's runtime proof passes, do not change tracked code/test and rerun without a new failure.**

## 10. Result and publication

Create exactly:

`docs/architecture/ELITESYNC_V10_APP_RUN_01_ANDROID_SYNTHETIC_RUNTIME_PROOF_RESULT_V0_1.md`

Record compactly:

- authority/task/branch/candidate/sole parent/tree;
- exact changed paths/blobs;
- Flutter/Dart version;
- selected emulator name/ID and Android API if reported;
- `flutter pub get --enforce-lockfile` result and confirmation lockfile unchanged;
- analyze command/attempt/result;
- targeted test command/attempt/tests result;
- runtime command/attempt;
- first visible route/surface;
- actual direct emulator interaction performed;
- whether any production API/RTC request was observed;
- generated ignored paths used;
- any bounded compatibility repair;
- remaining platform/runtime blockers;
- no-real-data/no-production confirmation.

Successful classification:

`APP-RUN-01 COMPLETE — FLUTTER MODULE MATERIALIZED FROM LOCKED DEPENDENCIES — ANDROID EMULATOR LAUNCH VERIFIED — LOCAL SYNTHETIC/DEV SURFACE INTERACTIVE — PRODUCTION API + RTC DISABLED FOR DEMO ENTRY — TARGETED TESTS PASS — READY FOR CLIENT INTEGRATION WORK`

Publish one immutable candidate only after the final code/test/runtime state has been validated.

Candidate author cannot self-accept or move main.

Then STOP.
