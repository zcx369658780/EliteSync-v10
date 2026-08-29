# EliteSync v10 H-01 D-02 API Transition Dependency Source-Identification Retry Task Sheet v0.1

## 1. Document authority

This document defines a possible later:

`H-01 D-02 API TRANSITION DEPENDENCY SOURCE IDENTIFICATION RETRY — STAGE A`

This publication is governance/documentation only. It does not authorize retry execution, a repository tree inventory, source identification, source or candidate content access, evidence collection, verdict change, Backend or Database work, repair, implementation, or successor work.

- Task-sheet publication baseline: `61c46b22128e4b2b7996f007ae951343e955c0b6`
- Future artifact: `docs/architecture/ELITESYNC_V10_H01_D02_API_TRANSITION_DEPENDENCY_SOURCE_IDENTIFICATION_RETRY_V0_1.md`
- Future review branch: `review/h01-d02-api-transition-dependency-source-identification-retry-v0.1`
- Future commit subject: `docs: retry H-01 D-02 API transition dependency source identification`
- Future accepted baseline: the exact immutable commit that publishes this task sheet

The future Retry Stage A requires separate exact GPT L3 acceptance of this task sheet and separate exact delegated Owner execution authority.

## 2. Immutable prior accepted attempt

- Historical artifact: `docs/architecture/ELITESYNC_V10_H01_D02_API_TRANSITION_DEPENDENCY_SOURCE_IDENTIFICATION_V0_1.md`
- Historical commit: `61c46b22128e4b2b7996f007ae951343e955c0b6`
- Committed-byte SHA-256: `CA63A049EA0C000F9D94DE4424516E2C338DAE8AF118F01ACEA777D3D446C04E`
- Git blob: `a0ea2088af166f4c3663a6694e54480f71d4e6c3`
- Immutable review branch: `review/h01-d02-api-transition-dependency-source-identification-v0.1`
- Outcome: `INDETERMINATE — METADATA AUTHORITY OR REPOSITORY STATE INSUFFICIENT`
- Prior failed inventory count: `1`
- Failure class: `$matches/$Matches case-insensitive automatic-variable collision`
- Failure point: the first exact-basename row reached the retention step
- Exact row displayed or durably retained: `NO`
- Exact basename match count: `INDETERMINATE`
- Retained exact match records: `0`
- Candidate records: `0`
- `D02-API-DEP-001`: `NOT CREATED`
- Technical/source/candidate/evidence reads: `0/0/0/0`
- Evidence added: `0`
- API verdict changes: `0`
- Backend/Database reads/verdicts: `0/0`
- Implementation actions: `0`
- Historical accepted technical/source-content reads: `8`
- D-02: `UNRESOLVED`

The failed artifact is immutable historical audit evidence. Do not amend, replace, rewrite, reinterpret, erase, or restate it as a successful partial discovery.

`NEW RETRY AUTHORITY != REVISION OF PRIOR FAILED EXECUTION`

## 3. Future retry purpose and limits

The future Retry Stage A may answer only:

> Under a fresh one-inventory metadata authority, does the exact accepted repository revision contain zero, one, or multiple eligible regular-file entries whose exact case-sensitive final basename is `MatchingRoundService.php`?

If exactly one eligible entry exists, the retry may establish its immutable source identity for a later evidence-read decision.

It must not answer what the file contains; whether `transition` exists or what it does; whether H-01 corresponds; whether any API verdict should change; whether the identity is Backend evidence; whether a defect exists; or whether repair or implementation is required.

## 4. Independent inventory authorities

- `PRIOR FAILED INVENTORY COUNT = 1`
- `NEW RETRY TREE INVENTORY AUTHORITY = 1`

These counters are independent and must never be merged into a claim that the historical inventory was retried inside its original authority.

The retry artifact must separately report:

- historical failed inventory count: `1`;
- fresh retry inventory count: `0 or 1`.

Once the future retry inventory begins, its fresh authority is consumed. No second retry inventory, compensation inventory, alternative recursive inventory, `git ls-files` substitute, GitHub code search, content search, or repository-wide second pass is authorized.

## 5. Exact locator contract

- Sole accepted evidence-limitation identifier: `MatchingRoundService::transition`
- Sole locator subject: `MatchingRoundService`
- Exact basename: `MatchingRoundService.php`
- Comparison target: final repository path basename only
- Equality: exact, case-sensitive, ordinal

No method or `transition` search, semantic search, fuzzy search, substring search, namespace inference, directory preference, source-name ranking, or architectural intuition is permitted.

## 6. Future fail-closed preflight

Before any synthetic resolver operation or repository inventory, fresh-fetch and require:

- `HEAD = main = origin/main = <exact retry accepted baseline>`;
- this task sheet's committed-byte SHA-256 and Git blob match the exact accepted identities;
- every accepted immutable H-01 D-01/D-02 review ref remains exact locally and through live `git ls-remote origin`;
- staged / tracked-unstaged is `0 / 0`;
- stash is empty;
- exactly one expected registered worktree exists;
- the future artifact and review branch are absent locally and live-remotely;
- FD02 remains the sole protected pre-existing untracked deviation under metadata-only checks.

Any mismatch: `STOP`.

FD02 remains permanently excluded. Never open, read, hash, modify, stage, commit, move, delete, cite, select, nominate, allowlist, inspect, or use FD02.

## 7. Mandatory deterministic resolver

The future repository tree resolver must not use regular-expression match state to identify or retain repository matches.

Prohibited inside the repository resolver:

- PowerShell automatic variable `$Matches`;
- any custom variable whose name is case-insensitively equal to `matches`;
- regex capture state for basename selection;
- `-match` or `-notmatch`;
- `[regex]::Match` or `[regex]::Matches`.

For each streamed `git ls-tree` row, the resolver must:

1. Treat the row as opaque metadata text.
2. Find the first literal TAB with a direct string operation such as `[string]::IndexOf([char]9)`.
3. Fail closed if no TAB exists.
4. Split into the metadata prefix before TAB and repository path after TAB.
5. Parse the prefix through direct whitespace/token splitting sufficient to obtain exactly mode, object type, and object SHA.
6. Use no regex capture state.
7. Split the Git path on literal `/` and take the final segment.
8. Compare exactly with `[string]::Equals($basename, 'MatchingRoundService.php', [System.StringComparison]::Ordinal)`.
9. Retain exact metadata only into an unambiguous collection such as `$retainedExactEntries`.
10. Immediately discard every nonmatching row.

No unmatched repository row may be printed, persisted, summarized, or reasoned over.

## 8. Mandatory automatic-variable collision gate

Before repository inventory, a synthetic-only gate must prove:

- the repository resolver contains no custom variable name equal case-insensitively to `Matches`;
- it does not rely on `$Matches`;
- a pre-existing populated synthetic `$Matches` cannot alter output;
- exact retention works while `$Matches` is populated before resolver execution;
- multiple eligible synthetic rows are retained without collision;
- zero matches produce zero retained entries;
- malformed rows fail under the accepted grammar;
- wrong-case and substring-only basenames do not match;
- a directory segment named `MatchingRoundService.php` does not match when the final basename differs.

The test must deliberately populate `$Matches`, invoke the resolver, and prove unchanged output. Synthetic diagnostics may expose synthetic fixture labels/counts only and no repository data.

Required gate result: `PASS`.

## 9. Synthetic eligibility coverage

The synthetic gate must also prove:

| Mode | Type | Eligibility |
|---|---|---|
| `100644` | `blob` | eligible |
| `100755` | `blob` | eligible |
| `120000` | any | ineligible |
| `160000` | any | ineligible |
| any | non-blob | ineligible |
| unexpected | any | ineligible |

No symlink or gitlink may be followed or resolved.

## 10. Sole fresh retry inventory

Only after all future preflight and synthetic gates pass may Retry Stage A run exactly once:

`git ls-tree -r --full-tree <exact retry accepted baseline>`

Required counter: `FRESH RETRY TREE METADATA INVENTORIES = 1`.

Rows must be streamed through the deterministic resolver. Nonmatching rows must be discarded immediately. No repeat, alternate inventory, compensation operation, or broader search follows.

## 11. Retained exact metadata and lookups

For exact basename matches only retain:

1. repository;
2. retry accepted revision;
3. exact repository-relative path;
4. file mode;
5. object type;
6. exact object SHA.

Only exact matches may receive `git cat-file -t <sha>` and `git cat-file -s <sha>`. Retain only object type and byte size. Never use `git cat-file -p`.

Optional exact-path no-patch provenance is permitted at most once per exact matched path only if materially necessary; otherwise record `NOT RUN`.

## 12. Regular-file candidate eligibility

An exact basename entry is eligible only when both hold:

- object type is exactly `blob`;
- mode is exactly `100644` or `100755`.

Symlinks `120000`, gitlinks `160000`, trees, commits, tags, non-blobs, and unexpected modes are ineligible and must not be followed or resolved.

## 13. Exact retry outcome taxonomy

Assign exactly one outcome.

### RETRY-A

`EXACT SINGLE TRANSITION-DEPENDENCY SOURCE IDENTITY IDENTIFIED`

Requires a completed inventory, exact basename match count `1`, and sole match eligible. Create exactly one `D02-API-DEP-001` with state `PROPOSED API EXTERNAL-EVIDENCE CANDIDATE — INACTIVE — UNREAD`.

### RETRY-B

`MULTIPLE EXACT BASENAME MATCHES — AMBIGUOUS`

Requires a completed inventory and match count greater than `1`. Retain all exact matches, rank/select none, and set candidate-selection count to `0`.

### RETRY-C

`NO EXACT BASENAME MATCH WITHIN AUTHORIZED RETRY ACCEPTED-REVISION TREE`

Requires a successfully completed inventory and match count `0`. It does not establish global absence.

### RETRY-D

`INDETERMINATE — RETRY METADATA AUTHORITY OR REPOSITORY STATE INSUFFICIENT`

Use for incomplete inventory, parser/resolver failure after authority consumption, malformed metadata preventing a deterministic result, a sole exact match that fails regular-file eligibility, or other accepted metadata insufficiency. No additional inventory follows.

## 14. Conditional candidate record

If and only if RETRY-A applies, create exactly one record with these 16 ordered nonblank fields:

1. dependency candidate ID: `D02-API-DEP-001`;
2. accepted evidence-limitation identifier: `MatchingRoundService::transition`;
3. exact locator subject: `MatchingRoundService`;
4. exact basename: `MatchingRoundService.php`;
5. repository;
6. retry accepted revision;
7. exact path;
8. exact blob SHA;
9. object type;
10. byte size;
11. provenance or `NOT RUN`;
12. affected accepted evidence limitation: `MatchingRoundService::transition`;
13. prospectively affected API cells;
14. remaining uncertainty;
15. prohibited inference;
16. exact future evidence authority required.

Prospective cells may be no broader than API-01, API-02, API-04, API-05, and API-06. API-03 is excluded from dependency-candidate attribution.

## 15. Required historical comparison block

The retry artifact must visibly distinguish:

### Prior accepted attempt

- commit: `61c46b22128e4b2b7996f007ae951343e955c0b6`;
- outcome: `INDETERMINATE — METADATA AUTHORITY OR REPOSITORY STATE INSUFFICIENT`;
- inventory count: `1`;
- failure class: `$matches/$Matches case-insensitive automatic-variable collision`;
- retained exact matches: `0`;
- candidate: `NONE`.

### Fresh retry

Report independently the new baseline, synthetic collision gate, new inventory count, exact match count, retained entries, eligibility, outcome, and candidate state.

## 16. API evidence and verdict preservation

Accepted verdicts remain unchanged:

| Cell | Verdict |
|---|---|
| API-01 | `PARTIAL / CONFLICTING EVIDENCE` |
| API-02 | `INDETERMINATE — MORE AUTHORITY/EVIDENCE REQUIRED` |
| API-03 | `NO CORRESPONDENCE ESTABLISHED` |
| API-04 | `INDETERMINATE — MORE AUTHORITY/EVIDENCE REQUIRED` |
| API-05 | `PARTIAL / CONFLICTING EVIDENCE` |
| API-06 | `INDETERMINATE — MORE AUTHORITY/EVIDENCE REQUIRED` |

- Evidence items added: `0`
- Verdict changes: `0`
- Correspondence-evidence reads: `0`
- API evidence-source coverage: historical `1/1`
- API verdict coverage: historical `6/6`
- Sufficient verdicts: historical `0/6`

Source identity metadata is not correspondence evidence.

## 17. Zero-content-read firewall

Throughout future Retry Stage A:

- technical-source reads: `0`;
- source-content reads: `0`;
- candidate-content reads: `0`;
- correspondence-evidence reads: `0`.

Forbidden: `git show`, `git cat-file -p`, `cat`, `type`, `Get-Content`, editor/preview, grep/rg/git grep, code or symbol/method search, dependency traversal, AST/indexing, Composer/autoload reads, tests/build/runtime/log/environment, and external search.

## 18. Backend and Database freeze

- Backend: `0/10 NOT INSPECTED / NOT AUTHORIZED`
- Database: `0/8 NOT INSPECTED / NOT AUTHORIZED`
- Backend reads/verdicts: `0/0`
- Database reads/verdicts: `0/0`

A path under a backend directory does not create Backend evidence authority.

## 19. Future counters

The retry artifact must report separately:

- prior accepted failed inventory count: `1`;
- fresh retry inventory authority: `1`;
- fresh retry inventory actually executed;
- synthetic collision-gate result;
- synthetic failed attempts/diagnostics;
- exact basename match count;
- exact retained match count;
- regular-file eligible count;
- candidate records created;
- type lookups;
- size lookups;
- provenance operations;
- technical/source/candidate/evidence reads: `0/0/0/0`;
- evidence added: `0`;
- verdict changes: `0`;
- Backend reads/verdicts: `0/0`;
- Database reads/verdicts: `0/0`;
- implementation actions: `0`;
- historical accepted technical/source-content reads: `8`;
- DeepSeek: `0`;
- D-02: `UNRESOLVED`.

## 20. Committed-byte hash-lock rule

All accepted artifact SHA-256 identities refer to `COMMITTED BLOB BYTES`, not a potentially line-ending-transformed working-tree copy.

After committing, obtain the exact Git blob identity, hash the raw committed blob bytes, and verify the immutable commit/blob. A CRLF working-tree representation does not invalidate an unchanged LF committed blob. Never normalize or rewrite a frozen accepted artifact merely to make its working-tree byte hash match.

## 21. Future review publication protocol

Future Retry Stage A must use `REVIEW-BRANCH HASH-LOCKED PROMOTION PROTOCOL` and create exactly:

- artifact: `docs/architecture/ELITESYNC_V10_H01_D02_API_TRANSITION_DEPENDENCY_SOURCE_IDENTIFICATION_RETRY_V0_1.md`;
- branch: `review/h01-d02-api-transition-dependency-source-identification-retry-v0.1`;
- subject: `docs: retry H-01 D-02 API transition dependency source identification`.

Require one artifact, one commit, one changed path, unchanged `main`, one non-force review-branch push, then freeze and stop for external GPT L3 review. External review may inspect only the retry artifact and Git/document metadata and must not rerun the inventory.

## 22. Stop boundary

Task-sheet publication does not authorize Retry Stage A. Do not execute the retry inventory, identify or open `MatchingRoundService.php`, inspect `transition`, activate a candidate, collect evidence, change an API verdict, begin Backend/Database work, repair, implement, start LC-03/LC-04 or Phase 36, or perform successor work without new exact authority.

## 23. Current authoring counters

- Recursive tree inventories: `0`
- Technical-source reads: `0`
- Source-content reads: `0`
- Candidate-content reads: `0`
- Correspondence-evidence reads: `0`
- Evidence added: `0`
- API verdict changes: `0`
- Backend reads/verdicts: `0/0`
- Database reads/verdicts: `0/0`
- Implementation actions: `0`
- Historical accepted reads remain: `8`
- DeepSeek: `0`
- D-02: `UNRESOLVED`

Current publication ends after exactly one new artifact, one commit, one changed path, and one non-force `main` push. No review branch or publication companion artifact is authorized.
