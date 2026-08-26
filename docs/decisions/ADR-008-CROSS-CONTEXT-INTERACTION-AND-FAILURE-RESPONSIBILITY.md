# ADR-008: Cross-Context Interaction and Failure Responsibility

Status: `PROPOSED — AWAITING GPT L3 AND OWNER REVIEW`

Date: `2026-08-26`

Decision owner: Owner, after GPT L3 review

Depends on: ADR-001–007; accepted U-02/U-03 and U-04 closeouts; Phase 34 Safety authority; accepted LC-02 boundaries

## Context

Seven conceptual domains are accepted, but U-11 remains `BLOCKING` because exact product responsibility for cross-context meaning, decisions, purpose review, lifecycle changes, failures, Connection, propagation, and reconstruction has not been accepted. Conceptual domains are not services, modules, stores, teams, or deployment units.

## Evidence discipline

### Observed / Accepted Authority

Product Truth, domain meaning, information purpose/lifecycle, reciprocal Connection, five-dimensional shared-information authority, and the 28 Safety invariants are controlling. Safety evidence cannot enter ordinary domains; only minimum-necessary control directives may cross. AI and case-processing state are not person truth.

### Prior Conceptual Exploration

The Quality Attribute Scenarios and Context Map workshop proposed movements, failure responses, and restrictive precedence but remained proposal-only and is reconciled here against later accepted authority.

### Product Inference

A bounded handoff must transfer only authorized meaning for a named purpose. Source and receiver retain distinct failure duties, and technical custody cannot absorb meaning, lifecycle, or decision authority.

### Proposed Product Decision

Accept the responsibility model in `ELITESYNC_V10_U11_CROSS_CONTEXT_RESPONSIBILITY_WORKSHOP_V0_1.md`, subject to Owner selection of its Decision Packet.

### Still Unknown / Requires Later Review

U-06 fairness method, U-12 quality/capacity, legal/factual duties, operational roles, exact targets, retention, reviewers, tooling, and implementation remain unresolved.

## Proposed decision

1. Use separate meaning authority, bounded decision authority, execution responsibility, purpose-review authority, lifecycle authority, failure ownership, reconstruction responsibility, and final Owner authority.
2. Require every cross-context interaction to state its source meaning, named purpose, minimum necessary content, prohibited inference, receiver acceptance, lifecycle propagation, and fail-safe outcome.
3. Keep Connection meaning in Relationship. Matching presents opportunity only; reciprocal current choice is required; Conversation receives only bounded access authority.
4. Require affirmative purpose compatibility. Storage, custody, visibility, prior use, or broad consent creates no new purpose authority.
5. When authority is missing, stale, contradictory, or partly propagated, do not create permission. The affected purpose applies the current effective least-permissive outcome while preserving distinct reasons and routing unresolved conflict for review.
6. Source authority declares correction/revocation/reversal/supersession; dependent contexts remove stale active effects and separately determine whether renewed use is permitted.
7. Safety authorizes minimum-necessary directives; ordinary domains enforce only their meaning, receive no evidence/reasoning, and remove stale controls after authorized reversal.
8. Consequential decisions must support bounded reconstruction of provenance, purpose, authority, time, policy, changes, restrictions, and consuming action without broad private/Safety disclosure or indefinite retention.
9. AI and analytics remain supporting capabilities and cannot create truth, consent, guilt, Connection, Relationship state, Safety finding, or cross-context authority.
10. Treat the workshop's nine minimum semantics as a proposed affected-MVP responsibility gate. Drafting this ADR does not satisfy or accept that gate.

Dependency classifications are limited to: `PRODUCT RULE CAN BE OWNER-DECIDED NOW`, `REQUIRES LATER FACT / FORMAL REVIEW`, `DEPENDS ON U-06 FAIRNESS`, `DEPENDS ON U-12 QUALITY / CAPACITY`, `REQUIRES LATER LEGAL AUTHORITY`, and `PROHIBITED BY ACCEPTED AUTHORITY`.

## Recommended option

Accept the workshop's recommended A options as a coherent technology-neutral product-policy baseline, then retain U-11 as `BLOCKING` until GPT L3 review, explicit Owner acceptance, incorporation of any required revisions, and final closeout.

Reasons:

- it preserves source meaning while making consumer and failure responsibility explicit;
- it makes cessation, denial, and omission legitimate safe outcomes;
- it prevents Safety evidence, private interaction, AI output, or custody from acquiring new authority;
- it gives later U-12 work responsibility boundaries without selecting targets or capacity; and
- it can reduce MVP scope when responsibility cannot yet be accepted.

## Viable alternative

Remove from affected MVP every cross-context interaction whose responsibility contract is not accepted. Retain only journeys whose meaning, purpose, lifecycle, failure, and reconstruction boundaries are already complete.

Prefer this alternative when the Owner wants the smallest safe scope or qualified review cannot yet support one or more proposed responsibilities.

Reject the alternative if the product still presents the affected cross-context promise or dependent output; deferral must remove the use, not hide an unresolved responsibility.

## Rejection and exit conditions

Reject or revise the proposed decision if later review shows that it:

- weakens ADR-001–007, Phase 34 Safety authority, or accepted LC-02 boundaries;
- transfers source meaning or purpose authority through custody;
- permits Safety evidence or private Conversation leakage;
- lets stale/unknown state create permission;
- collapses distinct restrictions, case states, or human meanings;
- requires an unaccepted fairness, legal, factual, or quality conclusion; or
- cannot be expressed without selecting implementation or Safety Operations.

Exit the affected MVP scope if a required responsibility cannot be accepted before implementation authority is considered.

## Alternatives rejected

- **One owner per record or flow:** rejects the accepted five-dimensional and multi-authority model.
- **Receiver owns transferred meaning:** allows handoff to redefine source truth.
- **Technical custody owns failures:** confuses availability with product authority.
- **Best-effort continuation under stale/unknown state:** silently creates permission.
- **Generic restrictive account state:** collapses closure, revocation, self-protection, interim protection, and reviewed restriction.
- **Safety evidence supplied to ordinary consumers:** violates containment.
- **AI/analytics resolves cross-context conflict:** grants unsupported truth and decision authority.

## Consequences

### Positive

- Cross-context decisions remain attributable and reviewable.
- Connection, Conversation access, correction, restriction, and Safety controls retain distinct meanings.
- Consumers have a defined duty to reject unauthorized use and remove stale effects.
- Later quality work can assign evidence and targets to accepted responsibility boundaries.

### Costs and constraints

- Some product value must stop or be omitted when authority is missing.
- Cross-context uses require explicit purpose and lifecycle reasoning.
- MVP scope may shrink if an interaction cannot meet the proposed gate.
- Operational and technical design remain blocked until separate authority and retained dependencies are addressed.

## Retained unknowns

- U-11 remains `BLOCKING` pending review and Owner decision.
- U-06 fairness scope/method and U-12 quality/capacity remain `BLOCKING` and unchanged.
- Concrete trigger thresholds/durations, evidence standards, reviewer qualification/authority, contested disclosure/retention outcomes, exact retention, legal preservation, backup treatment, anonymization verification, timing, notice/appeal, external routing, Safety Operations, and every other separately unresolved `BLOCKING UNKNOWN` remain unresolved.
- No database, schema, API, event, service, backend, Flutter, retry, queue, consistency, storage, infrastructure, model, analytics, deployment, or code decision is made.

## Authority boundary and stop

This ADR is a proposal, not acceptance. It grants no implementation, processing, Safety Operations, LC-03, LC-04, Phase 36, or successor-work authority. DeepSeek calls: `0`. Stop for GPT L3 and Owner review.
