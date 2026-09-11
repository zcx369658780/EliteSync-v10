# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 Native Share Contract + Host Wrapper Locator Review Task｜v0.1

Status: `PUBLISHED TASK SHEET — NATIVE-CONTRACT / LOCATOR REVIEW ONLY — NO OPERATIONAL SHARE — NO GUEST ACCESS — DEP13 NOT AUTHORIZED — B12 NOT AUTHORIZED`

Date: 2026-09-11 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Publication authority

Publication-base `main`:

`91bb6a6b3cfba084e068c6102370d5d39c465dfa`

FIRST handoff:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`

required blob:

`3aa2ead4cf1084b202b67856075c26ab80b0c9a2`

Accepted missing-fact review acceptance:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_WRITABLE_SHARE_MISSING_FACT_RESOLUTION_ACCEPTANCE_V0_1.md`

Accepted result identity:

- candidate commit: `bc05b89766bb73d6ade36c47dad7c21709920c73`
- result blob: `da07e0337dd100015cee5b013dcaa9b4714f47d4`

The executor may publish exactly one bounded candidate and must not self-accept it.

## 2. Accepted immutable state

Preserve:

`FAILED_START_RESULT_NOT_CAPTURED`

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

Current rebound/quarantined Sandbox ID:

`7ebc163d-7e92-4a63-8218-47c03d5db697`

Preserved continuation namespace:

`C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71/continuation-v0-1`

This namespace is immutable evidence and must not be accessed operationally, cleared, reused, renamed, overwritten, repaired, or repurposed.

Installed CLI/package identity already accepted:

`MicrosoftWindows.WindowsSandbox_0.8.107.0_x64__cw5n1h2txyewy`

The WSB-managed custom option-order/combination gap is CLOSED and must not be reopened without contradictory evidence.

## 3. Sole objective

Resolve as many as possible of the five remaining gaps, using only the two bounded evidence directions below:

1. native UDK acceptance of fully qualified Sandbox path spelling, especially `C:/...` versus backslash form;
2. native behavior for creating a new nested Sandbox target where intermediate parents may be absent;
3. native writable-specific guest-path/root/parent prerequisites beyond the proven managed policy and `AllowWrite` handling;
4. native UDK acceptance/canonicalization of the recorded rooted host path spelling using forward slashes;
5. exact host-side process-launch/quoting construction used for the failed invocation.

The task must determine whether the accepted `E_INVALIDARG` failure can now be causally explained and whether a corrected share contract is authorable without invention.

## 4. Startup gates

1. fresh-fetch remote `main`;
2. require `main` equals the commit publishing this task; otherwise `STOP — MAIN_AUTHORITY_CHANGED` unless later accepted authority explicitly reissues it;
3. read FIRST the handoff and verify blob `3aa2ead4cf1084b202b67856075c26ab80b0c9a2`;
4. read this task;
5. read the exact acceptance path from §1;
6. read accepted result blob `da07e0337dd100015cee5b013dcaa9b4714f47d4` if necessary.

Do not use conversation/project memory as execution authority.

## 5. Authorized evidence direction A — native share contract

Internet/source research is authorized only for Microsoft-controlled evidence directly relevant to `IManagedWindowsVM.ShareFolder`, Windows Sandbox mapped-folder native semantics, or the exact installed package's public contract surface.

Permitted classes:

- Microsoft Learn / official Windows documentation;
- official Microsoft GitHub repositories/source trees;
- Microsoft-published SDK/WinRT headers, metadata, IDL, symbol/type information, or API contract material;
- exact installed-package metadata/resources already identified from accepted package registration, but only through exact locators or direct type/reference relationships.

The executor may search Microsoft-controlled public sources specifically for these exact identifiers/concepts:

- `IManagedWindowsVM.ShareFolder`;
- `ManagedWindowsVM.ShareFolder`;
- `VMShareFolderOptions.AllowWrite`;
- `MappedFolder` / Windows Sandbox mapped folder path requirements;
- Windows UDK isolation share-folder path semantics;
- `E_INVALIDARG` conditions documented for the above APIs.

Requirements:

- record exact URL/repository/path/revision or document identity;
- distinguish normative contract, source implementation, symbol/type metadata, example, and inference;
- establish applicability to installed package `0.8.107.0` where possible;
- do not treat ordinary Win32 path behavior as proof of this API's contract unless Microsoft material explicitly links it;
- do not use unofficial sources, mirrors, forums, Q&A answers, blogs, Stack Overflow, Reddit, or AI summaries as evidence.

Narrow static inspection of exact installed package files may continue only when the file/type is directly referenced by already accepted package metadata or an already inspected exact assembly. Do not recursively enumerate the package and do not broadly decompile native binaries.

If no Microsoft-controlled contract/source establishes a native requirement, record that gap as externally unproven. Do not substitute experimentation.

## 6. Authorized evidence direction B — host-wrapper locator recovery

A narrow repository search is newly authorized solely to locate the single current-project host controller/script that constructed the accepted failed `wsb share` invocation.

Search scope is restricted to repository `zcx369658780/EliteSync-v10` current authority and only these exact search anchors:

- `7ebc163d-7e92-4a63-8218-47c03d5db697`
- `EliteSync-v10-M3A-RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71`
- `continuation-v0-1`
- `WRITABLE_CONTINUATION_SHARE_FAILED`
- the exact host path from the accepted failed mapping;
- the exact sandbox path `C:/M3A/transport/continuation-v0-1`;
- exact `wsb share` / `--host-path` / `--sandbox-path` construction only when combined with one of the above unique anchors.

This authorization permits repository code/text search for these anchors only. It does NOT permit directory browsing, repo-wide reading, commit archaeology, historical branch mining, README reading, FD02 inspection, or generalized keyword exploration.

Locator rule:

- if exactly one current-project script/controller is uniquely established as the constructor of the failed process invocation, record its exact path/blob and read only that file;
- inspect only the process-start / argument-construction / quoting code immediately necessary to establish the exact command-launch semantics;
- do not execute the script;
- do not edit it;
- do not follow unrelated imports/references unless an exact direct reference is required solely to resolve quoting/argv behavior;
- if multiple plausible files remain, record `HOST_WRAPPER_NOT_UNIQUELY_LOCATED` and do not broaden scope.

## 7. Analysis requirements

For each of the five remaining gaps, produce an evidence matrix with:

- fact sought;
- exact evidence source;
- source class (`INSTALLED_IMPL`, `MICROSOFT_NORMATIVE`, `MICROSOFT_SOURCE`, `HOST_WRAPPER`, `EXAMPLE`, `INFERENCE`);
- installed-version applicability;
- classification: `PROVEN`, `CONSTRAINED BUT NOT PROVEN`, `NOT PROVEN`, or `NOT APPLICABLE`;
- whether it causally explains the accepted `E_INVALIDARG` result.

If the host wrapper is located, explicitly distinguish:

- discrete argv intended by controller code;
- actual API/process-launch primitive used;
- whether quoting is shell-mediated or direct argument-list based;
- whether any slash/path normalization occurs before process creation.

Do not infer behavior from source naming or coding style.

## 8. Decision rules

`CAUSALLY_EXPLAINED` requires a specific violated requirement established by authorized evidence and matched to the preserved failed invocation/state.

`CORRECTED_SHARE_CONTRACT_AUTHORABLE` requires every material element needed for one corrected retry to be established without invention.

If any material gap remains, conclude:

`CORRECTED_SHARE_CONTRACT_NOT_YET_AUTHORABLE — MISSING FACTS`

If the native contract remains unpublished/unavailable after this bounded review and no causal explanation is established, classify that exact gap as an external fact limitation rather than authorize trial-and-error.

## 9. Explicit prohibitions

Do NOT:

- execute operational `wsb share`;
- retry or substitute any mapping;
- run `wsb exec` or runtime `wsb list`;
- access or mutate the guest/Sandbox;
- create/start/stop/kill/reset/close any Sandbox;
- create/alter guest directories to test hypotheses;
- access operational contents of `continuation-v0-1` beyond already accepted repository-recorded evidence;
- materialize anything;
- run DEP13;
- perform Maven/source acquisition or dependency work;
- run Gradle/M3/AAR/M2;
- read README;
- inspect FD02;
- inspect protected staged/index state;
- perform broad repo/package/host/cache/path enumeration;
- use trial-and-error syntax or path probes;
- use unofficial internet evidence;
- broadly reverse engineer native binaries;
- implement or patch any share/recovery code.

## 10. Durable boundaries

Preserve D-02 durable UNKNOWN, U-14 exclusion, U-12 exact-scope rules, `TP-SOURCE-CLASS-01`, `TP-TARGET-01`, Backend/Database/PUI boundaries, accepted legal/Safety/no-processing boundaries, no participant research/recruitment, no private-Conversation inspection, no telemetry/analytics/measurement, no Safety Operations, no new legal research, and no implementation/LC-03/LC-04/Phase36 authority.

B12 remains NOT AUTHORIZED. M2 remains separate and NOT automatically authorized.

DEP13 must not start until fixed-guest recovery continuation has actually succeeded and been independently accepted.

## 11. Required candidate artifact

Create exactly one review artifact on a dedicated review branch:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_NATIVE_SHARE_CONTRACT_AND_HOST_WRAPPER_LOCATOR_REVIEW_V0_1.md`

It must include:

- authority commit/tree/task blob identities;
- exact Microsoft-controlled evidence used;
- exact host-wrapper locator search anchors and result;
- exact wrapper path/blob if uniquely established;
- five-gap evidence matrix;
- causal conclusion;
- corrected-contract authorability decision;
- exact remaining external fact gaps, if any;
- negative attestations for prohibited actions.

Final classification must be exactly one of:

`WRITABLE SHARE FAILURE EXPLAINED — CORRECTED SHARE CONTRACT AUTHORABLE — AWAITING INDEPENDENT ACCEPTANCE`

or

`WRITABLE SHARE FAILURE REMAINS PARTLY/NOT EXPLAINED — CORRECTED SHARE CONTRACT NOT YET AUTHORABLE — AWAITING INDEPENDENT ACCEPTANCE`

Stop immediately after publishing the candidate commit. Do not merge, self-accept, retry the share, or publish a continuation execution task.

## 12. End state

`NATIVE-CONTRACT REVIEW != SHARE RETRY`

`HOST-WRAPPER LOCATED != RETRY AUTHORIZED`

`CONTRACT AUTHORABLE != RETRY AUTHORIZED`

`UNPUBLISHED NATIVE CONTRACT != LICENSE TO EXPERIMENT`

`DEP13 REMAINS BLOCKED`
