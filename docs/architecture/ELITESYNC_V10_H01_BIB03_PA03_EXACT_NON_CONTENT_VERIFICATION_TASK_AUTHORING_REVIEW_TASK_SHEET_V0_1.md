# EliteSync v10 H-01 BIB-03 PA-03 Exact Non-Content Verification Task Authoring Review Task Sheet v0.1

## 1. Status and exact authority

Status:

`PROPOSED — TASK-SHEET AUTHORING/REVIEW ONLY — ZERO OLD-REPOSITORY ACCESS — ZERO VERIFICATION EXECUTION — ZERO CONTENT READS — NO METHOD ELIGIBILITY/SELECTION/EXECUTION`

Repository:

`zcx369658780/EliteSync-v10`

Review branch:

`review/h01-bib03-pa03-exact-non-content-verification-task-authoring-v0-1`

Exact live-main authority required:

`70cec62323bf5c5cde7d01f505fa898aeef203d6`

Accepted PA-03 verification-governance artifact:

`docs/architecture/ELITESYNC_V10_H01_BIB03_PA03_METADATA_OBJECT_VERIFICATION_GOVERNANCE_REVIEW_V0_1.md`

Required accepted artifact blob:

`6b0ff741e98b6ed2d1e5e6aa62c2660ddc1c07ba`

Accepted governance authority:

`PA-03 METADATA-OBJECT IDENTITY VERIFICATION GOVERNANCE = RE-OPENABLE ONLY AS A LATER EXACT NON-CONTENT GIT IDENTITY-VERIFICATION GATE — DURABLE PA-03 INTAKE FACT ONLY — ZERO VERIFICATION EXECUTED — ZERO CONTENT READS — NO METHOD ELIGIBILITY/SELECTION/PROBE AUTHORITY CREATED`

Preserve:

`POST-E3 PROMOTION PUSH-OPERATION COUNT = UNKNOWN / NOT INDEPENDENTLY VERIFIABLE`

## 2. Durable PA-03 intake fact

The candidate verification task may be constrained only to these durable Owner-supplied intake fields:

`repository=zcx369658780/EliteSync`

`commit=0f06e895a89629a7f4f0cf0c62b784446ecf515a`

`metadata_object_path=apps/flutter_elitesync_module/pubspec.yaml`

`blob_sha=7ecd2f6835af9ceb1d67822adbac93d7fa07a939`

Provenance:

`Exact non-README metadata-object identity established in the old EliteSync project before this intake through exact-path Git tree verification. No README-derived or EliteSync-v10 incident-derived information was used.`

These remain intake facts only during this authoring gate.

Preserve exactly:

`PA-03 INTAKE FACT != VERIFIED METADATA OBJECT`

`PA-03 INTAKE FACT != NR-METHOD-03 ELIGIBILITY`

`PA-03 INTAKE FACT != NR-METHOD-03 SELECTION`

`PA-03 INTAKE FACT != METADATA-OBJECT PROBE AUTHORITY`

## 3. Owner-provided operational routing context

The Owner previously supplied the following old-project operational context:

`verification_worktree=D:\EliteSync`

`expected_origin=git@github.com:zcx369658780/EliteSync.git`

These values may be encoded in the future verification task solely as exact operational routing/prerequisite values. They are not PA-03 source evidence, source locators, source candidates, or source identities.

This authoring gate MUST NOT test whether either value exists or is correct.

## 4. Sole authoring question

Determine only:

`CAN ONE EXACT PA-03 NON-CONTENT GIT IDENTITY-VERIFICATION EXECUTION TASK SHEET BE AUTHORED, CONSTRAINED TO THE ACCEPTED REPOSITORY/COMMIT/EXACT-PATH/BLOB RELATIONSHIP AND EXACT OPERATIONAL WORKTREE, WITHOUT ACCESSING THE OLD REPOSITORY OR EXECUTING ANY VERIFICATION IN THIS AUTHORING GATE?`

## 5. Exact candidate verification task-sheet path

For Outcome A create exactly:

`docs/architecture/ELITESYNC_V10_H01_BIB03_PA03_EXACT_NON_CONTENT_VERIFICATION_TASK_SHEET_V0_1.md`

Its status must be exactly:

`PROPOSED — AWAITING INDEPENDENT GPT L3 ACCEPTANCE AND DURABLE PROMOTION — PA-03 VERIFICATION INACTIVE — DO NOT ACCESS OLD ELITESYNC YET`

No separate authoring-result artifact is permitted. The candidate verification task sheet itself is the review artifact.

## 6. Exact future execution prerequisites

The candidate task sheet must require before substantive verification:

1. exact EliteSync-v10 execution authority and task-sheet blob match;
2. exact old-project operational worktree string is `D:\EliteSync`;
3. no attempt is made to discover, search for, or substitute another old-project worktree;
4. the verification is strictly read-only with respect to the old project;
5. any inability to invoke the exact allowed non-content Git metadata checks results in `OPERATIONAL BLOCKED` or V3 as applicable, with no repair/fallback route.

The future verification task must not require the old worktree to be clean merely to perform read-only exact-object checks, and must not alter, stash, reset, restore, checkout, switch, fetch, pull, merge, rebase, or otherwise mutate it.

## 7. Exact future allowed Git metadata checks

The candidate task sheet must authorize only checks equivalent to the following exact bounded sequence, and no additional discovery:

### Check A — exact remote identity string

Read only the configured origin URL in the exact operational worktree, using a non-content Git metadata command equivalent to:

`git -C D:\EliteSync remote get-url origin`

Require exact output:

`git@github.com:zcx369658780/EliteSync.git`

Mismatch or absence fails closed. Do not normalize, rewrite, canonicalize, search for, or substitute another remote.

### Check B — exact commit object type

Check only the Git object type of:

`0f06e895a89629a7f4f0cf0c62b784446ecf515a`

using a non-content-bearing operation equivalent to:

`git -C D:\EliteSync cat-file -t 0f06e895a89629a7f4f0cf0c62b784446ecf515a`

Require exact output:

`commit`

Do not print commit contents or headers beyond the type result.

### Check C — exact commit:path object resolution

Resolve exactly and only:

`0f06e895a89629a7f4f0cf0c62b784446ecf515a:apps/flutter_elitesync_module/pubspec.yaml`

using a non-content-bearing exact-path lookup equivalent to:

`git -C D:\EliteSync rev-parse 0f06e895a89629a7f4f0cf0c62b784446ecf515a:apps/flutter_elitesync_module/pubspec.yaml`

Do not enumerate the tree or inspect neighboring paths.

### Check D — exact OID equality

Compare the single resolved OID from Check C byte-for-byte to:

`7ecd2f6835af9ceb1d67822adbac93d7fa07a939`

No alternate OID, path, revision, or candidate is permitted.

### Check E — exact blob object type

Check only the Git object type of:

`7ecd2f6835af9ceb1d67822adbac93d7fa07a939`

using a non-content-bearing operation equivalent to:

`git -C D:\EliteSync cat-file -t 7ecd2f6835af9ceb1d67822adbac93d7fa07a939`

Require exact output:

`blob`

No blob content may be emitted.

## 8. Explicitly forbidden future verification mechanisms

The candidate task sheet must forbid:

- `git show` of the commit/path/blob;
- `git cat-file -p`;
- `git cat-file blob` content output;
- opening, reading, parsing, printing, summarizing, or hashing anew `pubspec.yaml`;
- GitHub/raw file-content fetch;
- `git ls-tree`;
- `git ls-files`;
- `rg --files`;
- `find`;
- `fd`;
- recursive `ls`;
- recursive `dir`;
- `tree`;
- repository/directory globs;
- code search;
- filename search;
- `git grep`;
- alternative-path discovery;
- alternative commit discovery;
- alternate worktree discovery;
- `git fetch` / `pull` / network retrieval to repair missing objects;
- retry through another repository, remote, path, branch, tag, commit, or object.

Preserve exactly:

`NO REPOSITORY-WIDE OR DIRECTORY-WIDE FILE/PATH ENUMERATION IS AUTHORIZED.`

## 9. Exact future result envelope

The candidate verification task sheet must define exactly:

### V1 — exact identity match

`PA-03 METADATA-OBJECT IDENTITY VERIFIED — EXACT REPOSITORY/COMMIT/PATH/BLOB RELATIONSHIP MATCHES OWNER-SUPPLIED INTAKE FACT — ZERO CONTENT READS — NO METHOD SELECTED OR PROBE AUTHORITY CREATED`

Use V1 only if Checks A–E all pass exactly.

### V2 — exact identity mismatch or absence

`PA-03 METADATA-OBJECT IDENTITY NOT VERIFIED — EXACT REPOSITORY/COMMIT/PATH/BLOB RELATIONSHIP MISMATCHED OR ABSENT — FAIL CLOSED — NO ALTERNATIVE SEARCH OR REPAIR`

Use V2 for an exact repository/remote, commit type, path resolution, OID equality, or blob-type mismatch/absence when the bounded checks were executable.

### V3 — bounded non-content verification not possible

`PA-03 METADATA-OBJECT IDENTITY VERIFICATION NOT POSSIBLE WITHIN AUTHORIZED NON-CONTENT ENVELOPE — FAIL CLOSED`

Use V3 when the identity relationship cannot be determined without exceeding the exact allowed non-content envelope.

### Operational failure

`OPERATIONAL BLOCKED — NO PA-03 METADATA-OBJECT IDENTITY VERIFICATION EXECUTED`

Use only for EliteSync-v10 authority/ref/worktree/task-sheet/execution-environment prerequisite failure before the bounded verification can lawfully begin.

## 10. Future V1 semantics

Even V1 may establish only:

`verified PA-03 metadata-object identities = 1`

V1 MUST NOT automatically change:

`NR-METHOD-03 eligibility`

`NR-METHOD-03 selection`

`metadata-content probe authority`

`source identity candidates emitted / accepted`

`basis instances`

`source-target bindings`

`U-12 concrete targets`

A later method-eligibility/selection governance gate remains required.

## 11. Frozen accounting during THIS authoring gate

Preserve:

- accepted PA-03 metadata-object verification governance gates = `1`
- durable accepted prerequisite payloads = `1`
- durable accepted payload class = `PA-03`
- candidate verification task sheets authored = `1` only for Outcome A
- accepted/published verification task sheets = `0`
- verified PA-03 metadata-object identities = `0`
- old-repository metadata checks = `0`
- content reads = `0`
- metadata probes = `0`
- methods eligible / selected / executed = `0 / 0 / 0`
- execution task sheets = `0`
- accepted read ledger / unauthorized documentary reads = `12 / 1`
- remaining README/documentary content accesses = `0`
- source-locator candidates / package-URI normalizations = `0 / 0`
- source identity candidates emitted / accepted = `0 / 0`
- bounded concrete identification basis instances = `0`
- source-target bindings = `0`
- U-12 concrete targets = `0`

## 12. Higher-level frozen governance and protected path

Preserve all accepted ADRs, durable UNKNOWNs, legal/Safety boundaries, U-14 exclusion, U-12 exact-scope rules, D-02 unresolved state, `D02-DURABLE-UNKNOWN-01`, U-15 unresolved state, `TP-SOURCE-CLASS-01`, `TP-TARGET-01`, Backend/Database non-inspection, deferred PUI, PUI-PREREQ-12 = `0`, and technical design, implementation, LC-03, LC-04, Phase 36 as unauthorized.

FD02 remains protected and excluded.

## 13. Explicit prohibitions in THIS authoring gate

This authoring gate performs zero:

- old `EliteSync` repository/worktree access;
- testing `D:\EliteSync`;
- remote metadata checks;
- commit/path/blob verification;
- Git object lookup against old EliteSync;
- content reads;
- metadata probes;
- README/blob access or reconstruction;
- repository/source/web search;
- enumeration;
- source-path hypothesis creation;
- locator/source candidate creation or acceptance;
- basis-instance acceptance;
- source-target binding;
- evidence collection;
- method eligibility change;
- method selection/execution;
- verification execution;
- PUI reconsideration;
- technical design/implementation;
- LC-03/LC-04/Phase 36;
- FD02 access/search/hash/inspection/use.

## 14. Authoring outcomes and publication

### Outcome A

`PA-03 EXACT NON-CONTENT VERIFICATION TASK SHEET = CANDIDATE AUTHORED — EXACT FIVE-CHECK GIT IDENTITY ENVELOPE — VERIFICATION INACTIVE — ZERO OLD-REPOSITORY ACCESS — ZERO CONTENT READS — NO METHOD AUTHORITY CREATED`

Create exactly the candidate verification task sheet.

### EXPECTED OUTCOME B

`EXPECTED OUTCOME B — PA-03 EXACT NON-CONTENT VERIFICATION TASK SHEET NOT AUTHORABLE UNDER CURRENT AUTHORITY — FAIL CLOSED`

Do not create the candidate task sheet.

### OPERATIONAL BLOCKED

`OPERATIONAL BLOCKED — NO PA-03 VERIFICATION TASK-SHEET AUTHORING DETERMINATION MADE`

For Outcome A commit exactly:

`docs/architecture/ELITESYNC_V10_H01_BIB03_PA03_EXACT_NON_CONTENT_VERIFICATION_TASK_SHEET_V0_1.md`

Commit message:

`docs: author H-01 BIB-03 PA-03 exact non-content verification task sheet`

Changed-path count must equal exactly `1`.

Publish only to the same review branch by one non-force push if all prerequisites pass. Do not promote `main`.

For Outcome A report:

- candidate verification task sheets authored = `1`
- accepted/published verification task sheets = `0`
- old-repository metadata checks = `0`
- verified identities = `0`
- content reads / metadata probes = `0 / 0`
- methods eligible / selected / executed = `0 / 0 / 0`

Stop before any old-project access or verification execution.
