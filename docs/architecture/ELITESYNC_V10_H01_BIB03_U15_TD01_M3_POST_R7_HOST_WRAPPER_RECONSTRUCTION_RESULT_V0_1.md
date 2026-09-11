# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 Host Wrapper Reconstruction Result｜v0.1

Status: `HOST WRAPPER RECONSTRUCTED — PROSPECTIVE ARGV/QUOTING CONTRACT ESTABLISHED — READY FOR INDEPENDENT C ACCEPTANCE`

Date: 2026-09-11 (Asia/Singapore)

## 1. Authority and bounded result

- fresh-fetched `main`: `250e89ffd8d314422f3bc436f711fe49a0a423d2`;
- FIRST handoff blob: `3aa2ead4cf1084b202b67856075c26ab80b0c9a2`;
- task blob: `ea24cf6882670e823666d02b45622b349ecbc25b`;
- accepted Owner-decision-gate blob: `75f81031c8e4d15fc0aac337cc8dac76943dbfa2`;
- candidate branch: `review/h01-bib03-u15-td01-m3-post-r7-host-wrapper-reconstruction-v0-1`.

This C result reconstructs only a prospective current-project host wrapper. It neither reconstructs the unavailable historical launcher nor executes a share.

Created wrapper:

`tools/recovery/Invoke-EliteSyncWsbShare.ps1`

- Git blob: `b3a751e18d713c98b56d66972d501292544a847f`;
- SHA-256: `2776034B4BD42FA5D25EB2997B59EDEE5AEFF3668C567788BBCB3CF222A3BE64`.

## 2. Prospective wrapper contract

Required share inputs are:

1. exact `WsbExePath` text;
2. exact 8-4-4-4-12 hexadecimal `SandboxId` text;
3. exact `HostPath` text;
4. optional exact `SandboxPath` text, distinguished from omission by `PSBoundParameters`;
5. required Boolean `Writable`;
6. required Boolean `RawOutput`.

The fixed argv construction order is:

```text
share
--id
<SandboxId>
--host-path
<HostPath>
[--sandbox-path, <SandboxPath> only when supplied]
[--allow-write only when Writable=true]
[--raw only when RawOutput=true]
```

Every entry is appended separately to a `System.Collections.Generic.List[string]`. In a future separately authorized operational mode, every entry is then appended separately with `System.Diagnostics.ProcessStartInfo.ArgumentList.Add`. The executable is assigned independently to `ProcessStartInfo.FileName`; `UseShellExecute=false`. No shell, command string, `Invoke-Expression`, call operator, `Start-Process`, or `ProcessStartInfo.Arguments` is used.

The wrapper does not replace separators, resolve `.` or `..`, canonicalize or root paths, trim caller text, change case, change the Sandbox ID, test the host/share target in dry-run mode, or create host/guest directories. Validation is limited to rejecting null/empty/whitespace input, NUL/CR/LF ambiguity, and a nonconforming Sandbox ID lexical shape. JSON escaping changes only receipt representation; parsing the receipt recovers the exact caller strings.

## 3. Default and future activation gate

`ExecutionMode` defaults to `DRY_RUN_ONLY`. That branch rejects activation/evidence parameters, emits the receipt, and returns before any `ProcessStartInfo` instance or process object is constructed.

Operational mode exists solely as a future task interface and was not invoked in C. It requires all of the following before `Process.Start()` can be reached:

- explicit `-ExecutionMode OPERATIONAL`;
- explicit nonempty `-ActivationToken`;
- a nonempty process-scoped environment value named `ELITESYNC_WSB_SHARE_ACTIVATION_TOKEN`;
- ordinal equality between those two token values;
- explicit, pre-existing `EvidenceDirectory`;
- existing `WsbExePath` file;
- absence of every fixed evidence output file, preventing overwrite.

The token is never included in argv or receipts. A future task must own setting and supplying it. C does not establish such a token and creates no operational authority.

When separately authorized, the direct process branch writes `wsb-share-argv-receipt.json` before launch, redirects and captures stdout/stderr to `wsb-share-stdout.txt` and `wsb-share-stderr.txt`, and writes the exit code and filenames to `wsb-share-result.json`. It requires the evidence directory to exist and never creates it. These definitions are prospective and unexecuted.

## 4. Deterministic receipt verification

The dry-run receipt uses a fixed schema/property order, fixed LF separators, invariant lowercase JSON control escapes, and the exact ordered token array. Two runs with identical historical inputs produced ordinally identical receipt text. The final receipt was valid JSON.

Exact dry-run receipt for the accepted historical failed token set:

```json
{
  "schema": "elitesync.wsb-share.argv-receipt.v1",
  "executionMode": "DRY_RUN_ONLY",
  "processLaunch": false,
  "executablePath": "C:\\Program Files\\WindowsApps\\MicrosoftWindows.WindowsSandbox_0.8.107.0_x64__cw5n1h2txyewy\\wsb.exe",
  "argv": [
    "share",
    "--id",
    "7ebc163d-7e92-4a63-8218-47c03d5db697",
    "--host-path",
    "C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71/continuation-v0-1",
    "--sandbox-path",
    "C:/M3A/transport/continuation-v0-1",
    "--allow-write",
    "--raw"
  ]
}
```

Final verification facts:

- `DRY_RUNS_COMPLETED=True`;
- `DETERMINISTIC=True`;
- decoded synthetic executable, host path, and Sandbox path each matched the exact caller string;
- historical `argv` count: `9`;
- historical `processLaunch`: `false`;
- a future-B-shaped dry run that omitted `SandboxPath` omitted both `--sandbox-path` and its value, produced `7` tokens, and reported `processLaunch=false`;
- an ambiguous Sandbox ID failed closed.

The first serializer verification exposed an invalid backslash escape caused by switch-flow behavior. That implementation defect was corrected before the final verification above; the failed verification also remained entirely inside the dry-run return path.

## 5. No-launch and no-mutation proof

Both static control flow and execution evidence establish no process launch:

- the `DRY_RUN_ONLY` branch returns before `ProcessStartInfo` construction and `Process.Start()`;
- a dry run using the deliberately nonexistent executable text `Z:\synthetic path\wsb.exe` completed and emitted a valid receipt with `processLaunch=false`; it would not have completed if that executable had been launched;
- all C invocations used the default `DRY_RUN_ONLY` mode;
- no receipt/evidence output path is accepted in dry-run mode, so the wrapper wrote no verification files and created no directory;
- historical caller path text was serialized only; it was not accessed, tested, normalized, created, or mutated.

## 6. Future B interface, not execution

After fresh independent C acceptance only, a separate B task can invoke the accepted wrapper contract with its own runtime identity gate, new task-owned evidence namespace, explicit activation token, `Writable=true`, and installed CLI default Sandbox destination by omitting `SandboxPath`. This result does not supply a B namespace or token and does not publish or execute B.

`C WRAPPER RECONSTRUCTION != SHARE RETRY`

`C ACCEPTANCE -> OWNER-PREAUTHORIZED B TASK PUBLICATION`

`B SHARE SUCCESS != DEP13 AUTHORIZATION`

## 7. Preserved state and negative attestations

Preserved exactly:

`FAILED_START_RESULT_NOT_CAPTURED`

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

- No operational `wsb share`, `wsb exec`, runtime `wsb list`, or other WSB process was invoked.
- No Sandbox or guest was accessed, observed, created, started, stopped, killed, reset, closed, connected to, or mutated.
- `continuation-v0-1` was not accessed, tested, cleared, reused, renamed, overwritten, repaired, or repurposed.
- No alternative operational path or syntax was tested. No B experiment namespace or fixed input was materialized.
- No DEP13, dependency acquisition, Gradle, M3, AAR, M2, B12, Android Studio, emulator, Backend, Database, PUI, product implementation, legal research, Safety Operations, telemetry, analytics, or participant work occurred.
- README and FD02 were not read. No broad repository, directory, cache, package, host, or path enumeration occurred.
- Protected staged/index state was not inspected, and `git status` was not run.
- This candidate does not accept itself, merge, publish B, or create share-retry authority.

## 8. Classification

`HOST WRAPPER RECONSTRUCTED — PROSPECTIVE ARGV/QUOTING CONTRACT ESTABLISHED — READY FOR INDEPENDENT C ACCEPTANCE`
