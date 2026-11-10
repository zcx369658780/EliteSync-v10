# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 Fixed-Guest Recovery Execution Result v0.1

Status: `CANDIDATE — FIXED-GUEST RECOVERY FAILED — QUARANTINED — DEP13 NOT RUN — NOT SELF-ACCEPTED`

Date: 2026-09-11

Repository: `zcx369658780/EliteSync-v10`

## 1. Repository, FIRST, accepted-contract, and task gates

- fresh-fetched GitHub `main`: `77e3a90c0d5ec8a5dfef281a253563ba5c9f6f2f`;
- main tree: `3192b43500c65ed49c1410d55535e5275944e666`;
- FIRST path: `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_FIXED_GUEST_RECOVERY_LOCATOR_METHOD_COMPLETION_ACCEPTANCE_V0_1.md`;
- FIRST blob: `80acc7aa7d588e698bacc92a859effda46bc43ef`;
- accepted locator/method result path: `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_FIXED_GUEST_RECOVERY_LOCATOR_METHOD_COMPLETION_RESULT_V0_1.md`;
- accepted locator/method result blob: `06671fe085baf2fc0940a498bedecffd3780cb63`;
- preserved transition FIRST blob: `18485c95262051e43892436fb52413132c5ee626`;
- task commit: `f8f5b4c7c0cf813701c35d76a21d95664e4ec1c0`;
- task sole parent: `77e3a90c0d5ec8a5dfef281a253563ba5c9f6f2f`;
- task tree: `bb2645fc005716f30b1b9c1bb5394a9cc9e4e78f`;
- task blob: `337868ce4980c4377271fd1666ca4c20755f8980`.

All repository and documentary gates passed before runtime actions.

## 2. Exact attempt identity

- nonce: `cbbbaef73f3347d9ba72c0eeb04e9e71`;
- attempt ID: `RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71`;
- task-owned host attempt root: `C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71`;
- root pre-existed: `false`;
- root created exactly once after host identity gates: `true`;
- root retained: `true`.

No attempt root was deleted, renamed, cleared, or reused.

## 3. Bounded host source identity gates

| Source class | Exact bounded observation | Result |
|---|---|---|
| Flutter | Dart SHA-256 `44328B98B6BF981D8307F72EF38ACBB37B8067394916953CAA48B8B444525152`; Dart SDK `3.11.5 stable`; tools pubspec Length `2946`, SHA-256 `6E31FF00AC4441294B60F20A71DCE2777CC80EB33663E6621DAE38C2391DB0EA`; tools snapshot Length `43747920`, SHA-256 `E494C265BA9C38A6A5679842703D3041DF0D2D86C83BFC55DF56C3BD0DF8E808` | `PASS` |
| Android SDK | `adb.exe` SHA-256 `7035CF5EC7F99F7B5662A9F5395F9DCCFC3B6FE42583D0B9550124A0C3496606`; `sdkmanager.bat` SHA-256 `11D021F90186F7FCC0B2D97623348C9C857109636B29D70FA1B804A4D603F5E7` | `PASS` |
| JDK | `java.exe` SHA-256 `5369CF92FC590944793E47CC9C9FEF7955CE1A68DE22BA22023CDD3513E87C2B`; Temurin/OpenJDK `17.0.18+8` | `PASS` |
| Git | `git.exe` SHA-256 `DA240FE9BC24895B3E04150A4990B8A6FF329ECABCD8F19684C2CC310DA5EF3F`; `git version 2.53.0.windows.1` | `PASS` |
| Pub cache | exact root exists; package enumeration `NOT_RUN` | `PASS` |
| Gradle root | exact root, `caches`, and `wrapper/dists` exist; Gradle/dependency inspection `NOT_RUN` | `PASS` |
| Fixed module | files `527`; directories `301`; bytes `3234145`; reparse points `0`; canonical TSV records `527`, Length `69676`, SHA-256 `4F869B12B5F466E35326966272F13BEA6EBABC69A631200E26F8F8E3D382DD2E`; `pubspec.yaml` Length `1984`, SHA-256 `ECBC74EF27D949712532409EADC6BE0928EA56C9CBC603EB0C80FBE0CEC7E6BC` | `PASS` |

The fixed-module TSV was recomputed in memory from the one literal source root using the accepted canonical contract (`relative_path<TAB>length<TAB>SHA256`, `/` paths, ordinal ordering, uppercase hashes, UTF-8 without BOM, LF plus final LF). It also matched the exact accepted expected TSV. No alternate locator or broad search was used. The historical 526-record protected-module manifest was not substituted.

Launcher CLI identity also passed: `C:/Users/zcxve/AppData/Local/Microsoft/WindowsApps/wsb.exe`, version `0.8.107.0`.

## 4. Sandbox pre/start/post observations

### Pre-start

- exact args: `list`, `--raw`;
- exit: `0`;
- JSON parse: `PASS`;
- `WindowsSandboxEnvironments`: `0`;
- gate: `PASS`.

### Start

- exact invocation count: `1`;
- exact args: `start`, `--raw`, `--config`, `<Configuration><Networking>Disable</Networking></Configuration>`;
- observed controller PID: `11656`;
- controller creation UTC: `2026-09-11T05:07:36.2314600Z`;
- second start/retry: `NOT_RUN`;
- captured stdout: `UNAVAILABLE`;
- captured exit code: `UNAVAILABLE`.

The single controller exceeded the initial 30-second capture window. Its execution-session handle was not retained, so its eventual raw stdout and exit code could not be recovered. The controller was not terminated and was allowed to exit naturally.

### Post-start

An observation made while PID `11656` was still running returned exit `0`, valid JSON, and zero environments; it was not treated as a completed-start binding. After the controller exited naturally, the completed-start observation returned:

- exit: `0`;
- JSON parse: `PASS`;
- environment count: `1`;
- observed new Sandbox ID: `7ebc163d-7e92-4a63-8218-47c03d5db697`.

Because the start command's returned text was unavailable, equality between its returned GUID and the observed post-start ID cannot be established. The launcher uniqueness/binding gate therefore failed closed.

## 5. New Sandbox and quarantine state

- new Sandbox created: `true`;
- new Sandbox ID: `7ebc163d-7e92-4a63-8218-47c03d5db697`;
- task-owned attribution status: `OBSERVED UNIQUE AFTER THE SINGLE START, BUT START-RETURN GUID BINDING UNPROVEN`;
- left running: `true`;
- second Sandbox created: `false`;
- `CloseMainWindow` / stop / kill / reset / close: `NOT_RUN`;
- Owner-existing Sandbox action: `NOT_RUN`.

The new Sandbox is quarantined. No access, exec, share, materialization, or cleanup action was performed against it after the binding failure.

## 6. Eight share results

| Order | Mapping | Mode | Result |
|---:|---|---|---|
| 1 | attempt root -> `C:/M3A/transport` | writable transport | `NOT_RUN` |
| 2 | `D:/flutter` -> `C:/M3A/source/flutter` | read-only source | `NOT_RUN` |
| 3 | Android SDK -> `C:/M3A/source/a7/android` | read-only source | `NOT_RUN` |
| 4 | JDK -> `C:/M3A/source/a7/jdk` | read-only source | `NOT_RUN` |
| 5 | Git -> `C:/M3A/source/a7/git` | read-only source | `NOT_RUN` |
| 6 | Pub cache -> `C:/M3A/source/a7/pub` | read-only source | `NOT_RUN` |
| 7 | Gradle root -> `C:/M3A/source/a7/gradle` | read-only source | `NOT_RUN` |
| 8 | fixed module -> `C:/M3A/source/a7/module` | read-only source | `NOT_RUN` |

Successful shares: `0/8`. No extra share was attempted.

## 7. Guest-start binding

`guest.started.json` binding execution: `NOT_RUN`.

The receipt bearing this filename in the host attempt root is explicitly a host-side `NOT_RUN` record, not a guest sentinel. It states `binding_status=NOT_RUN`, `attributable_guest_result=false`, and records why no writable transport or guest binding was established.

## 8. Seven materialization results

| Order | Fixed target | Result |
|---:|---|---|
| 1 | `C:/M3A/tools/flutter` | `NOT_RUN` |
| 2 | `C:/M3A/tools/android` | `NOT_RUN` |
| 3 | `C:/M3A/tools/jdk` | `NOT_RUN` |
| 4 | `C:/M3A/tools/git` | `NOT_RUN` |
| 5 | `C:/M3A/cache/pub` | `NOT_RUN` |
| 6 | `C:/M3A/cache/gradle` | `NOT_RUN` |
| 7 | `C:/M3A/work/apps/flutter_elitesync_module` | `NOT_RUN` |

Successful materializations: `0/7`. Robocopy invocation count: `0`. No target was created, overwritten, merged, deleted, or reused by this execution.

## 9. Guest target identity verification

All seven guest fixed-target identity gates are `NOT_RUN` because the launcher GUID binding failed before sharing/materialization. Guest identity pass count: `0/7`.

## 10. Receipt inventory

Evidence root: `C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71`

All seven final receipts were written via same-directory temporary files, flushed/closed, and atomically renamed. No final receipt path was overwritten.

| Receipt | Length | SHA-256 |
|---|---:|---|
| `launcher.json` | 1952 | `1314C3737A786E44C9E3C0DDA19F5EA7058C347587354636224E3427DF5DC465` |
| `guest.started.json` | 703 | `8A7B6035FC4B0B6AC0DBF7AA16D42453EFF0F9AEC51F17E2459C56409B8CFBCF` |
| `share-results.json` | 4943 | `514D557B925FA8E990FE34D53A203F02A1F87A3D4DD1DE70C5A7A71EBDDC77E4` |
| `materialization-results.json` | 4389 | `328B167E7BF7D7BFC686068BB47DF6DC2D3E303FFFFC4BA0C709EECEF5FEB57D` |
| `identity-results.json` | 3459 | `484A50408A7063C5DF21EF3C7194927237C4BE33D2313E4FEDF7F9D1714A19FD` |
| `recovery-result.json` | 2020 | `A217D0A88F065E6D93FFCDC42549EDC6EB909BE8CED88198DDBDC962F9FEBA97` |
| `recovery-summary.json` | 1002 | `E0B41C440E1814E25099C3A9268EEAFB650B83FEB03759C32A7465FE803FC7C4` |

## 11. Explicit NOT_RUN state

- guest Sandbox access/exec: `NOT_RUN`;
- DEP13: `NOT_RUN`;
- Maven/source research: `NOT_RUN`;
- package fill/acquisition/download: `NOT_RUN`;
- Flutter pub/build: `NOT_RUN`;
- Gradle/gradlew/dependency resolution: `NOT_RUN`;
- M3: `NOT_RUN`;
- AAR probe: `NOT_RUN`;
- M1 retry: `NOT_RUN`;
- M2: `NOT_RUN`;
- product implementation / LC-03 / LC-04 / Phase 36: `NOT_RUN`;
- README / FD02: `NOT_READ`;
- protected staged/index inspection: `NOT_RUN`.

`network_not_used=true`; the only Sandbox configuration supplied was the exact networking-disabled inline XML. No guest command, network command, package operation, source research, acquisition, or download was invoked.

## 12. Terminal classification

`FIXED-GUEST RECOVERY FAILED — QUARANTINED — DEP13 NOT RUN`

## 13. First blocker

`START_RESULT_NOT_CAPTURED — wsb start stdout/exit unavailable; returned GUID equality with post-start Sandbox ID cannot be verified`

This is an evidence-binding failure, not proof that the observed Sandbox failed to start technically. Fail-closed attribution prevents all successor recovery steps.

## 14. Safest next bounded recommendation

First obtain a fresh independent `ACCEPT` or `REJECT` of this candidate. Until then, preserve the attempt root and leave Sandbox `7ebc163d-7e92-4a63-8218-47c03d5db697` running and untouched. Any later inspection, disposal, cleanup, reuse decision, or new recovery attempt requires separate explicit Owner authority. DEP13 remains blocked and must not be resumed from this execution.

`RECOVERY FAILURE QUARANTINE != DEP13 AUTHORITY`

`RECOVERY FAILURE QUARANTINE != B12 AUTHORITY`
