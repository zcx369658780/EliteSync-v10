# EliteSync v10｜IP-13I-R9 Candidate Independent Review｜v0.1

Status: `REJECTED — RECORD/PROJECTION DIRECTION SOUND BUT TERMINALITY/INVALIDATION CONTRACT INTERNALLY INCONSISTENT — R10 NOT AUTHORIZED — R9-R1 DOCUMENT-ONLY CORRECTION REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Fresh review base / current `origin/main`:
`b2113ac1c4a1c296398fba5db1ff4584ed8035ad`

Reviewed branch:
`review/next-ip-13i-r9-canonical-match-record-projection-contract-repair-v0-1`

Reviewed candidate:
`b03966d09e91430a31a03eecf5d3b8575602357d`

Candidate sole parent:
`b2113ac1c4a1c296398fba5db1ff4584ed8035ad`

Candidate tree:
`fa69f4d5a82f58460d06e3d506a1aae43a67df3d`

Candidate result blob:
`1f8394b25ee54373bf4d4e8836075b13b8efcbf1`

## 1. Topology, scope and evidence verification

Independent comparison established:

- candidate is exactly one commit ahead / zero behind the R9 task authority;
- merge base equals `b2113ac1c4a1c296398fba5db1ff4584ed8035ad`;
- exactly one authorized result document is added;
- no source/test/runtime artifact is part of the candidate diff.

All 14 fixed-input ledger objects recorded in the candidate were independently re-resolved and match exactly.

Therefore this rejection is not caused by Git topology, read-scope, ledger or write-scope failure.

## 2. Sound portions retained

The following R9 directions are not rejected:

- additive Canonical Match family rather than RR03 relabeling;
- record family name:
  `CANONICAL_MATCH_PROPOSAL_DECISION_DERIVED_PROJECTION`;
- derived/non-authoritative top-level correlation revision;
- typed proposal / participation / decision-slot dependency groups;
- bounded Match classification vocabulary;
- bounded reason-category reduction;
- source-order-independent deterministic correlation;
- raw source evidence excluded from the derived payload;
- IP-13A generic envelope as the likely extension point;
- IP-13E existing operations as potentially sufficient after a sound record repair;
- IP-13F unchanged/non-participating;
- no Match/Connection/Consent/Conversation/relationship/launch authority.

These remain candidate design evidence, not accepted contract.

## 3. Blocking contradiction — terminality versus dependency invalidation

R9 defines:

- generic `bindings.terminal = terminality.derived_terminal`;
- `derived_terminal=true` exactly for:
  `MUTUALLY_ACCEPTED | DECLINED | WITHDRAWN | EXPIRED`;
- `derived_terminal=false` for `UNKNOWN`;
- dependency invalidation changes classification to `UNKNOWN`;
- `proposal_reopened=false` and `lifecycle_reset=false` remain required.

The accepted Canonical Match evaluator supports exactly that invalidation transition:

- a derived result may first be terminal;
- `invalidate()` may later change its classification to `UNKNOWN`;
- invalidation explicitly preserves `proposal_reopened=false` and `lifecycle_reset=false`.

The accepted IP-13A generic persistence contract independently enforces:

`TERMINAL_IDENTITY_REOPEN_REJECTED`

whenever a record with the same `lifecycle_identity` previously had:

`bindings.terminal=true`

and a later record has:

`bindings.terminal!=true`.

Under the R9 candidate contract, materializing a dependency-invalidated form of an already terminal derived Match result would therefore produce:

- same Match lifecycle identity;
- prior `bindings.terminal=true`;
- new classification `UNKNOWN`;
- new `derived_terminal=false`;
- new `bindings.terminal=false`;
- payload says `proposal_reopened=false`;
- IP-13A treats the write as a terminal reopen and rejects it.

Those semantics cannot all be true simultaneously.

This is a record/projection contract defect, not an adapter implementation detail. R10 must not be asked to guess around it.

## 4. Required terminality/invalidation repair decision

A correction review must choose an exact sound model.

At minimum it must compare:

### Model A — sticky derived terminality

Once a derived Match lifecycle has reached a terminal classification, later dependency invalidation may produce classification `UNKNOWN` while the record-level terminal marker remains terminal.

If selected, the contract must define how the persisted payload carries enough pre-invalidation terminal context deterministically, because the current invalidated evaluator result overwrites classification with `UNKNOWN`.

### Model B — generic invalidation-overlay only for persisted terminal results

A terminal derived record remains stored unchanged and generic `observeInvalidation()` marks the projection unusable; no new non-terminal derived record is persisted for that lifecycle.

If selected, the contract must explicitly state whether payload-level dependency invalidation is:
- not materialized for terminal records;
- retained only for non-terminal records; or
- removed from the persistence contract.

It must also state how dependency identity provenance remains available without pretending the generic logical-record invalidation overlay identifies a domain dependency.

### Model C — additional evaluator/record contract evidence required

If neither A nor B can preserve exact dependency-scoped invalidation plus no-reopen semantics, the result must classify the repair blocked rather than inventing a mapping.

No implementation is authorized by this review.

## 5. Secondary ambiguity — malformed evaluator outputs versus record eligibility

R9's bounded persisted reason vocabulary includes evaluator reasons such as:

- `EXACTLY_TWO_PARTICIPANTS_REQUIRED`;
- `INVALID_PROPOSAL_SHAPE`;
- `INVALID_SLOT_DECISION`.

But the same R9 record contract requires, among other things:

- non-empty proposal identity;
- non-empty protected-use scope;
- exactly two binding participants;
- valid participation-state vocabulary;
- valid decision-slot vocabulary.

Some raw evaluator UNKNOWN results can therefore contain a permitted reason while lacking the fields required to construct the proposed record.

This can be sound only if the future domain-to-application adapter boundary rejects those malformed structures before evaluator-to-record materialization, analogous to the accepted Runtime Readiness synthetic boundary.

R9-R1 must explicitly classify:

- which evaluator input failures are pre-materialization request/input rejections;
- which evaluator UNKNOWN results are valid derived records and must be losslessly persistable;
- which bounded reason categories can actually occur in a persisted Match payload under that boundary.

Do not silently claim the record contract is lossless for evaluator outputs that it cannot represent.

## 6. Non-blocking observations

No blocker was established for:

- projection metadata vocabulary `CURRENT | LAGGED | UNKNOWN`;
- derived correlation revision value `0` as non-global correlation;
- deterministic lineages derived from semantic digest;
- IP-13F non-participation;
- existing IP-13E generic method set;
- privacy-minimal separation of raw source evidence.

## 7. Candidate disposition

Candidate:

`b03966d09e91430a31a03eecf5d3b8575602357d`

is not authorized for integration.

R10 domain-to-application mapping review is not yet authorized because it would inherit an unresolved terminality/invalidation contradiction from the record contract.

The next task must be:

`IP-13I-R9-R1 CANONICAL MATCH TERMINALITY / INVALIDATION AND RECORD-ELIGIBILITY CONTRACT CORRECTION REVIEW — DOCUMENT ONLY`

## 8. Final classification

`IP-13I-R9 CANDIDATE REJECTED — ADDITIVE MATCH RECORD/PROJECTION DIRECTION RETAINED BUT TERMINAL DERIVATION→DEPENDENCY INVALIDATION WOULD FLIP bindings.terminal TRUE→FALSE UNDER SAME LIFECYCLE AND TRIGGER IP-13A TERMINAL_IDENTITY_REOPEN_REJECTED WHILE PAYLOAD CLAIMS proposal_reopened=false — MALFORMED-EVALUATOR-OUTPUT RECORD ELIGIBILITY ALSO REQUIRES EXPLICIT BOUNDARY — R10 DEFERRED — R9-R1 DOCUMENT-ONLY CORRECTION REQUIRED`
