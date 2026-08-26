# ADR-011: Private-Interaction Analytics and Model-Improvement Scope Exclusion

Status: `PROPOSED — AWAITING GPT L3 AND OWNER REVIEW`

Date: `2026-08-26`

Decision owner: Owner, after GPT L3 review

Depends on: ADR-001–010; accepted U-02/U-03/U-04/U-06/U-07/U-11 closeouts; accepted Phase 34 Safety authority; accepted LC-02 boundaries

## Context

U-14 remains `BLOCKING`. Current accepted authority excludes private Conversation from default Compatibility, Ranking, analytics, fairness, and model-training use, but no Owner decision yet excludes the entire affected analytics/model-improvement purpose from current MVP/pre-alpha scope.

This proposal is based on current product scope and absence of accepted authority/evidence. It does not claim that the affected purpose is universally unlawful, unsafe, impossible, permanently prohibited, or universally undesirable. Issue #7 is the controlling execution contract.

## Evidence discipline

### Observed / Accepted Authority

- Private Conversation is not general Compatibility input, and ADR-003 rejects private Conversation mining for Compatibility learning and MVP private-message mining.
- Relationship Feedback is purpose-classified and non-reputational.
- Safety evidence, reasoning, counts, allegations, cases, and case state cannot become ordinary analytics/model inputs or person, Compatibility, Ranking, reputation, or desirability signals.
- Named-purpose, provenance, shared-rights, lifecycle, correction, fairness, epistemic, and cross-context authority remain mandatory. Storage, custody, visibility, history, availability, or technical access creates no new authority.
- U-07 signal candidacy creates no processing, model, or implementation authority.

### Prior Conceptual Exploration

The Phase 16 UNKNOWN-disposition workshop recorded U-14 as `BLOCKING` and identified explicit scope exclusion as a possible Owner disposition. Its prepared questions are planning inputs, not specialist findings, legal conclusions, evidence, or authority.

### Product Inference

A precise purpose exclusion can reduce current MVP scope without performing research, processing data, inspecting private interaction, designing analytics/models, or selecting technology. The exclusion must remove dependent product promises and must neither sweep ordinary operational telemetry into the scope nor authorize it.

### Proposed Product Decision

Recommend **Option A**: exclude the affected private-interaction analytics/model-improvement purpose from current MVP/pre-alpha scope, with the boundaries and re-entry gate below.

This is proposed, not Owner accepted. U-14 remains `BLOCKING` and Issue #7 remains OPEN.

### Still Unknown / Requires Later Review

Future purposes, fields, information classes, shared rights, data authority, privacy/sensitivity, consent/legal basis, minimization, lifecycle, fairness, evidence/method, comprehension/control, affected population, claims, remedies, qualified review, operational ownership, technical facts, processing, and implementation remain unknown.

## Proposed Decision

If the Owner later selects Option A after GPT L3 review:

1. Define the affected purpose as use of private/shared human-interaction information beyond its original interaction purpose for analytics, model improvement, signal learning, Ranking improvement, personalization learning, training/evaluation, or general optimization.
2. Exclude from current MVP promises and design scope private Conversation mining; private-message signal extraction; Conversation semantic summaries, embeddings, features, derived interpretations, and model inputs; Conversation-derived Ranking/Compatibility/general analytics; default training/evaluation on private Conversation; generalized learning from private/shared interaction meaning; and private-interaction-derived reputation, desirability, person, behavioral, or Compatibility signals.
3. Include message/interaction metadata only when it is used to infer relational, psychological, desirability, Compatibility, Safety, or behavioral meaning. A metadata label does not avoid the boundary.
4. Preserve multi-dimensional shared-information authority. Authorship, visibility, subject interest, custody, and lifecycle authority do not collapse into one permission.
5. Keep Relationship Feedback purpose-classified and non-reputational. A future bounded same-User reflection/feedback purpose may be considered only under separate authority; this decision grants none.
6. Keep Safety evidence, reasoning, counts, allegations, cases, findings, and case state out of ordinary analytics/model improvement. Minimum-necessary control directives remain enforcement-only.
7. Keep ordinary non-content operational telemetry outside the exclusion only when it neither inspects private content nor infers private/shared interaction meaning nor creates an incompatible new purpose. This is classification only and authorizes no field, logging, retention, pipeline, telemetry execution, analytics, or processing.
8. Remove current-MVP promises of private-conversation learning, private-message Compatibility improvement, hidden intimate personalization, automatic relationship-success learning, private-interaction reputation/desirability, or Safety-derived ordinary personalization.
9. Authorize no collection for later use, speculative retention, shadow dataset, embedding, feature, model copy, logging, or pipeline. Historical availability and legacy implementation cannot create or preserve authority.
10. Require a new Owner-authorized re-entry review covering exact purpose and information class; provenance/authorship/shared rights; U-05 data authority; privacy/sensitivity; applicable consent/legal basis; minimization; lifecycle/retention/correction/deletion; U-06 fairness/proxy/missingness; U-07 epistemic/signal boundaries; comprehension/control; affected population; model/analytics purpose and claim limits; stop/remedy; and qualified review.
11. Preserve U-05, U-08, U-09, U-10, U-12, U-13, and U-15 as independently unresolved. Do not infer meaningful-Conversation measurement, launch evidence, accessibility, pacing, quality targets, or technical facts.

Only explicit Owner acceptance and final closeout may change the U-14 disposition to `EXCLUDED FROM CURRENT MVP / PRE-ALPHA SCOPE`.

## Viable alternative

**Option B:** retain U-14 as `BLOCKING` pending later specialist, data, and legal authority.

Prefer Option B if the Owner wants to retain an affected future/current promise, the exclusion cannot cover every affected pathway, the operational-telemetry distinction cannot be safely expressed, or downstream independence cannot be established. Option B authorizes no research, collection, processing, analytics, model work, or implementation.

## Rejection and exit conditions

Reject or revise Option A if it:

- leaves any affected current-MVP promise or use in scope;
- treats a technology or storage label as the purpose boundary;
- silently includes all operational telemetry or silently authorizes telemetry/logging/retention/processing;
- implies current Relationship Feedback processing or learning authority;
- allows shared-information custody, visibility, history, broad consent, or unilateral permission to create reuse authority;
- permits Safety evidence or reasoning to leak into ordinary purposes;
- authorizes speculative collection, retention, shadow data, embeddings, features, or model copies;
- treats future-gate completeness as approval;
- relies on an unresolved U-05, U-06, U-07, legal, empirical, or specialist conclusion;
- selects analytics, model, technical, operational, or implementation design; or
- is described as empirical validation, legal clearance, processing authority, model authority, implementation authority, or a permanent universal ban.

If a required exclusion boundary cannot be maintained, remove the affected promise/use or retain U-14 `BLOCKING` under Option B.

## Alternatives rejected

- **Blanket exclusion of all telemetry:** collapses ordinary operational state with private-interaction meaning and overstates the proposed scope.
- **Telemetry or logging approval by omission:** converts classification into unauthorized execution.
- **Collect or retain now for possible future use:** lets an excluded purpose bootstrap data authority.
- **Custody, history, broad consent, or technical access as reuse authority:** violates named-purpose and shared-rights governance.
- **Permanent universal ban:** overclaims beyond current product scope and current evidence.
- **Partial exclusion while retaining affected promises:** hides a blocking purpose behind wording.

## Consequences

### Positive

- Current MVP scope and promises become smaller and more explicit.
- Private/shared interaction meaning, Relationship Feedback, Safety information, and ordinary telemetry remain distinguishable.
- Hidden learning and speculative data-retention pathways are made explicit stop conditions.
- Future proposals receive a strict re-entry gate without receiving authority now.

### Costs and constraints

- Current MVP cannot promise private-interaction learning or optimization.
- Any future proposal requires a new Owner-authorized review and all applicable evidence/authority.
- U-09 measurement and U-05/U-08/U-10/U-12/U-13/U-15 dependencies remain unchanged.
- No empirical, legal, analytics, model, operational, or technical conclusion follows.

## Retained unknowns

- U-14 remains `BLOCKING — PROPOSED SCOPE EXCLUSION AWAITING GPT L3 AND OWNER REVIEW`.
- U-05 participant/data authority; U-08 launch segment/readiness; U-09 meaningful-Conversation measurement; U-10 comprehension/accessibility; U-12 quality/targets; U-13 pacing/state vocabulary; and U-15 technical facts remain unresolved.
- Every concrete purpose, information class/field, provenance/shared-rights outcome, consent/legal basis, privacy/sensitivity assessment, minimization/lifecycle rule, fairness/proxy/missingness effect, method/evidence, telemetry boundary, feedback use, user control, affected population, claim, remedy, reviewer qualification, operational ownership, Safety process, technical architecture, processing activity, and implementation remains unknown.

## Authority boundary and stop

This ADR authorizes no DeepSeek or external/legal research; participant research or recruitment; data collection or personal/sensitive processing; private Conversation inspection/mining; analytics or telemetry execution; embeddings/features; model training/evaluation; Ranking/model design; statistics/fairness study; Safety Operations; logging/retention pipeline; database/schema/API/event/backend/Flutter/services/infrastructure/code; U-05/U-08/U-09/U-10/U-12/U-13/U-15 resolution; LC-03; LC-04; Phase 36; implementation; or successor work.

DeepSeek calls: `0`. Issue #7 remains OPEN. Do not mark U-14 excluded/resolved. Stop for GPT L3 and Owner review.
