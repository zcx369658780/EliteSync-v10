# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 One-Shot Writable Share Controlled Experiment Result｜v0.4

Status: `ONE-SHOT DEFAULT-DESTINATION WRITABLE SHARE SUCCEEDED — AWAITING INDEPENDENT B ACCEPTANCE — NO DEP13 AUTHORITY`

Date: 2026-09-11 (Asia/Singapore)

## 1. Authority and startup gates

- repository: `zcx369658780/EliteSync-v10`;
- fresh-fetched `main`: `38b27398b26f1f406b339a0ccd1b1dc50250c0f2` — `PASS`;
- FIRST handoff blob: `3aa2ead4cf1084b202b67856075c26ab80b0c9a2` — `PASS`;
- controlling v0.5 task blob: `443c6d888aca61d63b1b789d5b6c9df9c42b1e21` — `PASS`;
- controlling B R3 acceptance blob: `bc9b8759a5ebc3f83b611bdaafa24a201a482aaf` — read;
- dedicated candidate branch: `review/h01-bib03-u15-td01-m3-post-r7-one-shot-writable-share-controlled-experiment-v0-4`.

The accepted operational share count before this task was `0/1`.

## 2. Current-main wrapper identity

Wrapper path used directly and read-only:

`D:\EliteSync-v10-b-one-shot-share-v0-4\tools\recovery\Invoke-EliteSyncWsbShare.ps1`

Git-semantic gates:

- current-main tree blob: `b3a751e18d713c98b56d66972d501292544a847f` — `PASS`;
- `git hash-object --path=tools/recovery/Invoke-EliteSyncWsbShare.ps1 tools/recovery/Invoke-EliteSyncWsbShare.ps1`: `b3a751e18d713c98b56d66972d501292544a847f` — `PASS`.

Non-gating raw checkout evidence:

- raw SHA-256: `E2B6B98E77789C68381A2C06057D37836073E6C6A63EB7F18C0DEC31DF7E7000`;
- LF count: `277`;
- CRLF count: `277`;
- accepted LF-content provenance SHA-256: `2776034B4BD42FA5D25EB2997B59EDEE5AEFF3668C567788BBCB3CF222A3BE64`.

The wrapper was not copied, normalized, rewritten, patched, regenerated, merged, cherry-picked, or rematerialized.

## 3. Fresh B R4 host root

- nonce: `5b21067adecf449f82ea9fb842fa91eb`;
- root: `C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-M3B-WSB-SHARE-R4-5b21067adecf449f82ea9fb842fa91eb`;
- evidence directory: `C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-M3B-WSB-SHARE-R4-5b21067adecf449f82ea9fb842fa91eb\evidence`.

The root was created once from a fresh GUID nonce outside the repository. It does not reuse or modify any earlier B root or historical `continuation-v0-1`. Only the pre-existing `evidence/` directory and bounded host controller/receipt files were created. No guest directory was created.

Host controller evidence:

- `controller-preconditions.json` SHA-256: `FC90E75B4D9F793588F2F8BD5BAC6859702295F417085FBC3F0CF7AA8EBA5F06`;
- `Invoke-B-R4-OneShot.ps1` SHA-256: `85FE372FDA8D54B7E8517DD4DA8A6942980687574E0C41FE0418E35F0E3BDB55`.

## 4. Installed WSB identity gate

- normal command-resolution path: `C:\Users\zcxve\AppData\Local\Microsoft\WindowsApps\wsb.exe`;
- `--version` exit: `0`;
- exact version output: `0.8.107.0`;
- package count for exact package query: `1`;
- package full name: `MicrosoftWindows.WindowsSandbox_0.8.107.0_x64__cw5n1h2txyewy`;
- package install location: `C:\Program Files\WindowsApps\MicrosoftWindows.WindowsSandbox_0.8.107.0_x64__cw5n1h2txyewy`;
- gate: `PASS`;
- `wsb-identity.json` SHA-256: `576F962ABB846E2DA80D0D7EEFAF6E14EFBC885B0EE791FA40D013338A3F578F`.

## 5. Single runtime identity observation

Exactly one direct invocation of `wsb list --raw` was performed.

- exit code: `0`;
- stderr: empty;
- parsed running Sandbox count: `1`;
- sole ID: `7ebc163d-7e92-4a63-8218-47c03d5db697`;
- expected-ID match: `true`;
- gate: `PASS`.

Exact raw stdout:

```json
{
  "WindowsSandboxEnvironments": [
    {
      "Id": "7ebc163d-7e92-4a63-8218-47c03d5db697"
    }
  ]
}
```

Evidence:

- `runtime-list-stdout.txt` SHA-256: `7EDFB59307E755589EF0AEF6FDD1318F1B9C177FBF651964CDB1BE71A35CC748`;
- `runtime-list-stderr.txt` SHA-256: `E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855`;
- `runtime-identity.json` SHA-256: `B99A24C0FE6C355B52E8C9B38250EC26C7A9662D1639F8513A01F6199E212875`.

No second or post-result runtime observation occurred.

## 6. Exact one-shot operational invocation

The accepted current-main wrapper was invoked exactly once in `OPERATIONAL` mode with:

- `WsbExePath`: `C:\Users\zcxve\AppData\Local\Microsoft\WindowsApps\wsb.exe`;
- `SandboxId`: `7ebc163d-7e92-4a63-8218-47c03d5db697`;
- `HostPath`: `C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-M3B-WSB-SHARE-R4-5b21067adecf449f82ea9fb842fa91eb`;
- `SandboxPath`: **OMITTED ENTIRELY**;
- `Writable`: `$true`;
- `RawOutput`: `$true`;
- `ExecutionMode`: `OPERATIONAL`;
- `EvidenceDirectory`: `C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-M3B-WSB-SHARE-R4-5b21067adecf449f82ea9fb842fa91eb\evidence`.

A fresh 256-bit activation token was generated inside the dedicated controller process, set only in that process's `ELITESYNC_WSB_SHARE_ACTIVATION_TOKEN`, passed to the wrapper, never printed or persisted, and ceased to exist when that process completed.

Decoded argv receipt:

```text
share
--id
7ebc163d-7e92-4a63-8218-47c03d5db697
--host-path
C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-M3B-WSB-SHARE-R4-5b21067adecf449f82ea9fb842fa91eb
--allow-write
--raw
```

The ordered argv has seven tokens and contains no `--sandbox-path` token or Sandbox destination value.

## 7. One-shot share result and evidence

Result:

- operational wrapper calls: `1`;
- operational `wsb share` launches: `1/1`;
- exact process exit code: `0`;
- stdout: empty;
- stderr: empty;
- outcome: `ONE_SHOT_SHARE_SUCCESS`.

Wrapper evidence:

| File | SHA-256 | Bytes |
|---|---|---:|
| `wsb-share-argv-receipt.json` | `124E7BF871521F0C1AD5C4FF836AA37D69421CCBBF38BDE4C491889F474467DB` | 451 |
| `wsb-share-stdout.txt` | `E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855` | 0 |
| `wsb-share-stderr.txt` | `E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855` | 0 |
| `wsb-share-result.json` | `53683A6E69B219480907EDB3BD5E761B272C260A3C34FDDA06951C2C645DE720` | 205 |

`wsb-share-result.json` records schema `elitesync.wsb-share.process-result.v1`, exit code `0`, and the exact receipt/stdout/stderr filenames.

`ONE_SHOT_SHARE_SUCCESS != FIXED_GUEST_RECOVERY_CONTINUATION_SUCCESS`

No guest mapping location or guest-side writability was inspected, so those facts remain outside this result.

## 8. Mandatory stop and preserved state

All Sandbox activity stopped immediately after the single share result. No retry, second wrapper call, second share, or post-result `wsb list` occurred.

Remain exactly:

`FAILED_START_RESULT_NOT_CAPTURED`

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

All previous B roots and historical `continuation-v0-1` remain preserved evidence and were not read, repaired, reused, cleared, renamed, overwritten, or repurposed.

## 9. Negative attestations

- No `wsb exec` or guest filesystem/state access occurred.
- No default guest mapping location or guest writability was inspected or tested.
- No Sandbox was created, started, stopped, killed, reset, closed, connected to, or otherwise mutated beyond the single authorized host-folder share.
- No alternative mapping, retry, second share, or post-result Sandbox observation occurred.
- No fixed input, recovery continuation, DEP13, dependency acquisition, Gradle, M3, AAR, M2, B12, Android Studio, or emulator work occurred.
- README and FD02 were not read. No broad repository, cache, host, package, or path enumeration occurred.
- Protected staged/index state was not inspected, and `git status` was not run.
- No activation token value appears in repository files, result documentation, controller source, or evidence receipts.
- This result does not self-accept, merge, run continuation, or publish a downstream task.

## 10. Classification

`ONE-SHOT DEFAULT-DESTINATION WRITABLE SHARE SUCCEEDED — AWAITING INDEPENDENT B ACCEPTANCE — NO DEP13 AUTHORITY`

`B R4 = SAME OWNER-AUTHORIZED ONE-SHOT EXPERIMENT`

`PRIOR OPERATIONAL SHARE COUNT = 0`

`CURRENT OPERATIONAL SHARE COUNT = 1/1`

`B SUCCESS != FIXED_GUEST RECOVERY CONTINUATION SUCCESS`

`B SUCCESS != DEP13 AUTHORITY`
