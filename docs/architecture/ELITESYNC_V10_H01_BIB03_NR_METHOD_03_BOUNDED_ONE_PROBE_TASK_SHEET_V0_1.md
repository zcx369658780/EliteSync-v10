# EliteSync v10 H-01 BIB-03 NR-METHOD-03 Bounded One-Probe Task Sheet v0.1

## 1. Status and authoring outcome

Status:

`PROPOSED — AWAITING INDEPENDENT GPT L3 ACCEPTANCE AND DURABLE PROMOTION — NR-METHOD-03 PROBE INACTIVE — DO NOT READ PUBSPEC YET`

Authoring outcome:

`NR-METHOD-03 BOUNDED ONE-PROBE TASK SHEET = CANDIDATE AUTHORED ON CLEAN RETRY — EXACT VERIFIED PUBSPEC OBJECT — EXACTLY ONE FUTURE METADATA-CONTENT READ — BOUNDED DEPENDENCY GIT-LOCATOR GRAMMAR — PREDECLARED P0/P1/PM/P3 OUTCOMES — PROBE INACTIVE — ZERO CONTENT READS IN RETRY AUTHORING`

This candidate task sheet is not execution authority. It must not be executed unless it is independently accepted by GPT L3, durably promoted, and activated by a later exact Owner execution task.

## 2. Durable authority and retry provenance

- Durable authoring authority: `origin/main = bf483f4ab02a6e08e3d5d3587ce5de2753d7da61`.
- Retry authoring task-sheet commit: `7b998ac950278630092a7ef3fcc421b01162057e`.
- Retry authoring task-sheet blob: `f93243cbb0e03d8b5ab07ddc7591906e9bddfa7e`.
- Accepted method-selection artifact blob: `3339fa62bcee86444ca2d589522642b2540ff332`.
- Selected method: `NR-METHOD-03 — Single exact known non-README metadata-object probe`.

The prior attempt remains permanently classified:

`INCIDENT-BIB03-NR03-AUTHORING-ENUM-01 — ONE UNAUTHORIZED UNTRACKED-FILE/PATH ENUMERATION OCCURRED DURING THE PRIOR ONE-PROBE TASK-AUTHORING ATTEMPT — ZERO PATHS EMITTED — ZERO UNTRACKED FILES FOUND — ZERO CONTENT READS — PRIOR ATTEMPT OPERATIONALLY BLOCKED`

`UNAUTHORIZED PATH-ENUMERATION GOVERNANCE INCIDENT — NOT CONTENT READ — NOT SOURCE READ — NOT CANDIDATE EMISSION — NOT PROBE EXECUTION`

No result of that incident or blocked attempt may be reused.

## 3. Future execution entry gate

A later execution may begin only after all of the following are freshly and exactly established:

1. This task sheet has been independently accepted and durably promoted.
2. A new exact Owner execution task activates this one-probe task.
3. The exact repository, commit, path, and blob identity below remains the sole authorized metadata object.
4. The execution has performed zero prior metadata-content reads and zero probes under this task.
5. No search, enumeration, fallback, normalization, external resolution, source-content read, or alternate method has occurred.

If any prerequisite differs:

`OPERATIONAL BLOCKED — NO NR-METHOD-03 METADATA PROBE EXECUTED`

Do not repair, retry, compensate, or choose a second object or method.

## 4. Exact object and one-read budget

The sole authorized metadata object is:

- `repository=zcx369658780/EliteSync`
- `commit=0f06e895a89629a7f4f0cf0c62b784446ecf515a`
- `metadata_object_path=apps/flutter_elitesync_module/pubspec.yaml`
- `blob_sha=7ecd2f6835af9ceb1d67822adbac93d7fa07a939`

The future execution may perform exactly one content-bearing read of this exact verified object for structural YAML parsing. The read must be tied to the exact commit/path/blob identity and counted once even if parsing fails. It may not read the object a second time and may not read any other old-repository metadata, configuration, lockfile, or source object.

Before the future read is independently accepted and durably promoted, the accepted/unauthorized content-read ledger remains `12 / 1`. A later accepted and promoted lawful one-read result may advance the accepted side to `13`; this candidate task sheet does not do so.

## 5. Bounded YAML inspection scope

The future parser may inspect dependency declarations only under these top-level mappings, if present:

- `dependencies`
- `dev_dependencies`
- `dependency_overrides`

Only structural YAML parsing needed to identify direct dependency source forms within those mappings is allowed. No unrelated top-level metadata may be used for source identification, including root-level `repository`, `homepage`, `documentation`, issue tracker, description, authors, environment, Flutter assets, scripts, or any other section.

## 6. Exact qualifying candidate grammar

A qualifying source-locator candidate must be an explicit literal, non-local, self-contained locator already present directly inside one dependency declaration. It must require zero synthesis, concatenation, normalization, registry lookup, external resolution, search, inference, or substitution.

Only these forms qualify:

1. A direct scalar locator under that dependency's `git` source form.
2. An explicit literal `url` value inside that dependency's `git` source form.

An optional same-entry literal `ref` or `path` may be reported only as companion metadata. It must not be concatenated into, appended to, or used to rewrite the locator. The dependency key/name may be reported as exact context only; it is not a locator.

Never qualify:

- package name plus version constraint;
- a hosted dependency name/version without an explicit self-contained locator;
- an `sdk` dependency;
- a local `path` dependency;
- a workspace or local-relative reference;
- root-level repository, homepage, documentation, or issue-tracker values;
- lockfile-derived, Git-remote-derived, README-derived, memory-derived, incident-derived, registry-derived, web-derived, or network-derived values;
- reconstructed, concatenated, substituted, inferred, or normalized URI/package coordinates.

`METADATA CANDIDATE EXTRACTION != URI NORMALIZATION`

`METADATA CANDIDATE EXTRACTION != SOURCE IDENTITY ACCEPTANCE`

## 7. Deterministic classification and disclosure

After the single read and bounded parse, classify exactly one outcome.

### P0

`P0 — NR-METHOD-03 ONE-PROBE COMPLETED — ZERO QUALIFYING EXPLICIT SOURCE-LOCATOR CANDIDATES — FAIL CLOSED — NO SEARCH/NORMALIZATION/FALLBACK`

### P1

`P1 — NR-METHOD-03 ONE-PROBE COMPLETED — EXACTLY ONE QUALIFYING EXPLICIT SOURCE-LOCATOR CANDIDATE EMITTED AS CANDIDATE ONLY — ZERO NORMALIZATION — ZERO SOURCE IDENTITY ACCEPTANCE — NO SOURCE READ AUTHORITY CREATED`

P1 may emit exactly one qualifying locator literal, its dependency name as context, and any same-entry literal `ref` or `path` as separate companion metadata. The candidate remains unnormalized and unaccepted. It creates no authority to follow or read the locator.

### PM

`PM — NR-METHOD-03 ONE-PROBE COMPLETED — MULTIPLE QUALIFYING EXPLICIT SOURCE-LOCATOR CANDIDATES — FAIL CLOSED — NO RANKING OR SELECTION — NO CANDIDATE IDENTITY EMITTED`

PM may record only the abstract multiplicity fact and the count. It must not emit exact locator strings, dependency identities, companion metadata, rankings, selections, or memory-derived reconstruction.

### P3

`P3 — NR-METHOD-03 ONE-PROBE COULD NOT COMPLETE WITHIN THE AUTHORIZED EXACT ONE-READ METADATA ENVELOPE — FAIL CLOSED`

P3 applies when the exact read, structural parse, or classification cannot complete within the one-read and bounded-scope envelope. The consumed read remains consumed. Do not retry, reread, broaden parsing, repair input, or fall back.

Operational failure before the authorized content-bearing read remains:

`OPERATIONAL BLOCKED — NO NR-METHOD-03 METADATA PROBE EXECUTED`

## 8. Forbidden mechanisms

The future task must perform zero:

- repository-wide or directory-wide enumeration;
- `git ls-tree`, `git ls-files`, `rg --files`, `find`, `fd`, recursive `ls` or `dir`, `tree`, globs, code search, filename search, or `git grep`;
- lockfile or second metadata/config/source-file reads;
- web, network, package-registry, GitHub API, or other external lookup;
- Git fetch or pull against the old repository;
- source-file reads or following an emitted locator;
- URI/package normalization or coordinate construction;
- fallback to NR-METHOD-01, NR-METHOD-02, or NR-METHOD-04;
- README use or README-derived identity use;
- FD02 access, search, hash, inspection, or use.

`NO REPOSITORY-WIDE OR DIRECTORY-WIDE FILE/PATH ENUMERATION IS AUTHORIZED.`

## 9. Downstream stop boundary

Even P1 does not authorize URI/package normalization, source identity acceptance, source-content read, basis-instance acceptance, source-target binding, U-12 target creation, evidence collection, PUI reconsideration, technical design, implementation, LC-03, LC-04, or Phase 36.

Any handling of one emitted locator candidate requires a separate later governance gate.

## 10. Accounting

At task-sheet authoring completion:

- Candidate one-probe task sheets authored: `1`.
- Accepted/published one-probe task sheets: `0`.
- Executed methods: `0`.
- Metadata probes/content reads: `0 / 0`.
- Source-locator candidates: `0`.
- Package-URI normalizations: `0`.
- Source identity emitted/accepted: `0 / 0`.
- Basis/binding/U-12: `0 / 0 / 0`.
- Accepted/unauthorized content-read ledger: `12 / 1`.
- Cumulative unauthorized enumeration incidents: `1`.
- Current-retry unauthorized enumeration incidents: `0`.
- `POST-E3 PROMOTION PUSH-OPERATION COUNT = UNKNOWN / NOT INDEPENDENTLY VERIFIABLE`.

This authoring retry stops before probe execution and before any `pubspec.yaml` content read.
