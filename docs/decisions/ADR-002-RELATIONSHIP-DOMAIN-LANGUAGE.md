# ADR-002: Relationship Domain Language

Status: ACCEPTED

Owner acceptance recorded: 2026-08-24

Independent review state: AWAITING GPT L3 REVIEW

Date: 2026-08-23

Decision owners: Owner (final product authority), with ChatGPT architecture/product review

Depends on: ADR-001 (Product Vision and Trust Boundary), accepted

## Context

Phase 1 defines EliteSync as decision support for allocating limited attention to better-informed, respectful conversations. Phase 2 needs a shared relationship language before domain architecture or implementation can be designed. Historical entities, tables, and competitor feature names cannot supply that language because they carry legacy or product-specific assumptions.

## Observed

- Phase 1 distinguishes algorithmic hypotheses from human relationship potential.
- Phase 1 requires bounded candidate supply, reciprocal interaction, user correction, explicit uncertainty, and AI trust limits.
- Competitor evidence shows visible profile, matching, and chat surfaces but provides no evidence that their internal state language or safety journeys are suitable for EliteSync.

## Inferred

- Using “match” for a score, mutual connection, and relationship would collapse different consent states.
- Treating user feedback as a rating of another person would create safety, fairness, and human-worth risks.
- Explicit failure and control states are necessary domain concepts, not edge cases.

## Proposed Decision

### Lifecycle

The canonical product journey is:

```text
Anonymous Visitor
→ Identity Formation
→ Self Understanding
→ Match Ready
→ Curated Match
→ reciprocal Connection
→ Conversation
→ user-defined Relationship Development or respectful Closure
→ Feedback Update
```

Transitions require appropriate user choice and can pause, reverse, close, or enter a safety path. Registration alone does not imply Match Readiness.

### Core language

1. A **User** is a person with agency, not an algorithmic representation.
2. **Identity** is the evolving, self-authored relationship context; a **Profile** is a purpose-specific visible projection of selected Identity information.
3. A **Personality Profile** is a revisable reflection, not diagnosis or destiny.
4. **Relationship Preference** expresses current intent, pace, priorities, acceptable differences, and boundaries.
5. A **Compatibility Signal** is bounded evidence with source, purpose, uncertainty, sensitivity, and permitted use.
6. A **Compatibility Hypothesis** is an explainable, revisable proposition worth testing through human interaction, not a verdict.
7. A **Match** is a bounded introduction opportunity, not a score or mutual state.
8. A **Connection** is reciprocal, revocable consent to explore communication.
9. A **Conversation** is a consent-based communication context, not proof of interest or relationship.
10. An **Interaction** is concrete evidence whose meaning remains contextual.
11. A **Relationship** is human-defined and mutually understood; platform activity cannot create it automatically.
12. **Relationship Feedback** is contextual learning, not a public rating or objective judgment of another person.
13. **Ranking** orders eligible opportunities for a defined purpose; it does not rank human value.
14. A **Recommendation** is transparent decision support; it is not a command or destiny prediction.

### Compatibility learning

```text
Compatibility Signal
→ Compatibility Hypothesis
→ Human Interaction
→ Feedback Update
```

Feedback may confirm, contradict, complicate, or leave the hypothesis unknown. Preference feedback, product feedback, user correction, and safety evidence must retain distinct meanings.

### Consent invariants

- Profile creation is not consent to matching.
- Match Readiness requires informed opt-in and is reversible.
- A Match is not contact consent.
- Only reciprocal choice creates a Connection.
- A Connection is not permanent consent or a Relationship.
- Conversation participation is not consent to hidden inference, publicity, or AI impersonation.
- Relationship status belongs to the people involved, not algorithmic inference.
- Block and report do not require reciprocal agreement.

### Safety and failure states

Rejection, no response, Connection closure, block, report, harassment risk, and deception risk are first-class journey states. They must support neutral closure, immediate separation where requested, and clear safety routing without turning private preference into public reputation.

### Domain scope

Core product concerns are Identity/Self Understanding, Preference/Readiness, Compatibility, Matching, Connection/Conversation, Relationship Learning, and Trust/Safety Controls.

Payment, administration, analytics, notifications, customer support, and operational case handling are supporting/peripheral concerns. This classification does not select services, modules, tables, APIs, or ownership implementation.

### Authority

Acceptance of this ADR freezes product language and journey boundaries only. It does not authorize technical domain models, database schema, API contracts, backend/Flutter design, microservices, or code.

## Alternatives considered

### A. Reuse 9.x entity and database names

Rejected because persistence history must not define the new relationship domain.

### B. Use Match for every successful-looking state

Rejected because it conflates recommendation, mutual consent, conversation, and relationship, obscuring user rights and lifecycle meaning.

### C. Define compatibility as a single score

Rejected because it hides uncertainty and converts decision support into a false verdict.

### D. Treat rejection, silence, and reports as generic negative feedback

Rejected because preference, ambiguity, and safety evidence have different meaning, sensitivity, and consequences.

### E. Let activity infer relationship status

Rejected because message frequency or duration cannot establish mutual human meaning.

## Consequences if accepted

### Positive

- Creates precise shared language before technical modeling.
- Makes reciprocal consent and user control visible in every journey transition.
- Keeps algorithmic evidence separate from human relationship meaning.
- Prevents safety evidence from being reduced to recommendation feedback.
- Constrains MVP scope to the core Slow Dating loop.

### Costs and constraints

- Later product and technical designs must preserve distinct states rather than using a convenient generic “match.”
- Feedback provenance and user controls require dedicated product-policy design.
- A respectful pass or closure must be treated as a legitimate outcome, complicating activity-only success metrics.
- Some journey transitions cannot be finalized until safety, privacy, and compliance policy is reviewed.

## Unknowns requiring follow-up

- Minimum Match Readiness evidence and assurance.
- Approved relationship-state vocabulary for MVP.
- Signal taxonomy and epistemic-strength language.
- Meaningful-conversation definition and privacy-safe measurement.
- Cultural-reflection consent and permitted use.
- Deletion, retention, appeal, identity assurance, moderation, and emergency policy.
- Exact pacing, expiry, pause, and reset semantics.

## Validation required before acceptance

- GPT L3 product/domain review.
- Owner approval of lifecycle stages, core terms, consent invariants, safety states, domain scope, and MVP boundary.
- Consistency review against ADR-001 after its acceptance status is finalized.

## Recommended Phase 3

Trust, Safety, Privacy, and Compatibility Evidence Workshop.

Phase 3 should classify allowed signals and inferences, define consent/purpose boundaries, safety states and escalation principles, feedback provenance, deletion/retention questions, and evaluation needs. It must remain product-policy and conceptual architecture work before technical modeling.
