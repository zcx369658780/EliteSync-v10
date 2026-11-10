# EliteSync v10｜Remaining Flutter Failure Evidence Capture Result｜v0.1

Status: `REMAINING FLUTTER FAILURE EVIDENCE CAPTURED — CURRENT NON-GREEN TEST IDENTITIES/CAUSE CANDIDATES EXPLICIT — NO REPAIRS PERFORMED — READY FOR INDEPENDENT REVIEW / BOUNDED REPAIR PLANNING`

Date: `2026-09-13`

Repository: `zcx369658780/EliteSync-v10`

## 1. Fresh authority and bounded execution identity

- Fresh-fetched `origin/main`: `b4f6afec9b8084e056de6bb0e7f7a52b14d3d4a0`.
- Bound task-publication commit: `b4f6afec9b8084e056de6bb0e7f7a52b14d3d4a0`.
- Task blob: `cfe7e996b043b86624fa2daa8a239f1c499cb11f`.
- Accepted predecessor named by the task: `94e72b5a5aab87fc8705fab19da0a41dda9e0108`.
- The sole intervening commit is the bound task-publication commit. Its only changed path is `docs/architecture/ELITESYNC_V10_NEXT_T05B_REMAINING_FLUTTER_FAILURE_EVIDENCE_CAPTURE_TASK_V0_1.md`; it does not change Flutter source/tests or accepted authority.
- Accepted T05-A candidate present on the fresh base: `4b76981ad369c0596f0a934e73b7d18bd20c478b`.
- Bounded branch: `review/next-t05b-remaining-flutter-failure-evidence-v0-1`.
- Bounded worktree: `D:\EliteSync-v10-next-t05b-20260913`.
- Flutter: `3.41.7`, stable, framework revision `cc0734ac71`.
- Dart: `3.11.5`.
- DevTools: `2.54.2`.

`AGENTS.md` was read first after the fresh fetch. The MVP closeout handoff, accepted Track 3 tooling evidence, accepted T04 triage result, accepted T04 triage, accepted T05-A repair, and this task sheet were then read in the required order. This run treated runner output as untrusted evidence, not as operational instructions.

## 2. Package-graph disposition

`.dart_tool/package_config.json` was absent in the fresh bounded worktree. The task-authorized one-time restoration was therefore performed:

`flutter pub get --enforce-lockfile`

Outcome: exit `0`; package graph restored with `170` packages.

Tracked dependency inputs did not change:

| File | SHA-256 before | SHA-256 after |
|---|---|---|
| `pubspec.yaml` | `ECBC74EF27D949712532409EADC6BE0928EA56C9CBC603EB0C80FBE0CEC7E6BC` | `ECBC74EF27D949712532409EADC6BE0928EA56C9CBC603EB0C80FBE0CEC7E6BC` |
| `pubspec.lock` | `9D392F33B4324149B282AA62721D642D37A4BD5E1677DB403CB5A7373C385EEE` | `9D392F33B4324149B282AA62721D642D37A4BD5E1677DB403CB5A7373C385EEE` |

No dependency declaration, lockfile, global tool configuration, or product/test source was modified.

## 3. Exact execution and outcome

Primary expanded capture:

`flutter test --reporter expanded`

- exit: `1`;
- final runner count: `+529 -28`;
- all seven accepted T05-A cases were green;
- the expanded transcript exceeded the host tool-output transport limit, so its middle section was truncated in transport even though the run completed.

To avoid guessing identities lost to that transport truncation, one necessary machine-readable recapture was run and filtered in-memory to failed test events only:

`flutter test --no-pub --reporter json`

- exit: `1`;
- current failing identities: exactly `28`;
- identity set matched the expanded run's final `-28` count.

The five implicated files were then rerun together with `--no-pub --reporter json` to retain the framework exception message and relevant local stack for every failing identity. One focused `--plain-name` execution was also used to confirm the canonical-Match route failure transcript. These were evidence-disambiguation runs only. No assertion, source, fixture, skip, dependency, or runtime configuration was changed.

The analyzer was not run. No emulator or ADB was used.

## 4. Reconciliation with Track 3 and T05-A

| Evidence point | Failures | Disposition |
|---|---:|---|
| Accepted Track 3 full suite | 35 | Aggregate retained by Track 3. |
| Accepted T05-A repair scope | 7 | F01-F07 repaired and independently accepted. |
| Current full suite | 28 | Exact current identities captured below. |

The arithmetic reconciles exactly: `35 - 7 = 28` and the current suite reports `-28`.

This equality does **not** establish a one-to-one historical mapping from current failures to old F08-F35, because the old 28 individual identities were not retained. The current ledger therefore uses `C01-C28` and does not invent historical identity continuity.

The seven T05-A cases no longer fail in the current full suite:

- both invalid-route recovery cases;
- the Home acceptance smoke case;
- both fail-closed Conversation acceptance smoke cases;
- both common presentation-state theme-fixture cases.

No additional claim about which historical F08-F35 instance disappeared or appeared is possible from the retained Track 3 evidence.

## 5. Exact shared failure signatures

### S1 — canonical Match route test synchronization

Exact message:

```text
The following TestFailure was thrown running a test:
Expected: exactly one matching candidate
  Actual: _TypeWidgetFinder:<Found 0 widgets with type "MatchShellPage": []>
   Which: means none were found but one was expected
```

Relevant stack: `test/app/router/first_use_onboarding_router_integration_test.dart:137:7`.

The current route remains declared at `app_router.dart:418-421`, builds `MatchShellPage`, and the Progress entry still calls `context.go(AppRouteNames.progressMatch)` at `progress_page.dart:24-29`. The test performs only one `pump()` after the nested route action, unlike its earlier destination transitions. First-pass classification: `TEST_HARNESS_OR_FIXTURE_DEFECT`; current source does not support a stale route/class expectation or a canonical-Match product regression.

### S2 — ChatRoom teardown reads Riverpod `ref` after unmount

Exact message shared by 19 current cases:

```text
The following StateError was thrown running a test:
Bad state: Using "ref" when a widget is about to or has been unmounted is unsafe.
Ref relies on BuildContext, and BuildContext is unsafe to use when the widget is deactivated.
To safely refer to the state of providers inside State.dispose(), save the provider state in a field
of your State class.
```

Relevant production stack:

```text
_AuthorizedChatRoomPageState._canSend        chat_room_page.dart:122:28
_AuthorizedChatRoomPageState._persistDraftNow chat_room_page.dart:185:10
_AuthorizedChatRoomPageState.dispose          chat_room_page.dart:161:5
```

`dispose()` invokes `_persistDraftNow()`, which evaluates `_canSend` through `ref.read(...)` after deactivation. This is reproducible production-source lifecycle quality debt, not a fabricated consent seam and not evidence that the accepted Conversation gate is too strict. First-pass classification: `SOURCE_QUALITY_DEFECT_NON_PRODUCT_SEMANTIC`.

### S3 — first-use public-copy tuple is stale

Exact mismatch at list location `[4]`:

- expected body: `你可以跳过；之后可在“设置 > 新手引导”重新查看。`
- actual body: `你可以跳过；之后可在“设置 > 新手引导”重新查看。完成本引导不代表账户设置或准备状态已经完成。`

Relevant stack: `test/features/onboarding/presentation/first_use_onboarding_page_test.dart:94:5`. The actual copy is present at `first_use_onboarding_page.dart:45-48` and preserves the accepted distinction between completing an explanation and establishing Readiness/account state. First-pass classification: `STALE_TEST_EXPECTATION`.

### S4 — first-use completion label is stale

Exact finder failures are either:

```text
Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "完成": []>
   Which: means none were found but one was expected
```

or:

```text
The finder "Found 0 widgets with text "完成": []" (used in a call to "tap()") could not find any
matching widgets.
```

Current source renders `完成引导` and exposes the semantic label `完成首次使用引导` at `first_use_onboarding_page.dart:310-321`. First-pass classification: `STALE_TEST_EXPECTATION`.

### S5 — StatusAuthor fail-closed feedback has no descendant Scaffold

Primary exact message:

```text
The following assertion was thrown running a test:
ScaffoldMessenger.showSnackBar was called, but there are currently no descendant Scaffolds to
present to.
'package:flutter/src/material/scaffold.dart':
Failed assertion: line 319 pos 7: '_scaffolds.isNotEmpty'
```

Relevant production stack:

```text
AppFeedback._show                                      app_feedback.dart:37:9
AppFeedback.showInfo                                  app_feedback.dart:19:5
_NotificationCenterPageState._openNotification        notification_center_page.dart:143:19
_NotificationCenterPageState._openAndMarkRead         notification_center_page.dart:205:26
_NotificationCenterPageState._handlePrimaryAction     notification_center_page.dart:221:11
_NotificationCenterPageState._buildNotificationCard  notification_center_page.dart:348:40
```

Relevant test stack: `notification_center_page_test.dart:322:7`. A secondary after-test failure then reports zero widgets with `当前访问权限尚未建立，暂无法打开` at test line `326`.

The production notification route builds `NotificationCenterPage` directly (`app_router.dart:212-215`); that page builds `BrowseScaffold`, which does not create a Material `Scaffold`, while `AppFeedback` requires a descendant Scaffold. The captured run still proves `authorRouteBuilt == false`, no payload-derived author content is shown, and no mark-read succeeds. Thus `ROUTE IDENTITY != CONSENT` and the accepted B01 no-navigation/no-fetch boundary are not contradicted. First-pass classification: `SOURCE_QUALITY_DEFECT_NON_PRODUCT_SEMANTIC`, with a separate bounded production-composition review required before repair.

### S6 — unsupported notification test taps a privacy-sanitized raw title

Exact message:

```text
The finder "Found 0 widgets with text "未知跳转卡片": []" (used in a call to "tap()") could not find any
matching widgets.
```

Relevant stack: `test/features/notification/presentation/pages/notification_center_page_test.dart:897:20`. The page renders `NotificationPrivacyContract.inAppPreviewFor(item)` rather than the raw payload title at `notification_center_page.dart:240-243,281-284`, preserving APP-T09 generic notification presentation. First-pass classification: `STALE_TEST_EXPECTATION`.

## 6. Complete current 28-failure ledger

Each identity below reproduced in the full machine-readable run and the targeted five-file run.

| ID | Exact file and test identity | Declaration / failure stack | Signature | First-pass classification | MVP-invariant impact |
|---|---|---|---|---|---|
| C01 | `test/app/router/first_use_onboarding_router_integration_test.dart` — `authenticated shell reaches four target destinations and Match child` | `:95` / `:137:7` | S1 | `TEST_HARNESS_OR_FIXTURE_DEFECT` | No canonical-Match route regression established; route and builder remain present. |
| C02 | `test/features/chat/presentation/pages/chat_room_page_test.dart` — `unchanged explicit retry reuses the exact client key` | `:317` / S2 production stack | S2 | `SOURCE_QUALITY_DEFECT_NON_PRODUCT_SEMANTIC` | Teardown stability defect; no consent/authority bypass. |
| C03 | same file — `changed payload creates a new client key` | `:338` / S2 production stack | S2 | `SOURCE_QUALITY_DEFECT_NON_PRODUCT_SEMANTIC` | Same. |
| C04 | same file — `payload mismatch blocks unchanged same-key retry` | `:358` / S2 production stack | S2 | `SOURCE_QUALITY_DEFECT_NON_PRODUCT_SEMANTIC` | Same. |
| C05 | same file — `ChatRoomPage hides engineering test messages` | `:380` / S2 production stack | S2 | `SOURCE_QUALITY_DEFECT_NON_PRODUCT_SEMANTIC` | Same. |
| C06 | same file — `ChatRoomPage neutralizes SmokeUser in visible header` | `:482` / S2 production stack | S2 | `SOURCE_QUALITY_DEFECT_NON_PRODUCT_SEMANTIC` | Same. |
| C07 | same file — `ChatRoomPage renders voice rhythm guidance for valid chat` | `:514` / S2 production stack | S2 | `SOURCE_QUALITY_DEFECT_NON_PRODUCT_SEMANTIC` | Same. |
| C08 | same file — `ChatRoomPage renders 5.9 low-pressure opening contract` | `:578` / S2 production stack | S2 | `SOURCE_QUALITY_DEFECT_NON_PRODUCT_SEMANTIC` | Same. |
| C09 | same file — `ChatRoomPage opening suggestions write drafts without sending` | `:632` / S2 production stack | S2 | `SOURCE_QUALITY_DEFECT_NON_PRODUCT_SEMANTIC` | Same. |
| C10 | same file — `ChatRoomPage explains empty chat lifecycle state` | `:682` / S2 production stack | S2 | `SOURCE_QUALITY_DEFECT_NON_PRODUCT_SEMANTIC` | Same. |
| C11 | same file — `ChatRoomPage explains recoverable message loading failure` | `:719` / S2 production stack | S2 | `SOURCE_QUALITY_DEFECT_NON_PRODUCT_SEMANTIC` | Same. |
| C12 | same file — `ChatRoomPage rolls back failed text send and restores a sanitized draft` | `:754` / S2 production stack | S2 | `SOURCE_QUALITY_DEFECT_NON_PRODUCT_SEMANTIC` | Same. |
| C13 | same file — `attachment picker cancel selects nothing and does not fail` | `:852` / S2 production stack | S2 | `SOURCE_QUALITY_DEFECT_NON_PRODUCT_SEMANTIC` | Same. |
| C14 | same file — `attachment picker throw is sanitized and never uploads` | `:875` / S2 production stack | S2 | `SOURCE_QUALITY_DEFECT_NON_PRODUCT_SEMANTIC` | Same. |
| C15 | same file — `attachment upload throw is failed and not send ready` | `:903` / S2 production stack | S2 | `SOURCE_QUALITY_DEFECT_NON_PRODUCT_SEMANTIC` | Same. |
| C16 | same file — `explicit failed metadata is quarantined from manual send` | `:936` / S2 production stack | S2 | `SOURCE_QUALITY_DEFECT_NON_PRODUCT_SEMANTIC` | Same. |
| C17 | same file — `processing attachment remains visible but non-send-ready` | `:978` / S2 production stack | S2 | `SOURCE_QUALITY_DEFECT_NON_PRODUCT_SEMANTIC` | Same. |
| C18 | same file — `known ready fake stays manual and sends only after tap` | `:1009` / S2 production stack | S2 | `SOURCE_QUALITY_DEFECT_NON_PRODUCT_SEMANTIC` | Same. |
| C19 | same file — `video upload failure stays non-ready without success telemetry` | `:1041` / S2 production stack | S2 | `SOURCE_QUALITY_DEFECT_NON_PRODUCT_SEMANTIC` | Same. |
| C20 | same file — `known ready video remains manual until text send` | `:1086` / S2 production stack | S2 | `SOURCE_QUALITY_DEFECT_NON_PRODUCT_SEMANTIC` | Same. |
| C21 | `test/features/onboarding/presentation/first_use_onboarding_page_test.dart` — `the public contract contains exactly five truthful steps` | `:92` / `:94:5` | S3 | `STALE_TEST_EXPECTATION` | Current disclaimer reinforces `STATE VOCABULARY != AUTHORITY`; no product regression. |
| C22 | same file — `finish persists completion and returns to the invoking app` | `:179` / `:200` | S4 | `STALE_TEST_EXPECTATION` | Label-only expectation drift; completion authority is not inferred. |
| C23 | same file — `finish write failure still dismisses automatic flow` | `:208` / `:226:18` | S4 | `STALE_TEST_EXPECTATION` | Same. |
| C24 | same file — `finish write timeout still dismisses automatic flow` | `:234` / `:252:18` | S4 | `STALE_TEST_EXPECTATION` | Same. |
| C25 | same file — `replay finish preserves completion state and returns safely` | `:282` / `:303:18` | S4 | `STALE_TEST_EXPECTATION` | Same. |
| C26 | `test/features/notification/presentation/pages/notification_center_page_test.dart` — `status author notification fails closed without using payload identity` | `:254` / `:322:7`, `:326` | S5 | `SOURCE_QUALITY_DEFECT_NON_PRODUCT_SEMANTIC` | B01 authority boundary remains fail-closed; feedback composition is non-green. |
| C27 | same file — `card tap on unsupported route does not mark notification as read` | `:857` / `:897:20` | S6 | `STALE_TEST_EXPECTATION` | Generic notification privacy remains intact; raw payload title is not display authority. |
| C28 | `test/features/profile/presentation/pages/settings_page_test.dart` — `Settings replay completion returns to canonical Home` | `:467` / `:491:18` | S4 | `STALE_TEST_EXPECTATION` | Label-only expectation drift; canonical Home assertion is not reached, not contradicted. |

## 7. Classification totals

| Classification | Count |
|---|---:|
| `STALE_TEST_EXPECTATION` | 7 |
| `PRODUCT_REGRESSION_CANDIDATE` | 0 |
| `TEST_HARNESS_OR_FIXTURE_DEFECT` | 1 |
| `SOURCE_QUALITY_DEFECT_NON_PRODUCT_SEMANTIC` | 20 |
| `ENVIRONMENT_OR_TOOLING_FAILURE` | 0 |
| `DEPENDENCY_OR_PACKAGE_FAILURE` | 0 |
| `UNRESOLVED` | 0 |
| **Total** | **28** |

`UNRESOLVED = 0` means every current failure has an evidence-backed first-pass class. It does not mean every root cause is repaired, accepted, harmless, or authorized for work.

## 8. MVP-invariant assessment

No current item is classified as `PRODUCT_REGRESSION_CANDIDATE` on this bounded evidence.

- Canonical Match remains routed through `/progress/match`; C01 is a test synchronization failure, not evidence of a removed route or legacy Match restoration.
- C02-C20 expose an invalid teardown-time Riverpod access. They do not show that route identity, `eligibleMatch`, legacy peer identity, an existing row, or transport state creates Conversation read/send authority.
- C21-C25 and C28 are stale copy/label expectations. The current onboarding disclaimer strengthens the distinction between explanatory progress and authoritative Readiness/account state.
- C26 fails after the StatusAuthor action remains closed. No author route is built, no payload identity is displayed as authority, and no notification is marked read. The feedback surface itself is defective.
- C27 expects raw notification title copy that the accepted generic privacy presentation intentionally does not expose.

Preserved boundaries:

- `Match != Connection != Conversation != Relationship`;
- `ROUTE IDENTITY != CONSENT`;
- `UNKNOWN != ABSENT`;
- `STATE VOCABULARY != AUTHORITY`;
- private Conversation is not default Match/ranking/training data;
- generic notification presentation remains the current privacy default.

This evidence does not reopen or re-accept the MVP contract. Any product-regression promotion requires separate review of a candidate that contradicts an accepted invariant.

## 9. Implicated files and areas

| Failure group | Directly implicated areas |
|---|---|
| C01 | `first_use_onboarding_router_integration_test.dart`; Progress navigation timing; `app_router.dart`; `progress_page.dart`; `MatchShellPage`. |
| C02-C20 | `chat_room_page_test.dart`; `_AuthorizedChatRoomPageState.dispose`; draft persistence; `conversationAccessProvider` read timing. |
| C21-C25 | `first_use_onboarding_page_test.dart`; current first-use disclaimer and final action label. |
| C26 | `notification_center_page_test.dart`; `NotificationCenterPage`; `BrowseScaffold`; `AppFeedback`; top-level notification route composition. |
| C27 | `notification_center_page_test.dart`; `NotificationPrivacyContract.inAppPreviewFor`; unsupported-route interaction expectation. |
| C28 | `settings_page_test.dart`; replayed first-use final action label. |

No backend, API, database, service, legal/data-rights, dependency, lockfile, or global-tooling area is implicated by the captured failures.

## 10. Evidence still unresolved

Current failure identity/message/local-stack capture: `NONE`.

The following boundaries remain intentionally unresolved and are not repair work here:

1. Historical one-to-one mapping between C01-C28 and old F08-F35 is unavailable because Track 3 did not retain those identities.
2. C01 requires a separately authorized test-harness repair/verification to prove the minimal synchronization correction; no test was edited here.
3. C02-C20 require a separately authorized product-source lifecycle repair and regression verification; this result does not choose an implementation.
4. C26 requires a separately authorized notification feedback-composition decision/repair; this result does not choose whether ownership belongs to the route, page, scaffold, or feedback component.
5. Analyzer findings A01-A21 were not rerun or reclassified.

## 11. Recommended bounded sequencing

This sequence is advisory only and creates no repair authority:

1. Independently review this evidence candidate.
2. If accepted, isolate C02-C20 as one product-source lifecycle repair candidate because 19 failures share one exact teardown root.
3. Handle C26 separately because changing notification route/scaffold composition can affect navigation and presentation ownership; preserve the accepted B01 privacy gate.
4. Repair C21-C25/C28 and C27 only as bounded stale-test expectation batches; do not weaken current onboarding or notification privacy copy.
5. Handle C01 as a separate test-harness synchronization candidate while preserving canonical `/progress/match` routing.
6. Run the smallest targeted evidence for each authorized repair before any later full-suite confirmation.

## 12. Explicit non-goals and stop boundary

Only this result artifact is created. No product source, test source, dependency declaration, lockfile, generated source, authority/consent gate, global configuration, maintenance setting, Browser/model/notification configuration, backend/API/database/service, legal/data-rights decision, compatibility debt, or Phase-2 surface was changed.

No failure was repaired, skipped, muted, quarantined, suppressed, or reinterpreted as success. No fake Connection/Conversation authority, messaging consent, product theme fallback, emulator/ADB execution, private-data inspection, telemetry/Safety operation, Sandbox/DEP13/B12/M2/M3 work, or analyzer repair was performed.

Stop after publishing this single result candidate. Do not merge, self-accept, begin repair, or create a successor task from this artifact.

## 13. Final classification

`REMAINING FLUTTER FAILURE EVIDENCE CAPTURED — CURRENT NON-GREEN TEST IDENTITIES/CAUSE CANDIDATES EXPLICIT — NO REPAIRS PERFORMED — READY FOR INDEPENDENT REVIEW / BOUNDED REPAIR PLANNING`
