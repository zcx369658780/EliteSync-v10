# EliteSync v10 H-01 BIB-03 NR-METHOD-03 Bounded One-Probe Task Authoring Review Task Sheet v0.1

Status: `PROPOSED — TASK-SHEET AUTHORING/REVIEW ONLY — ZERO METADATA-OBJECT CONTENT READS — ZERO PROBES — ZERO OLD-REPOSITORY ACCESS — NO SOURCE CANDIDATE EMISSION`

Review branch: `review/h01-bib03-nr-method-03-bounded-one-probe-task-authoring-v0-1`

Exact live-main authority required: `bf483f4ab02a6e08e3d5d3587ce5de2753d7da61`

Accepted method-selection artifact: `docs/architecture/ELITESYNC_V10_H01_BIB03_NR_METHOD_03_METHOD_SELECTION_GOVERNANCE_REVIEW_V0_1.md`
Required blob: `3339fa62bcee86444ca2d589522642b2540ff332`

Durable method state at gate start:
- selected method = `NR-METHOD-03 — Single exact known non-README metadata-object probe`
- durable selected-method count = `1`
- durable eligible-method count = `1`
- executed methods = `0`
- execution/probe task sheets = `0`
- metadata probes/content reads = `0 / 0`
- durable verified PA-03 identities = `1`

Exact verified metadata object:
- repository = `zcx369658780/EliteSync`
- commit = `0f06e895a89629a7f4f0cf0c62b784446ecf515a`
- path = `apps/flutter_elitesync_module/pubspec.yaml`
- blob = `7ecd2f6835af9ceb1d67822adbac93d7fa07a939`

Preserve: `METHOD SELECTION != PROBE/READ AUTHORITY`; `METHOD SELECTION != EXECUTION TASK AUTHORITY`.

## Sole governance question

`CAN EXACTLY ONE FUTURE NR-METHOD-03 EXECUTION TASK BE AUTHORED TO READ THE VERIFIED PA-03 METADATA OBJECT CONTENT EXACTLY ONCE, INSPECT ONLY BOUNDED DEPENDENCY-SOURCE METADATA, AND PRODUCE PREDECLARED ZERO/ONE/MULTIPLE EXPLICIT SOURCE-LOCATOR-CANDIDATE OUTCOMES WITHOUT SEARCH, ENUMERATION, EXTERNAL RESOLUTION, NORMALIZATION, SOURCE-CONTENT READS, OR METHOD FALLBACK?`

This authoring review performs no probe and does not access the old repository.

## Required future task envelope

Outcome A is permitted only if the candidate future probe task can be constrained to ALL of the following.

### Exact object and one-read budget

A later, separately accepted/promoted execution may access only the exact verified metadata object above.

It may perform exactly one content-bearing read of that exact blob/file for metadata parsing. It may not read any other old-repository file or object content.

The later execution must record one authorized metadata-content read. Until that execution result is independently accepted/promoted, the durable accepted read ledger remains `12`; if a lawful one-read result is later accepted/promoted, the durable accepted read ledger may become `13`. This authoring review itself leaves the ledger at `12 / 1`.

### Bounded metadata inspection scope

The later task may inspect only dependency declarations under these exact top-level YAML mappings if present:
- `dependencies`
- `dev_dependencies`
- `dependency_overrides`

It may use structural YAML parsing only to identify direct dependency source forms in those mappings.

It must NOT inspect or use unrelated top-level metadata such as description, homepage, repository, issue tracker, authors, documentation, environment, flutter assets, scripts, or any other section for source identification.

### Qualifying source-locator candidate grammar

A qualifying candidate must be an explicit literal, non-local, self-contained source locator already written directly inside one dependency declaration and requiring ZERO synthesis, concatenation, normalization, registry lookup, external resolution, search, inference, or substitution.

Only these source forms may qualify:
1. a direct scalar locator under a dependency `git` source form; or
2. an explicit literal `url` value inside that dependency's `git` source form.

Optional sibling `ref` or `path` metadata may be reported only as literal companion metadata attached to the same qualifying git locator; it must not be concatenated into or used to rewrite the locator.

The dependency key/name may be reported only as exact contextual metadata; it is not itself a locator.

The following NEVER qualify:
- package name plus version constraint;
- hosted package name/version without an explicit self-contained source locator;
- `sdk` dependency forms;
- local `path` dependency forms;
- workspace/local-relative references;
- root-level repository/homepage/documentation fields;
- values obtained from YAML interpolation, external files, lockfiles, package registries, Git remotes, README, memory, prior incident exposure, web/network lookup, or external knowledge;
- reconstructed or normalized URI/package coordinates.

Preserve: `METADATA CANDIDATE EXTRACTION != URI NORMALIZATION`; `METADATA CANDIDATE EXTRACTION != SOURCE IDENTITY ACCEPTANCE`.

### Zero / one / multiple result envelope

The later execution must classify exactly one of:

`P0 — NR-METHOD-03 ONE-PROBE COMPLETED — ZERO QUALIFYING EXPLICIT SOURCE-LOCATOR CANDIDATES — FAIL CLOSED — NO SEARCH/NORMALIZATION/FALLBACK`

`P1 — NR-METHOD-03 ONE-PROBE COMPLETED — EXACTLY ONE QUALIFYING EXPLICIT SOURCE-LOCATOR CANDIDATE EMITTED AS CANDIDATE ONLY — ZERO NORMALIZATION — ZERO SOURCE IDENTITY ACCEPTANCE — NO SOURCE READ AUTHORITY CREATED`

`PM — NR-METHOD-03 ONE-PROBE COMPLETED — MULTIPLE QUALIFYING EXPLICIT SOURCE-LOCATOR CANDIDATES — FAIL CLOSED — NO RANKING OR SELECTION — NO CANDIDATE IDENTITY EMITTED`

`P3 — NR-METHOD-03 ONE-PROBE COULD NOT COMPLETE WITHIN THE AUTHORIZED EXACT ONE-READ METADATA ENVELOPE — FAIL CLOSED`

Operational prerequisites remain distinct:

`OPERATIONAL BLOCKED — NO NR-METHOD-03 METADATA PROBE EXECUTED`

For P1 only, exactly one source-locator candidate may be emitted. It remains unnormalized and unaccepted. For PM, only the abstract fact `multiple qualifying explicit source-locator candidates` and the count may be recorded; exact candidate locator strings/identities must not be emitted, ranked, selected, or reconstructed later from memory.

### Stop boundary after future probe

Even P1 does NOT authorize:
- URI/package normalization;
- source identity acceptance;
- source-content read;
- source-target binding;
- basis-instance acceptance;
- U-12 target creation;
- technical design or implementation.

Any later handling of one emitted candidate requires a separate governance gate.

## Forbidden mechanisms in the future probe

The candidate task must prohibit:
- repository/path enumeration;
- `git ls-tree`, `git ls-files`, `rg --files`, `find`, `fd`, recursive `ls`/`dir`, `tree`, globs, code search, filename search, `git grep`;
- reading lockfiles or any second metadata/config/source file;
- network/web/package-registry/GitHub API lookup;
- Git fetch/pull;
- reading source files;
- following a candidate locator;
- normalization or package-URI construction;
- fallback to NR-METHOD-01/02/04;
- README content or README-derived identities;
- FD02 access/search/hash/inspection/use.

`NO REPOSITORY-WIDE OR DIRECTORY-WIDE FILE/PATH ENUMERATION IS AUTHORIZED.`

## This authoring review performs zero

- old `EliteSync` access;
- `pubspec.yaml` read/open/parse/hash;
- metadata probe;
- metadata/config/source-content reads;
- candidate emission;
- normalization;
- source identity acceptance;
- source/basis/binding/U-12 activity;
- search/enumeration;
- evidence/PUI/design/implementation/LC-03/LC-04/Phase 36 activity;
- FD02 access/search/hash/inspection/use.

## Authoring result

For Outcome A create exactly one candidate execution task sheet:

`docs/architecture/ELITESYNC_V10_H01_BIB03_NR_METHOD_03_BOUNDED_ONE_PROBE_TASK_SHEET_V0_1.md`

Required candidate task status:

`PROPOSED — AWAITING INDEPENDENT GPT L3 ACCEPTANCE AND DURABLE PROMOTION — NR-METHOD-03 PROBE INACTIVE — DO NOT READ PUBSPEC YET`

Required authoring outcome:

`NR-METHOD-03 BOUNDED ONE-PROBE TASK SHEET = CANDIDATE AUTHORED — EXACT VERIFIED PUBSPEC OBJECT — EXACTLY ONE FUTURE METADATA-CONTENT READ — BOUNDED DEPENDENCY GIT-LOCATOR GRAMMAR — PREDECLARED P0/P1/PM/P3 OUTCOMES — PROBE INACTIVE — ZERO CONTENT READS IN AUTHORING`

EXPECTED OUTCOME B:

`EXPECTED OUTCOME B — NO EXACTLY BOUNDED ONE-PROBE TASK SHEET AUTHORABLE UNDER CURRENT SELECTED-METHOD AUTHORITY — FAIL CLOSED`

Operational:

`OPERATIONAL BLOCKED — NO NR-METHOD-03 ONE-PROBE TASK AUTHORING DETERMINATION MADE`

## Accounting

Gate start:
- accepted NR-METHOD-03 method-selection gates = `1`
- selected method = `NR-METHOD-03`
- selected-method count = `1`
- executed methods = `0`
- execution/probe task sheets = `0`
- metadata probes/content reads = `0 / 0`
- source-locator candidates = `0`
- package-URI normalizations = `0`
- source identity emitted/accepted = `0 / 0`
- basis/binding/U-12 = `0 / 0 / 0`
- accepted/unauthorized read ledger = `12 / 1`
- remaining README/documentary access = `0`

For authoring Outcome A only:
- candidate one-probe task sheets authored = `1`
- accepted/published one-probe task sheets = `0`
- executed methods = `0`
- metadata probes/content reads = `0 / 0`
- source-locator candidates = `0`

Preserve `POST-E3 PROMOTION PUSH-OPERATION COUNT = UNKNOWN / NOT INDEPENDENTLY VERIFIABLE`.

Preserve all accepted ADRs, durable UNKNOWNs, legal/Safety boundaries, U-14 exclusion, U-12 exact-scope rules, D-02 unresolved and `D02-DURABLE-UNKNOWN-01`, U-15 unresolved, `TP-SOURCE-CLASS-01`, `TP-TARGET-01`, Backend/Database non-inspection, deferred PUI, PUI-PREREQ-12=`0`, and technical design/implementation/LC-03/LC-04/Phase36 unauthorized.

Commit exactly the candidate probe task sheet for Outcome A with message `docs: author H-01 BIB-03 NR-METHOD-03 bounded one-probe task sheet`; changed-path count relative to this authoring-review task-sheet commit must be exactly `1`; publish non-force only to the same review branch; do not promote main.

Stop before probe execution or any metadata-object content read.
