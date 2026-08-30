# EliteSync v10 H-01 BIB-03 Manifest ML-1 Identity Execution Task Sheet v0.1

## 1. Purpose and publication non-authority

This document defines exactly one possible later execution:

`H-01 BIB-03 MANIFEST-GUIDED STAGE ML-1 IDENTITY EXECUTION — EXACT MANIFEST IDENTITY ONLY — NO CONTENT READ`

Repository:

`zcx369658780/EliteSync-v10`

Publication parent authority:

`4ab7e22ee97dbbe726663fbd9dbe517be40deeb5`

Controlling accepted method review:

`docs/architecture/ELITESYNC_V10_H01_BIB03_MANIFEST_GUIDED_BOUNDED_LOCATOR_METHOD_REVIEW_V0_1.md`

Accepted method-review Git blob:

`bba1f5d978d2dba9e240625ffe08c0d4ba40e3bb`

Controlling method model:

`BIB03-METHOD-02 — MANIFEST-GUIDED BOUNDED LOCATOR METHOD — STAGED EXACT-MANIFEST IDENTITY THEN SEPARATELY AUTHORIZED MINIMAL MANIFEST METADATA READ — NON-ENUMERATIVE — FAIL CLOSED`

Publication of this task sheet does NOT execute ML-1 and does NOT authorize:

- manifest content reads;
- YAML parsing;
- package-root identification;
- Stage ML-2;
- source-path hypotheses;
- source-content reads;
- technical/config read budget;
- candidate source identification;
- candidate acceptance;
- bounded basis-instance acceptance;
- source-target binding;
- inspection;
- evidence collection;
- U-15 fact resolution;
- PUI reconsideration;
- design;
- implementation;
- Safety Operations;
- legal research;
- LC-03;
- LC-04;
- Phase 36.

Preserve:

`METHOD MODEL ACCEPTED != METHOD EXECUTED`

`ML-1 TASK SHEET PUBLISHED != ML-1 EXECUTED`

`MANIFEST IDENTITY ESTABLISHED != MANIFEST CONTENT READ AUTHORIZED`

## 2. Exact publication/execution contract

Future execution artifact:

`docs/architecture/ELITESYNC_V10_H01_BIB03_MANIFEST_ML1_IDENTITY_EXECUTION_V0_1.md`

Future execution branch:

`review/h01-bib03-manifest-ml1-identity-execution-v0.1`

Future exact commit subject:

`docs: execute H-01 BIB-03 manifest ML-1 identity probe`

The future execution branch must be created exactly from this task-sheet publication commit.

The future execution must change exactly one path: the execution artifact above.

Do not promote `main` during ML-1 execution.

## 3. Protected-path and non-enumeration rule

Preserve exactly:

`NO REPOSITORY-WIDE OR DIRECTORY-WIDE FILE/PATH ENUMERATION IS AUTHORIZED.`

Do NOT use or authorize:

- `rg --files`;
- `find`;
- `fd`;
- `git ls-files`;
- recursive `ls`, `dir`, or `tree`;
- repository/directory path globs;
- GitHub code search;
- broad filename search;
- `git grep`;
- repository source discovery;
- directory source discovery;
- neighboring-directory inspection.

FD02 remains protected and excluded.

Do not search for, reveal, open, read, hash, re-hash, inspect, cite, select, allowlist, modify, move, delete, stage, commit, or use FD02.

Do not independently re-prove its presence or uniqueness.

Historical incident remains historical only:

`PROTECTED-PATH ENUMERATION EXPOSURE — NO CONTENT ACCESS — STAGE A VOID`

## 4. Exact immutable ML-1 probe baseline

All future ML-1 identity operations under this task sheet are pinned to exactly:

`4ab7e22ee97dbbe726663fbd9dbe517be40deeb5`

Do not substitute the task-sheet publication commit or any later commit.

Preserve:

`ML-1 PROBE COMMIT != ML-1 TASK-SHEET PUBLICATION COMMIT`

The immutable baseline is used only for exact manifest-object identity testing.

## 5. Exactly one predeclared manifest hypothesis

Although the accepted method ceiling permits up to three predeclared ML-1 probes, this invocation deliberately instantiates exactly one hypothesis to avoid predictable multiple-hit ambiguity among manifest types that may legitimately coexist.

### ML1-HYP-01

Origin class:

`MANIFEST-ORIGIN-01 — DETERMINISTIC STANDARD MANIFEST EXACT-PATH HYPOTHESIS PREDECLARED IN A SEPARATE EXECUTION TASK SHEET`

Exact manifest path hypothesis:

`pubspec.yaml`

Exact object hypothesis:

`4ab7e22ee97dbbe726663fbd9dbe517be40deeb5:pubspec.yaml`

Rationale is limited to deterministic Flutter/Dart package convention: `pubspec.yaml` is the standard root manifest hypothesis for a Flutter/Dart package or workspace. This does NOT establish that the repository root is a Flutter package, that the path exists, that the manifest is relevant to H-01, or that it identifies a package root.

No second manifest hypothesis is instantiated.

No fallback manifest hypothesis is authorized in this invocation.

Preserve:

`MANIFEST PATH HYPOTHESIS != MANIFEST EXISTS`

`MANIFEST EXISTS != MANIFEST RELEVANT`

`MANIFEST EXISTS != PACKAGE ROOT ACCEPTED`

`MANIFEST FILENAME CONVENTION != SOURCE PATH`

## 6. Exact future ML-1 metadata-only identity probe

A separately authorized execution may perform exactly one logical exact-object identity probe against:

`4ab7e22ee97dbbe726663fbd9dbe517be40deeb5:pubspec.yaml`

Allowed operations are limited to exact-object metadata equivalents of:

`git cat-file -e 4ab7e22ee97dbbe726663fbd9dbe517be40deeb5:pubspec.yaml`

If and only if existence is established:

`git rev-parse 4ab7e22ee97dbbe726663fbd9dbe517be40deeb5:pubspec.yaml`

and, if needed:

`git cat-file -t <resolved-object-sha>`

The resolved object must be a Git `blob`.

ML-1 may establish only:

1. exact manifest path existence;
2. Git object type;
3. Git blob SHA.

ML-1 must NOT emit, open, display, parse, summarize, tokenize, diff, grep, hash outside Git identity, or otherwise inspect manifest bytes.

Do NOT use:

- `git show` on the manifest;
- `git cat-file -p`;
- `git cat-file blob`;
- `git diff` for manifest content;
- `git grep`;
- YAML parsing;
- package/dependency parsing;
- any command or API that returns manifest content.

Preserve:

`MANIFEST IDENTITY PROBE != MANIFEST READ`

`MANIFEST IDENTITY PROBE != SOURCE INSPECTION`

`MANIFEST PROBE BUDGET != TECHNICAL/SOURCE READ BUDGET`

`MANIFEST IDENTITY ESTABLISHED != MANIFEST CONTENT READ AUTHORIZED`

## 7. Manifest identity output rule

If and only if ML1-HYP-01 exists and resolves to exactly one Git blob, emit exactly one manifest identity in canonical form:

`zcx369658780/EliteSync-v10@4ab7e22ee97dbbe726663fbd9dbe517be40deeb5:pubspec.yaml#blob=<resolved-git-blob-sha>`

This is a manifest identity only.

It is NOT:

- a manifest content read;
- a package-root locator candidate;
- a source identifier;
- candidate source acceptance;
- a bounded basis instance;
- a source-target binding;
- inspection authority;
- ML-2 authority.

Preserve:

`MANIFEST IDENTITY != MANIFEST CONTENT`

`MANIFEST IDENTITY != PACKAGE-ROOT LOCATOR CANDIDATE`

`MANIFEST IDENTITY != SOURCE IDENTIFIER`

`MANIFEST IDENTITY != ML-2 READ AUTHORITY`

## 8. Fail-closed rule

If the exact manifest path misses, cannot be resolved, is not a Git blob, or cannot be resolved without content exposure:

- emit no manifest identity;
- do not try another manifest path;
- do not mutate the hypothesis;
- do not infer a package root;
- do not search for manifests;
- do not inspect neighboring paths;
- do not create ML1-HYP-02 in this invocation;
- do not enter ML-2.

Preserve:

`ZERO MANIFEST HITS != NO RELEVANT SOURCE EXISTS`

`FAILED MANIFEST PROBE != AUTHORITY TO SEARCH`

`NO MANIFEST IDENTITY FROM THIS INVOCATION != NO MANIFEST EXISTS ELSEWHERE`

## 9. Stage ML-2 remains separately gated

Even if exactly one manifest identity is emitted, Stage ML-2 remains unauthorized.

Preserve exactly:

`MANIFEST READ IS A TECHNICAL/CONFIG READ`

`MANIFEST METADATA-ONLY SEMANTICS != ZERO-BYTE CONTENT READ`

`ANY FUTURE STAGE ML-2 MANIFEST CONTENT READ REQUIRES A SEPARATE TASK SHEET, EXPLICIT TECHNICAL/CONFIG READ BUDGET, AND INDEPENDENT GPT L3 REVIEW`

`MANIFEST IDENTITY ESTABLISHED != MANIFEST CONTENT READ AUTHORIZED`

No future ML-2 read budget is selected in this task sheet or its ML-1 execution.

Cumulative accepted technical/source-content reads remain exactly:

`10`

## 10. Frozen project state

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

Preserve:

`PUI-PREREQ-12 threshold satisfaction = 0`

U-10 remains `UNRESOLVED`.

U-14 exclusion remains unchanged.

U-15 fact values remain unresolved.

Preserve exactly:

`D02-DURABLE-UNKNOWN-01`

D-02 remains `UNRESOLVED` and is not reopened.

Backend remains:

`0/10 NOT INSPECTED / NOT AUTHORIZED`

Database remains:

`0/8 NOT INSPECTED / NOT AUTHORIZED`

## 11. Required future ML-1 execution counters

A future execution artifact must report:

- manifest-guided method executions = `1` if probe attempted;
- Stage ML-1 executions = `1` if probe attempted;
- Stage ML-2 executions = `0`;
- manifest-path hypotheses instantiated = exactly `1`;
- manifest identity probes executed = at most `1`;
- manifest hits = `0` or `1`;
- manifest identities emitted = `0` or `1`;
- manifest content reads = `0`;
- runtime/test/build/config/manifest reads = `0`;
- package-root locator candidates emitted = `0`;
- package-root locator candidates accepted = `0`;
- source-path hypotheses created = `0`;
- candidate source identifiers emitted = `0`;
- candidate source identifiers accepted = `0`;
- bounded basis instances accepted = `0`;
- concrete source-target bindings = `0`;
- repository-source metadata passes = `0` beyond the exact authorized manifest identity probe;
- repository-wide source discovery = `0`;
- directory-wide source discovery = `0`;
- technical-source reads = `0`;
- source-content reads = `0`;
- Flutter/client source reads = `0`;
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

## 12. Future execution terminal outcomes

Exactly one.

### Outcome A — one manifest identity

`H-01 BIB-03 STAGE ML-1 PRODUCED ONE MANIFEST IDENTITY — NO MANIFEST CONTENT READ — ML-2 REMAINS SEPARATELY GATED — NO PACKAGE-ROOT LOCATOR, SOURCE IDENTIFIER, BINDING, INSPECTION, EVIDENCE, PUI, DESIGN, OR IMPLEMENTATION AUTHORITY`

Use only if ML1-HYP-01 resolves to exactly one Git blob and exactly one canonical manifest identity is emitted.

### Outcome B — no manifest identity

`H-01 BIB-03 STAGE ML-1 PRODUCED NO MANIFEST IDENTITY — FAIL CLOSED — NO FALLBACK MANIFEST SEARCH OR ADDITIONAL MANIFEST HYPOTHESIS AUTHORIZED`

Use if ML1-HYP-01 misses, is not a blob, or cannot be resolved under identity-only authority.

No third outcome.

## 13. Publication terminal statement

`H-01 BIB-03 ML-1 IDENTITY EXECUTION TASK SHEET PUBLISHED — EXACTLY ONE PREDECLARED ROOT PUBSPEC MANIFEST HYPOTHESIS — NO MANIFEST PROBE OR CONTENT READ AUTHORITY CREATED BY PUBLICATION`

STOP AFTER ML-1 TASK-SHEET PUBLICATION — BEFORE MANIFEST IDENTITY PROBE, MANIFEST READ, ML-2, PACKAGE-ROOT LOCATOR IDENTIFICATION, SOURCE HYPOTHESIS, CANDIDATE ACCEPTANCE, BASIS-INSTANCE ACCEPTANCE, SOURCE-TARGET BINDING, INSPECTION, READ-BUDGET AUTHORIZATION, EVIDENCE COLLECTION, PUI RECONSIDERATION, DESIGN, OR IMPLEMENTATION
