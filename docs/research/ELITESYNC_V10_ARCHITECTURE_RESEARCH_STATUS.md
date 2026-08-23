# EliteSync-v10 Architecture Research Status

Status: READY_FOR_SCOPED_DISCOVERY_WORKSHOPS — CONTEXT GAP OPEN

Date: 2026-08-23

## Research principles

- Design EliteSync 10.0; do not restore EliteSync 9.x.
- Treat historical assets and competitor evidence as inputs, not decisions.
- Resolve product intent and evidence requirements before technical structure.
- Keep research claims separate from architecture decisions and implementation commitments.
- Do not begin business-code, API, database, migration, or service work in this phase.

## 1. Product Vision

Status: OPEN

Research needed:

- primary user and high-value relationship problem;
- precise definition and user promise of slow dating;
- differentiation through personality intelligence, cultural compatibility, and AI assistance;
- product principles, exclusions, trust promise, and mainland-China operating constraints;
- MVP hypothesis, outcome metrics, guardrails, and monetization hypotheses.

Required output: a testable product vision, target-user statement, jobs-to-be-done, product principles, non-goals, and success measures.

## 2. User Journey

Status: OPEN

Research needed:

- acquisition and expectation setting;
- consent-aware onboarding and progressive profile creation;
- compatibility discovery and explanation;
- considered introduction, pacing, conversation, and real-world next steps;
- retention without compulsive engagement;
- safety, blocking/reporting, appeals, privacy controls, deletion, and account recovery;
- premium and admin journeys only after core user value is defined.

Required output: current hypotheses, target journey map, critical moments, failure/recovery paths, and experiment plan.

## 3. Domain Model

Status: OPEN — MUST PRECEDE API/DATABASE DESIGN

Research needed:

- user, identity, profile, preferences, consent, and visibility;
- personality/cultural evidence and user-correctable interpretations;
- compatibility assessment, introduction, match, relationship intent, and pacing;
- conversation, assistance session, recommendation, feedback, moderation, and audit;
- distinction between source observations, derived signals, model outputs, explanations, and user decisions;
- lifecycle, ownership, retention, deletion, and policy boundaries for each domain object.

Required output: ubiquitous language, context map, entity/value-object hypotheses, invariants, lifecycle diagrams, and unresolved decisions. Historical tables and APIs must not define this model.

## 4. AI Matching

Status: OPEN — HIGH-RISK RESEARCH AREA

Research needed:

- matching objective and definition of a good outcome;
- candidate generation, ranking, compatibility reasoning, explanation, and feedback loops;
- role and evidentiary limits of questionnaires, MBTI, astrology, Bazi, Ziwei, preferences, and behavior;
- cold start, uncertainty, diversity, fairness, manipulation resistance, and feedback bias;
- privacy-preserving feature design and sensitive-inference controls;
- offline benchmarks, human review, online experiments, monitoring, rollback, and user recourse;
- boundaries between matching, recommendation, and relationship-assistance AI.

Required output: AI product contract, signal inventory, risk register, evaluation framework, human-control model, and architecture options. No model choice is yet authorized.

## 5. Backend Architecture

Status: DEFERRED UNTIL PRODUCT AND DOMAIN FRAMING

Research needed:

- quality attributes: privacy, safety, reliability, latency, evolvability, observability, and cost;
- bounded contexts and responsibility boundaries derived from the new domain model;
- modular-monolith versus service decomposition options and decision triggers;
- synchronous/asynchronous interaction principles;
- identity, moderation, notification, experimentation, AI orchestration, and audit boundaries;
- deployment and operational constraints for the mainland-China product context.

Required output: option comparison, decision drivers, context/container diagrams, responsibility map, and staged evolution path. The current Laravel/Flutter/Android runtime does not predetermine the answer.

## 6. Data Architecture

Status: DEFERRED UNTIL DOMAIN AND AI SIGNAL CONTRACTS

Research needed:

- authoritative data ownership and lineage;
- operational, analytical, model-feature, moderation, and audit data separation;
- consent, purpose limitation, minimization, retention, deletion, export, and correction;
- sensitive data and derived-inference classification;
- event semantics, versioning, quality, access control, encryption, and observability;
- training/evaluation data governance, leakage prevention, reproducibility, and model-output provenance.

Required output: conceptual data model, classification scheme, ownership matrix, lifecycle policies, lineage design, and data/AI governance controls. No schema creation is authorized.

## Cross-cutting open evidence

- The requested research-context handoff and context index are absent from current `origin/main`.
- Competitor evidence is screenshot-based and historical; it does not confirm current behavior, algorithms, economics, retention, settings, or interaction outcomes.
- No user research, market validation, legal/compliance determination, safety threat model, or quantitative product baseline has yet been supplied in the initialized context.

## Recommended next workshop phase

Run a Product Vision and Trust Boundary Workshop first. Its purpose is to freeze only:

1. primary user and core problem;
2. operational definition of slow dating;
3. smallest valuable relationship loop;
4. AI promise and explicit prohibitions;
5. privacy, consent, safety, and mainland-China compliance questions requiring expert resolution;
6. MVP outcome metrics and non-goals.

After that workshop is reviewed, proceed to User Journey and Domain Language discovery. Backend, data, and AI component architecture should follow those decisions rather than lead them.

## Review gate

Await GPT L3 review. Do not advance to implementation, schema, API, migration, service scaffolding, or model selection from this document alone.
