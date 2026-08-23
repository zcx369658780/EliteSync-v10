# EliteSync 10.0 Information Lifecycle, Data Responsibility and Quality Attribute Workshop V0.1

Status: PROPOSED — AWAITING GPT L3 AND OWNER REVIEW

Date: 2026-08-24

## 0. Evidence and decision discipline

### Observed

- ADR-001–004 are all proposed and distinguish user declarations, interpretations, Compatibility Hypotheses, Match, Connection, Conversation, Relationship Feedback, and Safety evidence.
- Existing research is historical or screenshot-based and supplies no validated retention schedule, legal basis, fairness threshold, or operating target.
- ADR-003 prohibits cultural-system Ranking, private-message mining, public reputation scoring, and Safety evidence reuse as romantic value.
- ADR-004 proposes seven conceptual domains and a viable five-domain alternative; Owner has not selected either.

### Inferred

- Information responsibility must follow meaning, provenance, purpose, and rights rather than storage location or the domain that happens to process it.
- Derived information can be more sensitive than its inputs and cannot silently inherit unrestricted permission.
- Shared interaction, Safety evidence, and user-private reflection need different rights even when they refer to the same event.

### Decision

This workshop proposes conceptual information rules. It does not select databases, schemas, APIs, services, models, modules, event systems, or deployment mechanisms.

The governing refinement boundary is:

```text
Product Truth
→ Domain
→ Information
→ Architecture
→ Implementation
```

Each layer must preserve the accepted meaning and constraints of the layers above it. Information lifecycle analysis refines proposed Product Truth and Domain meaning; it does not authorize Architecture or Implementation, and no later technical convenience may silently redefine an upstream product, domain, consent, provenance, purpose, or lifecycle decision.

### Unknown

- Applicable mainland-China legal bases, mandatory retention, data localization, minors policy, cross-border processing, model-training obligations, and regulator-facing requirements need specialist review.
- Direct user research has not established comprehension, control expectations, or acceptable information trade-offs.

## 1. Information classification

Classification is cumulative: one item may be AI-generated and Safety-controlled, or user-authored and private interaction information. The stricter applicable boundary governs.

### 1.1 User-authored information

**Examples:** Identity declarations, Profile choices, Relationship Preference, relationship goals, questionnaire answers, corrections, consent choices, private reflection, and Relationship Feedback.

**Decision:** The User is the authority for what they declared and may inspect, correct, withdraw from permitted future use, change visibility, request export, reset relevant learning, and request deletion. Authorship does not make a claim objectively true and does not give one User authority over another person's information.

**Lifecycle:** Drafted → purpose explained → submitted → reviewed/corrected → used within permission → revised/withdrawn/expired → deleted or retained only under a disclosed exception.

### 1.2 System-generated information

**Examples:** readiness or eligibility outcomes, Ranking, Match lifecycle, state transitions, explanation assembly, consent/status records, and pacing decisions.

**Decision:** Every material system-generated item must retain its generating purpose, input classes, governing rule or policy version, time relevance, responsible domain, and contest route. It is a system outcome, not a user-authored fact or human relationship truth.

**Lifecycle:** Generated for a named purpose → presented or applied → reviewable/contestable where consequential → refreshed, superseded, expired, or retired.

### 1.3 AI-generated information

**Examples:** Personality summaries, tentative interpretations, Compatibility explanation language, conversation suggestions, reflection prompts, and safe-refusal/routing suggestions.

**Decision:** AI output must be visibly labeled `AI-generated`, linked to its permitted source context, express material uncertainty, and permit correction, dismissal, or non-use. It is neither a User fact nor verified truth. Fluency does not raise its provenance or authority.

**Lifecycle:** Requested or policy-permitted → generated from allowed context → labeled and reviewed by the User or authorized human where required → accepted only as bounded assistance, corrected/dismissed → expired or regenerated when its basis changes.

### 1.4 Safety-controlled information

**Examples:** Reports, allegations, evidence, blocks, immediate protections, restrictions, case state, findings, outcomes, appeals, and retention obligations.

**Decision:** Safety controls purpose and access; Moderation Operations may execute reviewed policy. Allegation, evidence, interim action, verified finding, and appeal outcome must remain distinct. Safety information may protect or restrict access but may not become Compatibility evidence, romantic Ranking, a public reputation score, or engagement optimization input.

**Lifecycle:** Concern raised → immediate protection where appropriate → evidence preserved under restricted access → reviewed → outcome communicated within policy → appealed where available → retained or deleted under an approved Safety/legal rule.

### 1.5 Private Interaction information

**Examples:** Private Conversation content, shared interaction context, private closure reasons, and private Relationship Feedback.

**Decision:** Private Interaction information is limited to delivering the interaction, user-requested assistance, user-owned reflection, and specifically authorized Safety handling. It is not default input to general Ranking, cross-user explanations, analytics reuse, or general model training. Visibility between participants does not authorize unrelated platform reuse.

**Lifecycle:** Created within a valid Connection/context → available only to entitled participants and bounded operations → optionally used for an explicitly requested purpose → closed/restricted → retained or deleted according to an approved shared-data policy.

## 2. Provenance model

Provenance is not a ladder in which later stages become more truthful. It records how an item came to exist and which claims are justified.

| Provenance | Meaning and confidence boundary | Modifiability | Use restriction |
| --- | --- | --- | --- |
| User declared | What a User chose to state; authoritative as a declaration, not independently verified fact | User may correct, replace, withdraw, or change visibility/use | Only the explained purpose; never silently reclassified as verified |
| System observed | A bounded product event or state recorded by the system; context may be incomplete | Source event is not rewritten, but interpretation and contested status can be appended/corrected | Observation does not prove motive, affection, compatibility, or misconduct |
| Model interpreted | A probabilistic or rule-based interpretation of allowed inputs | Recomputable, correctable, rejectable, and version-sensitive | Must expose uncertainty and never masquerade as declaration or verified truth |
| AI generated | Generated language or suggestion based on permitted context | Dismissible, regenerable, correctable; material accepted corrections preserve User authorship separately | Must be labeled; cannot determine consent, guilt, Relationship state, or outcome |
| Human verified | A defined authorized reviewer checked a defined claim under a known standard | May be challenged, corrected, appealed, expire, or be superseded | Verification applies only to the checked claim and purpose; it is not universal truth |

### Decision

- Every consequential derived item preserves source provenance, purpose, time relevance, responsible actor/capability, uncertainty, and policy/model version where applicable.
- A provenance transition requires an explicit act and authority. Model interpretation does not become Human verified automatically; User acceptance of wording does not verify another person.
- Conflicting sources remain visible or are resolved through a defined review path; they are not hidden in one score.
- Derived artifacts never overwrite source records or silently expand the source's permitted use.

## 3. Purpose boundary

### Decision

Before information is used, the purpose must be named, understandable, necessary, and compatible with the original collection context. A new purpose requires separate review and, where applicable, new consent; convenience, availability, or technical accessibility is insufficient.

| Information | Permitted example | Not automatically permitted |
| --- | --- | --- |
| User interest | Profile context or user-requested conversation suggestion | Personality inference, sensitive-trait inference, or unrelated advertising |
| Relationship Preference | Match Readiness and approved Compatibility questions | Public labeling, permanent identity, or entitlement filtering outside the explained scope |
| Compatibility explanation | Help a User understand why exploration may be worthwhile | Guarantee an outcome, declare another person's inner state, or Safety-clear a person |
| Private Conversation | Deliver communication or provide explicitly requested in-context assistance | General Ranking, general model training, cross-user profiling, or relationship-status inference |
| Relationship Feedback | Improve the author's reflection, pacing, or explicitly allowed future hypotheses | Public rating, universal judgment of the other User, or undisclosed cross-user penalty |
| Safety report | Protection, reviewed investigation, appeal, and required compliance | Romantic desirability, Compatibility, public reputation, or growth optimization |

### Purpose-creep prevention rules

- Collection, visibility, recommendation use, AI assistance, analytics, model improvement, and Safety handling are separate purposes.
- One User's consent cannot authorize use of another User's private information.
- An approved output purpose does not authorize retaining every input indefinitely.
- Analytics may consume only approved, minimized observations and cannot create new domain truth or Ranking signals by convenience.
- When purpose compatibility is uncertain, processing stops pending Owner and specialist review.

## 4. Consent and user-rights lifecycle

### Decision

Consent is specific, informed, affirmative where required, time-relevant, visible, and revocable for future processing. Account creation, Profile visibility, Match participation, Connection, Conversation, AI assistance, cultural reflection, feedback learning, analytics, and model improvement must not be collapsed into one permission.

| User action | Conceptual effect |
| --- | --- |
| Consent | Enables only the named purpose and information class; records what was understood and chosen |
| Correction | Updates the authoritative declaration or adds a challenge to a derived/system item; dependent active outputs must be reviewed or refreshed |
| Revocation | Stops new processing for that consented purpose and prevents new dependent outputs; existing outputs are withdrawn, invalidated, or handled under an approved exception |
| Profile withdrawal | Stops future visibility and new use of withdrawn Profile information; it does not reveal private reasons or alter another User's independent records |
| Recommendation opt-out/pause | Stops new Match generation/presentation and related learning for that purpose while preserving unrelated identity controls |
| Reset | Retires the User's recommendation/reflection learning state and starts again from explicitly retained inputs; it is not account deletion or deletion of Safety/shared records |
| Export request | Provides understandable information about the User and relevant provenance/purpose, subject to other-person, Safety, and legal boundaries |
| Deletion request | Removes or de-identifies eligible information and dependent artifacts; exceptions must be narrow, disclosed, access-restricted, and time-bounded where law/policy permits |

### Inferred

Revocation cannot undo a Conversation already read by another participant or erase another person's own authored reflection. It can stop future platform use and access under policy. This distinction must be made understandable rather than promising impossible retroactive erasure.

### Unknown

- Exact deletion propagation, backup treatment, export format/scope, response times, consent age/renewal, withdrawal UX, and lawful or Safety retention exceptions.
- Rights when two Users share Conversation content or mutually declare a Relationship state.

## 5. Relationship Feedback lifecycle

### Decision

Relationship Feedback is classified at creation, because different purposes have different rights:

1. **Private reflection:** visible to its author; no cross-user scoring.
2. **Identity or Preference correction:** may update only the author's self-description or future choices.
3. **Compatibility learning:** may revise the author's pair-specific or future hypothesis only under explicit purpose permission.
4. **Product-usefulness feedback:** evaluates explanation or experience, not the other person's worth.
5. **Safety concern:** leaves the ordinary feedback path and enters restricted Safety handling.

Lifecycle:

```text
User authors feedback
→ purpose is selected and explained
→ provenance and people implicated are recorded conceptually
→ feedback remains private or routes only to an allowed consumer
→ User may correct or withdraw future use where allowed
→ feedback expires, is deleted, or is retained under a disclosed exception
```

- A rejection, silence, closure, block, allegation, and reviewed Safety outcome remain different information.
- Feedback about another person is contextual and never becomes a public personality, compatibility, virtue, or desirability rating.
- Withdrawal stops future optional learning; it does not silently alter Safety evidence or another User's independently authored record.

### Unknown

- Minimum retention needed to support correction, abuse prevention, appeals, product research, and dispute handling.
- Whether any privacy-safe aggregate can measure meaningful interaction without incentivizing surveillance or re-identification.

## 6. Conceptual information flow boundary

```text
User declaration and consent
  ↓ informed, purpose-specific submission
Identity / Relationship Preference
  ├─ optional explicit consent → Personality Reflection
  └─ permitted classification → Compatibility Signal
                                   ↓ explainable interpretation
                            Compatibility Hypothesis
                                   ↓ bounded presentation
                            Match Explanation
                                   ↓ independent reciprocal consent
                               Connection
                                   ↓ purpose-bound access
                           Human Conversation / Interaction
                                   ↓ explicit user authorship
                         Classified Relationship Feedback
                                   ↓ only permitted updates
              Identity / Preference / Hypothesis / Matching pace

Safety concern ── separate restricted route ──→ protection / review / appeal
Safety direction ── may constrain ──→ Match / Connection / Conversation access
Safety evidence ── must not flow ──→ romantic Ranking or public reputation
```

### Transformations requiring user knowledge or choice

- Identity/Profile visibility and recommendation participation.
- Personality/cultural reflection and any contribution beyond private reflection.
- Creation and presentation of a Compatibility Hypothesis from declared signals.
- Reciprocal Connection and continued Conversation access.
- AI processing of private context or generation of user-facing assistance.
- Routing Relationship Feedback into future personalization or product research.
- Any material new purpose or new sensitive inference.

### Transformations that cannot happen automatically

- Personality or cultural reflection becoming Ranking evidence.
- Match becoming Connection, Conversation, or Relationship.
- Conversation activity becoming affection, compatibility, or Relationship status.
- AI output becoming User fact, Human verified evidence, consent, guilt, or Safety outcome.
- Relationship Feedback becoming another User's identity or public reputation.
- Safety evidence becoming Compatibility or romantic Ranking.
- Visibility or prior consent becoming permission for unrelated reuse.

## 7. Quality attributes

These are product-level obligations and review questions, not technical solutions or accepted numeric targets.

| Attribute | Proposed quality obligation | Candidate evidence for later validation | Unknown target |
| --- | --- | --- | --- |
| Privacy | Collect and expose only information necessary for an understood purpose; keep private, shared, derived, and Safety information separated | Users can identify purpose/visibility; prohibited reuse tests find no leakage | Retention periods, privacy-risk thresholds, deletion/export timing |
| Explainability | A User can understand why a recommendation or interpretation exists, its sources, uncertainty, and available control | Comprehension testing and successful challenge/correction scenarios | Required comprehension rate and explanation depth |
| Reliability | Consent, pause, block, closure, correction, and lifecycle rules behave consistently, including during partial failure | Scenario tests show no new access/use after effective restriction | Availability, latency, recovery, and consistency targets |
| Auditability | Consequential generation, use, change, restriction, and review can be reconstructed with provenance and policy context | Authorized review can explain who/what/why/when without exposing unrelated content | Audit coverage, access, retention, and reviewer standards |
| Safety | Immediate protective controls take precedence over matching and engagement; reports follow restricted, reviewable paths | Harm scenarios confirm separation, escalation, appeal, and no romantic reuse | Severity taxonomy, response targets, human-review and external-routing thresholds |
| Fairness | Recommendation and restriction do not create unjustified disadvantage through direct signals, proxies, missingness, or feedback loops | Predefined group/harm analysis and stop conditions before expansion | Relevant groups, metrics, minimum evidence, acceptable disparity |
| User Control | Users can inspect, correct, pause, revoke, reset, export-request, delete-request, close, block, and contest without coercion | End-to-end control scenarios and user comprehension research | Completion times, exceptions, and remedies |

### Decision

Privacy, Safety, and User Control are constraints on product value, not optional optimizations. Reliability includes correct denial and cessation, not only successful delivery. Auditability must not become indiscriminate surveillance or unlimited retention. Fairness evaluation must be purpose-specific and cannot be reduced to one global score.

## 8. MVP information lifecycle scope

### Decision — MVP must support

- Minimum self-authored Identity, Profile visibility, Relationship Preference, consent, correction, pause, and withdrawal.
- Minimal optional Personality reflection with AI provenance, correction, dismissal, and expiry; cultural reflection may be deferred.
- An approved allowlist of explicit, relevant Compatibility Signals with source, purpose, uncertainty, and correction.
- Explainable Compatibility Hypothesis and Match Explanation with rejection, expiry, and reset paths.
- Reciprocal Connection and basic private Conversation with closure, block, report, and restricted Safety routing.
- Purpose-classified Relationship Feedback with private-by-default handling and correction/withdrawal controls.
- User requests for access/export, reset, and deletion, with clearly disclosed unresolved/approved exceptions before launch.
- Sufficient provenance and audit evidence for consent, consequential derived outputs, Safety restrictions, and user-rights handling.

### Decision — defer or exclude

- Passive behavioral compatibility scoring, private-message mining, sensitive-trait inference, cultural-system Ranking, and general model training on private interaction.
- Public ratings/reputation, unified feedback scores, permanent personality labels, deterministic Compatibility scores, and relationship-status inference.
- Broad cultural/personality catalogs, advanced cross-context personalization, autonomous AI decisions, and high-risk automated Safety adjudication.
- Indefinite collection or retention merely because information may later be useful.

## 9. Unknown and assumption register

### Lifecycle ambiguity

- Exact expiry and refresh conditions for Identity, Preference, Personality Profile, Compatibility Signals/Hypotheses, Match explanations, consent, and feedback.
- Propagation rules when a source is corrected, withdrawn, expired, or deleted.
- Rights and authority over shared Conversation and mutually declared Relationship information.
- Distinction between reversible reset, logical withdrawal, deletion, de-identification, and legally required preservation.

### Privacy and compliance

- Applicable legal bases, sensitive/personal information classification, consent form, age and identity assurance, localization, cross-border, automated-decision, generative-AI, moderation, and incident obligations.
- Exact export, deletion, appeal, notification, and retention policies.
- Whether model improvement is permitted at all for each information class and what independent safeguards would be required.

### Quality and product evidence

- User comprehension of provenance, purpose, uncertainty, and control.
- Fairness groups, harms, metrics, baselines, thresholds, and experimental stop conditions.
- Privacy-safe outcome measurement and minimum audit evidence.
- Reliability, availability, latency, recovery, operational, and cost scenarios.

### Future architecture — intentionally unresolved

- Selected domain option and context map.
- Logical data model, interfaces, schemas, stores, events, access-control mechanisms, encryption, deletion mechanisms, AI/model choices, and deployment topology.
- Organizational ownership, accountable reviewers, and operational response model.

## 10. Review and decision stop

This proposal freezes no implementation. GPT L3 and Owner must accept, revise, or reject the classification, provenance, purpose, consent, feedback, flow, quality-attribute, and MVP boundaries. Specialist privacy/legal, Safety, fairness, and user-research review is required before operational policy or technical architecture.

Recommended Phase 6: Quality Attribute Scenarios and Conceptual Context Map Workshop. It should turn accepted attributes into measurable, technology-neutral scenarios and clarify cross-domain information contracts and failure responsibilities. It must not design databases, APIs, backend/Flutter modules, infrastructure, or AI implementation.
