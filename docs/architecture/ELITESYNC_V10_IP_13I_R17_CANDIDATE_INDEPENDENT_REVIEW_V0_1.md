# EliteSync v10｜IP-13I-R17 Candidate Independent Review｜v0.1

Status: `REJECTED — UPSTREAM EVALUATOR ORDER-SENSITIVITY CONTRADICTS UNQUALIFIED MAPPING CLAIM — SUCCESSOR SOURCE MANIFEST INCOMPLETE — NO RESULT INTEGRATION / NO SUCCESSOR AUTHORIZATION`

Date: 2026-09-21 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

## 1. Decision and stop boundary

The fresh independent reviewer rejects immutable R17 candidate:

`6af50b3cdf82ac8bc285bd160f773b48b29f1328`

Result blob:

`14d92368dbb6a3e7ab2ed6c0cbcf4b149f831ac8`

The Git topology and document-only scope pass. Rejection is substantive, not a demand to rebase onto the later handoff commits.

The candidate's dedicated-adapter direction contains sound parts, but its unconditional Option A conclusion and implementation-entry claim are not supported by the exact evaluator source. A concrete source-order counterexample changes a domain classification and its protected-use validity, not merely explanation ordering.

The Owner requested review followed by a pause. This document records the verdict only. It does not authorize an evaluator change, a correction task, R18, persistence implementation, an application adapter, HTTP, or downstream work. The candidate result is not integrated into main.

## 2. Fresh authority and immutable topology

Fresh GitHub main before review and again before verdict publication:

`f0aae6b05c33af963a08c3679c29241f583726c4`

Main tree:

`c456b3f66ecddde765615198f0531dec51023564`

Frozen R17 execution authority:

`b0196202c78f688723600ac9919cf96463908375`

R17 task:

`docs/architecture/ELITESYNC_V10_NEXT_IP_13I_R17_PRODUCT_CONNECTION_DOMAIN_TO_APPLICATION_MAPPING_REVIEW_TASK_V0_1.md`

Task blob:

`68d18d4100ba24b493fd2b5ee9388f564aca9100`

Verified candidate:

- branch: `review/next-ip-13i-r17-product-connection-domain-to-application-mapping-v0-1`;
- remote branch tip: `6af50b3cdf82ac8bc285bd160f773b48b29f1328`;
- sole parent: `b0196202c78f688723600ac9919cf96463908375`;
- tree: `4e23da4143e6c060a90dd80ea974607b0df7c586`;
- comparison to frozen authority: one commit ahead, zero behind;
- exact diff: one added document, 678 added lines, zero deleted lines;
- path: `docs/architecture/ELITESYNC_V10_IP_13I_R17_PRODUCT_CONNECTION_DOMAIN_TO_APPLICATION_MAPPING_REVIEW_RESULT_V0_1.md`;
- result blob: `14d92368dbb6a3e7ab2ed6c0cbcf4b149f831ac8`.

Separately verified frozen-authority-to-current-main movement: two commits ahead, zero behind, with only the dated handoff document added. The current main commit has sole parent `e34ac2a1ffae4741fefe58341e1e71888fea7713`. No task-source or implementation movement is included in this comparison.

The handoff is:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_2026_09_21_V0_1.md`

Verified blob:

`ed36cab735c57f57d516400cf549dec2a1bae8db`

Rejected R16 candidate `5494bf6835134ef1af69d5ebe32aa28ef62fc92e` is not a candidate ancestor: GitHub comparison is diverged, with one commit behind and merge base `c5fa9ce274a17fe6e772f3bc178e2ff2a6027466`.

The user-specified in-flight exception is preserved. The reviewer did not require rebase, reinterpret handoff commits as execution authority, or independently claim observation of the executor's local gate time.

## 3. Fixed-object verification and review limits

GitHub path/ref reads independently resolved the task's fixed objects to these blobs. Substantive reads focused on the complete R17 task/result and the controlling contracts and relevant source methods; contrast sources were inspected only for their authorized contrast purpose.

| Object | Verified blob |
|---|---|
| AGENTS.md | `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1` |
| R17 task | `68d18d4100ba24b493fd2b5ee9388f564aca9100` |
| R16-R1 result | `f0da912cb3dcb1525fa36053168310f187cf58cb` |
| R16-R1 acceptance | `96110d9484897012c7946b42a2256951ec8a60fc` |
| Retained R16 source at rejected candidate only | `aee15cf45c75c5a8f1733f5604803fc3ee766b4b` |
| R15-R1 result | `fb064b7e290916ba7aa42d53990c9c54d289f5ba` |
| R15-R1 acceptance | `7424e368a31edcd3e8ccc7d37133d6f4b321ebc3` |
| Product Connection evaluator | `35a889ee5460e5c374a5a99bd93bebae49718c5b` |
| Common Authority | `e98e7db731d41269a7b89e01db12e1a81364751d` |
| IP-13A | `65d4a6c1bc3c535d56e4d4b50110eef6efc7b45f` |
| IP-13D | `640fb4a6cd0269d8eb55f218a2fc8ce823014f7c` |
| IP-13E | `aa9721dfa66fe17eb2314bc9466870d479c07644` |
| Canonical Match adapter, contrast only | `789e8905b2c9ee54d902d8b600100896af4f6063` |
| Canonical Match adapter Unit test, contrast only | `c8298f5e786a47d118b56f47cef6baab7f543b60` |

The executor's reported tracked/staged/untracked counts and prohibited-command non-execution remain executor attestations. GitHub proves the committed scope, not local worktree cleanliness or the complete execution history. The reviewer ran no project code, tests, toolchain, server, database, or private-data operation. The counterexample below is a static source trace, not a claimed runtime test result.

## 4. Blocking finding R17-F1: order-sensitive duplicate resolution

### 4.1 Candidate claim

R17 result Section 8 says higher comparable revision selection fixes the selected revision independently of source order. Section 17 repeats source-order-independent higher-revision selection and excludes arrival-order selection. The mapping makes one evaluator call and has no authorized additional semantic resolution of the original evidence list.

The narrower Section 8 recovery rule is sound: once an evaluator dependency is retained, collecting all exact public-vector matches and requiring identical recoverable metadata avoids first-match recovery. However, that does not prove that the evaluator retains the same dependency, or even the same classification, for every permutation of the original evidence set.

### 4.2 Exact source behavior

Source:

`services/backend-laravel/app/Domain/ProductConnectionStateTransitionEvaluator.php`

blob `35a889ee5460e5c374a5a99bd93bebae49718c5b`, methods `resolveDuplicates`, `resolveStateEvidence`, `stateSemanticSignature`, and `evaluateCurrent`.

`resolveDuplicates` initializes the selection with `array_shift`. During the single pass it:

1. replaces the current selection on `REVISION_OLDER`;
2. immediately returns a conflict when the current selection and candidate have equal revisions but different semantic signatures;
3. does not compare semantic signatures when a later candidate is older than the selection.

Common Authority blob `e98e7db731d41269a7b89e01db12e1a81364751d`, method `compareSourceRevisions`, compares values only after the four source-local namespace fields match. Thus the following counterexample uses comparable revisions, not a global revision or timestamp.

### 4.3 Structurally valid synthetic counterexample

Use one Connection identity `synthetic:connection:c1`, participants `synthetic:participant:p1` and `synthetic:participant:p2`, and protected-use scope `synthetic:connection:protected-use`.

All three current-state evidence items have the same non-empty `state_evidence_identity = synthetic:state:e1`, the same Connection identity and participant list, and all six exact current-evidence keys required by R17 Section 5.2.

Required bindings and source bindings are identical eleven-field objects. Their subject, aggregate context and lifecycle identity equal the Connection identity; participants equal the descriptor participants; purpose equals its protected-use scope; terminal is false. Owner/scope/actor/role/audience are fixed non-empty synthetic strings. Source revision owner/scope/context match the source bindings; source lineage is `synthetic:lineage:l1`. Each source evidence has the exact seven-key shape, `record_kind = SOURCE_EVIDENCE`, `source_condition = PRESENT`, `currentness = true`, `freshness = true`, and `authoritative_outcome = UNKNOWN`.

Only these valid state/revision values differ:

| Candidate | Source-local revision value | State |
|---|---:|---|
| A | 1 | CN_PENDING |
| B | 1 | CN_ACTIVE |
| C | 2 | CN_ACTIVE |

All states are non-terminal, so the same terminal=false bindings are valid. Every item passes R17's structural gate. A and B have different semantic signatures at equal revision; C is a higher comparable revision.

Static trace for order `[A, B, C]`:

- A becomes the initial selection.
- B compares equal to A but differs in state/signature.
- The evaluator returns before seeing C.
- Result: `UNKNOWN / CONFLICTING_EQUAL_REVISION_STATE_EVIDENCE`, no retained current dependency, `valid_for_protected_use = false`.

Static trace for the same multiset in order `[C, A, B]`:

- C becomes the initial selection.
- Each comparison with A or B yields `REVISION_NEWER` for the selection.
- Neither older candidate enters the equal-revision conflict branch.
- C remains selected and is fully usable.
- Result: `CN_ACTIVE`, dependency C, empty reasons, `valid_for_protected_use = true`.

This changes the exact typed payload and deterministic correlation input. Under the proposed future family mapping it also changes eligibility for a usable materialization. Both individual results can satisfy R16-R1's cross-field matrix. Selected-evidence recovery cannot catch the problem: one order has no retained dependency, while the other uniquely recovers C.

The shared duplicate resolver is also used for transition evidence. Transition evaluation additionally inherits current-state resolution. No extra evaluator call is needed to establish the source-level contradiction.

### 4.4 Consequence and bounded correction requirement

This is a pre-existing evaluator edge case newly exposed by independent R17 review, not code introduced by the document candidate. Historical evaluator/contract acceptances are not erased or retroactively rewritten.

Nevertheless, R17 cannot declare unconditional mapping soundness and implementation readiness while claiming source-order independence from that exact source. This is more than a wording-only defect because protected-use validity changes under permutation.

A future separately authorized resolution must explicitly decide the order-invariant policy for dominated equal-revision conflicts and demonstrate consistency for both current-state and transition resolution. The reviewer does not select a new conflict-precedence rule here.

Do not silently sort/filter evidence in the application builder, invent a pre-materialization diagnostic, discard the conflict as malformed, add a global revision, or use repeated evaluator calls to select a preferred answer. The accepted six structural diagnostics and 8/19 persisted reason vocabularies remain fixed unless separately and explicitly revised.

## 5. Secondary finding R17-F2: successor source manifest is not closed

R17 result Section 21 defines an exact R18 read list, but omits the retained original R16 document at its exact rejected-candidate/blob address.

R16-R1 result Section 16 explicitly retains original R16 definitions, including exact payload key sets, binding constants, invalidation object, lifecycle basis, schema markers and deterministic identities. R16-R1 is a correction, not a self-contained replacement for every retained definition. R17 Section 10 refers to the accepted exact 13-key and 15-key payloads without restating their full key lists.

The precise omitted source is:

`docs/architecture/ELITESYNC_V10_IP_13I_R16_PRODUCT_CONNECTION_RECORD_PROJECTION_CONTRACT_REVIEW_RESULT_V0_1.md`

at commit:

`5494bf6835134ef1af69d5ebe32aa28ef62fc92e`

blob:

`aee15cf45c75c5a8f1733f5604803fc3ee766b4b`

Only the sections retained by accepted R16-R1 may be used; the original rejected candidate is not accepted as a whole.

A successor implementation cannot infer missing exact key sets from analogy or treat a path reference as automatic extra read authority. Before any future implementation task is published, its fixed read manifest must include that retained source with its narrow section boundary, or an independently accepted self-contained consolidation containing the exact definitions. This review does not create that consolidation or publish a successor.

## 6. Sound directions retained as findings, not candidate acceptance

The following R17 directions are consistent with the inspected controlling sources:

- four explicit synthetic operations with no caller-supplied prior evaluator result;
- current evaluation once, transition evaluation once without a redundant external current call;
- invalidation through one fresh relevant evaluation and one evaluator invalidation;
- all-exact-match recovery with common protected-binding/currentness/freshness metadata;
- recovery of expected-state revision by equality across matching transition candidates, because the public evaluator vector does not expose it;
- protected-binding computation separated from source condition/currentness/freshness;
- Binding Model A, current-state-based terminality, and retained invalidation context;
- one IP-13E submit and conditional exact-lineage retrieval for the three supported storage outcomes;
- direct typed-payload equality rather than digest-only readback;
- `EXACT_MATERIALIZATION != PROTECTED_USE_VALIDITY` and UNKNOWN/REJECTED unusability;
- `PERSISTENCE_FAMILY_IMPLEMENTATION_FIRST`: current SQLite storage explicitly strips derived payloads outside RR03/Canonical Match, so an application adapter cannot obtain truthful exact Connection payload readback before family repair;
- existing IP-13E operations and IP-13F unchanged/non-participating direction.

None of these partial findings overrides R17-F1 or authorizes partial implementation.

## 7. Preserved boundaries and current state

Preserve all accepted ADRs, retained UNKNOWNs, legal/Safety/no-processing boundaries, U-14 exclusion and U-12 exact-scope rules. README budget remains exhausted; FD02 and the old repository remain excluded. No repository enumeration was required.

Preserve `NEXT_DOMAIN = PRODUCT_CONNECTION`, `MATCH_RESULT_UNUSED_AND_NON_PARTICIPATING`, the accepted family/two fact classes, Binding Model A, exact typed dependencies and reasons, R16-R1 cross-field rules, generic-overlay separation, and all non-authority fields.

No source/account/header/auth/session/token authority is inferred. No production persistence, deployment, real/private-data processing, global revision, LWW, arrival-order authority, Connection mutation, Messaging consent or Conversation is authorized.

Only this independent-review document is added to main. The R17 result and branch remain unchanged and unintegrated. No R17 acceptance, R18, correction task or implementation task is published. Planning/roadmap optimization is discussed separately with the Owner and is not a repository change authorized by this verdict.

Final classification:

`IP-13I-R17 REJECTED — TOPOLOGY AND FIXED OBJECTS VERIFIED — SOURCE-ORDER-INDEPENDENT RECOVERY DOES NOT ESTABLISH ORDER-INDEPENDENT EVALUATOR RESOLUTION — CONCRETE CURRENT-STATE PERMUTATION COUNTEREXAMPLE — SUCCESSOR EXACT SOURCE MANIFEST INCOMPLETE — CANDIDATE NOT INTEGRATED — OWNER-REQUESTED PAUSE — NO SUCCESSOR OR IMPLEMENTATION AUTHORIZED`
