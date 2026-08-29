# EliteSync v10 H-01 Flutter/Client First Presentation-Semantics Design Retry Task Sheet v0.1

## 1. Purpose and incident disposition

This document records the prior fail-closed Stage A attempt and defines exactly one possible later retry execution contract:

`H-01 FLUTTER/CLIENT FIRST TARGET-INDEPENDENT PRESENTATION-SEMANTICS DESIGN — STAGE A RETRY — NORMATIVE DESIGN ONLY`

Prior attempt disposition:

`PROTECTED-PATH ENUMERATION EXPOSURE — NO CONTENT ACCESS — STAGE A VOID`

The prior attempt produced no Stage A artifact, no commit, no push, no design decision, no evidence, no D-02 reopen action, and no technical/source-content read. It does not alter any accepted H-01 decision, UNKNOWN disposition, API/Backend/Database state, or cumulative accepted technical/source-content read count.

Publication of this retry task sheet does not itself authorize retry execution or any successor work.

Repository:

`zcx369658780/EliteSync-v10`

Publication parent authority:

`383005dd3c3f60b0a24f92b05c2905bb07b0cb90`

## 2. Controlling design contract

The substantive Stage A design ceiling remains exactly the contract defined by:

`docs/architecture/ELITESYNC_V10_H01_FLUTTER_CLIENT_FIRST_PRESENTATION_SEMANTICS_DESIGN_TASK_SHEET_V0_1.md`

Git blob:

`6c6687a551b4f4925b178123248a7394da5c504a`

This retry task sheet changes only execution/bootstrap safety and retry branch identity. It does not expand the nine-dimension design ceiling, source budget, presentation authority, or successor authority.

Future Stage A artifact remains exactly:

`docs/architecture/ELITESYNC_V10_H01_FLUTTER_CLIENT_FIRST_PRESENTATION_SEMANTICS_DESIGN_V0_1.md`

Retry review branch:

`review/h01-psem-retry-task-sheet-authoring-temp`

The branch name is intentionally retained because the ref already exists at the prior publication baseline and contains no retry design commit. It is repurposed as the sole authorized retry review branch. It must not be deleted, reset, force-moved, renamed, or substituted.

Future commit subject remains exactly:

`docs: design H-01 Flutter client first presentation semantics`

## 3. Protected FD02 boundary — strengthened retry rule

FD02 remains protected and excluded.

The prior failure establishes an additional execution rule for this retry:

`NO REPOSITORY-WIDE OR DIRECTORY-WIDE FILE/PATH ENUMERATION IS AUTHORIZED.`

The retry must not run any command or tool whose purpose or ordinary output can enumerate repository file paths or directory contents, including but not limited to:

- `rg --files`;
- `find`;
- `fd`;
- `git ls-files`;
- recursive `ls`, `dir`, `tree`, or equivalent directory listings;
- wildcard/glob expansion over repository paths;
- repo-wide filename search;
- path discovery by grep/search over directory listings;
- source discovery or source-identification operations;
- any tool call that lists repository files for convenience, validation, or orientation.

The retry must not search for FD02, test for its filename by search, or enumerate surrounding paths to prove its presence or uniqueness.

FD02 content must not be opened, read, hashed, modified, moved, deleted, staged, committed, cited, selected, allowlisted, inspected, or used.

The retry is not required to independently re-prove that FD02 is the sole untracked deviation by enumerating untracked paths. That fact may be inherited from the immediately preceding accepted Owner execution state unless an otherwise-authorized operation independently reveals a contradictory tracked-workspace condition.

## 4. Safe bootstrap allowlist

Before Stage A authoring, only the following bootstrap operations are authorized:

1. `git fetch origin`;
2. exact branch/HEAD/ref comparison commands that do not enumerate repository files;
3. tracked-cleanliness checks that suppress untracked enumeration, such as `git diff --quiet`, `git diff --cached --quiet`, or equivalent tracked-only checks;
4. `git stash list`;
5. `git worktree list --porcelain`;
6. exact-path reads of the already-known governance/normative documents explicitly named by the controlling task sheet;
7. branch switch/creation only as explicitly authorized below.

Do not use general repository status/listing commands if their output would enumerate untracked repository paths. If a cleanliness check cannot be performed without path enumeration, omit that specific check and fail closed only if tracked cleanliness itself cannot be established by the allowed tracked-only commands.

## 5. Retry synchronization and branch authority

A later startup authority must supply the exact retry-task-sheet publication commit.

If local `main` is a clean strict ancestor of `origin/main`, Owner may authorize only:

`git merge --ff-only origin/main`

Preconditions:

- no divergence;
- no local-only commit on `main`;
- tracked staged changes `0`;
- tracked unstaged changes `0`;
- stash empty;
- exactly one registered worktree;
- no repository path enumeration performed.

If currently on the prior local review branch from the failed attempt, switching to `main` is authorized only if there is no Stage A artifact, no commit, and tracked changes are `0/0`.

After synchronization, the retry review branch named in Section 2 must point exactly to the retry-task-sheet publication commit before authoring. Moving that existing ref forward is authorized only as a non-force fast-forward. No reset, rebase, force move, or substitute review branch is authorized.

## 6. Stage A design ceiling remains unchanged

Exactly nine dimensions may receive exactly nine records:

`PSEM-DIM-01..09` -> `PSEM-DD-01..09`

Every record must satisfy all 17 fields from the controlling task sheet.

No tenth dimension is permitted.

Hard-deferred states remain exact:

- `PUI-ENTRY-10 — DEFERRED TO LATER PRESENTATION / EVIDENCE / TECHNICAL GATE`;
- `PUI-ENTRY-11 — DEFERRED TO LATER PRESENTATION / EVIDENCE / TECHNICAL GATE`;
- `PUI-ENTRY-12 — DEFERRED TO LATER PRESENTATION / EVIDENCE / TECHNICAL GATE`.

Therefore:

- user-visible copy authored `0`;
- accessibility techniques selected `0`;
- accessibility/comprehension effectiveness claims `0`;
- concrete UI structure decisions `0`;
- technical-design decisions `0`;
- implementation actions `0`.

## 7. Preserved durable governance state

Preserve exactly:

`D02-DURABLE-UNKNOWN-01`

Preserve exactly:

`D-02 DURABLY UNRESOLVED / UNKNOWN FOR CURRENT AUTHORITY — CURRENT LOW-EXPANSION EVIDENCE PATH CLOSED — REOPEN ONLY ON MATERIAL NEW AUTHORITY/EVIDENCE BASIS`

D-02 remains unresolved and closed.

The six API verdicts remain unchanged. Backend remains `0/10 NOT INSPECTED / NOT AUTHORIZED`. Database remains `0/8 NOT INSPECTED / NOT AUTHORIZED`.

Cumulative accepted technical/source-content reads remain exactly `10`.

U-10 remains unresolved; U-12 concrete targets remain `0`; U-14 exclusion remains controlling; U-15 runtime/correspondence/feasibility/persistence/platform/implementation/target facts remain unresolved outside exact accepted ceilings.

## 8. Zero source/prototype/evidence budget

Retry budget:

- technical-source reads `0`;
- source-content reads `0`;
- Flutter/client source reads `0`;
- screenshot/prototype/design-file reads `0`;
- candidate/correspondence reads `0`;
- source-identification operations `0`;
- repository-source metadata passes `0`;
- D-02 reopen actions `0`;
- evidence added `0`;
- API/Backend/Database verdict changes `0`;
- participant/data/private-Conversation operations `0`;
- telemetry/analytics/measurement `0`;
- Safety Operations `0`;
- legal research `0`;
- implementation `0`.

## 9. Retry honesty rule for protected-path exposure

The retry artifact must distinguish:

- prior failed-attempt protected-path enumeration exposure: `1` historical incident;
- current retry protected-path enumeration exposure: required `0`.

The prior incident does not make the retry fail if it is accurately recorded as historical and no new prohibited enumeration occurs.

Any new repository path enumeration or FD02 search exposure during the retry is an immediate whole-task fail-closed stop before artifact commit/push.

## 10. Required retry artifact additions

In addition to every section required by the controlling task sheet, the Stage A artifact must include:

1. prior-attempt incident disposition;
2. safe-bootstrap attestation;
3. current-retry repository-wide/directory-wide path enumeration operations: `0`;
4. current-retry FD02 prohibited path-search exposure: `0`;
5. confirmation that all substantive document reads used exact already-known paths only.

## 11. Publication / execution separation

This retry task-sheet publication does not authorize Stage A execution.

A later exact Owner startup authority must name:

- this retry task-sheet publication commit;
- this retry task-sheet path;
- the original controlling task-sheet blob `6c6687a551b4f4925b178123248a7394da5c504a`;
- the exact future artifact path;
- the exact retry review branch;
- the no-path-enumeration bootstrap rule;
- the nine-dimension ceiling;
- hard-deferred PUI-ENTRY-10..12;
- zero technical/prototype/evidence budget;
- terminal stop for independent GPT L3 review.

## 12. Current publication contract

For this publication only:

- parent `383005dd3c3f60b0a24f92b05c2905bb07b0cb90`;
- create exactly this retry task sheet on `main`;
- no source/prototype/design execution;
- commit subject `docs: add H-01 Flutter client presentation semantics retry task sheet`;
- push only `main`, non-force;
- after publication, fast-forward the already-existing retry review ref in Section 2 to the exact publication commit, non-force only;
- no other ref changes;
- stop before retry execution.

## 13. Terminal statement

`H-01 FIRST PRESENTATION-SEMANTICS STAGE A RETRY CONTRACT DEFINED — PRIOR ATTEMPT VOID — NO PATH ENUMERATION, DESIGN EXECUTION, TECHNICAL DESIGN, IMPLEMENTATION, OR SUCCESSOR AUTHORITY`
