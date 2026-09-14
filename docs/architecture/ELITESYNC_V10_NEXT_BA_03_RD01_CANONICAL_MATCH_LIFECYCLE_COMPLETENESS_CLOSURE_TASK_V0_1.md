# EliteSync v10｜NEXT BA-03-RD01 Canonical Match Lifecycle Completeness Closure Task｜v0.1

Status: `OWNER-DELEGATED BOUNDED GOVERNANCE AUTHORIZED — PRODUCT/SOURCE CLOSURE ONLY — NO TECHNICAL-DESIGN OR IMPLEMENTATION AUTHORITY`

Date: 2026-09-14 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `a437c6b8a61978f1af1fe42bbf16e07c03964aaa`

## 1. Purpose and authority

BA-03 technical design stopped correctly because the accepted bounded sources name Match mutation classes and mutual-acceptance obligations but do not establish a complete canonical Match lifecycle vocabulary and source/action/actor/target matrix.

Under the Owner-delegated bounded-governance convention, this task is authorized to perform one reversible product/source-closure pass only. It may resolve bounded Match lifecycle semantics needed by BA-03 where no accepted source conflicts. It must not authorize backend/API/schema/storage/service/client implementation, production access, legal conclusions, Safety Operations, private-data activity, Compatibility total scoring, Connection creation, Messaging Consent, Conversation authority, Relationship state, or irreversible external commitments.

This task specifically increases validation density so that any remaining block returns a complete gap inventory rather than a single missing rule.

## 2. Required first reads

Fresh-fetch `main` and verify it equals the task-publication commit that contains this task. Read `AGENTS.md` first, then only:

1. `docs/architecture/ELITESYNC_V10_NEXT_BA_03_CANONICAL_MATCH_AUTHORITY_TECHNICAL_DESIGN_TASK_V0_1.md`
2. `docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md`
3. `docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_V0_1.md`, only binding/revision/freshness/idempotency/non-substitution sections needed here
4. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_ACCEPTANCE_V0_1.md`
5. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_V0_1.md`, BA-03 section only
6. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_ACCEPTANCE_V0_1.md`
7. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_CONTRACT_V0_1.md`, B01-B and directly dependent common sections only
8. `docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`, Match/product-invariant sections only

Do not enumerate directories or broadly search the repository.

For source resolution only, exact fixed-string repository searches are additionally authorized for these tokens/phrases, individually and without synonym expansion:

`Match lifecycle`
`canonical Match`
`proposal issuance`
`proposal accept`
`proposal decline`
`proposal withdraw`
`mutual acceptance`
`enrollment`
`pause`
`withdrawal`
`expiry`
`/progress/match`

Only plausible product/architecture/governance documents returned by those exact searches may be opened. Application source/tests cannot establish product authority.

## 3. Exact output

Produce exactly one candidate:

`docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_LIFECYCLE_COMPLETENESS_CLOSURE_V0_1.md`

Write no other file.

## 4. Required closure questions

The candidate must answer every item below separately as `SOURCE_RESOLVED`, `OWNER_DELEGATED_RULE`, `RETAINED_UNKNOWN`, `NOT_APPLICABLE`, or `BLOCKED` with exact provenance.

### 4.1 Aggregate and vocabulary

1. What is the canonical Match aggregate/lifecycle identity boundary?
2. Is enrollment part of the same lifecycle identity as proposal/response, or a parent participation context containing proposal lifecycles?
3. What exact canonical state vocabulary is required for BA-03?
4. Which states describe participation/enrollment versus a concrete proposal?
5. Which conditions are authority conditions/presentation states and must not become Match lifecycle states?
6. Whether more than one active proposal for the same participant may exist is `UNKNOWN` unless an accepted source explicitly establishes otherwise.

### 4.2 Enrollment, pause, withdrawal

7. Exact source/action/actor/target semantics for enrollment.
8. Exact actor allowed to pause participation.
9. Exact source condition from which pause is valid.
10. Whether pause preserves an already-issued proposal, invalidates it, or prevents only new proposal issuance.
11. Exact actor allowed to withdraw from Match participation.
12. Whether withdrawal is terminal for the current participation context.
13. Whether a later re-enrollment is allowed and, if so, whether it requires a new participation context.
14. Whether pause can be resumed and by whom.

### 4.3 Proposal issuance and proposal identity

15. Exact prerequisite for authoritative proposal issuance.
16. Exact authority actor for proposal issuance: system/Match authority rather than either participant unless accepted source says otherwise.
17. Exact participant binding required on one proposal.
18. Whether proposal identity is distinct from participation/enrollment identity.
19. Whether a new proposal after a terminal proposal outcome must use a new proposal identity.
20. Whether historical proposal evidence can be reused as current authority.

### 4.4 Participant decisions and mutual acceptance

21. Exact actor for proposal acceptance.
22. Exact actor for proposal decline.
23. Whether each participant records an independent decision against the same proposal.
24. Exact representation of one-sided acceptance while the other participant has not accepted.
25. Exact resulting Match state/outcome after both required participants accept the same current proposal.
26. Whether first acceptance remains valid after a newer proposal revision changes participants or proposal scope.
27. Whether either participant may withdraw their own decision before mutual acceptance.
28. Exact proposal-withdraw actor/source/target rule, if such a mutation is retained.
29. Whether decline by either participant terminates that proposal identity.
30. Whether a later proposal between the same people requires a fresh proposal identity and fresh independent decisions.

### 4.5 Expiry and terminality

31. Which proposal state(s) are eligible to expire under a future established expiry policy.
32. The authority actor for expiry representation.
33. Exact expiry duration remains `RETAINED UNKNOWN`.
34. Exact clock basis remains `RETAINED UNKNOWN`.
35. Extension/renewal rules remain `RETAINED UNKNOWN`.
36. Whether expired proposal identity is terminal.
37. Whether a later proposal after expiry must be a fresh proposal identity.
38. A countdown/client timer must never establish expiry authority.

### 4.6 Cross-domain and meaning boundaries

39. Mutual Match acceptance must not create Product Connection.
40. Mutual Match acceptance must not create Messaging Consent.
41. Mutual Match acceptance must not create Conversation read/send authority.
42. Mutual Match acceptance must not create Relationship state.
43. Decline/withdraw/expiry must not imply guilt, Safety finding, punishment, fraud, deception, person worth, or objective incompatibility.
44. No Compatibility total score may become authoritative.
45. Optional AI/personality/astrology/reference-signal policy remains unresolved unless already separately accepted.

## 5. Owner-delegated bounded closure rule

If the bounded source review does not conflict with the following product rule, the candidate is authorized to establish it as `OWNER_DELEGATED_RULE` for BA-03 consumption:

1. Canonical Match has two nested semantic scopes: a participant Match-participation context and zero or more distinct proposal contexts. They are related but must not share proposal decision identity.
2. Participation may be `NOT_ENROLLED`, `ENROLLED`, `PAUSED`, or `WITHDRAWN`. These are semantic product states for the participation context; exact wire codes are not selected.
3. User enrollment creates `ENROLLED`. The same participant may pause from `ENROLLED` to `PAUSED` and resume from `PAUSED` to `ENROLLED`. Withdrawal from `ENROLLED` or `PAUSED` ends that participation context as `WITHDRAWN`.
4. A later return after `WITHDRAWN` is permitted only as a fresh participation context; the old withdrawn context is not reopened.
5. Proposal issuance is authored by the Match authority only while both proposal participants are currently eligible under then-current separately authoritative Match prerequisites and currently enrolled for Match participation. This rule does not define those eligibility prerequisites.
6. Each proposal is a distinct proposal identity with exact two-participant binding and an independent decision slot for each participant.
7. Proposal semantic states are `PENDING`, `MUTUALLY_ACCEPTED`, `DECLINED`, `WITHDRAWN`, and `EXPIRED`; one-sided participant decisions are evidence inside a current `PENDING` proposal rather than new universal lifecycle states.
8. Either participant may accept or decline only for their own decision slot on the same current `PENDING` proposal. Mutual acceptance is established only after both participant decision slots contain current authoritative acceptance for the same proposal revision.
9. A decline by either participant makes that proposal `DECLINED` and terminal. It does not create adverse person meaning.
10. Proposal withdrawal means Match authority withdraws/cancels a still-current `PENDING` proposal when a product-authorized reason exists; this closure does not invent reason categories. Participants cannot use proposal withdrawal as a substitute for their own decline/participation withdrawal unless a separate accepted rule establishes it.
11. `MUTUALLY_ACCEPTED`, `DECLINED`, `WITHDRAWN`, and `EXPIRED` are terminal for that proposal identity. No terminal proposal can be reopened, reset, or mutated back to `PENDING`.
12. A later proposal, including after decline/withdraw/expiry/mutual acceptance, must use a fresh proposal identity and fresh participant decisions if then-current Match authority permits another proposal.
13. Expiry may apply only to a still-current `PENDING` proposal and is authored by Match authority/system under an established policy. Exact duration, clock basis, extension, renewal, cooldown, and re-proposal timing remain `RETAINED UNKNOWN`.
14. A participant moving to `PAUSED` or `WITHDRAWN` makes any still-pending proposal involving that participant ineligible for further acceptance. The Match authority must resolve that proposal to a non-active terminal outcome under its own newer authoritative revision; use `WITHDRAWN` for this closure without implying which participant caused a domain-wide withdrawal reason. This rule must be called out for independent review because it links participation and proposal scopes.
15. Historical acceptances, proposal identities, countdowns, cached projections, compatibility labels, routes, notifications, or transport acknowledgements cannot satisfy a new proposal or current mutual acceptance.

If an accepted source conflicts with any numbered Owner-delegated rule, do not override it. Record the exact conflict and classify only that item `BLOCKED`.

## 6. High-density verification matrix

The candidate must include a verification table with at least the following 40 checks, each marked PASS / RETAINED_UNKNOWN / BLOCKED with exact evidence:

1. fixed `origin/main` and task blob match;
2. exact one-file scope;
3. accepted BA-01 provenance established;
4. accepted B01-B provenance established;
5. accepted BA03 decomposition provenance established;
6. no broader repository enumeration used;
7. exact-token search ledger recorded;
8. application source/tests excluded as authority;
9. participation context identity defined;
10. proposal identity defined;
11. participation/proposal identities not collapsed;
12. participation vocabulary complete;
13. proposal vocabulary complete;
14. presentation/transport states excluded from lifecycle;
15. enrollment actor/source/target fixed;
16. pause actor/source/target fixed;
17. resume actor/source/target fixed;
18. participation withdrawal actor/source/target fixed;
19. post-withdraw fresh-context rule fixed;
20. proposal issuance actor fixed;
21. proposal issuance eligibility seam preserved;
22. exact participant binding fixed;
23. independent participant decision slots fixed;
24. one-sided acceptance not mutual acceptance;
25. mutual acceptance resulting state fixed;
26. decline actor/outcome fixed;
27. proposal-withdraw actor/outcome fixed;
28. participant pause effect on pending proposal fixed;
29. participant withdrawal effect on pending proposal fixed;
30. proposal terminal states fixed;
31. terminal proposal cannot reopen;
32. later proposal requires fresh identity/decisions;
33. expiry source state fixed;
34. expiry actor fixed;
35. expiry duration/clock/extension remain UNKNOWN;
36. route/countdown/cache/legacy/transport substitutions rejected;
37. no Compatibility total score;
38. Match acceptance does not create Connection/Conversation/Relationship authority;
39. neutral semantics for decline/withdraw/expiry preserved;
40. no implementation/API/schema/service/client/legal authority created.

Also include explicit truth cases for: duplicate enrollment; duplicate pause; pause-vs-withdraw; duplicate proposal issue; duplicate accept; accept-vs-decline; accept-vs-proposal-withdraw; both accepts in opposite arrival order; stale accept after proposal revision; accept after pause; accept after participation withdrawal; delayed accept after decline; expiry racing second acceptance; old proposal replay after fresh proposal; transport timeout after possible decision commit; changed semantic input under reused idempotency identity; participant/proposal mismatch; historical mutually accepted proposal presented as current; unknown expiry policy with pending proposal; projection lag; unknown/unavailable Match authority.

The closure does not need to design idempotency mechanics; these truth cases identify the semantic outcomes BA-03 must later design.

## 7. Required gap-density behavior

Do not stop after discovering the first non-conflicting missing rule. Continue the entire authorized matrix and report every unresolved item that can be determined without violating a hard authority/read boundary.

A hard stop before completing the matrix is required only for:

- fresh `main` mismatch;
- task blob/path mismatch;
- missing required exact authority file;
- accepted-source conflict that makes continued bounded product closure internally contradictory;
- need for prohibited broad discovery, old-repository access, legal research, private-data inspection, or implementation inspection.

Otherwise, complete the whole matrix and retain unresolved items explicitly.

## 8. Non-goals

Do not select exact expiry timing, cooldowns, proposal frequency, matching algorithm, candidate ranking, compatibility total score, optional signal allowlists, endpoints, API/wire/schema/storage/service/queue/clock/deployment/auth/client implementation, regional legal rules, Safety findings, participant research, or production policy.

## 9. Execution and stop boundary

Recommended branch:

`review/next-ba-03-rd01-canonical-match-lifecycle-completeness-closure-v0-1`

Write only:

`docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_LIFECYCLE_COMPLETENESS_CLOSURE_V0_1.md`

Run `git diff --check` for the candidate scope.

Push the candidate and report branch, candidate commit, sole parent, tree, artifact blob, exact scope, diff-check result, validation totals (`PASS / RETAINED_UNKNOWN / BLOCKED`), and a compact list of every retained gap.

STOP. Do not restart BA-03 technical design, do not merge/self-accept, and do not start BA-06/BA-07.

Expected success classification:

`CANONICAL MATCH LIFECYCLE COMPLETENESS CLOSURE ESTABLISHED — HIGH-DENSITY VALIDATION MATRIX COMPLETE — PRODUCT LIFECYCLE RULES FIXED / EXPIRY POLICY RETAINED UNKNOWN — NO IMPLEMENTATION AUTHORITY CREATED — READY FOR INDEPENDENT REVIEW`

If a genuine accepted-source conflict prevents closure:

`BLOCKED_CANONICAL_MATCH_LIFECYCLE_AUTHORITY_CONFLICT — FULL AUTHORIZED GAP MATRIX RECORDED — NO RULES INVENTED`
