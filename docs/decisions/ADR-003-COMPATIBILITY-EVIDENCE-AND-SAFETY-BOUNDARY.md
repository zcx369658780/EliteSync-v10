# ADR-003: Compatibility Evidence and Safety Boundary

Status: ACCEPTED

Owner acceptance recorded: 2026-08-24

Independent review state: AWAITING GPT L3 REVIEW

Date: 2026-08-23

Decision owners: Owner (final product authority), with ChatGPT architecture/product review

Depends on: ADR-001 and ADR-002, both accepted

## Context

ADR-001 defines compatibility as decision support rather than relationship truth. ADR-002 separates Compatibility Signal, Compatibility Hypothesis, Human Interaction, Feedback Update, Match, Connection, and Relationship. A product-level evidence policy is required before conceptual architecture, data design, or AI matching work can responsibly begin.

## Observed

- Historical EliteSync assets include questionnaires, MBTI, astrology, Bazi, Ziwei, matching, and scoring knowledge.
- Competitor screenshots display personality and cultural interpretation alongside social or matching surfaces.
- No supplied research demonstrates that these systems predict relationship success, that competitor algorithms are safe/effective, or that any legacy weight should be reused.

## Inferred

- Evidence utility depends on purpose, provenance, consent, sensitivity, uncertainty, and relevance—not mere availability.
- Ranking, Explanation, optional reflection, safety processing, and prohibited judgment require separate use categories.
- Without explicit boundaries, private interaction and cultural narratives could be turned into false certainty or coercive profiling.

## Proposed Decision

### Evidence model

The canonical product evidence flow is:

```text
Signal
→ Interpretation
→ Compatibility Hypothesis
→ Human Interaction
→ Feedback Update
```

Each transition preserves provenance, purpose, uncertainty, consent, sensitivity, correction, and permitted use. Feedback may confirm, contradict, complicate, or leave a hypothesis unknown.

### Signal classes

1. **User Provided Signals:** self-reported intent, pace, interests, values, preferences, boundaries, and acceptable differences. Relevant explicit signals may support Ranking and Explanation with consent.
2. **Personality Signals:** questionnaire inputs, MBTI, and personality reflections. User-declared underlying preferences may be evaluated item by item; type labels and interpretations are MVP Explanation/reflection only.
3. **Cultural Reflection Signals:** astrology, Bazi, Ziwei, zodiac, and related systems. They are opt-in cultural reflection language, excluded from MVP Ranking and all scientific/fate claims.
4. **Behavioral Signals:** explicit choices may adapt the same user's pacing and preferences. Passive behavior and interaction metadata are excluded from MVP compatibility Ranking.
5. **Human Interaction Evidence:** explicit user-owned reflection may revise that user's hypothesis; private Conversation content is not general compatibility input.
6. **Sensitive Signals:** require demonstrated necessity, valid authority/consent, minimization, restricted use, correction, retention, and deletion policy. MVP defaults them out of Ranking unless separately approved.
7. **Forbidden Signals/Inferences:** unauthorized sensitive inference, diagnosis, private-thought claims, destiny prediction, manipulative vulnerability, proxy discrimination, surveillance/external scraping, private-message scoring, and safety evidence reused as romantic desirability.

### Use boundary

- **Ranking:** limited to relevant, permitted, user-understood evidence. Explicit intent, boundaries, and preferences may qualify; every class requires purpose and evidence review.
- **Explanation:** may use permitted evidence and clearly labeled tentative interpretations without exposing another person's private information.
- **Optional reflection:** may include user-controlled MBTI, questionnaire interpretation, astrology, Bazi, or Ziwei with provenance and non-scientific labels.
- **Decision:** no signal may autonomously decide consent, relationship status, personal worth, guilt, destiny, or outcome.

### Cultural and personality boundary

- Astrology, Bazi, and Ziwei do not enter MVP Ranking.
- MBTI type does not enter MVP Ranking.
- Questionnaire total scores and opaque personality labels do not enter MVP Ranking.
- Underlying explicit questionnaire answers may be reconsidered only at item level, for a named purpose, after evidence, fairness, consent, and user-comprehension review.

### Compatibility Hypothesis

A Compatibility Hypothesis is pair-specific, dimension-specific, explainable, uncertain, falsifiable in ordinary language, correctable, rejectable, and revisable. It states what evidence supports or complicates exploration, what is missing, and what respectful interaction could clarify.

It is not a scalar truth, guarantee, probability of success, safety clearance, diagnosis, destiny claim, or judgment of worth.

### AI boundary

AI may summarize, explain, suggest questions, support reflection, expose uncertainty, and refuse unsupported judgments. It may not guarantee outcomes, infer private thoughts, manipulate emotion, impersonate users, silently use restricted evidence, determine consent/guilt/relationship status, or replace human judgment and qualified safety review.

### Privacy and consent

- Consent is specific by purpose and revocable for future use.
- User-authored data, other-person data, shared interaction data, safety data, and derived interpretations retain distinct rights and purposes.
- Users need inspection, correction, visibility control, opt-out, pause, reset, export-request, and deletion-request controls with transparent safety/legal exceptions.
- Private rejection, interaction feedback, blocks, reports, and allegations do not become public reviews or compatibility/desirability scores.

### Safety domain

Rejection, Connection closure, block, report, harassment, fraud, impersonation, and abuse are first-class lifecycle states. Safety processing is separate from compatibility optimization. Immediate protection, investigation, outcome, appeal, and retention are distinct concepts requiring later policy.

### MVP boundary

MVP may use explicit, relevant user-provided signals for explainable hypotheses; support optional reflection; collect explicit user correction/pacing/usefulness feedback; and provide rejection, closure, block, report, and safety-routing controls.

MVP excludes deterministic scores, cultural-system Ranking, passive behavior scoring, private-message mining, sensitive-trait inference, diagnosis, private-thought claims, public reputation scoring, autonomous relationship decisions, autonomous safety verdicts, and technical/model implementation.

### Authority

Acceptance of this ADR freezes product evidence, consent, privacy, AI, and safety boundaries only. It does not authorize legacy weights, algorithm design, model selection/training, database, API, backend, Flutter, services, or code.

## Alternatives considered

### A. Reuse 9.x matching weights and signals

Rejected because historical availability is not evidence of v10 purpose, validity, fairness, or consent.

### B. Treat all self-reported and behavioral data as ranking features

Rejected because data existence does not establish relevance or permission, and passive behavior invites covert inference.

### C. Include cultural systems in Ranking as a differentiator

Rejected for MVP because predictive validity is unestablished and deterministic framing conflicts with the trust boundary.

### D. Mine private Conversation for compatibility learning

Rejected because intimate content is highly sensitive, shared between users, context-dependent, and vulnerable to private-thought inference.

### E. Convert feedback and reports into a single reputation score

Rejected because preference, ambiguity, product usefulness, allegation, and safety outcome have distinct provenance and meaning.

### F. Let AI resolve uncertainty automatically

Rejected because plausible language cannot substitute for evidence, consent, safety review, or human relationship judgment.

## Consequences if accepted

### Positive

- Establishes an auditable evidence contract before AI or data architecture.
- Preserves user agency and epistemic honesty.
- Prevents cultural assets from becoming unsupported prediction engines.
- Protects private interaction and safety evidence from romantic scoring reuse.
- Narrows MVP to evidence that can be explained and controlled.

### Costs and constraints

- Historical algorithms and many available data points may remain unused.
- Ranking breadth will be deliberately limited until evidence and fairness review exists.
- Consent, correction, provenance, uncertainty, reset, and safety separation become mandatory product concerns.
- Numeric compatibility certainty and engagement-only optimization are unavailable shortcuts.

## Unknowns requiring follow-up

- MVP Ranking signal allowlist and item-level evidence standard.
- Fairness groups, harm taxonomy, evaluation measures, and experimental stop conditions.
- Provenance and uncertainty language understandable to users.
- Cultural reflection behavior when participants have different consent or beliefs.
- Privacy-safe interaction feedback and meaningful-conversation measurement.
- Exact correction, deletion, retention, export, reset, and appeal policies.
- Safety severity, immediate actions, review standards, identity assurance, external routing, and jurisdictional requirements.
- Human-review and AI-escalation boundaries.

## Validation required before acceptance

- GPT L3 evidence/trust/safety review.
- Owner approval of signal taxonomy, permitted-use matrix, cultural/personality restrictions, forbidden inferences, privacy controls, safety separation, and MVP exclusions.
- Specialist legal/privacy, safety, fairness, and research-method review before operational or technical design.
- Consistency review after ADR-001 and ADR-002 statuses are finalized.

## Recommended Phase 4

Conceptual Domain Architecture and Responsibility Boundary Workshop.

Phase 4 should map the accepted product language into conceptual bounded responsibilities, lifecycle ownership, policy decision points, and information-flow boundaries. It must remain technology-neutral and precede database, API, backend, Flutter, microservice, and AI implementation design.
