# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 Writable Share Missing-Fact Resolution Task｜v0.1

Status: `PUBLISHED TASK SHEET — FACT RESOLUTION ONLY — NO OPERATIONAL SHARE — NO GUEST ACCESS — DEP13 NOT AUTHORIZED — B12 NOT AUTHORIZED`

Date: 2026-09-11 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Publication authority

Publication-base `main`:

`e2a218511534b1e368cce623633413049a97b398`

Exact publication-base tree:

`b046f8a7d49b3253e68826fe5978475d2817b712`

FIRST handoff:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`

required blob:

`3aa2ead4cf1084b202b67856075c26ab80b0c9a2`

Accepted fact-review acceptance:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_WRITABLE_CONTINUATION_SHARE_FAILURE_FACT_REVIEW_ACCEPTANCE_V0_1.md`

Accepted review candidate identity:

- commit `42180fc7a27d93cdf423e9e8f1cc90b22ec38b7e`
- result blob `a7f1db9a781c46e4a0d505a0ca1b22328a791ce3`

The executor may publish one bounded candidate only and must not self-accept it.

## 2. Accepted state that remains immutable

Original launcher contract:

`FAILED_START_RESULT_NOT_CAPTURED`

Accepted current blocker:

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

Current rebound/quarantined Sandbox ID:

`7ebc163d-7e92-4a63-8218-47c03d5db697`

Preserved evidence namespace:

`C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71/continuation-v0-1`

It remains evidence only and must not be cleared, reused, renamed, overwritten, repaired, or repurposed.

Accepted installed CLI identity:

`wsb.exe 0.8.107.0`

Accepted previous conclusion:

`CORRECTED_SHARE_CONTRACT_NOT_YET_AUTHORABLE — MISSING FACTS`

## 3. Sole substantive objective

Resolve, as far as possible without any operational share or guest access, these six accepted missing facts:

1. accepted `--sandbox-path` grammar for installed/authoritative `wsb` semantics, including root/drive form and slash form;
2. guest parent/target existence requirements for `share`;
3. writable-share-specific guest-path/root/parent prerequisites under `--allow-write`;
4. complete material `--host-path` grammar/normalization constraints beyond the terse help text;
5. any option-order or option-combination constraint not exposed by `share --help`;
6. exact host-side invocation/quoting construction used by the failed execution, only if a single explicit current-project locator can be established without broad search.

The task must determine whether the accepted invalid-argument failure can now be causally explained and whether a corrected share contract is authorable without invention.

## 4. Startup and authority gates

1. fresh-fetch remote `main`;
2. require `main` equals the commit publishing this task; otherwise `STOP — MAIN_AUTHORITY_CHANGED` unless later authority explicitly reissues it;
3. read FIRST the handoff path in §1 and verify blob `3aa2ead4cf1084b202b67856075c26ab80b0c9a2`;
4. read this task;
5. read the exact acceptance path in §1;
6. read the accepted review candidate by exact blob `a7f1db9a781c46e4a0d505a0ca1b22328a791ce3` if needed.

Do not use conversation/project memory as execution authority.

## 5. Authorized fact sources

### 5.1 Exact installed package registration

Read-only Windows package/application metadata queries are authorized solely to identify the installed package owning the resolved WindowsApps `wsb.exe` alias and to obtain:

- package identity/name;
- package version;
- publisher;
- architecture;
- exact install location;
- package manifest path/identity where exposed.

Use direct package-registration APIs/cmdlets scoped to the resolved application/package identity. Do not enumerate all installed packages and do not recursively enumerate WindowsApps.

If the owning package cannot be uniquely resolved without broad enumeration, record `INSTALLED_PACKAGE_OWNER_NOT_PROVEN` and do not widen scope.

### 5.2 Exact package-owned local resources

Once an exact package install location is established, read-only inspection is authorized only for:

- package manifest(s) at exact standard/manifest-referenced paths;
- exact executable or managed assembly implementing `wsb`, if manifest/registration directly identifies it;
- directly referenced adjacent configuration/resource files whose exact names/paths are obtained from the manifest or executable metadata;
- file/version/assembly metadata and bounded static metadata/strings from those exact identified files.

Do not recursively list the package directory. Do not search the whole package by filename/content. Do not execute undocumented binaries or invoke operational subcommands.

Static inspection must remain non-mutating and narrowly aimed at the six missing facts. If binary static metadata cannot safely establish semantics, record UNKNOWN rather than decompile broadly.

### 5.3 Installed CLI help

The already accepted help-only facts may be re-verified only if necessary. Help-only execution must not include a real Sandbox ID, host path, or guest path and must not trigger an operational share.

### 5.4 Official Microsoft material

Internet research is authorized only for **official Microsoft-controlled sources** directly relevant to Windows Sandbox CLI / `wsb` / `ShareFolder` semantics, such as Microsoft Learn, Microsoft documentation, or an official Microsoft GitHub repository/source tree.

Requirements:

- record exact URL/title and retrieval date;
- distinguish installed-version-specific evidence from version-unspecific normative documentation;
- do not treat an example as a normative requirement unless the source states it;
- do not use blogs, forums, Stack Overflow, Reddit, mirrors, third-party tutorials, AI summaries, or unofficial repositories as evidence;
- if official material conflicts with installed help, installed-build behavior/help remains controlling for the local contract unless version mapping resolves the conflict.

### 5.5 Exact failed invocation construction

The accepted review already recovered discrete argv tokens. This task may additionally recover the host-side process-launch/quoting construction only if the acceptance, handoff, task sheet, or an already-read exact current-project artifact contains a **single explicit locator** to the host controller/script that constructed the failed `wsb share` process.

No repository code search, filename search, directory listing, recursive discovery, commit archaeology, or host-path search is authorized to find that locator.

If no explicit locator is present in authorized material, record:

`HOST_INVOCATION_WRAPPER_LOCATOR_NOT_AUTHORIZED/NOT_PROVEN`

and continue without it.

## 6. Analysis requirements

For each missing fact, produce an evidence matrix containing:

- fact sought;
- source identity;
- exact evidence;
- installed-version applicability;
- classification: `PROVEN`, `CONSTRAINED BUT NOT PROVEN`, `NOT PROVEN`, or `NOT APPLICABLE`;
- whether it can causally explain the accepted invalid-argument result.

Explicitly distinguish:

- documented accepted syntax;
- documented required preconditions;
- examples only;
- implementation-derived constraints;
- inference.

Inference alone cannot authorize a corrected contract.

## 7. Causal and contract decision rules

The result may classify the failure as `CAUSALLY EXPLAINED` only if authorized evidence establishes a specific violated requirement that matches the preserved failed invocation/state.

The result may classify:

`CORRECTED_SHARE_CONTRACT_AUTHORABLE`

only if every material invocation/precondition element needed for a single corrected retry is established without invention.

A corrected contract must specify, at minimum:

- exact `wsb` identity/version basis;
- exact `--id` form;
- exact host-path form and preconditions;
- exact sandbox-path form and preconditions;
- exact writable semantics/preconditions;
- exact `--raw` semantics if retained;
- any required option ordering/combination rule;
- exact new continuation namespace rule;
- preservation of `continuation-v0-1` as evidence;
- fail-closed behavior;
- no retroactive reinterpretation of `FAILED_START_RESULT_NOT_CAPTURED`.

If any material fact remains unknown, conclude:

`CORRECTED_SHARE_CONTRACT_NOT_YET_AUTHORABLE — MISSING FACTS`

and enumerate only the remaining exact gaps.

## 8. Explicit prohibitions

Do NOT:

- execute operational `wsb share`;
- retry or substitute any mapping;
- run `wsb exec`;
- run `wsb list` as a runtime observation;
- access the guest;
- create/start another Sandbox;
- stop/kill/reset/close/mutate the existing Sandbox;
- create or alter guest directories to test path hypotheses;
- clear/reuse/rename/overwrite/repair `continuation-v0-1`;
- materialize anything;
- run DEP13;
- perform Maven/source research or acquisition;
- run Gradle/M3/AAR/M2;
- read README;
- inspect FD02;
- perform broad repo/path/cache/host/package enumeration;
- inspect protected staged/index state;
- use trial-and-error syntax probes;
- use unofficial internet sources as evidence;
- decompile or reverse engineer broadly beyond narrowly bounded static metadata necessary to answer the six facts.

## 9. Durable governance boundaries

Preserve D-02 durable UNKNOWN, U-14 exclusion, U-12 exact-scope rules, `TP-SOURCE-CLASS-01`, `TP-TARGET-01`, Backend/Database/PUI boundaries, accepted legal/Safety/no-processing boundaries, no participant research/recruitment, no private-Conversation inspection, no telemetry/analytics/measurement, no Safety Operations, no new legal research, and no implementation/LC-03/LC-04/Phase36 authority.

B12 remains NOT AUTHORIZED. M2 remains separate and NOT automatically authorized.

DEP13 must not start until fixed-guest recovery continuation has actually succeeded and been independently accepted.

## 10. Required candidate artifact

Create exactly one review artifact on a dedicated review branch:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_WRITABLE_SHARE_MISSING_FACT_RESOLUTION_V0_1.md`

It must include:

- authority commit/tree/task blob identities;
- installed package identity/version/install-location evidence, if established;
- exact local package-owned files actually inspected and why each was authorized;
- exact official Microsoft sources used, with applicability classification;
- six-fact evidence matrix;
- causal conclusion;
- corrected-contract authorability decision;
- remaining missing facts, if any;
- negative attestations for every prohibited action category materially relevant to the work.

Final classification must be exactly one of:

`WRITABLE SHARE FAILURE EXPLAINED — CORRECTED SHARE CONTRACT AUTHORABLE — AWAITING INDEPENDENT ACCEPTANCE`

or

`WRITABLE SHARE FAILURE REMAINS PARTLY/NOT EXPLAINED — CORRECTED SHARE CONTRACT NOT YET AUTHORABLE — AWAITING INDEPENDENT ACCEPTANCE`

Stop immediately after publishing the candidate commit. Do not merge, self-accept, retry the share, or publish a continuation execution task.

## 11. End state

`MISSING-FACT RESOLUTION != SHARE RETRY`

`CONTRACT AUTHORABLE != RETRY AUTHORIZED`

`OFFICIAL DOCUMENTATION != INSTALLED-BUILD FACT UNLESS APPLICABILITY IS ESTABLISHED`

`REBOUND SANDBOX IDENTITY PASS != ORIGINAL LAUNCHER CONTRACT PASS`

`DEP13 REMAINS BLOCKED`
