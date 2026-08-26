# ADR-014: Mandatory Quality Scenario and Target-Authority Governance

Status: `PROPOSED — AWAITING GPT L3 REVIEW`

Date: `2026-08-27`

Decision authority: GPT L3 only within Owner-delegated bounded governance after independent review

Depends on: ADR-001–013; accepted U-02/U-03/U-04/U-06/U-07/U-09/U-11/U-13/U-14 closeouts; accepted LC-02 and Phase 34 Safety boundaries

## Context

U-12 remains `BLOCKING`. Accepted authority establishes quality priorities and scoped lifecycle, Safety, fairness, epistemic, privacy, and fail-closed boundaries, but no accepted mandatory scenario/target-authority governance or concrete quality targets. Historical Phase-6 scenarios and G-06 are conceptual/readiness inputs only.

The product-policy layer can propose mandatory scenario families, target grammar, evidence prerequisites, and remedy/stop rules without selecting numeric or operational targets. Every concrete target and target-dependent design choice remains separately gated.

## Evidence discipline

### Observed / Accepted Authority

Privacy, Safety, and User Control constrain ordinary value. Reliability includes correct scoped cessation/denial. Explainability cannot upgrade evidence. Fairness and Auditability cannot override privacy/Safety/control or create unrestricted collection/retention. Fail-closed is affected-scope-only and creates no person meaning. U-13 selects no pacing value; U-15 remains unresolved.

### Prior Conceptual Exploration

Historical quality scenarios and readiness gates are proposal evidence only, not validated wording, participant evidence, accepted metrics/targets, capacity, or technical requirements.

### Product Inference

Mandatory governance families can prevent silent waiver while leaving all target instances, measurement, evidence, operations, and technical feasibility unresolved.

### Proposed Product Decision

Recommend the decision below and Workshop Packet 1–13 = A. This remains proposed pending independent GPT L3 review.

### Still Unknown / Requires Later Review

All concrete targets, evidence packages, populations/environments, reviewer findings, operational capacity/staffing, Safety Operations, privacy/legal timing, fairness/comprehension metrics, technical feasibility, architecture, implementation, and U-05/U-08/U-10/U-15 remain unknown.

## Proposed Decision

1. Adopt Privacy, Explainability, Reliability, Safety, Fairness, User Control, and Auditability as mandatory current pre-alpha product-level quality-governance obligations, not empirical findings, complete NFRs, performance commitments, or numeric implementation requirements.
2. Require Privacy/Safety/User Control to constrain ordinary value; Reliability to include correct scoped cessation/denial; Explainability/Fairness/Auditability not to override those boundaries; and delivery/retry/continuation not to count as success when authority requires stop. Keep fail-closed scoped and non-personal.
3. Adopt `QA-PRIV-01`, `QA-EXPL-01`, `QA-REL-01`, `QA-SAFE-01`, `QA-FAIR-01`, `QA-CTRL-01`, and `QA-AUD-01` as mandatory scenario families. Historical wording is not validated; applicable families cannot be silently waived.
4. Require every scenario instance to contain the Workshop's fourteen-field contract: actor/condition, stimulus, environment, affected context, authority/provenance, expected and prohibited response, later observable evidence, target state, target authority, dependencies/reviewers, remedy, stop condition, and lifecycle/reversal implications. Schema completeness creates no measurement/data/processing/implementation authority.
5. Use only `POLICY INVARIANT`, `ACCEPTED TARGET`, and `UNKNOWN / NO TARGET AUTHORITY`. Policy invariants are not empirical validation. This ADR proposes no `ACCEPTED TARGET`; every concrete instance remains Unknown until separately accepted.
6. Separate target authority for comprehension/accessibility, fairness, participant outcomes, Safety, privacy/legal timing, reliability/operations, and audit/reconstruction. Concrete authority does not arise automatically from Codex, implementers, vendors, defaults, AI, analytics, telemetry, storage, or legacy code.
7. Require the Workshop's seventeen-element evidence package before any future concrete target acceptance. Checklist completeness is not acceptance and creates no research/data/measurement/telemetry/processing authority.
8. Permit bounded remedies: stop/deny/omit affected use/output; invalidate/withdraw stale effects; restore control; expose uncertainty/non-availability; route authorized review; reduce/exclude scope; and propagate correction/reversal. Create no blame, guilt, reputation, desirability, global restriction, or hidden person score.
9. Treat missing target authority as no permission for defaults and missing evidence as no success. Block/narrow/exclude only the affected decision; create no global account/person meaning. This ADR authorizes no successor discovery/design task.
10. Prohibit selection, recommendation, suggestion, implication, or inheritance of every concrete quality/pacing/operational target listed in the Workshop. Placeholders, historical values, benchmarks, vendors, conventions, AI estimates, implementation defaults, and samples create no authority.
11. Keep future target-dependent design blocked unless the applicable mandatory family and separately accepted target exist, or bounded target independence is explicitly demonstrated and separately authorized. U-15 cannot manufacture requirements from qualitative governance.
12. Permit qualitative governance promises only. Promise no numeric/validated reliability, availability, performance, Safety timing, fairness outcome, comprehension/accessibility rate, deletion/export/audit timing, empirical quality, or implementation readiness.
13. Permit only the Workshop's conditional disposition grammar. Later acceptance may complete solely the mandatory quality-scenario / target-authority / remedy-stop governance blocker, not any concrete target, evidence, capacity, operation, downstream dependency, design, or implementation.

## Alternative

Retain U-12 fully `BLOCKING` and do not establish a mandatory portfolio or target-authority grammar until concrete evidence exists.

Use this alternative if governance cannot be expressed without inventing targets, waiving applicable families, or expanding participant/data/operations/technical authority.

## Rejection and exit conditions

Reject or revise the proposal if it:

- treats mandatory family or policy invariant as empirical validation;
- creates an `ACCEPTED TARGET` without separate evidence/review/authority;
- smuggles a value through placeholder, default, history, vendor, benchmark, AI, sample, UI, or technical convenience;
- treats delivery/retry/availability as success when current authority requires cessation;
- lets Explainability/Fairness/Auditability override Privacy/Safety/User Control;
- makes fail-closed global person/account meaning;
- creates broad private/Safety disclosure, indefinite retention, blame, guilt, reputation, or hidden score;
- silently waives an applicable mandatory family;
- lets U-15 or implementers manufacture targets; or
- claims research/data/measurement/testing/operations/design/implementation/downstream authority.

## Consequences

### Positive

- Mandatory product-quality obligations and scenario coverage become explicit.
- Target absence remains visible rather than replaced with convenient defaults.
- Remedy and stop semantics preserve affected-scope authority and User control.
- Future target proposals receive a consistent evidence and acceptance contract.

### Costs and constraints

- No concrete quality acceptance target exists after this proposal.
- Target-dependent architecture/implementation remains blocked.
- Qualified evidence, specialist review, operations/technical feasibility, and explicit acceptance remain necessary.

## Retained dependencies and unknowns

- U-12 remains `BLOCKING — PROPOSED PRODUCT-POLICY GOVERNANCE AWAITING GPT L3 REVIEW`.
- U-05 participant/data activity, U-08 segment/readiness evidence, U-10 comprehension/accessibility, and U-15 technical/operations facts remain unresolved.
- All concrete quality targets; operational capacity/staffing; latency, availability, recovery, consistency; fairness metrics/baselines/thresholds; comprehension/accessibility thresholds; Safety Operations and response/review/appeal targets; privacy/legal timing; retention periods; audit/reconstruction targets; technical feasibility; architecture; and implementation remain unknown.

## Authority boundary and stop

This ADR authorizes no DeepSeek; web/external or new legal research; participant/user research/recruitment/activity; data collection/processing; telemetry/analytics/measurement; performance/load/reliability testing; statistics/experiments; concrete target/threshold/timing/SLA/SLO; capacity/staffing commitment; Safety Operations; retention/deletion/export period; fairness metric/baseline/threshold; comprehension/accessibility percentage; pacing/configuration value; architecture/interface/store/service/database/API/backend/Flutter/infrastructure/code; implementation; U-05/U-08/U-10/U-15 resolution; LC-03; LC-04; Phase 36; or successor work.

DeepSeek calls: `0`. Issue #10 remains OPEN. Do not independently accept or close U-12. Stop for independent GPT L3 review.
