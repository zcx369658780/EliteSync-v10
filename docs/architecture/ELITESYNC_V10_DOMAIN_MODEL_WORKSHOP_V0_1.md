# EliteSync 10.0 Domain Model and Responsibility Boundary Workshop V0.1

Status: PROPOSED — AWAITING GPT L3 AND OWNER REVIEW

Date: 2026-08-24

Scope: Conceptual domain model only. No database, API, ORM, backend module, Flutter, microservice, or code design is authorized.

## 0. Evidence and decision discipline

### Observed

- ADR-001 defines EliteSync as decision support for deliberate relational attention, not high-volume candidate selection.
- ADR-002 distinguishes Identity, Profile, Compatibility Signal, Compatibility Hypothesis, Match, Connection, Conversation, Interaction, Relationship, and Relationship Feedback.
- ADR-003 separates user-provided, personality, cultural, behavioral, interaction, sensitive, safety, and forbidden evidence uses.
- Competitor research exposes visible identity, reflection, matching, conversation, and social surfaces but does not reveal valid internal domain boundaries.

### Inferred

- Consent and meaning change across the journey, so one domain cannot safely own identity, ranking, conversation, relationship state, and safety evidence together.
- AI explanation is a constrained capability used within multiple domains; making it the owner of human meaning would violate ADR-001–003.
- Safety requires core product authority even when moderation operations are supporting capabilities.

### Decision

The proposed conceptual model contains seven core domains with explicit responsibilities and ownership boundaries. “Domain” here means a business meaning and policy boundary, not a service, module, table, or team.

### Unknown

- ADR-001–003 remain proposed pending GPT L3 and Owner acceptance.
- Operational ownership, organization structure, architecture style, deployment topology, service boundaries, storage, interfaces, scale, SLOs, compliance interpretation, and implementation constraints remain `UNKNOWN` or out of scope.

## 1. Core domain identification

### 1.1 Identity Domain

**Purpose:** Represent how a User deliberately presents and controls their relationship-context identity.

**Responsible for:**

- self-authored Identity and its evolution;
- purpose-specific Profile projections;
- self-description, relationship-context visibility, and correction;
- distinguishing user declarations from interpretations;
- user control over what may be presented to another person;
- relationship intent and identity context required by other domains, without deciding compatibility.

**Not responsible for:**

- authentication technology or account security implementation;
- diagnosing personality;
- producing Compatibility Hypotheses or Matches;
- granting contact consent;
- inferring Relationship status;
- safety investigation or punishment;
- deciding that a User is “complete” through maximal data collection.

**Boundary statement:** A Profile is a controlled projection of Identity, never the whole User and never automatic consent to matching or contact.

### 1.2 Personality Domain

**Purpose:** Support correctable self-understanding through questionnaires, personality vocabularies, and optional cultural reflection.

**Responsible for:**

- questionnaire meaning and reflection purpose;
- MBTI and personality reflection as non-diagnostic language;
- optional astrology, Bazi, Ziwei, and related cultural reflection;
- provenance and epistemic labeling of reflections;
- user acceptance, correction, dismissal, and permitted-use choice;
- supplying only permitted, clearly classified reflections to Compatibility.

**Not responsible for:**

- clinical or psychological diagnosis;
- fixed identity, destiny, or scientific relationship prediction;
- matching weights, candidate ordering, or relationship outcomes;
- deciding Profile visibility without Identity consent;
- using cultural reflection for MVP Ranking;
- evaluating safety or moral character.

**Boundary statement:** Personality and cultural outputs are reflections owned through user control, not facts that automatically become Compatibility Signals.

### 1.3 Compatibility Domain

**Purpose:** Form explainable, revisable propositions about dimensions worth exploring between two Users.

**Responsible for:**

- Compatibility Signal meaning, provenance, purpose, uncertainty, sensitivity, and permitted use;
- interpretation of permitted signals;
- Compatibility Hypothesis lifecycle;
- distinguishing alignment, tension, conflict, and unknown evidence;
- explanation content supplied to Matching;
- feedback-based hypothesis revision while preserving provenance;
- enforcing evidence-use prohibitions from ADR-003.

**Not responsible for:**

- predicting relationship success or destiny;
- assigning a scalar truth or human-value score;
- selecting or delivering Matches;
- granting Connection or Conversation access;
- reading private Conversation as general matching evidence;
- making consent, safety, guilt, or Relationship-state decisions.

**Boundary statement:** Compatibility owns a hypothesis and its evidence contract; it does not own the human relationship.

### 1.4 Matching Domain

**Purpose:** Allocate bounded relational attention by offering explainable candidate-introduction opportunities.

**Responsible for:**

- Match eligibility and readiness as defined by accepted product policy;
- bounded candidate consideration and pacing;
- ordering eligible opportunities using only approved evidence purposes;
- Match creation, presentation, expiry, pause, pass, and interest lifecycle;
- presenting an authorized Compatibility explanation without exposing restricted evidence;
- recognizing reciprocal interest and requesting creation of a Connection boundary.

**Not responsible for:**

- generating personality or cultural interpretations;
- guaranteeing compatibility or relationships;
- ranking human worth;
- overriding Identity visibility, consent, or Safety restrictions;
- opening Conversation before reciprocal Connection;
- determining Relationship state;
- converting rejection or reports into desirability scores.

**Boundary statement:** Matching owns an introduction opportunity, not mutual access, human compatibility truth, or relationship decisions.

### 1.5 Conversation Domain

**Purpose:** Provide a consent-based context in which connected Users communicate and create real human Interaction.

**Responsible for:**

- Conversation availability within a valid Connection;
- participation and closure boundaries;
- Interaction context and user-visible communication support;
- optional AI-assisted explanation, reflection, and conversation prompts within ADR-001/003;
- respecting block, closure, privacy, and Safety instructions;
- distinguishing communication activity from user-reported meaning.

**Not responsible for:**

- creating Connections or Relationship status;
- interpreting message volume as compatibility or affection;
- undisclosed AI impersonation or autonomous messaging;
- mining private content for general Ranking;
- diagnosing users or inferring private thoughts;
- adjudicating reports or guilt.

**Boundary statement:** Conversation supports human exchange. It does not own what the exchange means to the people involved.

### 1.6 Relationship Domain

**Purpose:** Represent user-owned progression, pause, closure, and learning after reciprocal Connection.

**Responsible for:**

- Connection as reciprocal, revocable consent to explore;
- user-declared Relationship progression and state meaning;
- respectful closure and transition away from matching;
- Relationship Feedback and its purpose classification;
- distinguishing private reflection, mutual fact, preference update, and product feedback;
- sending permitted feedback updates to Identity, Compatibility, or Matching without redefining another User.

**Not responsible for:**

- inferring Relationship from activity;
- guaranteeing mutuality, exclusivity, or success;
- owning Conversation content;
- publishing personal ratings or hidden reputation;
- making safety findings;
- forcing continued Connection or disclosure of private closure reasons.

**Boundary statement:** Users define the Relationship; the domain supports states and learning without claiming authority over human meaning.

### 1.7 Safety Domain

**Purpose:** Protect Users and relationship boundaries throughout discovery, Match, Connection, Conversation, and closure.

**Responsible for:**

- block, report, immediate separation, and protective restriction meaning;
- safety concern classification for harassment, fraud, impersonation, abuse, and related risks;
- separation of allegation, evidence, immediate action, review, outcome, appeal, and retention;
- safety-policy direction to Matching and Conversation;
- restricted safety evidence purpose and access semantics;
- preventing safety data from becoming romantic Ranking or public reputation;
- defining when human or qualified external review is required, subject to later policy.

**Not responsible for:**

- romantic compatibility or desirability;
- using reports as ordinary preference feedback;
- automatic guilt, emergency, legal, clinical, or abuse verdicts;
- AI-only adjudication;
- replacing emergency, law-enforcement, legal, medical, or crisis services;
- deciding ordinary Relationship meaning.

**Boundary statement:** Safety may constrain other domains to protect Users, but it cannot repurpose protected evidence into relationship judgment.

## 2. Supporting domains and capabilities

Supporting does not mean optional, low-risk, or technically separate. It means the concern enables the core Slow Dating value loop without owning its central relationship meaning.

### Account Access and Identity Assurance

Supports eligibility and trustworthy access. It may provide assurance claims with defined strength but does not own Identity meaning or Compatibility.

### Moderation Operations

Executes reviewed Safety policy, case handling, evidence review, communication, and appeals. Safety owns the product meaning and restrictions; Moderation does not become a relationship-rating domain.

### Notification

Delivers user-controlled reminders and state-change notices. It does not create urgency, infer consent, or own lifecycle states.

### Analytics and Experimentation

Measures product hypotheses within purpose, privacy, and safety boundaries. It consumes approved, minimized observations and does not redefine domain truth or create new Ranking signals by convenience.

### Payment and Subscription

Handles value exchange for later approved offerings. It does not buy relational priority, compatibility, safety outcomes, or access to another person.

### Administration

Supports authorized operational controls and policy management. It does not replace Owner product authority or silently override domain invariants.

### Customer Support

Helps Users understand and resolve product issues. It does not adjudicate clinical, legal, or relationship truth.

### Legal, Privacy, and Compliance

Provides specialist policy constraints, review, and obligations. It constrains all domains but does not itself define the product's relational value loop.

### AI Capability

AI is a governed capability used by Personality, Compatibility, Conversation, and potentially Safety triage. It is not a super-domain.

- **Responsible for:** bounded summarization, explanation, question suggestion, reflection support, uncertainty disclosure, and safe refusal.
- **Not responsible for:** source-of-truth ownership, consent, Relationship state, guilt, safety verdicts, private-thought inference, emotional manipulation, or human decisions.

## 3. Responsibility boundary matrix

| Domain | Responsible for | Not responsible for |
| --- | --- | --- |
| Identity | Self-authored relationship identity, Profile projection, visibility and correction | Personality diagnosis, compatibility, matching, contact consent, safety adjudication |
| Personality | Questionnaire and optional personality/cultural reflection with provenance and user control | Diagnosis, destiny, Ranking, relationship prediction, safety judgment |
| Compatibility | Permitted signals, interpretation, hypothesis, uncertainty, revision | Match delivery, human worth, consent, private-message mining, Relationship decision |
| Matching | Bounded introduction opportunities, pacing, Match lifecycle, explanation presentation | Guarantee, Connection consent, Conversation, Relationship status, desirability scoring |
| Conversation | Consent-bound communication context, Interaction support, bounded AI assistance | Connection creation, relationship inference, autonomous messaging, report adjudication |
| Relationship | Reciprocal Connection meaning, user-declared progression, closure, classified feedback | Activity-based relationship inference, public ratings, Safety findings |
| Safety | Block/report/protection meaning, restrictions, restricted safety evidence, review/appeal concepts | Compatibility, desirability, automatic guilt, relationship or clinical judgment |

### Cross-domain invariants

- No domain owns the User as a whole.
- Identity declarations and Personality interpretations remain distinguishable.
- A reflection does not become a Compatibility Signal without permitted-use classification.
- Compatibility supplies hypotheses; Matching decides only whether to offer an eligible opportunity.
- Match does not grant access; reciprocal choice creates Connection.
- Conversation activity cannot create Relationship state.
- Relationship Feedback cannot silently redefine another User.
- Safety restrictions may stop Matching or Conversation, but safety evidence cannot improve or reduce romantic Ranking.
- AI output never becomes authority merely because it is fluent or automated.

## 4. Conceptual entities and lifecycle

These are conceptual business objects, not database entities or ORM models.

| Concept | Meaning | Lifecycle | Owner Domain | Boundary / What it is NOT |
| --- | --- | --- | --- | --- |
| User | A person exercising agency and rights in EliteSync | Arrives anonymously; may form identity, participate, pause, withdraw, or leave | No single domain; Identity is steward of relationship-context representation | Not a record, candidate item, score, or engagement target |
| Identity | Evolving, self-authored relationship context | Drafted → reviewed/corrected → active/purpose-limited → paused/updated/deletion-requested | Identity | Not authentication, Profile, personality type, or permanent essence |
| Profile | Purpose-specific visible projection of selected Identity information | Prepared → visibility consented → presented → revised/hidden/withdrawn | Identity | Not the whole User or consent to matching/contact |
| Personality Profile | Revisable personality/cultural reflection with provenance | Requested/opted-in → interpreted → reviewed/corrected/dismissed → optionally shared for permitted purpose → expired/revisited | Personality | Not diagnosis, destiny, fixed identity, or automatic signal |
| Relationship Preference | Current intent, pace, priorities, acceptable differences, and boundaries | Declared → clarified → used for permitted readiness/matching → revised/paused/reset | Identity, with Matching as permitted consumer | Not entitlement, permanent rule, or judgment of others |
| Compatibility Signal | Bounded evidence relevant to a named compatibility dimension | Proposed → classified/consented → active for permitted use → corrected/expired/revoked/restricted | Compatibility; source meaning remains with originating domain | Not compatibility, proof, unrestricted feature, or hidden sensitive inference |
| Compatibility Hypothesis | Explainable proposition worth reciprocal exploration | Formed → explained → accepted/rejected as decision support → tested by interaction → confirmed/contradicted/complicated/unknown → revised/retired | Compatibility | Not score, truth, guarantee, safety clearance, or destiny |
| Match | Bounded introduction opportunity | Eligible/formed → presented → considered → passed/paused/expired/interested → reciprocal interest or closed | Matching | Not score, Connection, Conversation, Relationship, or obligation |
| Connection | Reciprocal, revocable consent to explore communication | Proposed by reciprocal interest → active → paused/ended/blocked/restricted → closed | Relationship | Not permanent consent, exclusivity, Conversation content, or Relationship commitment |
| Conversation | Consent-based communication context associated with Connection | Available → active/paused → closed/restricted by Connection or Safety state | Conversation | Not proof of interest, compatibility, Relationship, or AI authority |
| Interaction | Concrete communication/action through which Users may learn | Occurs within context → privately interpreted → may generate permitted feedback → remains contextual | Conversation for occurrence; Relationship for user-reported meaning | Not automatically positive engagement or objective outcome |
| Relationship | Human-defined, mutually understood ongoing relational state | User-declared exploration/progression → pause/change/closure; exact MVP vocabulary UNKNOWN | Relationship | Not inferred from activity, Match, Connection, or time elapsed |
| Relationship Feedback | Contextual account of what the User learned and what should change | Authored → purpose-classified → corrected/withdrawn where allowed → routed to permitted consumer or retained privately | Relationship | Not public rating, universal truth, Safety report, or reputation score |

## 5. Conceptual domain relationships

```text
User
  ↓ self-authors
Identity
  ├─ projects → Profile
  ├─ expresses → Relationship Preference
  └─ opts into → Personality Profile

Identity / Personality / explicit choices
  ↓ only after purpose and evidence classification
Compatibility Signal
  ↓ interpreted by Compatibility
Compatibility Hypothesis
  ↓ supplied as decision support
Match
  ↓ independent reciprocal choice
Connection
  ↓ permits
Conversation
  ↓ contains contextual
Interaction
  ↓ may produce user-owned
Relationship Feedback
  ↓ may revise permitted
Identity / Preference / Compatibility Hypothesis / Matching pace

Connection
  ↓ may support user-declared
Relationship

Safety
  ── constrains → Matching / Connection / Conversation / Relationship access
  ── protects but does not rank → User
```

### Relationship rules

- Identity supplies declarations, not candidate-selection decisions.
- Personality supplies reflections, not diagnoses or deterministic signals.
- Compatibility accepts only classified signals and returns hypotheses, not decisions.
- Matching consumes eligibility and hypothesis explanations, not restricted raw evidence.
- Relationship owns Connection meaning; Conversation consumes a valid Connection boundary.
- Conversation supplies contextual Interaction occurrence, not relationship interpretation.
- Relationship Feedback routes by purpose; it is never broadcast to every domain.
- Safety instructions may override ordinary access, but do not change romantic compatibility.

## 6. Information ownership and control boundary

“Ownership” here means authority over meaning, allowed purpose, correction, and lifecycle. It does not imply database ownership.

### User-owned / user-authored

**Includes:** Identity declarations, Profile visibility choices, Relationship Preference, questionnaire answers, consent choices, corrections, and private reflections.

**Authority:** The User can inspect, correct, change visibility/use, export-request, reset relevant learning, and deletion-request subject to transparent Safety/legal limits.

**Must not mix with:** System interpretations presented as user facts; other-person data; Safety outcomes; public reputation.

### System-generated

**Includes:** eligibility/readiness determinations under policy, Ranking/order, Match state, explanation assembly, lifecycle state transitions, and consent/status records.

**Authority:** The responsible domain must expose purpose, source dependency, contest/correction route, and expiry/review where meaningful.

**Must not mix with:** User-authored truth, AI output without provenance, or human Relationship meaning.

### AI-generated

**Includes:** reflection summaries, tentative interpretations, Compatibility explanation language, conversation prompts, and safe-refusal/routing suggestions.

**Authority:** The source domain owns whether AI output may be used; AI does not own the object it describes.

**Must not mix with:** Verified facts, user declarations, clinical/safety verdicts, consent, or Relationship state. AI provenance must remain visible.

### Safety-controlled

**Includes:** reports, allegations, evidence, immediate protections, restrictions, investigation state, outcomes, appeals, and retention obligations.

**Authority:** Safety controls purpose and access; Moderation Operations executes reviewed policy.

**Must not mix with:** romantic Ranking, Compatibility Signals, public ratings, ordinary rejection reasons, or engagement optimization.

### Private interaction

**Includes:** Conversation content, shared interaction context, and each User's private interpretation.

**Authority:** Shared interaction implicates both Users; each User owns their private reflection, while neither receives unrestricted reuse rights over the other's data.

**Must not mix with:** general model training, public Profile, compatibility scoring, cross-user explanation, or Safety evidence absent a specific reviewed authority.

### Ownership conflict rules

- Visibility does not transfer ownership or authorize unrelated reuse.
- One User's consent cannot authorize the other User's private data.
- A derived artifact retains links to its permitted source meaning and cannot overwrite the source.
- Resetting recommendation does not imply deletion of other-person or Safety-controlled records.
- Deletion requests, legal/Safety retention, shared-data rights, and export scope remain policy unknowns, not implementation assumptions.

## 7. MVP core versus supporting decision

### MVP must possess these core domain capabilities

- **Identity:** minimum self-authored Identity, Profile control, Relationship Preference, correction, pause, and purpose consent.
- **Personality:** minimal optional questionnaire/personality reflection with correction; cultural reflection may be deferred unless it can meet ADR-003 boundaries.
- **Compatibility:** approved signal classification and explainable Compatibility Hypothesis with uncertainty.
- **Matching:** Match Readiness, bounded opportunities, pacing, explanation, pass/interest/expiry, and reciprocal transition.
- **Conversation:** consent-bound basic communication, closure, Safety enforcement, and optional bounded AI prompts.
- **Relationship:** Connection, user-controlled progression/closure, and purpose-classified feedback.
- **Safety:** block, report entry, immediate separation, basic restriction, and explicit route to reviewed operational handling.

### Supporting capabilities required at minimum

- Account Access/Identity Assurance sufficient for approved eligibility policy.
- Moderation Operations sufficient to handle MVP report paths; report collection without handling is not acceptable.
- Notification limited to non-manipulative lifecycle communication.
- Administration limited to authorized policy/case operations.
- Privacy/Compliance review and user-rights handling sufficient for approved launch scope.
- Minimal Analytics capable of evaluating product value and harms without repurposing private/sensitive evidence.

### Can be deferred

- Payment/subscription breadth;
- public content, followers, live rooms, parties, gifts, virtual currency, and expert marketplaces;
- broad personality/cultural catalogs;
- advanced passive personalization;
- complex relationship structures outside the approved MVP scope;
- autonomous AI decisions, general Conversation mining, and high-risk automated Safety judgments;
- extensive customer-support, growth, and administration feature breadth beyond launch safety/rights obligations.

Deferral does not authorize deletion of historical assets; it excludes them from current product scope.

## 8. Unknown and assumption register

### Domain ambiguity

- Whether Relationship Preference belongs entirely to Identity or warrants a future separate Readiness/Preference domain.
- Whether Connection ownership should remain in Relationship or become a separate consent-focused domain at larger scale.
- Whether Personality is truly core to MVP differentiation or a replaceable supporting reflection capability.
- Exact boundary between Safety product policy and Moderation operational execution.
- Whether Identity Assurance is supporting Identity or a distinct trust domain.

### Product experiments

- Minimum Identity and Preference required for first value and Match Readiness.
- Whether users understand Profile versus Identity and Match versus Connection.
- Which hypothesis explanations improve decisions without creating false certainty.
- Whether personality reflection adds value beyond explicit preferences.
- Whether cultural reflection can be offered without bias, disclosure conflict, or prediction framing.
- Privacy-safe definition and measurement of meaningful Interaction.
- Effects of bounded Match cadence, expiry, pause, and reset.

### Future architecture questions — explicitly unresolved

- Context mapping, domain interaction contracts, policy-decision placement, and failure semantics.
- Data classification, lifecycle, provenance, retention, deletion, export, and shared-data rights.
- Quality attributes, load, latency, availability, consistency, auditability, operations, cost, and compliance targets.
- Architecture style, module/service boundaries, interfaces, storage, eventing, AI/model selection, and deployment topology.
- Organizational ownership and review responsibilities.

## 9. Review and decision stop

This workshop proposes conceptual boundaries and a recommended seven-domain model. A viable consolidation alternative is described in ADR-004. GPT L3 and Owner must decide whether to accept, revise, or reject the domain split before any conceptual information lifecycle or technical architecture work proceeds.

