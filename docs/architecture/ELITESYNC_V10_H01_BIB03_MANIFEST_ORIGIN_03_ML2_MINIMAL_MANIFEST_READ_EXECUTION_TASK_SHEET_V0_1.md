# EliteSync v10 H-01 BIB-03 MANIFEST-ORIGIN-03 ML-2 Minimal Manifest Read Execution Task Sheet v0.1

## 1. Purpose and publication non-authority

This document defines exactly one possible later execution:

`H-01 BIB-03 MANIFEST-ORIGIN-03 STAGE ML-2 MINIMAL MANIFEST CONTENT READ — EXACTLY ONE LOCKED BLOB — TECHNICAL/CONFIG READ BUDGET = 1 — NO SOURCE READ — FAIL CLOSED`

Repository:

`zcx369658780/EliteSync-v10`

Publication parent authority:

`5e614ff959e1c4d09a64f24fafd923ca7e53f8bd`

Controlling accepted ML-1 identity:

`zcx369658780/EliteSync-v10@33134dd23679bee4cee32f84782f255c1f0fb8cb:apps/flutter_elitesync_module/pubspec.yaml#blob=1b807ccdcced1e3166fd6e5378865ecb5bba4708`

Publication of this task sheet does NOT perform the ML-2 read and does NOT authorize any Dart/source read, directory inspection, package-root acceptance, source-target binding, inspection, evidence collection, PUI reconsideration, design, or implementation.

## 2. Exact read target

The sole authorized content-bearing object is:

`Git blob 1b807ccdcced1e3166fd6e5378865ecb5bba4708`

Bound identity:

`33134dd23679bee4cee32f84782f255c1f0fb8cb:apps/flutter_elitesync_module/pubspec.yaml`

Do not substitute a later commit, path, or blob.

Do not re-probe identity before reading.

Preserve:

`ACCEPTED ML-1 IDENTITY != AUTHORITY TO READ ANY OTHER OBJECT`

## 3. Explicit read budget

Authorize exactly:

`TECHNICAL/CONFIG MANIFEST CONTENT READ BUDGET = 1 DOCUMENT / 1 LOCKED GIT BLOB`

One and only one content-bearing Git read may supply bytes from the target blob.

The content-bearing source operation must be equivalent to:

`git cat-file blob 1b807ccdcced1e3166fd6e5378865ecb5bba4708`

It may be piped directly into a local parser that consumes stdin once.

The parser may not perform a second Git/file/network read.

No temporary manifest copy is required or authorized.

No network dependency installation is authorized.

Preserve:

`MANIFEST READ IS A TECHNICAL/CONFIG READ`

`MANIFEST READ != SOURCE CONTENT READ`

## 4. Minimal retained metadata only

The parser may retain only these normalized outputs:

1. top-level manifest `name` scalar, if present;
2. whether `dependencies.flutter` is explicitly a mapping containing `sdk: flutter`;
3. the already-known manifest path;
4. the deterministic parent-directory package-root locator candidate:
   `apps/flutter_elitesync_module/`;
5. parse success/failure.

Do NOT retain or report:

- full manifest text;
- unrelated dependency names or versions;
- dev dependencies;
- assets;
- fonts;
- environment constraints;
- URLs;
- comments;
- scripts;
- source paths;
- any other YAML keys/values.

Do not print the raw manifest to the terminal or artifact.

## 5. Exact qualification rule

Expected Outcome A requires all:

- exact locked blob read exactly once;
- YAML parse succeeds as a mapping;
- top-level `name` is a non-empty scalar;
- `dependencies.flutter.sdk` equals exactly `flutter`;
- no prohibited retained output or second read occurs.

If all are true, emit exactly:

`ML2-MANIFEST-NAME = <manifest-name>`

`ML2-FLUTTER-SDK-DEPENDENCY = CONFIRMED`

`ML2-PACKAGE-ROOT-LOCATOR-CANDIDATE-01 = apps/flutter_elitesync_module/`

The package-root value remains a locator candidate only.

Preserve:

`MANIFEST-DECLARED NAME != SOURCE IDENTIFIER`

`PACKAGE-ROOT LOCATOR CANDIDATE != PACKAGE ROOT ACCEPTED`

`PACKAGE-ROOT LOCATOR CANDIDATE != SOURCE IDENTIFIER`

`PACKAGE ROOT IDENTIFIED != AUTHORITY TO APPEND lib/ OR ANY SOURCE SUFFIX`

If any qualification requirement fails, use Outcome B and emit no package-root locator candidate for forward use.

## 6. Expected Outcome A

Label:

`EXPECTED OUTCOME A`

Terminal statement:

`H-01 BIB-03 MANIFEST-ORIGIN-03 STAGE ML-2 READ ONE LOCKED MANIFEST BLOB AND ESTABLISHED MINIMAL FLUTTER PACKAGE METADATA — ONE PACKAGE-ROOT LOCATOR CANDIDATE EMITTED — NO SOURCE PATH, SOURCE IDENTIFIER, BASIS-INSTANCE ACCEPTANCE, SOURCE-TARGET BINDING, INSPECTION, EVIDENCE, PUI, DESIGN, OR IMPLEMENTATION AUTHORITY`

## 7. Expected Outcome B

Use if parse/qualification fails or execution cannot preserve the one-read/minimal-retention boundary.

Label:

`EXPECTED OUTCOME B`

Terminal statement:

`H-01 BIB-03 MANIFEST-ORIGIN-03 STAGE ML-2 DID NOT ESTABLISH QUALIFYING MINIMAL FLUTTER PACKAGE METADATA FROM THE LOCKED MANIFEST — FAIL CLOSED — NO PACKAGE-ROOT LOCATOR CANDIDATE MAY BE CARRIED FORWARD`

A conforming negative result is not automatically `OPERATIONAL BLOCKED`.

## 8. No source-path derivation

Even on Outcome A, do NOT create or test:

- `apps/flutter_elitesync_module/lib/`;
- `apps/flutter_elitesync_module/lib/main.dart`;
- any Dart filename;
- any conventional source suffix;
- any directory child.

Do not enumerate the package root.

Preserve exactly:

`PACKAGE-ROOT LOCATOR CANDIDATE != AUTHORITY TO ENUMERATE PACKAGE ROOT`

`PACKAGE-ROOT LOCATOR CANDIDATE != AUTHORITY TO APPEND CONVENTIONAL SOURCE PATH`

## 9. Protected-path rule

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

FD02 search/access must remain `0 / 0`.

## 10. Primary-agent only

No helper/sub-agent may read the manifest, parse it, modify the worktree, create/edit the execution artifact, commit, or push.

Any helper/sub-agent read/write/commit/push action:

`OPERATIONAL BLOCKED — EXECUTION PROVENANCE VIOLATION`

## 11. Accepted-read accounting

Before execution:

`CUMULATIVE ACCEPTED TECHNICAL/SOURCE-CONTENT READS = 10`

During the review-branch execution:

- technical/config manifest reads performed = `1`;
- source-content reads performed = `0`;
- cumulative accepted technical/source-content reads remain `10` until independent GPT L3 acceptance.

If and only if this ML-2 execution is later independently accepted and promoted, the accepted cumulative technical/config/source-content read count becomes:

`11`

Preserve:

`PERFORMED READ != ACCEPTED READ UNTIL INDEPENDENT GPT L3 ACCEPTANCE`

## 12. Future execution artifact and branch

Future execution artifact:

`docs/architecture/ELITESYNC_V10_H01_BIB03_MANIFEST_ORIGIN_03_ML2_MINIMAL_MANIFEST_READ_EXECUTION_V0_1.md`

Future execution branch:

`review/h01-bib03-manifest-origin-03-ml2-minimal-manifest-read-execution-v0.1`

Future exact commit subject:

`docs: execute H-01 BIB-03 origin-03 ML-2 minimal manifest read v0.1`

Exactly one changed path is permitted.

Push only that review branch exactly once, non-force.

Do not promote `main` during execution.

## 13. Mandatory counters

The future execution artifact MUST explicitly record:

- Choice A / B / C selected = `YES / NO / NO`;
- Owner exact-path inputs / MANIFEST-ORIGIN-03 instances = `1 / 1`;
- accepted manifest identities = `1`;
- ML-1 executions in this invocation = `0`;
- ML-2 executions = `1`;
- manifest content-bearing read operations = `1`;
- technical/config manifest reads performed = `1`;
- source-content reads performed = `0`;
- raw manifest text retained/reported = `0`;
- package-root locator candidates emitted = `0` or `1`;
- package-root locator candidates accepted = `0`;
- package identities accepted = `0`;
- source-path hypotheses = `0`;
- candidate source identifiers emitted / accepted = `0 / 0`;
- bounded basis instances accepted = `0`;
- source-target bindings = `0`;
- repository / directory enumeration = `0 / 0`;
- filename / code searches = `0 / 0`;
- Flutter/client/Dart source reads = `0`;
- technical/platform inspection = `0`;
- future source read budgets = `0`;
- evidence = `0`;
- U-15 resolution = `0`;
- D-02 reopen = `0`;
- PUI changes / reconsideration / threshold claims = `0 / 0 / 0`;
- U-12 targets = `0`;
- design / implementation = `0 / 0`;
- telemetry / Safety Operations / legal research = `0 / 0 / 0`;
- LC-03 / LC-04 / Phase 36 = `0 / 0 / 0`;
- DeepSeek calls = `0`;
- pre-execution cumulative accepted technical/source-content reads = exactly `10`;
- post-execution cumulative accepted technical/source-content reads = exactly `10` pending independent GPT L3 acceptance;
- path-enumeration exposure = `0`;
- FD02 search/access = `0 / 0`;
- helper/sub-agent read/write/commit/push actions = `0`.

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
- Database `0/8 NOT INSPECTED / NOT AUTHORIZED`.

## 15. Stop point

A later conforming execution must end exactly:

`STOP AFTER MANIFEST-ORIGIN-03 ML-2 MINIMAL MANIFEST READ — BEFORE PACKAGE-ROOT ACCEPTANCE, SOURCE-PATH HYPOTHESIS, CANDIDATE SOURCE IDENTIFICATION, BASIS-INSTANCE ACCEPTANCE, SOURCE-TARGET BINDING, SOURCE READ, INSPECTION, SOURCE-READ-BUDGET AUTHORIZATION, EVIDENCE COLLECTION, PUI RECONSIDERATION, DESIGN, OR IMPLEMENTATION`
