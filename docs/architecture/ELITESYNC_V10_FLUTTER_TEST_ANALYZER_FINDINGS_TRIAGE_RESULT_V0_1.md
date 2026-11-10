# EliteSync v10｜Flutter Test / Analyzer Findings Triage Result｜v0.1

Status: `FLUTTER NON-GREEN EVIDENCE TRIAGED — TEST/ANALYZER FINDINGS CLASSIFIED — MVP IMPACT EXPLICIT — NO REPAIRS PERFORMED — READY FOR INDEPENDENT REVIEW / OWNER REPAIR PRIORITIZATION`

Date: `2026-09-13`

Repository: `zcx369658780/EliteSync-v10`

## 1. Fresh authority and bounded evidence basis

- Fresh-fetched `origin/main`: `befe03314d7994d4870504310576060a8adc3de1`.
- Bound task-publication commit: `befe03314d7994d4870504310576060a8adc3de1`.
- Task blob: `fca46b591c9aa7487a31a8247999927e438538ed`.
- Task-named publication authority: `7f85627f337f24e72708c41836b00bcbd6fdc004`.
- The sole intervening commit is `befe03314d7994d4870504310576060a8adc3de1`, which adds only the T04 task sheet. It does not alter Flutter source, tests, tooling evidence, or triage scope.
- Bounded branch: `review/next-t04-flutter-findings-triage-v0-1`.
- Bounded worktree: `D:\EliteSync-v10-next-t04-20260913`.

`AGENTS.md` was read first. The MVP closeout handoff, accepted Track 3 result, accepted Track 3 acceptance, and this task sheet were then read in the required order.

Primary execution evidence is the accepted Track 3 ledger:

- `flutter test`: exit `1`, final count `+522 -35`;
- `flutter analyze --no-pub`: exit `1`;
- analyzer: `0 errors / 4 warnings / 17 infos`;
- a null-check `_TypeError` involving `AppThemeX.appTokens` was observed in `app_presentation_state_view_test.dart`;
- named example failure files cover invalid-route recovery, first-use onboarding/router integration, acceptance smoke, and Settings.

This triage used only narrow static reads of those named test surfaces, their directly corresponding production seams, the exact analyzer locations, and accepted MVP contract material. The full test suite and full analyzer were not rerun. No targeted test was run because static inspection resolved the `AppThemeX` classification, while a single targeted invocation could not reconstruct the omitted 35-item runner transcript. No `pub get` was run.

## 2. Test-failure classification summary

All 35 runner failures are allocated exactly once:

| Primary classification | Count |
|---|---:|
| `STALE_TEST_EXPECTATION` | 5 |
| `PRODUCT_REGRESSION_CANDIDATE` | 0 |
| `TEST_HARNESS_OR_FIXTURE_DEFECT` | 2 |
| `SOURCE_QUALITY_DEFECT_NON_PRODUCT_SEMANTIC` | 0 |
| `UNRESOLVED` | 28 |
| **Total** | **35** |

The high unresolved count is an evidence-preservation boundary, not a product verdict. The accepted Track 3 artifact preserves the aggregate count and example files, but not a complete per-test identity/message transcript. T04 therefore does not invent identities, assertion messages, or product-regression claims that the durable evidence does not contain.

## 3. Complete 35-failure ledger

### 3.1 Exact identities statically classifiable from named failing files

| IDs | Exact test identity | Count | Primary classification | Evidence and repair surface |
|---|---|---:|---|---|
| F01 | `invalid initial route offers Home recovery` — `test/app/router/invalid_route_recovery_test.dart:69` | 1 | `STALE_TEST_EXPECTATION` | Recovery UI and actions still exist in `app_router.dart:575-601`; the final assertion expects superseded Home text `查看慢约进展` at test line 79, while current accepted Calm State Hub copy is `当前状态 · Current state` / `下一步 · Next decision` in `home_page.dart:55` and `:133`. Test-only expectation update. |
| F02 | `invalid pushed route can recover back` — `test/app/router/invalid_route_recovery_test.dart:82` | 1 | `STALE_TEST_EXPECTATION` | Same root cause: recovery-back behavior remains, but test line 97 uses the superseded Home marker. Test-only expectation update. |
| F03 | `home page renders current slow-date entry` — `test/features/acceptance_smoke_test.dart:104` | 1 | `STALE_TEST_EXPECTATION` | Test lines 108-114 expect old Home title/copy/key. Current Home implements the accepted Calm State Hub presentation at `home_page.dart:55-68` and `:121-145`. No accepted Home invariant contradiction is established. |
| F04 | `conversation list page renders mock conversations` — `test/features/acceptance_smoke_test.dart:117` | 1 | `STALE_TEST_EXPECTATION` | Test expects private mock rows without providing Conversation authority. Production defaults `conversationAccessProvider` to `notYetEstablished` at `conversation_access_state.dart:4-6` and gates protected list construction at `conversation_list_page.dart:32-37`, matching the accepted fail-closed Conversation contract. |
| F05 | `chat room page renders mock thread and safety menu` — `test/features/acceptance_smoke_test.dart:128` | 1 | `STALE_TEST_EXPECTATION` | Test supplies only `ChatRouteState.legacyPeer` and expects private thread UI. Production gates the protected room at `chat_room_page.dart:59-68`; route identity does not establish consent. Updating the test must not introduce fake production authority. |
| F06 | `stale content is visibly marked and retries only the read` — `test/shared/presentation_state/app_presentation_state_view_test.dart:7` | 1 | `TEST_HARNESS_OR_FIXTURE_DEFECT` | Test wraps the widget in a bare `MaterialApp` at lines 12-21. The stale branch reads `context.appTokens` at `app_presentation_state_view.dart:109`; the fixture omits the required `AppThemeTokens` extension. |
| F07 | `authority-not-established hides supplied protected content` — `test/shared/presentation_state/app_presentation_state_view_test.dart:32` | 1 | `TEST_HARNESS_OR_FIXTURE_DEFECT` | Same bare `MaterialApp` fixture at lines 35-43. The branch creates `AppEmptyState`, which reads `context.appTokens` at `app_empty_state.dart:23`. The privacy assertion itself remains aligned with the accepted fail-closed contract but cannot execute under the incomplete theme fixture. |

F06-F07 share one deterministic fixture root cause. The Track 3 narrative retained the file-level `_TypeError`, not which test emitted the first displayed exception; direct control-flow inspection establishes that both exact test identities enter a token-dependent widget under the same token-less fixture.

### 3.2 Failures whose individual identities were not durably retained

| IDs | Preserved identity boundary | Count | Primary classification | Required additional evidence |
|---|---|---:|---|---|
| F08 | At least one failure in `test/app/router/first_use_onboarding_router_integration_test.dart`; exact case and assertion were not retained | 1 | `UNRESOLVED` | Original Track 3 expanded/machine runner entry, or separately authorized bounded execution of the exact failing case. Static inspection shows the tested four-tab labels, onboarding copy, skip action, login copy, and Progress Match key still exist, so a product regression cannot be inferred. |
| F09 | At least one failure in `test/features/profile/presentation/pages/settings_page_test.dart`; exact case and assertion were not retained | 1 | `UNRESOLVED` | Original Track 3 runner entry identifying the exact Settings test and mismatch, followed by narrow source comparison. The file contains multiple unrelated Settings, replay, reset, role, debug, help, version, and write-failure cases; file identity alone cannot select a valid root cause. |
| F10-F35 | Remaining Track 3 failure instances not individually named in the accepted durable ledger; these may include additional cases in the named example files and/or other files | 26 | `UNRESOLVED` | The original Track 3 per-test failure transcript or a new Owner-authorized evidence-capture task. Do not infer identities from test inventory or use T04 as authority to rerun the full suite. |

Counts remain exact: `7 classified + 28 unresolved = 35`.

## 4. MVP-invariant impact assessment

No `PRODUCT_REGRESSION_CANDIDATE` is established by the bounded evidence.

- F01-F03 fail because tests retain superseded Home presentation markers; current source matches the accepted Calm State Hub direction.
- F04-F05 fail because tests expect private Conversation UI without the accepted Connection/messaging-consent authority. Current fail-closed source preserves `ROUTE IDENTITY != CONSENT` and `Match != Connection != Conversation != Relationship`.
- F06-F07 are unable to exercise their presentation-state assertions because their test theme fixture omits the repository theme extension; they do not contradict `UNKNOWN != ABSENT`, `STATE VOCABULARY != AUTHORITY`, or protected-content gating.
- F08-F35 remain `UNRESOLVED`. This means MVP impact is not established either way for those individual failures; it does not mean absent, benign, or blocking.
- The 21 analyzer findings contain no analyzer error and no P0 item. They do not by themselves reopen MVP integration acceptance.

The accepted MVP integration contract therefore remains unchanged by this triage. Fresh exact evidence would be required before promoting any unresolved test to `PRODUCT_REGRESSION_CANDIDATE`.

## 5. Focused `AppThemeX.appTokens` assessment

### Exact failing seam

- `AppThemeX.appTokens` is a non-null getter: `Theme.of(context).extension<AppThemeTokens>()!` at `lib/design_system/theme/app_theme_extensions.dart:259-260`.
- F06 reaches `_StalePresentation`, which reads it at `lib/shared/presentation_state/app_presentation_state_view.dart:109`.
- F07 reaches `AppEmptyState`, which reads it at `lib/design_system/components/states/app_empty_state.dart:23`.

### Production precondition

Token-dependent design-system widgets assume that their enclosing `ThemeData` contains `AppThemeTokens`. Both `buildLightTheme()` and `buildDarkTheme()` install the extension (`light_theme.dart:87`, `dark_theme.dart:87`). `EliteSyncApp` supplies `AppTheme.light` and `AppTheme.dark` to `MaterialApp.router` at `app.dart:21-27`.

### Test precondition

The two tests supply a plain `MaterialApp` with no `theme`, `darkTheme`, or `AppThemeTokens` extension. The required test precondition is missing.

### Reachability and classification

The seam is not plausibly reached without tokens through the normal `EliteSyncApp` composition shown above. It remains reachable if a token-dependent widget is mounted outside that composition, including the current unit-test harness. Current evidence therefore best supports `TEST_HARNESS_OR_FIXTURE_DEFECT`, not an accepted-product regression or a shared runtime theme-contract defect.

Recommended later candidate priority:

- `P1 test-only`: use the repository theme in `app_presentation_state_view_test.dart` so the two accepted common-state assertions actually execute.
- `DEFER product-source`: do not add a silent token fallback or change `AppThemeX` unless a separately authorized contract review decides these components must support standalone non-EliteSync composition. The present evidence does not require that semantic change.

## 6. Complete analyzer ledger

### 6.1 Warnings — 4

| ID | Exact finding | Priority | Classification |
|---|---|---|---|
| A01 | `connection_page.dart:60:26` — `unnecessary_non_null_assertion` on `state!.code` | `P2` | Source hygiene. `hasAuthority` is defined from `state != null` at line 41; no accepted lifecycle/authority defect is shown. |
| A02 | `connection_page.dart:65:38` — `unnecessary_non_null_assertion` on `state!.label` | `P2` | Same promotion/style debt; no behavior change established. |
| A03 | `connection_page.dart:66:38` — `unnecessary_non_null_assertion` on `state!.isTerminalRequestOutcome` | `P2` | Same promotion/style debt; terminal-outcome disclaimer remains present. |
| A04 | `standard_ziwei_grid.dart:508:11` — unused local variable `t` | `P2` | Dead local/source hygiene only; no current product-semantic effect established. |

### 6.2 Infos — 17

| ID | Exact finding | Priority | Classification |
|---|---|---|---|
| A05 | `logging_interceptor.dart:11:5` — `avoid_print` request line | `P1` | Uncontrolled duplicate console logging of method/URI; review data minimization and logging ownership, not merely syntax. No actual private value was inspected in T04. |
| A06 | `logging_interceptor.dart:18:5` — `avoid_print` response line | `P1` | Same console/logging boundary. |
| A07 | `logging_interceptor.dart:30:5` — `avoid_print` error line | `P1` | Same boundary, including error-path URI/status output. |
| A08 | `app_telemetry_service.dart:44:7` — `use_null_aware_elements` for `targetUserId` | `P2` | Equivalent collection-literal cleanup; no telemetry execution or semantic review authorized. |
| A09 | `app_telemetry_service.dart:45:7` — `use_null_aware_elements` for `matchId` | `P2` | Equivalent collection-literal cleanup. |
| A10 | `astro_profile_provider.dart:20:5` — `avoid_print` request/query line | `P1` | Console logging can duplicate request/query diagnostics outside the owned logger. Review logging/data-minimization boundary; no profile data was read. |
| A11 | `astro_profile_provider.dart:42:5` — `avoid_print` success/keys line | `P1` | Same boundary. |
| A12 | `astro_profile_provider.dart:57:3` — `avoid_print` failure line | `P1` | Same boundary, including failure message. |
| A13 | `astro_profile_provider.dart:69:7` — `avoid_print` fallback-success line | `P1` | Same boundary. |
| A14 | `astro_profile_provider.dart:85:5` — `avoid_print` fallback-failure line | `P1` | Same boundary. |
| A15 | `rtc_livekit_service.dart:422:20` — deprecated `setSpeakerOn` | `P1` | Probable near-term SDK/runtime-maintenance risk; current call remains supported but replacement behavior must be reviewed separately. |
| A16 | `rtc_livekit_service.dart:556:40` — deprecated `speakerOn` | `P1` | Same audio-route API migration risk. |
| A17 | `rtc_livekit_service.dart:557:43` — deprecated `forceSpeakerOutput` | `P1` | Same audio-route API migration risk. |
| A18 | `browse_scaffold_semantics_test.dart:34:41` — deprecated `containsSemantics` | `P2` | Test-only API cleanup; use the supported semantics matcher in a later bounded test repair. |
| A19 | `floating_dock_bottom_bar_semantics_test.dart:41:7` — deprecated `containsSemantics` | `P2` | Test-only API cleanup. |
| A20 | `floating_dock_bottom_bar_semantics_test.dart:84:7` — deprecated `containsSemantics` | `P2` | Test-only API cleanup. |
| A21 | `floating_dock_bottom_bar_semantics_test.dart:88:7` — deprecated `containsSemantics` | `P2` | Test-only API cleanup. |

Analyzer priority totals:

| Priority | Warnings | Infos | Total |
|---|---:|---:|---:|
| `P0` | 0 | 0 | 0 |
| `P1` | 0 | 11 | 11 |
| `P2` | 4 | 6 | 10 |
| `DEFER` | 0 | 0 | 0 |
| **Total** | **4** | **17** | **21** |

Analyzer severity is not treated as product severity. The P1 `avoid_print` items warrant a logging/data-minimization review because the duplicated strings include URI/query/failure context; this triage does not claim that private data was actually emitted. The RTC deprecations warrant migration review because replacement semantics can affect audio routing, but no current RTC failure was established.

## 7. Later repair-candidate separation

This section prioritizes possible later work; it creates no repair authority.

### Test-only candidates

1. `P1`: repair F06-F07's theme fixture using the repository theme, then verify the stale/read-retry and protected-content assertions themselves.
2. `P1`: update F01-F03 to accepted Calm State Hub markers without weakening route recovery coverage.
3. `P1`: update F04-F05 so default access remains explicitly tested as fail-closed; any authorized-content smoke path must receive synthetic authoritative evidence through the accepted contract seam, never through route identity or production fake authority.
4. `P2`: migrate A18-A21 to the supported semantics matcher.

### Product-source candidates

1. `P1`: review A05-A07 and A10-A14 together for logging ownership and data minimization. Removing `print` alone is insufficient if the same unrestricted payload remains in another logger.
2. `P1`: migrate A15-A17 only after verifying the supported LiveKit audio-output APIs preserve intended behavior.
3. `P2`: address A08-A09 as semantics-preserving collection cleanup.
4. `P2`: remove the redundant assertions in A01-A03 without changing Connection authority or terminal-outcome behavior.
5. `P2`: remove A04's unused local.

No product-source repair is recommended for `AppThemeX` on current evidence. Its non-null contract may be reviewed separately only if standalone widget composition becomes a requirement.

## 8. Unresolved items and required evidence

F08-F35 remain unresolved because the durable Track 3 result did not preserve their complete per-test identities and failure messages. Required evidence is one of:

1. the original Track 3 expanded or machine-readable runner transcript tied to accepted commit `38fcbf78fdbb346a6650ca157d650003c920e80b`; or
2. a new Owner-authorized evidence-capture task with an explicit bounded execution budget and output-retention requirement.

File inventory, test names, or current source alone cannot prove which additional cases contributed to `-35`. T04 does not authorize a full-suite rerun to reconstruct that ledger. Until exact evidence exists:

- do not assign those 28 failures to a repair branch;
- do not call them stale, product regressions, fixture defects, or harmless;
- do not infer that `UNRESOLVED` means `ABSENT`;
- do not reopen or re-accept the MVP contract from this uncertainty alone.

## 9. Recommended bounded sequence

Subject to fresh Owner authorization after independent review:

1. Close the evidence-preservation gap for F08-F35 from the original transcript if available; otherwise authorize an exact evidence-capture run before repair planning.
2. Take the isolated AppTheme test-fixture candidate, because it restores two high-value common-state tests without product semantics.
3. Update the five proven stale route/Home/Conversation smoke expectations while preserving fail-closed authority behavior.
4. Review the eight production `print` findings as one logging/data-minimization decision, then the three RTC deprecations as a separate behavior-sensitive migration.
5. Batch only the semantics-preserving P2 hygiene items whose file ownership and verification scope are explicitly authorized.
6. Reassess MVP impact only if an exact unresolved failure contradicts an accepted invariant.

Each step requires its own bounded authority and verification plan. No step is started here.

## 10. Non-goals and stop boundary

No product or test source was modified. No dependency, lockfile, generated output, build configuration, or global tooling/network/proxy/certificate/Browser/model/notification configuration was changed. No repair, full Flutter test/analyzer rerun, dependency restoration, backend/API/database/service work, legal/data-rights work, compatibility cleanup, Phase-2 work, private-data inspection, telemetry execution, Safety Operations, Sandbox, DEP13, B12, M2, or M3 work was performed.

Preserved boundaries include:

- `LOCAL TOOLING BLOCKER != PRODUCT DEFECT`
- `TRANSPORT FAILURE != DOMAIN OUTCOME`
- `UNKNOWN != ABSENT`
- `DEFERRED != MISSING`
- `STATE VOCABULARY != AUTHORITY`
- `ROUTE IDENTITY != CONSENT`
- `CURRENT SOURCE EXISTS != MUST KEEP`
- `Match != Connection != Conversation != Relationship`

Stop after publishing this single result candidate. Do not merge, self-accept, start repairs, or create successor work from this artifact.

## 11. Final classification

`FLUTTER NON-GREEN EVIDENCE TRIAGED — TEST/ANALYZER FINDINGS CLASSIFIED — MVP IMPACT EXPLICIT — NO REPAIRS PERFORMED — READY FOR INDEPENDENT REVIEW / OWNER REPAIR PRIORITIZATION`
