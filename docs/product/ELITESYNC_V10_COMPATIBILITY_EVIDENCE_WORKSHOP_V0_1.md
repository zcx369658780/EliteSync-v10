# EliteSync 10.0 Compatibility Evidence, Trust and Safety Workshop V0.1

Status: PROPOSED — AWAITING GPT L3 AND OWNER REVIEW

Date: 2026-08-23

## 0. Evidence and decision discipline

### Observed

- Phase 1 defines compatibility as a revisable hypothesis and algorithms as decision support.
- Phase 2 defines a Compatibility Signal as bounded evidence with source, purpose, uncertainty, sensitivity, and permitted use.
- Phase 2 separates Match, reciprocal Connection, Conversation, human-defined Relationship, and Relationship Feedback.
- Competitor screenshots visibly include MBTI, astrology, birth-related tools, matching entry points, identity tags, AI prompts, and social interaction surfaces.
- The supplied competitor evidence does not establish predictive validity, matching quality, safety outcomes, user consent, or algorithm behavior.

### Inferred

- Evidence is trustworthy only relative to a named purpose; a true fact can still be irrelevant, overly sensitive, or unfair for ranking.
- Self-report, interpretation, observed behavior, private interaction, and safety evidence require different consent and reuse rules.
- A useful compatibility product must preserve uncertainty and provenance instead of converting heterogeneous inputs into an unexplained certainty score.

### Decision

The decisions below define proposed product evidence and trust boundaries. They do not select fields, schemas, APIs, models, weights, services, or implementation.

### Unknown

- No prospective user study, relationship-outcome dataset, validated psychometric package, fairness study, safety threat model, or mainland-China legal/compliance opinion has been supplied.
- ADR-001 and ADR-002 remain proposed; this workshop depends on their acceptance.

## 1. Signal taxonomy

Every candidate signal must have: source, stated purpose, subject, consent status, freshness, uncertainty, sensitivity, allowed uses, correction path, and expiry/review expectation. Missing data is not negative evidence by default.

### 1.1 User Provided Signals

**Examples:** relationship goal, availability, preferred pace, interests, values, life priorities, boundaries, acceptable differences, communication preferences, and explicit deal-breakers.

**Purpose:** establish eligibility, respect hard boundaries, form interpretable areas to explore, and avoid obviously misaligned introductions.

**Trust boundary:**

- Self-report is authoritative about what the user currently states, not proof of future behavior or objective character.
- The user must understand whether an answer affects Profile visibility, eligibility, Ranking, Explanation, or optional reflection.
- Answers are contextual, editable, and time-sensitive.
- One user's preference cannot define another person's human value.

**Proposed use:** explicit relationship intent and consensual, relevant preferences may support Ranking and Explanation. Sensitive or highly subjective declarations require stricter purpose review.

**Limit:** inconsistency, impression management, ambiguity, and change over time must remain possible; the system must not silently reinterpret them as deception.

### 1.2 Personality Signals

**Examples:** MBTI self-identification, questionnaire responses, user-accepted personality reflections, and communication-style reflection.

**Purpose:** self-understanding, vocabulary for discussing tendencies, and generation of tentative compatibility questions.

**Trust boundary:**

- Raw user answers, a framework-generated interpretation, and user correction are distinct evidence.
- Provenance and epistemic status must be visible.
- Personality reflection is optional and revisable.

**Proposed use:**

- User-endorsed communication preferences expressed through a questionnaire may support Explanation and, only after evidence review, limited Ranking as the underlying declared preference—not as a type label.
- MBTI type and generalized personality interpretations are Explanation/reflection only for MVP.

**Limit:** no clinical diagnosis, fixed identity, deterministic pairing rule, or guarantee of relationship outcome.

### 1.3 Cultural Reflection Signals

**Examples:** astrology, Bazi, Ziwei, zodiac, and related user-chosen cultural interpretations.

**Purpose:** optional self-expression, cultural storytelling, reflection prompts, and mutually chosen conversation language.

**Trust boundary:**

- Participation and visibility are explicit opt-ins.
- Source and cultural/non-scientific status are displayed.
- One user's belief does not authorize inference or disclosure about another.

**Proposed use:** optional reflection and Explanation only. They do not enter MVP Ranking, eligibility, safety decisions, or relationship outcome claims.

**Limit:** no fate, destiny, scientific compatibility, health, fertility, morality, danger, or certainty claim.

### 1.4 Behavioral Signals

**Examples potentially observable within product purpose:** explicit accept/pass choices, requested pace, pause/resume choices, response-window preference, completion of respectful closure, correction of prior recommendations, and use or refusal of AI assistance.

**Purpose:** adapt pacing, reduce repeated irrelevant recommendations, and improve the user's own explanation experience.

**Allowed observation boundary:**

- Observe only behavior necessary for a disclosed product purpose.
- Prefer explicit user feedback over covert interpretation.
- Use coarse, contextual patterns rather than intimate content whenever possible.
- Keep product-use behavior separate from judgments about personality or relationship capacity.

**May not be inferred:** private thoughts, love, attraction, loyalty, mental health, honesty, sexual behavior, relationship status, moral character, or intent solely from response time, activity rhythm, message volume, wording, location, or device behavior.

**Proposed use:** explicit choices may support the user's own pacing and recommendation reset. Passive activity and interaction metadata are not MVP compatibility Ranking signals without separate evidence, consent, minimization, and fairness review.

### 1.5 Human Interaction Evidence

**Examples:** a user's private reflection that an interaction clarified a value, contradicted an assumption, revealed a boundary, or left an issue unknown.

**Purpose:** revise that user's Compatibility Hypothesis and future reflection.

**Trust boundary:**

- Interaction content, user interpretation, and mutual fact are distinct.
- One person's private interpretation does not become a fact or Profile attribute about the other person.
- Message content is not general-purpose model input.

**Proposed use:** explicit, user-owned reflection may update that user's hypothesis and preferences. It cannot create a public rating or hidden reputation score.

### 1.6 Sensitive Signals

**Includes or may include:** precise location, identity documents, contact details, birth time/place, sexual orientation, intimate relationship history, health or disability, religion or belief, ethnicity, income/assets, biometric data, private communications, safety reports, abuse/fraud allegations, and inferred sensitive traits.

**Required controls:**

- a named necessity and purpose;
- explicit or otherwise valid consent/authority appropriate to risk;
- minimization and restricted visibility/use;
- correction and user-understandable controls where applicable;
- retention and deletion rules;
- access and safety review boundaries;
- prohibition on unrelated reuse.

**Decision:** Sensitive does not mean “more predictive.” Most sensitive signals are excluded from compatibility Ranking unless a later reviewed policy proves necessity, legitimacy, proportionality, safety, and fairness. Safety evidence is processed for protection, not romantic suitability.

### 1.7 Forbidden Signals and Inferences

The following may not support Ranking, Compatibility Hypotheses, or relationship judgments:

- sensitive attributes inferred without valid purpose and consent;
- psychological or psychiatric diagnosis inferred from product behavior or conversation;
- private thoughts, feelings, attraction, loyalty, honesty, or future conduct attributed without direct evidence;
- destiny, fate, karmic, or scientific-prediction claims derived from cultural systems;
- protected or sensitive traits used as proxies through device, location, language, social graph, or behavior;
- private message content used for general compatibility scoring;
- reports, blocks, or allegations converted into public ratings or romantic desirability scores;
- socioeconomic status, spending, monetization, or engagement propensity used to determine relational worth;
- manipulative vulnerability, jealousy, scarcity, loneliness, or dependency signals used to increase engagement;
- externally obtained data, surveillance, contact scraping, or data supplied by another person without a valid and transparent authority;
- any signal whose provenance, subject, purpose, or permitted use cannot be explained.

## 2. Compatibility Evidence Model

```text
Signal
↓
Interpretation
↓
Compatibility Hypothesis
↓
Human Interaction
↓
Feedback Update
```

### Signal

- **Purpose:** supply a bounded fact, declaration, choice, or reflection relevant to a named relationship question.
- **Boundary:** carries provenance, subject, consent, freshness, uncertainty, sensitivity, and allowed use.
- **Limitation:** it is not compatibility and cannot travel into new purposes merely because it exists.

### Interpretation

- **Purpose:** translate permitted signals into understandable, tentative meaning such as possible alignment, tension, constraint, or unknown.
- **Boundary:** separates direct evidence from inference, names the affected dimension, and remains correctable.
- **Limitation:** interpretation introduces assumptions and bias; it may not present a type label or cultural narrative as fact.

### Compatibility Hypothesis

- **Purpose:** explain why a bounded introduction may be worth reciprocal exploration and what should be learned next.
- **Boundary:** multi-dimensional, time/context specific, falsifiable in ordinary language, and explicit about missing or conflicting evidence.
- **Limitation:** not a score, truth, guarantee, destiny, safety clearance, or prediction of relationship success.

### Human Interaction

- **Purpose:** allow two people to obtain reciprocal evidence through consent-based communication and real choices.
- **Boundary:** meaning belongs to the people involved; product observation remains purpose-limited and privacy-aware.
- **Limitation:** activity volume is not quality, silence is ambiguous, and interaction does not automatically establish Relationship status.

### Feedback Update

- **Purpose:** let a user confirm, contradict, complicate, or leave unknown the prior hypothesis and improve future support.
- **Boundary:** preserves whether feedback is identity correction, preference, explanation usefulness, interaction reflection, product feedback, or safety evidence.
- **Limitation:** one person's feedback does not become objective truth or an unappealable reputation label about another.

## 3. Compatibility Hypothesis contract

### Decision

A Compatibility Hypothesis is:

- a user-specific, pair-specific, dimension-specific proposition;
- built only from permitted evidence;
- understandable without exposing the other person's private data;
- explicit about evidence source, uncertainty, conflict, and missing information;
- framed as a question or reason to explore;
- correctable, rejectable, and revisable through user feedback and interaction.

It must answer:

1. What dimension is being considered?
2. Which allowed signals support or complicate it?
3. What remains unknown?
4. Why might a respectful conversation be useful?
5. What observation or question could update it?

It is not:

- a scalar compatibility truth;
- proof that two people should connect;
- a guarantee or probability of relationship success;
- a judgment of either person's worth;
- a clinical, moral, safety, or destiny verdict.

### Proposed evidence-strength language

- **Declared:** directly stated by the relevant user.
- **Reflected:** an interpretation the user has seen and can correct.
- **Observed choice:** an explicit in-product action relevant to a named purpose.
- **Interaction-reported:** a user's private account of what an interaction taught them.
- **Unknown:** insufficient or conflicting evidence.

These labels describe provenance, not truth ranking. Numeric certainty is not approved in MVP.

## 4. Ranking, Explanation, and Decision boundary

| Signal or interpretation | Ranking | Explanation | Optional reflection | Prohibited decision use |
| --- | --- | --- | --- | --- |
| Explicit relationship goal and current availability | Eligible with consent; may constrain eligibility | Yes | Yes | Cannot guarantee commitment |
| Explicit boundaries and deal-breakers | Eligible where relevant; hard constraints require clear semantics | Yes | Yes | Cannot assign human worth |
| Interests and lifestyle preferences | Eligible with user control and evidence review | Yes | Yes | Cannot imply long-term potential alone |
| Values and life priorities | Eligible only as user-declared, contextual evidence | Yes | Yes | Cannot become a moral ranking |
| Communication or pacing preference | Eligible when directly declared | Yes | Yes | Cannot infer personality or affection from response speed |
| Questionnaire answers | Underlying explicit answers may become eligible after item-level purpose/evidence review | Yes | Yes | No opaque total-score verdict |
| Questionnaire interpretation | Not MVP Ranking | Yes, if provenance and uncertainty are clear | Yes | No diagnosis or deterministic prediction |
| MBTI type | Not MVP Ranking | Yes, user-controlled and non-deterministic | Yes | No type-pair destiny or exclusion |
| Astrology, Bazi, Ziwei | Not Ranking | Only as clearly labeled cultural context when both visibility/purpose boundaries permit | Yes, opt-in | No scientific, fate, safety, or outcome judgment |
| Explicit accept/pass and pacing choices | May adapt the same user's supply/pacing, not another person's worth | Yes to the choosing user | Limited | No hidden desirability score |
| Passive activity or response metadata | Not MVP compatibility Ranking | Only basic service/pacing explanation if necessary | No by default | No affection, intent, loyalty, or personality inference |
| Private message content | Not compatibility Ranking | Not exposed as cross-user explanation | User-requested local reflection only under later consent policy | No general model judgment or private-thought inference |
| Relationship Feedback | May update the author's future preferences only under consent | Private explanation to author | Yes | No public rating or universal label of other user |
| Block/report/safety evidence | Not romantic Ranking | Safety-purpose communication only | No | No desirability score; safety process is separate |
| Sensitive attributes or inferred sensitive traits | Not Ranking unless a later explicit policy proves strict necessity and legality; MVP default excluded | Only when user-provided and necessary for a user-selected purpose | Restricted | No unauthorized inference or proxy use |

### Cultural systems decision

- **Ranking:** excluded from MVP.
- **Explanation:** permitted only as clearly labeled, user-controlled cultural context; never as the reason that a Match is objectively suitable.
- **Optional reflection:** permitted with explicit opt-in, provenance, correction/dismissal, and no destiny claim.
- **Decision:** never used for eligibility, safety action, relationship outcome, or autonomous judgment.

## 5. AI trust boundary

### AI may

- summarize user-provided Profile and reflection while separating facts, interpretations, and unknowns;
- explain permitted compatibility evidence and uncertainty;
- generate respectful questions tied to a named hypothesis;
- help a user reflect on their own observations, assumptions, needs, and boundaries;
- identify when a request is beyond scope and surface safety or qualified-help options;
- state that evidence is insufficient and decline to make a judgment.

### AI may not

- guarantee a Match, Connection, love, loyalty, safety, or relationship outcome;
- claim certainty or hide missing/conflicting evidence;
- infer another person's private thoughts, attraction, motives, diagnosis, honesty, or future behavior;
- manipulate emotion, scarcity, jealousy, fear, loneliness, urgency, or dependency;
- impersonate another person or send undisclosed messages;
- silently use private Conversation content, sensitive traits, or cultural signals for Ranking;
- determine consent, guilt, emergency status, or Relationship state;
- replace user judgment, human safety review, qualified counseling, legal advice, or crisis response.

### Explanation standard

Any AI output affecting relationship choice must identify its purpose, distinguish evidence from interpretation, expose material uncertainty, avoid unshared private information, and end at a clear user-controlled decision point.

## 6. Privacy and consent boundary

### Data ownership language

- **User-authored data:** the user's Identity, Profile choices, Relationship Preference, questionnaire answers, corrections, consent choices, and private reflections. The user has inspection, correction, export, purpose-control, and deletion-request rights subject to transparent safety/legal limits.
- **Other-person data:** information about another user remains that person's data even when visible in a Match or Conversation. Visibility is not ownership or unrestricted reuse.
- **Shared interaction data:** Conversation and mutual interaction involve both people. One person may control their own participation and reflections but cannot unilaterally redefine all shared records or the other person's rights.
- **Safety data:** reports, evidence, moderation outcomes, and protection actions have restricted safety purposes and cannot be reused as public reputation or compatibility scoring.
- **Derived interpretations:** summaries, hypotheses, rankings, and inferred preferences must retain provenance, purpose, correction/contest paths, and expiry/review expectations.

### Consent requirements

- Consent is specific by purpose: Profile visibility, matching participation, personality reflection, cultural reflection, AI assistance, feedback learning, and sensitive-data use are not bundled.
- Consent is understandable and revocable for future use.
- Revocation changes future processing and visibility; safety/legal retention exceptions must be explicit rather than hidden.
- One user's consent cannot authorize processing or disclosure of another user's private data.

### Required user controls

- inspect the evidence and interpretations used for their experience;
- correct source information and challenge interpretations;
- change visibility and permitted uses;
- pause or withdraw from recommendations;
- opt out of cultural reflection and AI assistance;
- request deletion and understand retained exceptions;
- export user-authored data and meaningful consent history at a policy-defined scope;
- reset recommendations without implying deletion of safety records or the other person's data;
- separate preference feedback from safety reporting.

### Feedback publicity boundary

Private rejection reasons, interaction reflections, blocks, reports, and allegations do not become public reviews, badges, desirability scores, or visible explanations to the other person by default.

## 7. Safety domain

Safety states are first-class relationship lifecycle states, not exceptional telemetry.

### Rejection

- A normal exercise of choice requiring no disclosure to the rejected person.
- Must not create guilt, repeated pressure, retaliation, or a universal negative label.

### Unmatched or Connection ended

- A revocation of future ordinary access, distinct from block/report.
- Communicated neutrally without revealing private reasons.

### Block

- Immediate unilateral separation and contact/discovery restriction according to later policy.
- Requires no negotiation and is not by itself a final guilt judgment.

### Report

- A restricted safety allegation initiating protection and review pathways.
- Must preserve separation between immediate protection, evidence, investigation, outcome, appeal, and retention.

### Harassment

- Continued unwanted contact, coercion, threats, sexual harassment, or boundary violation.
- The user needs immediate exit, block, report, and safe-routing options; previous engagement is not continuing consent.

### Fraud

- Suspected deceptive conduct intended to obtain money, property, credentials, or other material benefit.
- Safety handling is separate from compatibility. The product must not promise fraud certainty from automated inference.

### Impersonation

- Material misrepresentation of identity or unauthorized representation as another person.
- Users need a challenge/report path; verification claims must match actual assurance and allow proportional review/appeal.

### Abuse

- Coercive, threatening, controlling, exploitative, or violent behavior or credible risk.
- The product provides safe exit and routing; it is not a crisis, legal, medical, or abuse-intervention service.

### Safety-AI boundary

AI may surface options or triage cues under later policy. It may not declare guilt, fabricate evidence, confront a reported user autonomously, promise emergency response, or suppress human/user escalation.

### Unknown

- Severity taxonomy, immediate actions, evidence standards, human review, emergency pathways, notification, appeals, repeat-pattern handling, identity assurance, retention, and jurisdictional obligations require expert policy work.

## 8. MVP evidence scope

### MVP supports

- explicit relationship goal, current availability, pace, interests, values, priorities, boundaries, and acceptable differences;
- correctable self-description and relationship preferences;
- optional questionnaire reflection with item-level purpose discipline;
- optional MBTI explanation/reflection without Ranking authority;
- optional astrology/Bazi/Ziwei reflection excluded from Ranking;
- explainable, multi-dimensional Compatibility Hypotheses using permitted evidence;
- visible unknowns and conflicting evidence;
- user accept/pass, pacing, correction, explanation usefulness, and private interaction-reflection feedback;
- consent, visibility, correction, pause, opt-out, reset, export-request, and deletion-request entry points at a reviewed policy scope;
- respectful rejection and Connection closure;
- block and report entry, immediate separation, and clearly bounded safety routing;
- AI explanation, summary, question suggestion, reflection support, and safe refusal within the defined boundary.

### MVP does not support

- deterministic compatibility scores or relationship-success probabilities;
- cultural-system Ranking or fate prediction;
- passive behavioral compatibility scoring;
- private-message mining for compatibility or emotion detection;
- unauthorized sensitive-attribute inference or proxy modeling;
- psychological diagnosis, private-thought inference, deception certainty, or autonomous safety verdicts;
- public user ratings derived from rejection, interaction feedback, block, or report;
- autonomous Match acceptance, messaging, relationship decisions, moderation verdicts, or emergency response;
- training/model implementation, database, API, backend, Flutter, microservice, or infrastructure design.

## 9. Open questions for review

- Which explicit user-provided signals are necessary for MVP Ranking rather than Explanation only?
- What item-level evidence standard is required before questionnaire answers may influence Ranking?
- Should MBTI remain permanently explanation-only or be reconsidered after validation?
- Can cultural reflection appear in a Match when only one participant opts in, without revealing or judging the other?
- What constitutes adequate provenance and uncertainty language for users?
- Which passive events, if any, are necessary for pacing without becoming covert personality inference?
- How can meaningful interaction feedback be gathered without reading private Conversation content?
- What deletion, retention, export, reset, correction, and appeal promises are legally and operationally supportable?
- Which safety states require automatic separation, human review, notification, appeal, or external routing?
- What fairness groups, harms, and evaluation measures are required before any Ranking experiment?

