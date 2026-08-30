# EliteSync v10 H-01 BIB-03 MANIFEST-ORIGIN-03 ML-1 Identity Execution Task Sheet v0.1

## 1. Purpose and publication non-authority

This document defines exactly one possible later execution:

`H-01 BIB-03 MANIFEST-ORIGIN-03 STAGE ML-1 EXACT OWNER-PATH IDENTITY EXECUTION — ONE EXACT METADATA PROBE — NO CONTENT READ — FAIL CLOSED`

Repository:

`zcx369658780/EliteSync-v10`

Publication parent authority / immutable probe baseline:

`33134dd23679bee4cee32f84782f255c1f0fb8cb`

Controlling durable Owner decision:

`docs/architecture/ELITESYNC_V10_H01_BIB03_OWNER_SUCCESSOR_SELECTION_A_EXACT_PATH_INPUT_DECISION_V0_1.md`

Controlling Owner-decision Git blob:

`64e4fdea8e944fe70c8e2fea0788f8405d2047ee`

Publication of this task sheet does NOT execute the probe and creates no content-read, source-read, binding, inspection, evidence, design, or implementation authority.

## 2. Exact accepted input state

Choice A is selected.

Choice B is not selected.

Choice C is not selected.

The sole Owner-supplied path input is:

`apps/flutter_elitesync_module/pubspec.yaml`

Input class:

`MANIFEST-ORIGIN-03 — EXACT OWNER-SUPPLIED MANIFEST PATH USED AS A BOUNDED FUTURE INPUT`

Input-instance count:

`1`

No second path, fallback path, neighboring path, inferred directory, wildcard, glob, or filename search is permitted.

Preserve:

`OWNER-SUPPLIED EXACT PATH != PATH EXISTS`

`OWNER-SUPPLIED EXACT PATH != MANIFEST IDENTITY ESTABLISHED`

`OWNER-SUPPLIED EXACT PATH != CANDIDATE ACCEPTED`

`OWNER-SUPPLIED EXACT PATH != BOUNDED BASIS INSTANCE ACCEPTED`

## 3. Owner-reported provenance is not probe evidence

The Owner previously reported an external legacy-repository Codex assertion that the path exists in EliteSync-v10 and is Git-tracked, with package identity `flutter_elitesync_module` and package root `apps/flutter_elitesync_module/`.

Those assertions MUST NOT be used to determine this execution result.

Preserve:

`OWNER-REPORTED PATH EXISTENCE != ML-1 HIT`

`OWNER-REPORTED GIT TRACKING != ML-1 HIT`

`OWNER-REPORTED PACKAGE IDENTITY != PACKAGE IDENTITY ACCEPTED`

`OWNER-REPORTED PACKAGE ROOT != PACKAGE ROOT ACCEPTED`

## 4. Exact immutable object

The only authorized object is:

`33134dd23679bee4cee32f84782f255c1f0fb8cb:apps/flutter_elitesync_module/pubspec.yaml`

Do not substitute the later task-sheet publication commit.

Preserve:

`ML-1 PROBE COMMIT != ML-1 TASK-SHEET PUBLICATION COMMIT`

## 5. Exact probe semantics

Execute exactly once:

`git cat-file -e 33134dd23679bee4cee32f84782f255c1f0fb8cb:apps/flutter_elitesync_module/pubspec.yaml`

If and only if the existence probe succeeds, execute:

`git rev-parse 33134dd23679bee4cee32f84782f255c1f0fb8cb:apps/flutter_elitesync_module/pubspec.yaml`

and, if needed to establish object type:

`git cat-file -t <resolved-object-sha>`

The resolved object must be a Git `blob`.

Allowed retained information is limited to:

1. existence / non-existence;
2. object type;
3. Git blob SHA;
4. the already-authorized exact path;
5. the immutable commit baseline.

No file bytes may be emitted or read.

Do NOT use:

- `git show`;
- `git cat-file -p`;
- `git cat-file blob`;
- `git diff` on the manifest content;
- YAML parsing;
- line counting;
- grep;
- any API/file fetch returning content.

## 6. Expected Outcome A — exact identity established

If the exact object resolves to one Git blob, emit exactly one manifest identity in this form:

`zcx369658780/EliteSync-v10@33134dd23679bee4cee32f84782f255c1f0fb8cb:apps/flutter_elitesync_module/pubspec.yaml#blob=<resolved-git-blob-sha>`

Label:

`EXPECTED OUTCOME A`

Terminal statement:

`H-01 BIB-03 MANIFEST-ORIGIN-03 STAGE ML-1 ESTABLISHED ONE EXACT OWNER-PATH MANIFEST IDENTITY — NO MANIFEST CONTENT READ — NO PACKAGE IDENTITY OR PACKAGE-ROOT ACCEPTANCE — NO BASIS-INSTANCE ACCEPTANCE, SOURCE-TARGET BINDING, INSPECTION, EVIDENCE, PUI, DESIGN, OR IMPLEMENTATION AUTHORITY`

Preserve:

`MANIFEST IDENTITY ESTABLISHED != MANIFEST CONTENT READ AUTHORIZED`

`MANIFEST IDENTITY ESTABLISHED != PACKAGE IDENTITY ACCEPTED`

`MANIFEST IDENTITY ESTABLISHED != PACKAGE ROOT ACCEPTED`

`MANIFEST IDENTITY ESTABLISHED != BOUNDED BASIS INSTANCE ACCEPTED`

`MANIFEST IDENTITY ESTABLISHED != SOURCE-TARGET BINDING`

`MANIFEST IDENTITY ESTABLISHED != INSPECTION AUTHORITY`

## 7. Expected Outcome B — exact path does not establish one blob identity

If the exact object does not exist, cannot be resolved, or is not a Git blob:

- emit no manifest identity;
- execute no fallback probe;
- search no alternative path;
- inspect no directory;
- infer no corrected path.

Label:

`EXPECTED OUTCOME B`

Terminal statement:

`H-01 BIB-03 MANIFEST-ORIGIN-03 STAGE ML-1 DID NOT ESTABLISH A MANIFEST IDENTITY FROM THE SOLE OWNER-SUPPLIED EXACT PATH — FAIL CLOSED — NO FALLBACK PATH, SEARCH, OR SECOND PROBE AUTHORIZED`

Preserve:

`OWNER EXACT-PATH MISS != NO RELEVANT MANIFEST EXISTS`

`OWNER EXACT-PATH MISS != TP-SOURCE-CLASS-01 EMPTY`

`OWNER EXACT-PATH MISS != AUTHORITY TO SEARCH`

A conforming miss is EXPECTED OUTCOME B, not automatically OPERATIONAL BLOCKED.

## 8. No content-read or ML-2 authority

Even on Outcome A:

- manifest content reads = `0`;
- ML-2 executions = `0`;
- package-root candidates = `0`;
- technical/source read budgets = `0`.

Any later manifest content read requires a separate exact task sheet, explicit technical/config read budget, and independent GPT L3 review.

Preserve:

`MANIFEST READ IS A TECHNICAL/CONFIG READ`

`MANIFEST IDENTITY != MANIFEST READ AUTHORITY`

## 9. Protected-path and non-enumeration rule

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
- `git grep`;
- repository source discovery;
- directory source discovery.

FD02 remains protected and excluded.

Do not search for, reveal, open, read, hash, re-hash, inspect, cite, select, allowlist, modify, move, delete, stage, commit, or use FD02.

## 10. Primary-agent-only execution

No helper/sub-agent may execute the exact probe, modify the worktree, create/edit the execution artifact, commit, or push.

Any helper/sub-agent probe/write/commit/push action:

`OPERATIONAL BLOCKED — EXECUTION PROVENANCE VIOLATION`

## 11. Future execution artifact and branch

Future execution artifact:

`docs/architecture/ELITESYNC_V10_H01_BIB03_MANIFEST_ORIGIN_03_ML1_IDENTITY_EXECUTION_V0_1.md`

Future execution branch:

`review/h01-bib03-manifest-origin-03-ml1-identity-execution-v0.1`

Future exact commit subject:

`docs: execute H-01 BIB-03 origin-03 ML-1 manifest identity probe v0.1`

Exactly one changed path is permitted.

Push only that review branch exactly once, non-force.

Do not promote `main` during execution.

## 12. Mandatory execution authority fields

The future execution artifact MUST record:

- task-sheet publication commit;
- task-sheet path;
- task-sheet Git blob;
- immutable probe baseline `33134dd23679bee4cee32f84782f255c1f0fb8cb`;
- Owner decision path;
- Owner decision Git blob `64e4fdea8e944fe70c8e2fea0788f8405d2047ee`;
- exact Owner-supplied path `apps/flutter_elitesync_module/pubspec.yaml`;
- exact probe command;
- exit code;
- hit/miss;
- resolved blob SHA only if hit;
- content bytes read = `0`.

Any mismatch before commit:

`OPERATIONAL BLOCKED — PUBLICATION-AUTHORITY OR OWNER-PATH RECORD MISMATCH`

## 13. Mandatory counters

The future execution artifact MUST explicitly record:

- successor Choice A selected = `YES`;
- Choice B selected = `NO`;
- Choice C selected = `NO`;
- Owner exact-path inputs supplied = `1`;
- MANIFEST-ORIGIN-03 exact-path input instances = `1`;
- ML-1 executions = `1`;
- exact path hypotheses instantiated = `1`;
- exact identity probes executed = `1`;
- manifest hits = `0` or `1`;
- manifest identities emitted = `0` or `1`;
- manifest content reads = `0`;
- ML-2 executions = `0`;
- package-root candidates emitted / accepted = `0 / 0`;
- package identities accepted = `0`;
- source hypotheses = `0`;
- candidate source identifiers emitted / accepted = `0 / 0`;
- bounded basis instances accepted = `0`;
- source-target bindings = `0`;
- repository / directory enumeration = `0 / 0`;
- filename / code searches = `0 / 0`;
- technical-source reads = `0`;
- source-content reads = `0`;
- Flutter/client source reads = `0`;
- inspection = `0`;
- future technical/source read budgets = `0`;
- evidence = `0`;
- U-15 resolution = `0`;
- D-02 reopen = `0`;
- PUI changes / reconsideration / threshold claims = `0 / 0 / 0`;
- U-12 targets = `0`;
- design / implementation = `0 / 0`;
- telemetry / Safety Operations / legal research = `0 / 0 / 0`;
- LC-03 / LC-04 / Phase 36 = `0 / 0 / 0`;
- DeepSeek calls = `0`;
- cumulative accepted technical/source-content reads = exactly `10`;
- path-enumeration exposure = `0`;
- FD02 search/access = `0 / 0`;
- helper/sub-agent probe/write/commit/push actions = `0`.

## 14. Frozen project state

Preserve:

- `TP-SOURCE-CLASS-01` remains sole abstract source-class envelope;
- `TP-TARGET-01` remains sole evidence-subject target;
- accepted bounded concrete identification basis instances = `0`;
- U-12 accepted concrete targets = `0`;
- all PUI entries remain deferred;
- PUI-PREREQ-12 threshold satisfaction = `0`;
- U-10 remains `UNRESOLVED`;
- U-14 exclusion unchanged;
- U-15 unresolved;
- D-02 remains `UNRESOLVED` with `D02-DURABLE-UNKNOWN-01` preserved;
- Backend `0/10 NOT INSPECTED / NOT AUTHORIZED`;
- Database `0/8 NOT INSPECTED / NOT AUTHORIZED`;
- cumulative accepted technical/source-content reads exactly `10`.

## 15. Execution stop point

A later conforming execution must end exactly:

`STOP AFTER MANIFEST-ORIGIN-03 ML-1 EXACT OWNER-PATH IDENTITY EXECUTION — BEFORE MANIFEST CONTENT READ, ML-2, PACKAGE-ROOT ACCEPTANCE, PACKAGE-IDENTITY ACCEPTANCE, CANDIDATE ACCEPTANCE, BASIS-INSTANCE ACCEPTANCE, SOURCE-TARGET BINDING, INSPECTION, READ-BUDGET AUTHORIZATION, EVIDENCE COLLECTION, PUI RECONSIDERATION, DESIGN, OR IMPLEMENTATION`
