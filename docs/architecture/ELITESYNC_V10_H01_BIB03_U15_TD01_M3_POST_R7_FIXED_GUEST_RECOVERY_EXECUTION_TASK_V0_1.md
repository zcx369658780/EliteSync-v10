# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 Fixed-Guest Recovery Execution Task v0.1

Status: `TASK AUTHORIZED — ONE BOUNDED FIXED-GUEST RECOVERY EXECUTION — ONE NEW SANDBOX MAXIMUM — DEP13 NOT AUTHORIZED IN THIS TASK — NO MAVEN/SOURCE RESEARCH — NO ACQUISITION — NO GRADLE/M3 — NO M2`

Date: 2026-09-11

Repository: `zcx369658780/EliteSync-v10`

## 1. Purpose

Execute exactly once the accepted fixed-guest recovery contract and establish one new Windows Sandbox evidence environment suitable for later DEP13 local-state review.

This task may create exactly one new task-owned Sandbox, establish exactly one writable task-owned transport/evidence share plus seven read-only source shares, materialize the accepted M3A roots, verify the accepted bounded identities, and publish recovery evidence.

This task must stop after recovery success or first terminal blocker. It must not run DEP13 in the same execution.

`RECOVERY EXECUTION != DEP13 AUTHORITY`

`RECOVERY EXECUTION != B12 ACQUISITION AUTHORITY`

## 2. Mandatory repository startup gate

Fresh-fetch GitHub `main` first.

Require exact current durable authority:

`77e3a90c0d5ec8a5dfef281a253563ba5c9f6f2f`

Require exact tree:

`3192b43500c65ed49c1410d55535e5275944e666`

Read FIRST:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_FIXED_GUEST_RECOVERY_LOCATOR_METHOD_COMPLETION_ACCEPTANCE_V0_1.md`

Require FIRST blob:

`80acc7aa7d588e698bacc92a859effda46bc43ef`

Also read the accepted contract result:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_FIXED_GUEST_RECOVERY_LOCATOR_METHOD_COMPLETION_RESULT_V0_1.md`

Require result blob:

`06671fe085baf2fc0940a498bedecffd3780cb63`

Preserve transition FIRST blob:

`18485c95262051e43892436fb52413132c5ee626`

If any identity gate fails, stop before runtime/Sandbox actions.

## 3. Exact host source allowlist

Only these host sources are authorized:

1. Flutter/toolchain: `D:/flutter`
2. Android SDK: `C:/Users/zcxve/AppData/Local/Android/Sdk`
3. JDK: `C:/Program Files/Eclipse Adoptium/jdk-17.0.18.8-hotspot`
4. Git: `C:/Program Files/Git`
5. Pub cache: `C:/Users/zcxve/AppData/Local/Pub/Cache`
6. Gradle root: `D:/GradleHome`
7. Fixed module: `D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/input-r6-r1/apps/flutter_elitesync_module`

No source discovery, alternative-path search, drive scan, wildcard search, or substitution is authorized.

## 4. Required bounded host identity gates

Before creating a Sandbox, verify only the following bounded source facts:

### Flutter

- Dart SHA-256 = `44328B98B6BF981D8307F72EF38ACBB37B8067394916953CAA48B8B444525152`
- Dart SDK = `3.11.5 stable`
- Flutter-tools pubspec Length = `2946`
- Flutter-tools pubspec SHA-256 = `6E31FF00AC4441294B60F20A71DCE2777CC80EB33663E6621DAE38C2391DB0EA`
- Flutter-tools snapshot Length = `43747920`
- Flutter-tools snapshot SHA-256 = `E494C265BA9C38A6A5679842703D3041DF0D2D86C83BFC55DF56C3BD0DF8E808`

### Android SDK

- `adb.exe` SHA-256 = `7035CF5EC7F99F7B5662A9F5395F9DCCFC3B6FE42583D0B9550124A0C3496606`
- `sdkmanager.bat` SHA-256 = `11D021F90186F7FCC0B2D97623348C9C857109636B29D70FA1B804A4D603F5E7`

### JDK

- `java.exe` SHA-256 = `5369CF92FC590944793E47CC9C9FEF7955CE1A68DE22BA22023CDD3513E87C2B`
- version = `Temurin/OpenJDK 17.0.18+8`

### Git

- `git.exe` SHA-256 = `DA240FE9BC24895B3E04150A4990B8A6FF329ECABCD8F19684C2CC310DA5EF3F`
- version = `git version 2.53.0.windows.1`

### Pub cache

- exact root exists as a directory
- do not enumerate packages

### Gradle root

- `D:/GradleHome` exists
- `D:/GradleHome/caches` exists
- `D:/GradleHome/wrapper/dists` exists
- do not run Gradle or inspect dependency resolution state

### Fixed module

Use only the existing accepted bounded manifest/stat artifacts or an equivalent exact bounded check that does not broaden scope. Require:

- files = `527`
- directories = `301`
- bytes = `3234145`
- reparse points = `0`
- TSV Length = `69676`
- TSV SHA-256 = `4F869B12B5F466E35326966272F13BEA6EBABC69A631200E26F8F8E3D382DD2E`
- `pubspec.yaml` Length = `1984`
- `pubspec.yaml` SHA-256 = `ECBC74EF27D949712532409EADC6BE0928EA56C9CBC603EB0C80FBE0CEC7E6BC`

Do not substitute the historical 526-record protected-module manifest for this 527-file source baseline.

Any source identity mismatch is a terminal blocker before Sandbox creation.

## 5. Attempt identity and host evidence root

Generate exactly one fresh nonce:

`[Guid]::NewGuid().ToString('N')`

Set:

`attempt_id = RECOVERY-<nonce>`

Set task-owned host attempt root:

`C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-<attempt_id>`

The attempt root must not already exist.

If it exists, stop. Do not delete, clear, rename, or reuse it.

Create it only after all source identity gates pass and before the pre-start Sandbox list observation.

## 6. Exact Sandbox launcher contract

Use exactly:

`C:/Users/zcxve/AppData/Local/Microsoft/WindowsApps/wsb.exe`

Require CLI version `0.8.107.0`.

Use PowerShell native argument arrays, not a constructed shell command string.

Exact inline configuration:

`<Configuration><Networking>Disable</Networking></Configuration>`

Execution sequence:

1. `wsb list --raw`
   - exit must be `0`;
   - parse JSON;
   - require zero applicable running Sandboxes.
2. `wsb start --raw --config <inline XML>`
   - exit must be `0`;
   - returned text must parse as one GUID;
   - this GUID becomes the new task-owned Sandbox ID.
3. `wsb list --raw`
   - exit must be `0`;
   - require exactly one applicable running Sandbox;
   - require its ID equals the captured new Sandbox ID.

Any invalid JSON, invalid GUID, zero/multiple post-start environments, ID mismatch, or nonzero exit is terminal.

No retry and no second Sandbox are allowed.

## 7. Exact share map

After launcher uniqueness binding, establish the writable task-owned share first:

- host: the fresh attempt root
- guest: `C:/M3A/transport`
- mode: writable via `--allow-write`

Then establish exactly these seven read-only shares in order:

1. `D:/flutter` -> `C:/M3A/source/flutter`
2. `C:/Users/zcxve/AppData/Local/Android/Sdk` -> `C:/M3A/source/a7/android`
3. `C:/Program Files/Eclipse Adoptium/jdk-17.0.18.8-hotspot` -> `C:/M3A/source/a7/jdk`
4. `C:/Program Files/Git` -> `C:/M3A/source/a7/git`
5. `C:/Users/zcxve/AppData/Local/Pub/Cache` -> `C:/M3A/source/a7/pub`
6. `D:/GradleHome` -> `C:/M3A/source/a7/gradle`
7. `D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/input-r6-r1/apps/flutter_elitesync_module` -> `C:/M3A/source/a7/module`

Use `wsb share --id <SandboxId> --host-path <host> --sandbox-path <guest> --raw` for read-only sources.

`--allow-write` must not be used for any source share.

Every share exit must be `0`; otherwise stop and quarantine.

No extra shares are authorized.

## 8. Guest execution boundary

Guest-side recovery logic may be invoked only in the new task-owned Sandbox ID and only to:

- establish the accepted `guest.started.json` binding;
- create the exact allowed M3A destination/runtime roots;
- perform the accepted robocopy materializations;
- perform bounded identity verification;
- emit accepted receipts into the writable transport.

Use the current supported `wsb exec` mechanism for the exact new Sandbox ID, `--run-as System`, a literal working directory, and a literal PowerShell command/script path located in the task-owned writable transport.

A bootstrap/recovery script may be written only inside the fresh host attempt root and becomes visible through `C:/M3A/transport`.

Do not execute Flutter, Dart package operations, Gradle, Maven, Git network operations, build commands, M3, DEP13, or AAR probes.

## 9. guest.started binding gate

Before any materialization begins, atomically create:

`guest.started.json`

inside the task-owned attempt root via the writable transport.

Require exact binding:

- `attempt_id`
- `nonce`
- `sandbox_id`
- `binding_status = PASS`
- exact host/guest transport roots
- `written_before_materialization = true`

Any mismatch makes guest output non-attributable and is terminal.

## 10. Exact materialization order

Before the first copy, verify all seven final target roots are absent:

- `C:/M3A/tools/flutter`
- `C:/M3A/tools/android`
- `C:/M3A/tools/jdk`
- `C:/M3A/tools/git`
- `C:/M3A/cache/pub`
- `C:/M3A/cache/gradle`
- `C:/M3A/work/apps/flutter_elitesync_module`

If any exists, stop. Do not overwrite, merge, delete, or reuse it.

Then copy exactly once in this order:

1. Flutter
2. Android SDK
3. JDK
4. Git
5. Pub cache
6. Gradle root
7. Fixed module

Use exactly:

`robocopy <guest-seed> <fixed-target> /E /COPY:DAT /DCOPY:DAT /R:0 /W:0 /XJ /NFL /NDL /NP /NJH`

Robocopy exit `0..7` = success.

Any other exit = terminal failure.

No copy may write to its source.

## 11. Recovery write allowlist

Writes are allowed only to:

### Host

- fresh attempt root only

### Guest

- `C:/M3A/transport`
- `C:/M3A/tools/flutter`
- `C:/M3A/tools/android`
- `C:/M3A/tools/jdk`
- `C:/M3A/tools/git`
- `C:/M3A/cache/pub`
- `C:/M3A/cache/gradle`
- `C:/M3A/work/apps/flutter_elitesync_module`
- `C:/M3A/runtime/<attempt_id>/scratch`
- `C:/M3A/runtime/<attempt_id>/logs`

All other host and guest paths are write-forbidden.

In particular do not write:

- any host source root;
- `D:/EliteSync-v10`;
- Git index/staged state;
- historical evidence roots;
- any pre-existing/Owner-existing Sandbox;
- Gradle native metadata through manual fabrication/editing.

## 12. Post-materialization verification

After all seven copies succeed, verify every fixed target exists and re-run the same bounded identity gates at target-relative equivalents.

For Pub cache and Gradle, verify only the accepted existence-level facts; do not enumerate packages/dependencies and do not run package/Gradle tools.

For fixed module, require the accepted 527-file source baseline identity at the materialized target.

Do not use the separate 526-record protected-module manifest as a substitute.

## 13. Required receipts

The host attempt root must preserve exactly these top-level receipts:

- `launcher.json`
- `guest.started.json`
- `share-results.json`
- `materialization-results.json`
- `identity-results.json`
- `recovery-result.json`
- `recovery-summary.json`

Use common envelope:

- `schema`
- `attempt_id`
- `nonce`
- `sandbox_id`
- `written_utc`

Receipts must be written via same-directory temporary file, flushed/closed, then atomically renamed. Final receipt paths must not pre-exist and must not be overwritten.

`launcher.json` may use `sandbox_id = null` only if failure occurs before a valid ID is established.

Record exact native argument arrays, raw outputs, exit codes, parsed IDs/counts, share modes, robocopy exits, identity results, first blocker, and terminal classification as applicable.

Record:

- `network_not_used = true`
- `dep13_run = false`

## 14. Terminal classifications

Success only if every launcher, share, guest-start binding, target-absence, materialization, target-existence, and bounded identity gate passes:

`FIXED-GUEST RECOVERY COMPLETE — DEP13 NOT RUN`

Any first failure after task start:

`FIXED-GUEST RECOVERY FAILED — QUARANTINED — DEP13 NOT RUN`

Record the exact first blocker.

## 15. Failure quarantine

If a new Sandbox has been created and any later gate fails:

- preserve all obtainable evidence;
- report exact new Sandbox ID;
- leave that Sandbox running;
- do not create a second Sandbox;
- do not call `CloseMainWindow`;
- do not kill/reset/close;
- do not call `wsb stop`;
- do not delete/reuse the attempt root;
- do not act on any Owner-existing Sandbox.

Cleanup/disposal requires separate later authority.

## 16. Explicit prohibitions

No DEP13 probe in this task.
No Maven Central/Google Maven/mirror/source research.
No package fill or acquisition/download.
No Flutter pub/build.
No Gradle/gradlew/dependency resolution.
No M3.
No AAR probe.
No M1 retry.
No M2.
No product implementation.
No LC-03 / LC-04 / Phase 36.
No README read.
FD02 remains excluded.
No default `git status`.
No protected staged/index inspection.
No repository-wide/cache-wide/drive-wide/host-wide search.
No automatic helper agents.

## 17. Required result candidate

After reaching one terminal classification, create exactly one bounded result document on a fresh review branch whose sole parent is the verified durable `main` authority.

Recommended result path:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_FIXED_GUEST_RECOVERY_EXECUTION_RESULT_V0_1.md`

The result must contain:

1. repository/FIRST/task gates;
2. exact attempt ID/nonce/attempt root;
3. bounded source identity gate results;
4. pre/start/post Sandbox observations;
5. exact new Sandbox ID if created;
6. eight share results;
7. guest-start binding result;
8. seven materialization results;
9. guest target identity verification results;
10. receipt inventory;
11. explicit network/DEP13/Gradle/M3/AAR/M2 NOT_RUN state;
12. exact terminal classification;
13. exact first blocker if failure;
14. safest next bounded recommendation.

Executor must not self-accept and must not modify `main`.

After publishing candidate, stop and return:

- review branch;
- candidate commit;
- sole parent;
- candidate tree;
- result path;
- result blob;
- result SHA-256 if available;
- terminal classification;
- new Sandbox ID if established;
- attempt root;
- number of successful shares;
- number of successful materializations;
- failed gate / blocker or `NONE`.

`RECOVERY SUCCESS != DEP13 ACCEPTANCE`

`RECOVERY SUCCESS != B12 AUTHORITY`
