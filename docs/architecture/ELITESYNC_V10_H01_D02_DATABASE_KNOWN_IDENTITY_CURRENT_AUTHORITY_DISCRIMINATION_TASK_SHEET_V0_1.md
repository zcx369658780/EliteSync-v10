# EliteSync v10 H-01 D-02 Database Known-Identity Current-Authority Discrimination Task Sheet v0.1

## 1. Authority and publication boundary

This governance document defines one possible later gate only:

`H-01 D-02 DATABASE KNOWN-IDENTITY CURRENT-AUTHORITY / MINIMUM-NECESSITY DISCRIMINATION — STAGE A ONLY`

- Repository: `zcx369658780/EliteSync-v10`
- Publication parent authority: `aabaae6b1efd56310cdee47c1b8c9fbca7eacce2`
- Controlling continuity document: `docs/architecture/ELITESYNC_V10_H01_D02_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`
- Accepted Backend fail-closed artifact: `docs/architecture/ELITESYNC_V10_H01_D02_BACKEND_MINIMUM_APP_DEPENDENCY_SOURCE_IDENTIFICATION_V0_1.md`
- Accepted Backend artifact Git blob: `569712f48924d8bbefcc8731e44420aada668ff2`
- Future artifact: `docs/architecture/ELITESYNC_V10_H01_D02_DATABASE_KNOWN_IDENTITY_CURRENT_AUTHORITY_DISCRIMINATION_V0_1.md`
- Future review branch: `review/h01-d02-database-known-identity-current-authority-discrimination-v0.1`
- Future commit subject: `docs: discriminate H-01 D-02 Database candidate authority`
- Future protocol: `REVIEW-BRANCH HASH-LOCKED PROMOTION PROTOCOL`

Publication is governance authority only. It does not execute Stage A and does not authorize any technical/source-content read, candidate-content read, correspondence-evidence read, Database evidence collection, Backend evidence work, API reassessment, transition reread, source extractor/parser, technical design, repair, implementation, LC-03, LC-04, Phase 36, participant/data activity, private Conversation inspection, telemetry/analytics/measurement, Safety Operations, legal research, production action, spend, or irreversible action.

Future Stage A may run only under separate explicit Owner invocation and must remain inside this task sheet.

## 2. Controlling accepted state

Preserve every accepted ADR, semantic/mechanism decision, durable UNKNOWN disposition, legal boundary, Safety boundary, FD02 prohibition, U-14 exclusion, U-12 exact-scope target rule, and all no-processing/no-implementation limits.

Current D-02 state remains:

- D-02: `UNRESOLVED`
- cumulative accepted technical/source-content reads: `10`
- API sufficient: `0/6`
- Backend: `0/10 NOT INSPECTED / NOT AUTHORIZED`
- Database: `0/8 NOT INSPECTED / NOT AUTHORIZED`
- third transition read: `NOT AUTHORIZED`

Accepted API verdicts remain exactly:

| API cell | Accepted verdict |
|---|---|
| API-01 | `PARTIAL / CONFLICTING EVIDENCE` |
| API-02 | `INDETERMINATE — MORE AUTHORITY/EVIDENCE REQUIRED` |
| API-03 | `NO CORRESPONDENCE ESTABLISHED` |
| API-04 | `INDETERMINATE — MORE AUTHORITY/EVIDENCE REQUIRED` |
| API-05 | `PARTIAL / CONFLICTING EVIDENCE` |
| API-06 | `INDETERMINATE — MORE AUTHORITY/EVIDENCE REQUIRED` |

Nothing in this gate changes any verdict.

## 3. Why this is the next and final low-expansion Database identification gate

Accepted D-02 scope assessment states that all DB-01..DB-08 require later technical-source inspection before correspondence verdict eligibility.

Earlier content-blind technical-source selection identified two Database-shaped repository identities but excluded both because H-01 relevance, current-authority status, and minimum necessity were not established from metadata alone.

Later locator-only probe work read those identities only under restricted source-identification firewalls. Those historical reads did not create Database correspondence evidence and did not activate a Database evidence allowlist. Subsequent probe-informed discrimination ended with:

`DATABASE SOURCE-IDENTIFICATION GAP REMAINS`

The recently accepted Backend identification gate also failed closed without source reads. Further API and Backend low-expansion selection is paused.

This Database gate therefore does not rediscover the repository. It asks one narrower question only:

> Can the two exact already-known Database-shaped identities be discriminated, using accepted documentary provenance plus current repository metadata only, so that exactly one is defensibly the current minimum prospective Database correspondence-evidence source?

`KNOWN IDENTITY != CURRENT AUTHORITY != DATABASE EVIDENCE != CORRESPONDENCE`

If this gate cannot establish exactly one candidate, the current low-expansion static source-identification path is exhausted. The executor must fail closed rather than create another identification round.

## 4. Exact closed identity pool

The Stage A pool contains exactly two identities and no others.

### DB-KNOWN-01

- exact historical path: `services/backend-laravel/app/Models/UserRelationshipEvent.php`
- accepted historical blob: `19df856a3b42b80c0222ef5decda21790c01ea5e`
- accepted historical type: `blob`
- accepted historical size: `805` bytes
- historical prospective category: `Database responsibility/persistence-definition evidence`
- prior restricted source-content reads in accepted D-02 chain: `2`
- accepted correspondence evidence from those reads: `0`

### DB-KNOWN-02

- exact historical path: `services/backend-laravel/database/migrations/2026_04_18_000050_create_user_relationship_events_table.php`
- accepted historical blob: `d5d6d6215fdd93e035399f3e3933f848e6db7985`
- accepted historical type: `blob`
- accepted historical size: `965` bytes
- historical prospective category: `Database responsibility/persistence-definition evidence`
- prior restricted source-content reads in accepted D-02 chain: `1`
- accepted correspondence evidence from that read: `0`

These prior reads were locator/source-identification reads only. They are not reusable as correspondence evidence and do not authorize rereading either identity now.

No third identity may be nominated, substituted, discovered, inferred, searched, or carried forward.

## 5. Explicit bounded local fast-forward synchronization authority

Before Stage A, Owner may supply the exact publication commit in the startup instruction.

After `git fetch origin`, the executor may synchronize local `main` to that exact commit only if all are true:

1. current branch is exactly `main`;
2. `origin/main` equals the exact Owner-supplied publication commit;
3. local `HEAD` is equal to it or is a strict ancestor;
4. no divergence or local-only commit exists;
5. staged files = `0`;
6. tracked-unstaged files = `0`;
7. stash is empty;
8. exactly one registered worktree exists;
9. FD02 remains the sole accepted protected pre-existing untracked deviation and is not touched or used.

If local `HEAD` is behind and all conditions pass, the only authorized synchronization command is:

`git merge --ff-only origin/main`

Then require:

`HEAD = origin/main = <EXACT OWNER-SUPPLIED PUBLICATION COMMIT>`

No reset, rebase, non-fast-forward merge, force update, stash manipulation, clean, deletion, conflict repair, or workspace normalization is authorized.

Any failed condition: `STOP WHOLE TASK`.

## 6. Fail-closed preflight

After any authorized synchronization and before Stage A:

1. verify this task-sheet path at the exact publication commit;
2. verify the controlling handoff path/blob exact;
3. verify the accepted Backend fail-closed artifact on `main` with blob `569712f48924d8bbefcc8731e44420aada668ff2`;
4. verify staged/tracked-unstaged `0/0`;
5. verify stash empty;
6. verify exactly one registered worktree;
7. verify future artifact path and future review branch absent;
8. preserve FD02 as the sole protected pre-existing untracked deviation if still present.

Any mismatch: `STOP WHOLE TASK`.

No cleanup or repair may cure a mismatch.

## 7. FD02 permanent prohibition

Use only the exact protected FD02 identity already defined by the controlling handoff.

FD02 must not be opened, read, hashed, rehashed, modified, moved, deleted, staged, committed, cited, selected, nominated, allowlisted, inspected, searched, or used in reasoning/evidence.

Do not rediscover or resolve FD02 through repository search.

## 8. Allowed documentary inputs

Stage A may read only accepted governance/evidence documentation necessary to establish the history and limitations of DB-KNOWN-01 and DB-KNOWN-02:

- controlling current-session handoff;
- accepted D-02 entry correspondence-scope assessment;
- accepted technical-source selection artifact;
- accepted minimal source-identification probe artifact;
- accepted probe-informed candidate-discrimination/Database-completion artifact;
- accepted API-only correspondence-evidence artifact only when necessary to preserve cross-class non-substitution boundaries;
- accepted Backend fail-closed artifact;
- accepted task sheets only to verify a previously accepted identity, counter, or prohibition.

These are documentation reads, not technical/source-content reads.

Do not reopen any previously read technical source.

## 9. Frozen Database questions

DB-01 through DB-08 remain the exact accepted Database correspondence questions from the D-02 scope assessment and remain `NOT INSPECTED / NOT AUTHORIZED`.

Stage A may use them only as prospective minimum-necessity criteria:

- exact-Connection support boundary;
- coherent first-establishment support;
- same-author already-established support;
- other-participant independent-authorship support;
- outcome-unavailable support;
- prior-receipt and independent-authorship preservation;
- concurrent convergence / contradiction prevention;
- normative consistency and transport non-authority.

No Database verdict may be assigned.

## 10. Documentary qualification rule

Before current metadata resolution, determine from accepted documentation only whether each known identity is still eligible for current-authority discrimination.

An identity remains eligible only if all are true:

1. it is exactly one of DB-KNOWN-01 or DB-KNOWN-02;
2. accepted documentation already records it as prospective Database responsibility/persistence-definition material;
3. no accepted later artifact converted it into correspondence evidence;
4. no accepted later artifact established it as irrelevant to every DB-01..DB-08 question;
5. evaluating its current identity does not require source content, runtime, schema inference, filename semantics, private data, Safety Operations, legal research, or implementation assumptions.

If neither remains eligible: fail closed.

If exactly one remains eligible: proceed to the sole metadata pass for that identity only.

If both remain eligible: the metadata pass may evaluate both, but no semantic tie-breaker may be invented.

## 11. Sole current-authority metadata-resolution pass

Stage A may perform at most one bounded metadata pass against the exact publication baseline and only for the eligible known paths.

For each eligible known path, the pass may retain only:

- path existence at exact baseline: `YES/NO`;
- exact current blob SHA if present;
- mode;
- object type;
- byte size;
- equality/inequality to the accepted historical blob;
- path-scoped latest commit SHA, parent SHA(s), timestamp, subject, and path status, with **no patch/diff/content**.

Permitted commands must be path-locked equivalents of:

- exact `git rev-parse <baseline>:<known-path>`;
- `git cat-file -t <resolved-sha>`;
- `git cat-file -s <resolved-sha>`;
- one path-scoped `git log --no-patch` / name-status metadata query if needed.

Prohibited:

- repository tree inventory;
- directory listing used for candidate discovery;
- `git grep`;
- GitHub code search;
- source/content regex;
- snippets;
- blob materialization;
- source parser/extractor;
- sibling/adjacent fallback;
- alternate branch/history content;
- new model/migration/table/schema discovery;
- Backend candidate fallback;
- API candidate fallback;
- any third transition read.

The pass may occur once only and may not be rerun after error, ambiguity, or tie.

## 12. Mechanical current-authority discrimination rule

Current repository metadata may discriminate the two identities only mechanically; it may not infer persistence semantics.

Classify each eligible identity into exactly one currentness state:

- `CURRENT-SAME` — exact known path exists and current blob equals accepted historical blob;
- `CURRENT-CHANGED` — exact known path exists but current blob differs;
- `CURRENT-ABSENT` — exact known path does not exist at the exact baseline;
- `INDETERMINATE-METADATA` — metadata cannot be established within the one authorized pass.

These labels mean only repository identity continuity. They do not mean behavioral or schema authority.

Exactly one candidate may be retained only if:

1. exactly one eligible identity is `CURRENT-SAME`;
2. the other eligible identity is `CURRENT-CHANGED`, `CURRENT-ABSENT`, or `INDETERMINATE-METADATA`;
3. accepted documentation already supplies a prospective DB-cell relationship for the `CURRENT-SAME` identity without filename/path semantics;
4. no new source, sibling, or semantic inference is needed;
5. all API and Backend states remain frozen.

If both are `CURRENT-SAME`, both are non-current, both are indeterminate, or accepted documentation still cannot establish minimum necessity for the sole `CURRENT-SAME` identity:

`NO UNIQUE DATABASE CANDIDATE ESTABLISHED — FAIL CLOSED`

Do not rank model over migration or migration over model based on framework convention, naming, timestamp in filename, size, directory, or intuition.

## 13. Candidate state if uniquely established

At most one candidate may be retained as:

`D02-DB-DEP-001`

Required state:

`PROPOSED DATABASE EVIDENCE CANDIDATE — INACTIVE — PRIOR LOCATOR-ONLY READ EXISTS — NO CORRESPONDENCE-EVIDENCE READ AUTHORITY`

Required record:

- candidate ID;
- DB-KNOWN identity;
- exact current path;
- exact current blob;
- historical blob;
- currentness state;
- mode/type/size;
- prior restricted-read count;
- accepted correspondence evidence count `0`;
- exact prospective DB cell(s) justified by accepted documentation only;
- documentary minimum-necessity rationale;
- explicit statement that historical locator-only reads are not correspondence evidence;
- explicit statement that no new content read is authorized.

No second candidate may be retained.

## 14. Zero technical/source-content read budget

Stage A content budget is exactly zero.

Required counters:

- technical-source reads: `0`
- source-content reads: `0`
- candidate-content reads: `0`
- correspondence-evidence reads: `0`
- candidate materializations: `0`
- charged source bytes: `0`
- repository-source extractor/parser runs: `0`
- controller rereads: `0`
- transition rereads: `0`
- Backend source reads: `0`
- Database source reads: `0`
- evidence added: `0`
- API verdict changes: `0`
- Backend verdict changes: `0`
- Database verdict changes: `0`
- implementation actions: `0`

Report metadata-resolution passes separately as `0 or 1`.

Current cumulative accepted technical/source-content reads must remain `10`.

## 15. Cross-class freeze

All six API verdicts remain frozen exactly, including API-03 = `NO CORRESPONDENCE ESTABLISHED`.

Backend remains `0/10 NOT INSPECTED / NOT AUTHORIZED`.

Database remains `0/8 NOT INSPECTED / NOT AUTHORIZED` even if one candidate identity is established.

No API or Backend candidate may be nominated or reopened.

## 16. Required Stage A artifact

The future artifact must contain:

1. exact authority and synchronization result;
2. task-sheet identity;
3. controlling handoff identity;
4. accepted Backend fail-closed artifact identity;
5. FD02 exclusion confirmation;
6. frozen API/Backend/Database states;
7. cumulative accepted reads `10`;
8. documentary inputs actually read;
9. DB-KNOWN-01 and DB-KNOWN-02 historical identity/read records;
10. documentary eligibility result for each;
11. metadata-resolution pass count `0 or 1`;
12. mechanical currentness state for each eligible identity;
13. if unique, exactly one D02-DB-DEP-001 record with required state;
14. otherwise exact fail-closed reason;
15. all zero content/evidence/verdict/implementation counters;
16. explicit statement that no historical locator-only read is correspondence evidence;
17. exact non-authorities;
18. whether a later Database correspondence-evidence-read task sheet is justified;
19. whether the low-expansion static source-identification path is exhausted;
20. `STOP BEFORE DATABASE CONTENT READ`.

No source snippet, schema claim, table claim, behavioral claim, or persistence claim may appear.

## 17. Exhaustion rule

If Stage A ends `NO UNIQUE DATABASE CANDIDATE ESTABLISHED — FAIL CLOSED`, then record exactly:

`LOW-EXPANSION STATIC SOURCE-IDENTIFICATION PATH EXHAUSTED UNDER CURRENT H-01 D-02 AUTHORITY`

That terminal result does **not** resolve D-02 and does **not** prove absence of Database support. It means only that no further candidate-identification retry is justified under the current documentary/metadata authority.

After such a result, the only permitted recommendation is independent GPT L3 review and a governance disposition decision such as durable UNKNOWN / pause / broader authority request. Do not author another source-identification retry automatically.

## 18. Publication protocol

If preflight passes:

1. create the exact review branch from the exact task-sheet publication commit;
2. author only the specified Stage A artifact;
3. commit only that artifact using the specified subject;
4. report review commit, sole parent, changed paths, artifact blob, committed-byte SHA-256 if locally available, counters, and review-branch ahead/behind state;
5. do not merge, fast-forward, or otherwise promote `main`;
6. stop for independent GPT L3 review.

Publication to the review branch is not promotion authority.

## 19. Exact non-authorities

This task sheet does not authorize:

- any technical/source-content read or reread;
- opening either known Database identity;
- correspondence evidence collection;
- Database schema/table/persistence inference;
- model or migration semantics;
- repository-wide or directory-wide discovery;
- new candidate nomination;
- controller or transition reread;
- third transition read;
- API reassessment;
- Backend evidence or source selection;
- Database verdict assignment;
- runtime/log/telemetry/private Conversation/participant/data activity;
- Safety Operations;
- legal research;
- technical design, repair, implementation, testing as evidence, LC-03, LC-04, or Phase 36;
- unlimited delegated Owner authority.

## 20. Success / stop condition

Success means only one of:

`EXACTLY ONE DATABASE CANDIDATE IDENTIFIED — INACTIVE — NO CONTENT READ AUTHORITY`

or

`NO UNIQUE DATABASE CANDIDATE ESTABLISHED — FAIL CLOSED`

Neither result changes D-02 or any correspondence verdict.

Terminal instruction:

`STOP BEFORE DATABASE CONTENT READ`
