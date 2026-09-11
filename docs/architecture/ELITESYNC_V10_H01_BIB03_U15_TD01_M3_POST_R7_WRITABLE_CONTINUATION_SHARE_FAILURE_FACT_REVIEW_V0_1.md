# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 Writable Continuation Share Failure Fact Review｜v0.1

Status: `WRITABLE SHARE FAILURE PARTLY/NOT EXPLAINED — CORRECTED SHARE CONTRACT NOT YET AUTHORABLE — AWAITING INDEPENDENT ACCEPTANCE`

Date: 2026-09-11 (Asia/Singapore)

## 1. Authority and bounded role

- fresh-fetched `main`: `aa113484987a6e2377950e7a3acd3639d61ea639`
- `main` sole parent: `c5b816eed67bc59f46dd0cd7bec430af757686ee`
- `main` tree: `5361084e4fb1b0e30adb7f84ca57858a9c6ea24f`
- task publication-base tree: `9b338fc276bdfdc19b381757f773d6c142fcecdf`
- FIRST path: `docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`
- FIRST blob: `3aa2ead4cf1084b202b67856075c26ab80b0c9a2`
- task path: `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_WRITABLE_CONTINUATION_SHARE_FAILURE_FACT_REVIEW_TASK_V0_1.md`
- task blob: `fa7b234d99d5caa525416b5f967d1e831330a49d`

FIRST was blob-verified and read before the task sheet. This candidate is a fact/review artifact only. It does not accept itself and creates no share-retry, recovery-continuation, DEP13, B12, M3, AAR, or M2 authority.

## 2. Installed `wsb.exe` identity and help-only evidence

Normal command resolution returned:

- resolved executable: `C:\Users\zcxve\AppData\Local\Microsoft\WindowsApps\wsb.exe`
- file-version metadata at the resolved WindowsApps alias: `FileVersion=null`, `ProductVersion=null`, `ProductName=null`, `CompanyName=null`

The installed-build identity is therefore based on the executable's own version output, not invented file metadata.

| Help-only command | Exit | stdout | stderr |
|---|---:|---|---|
| `C:\Users\zcxve\AppData\Local\Microsoft\WindowsApps\wsb.exe --version` | 0 | `0.8.107.0` | empty |
| `C:\Users\zcxve\AppData\Local\Microsoft\WindowsApps\wsb.exe --help` | 0 | `Usage: wsb [command] [options]`; global `--raw`; commands include `ShareFolder, share` | empty |
| `C:\Users\zcxve\AppData\Local\Microsoft\WindowsApps\wsb.exe share --help` | 0 | `Usage: wsb ShareFolder [options]`; options shown below | empty |

Exact `share --help` option text exposed by installed version `0.8.107.0`:

```text
--id <id> (REQUIRED)                    Windows 沙盒环境的 ID。
-f, --host-path <host-path> (REQUIRED)  将从主机共享的文件夹的路径。
-s, --sandbox-path <sandbox-path>       文件夹将放置在 Windows 沙盒内的路径。
-w, --allow-write                       如果为 true，则允许 Windows 沙盒环境写入共享文件夹。 [default: False]
--raw                                   以 JSON 格式设置所有输出的格式。
-?, -h, --help                          Show help and usage information
```

Exact captured streams (line endings rendered as ordinary Markdown newlines):

```text
COMMAND: C:\Users\zcxve\AppData\Local\Microsoft\WindowsApps\wsb.exe --version
EXIT: 0
STDOUT:
0.8.107.0
STDERR:
<empty>
```

```text
COMMAND: C:\Users\zcxve\AppData\Local\Microsoft\WindowsApps\wsb.exe --help
EXIT: 0
STDOUT:
Description:
  Windows 沙盒命令行接口 (CLI)

Usage:
  wsb [command] [options]

Options:
  --raw           以 JSON 格式设置所有输出的格式。
  -?, -h, --help  Show help and usage information
  --version       Show version information

Commands:
  StartSandbox, start         启动 Windows 沙盒的实例。
  ListRunningSandboxes, list  列出所有正在运行的 Windows 沙盒环境的 ID。
  Execute, exec               在正在运行的 Windows 沙盒环境中执行命令。
  ShareFolder, share          将文件夹从主机共享到 Windows 沙盒会话。
  StopSandbox, stop           终止正在运行的 Windows 沙盒。
  ConnectToSandbox, connect   为 Windows 沙盒环境启动远程会话。
  GetIpAddress, ip            获取 Windows 沙盒环境的 IP 地址。
STDERR:
<empty>
```

```text
COMMAND: C:\Users\zcxve\AppData\Local\Microsoft\WindowsApps\wsb.exe share --help
EXIT: 0
STDOUT:
Description:
  将文件夹从主机共享到 Windows 沙盒会话。

Usage:
  wsb ShareFolder [options]

Options:
  --id <id> (REQUIRED)                    Windows 沙盒环境的 ID。
  -f, --host-path <host-path> (REQUIRED)  将从主机共享的文件夹的路径。
  -s, --sandbox-path <sandbox-path>       文件夹将放置在 Windows 沙盒内的路径。
  -w, --allow-write                       如果为 true，则允许 Windows 沙盒环境写入共享文件夹。 [default: False]
  --raw                                   以 JSON 格式设置所有输出的格式。
  -?, -h, --help                          Show help and usage information
STDERR:
<empty>
```

No help-only command included a real Sandbox ID or host/guest path. No operational `wsb` command was run.

## 3. Preserved evidence identities

The following exact files were hash-verified before their content was relied upon:

| Exact preserved file | SHA-256 | Identity |
|---|---|---|
| `share-results.json` | `76647607581F9F2AC45E0721D8FC25AE551DDD8960632E64F2933CB6BB8F90DB` | PASS |
| `continuation-result.json` | `8566F385CECB8F134096ACE7A02F2DD718FC461D84D7620D89CC9C507893D3AF` | PASS |
| `continuation-summary.json` | `FD180FF19DFEDEC6DEA369F313CAFBA70DB553FB7D05CD44B0CB5A09E37C6A68` | PASS |
| `continuation-recovery.ps1` | `8B91B1762183B5A87629BD172ADDB380AB6239BA1DD9D310115A416DC553B97B` | PASS |

All are under the single authorized preserved namespace `C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71/continuation-v0-1`. No sibling enumeration or modification occurred.

## 4. Accepted mapping facts and recovered argv

The accepted failed intent/mapping facts remain:

- host path: `C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71/continuation-v0-1`
- sandbox path: `C:/M3A/transport/continuation-v0-1`
- writable intent: `--allow-write`
- Sandbox ID: `7ebc163d-7e92-4a63-8218-47c03d5db697`
- exit: `-2147024809`
- raw output: `Value does not fall within the expected range.`

Separately, `share-results.json` recovers this exact ordered argv token array:

```text
share
--id
7ebc163d-7e92-4a63-8218-47c03d5db697
--host-path
C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71/continuation-v0-1
--sandbox-path
C:/M3A/transport/continuation-v0-1
--allow-write
--raw
```

This proves the recorded argv values and order. The authorized evidence does not contain the host-side process-launch wrapper, so shell quoting/escaping mechanics beyond the recorded discrete argv tokens are `NOT PROVEN`; they are not silently normalized here. `continuation-recovery.ps1` is the never-executed guest script and does not construct the host-side share command.

## 5. Parameter and precondition comparison

| Parameter/condition | Installed-help fact | Preserved failed-command fact | Match / mismatch / unknown | Invalid-argument explanation | Confidence |
|---|---|---|---|---|---|
| subcommand | `ShareFolder, share` is exposed; help invoked through `share` | first argv token is `share` | MATCH | Cannot explain rejection | PROVEN |
| `--id` | required; value placeholder is only `<id>` | expected rebound ID supplied as one token; prior accepted runtime identity gate matched it | MATCH at required-presence and accepted-identity level; lexical grammar otherwise UNKNOWN | No documented lexical defect is established | PROVEN for presence/value identity; NOT PROVEN for complete lexical rules |
| `--host-path` | required; described as path of folder shared from host | exact existing continuation namespace supplied as one token; exact evidence files were read beneath it | MATCH for presence and directory existence; slash/normalization and other constraints UNKNOWN | No documented defect established | PROVEN for presence/existence; NOT PROVEN for accepted path grammar or other constraints |
| `--sandbox-path` | optional; described only as where the folder will be placed inside Sandbox | `C:/M3A/transport/continuation-v0-1` supplied as one token | MATCH for option presence; path grammar, drive/root rules, parent/target existence semantics UNKNOWN | A path/precondition rejection is plausible but not attributable | NOT PROVEN |
| `--allow-write` | supported switch; true permits Sandbox writes; default false | supplied after `--sandbox-path` value | MATCH at exposed flag level | No writable-specific path precondition is documented by help | PROVEN for flag availability; NOT PROVEN for additional preconditions |
| `--raw` | global and share option; formats output as JSON | final argv token is `--raw`; returned text was not JSON | MATCH at exposed flag level; reason for non-JSON failure text UNKNOWN | No unsupported-combination fact established | PROVEN for availability; NOT PROVEN for failure-path formatting semantics |
| option order | usage is `wsb ShareFolder [options]`; no ordering constraint stated | exact order recovered above | UNKNOWN | Cannot attribute rejection to order | NOT PROVEN |
| additional required parameter | help marks only `--id` and `--host-path` required | both are present | MATCH; none shown missing | Missing-required-parameter explanation is not supported | PROVEN within installed help |
| mutually exclusive/unsupported combination | help exposes all five options and states no exclusions | `--id`, `--host-path`, `--sandbox-path`, `--allow-write`, `--raw` combined | UNKNOWN beyond absence of documented exclusion | Cannot attribute rejection to combination | NOT PROVEN |
| Sandbox state | share help gives no state precondition | accepted evidence says the prior runtime identity gate passed for exactly one matching running Sandbox | MATCH with prior accepted state; no fresh observation authorized | Does not explain invalid argument | PROVEN as accepted historical evidence; NOT APPLICABLE as fresh runtime evidence |

## 6. Causal conclusion

The installed help and preserved argv rule out several superficial explanations: the `share` alias exists; both displayed required options were supplied; `--sandbox-path`, `--allow-write`, and `--raw` are exposed for `share`; and no additional required option or explicit mutual exclusion is shown.

They do not identify which input or undocumented precondition caused `WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.` The error is therefore **not causally explained from authorized evidence**. It cannot be upgraded to a specific path-format, parent-existence, writable-mode, ordering, quoting, or ID-format diagnosis merely because one is plausible.

## 7. Corrected-contract authorability

Decision:

`CORRECTED_SHARE_CONTRACT_NOT_YET_AUTHORABLE — MISSING FACTS`

Exact material missing facts are:

1. the installed build's accepted `--sandbox-path` grammar, including drive/root form and whether forward-slash form is valid;
2. the installed build's guest parent/target existence requirements and whether `C:/M3A/transport/continuation-v0-1` violated one;
3. any writable-share-specific guest-path or parent/root precondition imposed when `--allow-write` is present;
4. the installed build's complete `--host-path` grammar/normalization constraints beyond “folder path,” including whether the recorded forward-slash form is accepted;
5. whether the installed build imposes an option-order or combination constraint not surfaced by `share --help`;
6. the exact host-side invocation/quoting construction beyond the preserved argv token array, if that construction can materially affect parsing.

Without these facts, selecting a new guest path, changing slashes, creating a parent, changing option order, removing `--raw`, or altering writable syntax would be invention or trial-and-error. No corrected invocation is proposed.

Any future contract must preserve `continuation-v0-1` as evidence, bind the exact authorized Sandbox ID, use a separately authorized fresh continuation namespace and receipt contract, and fail closed. Even after independent acceptance, this review alone does not authorize a retry.

## 8. Preserved state and negative attestations

- Original launcher contract remains `FAILED_START_RESULT_NOT_CAPTURED`.
- Accepted blocker remains `WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`
- Existing Sandbox remains quarantined; no runtime observation was performed.
- No operational `wsb share`, `wsb exec`, `wsb start`, `wsb list`, `wsb stop`, reset, kill, close, or other Sandbox mutation/access occurred.
- No guest access, share retry/substitution, second Sandbox, `guest.bound.json`, namespace reuse/modification, materialization, DEP13, Maven/source acquisition, Gradle, M3, AAR, or M2 occurred.
- README and FD02 were not read. No broad host/repository/cache/path enumeration and no protected staged/index inspection occurred.
- The four exact preserved files were read only and were not executed or modified.
- No acceptance, merge, main update, retry task, or downstream execution task is included.

## 9. Final classification

`WRITABLE SHARE FAILURE PARTLY/NOT EXPLAINED — CORRECTED SHARE CONTRACT NOT YET AUTHORABLE — AWAITING INDEPENDENT ACCEPTANCE`

`FACT REVIEW SUCCESS != SHARE RETRY SUCCESS`

`CORRECTED CONTRACT AUTHORABLE != RETRY AUTHORIZED`

`REBOUND SANDBOX IDENTITY PASS != ORIGINAL LAUNCHER CONTRACT PASS`

`DEP13 REMAINS BLOCKED`
