# EliteSync v10 H-01 D-02 API-05 Minimum Error-Mapping Dependency Source-Identification Task Sheet v0.2

## 1. Authority and publication boundary

This governance document supersedes v0.1 for one possible later gate:

`H-01 D-02 API-05 MINIMUM ERROR-MAPPING DEPENDENCY SOURCE-IDENTIFICATION — STAGE A ONLY`

- Repository: `zcx369658780/EliteSync-v10`
- Publication parent authority: `bcdc043d520d22d97835eeb6605cbd60fa9f0870`
- Prior task sheet: `docs/architecture/ELITESYNC_V10_H01_D02_API05_MINIMUM_ERROR_MAPPING_DEPENDENCY_SOURCE_IDENTIFICATION_TASK_SHEET_V0_1.md`
- Prior task-sheet Git blob: `3a70c0b852afd4de82e805ea3588bcb917f8f98e`
- Controlling continuity document: `docs/architecture/ELITESYNC_V10_H01_D02_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`
- Controlling continuity Git blob: `df3e0714c52af66b922c1423177f5f2d20d63bcd`
- Future artifact: `docs/architecture/ELITESYNC_V10_H01_D02_API05_MINIMUM_ERROR_MAPPING_DEPENDENCY_SOURCE_IDENTIFICATION_V0_1.md`
- Future review branch: `review/h01-d02-api05-minimum-error-mapping-dependency-source-identification-v0.1`
- Future commit subject: `docs: identify H-01 D-02 API-05 error mapping dependency`
- Future protocol: `REVIEW-BRANCH HASH-LOCKED PROMOTION PROTOCOL`

Publication of this task sheet is governance authority only. It does not itself execute Stage A and does not authorize any technical/source-content read, candidate-content read, correspondence-evidence read, extractor, parser, technical design, repair, implementation, Backend/Database inspection, LC-03, LC-04, Phase 36, participant/data activity, private Conversation inspection, telemetry/analytics/measurement, Safety Operations, legal research, production action, spend, or irreversible action.

Future Stage A may run only under separate explicit Owner invocation and must remain inside this task sheet.

## 2. Correction introduced by v0.2

v0.1 required local `HEAD = origin/main` before Stage A but did not explicitly authorize a safe local fast-forward when the local `main` was merely behind the exact remote task-sheet authority. The prior Codex attempt correctly failed closed with local `HEAD = 033f288fc2c3698211681711e7705e72b657e826` and `origin/main = bcdc043d520d22d97835eeb6605cbd60fa9f0870`.

v0.2 adds one bounded pre-Stage-A synchronization authority only. It does not broaden Stage A evidence or source authority.

`SAFE FAST-FORWARD SYNC AUTHORITY != SOURCE READ AUTHORITY != STAGE A EVIDENCE AUTHORITY`

## 3. Controlling accepted state

Preserve every accepted ADR, semantic/mechanism decision, UNKNOWN disposition, legal boundary, Safety boundary, FD02 prohibition, U-14 exclusion, U-12 exact-scope target rule, and all no-processing/no-implementation limits from the controlling handoff.

Current D-02 state remains:

- D-02: `UNRESOLVED`
- cumulative accepted technical/source-content reads: `10`
- two independent transition-source content-read authorities consumed
- accepted transition body evidence: `0`
- accepted transition-specific evidence: `API-TRANS-EV-001` only
- `API-TRANS-EV-001`: declaration/signature-only, relation `LIMITS`
- `API-TRANS-RETRY-EV-*`: `NONE`
- third transition read: `NOT AUTHORIZED`

Current API verdicts remain exactly:

| API cell | Accepted verdict |
|---|---|
| API-01 | `PARTIAL / CONFLICTING EVIDENCE` |
| API-02 | `INDETERMINATE — MORE AUTHORITY/EVIDENCE REQUIRED` |
| API-03 | `NO CORRESPONDENCE ESTABLISHED` |
| API-04 | `INDETERMINATE — MORE AUTHORITY/EVIDENCE REQUIRED` |
| API-05 | `PARTIAL / CONFLICTING EVIDENCE` |
| API-06 | `INDETERMINATE — MORE AUTHORITY/EVIDENCE REQUIRED` |

- sufficient: `0/6`
- Backend: `0/10 NOT INSPECTED / NOT AUTHORIZED`
- Database: `0/8 NOT INSPECTED / NOT AUTHORIZED`

Controlling rule:

`TWO CONSUMED READS + ZERO ACCEPTED BODY EVIDENCE != AUTOMATIC THIRD READ AUTHORITY`

Nothing in this task sheet changes that rule.

## 4. Explicit bounded local fast-forward synchronization authority

Before reading or executing the Stage A body, Owner may supply the exact v0.2 publication commit in the startup instruction. After `git fetch origin`, the executor is authorized to synchronize local `main` to that exact commit only if every condition below is true:

1. current branch is exactly `main`;
2. `origin/main` equals the exact v0.2 publication commit supplied by Owner;
3. local `HEAD` is either already equal to that exact commit or is a strict ancestor of it;
4. there is no local divergence and no local commit outside the ancestry of the exact `origin/main` authority;
5. staged files = `0`;
6. tracked-unstaged files = `0`;
7. stash is empty;
8. exactly one registered worktree exists;
9. FD02, if still present, is only the accepted protected pre-existing untracked deviation and is not touched, opened, hashed, staged, cleaned, moved, or used;
10. no other unexpected untracked deviation is present.

If local `HEAD` is behind and all conditions pass, exactly one synchronization action is authorized:

`git merge --ff-only origin/main`

Equivalent behavior may be used only if it is provably a pure fast-forward to the exact supplied authority and creates no merge commit.

After synchronization require:

`HEAD = origin/main = <exact v0.2 publication commit supplied by Owner>`

Only then may the executor read this v0.2 task sheet and begin the ordinary Stage A preflight.

The synchronization authority does **not** authorize:

- `git reset` of any kind;
- `git rebase`;
- non-fast-forward merge;
- merge commit creation;
- force checkout or force branch movement;
- stash creation/application/drop;
- `git clean`;
- deleting or modifying untracked files;
- repairing divergence;
- discarding local work;
- changing another worktree;
- fetching/merging another branch as a substitute;
- continuing after any ambiguity.

Any failed condition or failed `--ff-only` operation: `STOP WHOLE TASK`.

## 5. Exact Stage A objective

Stage A has exactly one objective:

> From accepted governance/evidence documentation plus bounded repository metadata only, determine whether exactly one concrete, unread technical-source candidate can be identified as the minimum next dependency that is documentary-linked to API-05 error/unavailable mapping.

Permitted terminal outcomes are only:

1. `EXACTLY ONE CANDIDATE IDENTIFIED — PROPOSED / INACTIVE / UNREAD`; or
2. `NO UNIQUE CANDIDATE ESTABLISHED — FAIL CLOSED`.

Stage A must not open, materialize, read, inspect, parse, quote, hash from bytes, or infer behavior from the candidate source.

## 6. Ordinary Stage A fail-closed preflight

After any authorized fast-forward synchronization:

1. fresh-confirm `HEAD = origin/main =` the exact v0.2 publication commit supplied by Owner;
2. verify this v0.2 task-sheet path exists at that exact commit;
3. verify the controlling handoff path/blob remains exact;
4. verify staged/tracked-unstaged `0/0`;
5. require empty stash;
6. require exactly one registered worktree;
7. require the future artifact path and future review branch to be absent;
8. preserve FD02 as the sole protected pre-existing untracked deviation if that remains the accepted workspace state.

Any mismatch: `STOP WHOLE TASK`.

No cleanup, repair, reset, stash manipulation, source opening, or workspace normalization is authorized to cure a mismatch.

## 7. FD02 permanent prohibition

Protected path:

`docs/architecture/ELITESYNC_V10_FD02_EXPANDED_STATIC_TECHNICAL_DISCOVERY_REPORT_V0_1.md`

FD02 must never be opened, read, hashed, rehashed, modified, moved, deleted, staged, committed, cited, selected, nominated, allowlisted, inspected, searched, or used in reasoning or evidence.

Stage A must not include FD02 in any metadata allowlist or candidate set.

## 8. Allowed documentary inputs

Stage A may read only accepted governance/evidence artifacts needed to reconstruct API-05's already-accepted dependency limitations and identifiers:

- the controlling current-session handoff;
- accepted H-01 D-02 controller correspondence-evidence artifact(s);
- accepted transition correspondence-evidence artifact;
- accepted transition extraction-retry artifact;
- accepted task sheets or review artifacts only when necessary to disambiguate the documentary identity of an already-mentioned dependency.

These are documentation reads, not technical/source-content reads.

Do not reopen the accepted controller source. Do not reopen `MatchingRoundService.php`. Do not inspect any other technical source.

Documentary text may be used only to extract already-recorded exact dependency identifiers, evidence IDs, source IDs, path/blob metadata already accepted, and explicit API-05 limitations. Do not create a new dependency by semantic guess, framework convention, class-name intuition, or implementation knowledge.

## 9. Documentary nomination rule

Create a temporary in-memory nomination list containing only exact identifiers that satisfy all of the following:

1. the identifier is explicitly present in accepted documentation;
2. accepted documentation explicitly links it to an API-05 unresolved error/unavailable/mapping limitation, or explicitly records it as an uninspected dependency bearing on that limitation;
3. it is not merely a type/parameter name whose behavior was prohibited from inference;
4. it is not `MatchingRoundService::transition` or any already-consumed transition-source reread path;
5. it is not the accepted controller source;
6. it is not FD02;
7. it is not a Backend or Database evidence candidate by virtue of this gate;
8. its relevance does not depend on inspecting private Conversations, participant data, telemetry, runtime, logs, environment, production, or Safety Operations.

If there are zero documentary-qualified identifiers: `NO UNIQUE CANDIDATE ESTABLISHED — FAIL CLOSED`.

Do not broaden the documentary corpus or invent search terms to compensate.

## 10. Sole metadata-resolution authority

If and only if at least one documentary-qualified exact identifier exists, Stage A may perform one bounded repository-tree metadata resolution pass against the exact accepted baseline.

This pass is metadata-only. It may expose path, blob SHA, mode, object type, and size. It must not return or inspect blob contents.

The metadata pass exists only to resolve documentary-qualified exact identifiers. It must not be repurposed as general repository discovery, architecture inventory, code search, Backend inventory, Database inventory, implementation reconnaissance, or source selection by intuition.

Filtering rules:

- exact identifier/basename/namespace-token matching only;
- no content search;
- no `git grep`;
- no GitHub code search;
- no regex over source contents;
- no source snippet retrieval;
- no blob fetch/materialization;
- no alternate branch or newer blob;
- no fallback into adjacent/sibling files because a name looks relevant.

The artifact may retain only:
- total documentary-qualified identifier count;
- exact metadata-match count per qualified identifier;
- at most the single final candidate row;
- fail-closed diagnostics.

Do not publish unrelated repository paths discovered incidentally by the metadata pass.

## 11. Unique-candidate activation rule

Exactly one candidate may be retained as `D02-API05-DEP-001` only if all are true:

1. exactly one documentary-qualified identifier materially dominates the minimum API-05 missing mapping question without requiring behavioral inference;
2. that identifier resolves to exactly one repository blob at the accepted baseline;
3. path/blob/mode/type/size are exact and stable in the metadata result;
4. the candidate is not the controller source, transition source, FD02, or an already-consumed source;
5. selecting it does not require Backend/Database evidence authority;
6. its relationship to API-05 is established by accepted documentation, not by file-name or framework inference;
7. no tie, ambiguity, sibling alternative, or multi-file chain must be resolved by opening source.

Retained candidate state must be exactly:

`PROPOSED API-05 EXTERNAL-EVIDENCE CANDIDATE — INACTIVE — UNREAD`

If any condition fails: `NO UNIQUE CANDIDATE ESTABLISHED — FAIL CLOSED`.

Do not activate two candidates. Do not rank a shortlist for later silent use.

## 12. Zero content-read budget

Stage A technical/source-content budget is exactly zero.

Required counters:

- technical-source reads: `0`
- source-content reads: `0`
- candidate-content reads: `0`
- correspondence-evidence reads: `0`
- candidate materializations: `0`
- charged source bytes: `0`
- extractor/parser runs on repository source: `0`
- controller rereads: `0`
- transition rereads: `0`
- Backend source reads: `0`
- Database source reads: `0`
- evidence added: `0`
- API verdict changes: `0`
- implementation actions: `0`

The repository-tree metadata pass, if used, is not a technical/source-content read, but must be reported separately as `metadata-resolution passes: 0 or 1`.

The pre-Stage-A `git fetch` and authorized pure fast-forward are Git synchronization operations, not technical/source-content reads, and must be reported separately.

## 13. API-05 and other-cell freeze

API-05 remains:

`PARTIAL / CONFLICTING EVIDENCE`

Stage A identifies a possible future evidence source only. It cannot reassess API-05 and cannot create `API-EV-*`, `API-TRANS-EV-*`, `API-TRANS-RETRY-EV-*`, or any new correspondence-evidence record.

API-01, API-02, API-03, API-04, and API-06 are fully frozen.

API-03 remains specifically:

`NO CORRESPONDENCE ESTABLISHED`

Backend remains `0/10 NOT INSPECTED / NOT AUTHORIZED`.

Database remains `0/8 NOT INSPECTED / NOT AUTHORIZED`.

## 14. Required Stage A artifact

The future artifact must contain:

1. initial local `HEAD`, fetched `origin/main`, and whether bounded fast-forward sync was required/performed;
2. exact post-sync authority/baseline verification;
3. v0.2 task-sheet committed identity;
4. controlling handoff identity;
5. explicit FD02 exclusion confirmation without opening/hash/reuse;
6. accepted API verdict matrix unchanged;
7. current cumulative accepted technical/source-content reads `10`;
8. documentary inputs actually read;
9. documentary-qualified identifier count and exact identifiers retained for nomination;
10. metadata-resolution pass count `0 or 1`;
11. exact-match counts;
12. final candidate row if and only if uniquely established:
   - candidate ID `D02-API05-DEP-001`;
   - exact documentary identifier;
   - exact path;
   - blob SHA;
   - mode;
   - type;
   - size;
   - documentary relationship to API-05;
   - state `PROPOSED API-05 EXTERNAL-EVIDENCE CANDIDATE — INACTIVE — UNREAD`;
13. otherwise exact fail-closed reason;
14. all zero content-read/evidence/verdict-change counters;
15. explicit Backend/Database freeze;
16. exact non-authorities;
17. whether a later candidate-content-read task sheet is justified;
18. `STOP BEFORE CONTENT READ`.

Do not include source snippets or behavioral claims.

## 15. Publication protocol

If preflight passes, create the future review branch from the exact accepted v0.2 task-sheet publication commit.

Author only the future Stage A artifact on that review branch.

Before commit, require:
- only the Stage A artifact is staged;
- FD02 is not staged;
- no technical source is staged or modified;
- zero technical/source-content reads remain true;
- verdicts are unchanged;
- candidate state, if any, is inactive/unread.

Commit subject:

`docs: identify H-01 D-02 API-05 error mapping dependency`

After commit:
- report review-branch commit SHA;
- report artifact Git blob;
- compute/report committed-byte SHA-256 if locally available from the committed artifact bytes;
- verify review branch/worktree cleanliness except the protected accepted FD02 deviation;
- do not merge or fast-forward `main`;
- stop for independent GPT L3 review.

No promotion to `main` is authorized by this task sheet.

## 16. Exact non-authorities

Stage A has no authority to:

- open, read, materialize, hash from bytes, inspect, parse, quote, or summarize any technical source;
- reopen the controller source;
- reopen `MatchingRoundService.php`;
- perform a third transition-source read;
- run an extractor/scanner/parser on repository source;
- inspect the body of `D02-API05-DEP-001` if identified;
- identify or inspect a second candidate after a unique candidate is retained;
- collect correspondence evidence;
- change any API verdict;
- infer runtime correctness, persistence, feasibility, implementation, complete error taxonomy, disclosure behavior, or production state;
- inspect Backend or Database source;
- perform participant/user/data activity;
- inspect private Conversations;
- perform telemetry, analytics, measurement, logs, runtime, environment, or production inspection;
- perform Safety Operations;
- conduct legal research;
- design repair or implementation;
- run tests/builds as evidence;
- start LC-03, LC-04, Phase 36, or successor implementation;
- exercise unlimited Owner, legal, spend, production, participant/data, Safety Operations, or irreversible-action authority.

Owner-delegated authority remains bounded.

## 17. Success semantics and stop condition

A successful Stage A means only:

`ONE MINIMUM API-05 CANDIDATE IDENTITY ESTABLISHED — CONTENT UNREAD — EVIDENCE UNCHANGED`

It does not mean API-05 correspondence improved.

If no unique candidate is established, that is an accepted fail-closed governance result and must not trigger broader discovery.

Any future content read requires:
1. independent GPT L3 review of the Stage A artifact;
2. a new exact candidate-content-read task sheet;
3. separate explicit Owner authority.

Terminal line:

`STOP BEFORE CONTENT READ`
