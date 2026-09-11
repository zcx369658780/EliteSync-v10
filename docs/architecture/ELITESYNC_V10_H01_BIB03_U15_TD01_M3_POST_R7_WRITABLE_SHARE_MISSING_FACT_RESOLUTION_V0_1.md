# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 Writable Share Missing-Fact Resolution｜v0.1

Status: `WRITABLE SHARE FAILURE REMAINS PARTLY/NOT EXPLAINED — CORRECTED SHARE CONTRACT NOT YET AUTHORABLE — AWAITING INDEPENDENT ACCEPTANCE`

Date: 2026-09-11 (Asia/Singapore)

## 1. Authority and bounded role

- Owner-reissued and fresh-fetched `main`: `74ab38a67ef5864108599db28c4d78d0bc836243`
- `main` sole parent: `e2a218511534b1e368cce623633413049a97b398`
- `main` tree: `768773e17585149ec197b76807069287f6e9ee4c`
- task publication-base tree: `b046f8a7d49b3253e68826fe5978475d2817b712`
- FIRST path: `docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`
- FIRST blob: `3aa2ead4cf1084b202b67856075c26ab80b0c9a2`
- task path: `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_WRITABLE_SHARE_MISSING_FACT_RESOLUTION_TASK_V0_1.md`
- task blob: `278338acfa708a162d314488724d7b579c78f320`
- accepted fact-review acceptance blob: `820017f597d546ce7b4161069ff6454e57e54f1b`
- accepted fact-review result blob: `a7f1db9a781c46e4a0d505a0ca1b22328a791ce3`

The task text records `e2a218511534b1e368cce623633413049a97b398` as its original publication-base. The Owner explicitly reissued the task in this session with required `main` `74ab38a67ef5864108599db28c4d78d0bc836243`; that commit is the sole child of the recorded publication-base and contains the required task blob. FIRST was blob-verified and read before the task sheet. This candidate resolves facts only and creates no share-retry or continuation authority.

## 2. Exact installed package identity

Normal command resolution returned the exact alias:

`C:\Users\zcxve\AppData\Local\Microsoft\WindowsApps\wsb.exe`

The alias is a zero-length Microsoft reparse point. Its exact reparse metadata identifies:

- package family: `MicrosoftWindows.WindowsSandbox_cw5n1h2txyewy`;
- application: `AppCli`;
- target: `C:\Program Files\WindowsApps\MicrosoftWindows.WindowsSandbox_0.8.107.0_x64__cw5n1h2txyewy\wsb.exe`.

An exact-name registration query for `MicrosoftWindows.WindowsSandbox` returned:

| Field | Value |
|---|---|
| package full name | `MicrosoftWindows.WindowsSandbox_0.8.107.0_x64__cw5n1h2txyewy` |
| family | `MicrosoftWindows.WindowsSandbox_cw5n1h2txyewy` |
| version | `0.8.107.0` |
| architecture | `X64` |
| publisher | `CN=Microsoft Windows, O=Microsoft Corporation, L=Redmond, S=Washington, C=US` |
| signature kind / registration status | `Store` / `Ok` |
| install location | `C:\Program Files\WindowsApps\MicrosoftWindows.WindowsSandbox_0.8.107.0_x64__cw5n1h2txyewy` |

The standard manifest at that exact location declares identity/version `MicrosoftWindows.WindowsSandbox` / `0.8.107.0`, and declares `Application Id="AppCli" Executable="wsb.exe" EntryPoint="SandboxCli.Program"` plus alias `wsb.exe`. This independently binds the previously accepted CLI-reported version `0.8.107.0` to the installed Store package.

## 3. Exact package-owned files inspected

No package directory was listed or recursively searched. Each file below was obtained from the exact registration/manifest entry or a direct managed assembly reference from an already identified file.

| Exact file | SHA-256 | Why inspection was authorized and material |
|---|---|---|
| `AppxManifest.xml` | `4A0901C7C34B97D56F217C865F53AC1B50E401088A90661544DCED9AE2CCF230` | standard manifest at the exact registered install location; binds identity, version, CLI entry and server entry |
| `wsb.exe` | `247E092B5C5BD37820F225A7DD3DDF10AE37A67E2751A19C24B802C84769C441` | manifest-declared CLI apphost; static strings directly identify adjacent `wsb.dll` |
| `wsb.dll` | `31092DF7168B08551B08D3EFB0497A08E34974E704F7C295A73E56BADA67084D` | CLI implementation; bounded PE/IL metadata for `Commands.MapFolderCommand`, `Commands.RootCommand`, `Handlers.MapHandler` and its state machine |
| `SandboxCommon.dll` | `0D7EA812D0211B139701A14B58157F87E367C993A0313637592F2F2B113392FE` | direct `wsb.dll` reference; bounded PE/IL metadata for `GrpcClient.MapFolderAsync` and `MappedFolder` path handling |
| `SandboxGrpc.dll` | `17D53E695D3362B2B5CA9040337BAD02E0AE2BA88FABBB4E49970AC5F5C4E0D6` | direct `wsb.dll`/server reference; bounded metadata confirmed the typed `MapFolderRequest` transport |
| `WindowsSandboxServer.exe` | `0EEA154EB84B6059B6EF86186E2CF1B22E9CD570519D654828E1EF17CCA2C428` | manifest-declared server apphost; static strings directly identify adjacent `WindowsSandboxServer.dll` |
| `WindowsSandboxServer.dll` | `37031110A901AFC1A6746CEB3D864D531EEFE5EAFC47B88B6B3EFFB098943551` | server implementation; bounded PE/IL metadata for `CoreService.MapFolder`, `SandboxVM.MapFolderAsync`, `MapFolderInternal`, and `GetDefaultMappedFolderPath` |
| `SandboxUDK.dll` | `664805E33E8C931571C744235A849567242EF33D8943DE237D4B6F025A2585CE` | direct server reference; bounded PE/IL metadata shows the final managed-to-WinRT `ManagedWindowsVM.ShareFolder` pass-through |

All seven binaries report file/product version `0.8.107.0` (product build suffix `9f17d2d096a2578121386fea1f35ce74d134f621` where exposed). The inspection used raw file metadata, strings, and narrowly selected managed method bodies only; no package binary or entry point was executed.

## 4. Installed-build implementation facts

The exact managed call chain is:

`System.CommandLine` → `SandboxCli.Handlers.MapHandler` → `SandboxCommon.Grpc.GrpcClient.MapFolderAsync` → `SandboxServer.Grpc.CoreService.MapFolder` → `SandboxServer.VM.SandboxVM.MapFolderAsync/MapFolderInternal` → `WindowsUdk.Security.Isolation.ManagedWindowsVM.ShareFolder`.

Bounded static metadata establishes:

1. `MapFolderCommand` registers `--host-path/-f` as required `ExactlyOne`, `--sandbox-path/-s` as optional `ZeroOrOne`, and `--allow-write/-w` as a Boolean with default `false`. It adds no validator or mutual-exclusion rule. `RootCommand` registers `--raw` as a global option.
2. `MapHandler` converts a missing sandbox path to `String.Empty` and otherwise forwards the parsed `Guid`, host path, sandbox path, and writable Boolean without changing their order or text.
3. `CoreService.MapFolder` parses the transported Sandbox ID with `Guid.Parse`, then forwards the three remaining request values to the exact Sandbox VM.
4. CLI `allowWrite=true` is converted to `MappedFolder.ReadOnly=false`. `MapFolderInternal` checks the mapped-folders policy and, for a writable mapping, the allow-write-to-mapped-folders policy; it then sets only `VMShareFolderOptions.AllowWrite`.
5. For the host path, `MappedFolder.GetFullHostPath` expands environment variables. If `Path.IsPathRooted` is false it calls `Path.GetFullPath(path, recipe.WorkingDirectory)`; if rooted it leaves the string unchanged. No managed existence, directory-kind, slash-normalization, or canonicalization check is present before the UDK call.
6. For the sandbox path, the CLI/server managed path performs no normalization or syntax validation. Empty/whitespace selects a default `C:\Users\<recipe user>\Desktop\<host leaf>`; a supplied value is forwarded unchanged.
7. The final `SandboxUDK.dll` method marshals the host and sandbox strings directly into the WinRT `IManagedWindowsVM.ShareFolder` ABI. The package-owned managed layer contains no further public contract for the native UDK path parser, parent creation, or writable-path restrictions.
8. A mapped-folders policy rejection, or a writable-mapped-folders policy rejection, follows the explicit `NS_E_FEATURE_DISABLED_BY_GROUP_POLICY` path. That is not the accepted `E_INVALIDARG`/`-2147024809` result, so the exposed managed policy gates do not causally explain the accepted failure.

These are implementation-derived installed-version facts. They do not upgrade undisclosed native UDK behavior into a documented contract.

## 5. Official Microsoft sources

Retrieved 2026-09-11:

1. Microsoft Learn, [Windows Sandbox command line](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-cli), page metadata `document_id=459e3ffb-cbd8-3559-bb5b-486348778daa`, content commit `b34d3f8baadc0a6e220399a86b5a9a4e1a12cc58`, updated 2025-01-24. This is official, version-unspecific CLI documentation applicable from Windows 11 version 24H2; it is not explicitly mapped to package `0.8.107.0`.
   - It states that `share` takes Sandbox ID, host path, and sandbox path; the host path should be a folder; the sandbox path can be an existing or a new folder; and `--allow-write` permits the Sandbox to write.
   - It labels `--sandbox-path` required, whereas installed `0.8.107.0` help and implementation make it optional. Installed-build evidence controls this local conflict.
   - Its example uses `C:\host\folder` and `C:\sandbox\folder`. That is an example, not a statement that forward slashes are rejected.
2. Microsoft Learn, [Use and configure Windows Sandbox](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-configure-using-wsb-file), page metadata `document_id=5ce6b999-ce30-3703-b451-ebabaea28f58`, content commit `a26bdad60957d0138e975a89194aa028a860b0ac`, updated 2026-03-31. This is official current mapped-folder configuration documentation, not a complete CLI grammar.
   - It states that `HostFolder` must already exist, `SandboxFolder` is an absolute path, a missing target is created, omission maps to the Sandbox user's desktop, and writable changes persist to the host.
   - The installed CLI is implementation-linked to the same `MappedFolder` model and `ManagedWindowsVM.ShareFolder` call, so these statements constrain mapped-folder semantics. They do not state accepted slash spelling or whether every missing intermediate guest parent is created.

No unofficial page, forum, Q&A answer, blog, mirror, tutorial, or AI summary is used as evidence.

## 6. Six-fact evidence matrix

| Fact sought | Source identity and exact evidence | Installed-version applicability | Classification | Can explain accepted invalid argument? |
|---|---|---|---|---|
| 1. `--sandbox-path` grammar, root/drive and slash form | installed `wsb.dll` accepts one string and forwards a supplied value unchanged; installed server uses an empty value only for its default path; official CLI/configuration docs require/described an absolute Sandbox path and show `C:\...`; no source states whether `C:/...` is accepted by the native UDK | managed behavior is exact for `0.8.107.0`; Microsoft Learn is version-unspecific | `CONSTRAINED BUT NOT PROVEN` | Yes, native rejection of the recorded forward-slash form remains plausible, but it is not proven |
| 2. guest parent/target existence | official CLI says the target may be existing or new; mapped-folder documentation says a missing Sandbox target is created; neither states whether a missing intermediate parent chain is created; native UDK contract is not exposed | target-absence rule is official but not package-version-mapped; installed managed layer adds no check | `CONSTRAINED BUT NOT PROVEN` | Target nonexistence alone is ruled out as a required defect; an intermediate-parent condition remains unproven |
| 3. writable-specific guest path/root/parent prerequisites | installed server adds only two group-policy gates and `VMShareFolderOptions.AllowWrite`; it contains no writable-specific managed path/root/parent rule; official CLI describes only permission effect | exact for managed `0.8.107.0`; native UDK internals remain unavailable | `CONSTRAINED BUT NOT PROVEN` | Exposed policy gates do not match the accepted HRESULT; an undisclosed native writable prerequisite cannot be ruled in or out |
| 4. complete material `--host-path` grammar/normalization | installed code expands environment variables, resolves only relative paths against working directory, and otherwise forwards a rooted string unchanged; official docs require an existing host folder; the accepted host folder existed; native acceptance of forward slashes/canonical forms is unstated | exact managed behavior plus version-unspecific official mapped-folder rule | `CONSTRAINED BUT NOT PROVEN` | Known existence/folder requirements do not explain failure; native spelling/normalization still could |
| 5. hidden option order/combination constraint | installed `MapFolderCommand` registers independent `System.CommandLine` options, adds no validator/exclusion, binds them by typed handler parameters, and registers `--raw` globally; the official example uses the same substantive ID/host/sandbox/write sequence | exact for installed managed CLI `0.8.107.0` | `PROVEN` for absence of a WSB-managed order or combination rule | No WSB-managed ordering/combination cause is present; undisclosed host-wrapper construction is addressed separately |
| 6. host-side invocation/quoting construction | FIRST, task, acceptance, and accepted candidate contain the discrete argv only and no single explicit current-project controller/script locator | exact authorized-material result | `NOT PROVEN` — `HOST_INVOCATION_WRAPPER_LOCATOR_NOT_AUTHORIZED/NOT_PROVEN` | Potentially; the task forbids discovery beyond an explicit locator, so quoting mechanics cannot be eliminated |

## 7. Causal conclusion

The new evidence narrows the failure but does not establish a specific violated requirement.

- A missing/new sandbox target is supported, so target nonexistence by itself is not an established defect.
- The installed managed CLI contains no hidden order, mutual-exclusion, or `--raw`/`--allow-write` combination validator.
- The exposed writable policy rejection has a different explicit HRESULT path.
- The accepted host folder existed and satisfied the official folder-level precondition.
- Both supplied paths reach the native `ManagedWindowsVM.ShareFolder` boundary without slash normalization. No authorized source defines whether the recorded `C:/...` spellings, nested guest-parent state, or another native UDK prerequisite are accepted.
- The process-launch wrapper remains unavailable under the exact-locator rule.

Therefore:

`WRITABLE_SHARE_FAILURE_NOT_CAUSALLY_EXPLAINED_FROM_AUTHORIZED_EVIDENCE`

No slash, parent, quoting, ordering, writable, or ID hypothesis is promoted from plausible to proven.

## 8. Corrected-contract authorability

Decision:

`CORRECTED_SHARE_CONTRACT_NOT_YET_AUTHORABLE — MISSING FACTS`

Remaining exact material gaps:

1. the installed native UDK's accepted fully qualified sandbox-path spelling, specifically whether `C:/...` is valid or only a backslash-form contract is supported;
2. whether creation of a new nested Sandbox target also creates all missing intermediate parents, or requires an existing parent/root;
3. any native UDK writable-specific guest-path/root/parent restriction beyond the proven group-policy and `AllowWrite` handling;
4. the native UDK's accepted host-path spelling/canonicalization constraints after the installed managed layer forwards a rooted path unchanged, specifically the recorded forward-slash form;
5. the exact host-side process-launch/quoting construction, because no authorized artifact supplies a single explicit wrapper locator.

The WSB-managed option-order/combination gap is resolved and is not carried forward. The remaining five gaps prevent selecting one corrected command without inventing path or quoting facts. No corrected invocation is proposed.

Any future contract must preserve `continuation-v0-1` as evidence, bind only an exactly authorized Sandbox ID, use a separately authorized fresh continuation namespace and receipt contract, and fail closed. Independent acceptance of this candidate would still not authorize a retry.

## 9. Preserved state and negative attestations

- Original launcher contract remains `FAILED_START_RESULT_NOT_CAPTURED`.
- Accepted blocker remains `WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`
- No operational `wsb share`, `wsb exec`, `wsb list`, runtime observation, start, stop, kill, reset, close, or other Sandbox/guest access or mutation occurred.
- No retry or substitute mapping occurred; no guest or host path was supplied to a `wsb` operational command.
- `continuation-v0-1` was not accessed, cleared, reused, renamed, overwritten, repaired, or repurposed.
- No materialization, DEP13, Maven/source research or acquisition, Gradle, M3, AAR, M2, B12, LC-03, LC-04, Phase36, Backend, Database, or PUI work occurred.
- README and FD02 were not read. No repo-wide, directory-wide, package-wide, host, cache, or path enumeration occurred; only exact refs, exact registered package identity, and exact manifest/assembly-derived file locators were inspected.
- No protected staged/index state was inspected. No `git status` was run.
- No trial-and-error syntax probe, undocumented package binary execution, broad decompilation, or unofficial internet evidence was used.
- This artifact does not accept itself, merge, update `main`, retry the share, or publish a continuation execution task.

## 10. Final classification

`WRITABLE SHARE FAILURE REMAINS PARTLY/NOT EXPLAINED — CORRECTED SHARE CONTRACT NOT YET AUTHORABLE — AWAITING INDEPENDENT ACCEPTANCE`

`MISSING-FACT RESOLUTION != SHARE RETRY`

`CONTRACT AUTHORABLE != RETRY AUTHORIZED`

`OFFICIAL DOCUMENTATION != INSTALLED-BUILD FACT UNLESS APPLICABILITY IS ESTABLISHED`

`REBOUND SANDBOX IDENTITY PASS != ORIGINAL LAUNCHER CONTRACT PASS`

`DEP13 REMAINS BLOCKED`
