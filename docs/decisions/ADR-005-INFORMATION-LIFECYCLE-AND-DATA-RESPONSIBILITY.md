# ADR-005: Information Lifecycle and Data Responsibility

Status: ACCEPTED

Owner acceptance recorded: 2026-08-24

Independent review state: AWAITING GPT L3 REVIEW

Date: 2026-08-24

Decision owners: Owner (final product authority), with ChatGPT architecture/product review

Depends on: ADR-001 through ADR-004, all accepted

## Context

The proposed v10 product and domain language separates declarations, interpretations, Compatibility Hypotheses, Matches, Connections, private interaction, Relationship Feedback, and Safety evidence. Before technical architecture, v10 needs a conceptual rule for where information comes from, who controls its meaning, which purposes may consume it, and what correction, revocation, reset, export, deletion, and retention mean.

## Observed

- Existing ADRs require provenance, purpose limitation, uncertainty, user correction, consent, and separation of Safety from romantic Ranking.
- AI is a constrained capability rather than a source of domain truth.
- No supplied evidence establishes legal bases, retention periods, fairness thresholds, or technical quality targets.
- ADR-004's seven-domain recommendation and five-domain alternative remain unaccepted proposals.

## Inferred

- Storage ownership cannot safely determine information authority.
- Visibility, collection, and technical availability do not authorize reuse.
- Derived artifacts retain source restrictions and may create greater sensitivity than their inputs.
- Revocation must stop future optional processing but cannot promise to undo another person's prior receipt or independent authorship.

## Proposed Decision

### 1. Responsibility model

Information responsibility is governed by four independent questions:

1. **Meaning authority:** which User or domain defines what the information means.
2. **Provenance:** User declared, System observed, Model interpreted, AI generated, or Human verified.
3. **Purpose authority:** which named use was explained and approved.
4. **Lifecycle authority:** who may correct, restrict, expire, retain, export, reset, or delete it.

No database, service, model, or processing domain becomes the owner of human meaning merely by holding or transforming information.

### 2. Information classes

- **User-authored:** declarations, preferences, corrections, consent choices, private reflections, and feedback. Users control declaration, visibility, correction, and future optional use, subject to narrow disclosed exceptions.
- **System-generated:** readiness, Ranking, Match/state transitions, and explanation assembly. These must expose purpose, input class, time relevance, responsibility, and contest route where consequential.
- **AI-generated:** summaries, interpretations, explanations, prompts, and suggestions. These are labeled AI-generated, uncertain, correctable/dismissible, and never User fact or verified truth.
- **Safety-controlled:** reports, allegations, evidence, protections, restrictions, outcomes, appeals, and retention duties. Safety controls access and purpose; this class never becomes romantic Ranking or public reputation.
- **Private Interaction:** Conversation, shared interaction context, and private feedback. It is private by default and excluded from general Ranking, cross-user profiling, and general model training without a separately reviewed authority.

Classifications may overlap; the strictest applicable boundary governs.

### 3. Provenance rules

- Provenance stages do not form an automatic confidence ladder.
- Every consequential derived item preserves its sources, purpose, uncertainty, time relevance, and governing policy/model context.
- Model interpreted and AI generated information cannot become Human verified without a defined authorized human act and standard.
- Human verification is claim-specific, purpose-specific, contestable, and capable of expiry.
- Derived information does not overwrite its source or silently broaden permission.

### 4. Purpose limitation

- Every use requires a named, understandable, necessary purpose compatible with collection context.
- Collection, Profile visibility, Matching, AI assistance, analytics, model improvement, and Safety handling are separate purposes.
- New or incompatible purposes require review and new consent or other valid authority where applicable.
- One User cannot authorize another person's private information.
- Safety evidence, private interaction, and Relationship Feedback cannot be repurposed into romantic desirability or public reputation.

### 5. Consent and rights lifecycle

- Consent is specific, informed, affirmative where required, time-relevant, and revocable for future processing.
- Correction triggers review or refresh of active dependent outputs.
- Revocation stops new optional processing and new dependent outputs for that purpose; existing outputs are invalidated, withdrawn, deleted, or retained only under an approved exception.
- Recommendation pause/opt-out is separate from Identity deletion.
- Reset retires recommendation/reflection learning but is not account deletion and does not erase other-person or Safety-controlled records.
- Export and deletion requests must be understandable and preserve other-person, Safety, and legal boundaries.
- Any retention exception must be narrow, disclosed, access-restricted, purpose-limited, and reviewed.

### 6. Relationship Feedback

Feedback is classified at authorship as private reflection, author-owned Identity/Preference correction, permitted Compatibility learning, product-usefulness feedback, or Safety concern. Only the selected purpose receives it. It never becomes a public personality or worth score. A Safety concern leaves the ordinary feedback path and follows restricted Safety handling.

### 7. Non-automatic transitions

The following cannot occur automatically:

- Personality/cultural reflection → Ranking evidence.
- Match → Connection, Conversation, or Relationship.
- Conversation activity → affection, Compatibility, or Relationship status.
- AI output → User fact, Human verified evidence, consent, guilt, or Safety outcome.
- Relationship Feedback → another User's Identity or public reputation.
- Safety evidence → Compatibility or romantic Ranking.
- Visibility or prior consent → unrelated reuse.

### 8. Quality attributes

- **Privacy:** minimization and separation by purpose and information class.
- **Explainability:** understandable source, rationale, uncertainty, and control for material outputs.
- **Reliability:** consistent enforcement of consent, correction, pause, closure, block, and revocation, including failure conditions.
- **Auditability:** reconstruct consequential generation/use/change/restriction without indiscriminate surveillance.
- **Safety:** protection precedes engagement; Safety handling is restricted, reviewable, and separated from romantic meaning.
- **Fairness:** purpose-specific assessment of direct signals, proxies, missingness, and feedback loops with defined stop conditions before expansion.
- **User Control:** inspection, correction, pause, revoke, reset, export-request, deletion-request, closure, block, and contest.

Numeric targets and technical mechanisms remain Unknown and require a later scenario workshop.

### 9. MVP boundary

MVP supports minimum self-authored Identity/Profile/Preference controls; explicit consent; corrections; an approved explicit-signal allowlist; labeled optional reflection; explainable hypotheses and Match explanations; reciprocal Connection; basic private Conversation; classified feedback; block/report/Safety routing; reset/export/deletion requests; and sufficient provenance/audit evidence.

MVP excludes passive compatibility scoring, private-message mining, sensitive-trait inference, cultural-system Ranking, general training on private interaction, public reputation, unified feedback scores, deterministic Compatibility, autonomous relationship decisions, and high-risk automated Safety verdicts.

### 10. Authority boundary

Acceptance freezes conceptual lifecycle, responsibility, provenance, purpose, user-control, quality-attribute, and MVP boundaries only. It does not authorize database/schema/ORM, API, backend/Flutter, services, infrastructure, model selection/training, code, migration, or deployment.

This decision is governed by the refinement order:

```text
Product Truth
→ Domain
→ Information
→ Architecture
→ Implementation
```

Downstream Architecture and Implementation must preserve the accepted Product Truth, Domain meaning, and Information responsibilities. Storage or implementation convenience cannot redefine upstream meaning, provenance, purpose, consent, or lifecycle authority.

## Alternatives considered

### A. Treat storage holder as information owner

Rejected because custody does not establish meaning, consent, purpose, or human rights.

### B. Use one broad consent for the entire product

Rejected because visibility, Matching, AI, analytics, model improvement, and Safety have materially different consequences.

### C. Let derived outputs inherit all permissions from inputs

Rejected because inference changes meaning and sensitivity and can create uses the User never understood.

### D. Retain all information for future value

Rejected because speculative utility conflicts with minimization, expiry, revocation, and purpose limitation.

### E. Merge preference, product, relationship, and Safety feedback

Rejected because these have different subjects, evidentiary force, access, correction, and harm risks.

### F. Delete every related item immediately on any request

Rejected as a universal promise because shared authorship, another User's rights, Safety evidence, appeals, and legal duties may require bounded exceptions; exact policy remains Unknown.

## Consequences if accepted

### Positive

- Preserves user agency and provenance across every derived artifact.
- Prevents purpose creep, public rating, Safety-to-Ranking leakage, and AI authority inflation.
- Makes correction, revocation, reset, export, and deletion first-class product obligations.
- Gives later architecture a technology-neutral quality and responsibility contract.

### Costs and constraints

- Data collection and reuse opportunities remain intentionally narrow.
- Derived outputs need expiry, correction, and dependency handling.
- Shared and Safety-controlled information requires policy and specialist review.
- Auditability must be balanced against minimization and private-interaction protection.
- Technical design cannot begin from this ADR alone.

## Unknowns requiring follow-up

- Legal bases, sensitive-information classification, localization/cross-border rules, age/identity assurance, generative-AI and automated-decision obligations.
- Exact consent renewal, retention, expiry, deletion propagation, backup treatment, export, appeal, and notification rules.
- Shared Conversation and mutually authored Relationship rights.
- Fairness groups, harm taxonomy, measures, thresholds, and stop conditions.
- Measurable Privacy, Explainability, Reliability, Auditability, Safety, Fairness, and User Control scenarios.
- Selected domain model, context map, information contracts, failure ownership, and all technical architecture choices.

## Validation required before acceptance

- GPT L3 product-architecture review.
- Owner approval of classification, provenance, purpose, consent/revocation, feedback, prohibited transitions, MVP scope, and quality priorities.
- Specialist legal/privacy, Safety, fairness, and user-research review before operational policy or technical design.
- Consistency review after ADR-001–004 statuses and the domain option are finalized.

## Recommended Phase 6

Quality Attribute Scenarios and Conceptual Context Map Workshop. It should define measurable, technology-neutral scenarios; cross-domain information contracts; policy decision points; and failure responsibility. It must remain prior to database, API, backend, Flutter, infrastructure, AI implementation, or code design.
