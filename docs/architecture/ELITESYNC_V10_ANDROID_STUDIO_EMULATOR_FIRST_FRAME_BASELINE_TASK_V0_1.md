# EliteSync v10｜Android Studio Emulator First-Frame Baseline Task｜v0.1

Status: `PUBLISHED TASK SHEET — EMULATOR-ONLY FIRST-FRAME BASELINE — ONE PUBLIC/NON-PRIVATE INTERACTION MAXIMUM — NO LOGIN — NO SOURCE MODIFICATION — SANDBOX DEP13 REMAINS UNRESOLVED`

Date: 2026-09-12 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Publication authority

Publication-base `main`:

`02011fe916bc4343802e29f5b90b469755eb9f89`

FIRST handoff:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`

required blob:

`3aa2ead4cf1084b202b67856075c26ab80b0c9a2`

Accepted emulator-route activation acceptance:

`docs/architecture/ELITESYNC_V10_ANDROID_STUDIO_EMULATOR_ROUTE_ACTIVATION_ACCEPTANCE_V0_1.md`

Accepted emulator-route result identity:

- candidate commit: `311d539763fa229da747b50f93c1dadbf9a40787`
- result blob: `819444070eac53f5dc48eccea9800d592d0bc4cb`
- accepted APK SHA-256: `75CF727465502817DC1AC60BB4B27090A21E725A9B730B40566D55AA8DA12789`
- package: `com.elitesync`
- launcher: `com.elitesync/.MainActivity`
- accepted AVD: `elitesync_api36`
- accepted prior device serial: `emulator-5554`

The executor may publish one bounded candidate and must not self-accept it.

## 2. Sole objective

Establish a deterministic emulator-only first-frame baseline for the current EliteSync Android/Flutter application and validate exactly one public/non-private interaction visible from the unauthenticated initial state.

This task is UI/runtime baseline evidence only. It is not broad QA, feature verification, login testing, participant testing, product redesign, or Sandbox DEP13 work.

## 3. Startup authority gate

Activation prompt MUST provide:

- `REQUIRED_MAIN` = the commit publishing this task;
- `REQUIRED_TASK_BLOB` = this task's exact blob.

Startup sequence:

1. fresh-fetch remote `main`;
2. require `main == REQUIRED_MAIN`, else `STOP — MAIN_AUTHORITY_CHANGED`;
3. read FIRST and require blob `3aa2ead4cf1084b202b67856075c26ab80b0c9a2`;
4. read this task and require `REQUIRED_TASK_BLOB`;
5. read the accepted emulator-route activation acceptance named in §1;
6. do not treat conversation/project memory as execution authority.

No default `git status`; do not inspect protected staged/index state.

## 4. Emulator/device gate

Use only the already authorized AVD `elitesync_api36`.

Preferred gate:

- if exactly one running emulator exists and it reports `ro.boot.qemu.avd_name=elitesync_api36`, use it;
- otherwise, if no emulator is running, start exactly `elitesync_api36` once using the already-installed emulator binary and wait for boot readiness;
- if a different or multiple active emulator state makes the exact target ambiguous, stop with `FIRST_FRAME_EMULATOR_IDENTITY_NOT_UNIQUE`.

Require:

- API 36;
- Android 16;
- ABI `x86_64`;
- `sys.boot_completed=1`.

Do not create, delete, edit, wipe, reset, upgrade, or snapshot-rewrite an AVD.

## 5. Installed app identity gate

Before any UI interaction:

1. require package `com.elitesync` installed on the exact target emulator;
2. require launcher resolution remains `com.elitesync/.MainActivity` or the exact equivalent resolved by the current package manager;
3. record the installed package path and package version metadata available locally;
4. do not pull or inspect private app data.

If the package is absent or launcher identity cannot be established, stop with:

`FIRST_FRAME_INSTALLED_APP_IDENTITY_NOT_ESTABLISHED`

Do not rebuild, reinstall, download dependencies, or substitute another APK in this task. The accepted APK SHA-256 is provenance from route activation, not authority to reconstruct the artifact in this task.

## 6. Clean initial-state capture

Establish the initial unauthenticated visible state without login or data entry.

Authorized actions:

- force-stop only package `com.elitesync` if necessary to obtain a clean app restart;
- clear only logcat buffers if needed for bounded PID-scoped diagnostics;
- launch exactly `com.elitesync/.MainActivity` once;
- wait a short deterministic stabilization window;
- verify target PID is alive and `MainActivity` is top-resumed/visible;
- capture exactly one initial screenshot;
- capture exactly one bounded UI hierarchy / accessibility dump or equivalent structural tree for the visible screen;
- compute SHA-256 for the screenshot and structural evidence file.

Do NOT clear app data, permissions, storage, or accounts.

Do NOT log in or enter any private/user/participant data.

## 7. Public/non-private interaction selection

From the captured initial UI only, select exactly one interaction that satisfies all of the following:

- target is visibly present in the initial state;
- target is public/non-private and unauthenticated;
- interaction does not submit credentials, personal data, participant data, private Conversation data, analytics/telemetry consent, or production configuration;
- interaction is reversible or observational in nature;
- interaction does not initiate broad navigation or a multi-step workflow.

Preference order:

1. a visible informational/help/about/public-details affordance;
2. a visible local navigation control that reveals only public/static app UI;
3. if neither exists, a visible non-submitting toggle/tab/filter whose state is purely local and contains no private information.

If no interaction satisfies the contract, do not invent one. Classify:

`FIRST_FRAME_BASELINE ESTABLISHED — NO AUTHORIZED PUBLIC INTERACTION AVAILABLE`

and stop after baseline capture.

Record the exact selected control label/semantic node/coordinates and selection rationale before executing it.

## 8. Single interaction execution

Execute exactly one tap/click on the selected target.

After the interaction:

- wait a short deterministic stabilization window;
- capture exactly one post-interaction screenshot;
- capture exactly one post-interaction bounded UI hierarchy / structural tree;
- record top-resumed activity/window state;
- verify the target PID remains alive;
- collect PID-scoped fatal diagnostics for `FATAL EXCEPTION`, fatal signal, or process death patterns only;
- compute SHA-256 for evidence files.

No second interaction is authorized.

Do not use back/home/navigation to explore further after evidence capture unless necessary only to leave the emulator in a safe idle state; if such cleanup occurs, it is not evidence and must be documented.

## 9. Source/build/acquisition prohibition

Do NOT:

- modify product source code;
- modify test code or Gradle/Flutter configuration;
- rebuild APK/AAR;
- run `flutter pub get`;
- run Gradle build tasks;
- download SDK/system images/dependencies;
- install another APK;
- use network acquisition as a workaround;
- read README;
- inspect FD02;
- perform broad repository/filesystem archaeology.

This task consumes the already activated local emulator route only.

## 10. Privacy / Safety / product boundaries

Do NOT:

- log into any account;
- enter email, phone, credentials, names, identifiers, participant data, or private Conversation content;
- inspect app private storage;
- enable or configure telemetry/analytics;
- run participant workflows;
- perform Safety Operations;
- perform new legal research;
- test Backend/Database/PUI production behavior;
- claim feature correctness, release readiness, or production readiness.

## 11. Required result artifact

Publish exactly one result artifact on a dedicated review branch:

`docs/architecture/ELITESYNC_V10_ANDROID_STUDIO_EMULATOR_FIRST_FRAME_BASELINE_RESULT_V0_1.md`

Result must record:

- main/FIRST/task identities;
- emulator AVD/serial/API/ABI identity;
- installed package/launcher identity;
- exact launch command and exit/result;
- PID/top-resumed state before interaction;
- initial screenshot path/SHA-256;
- initial structural evidence path/SHA-256;
- a concise factual description of the visible unauthenticated first frame derived only from captured evidence;
- exact selected interaction or explicit `NO AUTHORIZED PUBLIC INTERACTION AVAILABLE`;
- exact single interaction command/target if performed;
- post-interaction screenshot/path/SHA-256 and structural evidence if performed;
- post-interaction activity/PID state;
- PID-scoped fatal diagnostic result;
- explicit statement that no login/private data/source modification/dependency acquisition/broad QA occurred;
- exact next recommended bounded emulator development/test task.

Final classification exactly one of:

`EMULATOR FIRST-FRAME BASELINE ESTABLISHED — ONE PUBLIC/NON-PRIVATE INTERACTION VERIFIED — READY FOR INDEPENDENT ACCEPTANCE`

or

`EMULATOR FIRST-FRAME BASELINE ESTABLISHED — NO AUTHORIZED PUBLIC INTERACTION AVAILABLE — READY FOR INDEPENDENT ACCEPTANCE`

or

`EMULATOR FIRST-FRAME BASELINE NOT ESTABLISHED — AWAITING INDEPENDENT ACCEPTANCE`

## 12. Sandbox boundary

Remain unchanged:

`FAILED_START_RESULT_NOT_CAPTURED`

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

Accepted B R4 share-success fact remains valid.

Sandbox DEP13 remains unresolved and blocked. Emulator first-frame evidence is a separate local development/test evidence class.

## 13. Stop rule

Stop immediately after publishing the single candidate result.

Do not self-accept, merge, perform a second interaction, begin broad implementation, publish the next task, create a new Windows Sandbox, or run DEP13.

## 14. Durable boundaries

Preserve D-02 durable UNKNOWN, U-14 exclusion, U-12 exact-scope rules, `TP-SOURCE-CLASS-01`, `TP-TARGET-01`, Backend/Database/PUI boundaries, README exhausted, FD02 excluded, protected-index boundary, accepted legal/Safety/no-processing boundaries, and no LC-03/LC-04/Phase36 authority unless separately reauthorized.

B12 remains NOT AUTHORIZED. M2 remains separate and NOT automatically authorized.

## 15. End state

`EMULATOR ROUTE ACTIVE -> FIRST-FRAME BASELINE`

`FIRST-FRAME BASELINE != BROAD QA`

`ONE PUBLIC INTERACTION != FEATURE CORRECTNESS`

`EMULATOR EVIDENCE != SANDBOX DEP13 EVIDENCE`
