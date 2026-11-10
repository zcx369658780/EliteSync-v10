# EliteSync v10｜New-Version APP Feature-Design Owner Acceptance｜v0.1

Status: `OWNER ACCEPTED — FEATURE-DESIGN BASELINE ESTABLISHED — ROADMAP LOCK MAY PROCEED — CODE IMPLEMENTATION STILL REQUIRES BOUNDED TASK AUTHORIZATION`

Date: 2026-09-12 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Accepted design artifact

Owner reviewed and accepted the new-version APP feature-design direction recorded in:

`docs/architecture/ELITESYNC_V10_NEW_VERSION_APP_FEATURE_DESIGN_SUPPLEMENT_V0_1.md`

Accepted design blob:

`b72ed9ec851d44aba7be65883186cb275fab22d1`

Design commit on review branch:

`1506ec298de419e50d074e8385aae0ef636510fd`

Acceptance base before this documentation sequence:

`d96901e288a6b3da6da12caf226e6d11638838e1`

## 2. Owner-confirmed product direction

The following are now accepted planning decisions for the new APP target:

1. MVP top-level IA is `Home | Progress | Messages | Me`.
2. Discover is not an MVP top-level feed; it is redefined as a secondary `Explore / Support Library`, targeted for Phase 2 unless future evidence justifies elevation.
3. `Match != Connection != Conversation != Relationship` remains mandatory and is implemented as independent lifecycle/consent boundaries.
4. Match acceptance does not automatically create Connection.
5. Connection does not automatically authorize Conversation.
6. Conversation activity does not establish or infer Relationship.
7. Relationship support is a Phase-2 mutual opt-in support context, not an AI-inferred state.
8. MVP does not establish a globally public Profile. Private Identity, Matching Inputs, Readiness and Showcase are separate purpose/lifecycle surfaces.
9. MVP does not use a single authoritative Compatibility total score; reasons, provenance, constraints and uncertainty are preferred.
10. Private Conversation is not a default AI, training or ranking input.
11. Canonical Match is the forward product path; the participant-linked legacy Match path is a bounded retirement/migration concern rather than a co-equal long-term product model.
12. Privacy-minimal notifications, point-of-use consent, central privacy controls, and a named readiness checklist are required target capabilities.

## 3. Preserved immutable boundaries

This acceptance does not change the already accepted product truth:

- EliteSync is a Relationship Decision Support System;
- it is not an AI relationship authority, truth authority, guilt authority, autonomous Safety authority, or engagement-maximization system;
- Privacy, Safety and User Control remain highest-priority constraints;
- Explainability, Reliability, Fairness and Auditability remain supporting constraints;
- AI output is not verified truth;
- Safety evidence is not ordinary Compatibility/Ranking/public-reputation evidence;
- private Conversation is not default training data;
- Block != Report; Report != Finding; Allegation != Finding.

## 4. Retained bounded unknowns

Owner acceptance of the target design does not invent decisions that were deliberately left unresolved. The following remain future bounded decisions:

- launch segment and exact eligibility scope;
- exact minimum identity-assurance mechanism/level;
- exact Match proposal expiry duration and any future multi-candidate limit;
- exact Conversation/shared-content retention, export and deletion semantics;
- region-specific data-right implementation/legal bases at the appropriate maturity trigger;
- exact Phase-2 Relationship tools;
- exact optional AI/personality/astrology/reference-signal allowlist and evidence standard.

These are not reasons to reopen the old APP audit. They are scoped downstream decision points.

## 5. Roadmap consequence

The prior sequence:

`ACCEPTED CODE-AUDIT CLOSEOUT -> FEATURE-DESIGN SUPPLEMENT -> OWNER DECISIONS -> FINAL CAPABILITY GAP / ROADMAP LOCK -> IMPLEMENTATION`

has now advanced through Owner decisions.

The next documentation/planning action may therefore establish a new APP implementation-roadmap baseline and explicit workstream ordering.

This acceptance itself does not authorize arbitrary code changes. Implementation should still be issued as bounded tasks with exact repository authority and scope.

## 6. Explicit exclusions

This acceptance does not authorize:

- participant research or recruitment;
- private Conversation inspection;
- telemetry/analytics/measurement;
- Safety Operations;
- new legal research outside an explicit maturity-trigger task;
- Sandbox/DEP13;
- B12;
- M2;
- unrelated acquisition;
- unrestricted source archaeology;
- immediate broad code implementation.

## 7. Acceptance result

`ACCEPT — NEW-VERSION APP FEATURE-DESIGN BASELINE ESTABLISHED — OWNER DECISIONS RECORDED — FINAL APP ROADMAP BASELINE MAY NOW BE LOCKED — IMPLEMENTATION MUST REMAIN BOUNDED`
