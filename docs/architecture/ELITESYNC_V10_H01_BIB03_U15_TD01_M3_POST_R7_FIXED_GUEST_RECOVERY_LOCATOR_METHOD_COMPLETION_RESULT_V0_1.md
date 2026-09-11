# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 Fixed-Guest Recovery Locator/Method Completion Result v0.1

Status: `CANDIDATE — RECOVERY EXECUTION CONTRACT COMPLETE — READY FOR BOUNDED RECOVERY EXECUTION TASK — NOT SELF-ACCEPTED — NO RECOVERY EXECUTION AUTHORITY`

Date: 2026-09-11

Repository: `zcx369658780/EliteSync-v10`

## 1. Repository and FIRST gates

- fresh-fetched GitHub `main`: `32b595f747e03f0164a209543d28499398a02520`;
- required main tree: `940dc6603fcd3cf52ad55757eb1b891c98ecfaa3`;
- FIRST path: `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_FIXED_GUEST_RECOVERY_CONTRACT_REVIEW_ACCEPTANCE_V0_1.md`;
- required and observed FIRST blob: `04014bf9887e8838b7963f2e38e7fd11145d9edb`;
- fixed transition FIRST blob preserved: `18485c95262051e43892436fb52413132c5ee626`.

All mandatory repository/FIRST identities matched before substantive review.

## 2. Owner-supplied current fact inventory

The following values are treated only as the bounded Owner-supplied inputs authorized by the task.

| Class | Host source | Guest read-only seed | Fixed guest target |
|---|---|---|---|
| Flutter | `D:/flutter` | `C:/M3A/source/flutter` | `C:/M3A/tools/flutter` |
| Android SDK | `C:/Users/zcxve/AppData/Local/Android/Sdk` | `C:/M3A/source/a7/android` | `C:/M3A/tools/android` |
| JDK | `C:/Program Files/Eclipse Adoptium/jdk-17.0.18.8-hotspot` | `C:/M3A/source/a7/jdk` | `C:/M3A/tools/jdk` |
| Git | `C:/Program Files/Git` | `C:/M3A/source/a7/git` | `C:/M3A/tools/git` |
| Pub cache | `C:/Users/zcxve/AppData/Local/Pub/Cache` | `C:/M3A/source/a7/pub` | `C:/M3A/cache/pub` |
| Gradle root | `D:/GradleHome` | `C:/M3A/source/a7/gradle` | `C:/M3A/cache/gradle` |
| Fixed module | `D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/input-r6-r1/apps/flutter_elitesync_module` | `C:/M3A/source/a7/module` | `C:/M3A/work/apps/flutter_elitesync_module` |

The launcher is `C:/Users/zcxve/AppData/Local/Microsoft/WindowsApps/wsb.exe`, CLI version `0.8.107.0`. The exact inline configuration is `<Configuration><Networking>Disable</Networking></Configuration>`; no `.wsb` file or project-owned launcher wrapper is part of this contract. `D:/GradleHome/caches` and `D:/GradleHome/wrapper/dists` are included only through the Gradle-root mapping.

The bounded identity baselines are:

- Dart SHA-256 `44328B98B6BF981D8307F72EF38ACBB37B8067394916953CAA48B8B444525152`, SDK `3.11.5 stable`;
- Flutter-tools pubspec Length `2946`, SHA-256 `6E31FF00AC4441294B60F20A71DCE2777CC80EB33663E6621DAE38C2391DB0EA`;
- Flutter-tools snapshot Length `43747920`, SHA-256 `E494C265BA9C38A6A5679842703D3041DF0D2D86C83BFC55DF56C3BD0DF8E808`;
- Android `adb.exe` SHA-256 `7035CF5EC7F99F7B5662A9F5395F9DCCFC3B6FE42583D0B9550124A0C3496606` and `sdkmanager.bat` SHA-256 `11D021F90186F7FCC0B2D97623348C9C857109636B29D70FA1B804A4D603F5E7`;
- JDK `java.exe` SHA-256 `5369CF92FC590944793E47CC9C9FEF7955CE1A68DE22BA22023CDD3513E87C2B`, Temurin/OpenJDK `17.0.18+8`;
- Git `git.exe` SHA-256 `DA240FE9BC24895B3E04150A4990B8A6FF329ECABCD8F19684C2CC310DA5EF3F`, `git version 2.53.0.windows.1`;
- fixed module: files `527`, directories `301`, bytes `3234145`, reparse points `0`, TSV Length `69676`, TSV SHA-256 `4F869B12B5F466E35326966272F13BEA6EBABC69A631200E26F8F8E3D382DD2E`, `pubspec.yaml` Length `1984`, SHA-256 `ECBC74EF27D949712532409EADC6BE0928EA56C9CBC603EB0C80FBE0CEC7E6BC`;
- Pub cache root exists, without package enumeration;
- Gradle root, `caches`, and `wrapper/dists` exist, without dependency-resolution inspection.

The 527-file source baseline is not the earlier protected-module manifest of 526 records and must never be substituted for it.

## 3. Exact launcher/controller contract

The future bounded recovery task must use PowerShell argument arrays; it must not construct a shell command string or rely on nested quote interpretation:

```powershell
$WsbExe = 'C:/Users/zcxve/AppData/Local/Microsoft/WindowsApps/wsb.exe'
$InlineConfig = '<Configuration><Networking>Disable</Networking></Configuration>'
$Nonce = [Guid]::NewGuid().ToString('N')
$AttemptId = "RECOVERY-$Nonce"
$AttemptRoot = "C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-$AttemptId"

$PreRaw = & $WsbExe @('list', '--raw') 2>&1
$PreExit = $LASTEXITCODE
# Parse $PreRaw as JSON; WindowsSandboxEnvironments must exist and have Count 0.

$StartRaw = & $WsbExe @('start', '--raw', '--config', $InlineConfig) 2>&1
$StartExit = $LASTEXITCODE
$SandboxIdText = ([string]::Join("`n", $StartRaw)).Trim()
$ParsedSandboxId = [Guid]::Empty
$IdValid = [Guid]::TryParse($SandboxIdText, [ref]$ParsedSandboxId)
$SandboxId = if ($IdValid) { $ParsedSandboxId.ToString() } else { $null }

$PostRaw = & $WsbExe @('list', '--raw') 2>&1
$PostExit = $LASTEXITCODE
# Parse $PostRaw as JSON; select WindowsSandboxEnvironments entries whose State is Running.
# Exactly one must remain, and its Id parsed as a GUID must equal $SandboxId.
```

Each native invocation is one executable plus one literal argument array. Consequently the XML is passed as one argument without additional escaping, and the executable path with spaces needs no manual quoting. Pre-list, start, and post-list exit codes must each be `0`. Missing/invalid JSON, missing properties, invalid returned GUID, zero/multiple running entries, or ID mismatch is a terminal fail-closed result. No retry and no second Sandbox is permitted.

Before pre-list, the future task must require `$AttemptRoot` not to exist and then create it exclusively for this attempt. `launcher.json` records the common binding envelope plus CLI path/version, exact argument arrays, inline XML, full pre/start/post raw outputs, their exit codes, parsed counts and IDs, `launcher_started_utc`, and `launcher_controller_pid: "NOT_APPLICABLE"`; `wsb start --raw` supplies no stable Sandbox launcher PID. The receipt is emitted even for a launcher gate failure when the attempt root exists.

## 4. Exact share contract

After launcher uniqueness binding, establish the writable evidence share first:

```text
wsb share --id <SandboxId> --host-path C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-<attempt-id> --sandbox-path C:/M3A/transport --allow-write --raw
```

Then establish exactly seven source shares in the table order in §2 using:

```text
wsb share --id <SandboxId> --host-path <literal-host-source> --sandbox-path <literal-guest-seed> --raw
```

The future PowerShell implementation must invoke `$WsbExe` with an argument array for each share. `--allow-write` is present only for the task-owned transport share and absent from every source share. Every share exit code must be `0`; failure is terminal. The attempt root must not overlap, contain, or be contained by any source root. No extra share is permitted.

## 5. Exact materialization order and copy contract

The future task must perform these stages exactly once and in this order:

1. Require the seven literal host sources to exist and pass all bounded source identity gates in §2 before any share or materialization. Require the fresh attempt root to have been absent; create it. Pub checking stops at root existence. Gradle checking stops at root/`caches`/`wrapper/dists` existence. No DEP13 or dependency inspection occurs.
2. Run the pre-list/start/capture/post-list uniqueness contract in §3.
3. Establish the one writable transport share.
4. Establish the seven read-only source shares in §2 table order.
5. Atomically emit `guest.started.json`, bound to the exact `attempt_id + nonce + sandbox_id`, before any materialization.
6. Materialize Flutter.
7. Materialize Android SDK.
8. Materialize JDK.
9. Materialize Git.
10. Materialize Pub cache.
11. Materialize Gradle root.
12. Materialize fixed module.
13. Verify all fixed M3A target roots and the same bounded identities from §2 at their target-relative equivalents.
14. Atomically emit terminal recovery result and summary receipts.
15. Stop. DEP13 is not run in the same execution.

For each of stages 6–12, all seven destinations must first have been checked absent before the first copy begins. Invoke exactly:

```text
robocopy <literal-guest-seed> <literal-fixed-target> /E /COPY:DAT /DCOPY:DAT /R:0 /W:0 /XJ /NFL /NDL /NP /NJH
```

Robocopy exits `0..7` are success; every other exit is terminal failure. `/XJ` is mandatory. No option that writes to a source is permitted. After each copy, its destination must exist; later identity gates determine whether its content is acceptable. The Flutter mapping uses this same contract, so it has no exceptional materialization semantics.

## 6. Exact recovery write allowlist

Only these roots may be written by the future recovery task:

- host `C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-<attempt-id>`;
- guest `C:/M3A/transport`;
- guest `C:/M3A/tools/flutter`;
- guest `C:/M3A/tools/android`;
- guest `C:/M3A/tools/jdk`;
- guest `C:/M3A/tools/git`;
- guest `C:/M3A/cache/pub`;
- guest `C:/M3A/cache/gradle`;
- guest `C:/M3A/work/apps/flutter_elitesync_module`;
- guest runtime scratch `C:/M3A/runtime/<attempt-id>/scratch`;
- guest runtime logs `C:/M3A/runtime/<attempt-id>/logs`.

The attempt ID embedded in every guest runtime path must equal the receipt binding. All other host and guest paths are write-forbidden. This explicitly includes all seven host sources, `D:/EliteSync-v10`, its Git index/staged state, historical evidence roots, any Owner-existing Sandbox, and Gradle native metadata. Native Gradle metadata must not be fabricated or edited.

## 7. Exact sentinel and receipt contract

The attempt root contains exactly these top-level receipt paths:

- `launcher.json`;
- `guest.started.json`;
- `share-results.json`;
- `materialization-results.json`;
- `identity-results.json`;
- `recovery-result.json`;
- `recovery-summary.json`.

Every JSON receipt has the common envelope `schema`, `attempt_id`, `nonce`, `sandbox_id`, and `written_utc`. `schema` is the literal filename without `.json`, suffixed `/v1` (for example, `guest.started/v1`). Only `launcher.json` may use `sandbox_id: null`, and only when a pre-list/start/ID-capture gate fails before a valid ID exists; once the Sandbox ID exists, `launcher.json` and all later receipts must contain the same normalized GUID. A receipt is written to a same-directory task-owned temporary filename, flushed and closed, and atomically renamed to its final name; the final path must not pre-exist and is never overwritten.

Required record bodies are:

| Receipt | Required fields beyond common envelope |
|---|---|
| `launcher.json` | `launcher_path`, `launcher_version`, exact `pre_args`, `start_args`, `post_args`, `inline_config`, `launcher_started_utc`, `launcher_controller_pid`, raw outputs, exit codes, parsed counts/IDs, and gate result/blocker |
| `guest.started.json` | `binding_status`, `transport_host_root`, `transport_guest_root`, and `written_before_materialization`; all must affirm the exact binding and order |
| `share-results.json` | eight ordered entries containing host path, guest path, mode (`writable-transport` or `read-only-source`), exact args, raw output, exit code, and pass/fail |
| `materialization-results.json` | seven ordered entries containing source, target, exact robocopy args, pre-copy target-absence result, exit code, post-copy target-existence result, and pass/fail |
| `identity-results.json` | seven source-locator results and seven guest-root results, each with applicable version/hash/Length/count/bytes/reparse/manifest values from §2; Pub and Gradle carry only their authorized existence checks |
| `recovery-result.json` | ordered gate results, first terminal blocker or `NONE`, `network_not_used: true`, evidence that inline networking was disabled and no network/acquisition command was invoked, `dep13_run: false`, and terminal classification |
| `recovery-summary.json` | compact attempt binding, Sandbox ID, passed/failed counts, first blocker, preserved paths, `network_not_used`, `dep13_run`, and terminal classification |

`guest.started.json` must be visible through the writable transport and bind `attempt_id + nonce + sandbox_id` before stage 6 begins. Any guest output missing or disagreeing with this triple is non-attributable and fails closed. Terminal success requires every launcher, share, target-absence, materialization, target-existence, and bounded source/guest identity gate to pass. The success classification is `FIXED-GUEST RECOVERY COMPLETE — DEP13 NOT RUN`. Any first failed gate yields `FIXED-GUEST RECOVERY FAILED — QUARANTINED — DEP13 NOT RUN` plus its exact blocker.

## 8. Quarantine and cleanup contract

If any gate fails after a new task-owned Sandbox was created, the future task must preserve all obtainable receipts, report the exact new Sandbox ID and first terminal blocker, leave that Sandbox running, and stop. It must not create a second Sandbox and must not call `CloseMainWindow`, kill, reset, close, or `wsb stop`.

The future task must never act on an Owner-existing Sandbox. Historical evidence is neither deleted nor reused. The task-owned host attempt root remains preserved after success or failure. Any disposal or cleanup requires a separately authorized later task. This evidence-preserving stop state is intentional.

## 9. Unresolved facts

Unresolved contract-element count: `0`.

The supplied locator, launcher, share, materialization, write-boundary, identity, receipt, and quarantine inputs form one internally consistent fail-closed contract. No source discovery, Sandbox test, or external research was needed to close it.

## 10. Readiness classification

`RECOVERY EXECUTION CONTRACT COMPLETE — READY FOR BOUNDED RECOVERY EXECUTION TASK`

This classification means only that a separately authorized execution task can be authored without inventing locator or method fields.

`CONTRACT COMPLETE != SANDBOX RECOVERY EXECUTION AUTHORITY`

## 11. Explicit NOT_RUN / NOT_AUTHORIZED

This review did not create, start, stop, close, reset, kill, share, materialize, access, or inspect any Sandbox and did not execute `wsb`. It did not run DEP13, Maven/source research, acquisition, network/package fill, Gradle/gradlew/dependency resolution, M3, AAR probing, M1, M2, product implementation, LC-03, LC-04, or Phase 36. It did not read README or FD02, perform host/repository-wide discovery, inspect protected staged/index state, modify `main`, or self-accept this candidate.

## 12. Safest next bounded task

After fresh independent acceptance of this candidate, the sole safest successor is an Owner-authored and explicitly authorized bounded fixed-guest recovery execution task that copies this contract literally, uses one fresh task-owned Sandbox attempt, stops before DEP13, preserves the quarantine rule, and grants no additional authority. No downstream task is published or executed here.
