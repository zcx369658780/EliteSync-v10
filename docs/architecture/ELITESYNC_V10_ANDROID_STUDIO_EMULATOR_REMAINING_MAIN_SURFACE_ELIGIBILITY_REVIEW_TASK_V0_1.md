# EliteSync v10｜Android Studio Emulator Remaining Main Surface Eligibility Review Task｜v0.1

Status: `PUBLISHED TASK SHEET — READ-ONLY MATCH/MESSAGES/PROFILE ELIGIBILITY REVIEW — NO RUNTIME NAVIGATION — NO PRIVATE/PRODUCTION DATA — NO SOURCE MODIFICATION`

Date: 2026-09-12 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Publication authority

Publication-base `main`:

`ee4950f1542c03d63a5423816a45d5be83f07a37`

FIRST handoff:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`

required blob:

`3aa2ead4cf1084b202b67856075c26ab80b0c9a2`

Accepted Discover static-review acceptance:

`docs/architecture/ELITESYNC_V10_ANDROID_STUDIO_EMULATOR_DISCOVER_LOCAL_STUB_VISUAL_SEMANTICS_REVIEW_ACCEPTANCE_V0_1.md`

Accepted Discover decision:

`NO SOURCE-ACTIONABLE ISSUE ESTABLISHED`

This task is a read-only eligibility gate. It does not authorize rendering, implementation, emulator navigation, production calls, private-data access, or participant-flow execution.

## 2. Sole objective

Classify the three remaining unreviewed AppShell destinations:

- index 2 `匹配` / Match;
- index 3 `消息` / Messages;
- index 4 `我的` / Profile.

For each, determine only whether current source/test seams support a future deterministic synthetic/local widget baseline that can be executed without:

- real user/private/participant/Conversation data;
- production Backend/Database/PUI behavior;
- emulator navigation;
- tracked source modification;
- destination-side interactions.

Then nominate at most ONE future local-stub widget baseline surface if it is clearly eligible and lower-risk under the preserved boundaries.

If none is eligible, classify NONE. Do not weaken the boundaries to force progress.

## 3. Startup authority gate

Activation prompt MUST provide:

- `REQUIRED_MAIN` = commit publishing this task;
- `REQUIRED_TASK_BLOB` = exact blob of this task.

Startup sequence:

1. fresh-fetch remote `main`;
2. require `main == REQUIRED_MAIN`, else `STOP — MAIN_AUTHORITY_CHANGED`;
3. read FIRST and require blob `3aa2ead4cf1084b202b67856075c26ab80b0c9a2`;
4. read this task and require `REQUIRED_TASK_BLOB`;
5. read the accepted Discover static-review acceptance named in §1;
6. do not use conversation/project memory as execution authority.

No default `git status`; no protected staged/index inspection.

## 4. Exact source identity gates

Require current-main exact blobs:

### Shell ownership

`apps/flutter_elitesync_module/lib/app/router/app_shell.dart`

blob:

`2f1d4933fd4fb928afed77f98e84d7cb6021dbf8`

### Match

`apps/flutter_elitesync_module/lib/features/match/presentation/pages/match_portal_page.dart`

blob:

`9ec5d659c5dd923aee1316ac97e6ff5f0118b270`

`apps/flutter_elitesync_module/lib/features/match/presentation/providers/match_providers.dart`

blob:

`e014443f97d720cb9debdc2968f0e1b7021a4a5e`

### Messages

`apps/flutter_elitesync_module/lib/features/chat/presentation/pages/conversation_list_page.dart`

blob:

`d2372f0dd913965f38eb03146c4618416527fe31`

`apps/flutter_elitesync_module/lib/features/chat/presentation/providers/chat_providers.dart`

blob:

`eb3f2405293f39f67b734ed7dd92a72b44c4324f`

### Profile

`apps/flutter_elitesync_module/lib/features/profile/presentation/pages/profile_page.dart`

blob:

`647344288f418f158092a0e747ea3066bccfe011`

`apps/flutter_elitesync_module/lib/features/profile/presentation/providers/profile_providers.dart`

blob:

`d10b2e4cfe8ec236b041809859360d472dd86424`

If any required blob differs, stop:

`REMAINING_SURFACE_ELIGIBILITY_SOURCE_IDENTITY_CHANGED`

## 5. Bounded one-step outward reads

For each candidate surface, directly referenced provider/data-source/test files may be read one step outward only when necessary to answer:

- what automatic data fetch/watch occurs on first build;
- what data class the page consumes;
- whether current tests already demonstrate a provider override/fake/local synthetic seam;
- whether such a seam avoids production calls and private/participant data by construction.

Do not inspect actual persisted records, API responses, chat messages, participant records, match results, profile contents, or production databases.

Do not inspect detail destinations reached from these pages.

Do not search history/non-main branches or browse unrelated modules.

## 6. Eligibility criteria

For a surface to be `LOCAL-STUB WIDGET BASELINE ELIGIBLE`, all must be established from current source/test seams:

1. deterministic page ownership from AppShell;
2. default data side effects are understood;
3. a local provider/fake override seam already exists or can be constructed in a TEMP harness using public/current provider interfaces without tracked-source changes;
4. synthetic fixtures can be explicitly non-personal and non-participant;
5. production `ApiClient`/socket/request count can be proven `0` by in-process instrumentation;
6. no content-detail/chat-room/match-result/profile-edit destination needs to be entered;
7. the future baseline can use zero UI interaction;
8. the future baseline would not require reading private Conversation/user/profile/match production data.

If a surface intrinsically depends on private/user/participant/Conversation state for the very content being assessed, classify it ineligible for the current evidence route even if the code could technically be mocked.

## 7. Candidate-specific review questions

### A. Match

Determine:

- whether first build watches match countdown/result/notification or other participant/match-state providers;
- whether source data includes match partner identifiers/nickname, result/highlight/reason/detail state, or other participant-linked material;
- whether an existing focused synthetic seam can render only a public/static shell without exercising a participant workflow;
- whether `useMockMatch`/round-contract branching changes the eligibility materially.

Do not inspect or render real match results and do not enter match result/detail/feedback/showcase/messages routes.

### B. Messages

Determine:

- whether first build watches `conversationListProvider` and/or reads cached conversation/search-history state;
- whether the surface is fundamentally a private Conversation list surface;
- whether any future baseline could be limited to a generic empty/loading shell without reading or synthesizing Conversation content;
- whether such a shell would be meaningful enough to justify a baseline under current goals.

Do not inspect any real or cached Conversation item, message, peer identity, search history value, or chat room.

### C. Profile

Determine:

- whether first build watches `profileProvider`, session state, and admin-access state;
- whether the displayed surface intrinsically consumes user profile fields, including potentially private birth/location/profile data;
- whether a generic empty/error/public shell exists that can be rendered synthetically without accessing or implying a real user's profile;
- whether an existing provider override seam makes such a baseline deterministic and meaningful.

Do not inspect any real/cached user profile record, birth fields, location fields, session user values, personal showcase data, or admin data.

## 8. Selection rule

Classify each surface exactly one of:

- `LOCAL-STUB WIDGET BASELINE ELIGIBLE`
- `NOT ELIGIBLE — PRIVATE/PARTICIPANT/CONVERSATION COUPLING`
- `NOT ELIGIBLE — PRODUCTION/REMOTE SIDE EFFECT WITHOUT ACCEPTED LOCAL SEAM`
- `NOT ELIGIBLE — MEANINGFUL BASELINE NOT ESTABLISHED`

After individual classification:

- if exactly one surface is eligible, nominate it;
- if multiple are eligible, nominate the lowest-risk surface with the least private/participant coupling and strongest already-established local seam;
- if none are eligible, nominate `NONE` and stop UI-surface expansion under current boundaries.

Do not nominate a surface merely because a fake could theoretically be written.

## 9. Explicit prohibitions

Do NOT:

- render Match/Messages/Profile in widget tests or emulator;
- run emulator/ADB/uiautomator/logcat/screenshots;
- call production or remote APIs/sockets;
- inspect real responses, cached private records, Conversation content, profile contents, participant/match result content, or session user data;
- navigate to any of the three destinations;
- inspect downstream detail/chat/profile-edit/result destinations;
- modify source/tests/build/configuration;
- create a harness or synthetic fixture in this task;
- run tests/builds/dependency resolution;
- read README;
- inspect FD02;
- search history/non-main branches;
- perform broad archaeology or broad QA;
- create Windows Sandbox;
- run DEP13, B12, M2, M3 acquisition, or unrelated implementation.

## 10. Required result candidate

Publish exactly one result artifact on a dedicated review branch:

`docs/architecture/ELITESYNC_V10_ANDROID_STUDIO_EMULATOR_REMAINING_MAIN_SURFACE_ELIGIBILITY_REVIEW_RESULT_V0_1.md`

It must record:

- main/FIRST/task/acceptance identities;
- all exact source identity gates;
- bounded ownership/data-flow summary for Match, Messages, Profile;
- data/private/participant/Conversation boundary for each;
- exact local-seam evidence or absence;
- individual eligibility classifications;
- exact nominated surface or `NONE`;
- next bounded task recommendation only if one surface is legitimately eligible;
- negative attestations.

Final classification exactly one of:

`REMAINING MAIN SURFACE ELIGIBILITY REVIEW COMPLETE — <MATCH or MESSAGES or PROFILE> LOCAL-STUB BASELINE NOMINATED — AWAITING INDEPENDENT ACCEPTANCE`

or

`REMAINING MAIN SURFACE ELIGIBILITY REVIEW COMPLETE — NO REMAINING SURFACE ELIGIBLE UNDER CURRENT DATA BOUNDARIES — AWAITING INDEPENDENT ACCEPTANCE`

Stop after candidate publication. Do not self-accept or publish a baseline/implementation task.

## 11. Preserved boundaries

Discover remains:

`NO SOURCE-ACTIONABLE ISSUE ESTABLISHED`

Real remote Discover content remains:

`RUNTIME REMOTE CONTENT OF UNKNOWN PRIVACY/PRODUCTION CLASS`

Direct Discover emulator baseline remains unauthorized.

Home H1/H2 remain `NO MIGRATION ENTRY ESTABLISHED`; accepted Home semantics findings remain closed.

Remain unchanged:

`FAILED_START_RESULT_NOT_CAPTURED`

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

Accepted B R4 share-success fact remains valid. Sandbox DEP13 remains unresolved. B12 remains NOT AUTHORIZED. M2 remains separate and NOT automatically authorized.

## 12. End state

`HOME NO ENTRY + DISCOVER NO ISSUE -> REMAINING MAIN SURFACE ELIGIBILITY GATE`

`ELIGIBILITY REVIEW != PRIVATE DATA AUTHORITY`

`SYNTHETIC POSSIBILITY != ELIGIBILITY`

`NO ELIGIBLE SURFACE IS A VALID TERMINAL RESULT`
