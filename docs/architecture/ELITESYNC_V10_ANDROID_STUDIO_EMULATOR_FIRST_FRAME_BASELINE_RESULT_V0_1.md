# EliteSync v10｜Android Studio Emulator First-Frame Baseline Result｜v0.1

Status: `PUBLISHED RESULT CANDIDATE — AWAITING INDEPENDENT ACCEPTANCE`

Date: 2026-09-12 (Asia/Shanghai).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Authority and scope

- Fresh-fetched required `main`: `73b5c186d483596ca472d1b0fa554713e98f43ba` — exact match.
- FIRST handoff: `docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`.
- FIRST blob: `3aa2ead4cf1084b202b67856075c26ab80b0c9a2` — exact match and read first.
- Task: `docs/architecture/ELITESYNC_V10_ANDROID_STUDIO_EMULATOR_FIRST_FRAME_BASELINE_TASK_V0_1.md`.
- Task blob: `a86e392fadc2dee176f0c92e3057842b4f6e252b` — exact match.
- Accepted emulator-route activation acceptance blob: `6736aea9ef6d858c4a12b7add43299144f67028c` — read before runtime execution.
- Accepted route-activation candidate: `311d539763fa229da747b50f93c1dadbf9a40787`.
- Accepted APK provenance SHA-256: `75CF727465502817DC1AC60BB4B27090A21E725A9B730B40566D55AA8DA12789`.
- Dedicated review worktree: `D:\EliteSync-v10-emulator-first-frame-baseline-v0-1`.
- Dedicated review branch: `review/android-studio-emulator-first-frame-baseline-v0-1`.

This execution consumed only the already-active emulator route and installed application. It did not rebuild or reinstall the application and did not start another emulator.

## 2. Emulator and installed-app identity gates

Exactly one running emulator was present:

- AVD: `elitesync_api36`;
- serial: `emulator-5554`;
- state: `device`;
- product/model/device: `sdk_gphone64_x86_64` / `sdk_gphone64_x86_64` / `emu64xa`;
- `sys.boot_completed=1`;
- API: `36`;
- Android: `16`;
- ABI: `x86_64`.

Installed application identity:

- package: `com.elitesync`;
- package path: `package:/data/app/~~6wOo9Wso5pUb0nnb3FoYfQ==/com.elitesync-lvqU4POX_vQq0aZk0zhsHQ==/base.apk`;
- version code: `80400`;
- version name: `0.08.04`;
- package-manager launcher resolution: `com.elitesync/.MainActivity`;
- first install time reported locally: `2026-07-17 04:33:06`;
- last update time reported locally: `2026-09-11 23:18:04`.

The launcher resolver emitted additional resolution metadata on the same line before the exact component. The component suffix was parsed and matched `com.elitesync/.MainActivity`; no launcher substitution was made.

## 3. Clean initial launch

Only package `com.elitesync` was force-stopped. The logcat buffers were cleared for bounded target-process diagnostics. App data, permissions, storage, accounts, and emulator state were not cleared or reset.

Exact launch command:

```powershell
& $adb -s emulator-5554 shell am start -W -n 'com.elitesync/.MainActivity'
```

Launch result:

- command exit: `0`;
- status: `ok`;
- launch state: `COLD`;
- activity: `com.elitesync/.MainActivity`;
- total time: `2455ms`;
- wait time: `2459ms`.

After the deterministic five-second stabilization window:

- PID: `8318`, alive;
- top-resumed activity: `com.elitesync/.MainActivity`;
- task/activity record: `t60`.

## 4. Initial first-frame evidence

Task-owned host evidence root:

`C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-Emulator-FirstFrame-a8dd19155ce3459fa470257e92eb3c70`

Exactly one initial screenshot was captured using:

```powershell
& $adb -s emulator-5554 exec-out screencap -p
```

- path: `C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-Emulator-FirstFrame-a8dd19155ce3459fa470257e92eb3c70\initial-first-frame.png`;
- bytes: `76765`;
- SHA-256: `6A7314CF559197F4D1CD680CE7ACB18B196FEB17F72BFCF5087317FB405324D9`.

Exactly one initial hierarchy was captured using:

```powershell
& $adb -s emulator-5554 shell uiautomator dump /sdcard/Download/elitesync-v10-initial-first-frame.xml
& $adb -s emulator-5554 pull /sdcard/Download/elitesync-v10-initial-first-frame.xml $initialXml
```

- host path: `C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-Emulator-FirstFrame-a8dd19155ce3459fa470257e92eb3c70\initial-first-frame.xml`;
- bytes: `6704`;
- SHA-256: `C3B0C97B9DF56DE4D1331D7B0BF9528895ECD22B05CEA704D1D4EBF67643F3CD`;
- bounded node count: `19`.

Factual visible-state description derived only from the screenshot and hierarchy:

- the unauthenticated light-background screen displayed the title `首页` and subtitle `从这里查看慢约进展。`;
- a dark button labeled `查看慢约进展` was visible;
- the bottom navigation displayed `首页`, `发现`, `匹配`, `消息`, and `我的`;
- `首页` was visibly selected;
- no credential fields, entered user data, Conversation content, or participant content was visible.

## 5. Single public/non-private interaction selection

The initial hierarchy exposed these clickable targets: the `查看慢约进展` button and the five bottom tabs.

`发现`, `匹配`, `消息`, `我的`, and `查看慢约进展` were not selected because initial-frame evidence alone could not establish that their destinations would avoid user, participant, private, or backend-derived data.

The selected target was the currently selected `首页` bottom-navigation tab:

- semantic label: `首页`;
- hierarchy class: `android.view.View`;
- bounds: `[60,2198][252,2295]`;
- tap coordinate: `(156,2246)`.

Selection rationale: this control was visibly present, unauthenticated, non-submitting, and local; tapping the already-selected Home tab was observational and reversible and remained on the same public first frame. This was the only target whose safe result was established directly by the captured initial state without inventing destination semantics.

## 6. Exactly one interaction and post-interaction evidence

Exactly one interaction was executed:

```powershell
& $adb -s emulator-5554 shell input tap 156 2246
```

Result: exit `0`. No second tap/click or navigation interaction was performed.

After a five-second stabilization window:

- PID remained `8318`;
- `com.elitesync/.MainActivity` remained top-resumed in task `t60`;
- PID-scoped fatal diagnostic matches: `0` for `FATAL EXCEPTION`, target-process death, or fatal signal patterns.

Exactly one post-interaction screenshot was captured:

- path: `C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-Emulator-FirstFrame-a8dd19155ce3459fa470257e92eb3c70\post-home-tab.png`;
- bytes: `77286`;
- SHA-256: `95A1D55F49808E5E0556E4AF6F25B95DAB50A3B7C78619AD60E4E9EC7385FE5D`.

Exactly one post-interaction hierarchy was captured:

- device path: `/sdcard/Download/elitesync-v10-post-home-tab.xml`;
- host path: `C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-Emulator-FirstFrame-a8dd19155ce3459fa470257e92eb3c70\post-home-tab.xml`;
- bytes: `6704`;
- SHA-256: `C3B0C97B9DF56DE4D1331D7B0BF9528895ECD22B05CEA704D1D4EBF67643F3CD`.

The post-interaction hierarchy was byte-identical to the initial hierarchy. Visual inspection found the same app UI and selected Home tab; the screenshot hash changed with the system status-bar time advancing from 11:47 to 11:48. No app-level navigation or content change was observed.

## 7. Boundaries and non-claims

No login, credential entry, private/user/participant data entry, private app-storage inspection, telemetry/analytics configuration, source/test/build-config modification, APK/AAR rebuild, pub/Gradle command, dependency/SDK acquisition, APK installation, broad navigation, or broad QA occurred.

This result establishes only a deterministic unauthenticated first frame and one bounded public/non-private local-tab interaction. It does not establish feature correctness, backend/database behavior, login correctness, participant-flow correctness, release readiness, production readiness, or any Sandbox-specific fact.

## 8. Exact next recommended bounded emulator task

After fresh independent acceptance, the next recommended task is a screenshot-and-hierarchy-only Home first-frame visual/accessibility review against the exact evidence hashes above: evaluate visible text legibility, semantic-label coverage, touch-target bounds, selected-tab state, and layout clipping on this one API 36 / x86_64 viewport, without another device interaction, source modification, login, private data, backend calls, dependency acquisition, or broad QA.

This result does not publish or authorize that successor task.

## 9. Preserved Sandbox boundary

Remain unchanged:

`FAILED_START_RESULT_NOT_CAPTURED`

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

The accepted B R4 share-success fact remains valid. Sandbox DEP13 remains unresolved and blocked. Emulator first-frame evidence is a separate local development/test evidence class and does not satisfy or replace Sandbox DEP13.

## 10. Final classification

`EMULATOR FIRST-FRAME BASELINE ESTABLISHED — ONE PUBLIC/NON-PRIVATE INTERACTION VERIFIED — READY FOR INDEPENDENT ACCEPTANCE`

Stop boundary: publish this single result candidate only; do not self-accept, merge, perform a second interaction, begin broad implementation, publish a successor task, create a Windows Sandbox, or run DEP13.
