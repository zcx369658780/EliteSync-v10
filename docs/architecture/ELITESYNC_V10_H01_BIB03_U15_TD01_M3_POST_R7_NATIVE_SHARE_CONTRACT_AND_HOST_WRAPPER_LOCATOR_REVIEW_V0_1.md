# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 Native Share Contract + Host Wrapper Locator Review｜v0.1

Status: `WRITABLE SHARE FAILURE REMAINS PARTLY/NOT EXPLAINED — CORRECTED SHARE CONTRACT NOT YET AUTHORABLE — AWAITING INDEPENDENT ACCEPTANCE`

Date: 2026-09-11 (Asia/Singapore)

## 1. Authority and bounded role

- Owner-reissued and fresh-fetched `main`: `192acbce453cbd39ad7a192636ab4b25bc388c39`
- `main` sole parent: `91bb6a6b3cfba084e068c6102370d5d39c465dfa`
- `main` tree: `5575b99ffb70032f6da708f21f8c6df1ea7577b1`
- FIRST path: `docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`
- FIRST blob: `3aa2ead4cf1084b202b67856075c26ab80b0c9a2`
- task path: `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_NATIVE_SHARE_CONTRACT_AND_HOST_WRAPPER_LOCATOR_REVIEW_TASK_V0_1.md`
- task blob: `b7146e8ed30335f29bb659b249870fa81300169d`
- accepted missing-fact acceptance blob: `4dff36eeb94b3b3d4da895f795608042dee8d9e5`
- accepted missing-fact result blob: `da07e0337dd100015cee5b013dcaa9b4714f47d4`

The task records `91bb6a6b3cfba084e068c6102370d5d39c465dfa` as its original publication-base. The Owner explicitly reissued it in this session with required `main` `192acbce453cbd39ad7a192636ab4b25bc388c39`; that commit is the sole child of the recorded base and contains the required task blob. FIRST was blob-verified and read before the task sheet. This artifact is a fact/locator review only.

## 2. Accepted baseline

The following accepted results are not reopened:

- installed package: `MicrosoftWindows.WindowsSandbox_0.8.107.0_x64__cw5n1h2txyewy`;
- package-owned `SandboxUDK.dll` SHA-256: `664805E33E8C931571C744235A849567242EF33D8943DE237D4B6F025A2585CE`;
- the managed CLI/server chain forwards supplied rooted host and Sandbox path strings to `WindowsUdk.Security.Isolation.ManagedWindowsVM.ShareFolder` without slash normalization;
- no WSB-managed custom option-order, mutual-exclusion, or combination cause is present;
- host folder existence and the ability to use an existing or new Sandbox target are already constrained by accepted Microsoft Learn evidence;
- five native/wrapper gaps remain.

Preserved immutable state:

`FAILED_START_RESULT_NOT_CAPTURED`

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

## 3. Microsoft-controlled native-contract evidence

### 3.1 Exact installed Microsoft package projection

Narrow static metadata inspection was limited to the already accepted exact file:

`C:\Program Files\WindowsApps\MicrosoftWindows.WindowsSandbox_0.8.107.0_x64__cw5n1h2txyewy\SandboxUDK.dll`

The public projected surface exposes:

```text
IManagedWindowsVM.ShareFolder(
  runningReference,
  hostFolder,
  guestFolder,
  options)

VMShareFolderOptions.AllowWrite
VMShareFolderResult.ExtendedError
VMShareFolderResult.Status
```

`VMShareFolderStatus` contains these exact values:

| Value | Name |
|---:|---|
| 0 | `Success` |
| 1 | `UnknownFailure` |
| 2 | `HostFolderNotFound` |
| 3 | `GuestFolderAlreadyMapped` |
| 4 | `AccessDenied` |

The exact projection contains no path grammar, separator rule, parent-creation rule, writable-path prerequisite, or `E_INVALIDARG` condition. Its bounded static strings expose only identifiers/status names such as `hostFolder`, `guestFolder`, `AllowWrite`, `HostFolderNotFound`, and `GuestFolderAlreadyMapped`; there is no hidden descriptive contract text. This is `INSTALLED_IMPL` evidence exact for package `0.8.107.0`, but it is an ABI projection, not the native implementation contract.

### 3.2 Official Microsoft documentation

Retrieved 2026-09-11:

1. Microsoft Learn, [Windows Sandbox command line](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-cli), `document_id=459e3ffb-cbd8-3559-bb5b-486348778daa`, content revision `b34d3f8baadc0a6e220399a86b5a9a4e1a12cc58`, updated 2025-01-24. It documents the public CLI and gives backslash-form examples, but does not document the native `IManagedWindowsVM.ShareFolder` separator, parent-chain, writable-native, or `E_INVALIDARG` rules. The examples are not converted into normative rejection rules.
2. Microsoft Learn, [Use and configure Windows Sandbox](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-configure-using-wsb-file), `document_id=5ce6b999-ce30-3703-b451-ebabaea28f58`, content revision `a26bdad60957d0138e975a89194aa028a860b0ac`, updated 2026-03-31. It states that the host folder must exist, the Sandbox folder is absolute, and a missing Sandbox target is created. It does not state whether every missing intermediate parent is created or define native separator acceptance.
3. Microsoft Learn, [Error Handling Strategies](https://learn.microsoft.com/en-us/windows/win32/com/error-handling-strategies), `document_id=c0c9e713-369d-e0ec-7e7e-8c6619c2db7b`, content revision `3e02cb24a30f316c0a31c934a25a6c977449bded`, updated 2025-03-11. It defines `E_INVALIDARG` / `0x80070057` only as “One or more arguments are invalid.” It does not identify which `ShareFolder` argument or precondition failed.

The first two sources are `MICROSOFT_NORMATIVE` for their published Windows Sandbox surfaces but are not version-mapped native UDK contracts. The third is a generic `MICROSOFT_NORMATIVE` HRESULT definition and is non-causal by itself.

### 3.3 Exact Microsoft source searches and availability result

On 2026-09-11, bounded exact-identifier searches were made through Microsoft Learn search and GitHub's Microsoft-organization issue/commit search for:

- `IManagedWindowsVM.ShareFolder`;
- `ManagedWindowsVM.ShareFolder`;
- `VMShareFolderOptions.AllowWrite` / `VMShareFolderOptions`;
- `WindowsUdk.Security.Isolation`;
- Windows Sandbox `ShareFolder` plus `E_INVALIDARG`.

Microsoft Learn returned no documentation page for the `WindowsUdk.Security.Isolation` interface or its native error conditions. Results for similarly named deprecated `Windows.Security.Isolation.IsolatedWindowsEnvironment*` APIs are a different namespace/contract and were not used to transfer semantics. Exact Microsoft-organization GitHub issue and commit searches returned zero matches for the four native identifiers.

This is a bounded availability result, not proof that no nonpublic Microsoft implementation exists. No official public source/revision establishing the three native path/precondition questions was found within the authorized search. Classification:

`NATIVE_SHARE_CONTRACT_PUBLIC_SOURCE_NOT_ESTABLISHED`

No unofficial material is used as evidence.

## 4. Host-wrapper locator search

The narrow search ran against exact current authority `192acbce453cbd39ad7a192636ab4b25bc388c39`, excluding README and FD02, with only these authorized anchors:

1. `7ebc163d-7e92-4a63-8218-47c03d5db697`;
2. `EliteSync-v10-M3A-RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71`;
3. `continuation-v0-1`;
4. `WRITABLE_CONTINUATION_SHARE_FAILED`;
5. the exact accepted host path;
6. `C:/M3A/transport/continuation-v0-1`;
7. exact `wsb share` / `--host-path` / `--sandbox-path` text only in the unique-anchor context.

Result:

- every match was under `docs/architecture/*.md`;
- zero script/controller/source path matched;
- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_RECOVERY_CONTINUATION_SCOPE_DECISION_RESULT_V0_1.md`, blob `ff6ccebf36e60244dcf334893f45f63e445d937c`, contains the specified one-line command but is a governance contract, not the process constructor;
- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_EXISTING_SANDBOX_RECOVERY_CONTINUATION_EXECUTION_RESULT_V0_1.md`, blob `62f66a503738c166c28659feab8744e820441f39`, records the mapping, exit and stop condition but exposes no wrapper path or launch primitive;
- no exact current-project file establishes whether invocation used a shell command string, PowerShell call operator/splatting, `Start-Process`, `ProcessStartInfo.ArgumentList`, or another primitive.

Therefore:

`HOST_WRAPPER_NOT_UNIQUELY_LOCATED — ZERO SCRIPT/CONTROLLER MATCHES`

No directory browsing, generalized keyword search, commit archaeology, historical branch search, or follow-on locator inference occurred.

## 5. Five-gap evidence matrix

| Fact sought | Exact evidence | Source class | Installed-version applicability | Classification | Causal explanation of accepted `E_INVALIDARG` |
|---|---|---|---|---|---|
| 1. native Sandbox-path spelling, especially `C:/...` | installed projection names `guestFolder` and forwards the string; Microsoft Sandbox docs require an absolute target and show backslash examples; no native separator rule was published/found | `INSTALLED_IMPL`, `MICROSOFT_NORMATIVE`, `EXAMPLE` | projection exact for `0.8.107.0`; docs not native-version-mapped | `CONSTRAINED BUT NOT PROVEN` | Forward-slash rejection remains plausible but unproven |
| 2. nested new target with missing intermediate parents | official docs say a missing Sandbox target is created; projection/status metadata contains no parent-chain status or rule | `MICROSOFT_NORMATIVE`, `INSTALLED_IMPL` | official mapped-folder semantics, not exact native parent algorithm | `CONSTRAINED BUT NOT PROVEN` | Target absence alone is not a defect; missing-parent rejection remains unproven |
| 3. native writable-specific path/root/parent prerequisite | exact projection exposes only `VMShareFolderOptions.AllowWrite`; no relevant native contract/source was found | `INSTALLED_IMPL` | exact public projection for `0.8.107.0`; native implementation unavailable | `NOT PROVEN` | No specific writable-native violation can be matched |
| 4. native acceptance/canonicalization of rooted forward-slash host path | exact projection takes `hostFolder`; accepted managed chain forwards the rooted value unchanged; official docs require an existing host folder but do not define separator handling | `INSTALLED_IMPL`, `MICROSOFT_NORMATIVE` | exact to native boundary for `0.8.107.0`; native parser unknown | `CONSTRAINED BUT NOT PROVEN` | Recorded host existed; spelling rejection remains plausible but unproven |
| 5. exact host process-launch/quoting construction | exact authorized anchor search found only governance/result documents and zero script/controller paths | `HOST_WRAPPER` availability result | exact current repository authority | `NOT PROVEN` | Shell mediation, quoting and last-mile argv materiality cannot be established or eliminated |

## 6. Causal conclusion

The accepted result converts `-2147024809` to the generic `E_INVALIDARG` meaning, but authorized Microsoft material does not bind that HRESULT to a particular `ShareFolder` argument or state. The projected result/status surface does not supply an `InvalidPath` or `InvalidParent` status, and `ExtendedError` remains generic. No native path separator, intermediate-parent, or writable-specific contract is public in the evidence found. The repository anchor search supplies no host wrapper with which to eliminate quoting or launch-primitive effects.

Therefore:

`WRITABLE_SHARE_FAILURE_NOT_CAUSALLY_EXPLAINED_FROM_AUTHORIZED_EVIDENCE`

No forward-slash, backslash, missing-parent, writable, or quoting hypothesis is promoted to fact.

## 7. Corrected-contract authorability

Decision:

`CORRECTED_SHARE_CONTRACT_NOT_YET_AUTHORABLE — MISSING FACTS`

Exact remaining external/material gaps:

1. Microsoft native UDK contract or implementation evidence defining accepted `guestFolder` separator/root syntax for installed behavior;
2. Microsoft native UDK evidence defining creation behavior when intermediate guest parents are absent;
3. Microsoft native UDK evidence defining any writable-specific guest-path/root/parent requirement beyond `AllowWrite`;
4. Microsoft native UDK evidence defining accepted/canonicalized rooted `hostFolder` forward-slash syntax;
5. the actual host wrapper/process-launch construction, which is not present under any authorized current-project anchor.

These gaps cannot be filled by ordinary Win32 assumptions, examples, a similarly named deprecated API, or experimental path substitution. No corrected invocation is authored.

## 8. Preserved state and negative attestations

- `FAILED_START_RESULT_NOT_CAPTURED` remains unchanged.
- `WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.` remains the accepted blocker.
- No operational `wsb share`, `wsb exec`, runtime `wsb list`, alternative syntax/path probe, retry, or substitute mapping occurred.
- No guest or Sandbox was accessed, observed operationally, created, started, stopped, killed, reset, closed, or mutated.
- `continuation-v0-1` was not accessed, cleared, reused, renamed, overwritten, repaired, or repurposed.
- No DEP13, Maven/source acquisition, dependency work, Gradle, M3, AAR, M2, B12, implementation, LC-03, LC-04, Phase36, Backend, Database, or PUI work occurred.
- README and FD02 were not read. No broad repository, branch-history, directory, package, host, cache, or path enumeration occurred.
- No protected staged/index state was inspected and no `git status` was run.
- No script/controller was executed or edited. No share/recovery implementation was patched.
- No unofficial source, forum, Q&A answer, blog, tutorial, mirror, or AI summary was used as evidence. No broad native reverse engineering occurred.
- This candidate does not accept itself, merge, update `main`, retry the share, or publish a continuation execution task.

## 9. Final classification

`WRITABLE SHARE FAILURE REMAINS PARTLY/NOT EXPLAINED — CORRECTED SHARE CONTRACT NOT YET AUTHORABLE — AWAITING INDEPENDENT ACCEPTANCE`

`NATIVE-CONTRACT REVIEW != SHARE RETRY`

`HOST-WRAPPER LOCATED != RETRY AUTHORIZED`

`CONTRACT AUTHORABLE != RETRY AUTHORIZED`

`UNPUBLISHED NATIVE CONTRACT != LICENSE TO EXPERIMENT`

`DEP13 REMAINS BLOCKED`
