# EliteSync v10 H-01 BIB-03 Source-Path Identity Probe Execution Task Sheet v0.1

## 1. Purpose and publication non-authority

This document defines exactly one possible later execution:

`H-01 BIB-03 SOURCE-PATH IDENTITY PROBE EXECUTION — ONE EXACT ACCEPTED HYPOTHESIS — METADATA ONLY — ZERO SOURCE BYTES — FAIL CLOSED`

Repository:

`zcx369658780/EliteSync-v10`

Publication parent authority:

`90e752f8bb26981e05b439c4499125410f69bcbe`

Accepted source-path hypothesis:

`SOURCE-PATH-HYPOTHESIS-01 — apps/flutter_elitesync_module/lib/flutter_elitesync_module.dart — ACCEPTED AS ONE EXACT UNVERIFIED SOURCE-PATH HYPOTHESIS FOR LATER METADATA-ONLY IDENTITY PROBE`

Publication of this task sheet does NOT execute the probe and creates no source-content-read, source-candidate acceptance, bounded-basis-instance acceptance, source-target binding, inspection, evidence, PUI, design, or implementation authority.

## 2. Exact immutable probe target

The sole authorized Git object expression is:

`3c59d0f4d97b2b6d4607f464a1dd73bfd36ba8ba:apps/flutter_elitesync_module/lib/flutter_elitesync_module.dart`

The immutable probe baseline is exactly:

`3c59d0f4d97b2b6d4607f464a1dd73bfd36ba8ba`

Do NOT substitute the task-sheet publication commit, current HEAD, or any later commit.

Preserve:

`SOURCE-PATH PROBE BASELINE != TASK-SHEET PUBLICATION COMMIT`

`SOURCE-PATH HYPOTHESIS != PATH EXISTS`

## 3. Exact probe semantics

Execute exactly once:

`git cat-file -e 3c59d0f4d97b2b6d4607f464a1dd73bfd36ba8ba:apps/flutter_elitesync_module/lib/flutter_elitesync_module.dart`

If and only if that succeeds, execute:

`git rev-parse 3c59d0f4d97b2b6d4607f464a1dd73bfd36ba8ba:apps/flutter_elitesync_module/lib/flutter_elitesync_module.dart`

and, if needed to establish object type:

`git cat-file -t <resolved-object-sha>`

The resolved object must be a Git `blob`.

Allowed retained information is limited to:

1. HIT / MISS;
2. object type;
3. Git blob SHA on HIT;
4. the already-authorized exact hypothesis path;
5. the immutable commit baseline.

No source bytes may be emitted or read.

## 4. Absolutely no source-content read

Do NOT use:

- `git show` on the source path or resolved blob;
- `git cat-file -p`;
- `git cat-file blob`;
- source/file fetch APIs returning content;
- grep;
- line counting;
- parsing;
- content diff;
- syntax inspection;
- import/export inspection.

Source-content reads must remain exactly `0`.

Preserve:

`METADATA PROBE HIT != SOURCE CONTENT READ AUTHORIZED`

`SOURCE BLOB IDENTITY != SOURCE CONTENT READ AUTHORITY`

## 5. Single-hypothesis fail-closed boundary

The sole probe target is:

`apps/flutter_elitesync_module/lib/flutter_elitesync_module.dart`

No second or fallback hypothesis is authorized.

Do NOT create, infer, test, or probe:

- `apps/flutter_elitesync_module/lib/main.dart`;
- any `src/` path;
- generated paths;
- platform paths;
- tests;
- alternate Dart filenames;
- neighboring package paths.

Preserve:

`ONE HYPOTHESIS MISS != AUTHORITY FOR A SECOND HYPOTHESIS`

`SOURCE-PATH IDENTITY PROBE != CONVENTION SEQUENCE`

## 6. Outcome A — exact Git blob identity established

If the exact object expression resolves to one Git blob, label:

`EXPECTED OUTCOME A`

Emit exactly one canonical candidate identity:

`zcx369658780/EliteSync-v10@3c59d0f4d97b2b6d4607f464a1dd73bfd36ba8ba:apps/flutter_elitesync_module/lib/flutter_elitesync_module.dart#blob=<resolved-git-blob-sha>`

Record exactly:

`SOURCE-IDENTITY-CANDIDATE-01 — <canonical identity> — EMITTED, NOT ACCEPTED`

Terminal statement:

`H-01 BIB-03 SOURCE-PATH IDENTITY PROBE ESTABLISHED ONE EXACT GIT-BLOB IDENTITY FROM SOURCE-PATH-HYPOTHESIS-01 — ONE SOURCE-IDENTITY CANDIDATE EMITTED — NO SOURCE CONTENT READ — NO CANDIDATE ACCEPTANCE, BASIS-INSTANCE ACCEPTANCE, SOURCE-TARGET BINDING, INSPECTION, EVIDENCE, PUI, DESIGN, OR IMPLEMENTATION AUTHORITY`

Preserve:

`SOURCE IDENTITY CANDIDATE EMITTED != SOURCE CANDIDATE ACCEPTED`

`SOURCE IDENTITY CANDIDATE EMITTED != BOUNDED BASIS INSTANCE ACCEPTED`

`SOURCE IDENTITY CANDIDATE EMITTED != SOURCE-TARGET BINDING`

`SOURCE IDENTITY CANDIDATE EMITTED != SOURCE READ AUTHORITY`

## 7. Outcome B — MISS / non-blob / unresolved

If the exact object misses, cannot resolve, or is not a Git blob, label:

`EXPECTED OUTCOME B`

Emit no source identity candidate.

Terminal statement:

`H-01 BIB-03 SOURCE-PATH IDENTITY PROBE DID NOT ESTABLISH A GIT-BLOB IDENTITY FROM SOURCE-PATH-HYPOTHESIS-01 — FAIL CLOSED — NO SECOND HYPOTHESIS, FALLBACK PATH, SEARCH, ENUMERATION, OR SOURCE READ AUTHORITY`

No fallback probe.
No path correction.
No alternative hypothesis.

A conforming MISS is EXPECTED OUTCOME B, not automatically OPERATIONAL BLOCKED.

## 8. Protected-path and non-enumeration rule

Preserve exactly:

`NO REPOSITORY-WIDE OR DIRECTORY-WIDE FILE/PATH ENUMERATION IS AUTHORIZED.`

Do NOT use:

- `rg --files`;
- `find`;
- `fd`;
- `git ls-files`;
- `git ls-tree` for discovery;
- recursive `ls`, `dir`, or `tree`;
- repository/directory globs;
- GitHub code search;
- filename search;
- `git grep`.

FD02 remains protected and excluded.

Do not search for, reveal, open, read, hash, re-hash, inspect, cite, select, allowlist, modify, move, delete, stage, commit, or use FD02.

## 9. Read accounting

Cumulative accepted technical/config/source-content reads before and after this metadata-only execution remain exactly:

`11`

This execution performs:

- source-path metadata probes = `1`;
- source-content reads = `0`;
- technical/config content reads = `0`.

Metadata-only object identity does not increment the accepted content-read count.

## 10. Primary-agent-only execution

No helper/sub-agent may execute the probe, create/edit the execution artifact, commit, or push.

Helper/sub-agent probe/write/commit/push actions must remain `0`.

## 11. Future execution branch and artifact

Execution branch:

`review/h01-bib03-source-path-identity-probe-execution-v0.1`

Execution artifact:

`docs/architecture/ELITESYNC_V10_H01_BIB03_SOURCE_PATH_IDENTITY_PROBE_EXECUTION_V0_1.md`

Exact commit subject:

`docs: execute H-01 BIB-03 source-path identity probe v0.1`

Exactly one changed path is permitted.

Push only the execution branch exactly once, non-force.

Do not promote `main` during execution.

## 12. Mandatory counters

The execution artifact MUST explicitly record:

- Choice A / B / C = `YES / NO / NO`;
- accepted manifest identities = `1`;
- accepted package-root locators = `1`;
- accepted source-path hypotheses = `1`;
- source-path metadata probes executed in this invocation = `1`;
- source-path hits = `0` or `1`;
- source identity candidates emitted = `0` or `1`;
- source identity candidates accepted = `0`;
- source-content reads = `0`;
- technical/config content reads = `0`;
- bounded basis instances accepted = `0`;
- source-target bindings = `0`;
- repository / directory enumeration = `0 / 0`;
- filename / code searches = `0 / 0`;
- inspection = `0`;
- future source-read budgets = `0`;
- evidence = `0`;
- U-15 resolution = `0`;
- D-02 reopen = `0`;
- PUI changes / reconsideration / threshold claims = `0 / 0 / 0`;
- U-12 targets = `0`;
- design / implementation = `0 / 0`;
- telemetry / Safety Operations / legal research = `0 / 0 / 0`;
- LC-03 / LC-04 / Phase 36 = `0 / 0 / 0`;
- DeepSeek calls = `0`;
- cumulative accepted technical/config/source-content reads = exactly `11`;
- path-enumeration exposure = `0`;
- FD02 search/access = `0 / 0`;
- helper/sub-agent probe/write/commit/push actions = `0`.

## 13. Frozen project state

Preserve:

- `TP-SOURCE-CLASS-01` remains the sole abstract source-class envelope;
- `TP-TARGET-01` remains the sole evidence-subject target;
- bounded concrete identification basis instances accepted = `0`;
- source-target bindings = `0`;
- U-12 accepted concrete targets = `0`;
- all PUI entries remain deferred;
- PUI-PREREQ-12 threshold satisfaction = `0`;
- U-10 remains `UNRESOLVED`;
- U-14 exclusion unchanged;
- U-15 unresolved;
- D-02 remains `UNRESOLVED` with `D02-DURABLE-UNKNOWN-01` preserved;
- Backend remains `0/10 NOT INSPECTED / NOT AUTHORIZED`;
- Database remains `0/8 NOT INSPECTED / NOT AUTHORIZED`.

## 14. Stop point

A conforming execution must end exactly:

`STOP AFTER SOURCE-PATH IDENTITY PROBE EXECUTION — BEFORE SOURCE-CANDIDATE ACCEPTANCE, BASIS-INSTANCE ACCEPTANCE, SOURCE-TARGET BINDING, SOURCE READ, INSPECTION, SOURCE-READ-BUDGET AUTHORIZATION, EVIDENCE COLLECTION, PUI RECONSIDERATION, DESIGN, OR IMPLEMENTATION`
