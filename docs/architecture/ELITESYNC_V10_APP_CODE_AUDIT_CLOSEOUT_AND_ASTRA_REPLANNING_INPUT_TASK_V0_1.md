# EliteSync v10｜APP Code Audit Closeout and Astra Replanning Input Task｜v0.1

Status: `PUBLISHED TASK SHEET — APP MAIN-SURFACE CODE-AUDIT CLOSEOUT — CURRENT CAPABILITY INVENTORY — KEEP/REFACTOR/REPLACE/DEFER CLASSIFICATION — GPT-6 ASTRA FEATURE-DESIGN HANDOFF PREPARATION — NO IMPLEMENTATION`

Date: 2026-09-12 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Publication authority

Publication-base `main`:

`8b19d26335b011db79dcd2687e5e0c5bd74349e1`

FIRST handoff:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`

required blob:

`3aa2ead4cf1084b202b67856075c26ab80b0c9a2`

Latest accepted Match failure acceptance:

`docs/architecture/ELITESYNC_V10_ANDROID_STUDIO_EMULATOR_MATCH_LOCAL_STUB_WIDGET_BASELINE_ACCEPTANCE_V0_1.md`

This task is the planned transition from bounded old-APP code/evidence review to product replanning input. It does not authorize implementation, new runtime evidence, private-data access, or final roadmap locking.

## 2. Sole objective

Produce one durable APP code-audit closeout/replanning-input document that answers, from accepted repository evidence only:

1. what current APP capabilities are actually established;
2. which current product surfaces/assets should be classified `KEEP`, `REFACTOR`, `REPLACE`, `DEFER`, or `UNKNOWN`;
3. what accepted defects/remediations are already closed;
4. what evidence gaps or privacy/participant boundaries prevent further old-APP runtime review;
5. what capabilities exist in code but still need product-definition review before reuse;
6. what APP feature-design questions remain unresolved and must be handed to GPT-6 Astra before the new-version implementation roadmap is locked;
7. what can be safely carried forward into Astra planning without re-reading the entire old repository.

This task must not invent a final new APP feature set. Its job is to prepare the evidence-backed design input for the Owner's planned GPT-6 Astra session.

## 3. Startup authority gate

Activation prompt MUST provide:

- `REQUIRED_MAIN` = commit publishing this task;
- `REQUIRED_TASK_BLOB` = exact blob of this task.

Startup sequence:

1. fresh-fetch remote `main`;
2. require `main == REQUIRED_MAIN`, else `STOP — MAIN_AUTHORITY_CHANGED`;
3. read FIRST and require blob `3aa2ead4cf1084b202b67856075c26ab80b0c9a2`;
4. read this task and require `REQUIRED_TASK_BLOB`;
5. read the accepted audit artifacts listed in §4;
6. do not use conversation/project memory as execution authority.

No default `git status`; no protected staged/index inspection.

## 4. Accepted evidence set to read

Read only the accepted/current audit and architecture objects needed for this closeout.

### Required accepted APP-audit objects

- Home first-frame baseline acceptance;
- Home visual/accessibility review acceptance;
- Home semantics source-locator acceptance;
- Home bounded remediation implementation acceptance;
- Home next-migration-entry review acceptance;
- Home large-text evidence acceptance;
- Discover runtime-eligibility acceptance;
- Discover local-stub widget baseline acceptance;
- Discover local-stub visual/semantics review acceptance;
- Remaining-main-surface eligibility acceptance;
- Match local-stub baseline failure acceptance.

Resolve exact current paths/blobs from `main`; record them in the result.

### Required architecture/governance context

Read only exact current versions of:

- `docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`;
- the current product architecture / immutable-boundary document establishing Relationship Decision Support System framing and Match/Connection/Conversation/Relationship separation;
- the current evidence-index/coverage-gap document;
- any current audit closeout/replanning predecessor explicitly referenced by those accepted artifacts.

Do NOT read README. Do NOT inspect FD02. Do NOT perform broad repository archaeology.

### Bounded source confirmation

Source reads are NOT the primary task. Only if an accepted audit conclusion refers to a current surface/capability whose exact current source ownership would otherwise be ambiguous, one bounded direct source confirmation is permitted. Do not reopen broad source review.

## 5. Current surface inventory requirements

At minimum inventory these user-facing domains:

- AppShell/navigation;
- Home;
- Discover;
- Match;
- Messages/Conversation;
- Profile/Identity;
- onboarding/first-use/navigation guards where already established by accepted source evidence;
- verification/questionnaire entry dependencies only to the extent already established by current accepted architecture/source evidence;
- settings/privacy/user-control entry points only where already established;
- notification entry only where already established;
- connection/relationship lifecycle concepts only where accepted architecture documents establish them.

For every domain, record:

- current established capability;
- evidence class (`EMULATOR`, `LOCAL-STUB WIDGET`, `STATIC SOURCE`, `ARCHITECTURE/GOVERNANCE`, or `DEFERRED`);
- data sensitivity / privacy coupling;
- current known defects or accepted closures;
- whether current behavior is safe to treat as reusable planning input;
- one of the classifications in §6.

Do not infer production correctness from widget evidence.

## 6. Required disposition vocabulary

Every major APP capability/surface must receive exactly one primary disposition:

### `KEEP`
Use when current capability/structure is sufficiently established and no accepted evidence currently justifies redesign/replacement. `KEEP` does not mean permanently frozen.

### `REFACTOR`
Use when the capability remains valuable but accepted source/evidence shows structural, ownership, semantics, lifecycle, coupling, maintainability, or product-boundary reasons to restructure it.

### `REPLACE`
Use only when accepted evidence or immutable product architecture establishes that the current implementation/product model conflicts with the target direction strongly enough that carrying it forward as the base would be misleading.

### `DEFER`
Use when the capability cannot be safely audited/decided under current privacy/participant/production/data boundaries, or when a local tooling blocker prevents completion but does not justify a source/product judgment.

### `UNKNOWN`
Use only where evidence is genuinely insufficient and no bounded accepted disposition exists.

Do not use `REFACTOR` or `REPLACE` merely because a newer design could look better.

## 7. Mandatory accepted decisions to preserve

The result must preserve at least these accepted conclusions:

- Home first-frame semantics defects were fixed and promoted to `main`;
- Home H1/H2: `NO MIGRATION ENTRY ESTABLISHED` after ordinary and 2.0-text-scale evidence;
- Discover: `NO SOURCE-ACTIONABLE ISSUE ESTABLISHED` from the accepted synthetic baseline;
- real remote Discover content remains `RUNTIME REMOTE CONTENT OF UNKNOWN PRIVACY/PRODUCTION CLASS`;
- direct Discover emulator baseline remains unauthorized;
- Messages remains excluded from populated audit under private/participant/Conversation coupling;
- Profile remains excluded from populated audit under private/user/session/profile-data coupling;
- Match local-stub eligibility was established for the canonical synthetic `noRound` seam;
- Match baseline itself remains `NOT ESTABLISHED` because the local Flutter test runner failed to exit after `test_body_complete`;
- Match static review is therefore not accepted/authorized from that incomplete baseline;
- this Match runner-exit blocker is local/tooling and must not be converted into a product defect;
- Sandbox DEP13 remains unresolved and separate from emulator/widget evidence;
- B12 remains NOT AUTHORIZED;
- M2 remains separate and not automatically authorized.

## 8. Capability-gap / Astra handoff matrix

Create a dedicated matrix for the planned GPT-6 Astra session.

For each major product domain, record:

- `CURRENT ESTABLISHED CAPABILITY`;
- `CURRENT DISPOSITION`;
- `WHAT THE OLD APP ALREADY DOES`;
- `WHAT IS NOT YET PRODUCT-DEFINED / NOT YET PROVEN`;
- `ASTRA DESIGN QUESTION`;
- `DECISION NEEDED BEFORE ROADMAP LOCK` (`YES`/`NO`);
- `IMPLEMENTATION MAY START BEFORE ASTRA` (`YES`/`NO`).

The matrix must separate:

- missing feature versus unreviewed private feature;
- implementation gap versus product-definition gap;
- runtime-evidence gap versus architectural gap;
- technical debt versus intentional product simplification.

Do not present an unreviewed feature as absent merely because it was excluded from runtime evidence.

## 9. Astra design-question package

Produce a concise but comprehensive Owner/Astra design-question package. At minimum ask whether the new-version APP should retain, redefine, merge, split, add, or remove capabilities across:

- Home role and information density;
- Discover role versus relationship-support content;
- Match lifecycle and canonical round-contract states;
- Connection lifecycle after Match;
- Conversation lifecycle and when messaging becomes available;
- Relationship lifecycle / ongoing support after connection;
- Profile versus private identity versus public/showcase expression separation;
- questionnaire/verification/readiness roles in navigation and matching eligibility;
- explainability/user-control surfaces;
- notification strategy;
- settings/privacy controls;
- onboarding/first-use flow;
- empty/error/offline states;
- what should be explicit public content versus private user data;
- whether any legacy concepts should be removed entirely.

This is a design-question package, not the answers.

## 10. Required transition recommendation

The result must end with a precise recommendation for the Owner's next action.

If the accepted evidence is sufficient for replanning input, the recommended next action must be:

`SWITCH TO GPT-6 ASTRA FOR NEW-VERSION APP FEATURE-DESIGN SUPPLEMENT BEFORE FINAL IMPLEMENTATION-ROADMAP LOCK`

The result must explicitly state that Astra should receive this closeout artifact plus the current product architecture/immutable-boundary document, and should not be asked to rediscover old-code facts already established here.

No implementation roadmap may be marked final before the Owner completes that Astra design-supplement session.

## 11. Explicit prohibitions

Do NOT:

- modify product source/tests/build/configuration;
- run widget tests, builds, emulator, ADB, uiautomator, logcat, screenshots, APIs, sockets, or dependency resolution;
- inspect real/cached private records, Conversation data, profile/session values, participant/match results, or production responses;
- reopen Match runner debugging;
- create new widget evidence;
- reopen Messages/Profile populated baselines;
- perform participant research/recruitment;
- inspect private Conversation content;
- run telemetry/analytics/measurement;
- perform Safety Operations or new legal research;
- read README;
- inspect FD02;
- search history/non-main branches;
- perform broad repository archaeology;
- create Windows Sandbox;
- run DEP13, B12, M2, M3 acquisition, or unrelated implementation.

## 12. Required result candidate

Publish exactly one result artifact on a dedicated review branch:

`docs/architecture/ELITESYNC_V10_APP_CODE_AUDIT_CLOSEOUT_AND_ASTRA_REPLANNING_INPUT_RESULT_V0_1.md`

Candidate commit must contain only that result artifact.

The result must include:

- exact main/FIRST/task identities;
- exact accepted evidence set used;
- audit scope and explicit exclusions;
- current capability inventory;
- surface-by-surface `KEEP/REFACTOR/REPLACE/DEFER/UNKNOWN` table;
- closed defects/remediations;
- unresolved blockers/evidence gaps;
- current privacy/data-boundary map;
- current architecture/product-boundary map;
- Astra capability-gap/design-question matrix;
- explicit items that are NOT missing but merely deferred/unreviewed;
- exact recommended Owner/Astra next action;
- negative attestations.

Final classification exactly:

`APP CODE AUDIT CLOSEOUT COMPLETE — CURRENT CAPABILITY INVENTORY ESTABLISHED — ASTRA REPLANNING INPUT READY — AWAITING INDEPENDENT ACCEPTANCE`

Stop after candidate publication. Do not self-accept, modify implementation, or publish a final implementation roadmap.

## 13. End state

`OLD APP EVIDENCE AUDIT -> CLOSEOUT + CAPABILITY INVENTORY -> OWNER SWITCHES TO GPT-6 ASTRA -> FEATURE-DESIGN SUPPLEMENT -> FINAL ROADMAP LOCK -> IMPLEMENTATION`

`CLOSEOUT != FINAL FEATURE DESIGN`

`DEFERRED != MISSING`

`LOCAL TOOLING BLOCKER != PRODUCT DEFECT`

`ASTRA SUPPLEMENT REQUIRED BEFORE FINAL ROADMAP LOCK`
