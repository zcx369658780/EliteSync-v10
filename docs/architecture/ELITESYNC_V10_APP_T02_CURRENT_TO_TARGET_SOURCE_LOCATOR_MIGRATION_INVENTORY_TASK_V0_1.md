# EliteSync v10｜APP-T02 Current-to-Target Source Locator / Migration Inventory Task｜v0.1

Status: `AUTHORIZED — BOUNDED SOURCE LOCATOR / MIGRATION INVENTORY ONLY — NO IMPLEMENTATION`

Date: 2026-09-12 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Authority

Fresh-start expected GitHub authority is the current `origin/main` after APP-T01 acceptance.

Read FIRST:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260912_V0_1.md`

Then read:

- `docs/architecture/ELITESYNC_V10_NEW_VERSION_APP_FEATURE_DESIGN_SUPPLEMENT_V0_1.md`
- `docs/architecture/ELITESYNC_V10_NEW_VERSION_APP_FEATURE_DESIGN_OWNER_ACCEPTANCE_V0_1.md`
- `docs/architecture/ELITESYNC_V10_NEW_VERSION_APP_IMPLEMENTATION_ROADMAP_BASELINE_V0_1.md`
- `docs/architecture/ELITESYNC_V10_APP_T01_TARGET_ROUTE_DOMAIN_STATE_DATA_AUDIENCE_CONTRACT_RESULT_V0_1.md`
- `docs/architecture/ELITESYNC_V10_APP_T01_TARGET_ROUTE_DOMAIN_STATE_DATA_AUDIENCE_CONTRACT_ACCEPTANCE_V0_1.md`
- this task sheet.

APP-T01 accepted result blob:

`8ebe98c52b322b7e1a7f1dbac8a621748123f418`

## 2. Local-worktree safety

A pre-existing local worktree is known to be detached and dirty, including a tracked `AGENTS.md` modification and untracked architecture documents.

Do not modify, clean, stash, reset, checkout over, delete, move, adopt, stage, commit, or otherwise disturb that worktree.

APP-T02 explicitly authorizes a separate fresh clean Git worktree based on fresh-fetched `origin/main`.

## 3. Sole objective

Produce a bounded **current-to-target source locator / migration inventory** that tells later implementation tasks exactly where the current APP ownership and migration seams are, without changing source code.

This is NOT an implementation task, runtime audit, private-data inspection, dependency task, or broad source archaeology.

## 4. Required inventory domains

Locate and classify the current source ownership for these target areas:

1. top-level AppShell navigation and route ownership relative to target `Home | Progress | Messages | Me`;
2. Home surface and any current lifecycle summary / CTA ownership relevant to Calm Home;
3. Discover top-level route/feed ownership and reusable card/detail primitives relevant to later Explore/Support migration;
4. canonical Match route/view/state/contract consumers;
5. participant-linked legacy Match countdown/result/notification consumers and entry points;
6. current Profile/session/private-identity ownership;
7. matching-input / readiness / verification ownership and coupling;
8. candidate/public Showcase-like fields or views, if explicitly established by source;
9. current Messages/Conversation list/thread routing and gating ownership;
10. any existing Connection representation, consent, state or route ownership;
11. any existing Relationship representation, support-state or route ownership;
12. settings/privacy/notification entry points relevant to APP-T01 controls;
13. route guards / authentication / onboarding entry points relevant to the target guard contract;
14. source locations where current code appears to cross an APP-T01 data-class, audience, purpose, consent or explanation boundary.

## 5. Required classification per located object

For each located file/class/widget/provider/controller/router/model/store/contract or other bounded source object, record:

- exact path;
- exact symbol/object name when practical;
- current responsibility established by source;
- target responsibility under APP-T01;
- migration disposition: `KEEP`, `REFACTOR`, `REPLACE`, `REMOVE`, `DEFER`, or `UNKNOWN`;
- rationale tied to accepted target contract;
- known consumers/entry points only where bounded source evidence establishes them;
- privacy/data-class coupling;
- whether later implementation can change it before a retained UNKNOWN is resolved;
- downstream task most likely to own the change (`APP-T03` through `APP-T11` where applicable).

`CURRENT SOURCE EXISTS != MUST KEEP`.

`NEW TARGET EXISTS != CURRENT CAPABILITY ABSENT`.

## 6. Mandatory migration questions

The result must answer, with bounded source evidence:

### Navigation

- What currently owns the five top-level destinations?
- What exact source seams must change to reach four-target IA?
- Can Discover and Match top-level ownership be removed/refactored without touching unrelated domains?

### Match

- What is the exact canonical Match seam and who consumes it?
- What exact participant-linked legacy Match path(s) remain?
- Which files/symbols would need to be retired or bridged after replacement exists?
- Do not infer product defect from the known `flutter_tester` exit blocker.

### Profile / Me

- Which current source objects mix Private Identity, Matching Inputs, Readiness, verification, session/profile or Showcase-like concerns?
- Which can be separated later without inspecting populated private values?

### Conversation / Connection

- What source currently gates or opens Messages/Conversation?
- Is an explicit Connection concept represented in source? If not established, classify `UNKNOWN`/not located within authorized scope rather than `ABSENT`.
- Identify seams where separate Connection and Conversation consent could later be inserted.

### Relationship

- Locate only explicit current Relationship references relevant to target Phase-2 boundaries.
- Do not broaden search to infer relationship status from private Conversation behavior.

### Cross-cutting controls

- Where are notifications, settings/privacy, auth/onboarding guards, empty/error/loading/offline/stale behaviors currently owned?
- Which existing source semantics conflict with or can support APP-T01 explanation/control rules?

## 7. Read scope

APP-T02 authorizes bounded read-only source inspection necessary to answer the required inventory questions.

Prefer direct locators from already-known accepted evidence and source references. Expand only when a located consumer/import/router/reference requires following one bounded link.

Do not perform broad repository archaeology or unrelated enumeration.

Do not read README or FD02.

Do not read historical/non-main branches except the fresh APP-T02 task branch created from current `origin/main`.

## 8. Private / production / runtime boundary

Do not:

- run the app, emulator, widget tests, ADB, network calls or backend requests;
- inspect populated Profile/session values;
- inspect participant/candidate records;
- inspect private Conversation/message content;
- inspect production Discover payloads;
- synthesize or populate private records merely to make a path testable;
- perform telemetry/analytics/measurement;
- perform participant research;
- perform Safety Operations or new legal research.

Static source may be read to establish ownership, field names, dependencies and control flow, but private data values must not be read.

## 9. Implementation boundary

Do not modify:

- Dart/Flutter/product source;
- tests;
- route tables;
- providers/controllers;
- models/contracts;
- API/database/service/module decomposition;
- build/dependency configuration.

Do not perform migrations, delete legacy code, rename source symbols, implement target states, or start APP-T03.

## 10. Retained UNKNOWNs

APP-T02 must preserve and must not select values for:

- launch segment / exact eligibility;
- minimum identity-assurance mechanism/level;
- exact Match proposal expiry duration;
- Conversation/shared-content retention/export/deletion rights;
- region-specific legal/data-right implementation;
- exact Phase-2 Relationship tools;
- optional AI/personality/astrology/reference-signal allowlist.

Where a source migration depends on one of these, mark it `BLOCKED_BY_RETAINED_UNKNOWN` or equivalent; do not invent the missing decision.

## 11. Required deliverable

Create exactly one candidate result artifact:

`docs/architecture/ELITESYNC_V10_APP_T02_CURRENT_TO_TARGET_SOURCE_LOCATOR_MIGRATION_INVENTORY_RESULT_V0_1.md`

The result must contain:

1. authority and source-read scope;
2. source locator inventory by domain;
3. target migration disposition matrix;
4. canonical Match vs legacy Match consumer map;
5. Profile/private-identity/readiness/Showcase coupling map;
6. Conversation/Connection/Relationship source-ownership map;
7. route/guard/settings/notifications/common-state map;
8. APP-T01 contract conflict/support findings;
9. retained-UNKNOWN blockers;
10. an explicit APP-T03 readiness recommendation;
11. a bounded list of exact source files/symbols that APP-T03 may change if accepted.

## 12. Candidate rules

Use a fresh candidate branch, suggested:

`review/app-t02-current-to-target-source-locator-migration-inventory-v0-1`

Commit and push exactly the result artifact.

Do not merge to `main`.
Do not self-accept.
Stop after reporting candidate identity and classification.

Expected success classification:

`APP-T02 SOURCE LOCATOR / MIGRATION INVENTORY ESTABLISHED — READY FOR INDEPENDENT ACCEPTANCE`
