# ADR-004: Domain Model and Responsibility Boundary

Status: ACCEPTED

Owner acceptance recorded: 2026-08-24

Independent review state: AWAITING GPT L3 REVIEW

Date: 2026-08-24

Decision owners: Owner (final product authority), with ChatGPT architecture/product review

Depends on: ADR-001, ADR-002, and ADR-003, all accepted

## Context

EliteSync-v10 has proposed product purpose, relationship language, evidence use, consent, privacy, AI, and Safety boundaries. A conceptual domain split is needed before information lifecycle or technical architecture work. Historical 9.x entities, database tables, services, and competitor feature structures are not valid boundary authorities.

## Observed

- Product language already distinguishes User, Identity, Profile, Personality Profile, Relationship Preference, Compatibility Signal, Compatibility Hypothesis, Match, Connection, Conversation, Interaction, Relationship, and Relationship Feedback.
- Evidence and consent meaning changes between self-description, interpretation, recommendation, reciprocal access, private interaction, relationship learning, and Safety processing.
- Safety evidence is explicitly prohibited from romantic Ranking and public reputation reuse.

## Inferred

- A single “user/matching” domain would conflate user meaning, evidence, introduction, interaction, relationship, and protection authority.
- AI is cross-domain assistance and cannot safely own domain truth.
- Safety needs authority to constrain ordinary journeys while remaining separate from compatibility meaning.

## Proposed Decision

### Seven core domains

1. **Identity:** owns self-authored relationship Identity, Profile projection, Relationship Preference stewardship, visibility, and correction.
2. **Personality:** owns questionnaire, personality, MBTI, and optional cultural reflection meaning, provenance, correction, and permitted contribution.
3. **Compatibility:** owns classified Compatibility Signals, interpretation, Compatibility Hypotheses, uncertainty, and revision.
4. **Matching:** owns bounded introduction opportunities, pacing, Match lifecycle, and presentation of permitted explanation.
5. **Conversation:** owns consent-bound communication context, Interaction occurrence, communication support, and bounded AI assistance.
6. **Relationship:** owns reciprocal Connection meaning, user-declared progression/closure, and purpose-classified Relationship Feedback.
7. **Safety:** owns block/report/protection meaning, restricted Safety evidence, restrictions, review/appeal concepts, and Safety direction to ordinary journeys.

These are conceptual business boundaries, not services, modules, tables, teams, or deployment units.

### Responsibility invariants

- No domain owns the User as a whole.
- Identity declarations and Personality interpretations remain distinct.
- Personality output is not automatically a Compatibility Signal.
- Compatibility produces hypotheses, not Match, consent, or Relationship decisions.
- Matching introduces opportunities; it cannot guarantee relationships or grant contact access.
- Reciprocal choice forms Connection; Match alone does not.
- Conversation activity cannot infer Relationship state.
- Relationship Feedback cannot become public rating or silently redefine another User.
- Safety may stop or restrict Matching/Connection/Conversation access; Safety evidence cannot become romantic Ranking.
- AI may assist several domains but owns no source truth, consent, guilt, or Relationship status.

### Supporting domains/capabilities

Account Access/Identity Assurance, Moderation Operations, Notification, Analytics/Experimentation, Payment/Subscription, Administration, Customer Support, and Legal/Privacy/Compliance support the core loop.

- Moderation executes Safety policy but does not define romantic or human-value meaning.
- Analytics measures approved product hypotheses but does not create domain truth or new evidence purposes.
- Payment cannot purchase compatibility, Safety outcomes, or access to another person.
- Notification cannot manufacture urgency or consent.

### Concept ownership

| Concept | Conceptual owner |
| --- | --- |
| User | No single domain; the person remains above domain representations |
| Identity, Profile | Identity |
| Relationship Preference | Identity, with permitted Matching consumption |
| Personality Profile | Personality |
| Compatibility Signal, Compatibility Hypothesis | Compatibility, while source meaning remains with origin domain |
| Match | Matching |
| Connection | Relationship |
| Conversation, Interaction occurrence | Conversation |
| Relationship, Relationship Feedback | Relationship |
| Report, Block, protection/restriction meaning | Safety |

### Information ownership classes

- **User-owned/user-authored:** declarations, Profile choices, preferences, answers, corrections, consent, and private reflections.
- **System-generated:** eligibility/readiness outcomes, Ranking, Match lifecycle, explanations, and recorded state transitions.
- **AI-generated:** summaries, tentative interpretations, explanation language, prompts, and safe-refusal/routing suggestions.
- **Safety-controlled:** reports, allegations, evidence, protections, restrictions, outcomes, appeals, and retention obligations.
- **Private interaction:** Conversation content, shared interaction context, and private user interpretation.

These classes must preserve provenance and purpose. AI output is not a verified fact; Safety data is not Compatibility evidence; private interaction is not general model input; visibility does not grant unrelated reuse.

### MVP boundary

MVP requires usable Identity, minimal optional Personality reflection, Compatibility hypotheses, bounded Matching, consent-bound Conversation, Connection/Relationship closure and feedback, and Safety block/report/protection capabilities.

Supporting launch capability must cover access/assurance, report handling, non-manipulative notification, authorized administration, privacy/compliance, and harm-aware analytics. Payment, broad cultural/personality catalogs, public social systems, passive personalization, and autonomous AI decisions can be deferred.

### Authority

Acceptance freezes conceptual responsibility and ownership boundaries only. It does not authorize database schemas, APIs, ORM models, backend/Flutter modules, services, microservices, storage, events, AI models, code, or migration.

## Recommended option

Adopt the seven-domain model because it keeps Identity, interpretation, evidence, introduction, communication, relationship meaning, and protection authority visibly separate. This is the lowest conceptual split that preserves the consent and evidence invariants established by ADR-001–003.

### Rejection conditions

Reject or revise this option if user research shows Personality has no independent product meaning, if Connection requires a materially distinct consent lifecycle beyond Relationship ownership, or if specialist Safety review requires a different product-policy boundary.

## Viable alternative

Use five conceptual domains:

- combine Personality into Identity/Self Understanding;
- combine Conversation into Relationship/Interaction;
- retain Compatibility, Matching, and Safety separately.

This reduces boundary count and may fit an extremely narrow MVP. It should be preferred if Personality is only a small optional reflection and Conversation has no distinct product rules beyond reciprocal relationship interaction.

### Alternative rejection conditions

Reject the five-domain alternative if personality/cultural provenance needs independent policy, if Conversation AI/privacy rules differ materially from Relationship feedback, or if combining them obscures consent and private-interaction ownership.

## Alternatives rejected

### Reuse 9.x entities or database ownership

Rejected because persistence history cannot define v10 business meaning.

### One unified User/Matching domain

Rejected because it centralizes incompatible authority over Identity, evidence, recommendation, communication, relationship, and Safety.

### AI as a primary domain owner

Rejected because AI is a governed capability and cannot own human meaning or decisions.

### Safety as analytics or a peripheral exception

Rejected because protection and user recourse are first-class lifecycle concerns with authority to restrict ordinary journeys.

## Consequences if accepted

### Positive

- Preserves precise language and consent transitions.
- Prevents a single domain from owning every aspect of the User.
- Keeps hypotheses, opportunities, reciprocal access, private interaction, relationship meaning, and Safety distinct.
- Creates a clear basis for later conceptual information lifecycle and context mapping.
- Prevents AI and analytics from becoming accidental domain authorities.

### Costs and constraints

- Cross-domain meaning must later be made explicit without duplicating ownership.
- Relationship Preference and Connection ownership need further validation.
- Safety and Moderation responsibilities require specialist policy review.
- Seven conceptual boundaries may be too granular for an ultra-thin MVP; conceptual separation still does not require separate technology.

## Unknowns requiring follow-up

- Whether Personality remains a core domain or folds into Identity.
- Whether Connection remains in Relationship or becomes a separate consent boundary.
- Exact context map and interaction contracts.
- Policy ownership for Match Readiness, consent renewal, feedback routing, and Safety restrictions.
- Data classification, derived-artifact provenance, shared interaction rights, deletion, retention, export, and reset.
- Required quality attributes and measurable scenarios.
- Scale, latency, availability, consistency, auditability, operations, cost, and compliance facts.
- Future architecture style, interfaces, stores, modules/services, and deployment remain undecided.

## Validation required before acceptance

- GPT L3 conceptual-domain review.
- Owner selection between the recommended seven-domain model, the viable five-domain alternative, or a requested revision.
- Specialist Safety/privacy review of Safety versus Moderation and information ownership boundaries.
- Consistency review after ADR-001–003 statuses are finalized.

## Recommended Phase 5

Conceptual Information Lifecycle and Quality Attribute Workshop.

Phase 5 should define information classes, provenance and purpose transitions, consent/revocation effects, lifecycle ownership, deletion/retention/export unknowns, trust-boundary flows, and measurable quality-attribute scenarios. It must remain conceptual and technology-neutral before database, API, backend, Flutter, microservice, or AI implementation design.
