# EliteSync v10 H-01 BIB-03 U-12 Target-Locator Minimal Discovery-Method Governance Task Sheet v0.1

Status: `PROPOSED — U-12 MINIMAL TARGET-LOCATOR DISCOVERY-METHOD GOVERNANCE REVIEW ONLY — ACCEPTED DISCOVERY-AUTHORITY ENTRY = 1 — METHOD SELECTION = 0 — DISCOVERY EXECUTION = 0 — ZERO SOURCE READS`

Review branch:

`review/h01-bib03-u12-target-locator-minimal-discovery-method-governance-v0-1`

Exact durable live-main authority required at task start:

`2011e0735aabd20688b0d08738fb63e668fd5ee6`

This task sheet is issued under Owner-delegated bounded governance for exactly one purpose: independently determine whether one predeclared minimal target-side locator discovery method may be selected for a later separately authored execution task.

This task does NOT execute discovery, does NOT require the Owner to provide a locator now, does NOT resolve or name a locator, does NOT read source content, and does NOT authorize technical design or implementation.

## 1. Durable gate-start state

Preserve exactly:

- accepted U-12 target-locator discovery-authority entry governance reviews = `1`
- durable discovery-authority entry outcome = `OUTCOME A / RE-OPENABLE FOR LATER METHOD GOVERNANCE ONLY`
- durable target-locator resolution outcome = `EXPECTED OUTCOME B / FAIL CLOSED`
- U-12 target definition = `1 durable`
- discovery methods selected = `0`
- discovery executions = `0`
- locator definitions = `0`
- accepted source-path hits = `0`
- target-side concrete locator hits = `0`
- source reads = `0`
- old-repository access = `0`
- source-repository access = `0`
- accepted / unauthorized content-read ledger = `13 / 1`
- cumulative unauthorized enumeration incidents = `2`
- `POST-E3 PROMOTION PUSH-OPERATION COUNT = UNKNOWN / NOT INDEPENDENTLY VERIFIABLE`
- `OWNER LIMITATION — CURRENT SHA IS THE LATEST VERSION TO INHERIT = UNPROVEN`

Exact durable discovery-authority entry artifact:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U12_TARGET_LOCATOR_DISCOVERY_AUTHORITY_ENTRY_GOVERNANCE_REVIEW_V0_1.md`

Required blob:

`375273dc45dd140f9e6a1c020a415a90765da5ab`

Exact durable U-12 governance target remains:

`U-12 EXACT-SCOPE GOVERNANCE TARGET = TP-TARGET-01 — THE SOLE ABSTRACT EVIDENCE-SUBJECT TARGET ALREADY DURABLY DEFINED BY ELITESYNC-V10 GOVERNANCE — NO SOURCE PATH, TARGET PATH, LOCATOR, IMPLEMENTATION OBJECT, RUNTIME OBJECT, BACKEND/DATABASE OBJECT, OR SOURCE CONTENT IS PART OF THIS TARGET DEFINITION.`

## 2. Sole predeclared method candidate

The only method candidate under this gate is:

`MDM-01 = OWNER-SUPPLIED EXACT ELITESYNC-V10 REPOSITORY-RELATIVE TARGET-SIDE CANDIDATE LOCATOR + SINGLE EXACT V10-ONLY NON-CONTENT GIT-OBJECT EXISTENCE/TYPE CHECK AGAINST ONE PREDECLARED DURABLE REVISION`

MDM-01 semantics:

1. A future execution task may accept exactly one repository-relative candidate target locator supplied explicitly by the Owner.
2. The candidate locator MUST be supplied before execution; the execution session MUST NOT derive, guess, normalize, complete, expand, or search for it.
3. The execution task may predeclare exactly one durable EliteSync-v10 Git revision against which the candidate is checked.
4. The only permitted locator test is an exact non-content Git-object existence/type check such as:
   - `git cat-file -e <EXACT_REVISION>:<EXACT_OWNER_SUPPLIED_PATH>`
   - optionally `git cat-file -t <EXACT_REVISION>:<EXACT_OWNER_SUPPLIED_PATH>`
5. `git cat-file -p`, blob-content output, file reads, diffs, source reads, directory listing, path enumeration, code search, filename search, globs, recursive inspection, and fallback candidate generation are forbidden.
6. A failed exact check MUST fail closed and MUST NOT trigger a second guessed path.
7. A successful exact existence/type check would still be only a later execution result; it would not itself authorize source reads, technical design, implementation, evidence/PUI processing, LC-03, LC-04, or Phase 36.

MDM-01 is intentionally confirmation-like rather than exploratory: it can test one exact Owner-supplied candidate without granting repository search or content-read capability.

## 3. Mandatory distinctions

Preserve exactly:

`DISCOVERY METHOD SELECTED != DISCOVERY METHOD EXECUTED`

`DISCOVERY METHOD SELECTED != LOCATOR RESOLVED`

`DISCOVERY METHOD SELECTED != SOURCE READ AUTHORITY`

`DISCOVERY METHOD SELECTED != SOURCE-PATH AUTHORITY`

`MDM-01 != REPOSITORY ENUMERATION`

`MDM-01 != CODE SEARCH`

`MDM-01 != FILENAME SEARCH`

`MDM-01 != PATH GUESSING`

`MDM-01 != SOURCE CONTENT READ`

`MDM-01 != TECHNICAL DESIGN AUTHORITY`

`MDM-01 != IMPLEMENTATION AUTHORITY`

`OWNER-SUPPLIED CANDIDATE LOCATOR != ACCEPTED LOCATOR`

`EXACT EXISTENCE CHECK PASS != LOCATOR SUITABILITY FOR IMPLEMENTATION`

## 4. Sole governance question

Determine ONLY:

`IS MDM-01 — OWNER-SUPPLIED EXACT ELITESYNC-V10 REPOSITORY-RELATIVE TARGET-SIDE CANDIDATE LOCATOR PLUS ONE EXACT V10-ONLY NON-CONTENT GIT-OBJECT EXISTENCE/TYPE CHECK — ADMISSIBLE AS THE SOLE MINIMAL TARGET-LOCATOR DISCOVERY METHOD FOR A LATER SEPARATELY AUTHORED EXECUTION TASK, WHILE METHOD EXECUTIONS, LOCATOR DEFINITIONS, SOURCE-PATH HITS, TARGET-SIDE LOCATOR HITS, SOURCE READS, CODE/FILENAME SEARCHES, AND REPOSITORY ENUMERATION ALL REMAIN ZERO NOW?`

No method execution, locator value, path value, source read, technical design, implementation, evidence/PUI, legal, Safety, lifecycle, LC-03, LC-04, or Phase 36 question may be decided here.

## 5. Outcome A — MDM-01 selected as sole minimal method

Outcome A is permitted only if MDM-01 is sufficiently bounded, non-enumerative, non-content-reading, reversible, and fail-closed for later exact execution governance.

Required Outcome A classification:

`U-12 TARGET-LOCATOR MINIMAL DISCOVERY-METHOD GOVERNANCE = MDM-01 SELECTED AS THE SOLE BOUNDED METHOD FOR LATER SEPARATELY AUTHORED EXECUTION — OWNER-SUPPLIED EXACT CANDIDATE LOCATOR REQUIRED — ONE EXACT V10-ONLY NON-CONTENT GIT-OBJECT EXISTENCE/TYPE CHECK ONLY — ZERO DISCOVERY EXECUTION NOW — ZERO LOCATOR DEFINITIONS — ZERO SOURCE READS — ZERO CODE/FILENAME SEARCH — ZERO REPOSITORY ENUMERATION — ZERO TECHNICAL-DESIGN/IMPLEMENTATION AUTHORITY`

Candidate-stage accounting only:

- candidate U-12 minimal discovery-method governance reviews = `1`
- accepted U-12 minimal discovery-method governance reviews = `0` pending fresh GPT L3 independent acceptance and durable promotion
- discovery methods selected = `1 candidate / 0 durable`
- selected method candidate = `MDM-01`
- discovery executions = `0`
- locator definitions = `0`
- accepted source-path hits = `0`
- target-side concrete locator hits = `0`
- source reads = `0`
- old-repository access = `0`
- source-repository access = `0`
- network fetch/pull = `0`

Outcome A does NOT execute MDM-01. Even after later independent acceptance and promotion, an exact execution task remains mandatory.

## 6. Expected Outcome B — MDM-01 not selected

If MDM-01 is not sufficiently bounded or cannot be safely governed without creating prohibited authority, classify exactly:

`EXPECTED OUTCOME B — NO MINIMAL TARGET-LOCATOR DISCOVERY METHOD SELECTED UNDER CURRENT DURABLE GOVERNANCE — FAIL CLOSED — DISCOVERY-AUTHORITY ENTRY OUTCOME PRESERVED — METHOD SELECTION / EXECUTION REMAIN 0 / 0 — LOCATOR DEFINITIONS REMAIN 0 — ZERO NEW SOURCE-READ/SEARCH/ENUMERATION AUTHORITY CREATED`

Outcome B MUST NOT trigger invention of MDM-02, code search, filename search, path guessing, repository enumeration, source access, or implementation inspection.

## 7. Mandatory zero-activity semantics

This governance review MUST perform ZERO:

- Owner locator collection or solicitation during the substantive review;
- MDM-01 execution;
- old `D:\EliteSync` access;
- source-repository access;
- source commit dereference;
- source content reads;
- source-path discovery;
- target-locator discovery;
- exact-path existence checks;
- `git cat-file` execution for locator testing;
- code search;
- filename search;
- repository-wide or directory-wide enumeration;
- path guessing or locator guessing;
- package/module/class/function/component discovery;
- implementation inspection;
- backend/database inspection;
- evidence/PUI processing;
- technical design;
- implementation;
- LC-03;
- LC-04;
- Phase 36;
- FD02 access/search/hash/inspection/use.

Preserve:

`discovery executions = 0`

`locator definitions = 0`

`accepted source-path hits = 0`

`target-side concrete locator hits = 0`

`source reads = 0`

`old-repository access = 0`

`source-repository access = 0`

`network fetch/pull = 0`

## 8. Permanent enumeration boundary

Preserve exactly:

`NO REPOSITORY-WIDE OR DIRECTORY-WIDE FILE/PATH ENUMERATION IS AUTHORIZED.`

Forbidden includes `rg --files`, `find`, `fd`, `git ls-files`, `git ls-tree`, recursive `ls`, recursive `dir`, `tree`, repository/directory globs, GitHub code search, filename search, `git grep`, `git status`, `git status --short`, and untracked-file checks.

Allowed EliteSync-v10 cleanliness checks only remain:

- `git diff --quiet`
- `git diff --cached --quiet`
- `git stash list`
- `git worktree list --porcelain`

## 9. Permanent governance boundaries

README documentary-read budget remains exhausted.

FD02 remains permanently excluded.

Preserve exact BIB03 enumeration incident and the rule:

`Do not inspect, reconstruct, summarize, search within, or use prior enumeration output.`

Preserve accepted / unauthorized content-read ledger = `13 / 1`.

Preserve cumulative unauthorized enumeration incidents = `2`.

Preserve D-02 unresolved / `D02-DURABLE-UNKNOWN-01`, U-15 unresolved, U-14 exclusion, every accepted U-12 exact-scope rule, `TP-SOURCE-CLASS-01`, `TP-TARGET-01`, Backend `0/10 NOT INSPECTED / NOT AUTHORIZED`, Database `0/8 NOT INSPECTED / NOT AUTHORIZED`, deferred PUI, and PUI-PREREQ-12=`0`.

Technical design unauthorized.
Implementation unauthorized.
LC-03 unauthorized.
LC-04 unauthorized.
Phase 36 unauthorized.

Preserve exactly:

`OWNER LIMITATION — CURRENT SHA IS THE LATEST VERSION TO INHERIT = UNPROVEN`

`POST-E3 PROMOTION PUSH-OPERATION COUNT = UNKNOWN / NOT INDEPENDENTLY VERIFIABLE`

## 10. Required result and publication

For Outcome A or Expected Outcome B create exactly:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U12_TARGET_LOCATOR_MINIMAL_DISCOVERY_METHOD_GOVERNANCE_REVIEW_V0_1.md`

Candidate sole parent must be the exact task-sheet commit created by this authoring action.

Relative to that task-sheet commit:

- `ahead_by = 1`
- `behind_by = 0`
- changed-path count = `1`
- sole changed path = the result artifact above

Required candidate commit subject:

`docs: review H-01 BIB-03 U-12 minimal target locator discovery method governance`

Publish non-force only to:

`review/h01-bib03-u12-target-locator-minimal-discovery-method-governance-v0-1`

Do NOT promote `main`.

Do NOT execute MDM-01.

Do NOT request or record an Owner-supplied locator in the result artifact.

After candidate publication, STOP.

A fresh GPT L3 must independently ACCEPT or REJECT the exact candidate before durable promotion.

Even after later Outcome A acceptance/promotion, MDM-01 execution remains a separate exact task and source reads, technical design, and implementation remain separately governed.