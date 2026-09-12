# EliteSync v10｜Android Studio Emulator Match Local-Stub Widget Baseline Task｜v0.1

Status: `PUBLISHED TASK SHEET — MATCH CANONICAL NO-ROUND LOCAL-STUB WIDGET BASELINE — ZERO PRIVATE/PARTICIPANT DATA — ZERO PRODUCTION REQUESTS — NO UI INTERACTION`

Date: 2026-09-12 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Publication authority

Publication-base `main`:

`20e28a673970fbd2bf9a7c8cabe29d144b4a6967`

FIRST handoff:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`

required blob:

`3aa2ead4cf1084b202b67856075c26ab80b0c9a2`

Accepted remaining-surface eligibility acceptance:

`docs/architecture/ELITESYNC_V10_ANDROID_STUDIO_EMULATOR_REMAINING_MAIN_SURFACE_ELIGIBILITY_REVIEW_ACCEPTANCE_V0_1.md`

Accepted candidate/result:

- candidate commit: `3ab76dd74f1eb6ce80f1ccdeb104f3a54f4c5453`
- result blob: `4fe8800889c5ac2104c89cb03d90ba75c70abfe4`
- accepted nomination: `MATCH`
- Messages/Profile remain excluded by private/participant/Conversation coupling.

This task gathers one final safe main-surface widget baseline before APP code-audit closeout. It does not authorize production Match behavior, participant workflows, implementation, or emulator navigation.

## 2. Sole objective

Establish one deterministic Match first-frame widget baseline for the canonical round-contract `noRound` state while proving all of the following:

1. current `MatchPortalPage` selects the canonical `MatchRoundContractView` branch;
2. one direct synthetic `matchRoundProjectionProvider` override supplies exactly one `MatchRoundBusinessState.noRound` projection;
3. no legacy countdown/result/notification provider is evaluated;
4. no production API or socket request occurs;
5. no local match-result/detail snapshot or participant/private record is read;
6. no UI interaction or destination navigation occurs;
7. bounded visual/semantics evidence is captured for the stable `noRound` frame.

This task must not presume that the baseline contains a defect.

## 3. Startup authority gate

Activation prompt MUST provide:

- `REQUIRED_MAIN` = commit publishing this task;
- `REQUIRED_TASK_BLOB` = exact blob of this task.

Startup sequence:

1. fresh-fetch remote `main`;
2. require `main == REQUIRED_MAIN`, else `STOP — MAIN_AUTHORITY_CHANGED`;
3. read FIRST and require blob `3aa2ead4cf1084b202b67856075c26ab80b0c9a2`;
4. read this task and require `REQUIRED_TASK_BLOB`;
5. read the remaining-surface eligibility acceptance named in §1;
6. do not use conversation/project memory as execution authority.

No default `git status`; no protected staged/index inspection.

## 4. Exact current-source identity gates

Before harness creation, require current-main exact blobs:

- `apps/flutter_elitesync_module/lib/features/match/presentation/pages/match_portal_page.dart`
  - `9ec5d659c5dd923aee1316ac97e6ff5f0118b270`
- `apps/flutter_elitesync_module/lib/features/match/presentation/providers/match_providers.dart`
  - `e014443f97d720cb9debdc2968f0e1b7021a4a5e`
- `apps/flutter_elitesync_module/lib/features/match/presentation/widgets/match_round_contract_view.dart`
  - `2c56d12a2ca75dc50d710fe43ecac112e42cf7fc`
- `apps/flutter_elitesync_module/test/features/match/presentation/pages/match_portal_page_test.dart`
  - `d4036430f69b6e65f422b6240bf68ec6890d00eb`
- `apps/flutter_elitesync_module/lib/design_system/components/layout/browse_scaffold.dart`
  - `a064369146732eca394d3b2abfe473d5fff3ef48`

If any identity differs, stop:

`MATCH_LOCAL_STUB_BASELINE_SOURCE_IDENTITY_CHANGED`

Do not adapt the harness to changed source by inference.

## 5. Temporary-harness authority

Create exactly one task-owned TEMP Flutter widget-test harness outside tracked repository source/test/build paths.

Requirements:

- fresh task-owned TEMP directory;
- harness is not tracked and not committed;
- record exact path and SHA-256;
- use current package imports only;
- if `.dart_tool/package_config.json` is absent in the dedicated worktree, exactly one `flutter pub get --offline` inside `apps/flutter_elitesync_module` is authorized solely to establish local package state;
- no network retrieval;
- tracked source/test/pubspec/lock/build/config files must remain byte-identical;
- do not create a second alternate harness.

If the TEMP harness cannot execute without tracked modifications, stop:

`MATCH_LOCAL_STUB_TEMP_HARNESS_NOT_EXECUTABLE`

## 6. Canonical branch contract

The harness must render exactly:

`MatchPortalPage`

under a local `ProviderScope` with an `AppEnv` that forces the canonical round-contract path by setting:

- `useMockMatch = false`
- `useMatchRoundContract = false` is permitted because `!useMockMatch` already selects the canonical branch.

The harness must override:

`matchRoundProjectionProvider`

with exactly one synthetic projection:

- state: `MatchRoundBusinessState.noRound`;
- contract version: synthetic/static test value such as `match_round_v2`;
- projection version: deterministic positive integer;
- retry eligible: `false`;
- user action: `wait_next_round`;
- result: absent/null;
- conversation capability: absent/null;
- no match id;
- no partner id;
- no partner nickname;
- no participant field;
- no user/private/profile/Conversation field.

Time fields may use one deterministic fixed UTC timestamp generated in the harness. Do not use real server data.

## 7. Legacy-path non-evaluation proof

The harness must prove the participant-linked legacy branch is unreachable.

Override at least these providers with fail-fast sentinels that increment counters and throw if evaluated:

- `matchCountdownProvider`
- `matchResultProvider`

If the current canonical branch would otherwise touch notification state, provide a zero/local override or fail-fast sentinel as appropriate; final evidence must establish that no participant-linked notification behavior was needed for the canonical `noRound` frame.

Required final counters:

- projection override evaluation count: exactly `1`;
- legacy countdown evaluation count: `0`;
- legacy result evaluation count: `0`.

Any non-zero legacy count invalidates the baseline.

## 8. Zero-production-request / zero-private-state proof

Use in-process controlled instrumentation only.

Provide task-local `ApiClient`/Dio counting instrumentation through provider overrides sufficient to prove:

- API request count: `0`.

If a socket provider/client is constructible through the rendered path, instrument or override it and require:

- socket connection/request count: `0`.

No localhost/external probe is permitted.

Do not read or seed:

- `matchResultSnapshot`;
- `matchDetailSnapshot`;
- partner/participant records;
- session user values;
- Conversation content;
- profile data.

If such state is unexpectedly requested, classify the baseline invalid and stop without inspecting the value.

## 9. Render configuration

Fixed widget configuration:

- logical viewport `390 x 844`;
- DPR `1.0`;
- light theme;
- text scale `1.0`;
- no AppShell;
- no route navigation;
- no tap/click/scroll/drag/refresh action;
- no timer-driven second-state capture.

Pump only until the synthetic projection is stably rendered.

The 30-second internal timer in `MatchRoundContractView` must not be allowed to create a second evidence state; finish well before that period and dispose the widget normally.

## 10. Required baseline evidence

Preserve exactly three task-owned evidence files outside the repository:

1. one rendered Match PNG;
2. one bounded semantics/structure JSON/text artifact;
3. one machine-readable receipt JSON/text artifact.

Record byte size and SHA-256 for each.

The receipt must include at least:

- viewport/DPR/theme/text scale;
- all source identity gates;
- canonical branch selected: true/false;
- synthetic projection state;
- projection evaluation count;
- legacy countdown/result evaluation counts;
- API request count;
- socket request/connection count if applicable;
- interaction count;
- navigation count;
- private/cache access count or explicit controlled assertion that none was read;
- Flutter exception count;
- presence count for header `慢约会`;
- presence count for subtitle `查看当前状态和可用的下一步。`;
- presence count for state title `当前没有进行中的慢约会`;
- presence count for state body `有新的轮次开放时，会在这里显示。`;
- presence/action representation for `返回首页` without invocation;
- top-level bounds for header and main state card where determinable;
- clipping/overflow/framework exception evidence.

## 11. Interpretation limits

This baseline may establish only:

- deterministic current canonical Match `noRound` widget rendering;
- absence of participant-linked legacy provider evaluation in this exact harness;
- zero controlled production requests;
- layout/semantics facts for the one synthetic static state;
- zero interaction/navigation facts.

It must NOT establish or claim:

- real Match/participant data correctness;
- countdown/result/revealed/noCandidate/failed/closed states;
- match algorithm correctness;
- partner selection quality;
- Conversation availability;
- Backend/Database/PUI correctness;
- emulator equivalence;
- production or release readiness.

## 12. Explicit prohibitions

Do NOT:

- render AppShell or navigate to Match in emulator;
- run emulator/ADB/uiautomator/logcat/device screenshot;
- render legacy Match branch;
- inspect or synthesize participant/partner/result/detail/Conversation/profile/session data;
- call real APIs/sockets;
- read match caches or private records;
- tap `返回首页`, refresh, pull-to-refresh, or any control;
- enter result/detail/feedback/showcase/messages/notification destinations;
- modify tracked source/tests/build/pubspec/configuration;
- commit TEMP harness/evidence/package state;
- run broad/full test suites;
- download dependencies, SDK components, or system images;
- read README;
- inspect FD02;
- search history/non-main branches;
- perform broad archaeology/QA;
- create Windows Sandbox;
- run DEP13, B12, M2, M3 acquisition, or unrelated implementation.

## 13. Required result candidate

Publish exactly one result artifact on a dedicated review branch:

`docs/architecture/ELITESYNC_V10_ANDROID_STUDIO_EMULATOR_MATCH_LOCAL_STUB_WIDGET_BASELINE_RESULT_V0_1.md`

Candidate commit must contain only that result artifact.

Result must record:

- main/FIRST/task/acceptance identities;
- source identity gates;
- TEMP harness path/SHA-256;
- exact execution command/result;
- synthetic projection specification;
- all legacy/provider/network/socket/interaction/navigation/private-state counters;
- evidence paths/bytes/SHA-256;
- visible/structural/semantics observations;
- Flutter exception/overflow result;
- exact interpretation limits;
- exact next bounded recommendation;
- negative attestations.

Final classification exactly one of:

`MATCH LOCAL-STUB WIDGET BASELINE ESTABLISHED — READY FOR INDEPENDENT ACCEPTANCE`

or

`MATCH LOCAL-STUB WIDGET BASELINE NOT ESTABLISHED — CONTROLLED/LOCAL GATE FAILED — AWAITING INDEPENDENT ACCEPTANCE`

## 14. Stop and project-transition rule

Stop immediately after publishing the one candidate. Do not self-accept or publish an implementation/runtime task.

If the Match baseline is later independently accepted, the next bounded action should be exactly one static visual/semantics review of the accepted Match baseline. After that review is accepted, the APP main-surface evidence audit should transition to:

`CODE AUDIT CLOSEOUT + CURRENT CAPABILITY INVENTORY + ASTRA REPLANNING INPUT`

Do not reopen Messages/Profile through populated synthetic data solely to increase audit coverage.

The closeout/replanning input must explicitly prepare for an Owner-requested switch to GPT-6 Astra to supplement the new-version APP feature design before final implementation-roadmap locking.

## 15. Preserved boundaries

Preserve:

- Home H1/H2: `NO MIGRATION ENTRY ESTABLISHED`;
- Discover: `NO SOURCE-ACTIONABLE ISSUE ESTABLISHED`;
- real remote Discover content: `RUNTIME REMOTE CONTENT OF UNKNOWN PRIVACY/PRODUCTION CLASS`;
- Messages/Profile excluded under current private-data boundary;
- `FAILED_START_RESULT_NOT_CAPTURED`;
- `WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`
- Sandbox DEP13 unresolved;
- B12 NOT AUTHORIZED;
- M2 separate and NOT automatically authorized.

## 16. End state

`REMAINING-SURFACE REVIEW -> MATCH CANONICAL NO-ROUND SYNTHETIC BASELINE -> STATIC REVIEW -> CODE AUDIT CLOSEOUT -> ASTRA REPLANNING INPUT`
