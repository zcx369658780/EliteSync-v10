# EliteSync v10 H-01 BIB-03 Method-Execution Task Sheet v0.2

## 1. Purpose and publication non-authority

This document defines exactly one possible later execution:

`H-01 BIB-03 NON-ENUMERATIVE IDENTIFICATION METHOD EXECUTION V0.2 — METADATA ONLY`

Publication of this task sheet does not execute the method and does not authorize any exact-path probe, candidate acceptance, source-target binding, source-content read, technical/platform inspection, technical/source read budget, evidence collection, PUI reconsideration, design, or implementation.

Repository:

`zcx369658780/EliteSync-v10`

Publication parent authority:

`fa130f6437b8a801d7aff58d65d7b34b63705edd`

Controlling accepted BIB-03 method review:

`docs/architecture/ELITESYNC_V10_H01_TECHNICAL_PLATFORM_BIB03_NON_ENUMERATIVE_IDENTIFICATION_METHOD_REVIEW_V0_1.md`

Accepted method-review Git blob:

`7e4e9112e95025c52c6f6c127c23cf39dbe2a1a9`

Accepted prior BIB-03 execution record:

`docs/architecture/ELITESYNC_V10_H01_TECHNICAL_PLATFORM_BIB03_METHOD_EXECUTION_V0_1.md`

Prior execution Git blob:

`e27acfaf882157e258dd88494ff6f02740e64cee`

Prior accepted outcome:

`H-01 BIB-03 METHOD EXECUTION PRODUCED NO CANDIDATE IDENTIFIER — FAIL CLOSED — NO FALLBACK SEARCH OR SECOND HYPOTHESIS AUTHORIZED`

This v0.2 task sheet creates a NEW invocation. It is not a fallback inside the prior invocation.

Preserve:

`CURRENT INVOCATION EXHAUSTED != BIB-03 METHOD EXHAUSTED`

`NEW INVOCATION != FALLBACK SEARCH`

## 2. Protected-path and non-enumeration rule

Preserve exactly:

`NO REPOSITORY-WIDE OR DIRECTORY-WIDE FILE/PATH ENUMERATION IS AUTHORIZED.`

No repository listing, directory listing, filename search, wildcard search, code search, source-content search, neighboring-directory inspection, or broad source discovery is authorized.

FD02 remains protected and excluded. Do not search for it or independently re-prove its presence or uniqueness.

Historical incident remains historical only:

`PROTECTED-PATH ENUMERATION EXPOSURE — NO CONTENT ACCESS — STAGE A VOID`

## 3. Immutable probe baseline

The exact source-object probe baseline for this invocation is:

`fa130f6437b8a801d7aff58d65d7b34b63705edd`

Do not substitute another commit or branch.

Preserve:

`PROBE COMMIT != FUTURE REVIEW/EXECUTION COMMIT`

## 4. Exactly one predeclared hypothesis

Exactly one hypothesis is predeclared.

### BIB03-HYP-02

Origin class:

`HYP-ORIGIN-01 — DETERMINISTIC CONVENTION-BASED EXACT-PATH HYPOTHESIS ACCEPTED IN THE EXECUTION TASK SHEET`

Exact path:

`client/lib/main.dart`

Exact object hypothesis:

`fa130f6437b8a801d7aff58d65d7b34b63705edd:client/lib/main.dart`

Rationale is limited to deterministic convention: after the accepted root-level Flutter entry hypothesis `lib/main.dart` missed, a client-scoped Flutter application entry at `client/lib/main.dart` is a finite convention-based monorepo hypothesis consistent with the already accepted H-01 Flutter/client abstract source-class envelope.

This rationale does NOT establish that the path exists, that a client directory exists, that Flutter is implemented there, or that the object is relevant to `TP-TARGET-01`.

No second hypothesis is created.

No fallback hypothesis is authorized.

No sibling-path guess is authorized.

Preserve:

`HYPOTHESIS PREDECLARED != PATH EXISTS`

`PATH EXISTS != CANDIDATE ACCEPTED`

`CANDIDATE IDENTIFIED != CANDIDATE ACCEPTED`

`CANDIDATE ACCEPTED != SOURCE-TARGET BINDING`

## 5. Future exact metadata-only probe contract

A separately authorized execution may perform exactly one logical metadata-only probe against:

`fa130f6437b8a801d7aff58d65d7b34b63705edd:client/lib/main.dart`

Permitted logical operations are limited to exact-object existence and identity equivalents of:

`git cat-file -e fa130f6437b8a801d7aff58d65d7b34b63705edd:client/lib/main.dart`

If and only if existence is established:

`git rev-parse fa130f6437b8a801d7aff58d65d7b34b63705edd:client/lib/main.dart`

and, if needed:

`git cat-file -t <resolved-object-sha>`

The resolved object must be a Git `blob`.

No operation may emit source bytes.

Forbidden include `git show`, `git cat-file -p`, blob-content output, grep, source parsing, import inspection, line counting, source-content hashing, syntax analysis, diffing candidate content, or any source-content inspection.

Preserve:

`PATH EXISTENCE / METADATA PROBE != SOURCE CONTENT READ`

`PROBE BUDGET != READ BUDGET`

`EXACT-PATH METADATA PROBE != SOURCE INSPECTION`

`FAILED PROBE != AUTHORITY TO SEARCH`

## 6. Candidate identity rule

If and only if the exact hypothesis exists and resolves to one Git blob, a future execution may emit exactly one metadata-only candidate identifier in this form:

`zcx369658780/EliteSync-v10@fa130f6437b8a801d7aff58d65d7b34b63705edd:client/lib/main.dart#blob=<resolved-git-blob-sha>`

Candidate emission does not establish source-class membership or target relevance.

Preserve exactly:

`CONCRETE SOURCE IDENTIFIER != SOURCE CONTENT`

`CONCRETE SOURCE IDENTIFIER != CANDIDATE ACCEPTED`

`CONCRETE SOURCE IDENTIFIER != SOURCE-TARGET BINDING`

`CONCRETE SOURCE IDENTIFIER != INSPECTION AUTHORITY`

`CONCRETE SOURCE IDENTIFIER != READ BUDGET`

`CANDIDATE EMITTED != TP-SOURCE-CLASS-01 MEMBERSHIP ESTABLISHED`

`CANDIDATE EMITTED != TP-TARGET-01 RELEVANCE ESTABLISHED`

## 7. Fail-closed rule

If the exact path misses, cannot be resolved, is not a blob, or cannot be resolved under metadata-only authority:

- emit no candidate identifier;
- do not try another path;
- do not mutate the hypothesis;
- do not inspect neighboring paths;
- do not search filenames;
- do not enumerate repository or directory paths;
- do not create a third hypothesis inside the same invocation.

Preserve:

`ZERO HITS != NO RELEVANT SOURCE EXISTS`

`NO CANDIDATE FROM THIS INVOCATION != TP-SOURCE-CLASS-01 EMPTY`

`SECOND INVOCATION MISS != SOURCE ABSENCE`

## 8. Frozen project state

Preserve:

`TP-SOURCE-CLASS-01`

as the sole abstract source-class envelope.

Preserve:

`TP-TARGET-01`

as the sole evidence-subject target.

Preserve:

`CURRENT ACCEPTED BOUNDED CONCRETE IDENTIFICATION BASIS INSTANCES = 0`

Preserve:

`U-12 accepted concrete targets = 0`

All three PUI entries remain deferred.

`PUI-PREREQ-12 threshold satisfaction = 0`

U-10 remains `UNRESOLVED`.

U-14 exclusion remains unchanged.

U-15 fact values remain unresolved.

Preserve exactly:

`D02-DURABLE-UNKNOWN-01`

D-02 remains `UNRESOLVED`.

Backend remains:

`0/10 NOT INSPECTED / NOT AUTHORIZED`

Database remains:

`0/8 NOT INSPECTED / NOT AUTHORIZED`

Cumulative accepted technical/source-content reads remain exactly:

`10`

## 9. Execution branch and artifact contract

Future execution artifact:

`docs/architecture/ELITESYNC_V10_H01_TECHNICAL_PLATFORM_BIB03_METHOD_EXECUTION_V0_2.md`

Future execution branch:

`review/h01-bib03-method-execution-v0.2`

Future exact commit subject:

`docs: execute H-01 BIB-03 metadata identification method v0.2`

Exactly one changed path is permitted in the future execution.

Push only the review branch, exactly once, non-force.

Do not promote `main` during the execution invocation.

## 10. Required execution counters

A future execution must report:

- BIB-03 method executions in this invocation = `1` if probe attempted;
- exact-path hypotheses instantiated in this invocation = `1`;
- exact-path probes executed in this invocation = `1` if attempted;
- hypothesis hits = `0` or `1`;
- candidate identifiers emitted = `0` or `1`;
- candidate identifiers accepted = `0`;
- bounded basis instances accepted = `0`;
- concrete source-target bindings = `0`;
- repository-source metadata passes = `0` beyond the exact authorized probe;
- repository-wide source discovery = `0`;
- directory-wide source discovery = `0`;
- technical-source reads = `0`;
- source-content reads = `0`;
- Flutter/client source reads = `0`;
- runtime/test/build/config/manifest reads = `0`;
- technical/platform inspection actions = `0`;
- future technical/source read budgets selected = `0`;
- evidence added/collected = `0`;
- U-15 fact values resolved = `0`;
- D-02 reopen actions = `0`;
- PUI-ENTRY verdict changes = `0`;
- PUI-ENTRY reconsideration actions = `0`;
- PUI-PREREQ-12 threshold satisfactions claimed = `0`;
- U-12 concrete targets added = `0`;
- technical-design decisions = `0`;
- implementation actions = `0`;
- telemetry/analytics/measurement operations = `0`;
- Safety Operations = `0`;
- legal-research operations = `0`;
- LC-03 / LC-04 / Phase 36 actions = `0 / 0 / 0`;
- DeepSeek calls = `0`;
- cumulative accepted technical/source-content reads = exactly `10`;
- current-execution repository/directory path-enumeration exposure = `0`;
- current-execution FD02 search/access = `0 / 0`.

## 11. Terminal outcomes

Exactly one future terminal outcome is permitted.

### Outcome A

`H-01 BIB-03 METHOD EXECUTION V0.2 PRODUCED ONE METADATA-ONLY CANDIDATE IDENTIFIER — CANDIDATE NOT ACCEPTED OR BOUND — NO SOURCE CONTENT READ, INSPECTION, READ-BUDGET, EVIDENCE, PUI, DESIGN, OR IMPLEMENTATION AUTHORITY`

Use only if the exact hypothesis resolves to one Git blob and exactly one canonical candidate identifier is emitted.

### Outcome B

`H-01 BIB-03 METHOD EXECUTION V0.2 PRODUCED NO CANDIDATE IDENTIFIER — FAIL CLOSED — NO FALLBACK SEARCH OR ADDITIONAL HYPOTHESIS AUTHORIZED`

Use if the exact hypothesis misses, is not a blob, or cannot be resolved under metadata-only authority.

No third outcome.

Publication of this task sheet grants no probe-execution authority by itself.