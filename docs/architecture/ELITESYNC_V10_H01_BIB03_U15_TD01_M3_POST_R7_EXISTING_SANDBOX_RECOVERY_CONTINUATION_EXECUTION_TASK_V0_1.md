# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 Existing Sandbox Recovery Continuation Execution Task v0.1

Status: `TASK AUTHORIZED — ONE BOUNDED EXISTING-SANDBOX RECOVERY CONTINUATION EXECUTION — NO NEW SANDBOX — DEP13 NOT AUTHORIZED — NO MAVEN/SOURCE RESEARCH — NO ACQUISITION — NO GRADLE/M3 — NO M2`

Date: 2026-09-11

Repository: `zcx369658780/EliteSync-v10`

## 1. Purpose

Execute exactly one bounded continuation of fixed-guest recovery on the already rebound existing Windows Sandbox.

This task may resume only the previously unexecuted recovery chain:

`fresh runtime identity gate -> rebinding receipt gate -> fresh continuation namespace -> bounded host identity gates -> 1 writable continuation share + 7 read-only source shares -> continuation guest binding -> 7 target-absence gates -> 7 materializations -> bounded guest identity gates -> terminal receipts -> STOP`

This task does not authorize DEP13, Maven/source-object research, package acquisition, Gradle/M3, AAR probe, M1 retry, M2, product implementation, LC-03, LC-04, or Phase 36.

`RECOVERY CONTINUATION EXECUTION != DEP13 AUTHORITY`

## 2. Mandatory repository startup gate

Fresh-fetch GitHub `main` first and require exact durable authority:

`72a243ce5b03480834599a26c65e51887b7082ec`

Require exact tree:

`0f0606d279fac9dca481c6a527281918385183c6`

Read FIRST:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_RECOVERY_CONTINUATION_SCOPE_DECISION_ACCEPTANCE_V0_1.md`

Require FIRST blob:

`68497d618974f3ec9ccb5dd262da76a1151ab20c`

Also read exact accepted execution inputs:

1. `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_RECOVERY_CONTINUATION_SCOPE_DECISION_RESULT_V0_1.md`
   - require blob `ff6ccebf36e60244dcf334893f45f63e445d937c`
2. `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_FIXED_GUEST_RECOVERY_LOCATOR_METHOD_COMPLETION_RESULT_V0_1.md`
   - require blob `06671fe085baf2fc0940a498bedecffd3780cb63`
3. `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_FIXED_GUEST_RECOVERY_EXECUTION_RESULT_V0_1.md`
   - require blob `687a62e9c0016bb9521cc2f77fc451d38baa89f1`
4. `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_EXISTING_SANDBOX_REBINDING_IDENTITY_ESTABLISHMENT_RESULT_V0_1.md`
   - require blob `cc0ce0007c910cb13baab203d5ad8f4c514b27ff`

Preserve transition FIRST blob:

`18485c95262051e43892436fb52413132c5ee626`

If any identity gate fails, stop before runtime action.

## 3. Accepted facts and immutable boundaries

Preserve without reinterpretation:

- original launcher contract remains failed at `START_RESULT_NOT_CAPTURED`;
- accepted rebound Sandbox ID is exactly `7ebc163d-7e92-4a63-8218-47c03d5db697`;
- no new Sandbox may be created or started;
- historical attempt ID is `RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71`;
- historical nonce is `cbbbaef73f3347d9ba72c0eeb04e9e71`;
- preserved host attempt root is `C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71`;
- rebinding receipt is `rebinding-v0-1.json`;
- accepted rebinding receipt SHA-256 is `84449F657588C4E3488C1A42F78EB6B1DB27ED1C028C98ABCD7A5EADDE37A915`;
- prior recovery execution completed `0/8` shares and `0/7` materializations;
- historical top-level receipts and rebinding receipt are immutable;
- B12 remains NOT AUTHORIZED.

## 4. Exact continuation namespace

Exact host continuation namespace:

`C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71/continuation-v0-1`

After runtime and rebinding-receipt gates, require this exact path absent. Create it exactly once.

If it already exists, terminal fail closed. Do not clear, delete, rename, reuse, merge, or overwrite it.

All new task-owned scripts, logs, and receipts must remain inside this namespace.

Expected continuation-owned final files:

- `runtime-observation.json`
- `rebinding-verification.json`
- `source-identity-results.json`
- `share-results.json`
- `guest.bound.json`
- `target-absence-results.json`
- `materialization-results.json`
- `guest-identity-results.json`
- `continuation-result.json`
- `continuation-summary.json`
- `continuation-recovery.ps1`

Use same-directory temporary files, flush/close, and atomic rename for final receipts. Final paths must not pre-exist and must never be overwritten.

## 5. Runtime identity gate

Perform exactly one fresh runtime observation before any continuation action using the accepted `wsb` executable and invocation semantics from the locator/method contract:

`wsb list --raw`

Require:

- process exit `0`;
- valid JSON containing `WindowsSandboxEnvironments`;
- exactly one applicable running Sandbox;
- sole Sandbox ID exactly `7ebc163d-7e92-4a63-8218-47c03d5db697`.

Zero, multiple, invalid JSON, nonzero exit, or ID mismatch is terminal.

No polling. No retry. No `wsb start`.

## 6. Rebinding receipt gate

Before creating the continuation namespace, verify the exact preserved rebinding receipt as an ordinary file under the accepted attempt root.

Require SHA-256 exactly:

`84449F657588C4E3488C1A42F78EB6B1DB27ED1C028C98ABCD7A5EADDE37A915`

Absence, type mismatch, unreadability, or hash mismatch is terminal.

Do not edit, rename, replace, delete, or reuse the receipt.

## 7. Host source identity gates

After creating the fresh continuation namespace and before any share, verify exactly the accepted bounded host-source baselines from the locator/method contract and scope decision.

Use only exact literal source paths already accepted:

1. Flutter: `D:/flutter`
2. Android SDK: `C:/Users/zcxve/AppData/Local/Android/Sdk`
3. JDK: `C:/Program Files/Eclipse Adoptium/jdk-17.0.18.8-hotspot`
4. Git: `C:/Program Files/Git`
5. Pub cache: `C:/Users/zcxve/AppData/Local/Pub/Cache`
6. Gradle root: `D:/GradleHome`
7. fixed module: `D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/input-r6-r1/apps/flutter_elitesync_module`

Accepted bounded baselines:

- Dart SHA-256 `44328B98B6BF981D8307F72EF38ACBB37B8067394916953CAA48B8B444525152`, SDK `3.11.5 stable`;
- Flutter-tools pubspec Length `2946`, SHA-256 `6E31FF00AC4441294B60F20A71DCE2777CC80EB33663E6621DAE38C2391DB0EA`;
- Flutter-tools snapshot Length `43747920`, SHA-256 `E494C265BA9C38A6A5679842703D3041DF0D2D86C83BFC55DF56C3BD0DF8E808`;
- Android `adb.exe` SHA-256 `7035CF5EC7F99F7B5662A9F5395F9DCCFC3B6FE42583D0B9550124A0C3496606`;
- Android `sdkmanager.bat` SHA-256 `11D021F90186F7FCC0B2D97623348C9C857109636B29D70FA1B804A4D603F5E7`;
- JDK `java.exe` SHA-256 `5369CF92FC590944793E47CC9C9FEF7955CE1A68DE22BA22023CDD3513E87C2B`, Temurin/OpenJDK `17.0.18+8`;
- Git `git.exe` SHA-256 `DA240FE9BC24895B3E04150A4990B8A6FF329ECABCD8F19684C2CC310DA5EF3F`, `git version 2.53.0.windows.1`;
- Pub cache root existence only, without package enumeration;
- Gradle root, `caches`, and `wrapper/dists` existence only, without dependency-resolution inspection or Gradle execution;
- fixed module files `527`, directories `301`, bytes `3234145`, reparse points `0`, TSV Length `69676`, TSV SHA-256 `4F869B12B5F466E35326966272F13BEA6EBABC69A631200E26F8F8E3D382DD2E`, `pubspec.yaml` Length `1984`, SHA-256 `ECBC74EF27D949712532409EADC6BE0928EA56C9CBC603EB0C80FBE0CEC7E6BC`.

Do not substitute the separate 526-record protected-module manifest for the 527-file fixed-module baseline.

Write bounded results to `source-identity-results.json`.

Any mismatch is terminal before share.

## 8. Prepare continuation script and initial receipts

Create `continuation-recovery.ps1` inside the fresh continuation namespace using only the exact execution contract in this task and accepted scope result.

Before sharing, create host-side immutable receipts for runtime observation, rebinding verification, and source identity results.

The continuation script must be immutable after guest binding begins.

Do not place scripts or receipts outside the continuation namespace.

## 9. Exact share scope

Use only the accepted `wsb share` syntax from the scope result and accepted locator/method contract.

### 9.1 One writable continuation share

Expose only the continuation namespace, not the whole attempt root:

- host: `C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71/continuation-v0-1`
- guest: `C:/M3A/transport/continuation-v0-1`
- writable: YES

The accepted command shape is:

`wsb share --id 7ebc163d-7e92-4a63-8218-47c03d5db697 --host-path <literal-host> --sandbox-path <literal-guest> --allow-write --raw`

### 9.2 Exactly seven read-only source shares

Establish in this exact order, without `--allow-write`:

1. `D:/flutter` -> `C:/M3A/source/flutter`
2. `C:/Users/zcxve/AppData/Local/Android/Sdk` -> `C:/M3A/source/a7/android`
3. `C:/Program Files/Eclipse Adoptium/jdk-17.0.18.8-hotspot` -> `C:/M3A/source/a7/jdk`
4. `C:/Program Files/Git` -> `C:/M3A/source/a7/git`
5. `C:/Users/zcxve/AppData/Local/Pub/Cache` -> `C:/M3A/source/a7/pub`
6. `D:/GradleHome` -> `C:/M3A/source/a7/gradle`
7. `D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/input-r6-r1/apps/flutter_elitesync_module` -> `C:/M3A/source/a7/module`

Accepted read-only command shape:

`wsb share --id 7ebc163d-7e92-4a63-8218-47c03d5db697 --host-path <literal-host> --sandbox-path <literal-guest> --raw`

Every share must exit `0`. First failure terminates execution. No additional share is authorized.

Record exact outcomes in `share-results.json`.

## 10. Guest execution and continuation binding

After all 8 shares succeed, run exactly one continuation guest execution against the rebound Sandbox using the accepted `wsb exec` semantics from the locator/method contract.

Restrictions:

- exact Sandbox ID only: `7ebc163d-7e92-4a63-8218-47c03d5db697`;
- run as System;
- working directory exactly `C:/M3A/transport/continuation-v0-1`;
- script exactly `C:/M3A/transport/continuation-v0-1/continuation-recovery.ps1`;
- no additional guest command or shell exploration.

The script must first atomically establish and verify:

`C:/M3A/transport/continuation-v0-1/guest.bound.json`

Required fields:

- `schema = existing-sandbox-recovery-continuation-binding/v1`
- `attempt_id = RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71`
- `nonce = cbbbaef73f3347d9ba72c0eeb04e9e71`
- `sandbox_id = 7ebc163d-7e92-4a63-8218-47c03d5db697`
- `rebinding_receipt_sha256 = 84449F657588C4E3488C1A42F78EB6B1DB27ED1C028C98ABCD7A5EADDE37A915`
- `continuation_version = v0-1`
- exact `host_namespace`
- `guest_transport_root = C:/M3A/transport/continuation-v0-1`
- `original_launcher_contract = FAILED_START_RESULT_NOT_CAPTURED`
- `no_second_sandbox = true`
- `written_before_target_or_materialization_action = true`
- `binding_status = PASS`
- `written_utc`

Any missing or mismatched field is terminal before target checks.

Do not edit historical `guest.started.json`.

## 11. Seven target-absence gates

Before every copy, require all seven fixed targets absent:

1. `C:/M3A/tools/flutter`
2. `C:/M3A/tools/android`
3. `C:/M3A/tools/jdk`
4. `C:/M3A/tools/git`
5. `C:/M3A/cache/pub`
6. `C:/M3A/cache/gradle`
7. `C:/M3A/work/apps/flutter_elitesync_module`

Write results to `target-absence-results.json`.

If any target exists, terminal fail closed before all copies.

Never overwrite, merge, delete, clear, rename, or reuse a pre-existing target.

## 12. Exact materialization scope

Only if all seven targets are absent, materialize exactly once in this order:

1. Flutter: `C:/M3A/source/flutter` -> `C:/M3A/tools/flutter`
2. Android SDK: `C:/M3A/source/a7/android` -> `C:/M3A/tools/android`
3. JDK: `C:/M3A/source/a7/jdk` -> `C:/M3A/tools/jdk`
4. Git: `C:/M3A/source/a7/git` -> `C:/M3A/tools/git`
5. Pub cache: `C:/M3A/source/a7/pub` -> `C:/M3A/cache/pub`
6. Gradle root: `C:/M3A/source/a7/gradle` -> `C:/M3A/cache/gradle`
7. fixed module: `C:/M3A/source/a7/module` -> `C:/M3A/work/apps/flutter_elitesync_module`

Use only:

`robocopy <guest-seed> <fixed-target> /E /COPY:DAT /DCOPY:DAT /R:0 /W:0 /XJ /NFL /NDL /NP /NJH`

Exit `0..7` = success. Any other exit is terminal.

Do not use options that write to source.

Record exact outcomes in `materialization-results.json`.

## 13. Bounded guest identity verification

After all seven materializations succeed, require every target root to exist and verify the same accepted bounded identities relative to guest targets.

Use the baselines in §7 unchanged.

Do not run Flutter build/pub, Gradle, Maven, dependency resolution, package installation, network activity, or project implementation.

Record exact outcomes in `guest-identity-results.json`.

Any mismatch is terminal.

## 14. Terminal receipts and classification

On complete success, atomically emit continuation result and summary receipts inside the continuation namespace and classify exactly:

`FIXED-GUEST RECOVERY CONTINUATION COMPLETE — DEP13 NOT RUN`

On the first failure after namespace creation, emit obtainable failure receipts and classify exactly:

`FIXED-GUEST RECOVERY CONTINUATION FAILED — QUARANTINED — DEP13 NOT RUN`

The result must record at minimum:

- observed running Sandbox count and exact ID;
- rebinding receipt verification;
- continuation namespace status;
- host source identity pass count;
- successful share count out of 8;
- guest binding status;
- target-absence pass count out of 7;
- materialization success count out of 7;
- guest identity pass count;
- first blocker or `NONE`;
- original launcher contract remains failed;
- DEP13 = NOT_RUN.

## 15. Failure quarantine

At first blocker:

- preserve all obtainable continuation evidence;
- leave existing rebound Sandbox running;
- no retry;
- no polling loop;
- no second Sandbox;
- no `wsb start`;
- no stop/close/reset/kill;
- no cleanup/disposal;
- do not undo successful shares;
- do not undo partial materializations;
- no DEP13.

Any later cleanup or disposal requires separate authority.

## 16. Explicit prohibitions

No new Sandbox creation/start.
No second Sandbox.
No broad runtime observation beyond the single initial `wsb list --raw` gate.
No unauthorized shares.
No guest exploration.
No extra guest command beyond the exact continuation script execution.
No host/repo/cache/drive discovery.
No Maven/source-object research.
No acquisition/package fill.
No guest network use.
No Flutter pub/build.
No Gradle execution.
No M3/AAR/M1/M2.
No DEP13.
No cleanup/stop/close/reset/kill.
No README read.
FD02 remains excluded.
No protected staged/index inspection.
No automatic helper agents.
No product implementation / LC-03 / LC-04 / Phase 36.

## 17. Required repository result candidate

After terminal success or failure, create exactly one result document on a fresh review branch whose sole parent is the verified durable `main` from §2.

Recommended path:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_EXISTING_SANDBOX_RECOVERY_CONTINUATION_EXECUTION_RESULT_V0_1.md`

The result must contain:

1. repository/FIRST/task gates;
2. runtime observation;
3. rebinding receipt verification;
4. namespace result;
5. host identity gates;
6. exact share results;
7. guest binding result;
8. target-absence results;
9. materialization results;
10. guest identity results;
11. terminal receipt summary;
12. first blocker or NONE;
13. exact terminal classification;
14. explicit NOT_RUN / NOT_AUTHORIZED section;
15. one safest next bounded recommendation.

Executor must not self-accept.
Do not modify `main`.
Do not publish or execute DEP13 in the same execution.

After publishing the candidate, stop and report:

- review branch;
- candidate commit;
- sole parent;
- candidate tree;
- result path;
- result blob;
- result SHA-256 if available;
- terminal classification;
- runtime Sandbox count and ID;
- host source identity pass count;
- successful share count `/8`;
- guest binding PASS/FAIL;
- target-absence pass count `/7`;
- materialization success count `/7`;
- guest identity pass count;
- first blocker or NONE.

`RECOVERY CONTINUATION SUCCESS != DEP13 AUTHORITY UNTIL INDEPENDENT ACCEPTANCE`