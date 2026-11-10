# EliteSync v10｜Deterministic Test Debt Repair Result｜v0.1

Status: `DETERMINISTIC FLUTTER TEST DEBT REPAIRED — F01-F07 TARGETED EVIDENCE GREEN — NO PRODUCT SOURCE OR AUTHORITY SEMANTICS CHANGED — READY FOR INDEPENDENT REVIEW`

Date: `2026-09-13`

Repository: `zcx369658780/EliteSync-v10`

## 1. Fresh authority and task base

- Fresh-fetched `origin/main`: `0aa5ab44e2a998d5054a3f705411674db5b69bbb`.
- Bound task-publication commit: `0aa5ab44e2a998d5054a3f705411674db5b69bbb`.
- Task blob: `437c89925b9c89d9f0b80beca87520da14c33775`.
- Task-named publication authority: `20dba4fc75cbec2bcefd87c5954b8a3c9cf8136f`.
- The sole intervening commit adds only the T05A task sheet; it does not alter F01-F07 or accepted product contracts.
- Bounded branch: `repair/next-t05a-deterministic-test-debt-v0-1`.
- Bounded worktree: `D:\EliteSync-v10-next-t05a-20260913`.

`AGENTS.md` was read first. The MVP closeout handoff, accepted Track 3 acceptance, accepted T04 triage result, accepted T04 acceptance, and this task sheet were then read in the required order.

## 2. Exact changed test files

Only these three test-source files were changed:

1. `apps/flutter_elitesync_module/test/app/router/invalid_route_recovery_test.dart`
2. `apps/flutter_elitesync_module/test/features/acceptance_smoke_test.dart`
3. `apps/flutter_elitesync_module/test/shared/presentation_state/app_presentation_state_view_test.dart`

The only additional candidate path is this required result artifact.

No `lib/**`, product authority gate, dependency declaration, lockfile, generated source, build/configuration source, backend source, or global configuration was modified.

## 3. Per-ID repair record

| T04 ID | Repair performed | Preserved behavior/boundary |
|---|---|---|
| F01 | Replaced the superseded post-`返回首页` text assertion with the accepted Calm State Hub area keys `home-area-current-state` and `home-area-next-decision`. | The invalid-initial-route recovery action is still exercised before Home is asserted. |
| F02 | Replaced the superseded initial/post-back Home text assertions with the same two accepted Calm State Hub area keys. | The pushed invalid route and `返回上一页` navigation remain exercised. |
| F03 | Renamed the smoke case around the accepted Calm State Hub and asserted `home-area-current-state`, `home-area-next-decision`, and `home-primary-next-decision`. | No Home production source or lifecycle semantics changed. |
| F04 | Changed the Conversation-list smoke case from expecting mock private rows to expecting `消息权限尚未建立`, with peer names and `ConversationListItem` absent. | Default Conversation access remains fail-closed when authoritative Connection plus mutual messaging consent are absent. |
| F05 | Kept `ChatRouteState.legacyPeer` as input but changed the room smoke case to require the locked message-authority presentation and absence of peer title, attachment picker, and Safety menu. | `legacyPeer` route identity remains insufficient to authorize private content or operations. No authority/consent provider override or authoritative evidence was added. |
| F06 | Mounted the stale-state test under `AppTheme.light`. | Original stale marker, non-authoritative disclaimer, last-known-content visibility, and read-only retry assertions remain unchanged. |
| F07 | Mounted the authority-not-established test under `AppTheme.light`. | Original authority-not-established and protected-content-hidden assertions remain unchanged. No product theme fallback was added. |

## 4. Package-graph state

The fresh bounded worktree did not contain `.dart_tool/package_config.json`, so the task-authorized command was run once before tests:

```text
flutter pub get --enforce-lockfile
```

Result: exit `0`; package graph established.

The first pre-repair targeted `flutter test` command was invoked without `--no-pub`, so Flutter also performed its normal automatic locked dependency check and reported `Got dependencies!`. All remaining targeted commands used `--no-pub`. Neither operation changed tracked dependency input.

Final SHA-256 values:

- `pubspec.yaml`: `ECBC74EF27D949712532409EADC6BE0928EA56C9CBC603EB0C80FBE0CEC7E6BC`
- `pubspec.lock`: `9D392F33B4324149B282AA62721D642D37A4BD5E1677DB403CB5A7373C385EEE`
- `.dart_tool/package_config.json`: `A0397A29C470252B6DBA62E8E8D3D341209A93944DEBF6B666FCF70917882CA1`

The manifest and lockfile hashes match their pre-restoration values. Generated `.dart_tool` state is not a candidate deliverable.

## 5. Targeted pre/post verification

No full Flutter suite or full analyzer was run.

| Authorized file | Pre-repair targeted result | Post-repair targeted result |
|---|---|---|
| `test/app/router/invalid_route_recovery_test.dart` | `flutter test test/app/router/invalid_route_recovery_test.dart --reporter expanded`: exit `1`, `+0 -2`; both cases failed on superseded `查看慢约进展` expectations. | `flutter test --no-pub test/app/router/invalid_route_recovery_test.dart --reporter expanded`: exit `0`, `+2`; all tests passed. |
| `test/features/acceptance_smoke_test.dart` | `flutter test --no-pub test/features/acceptance_smoke_test.dart --reporter expanded`: exit `1`, `+0 -3`; failures were the old Home marker and unauthorized private Conversation expectations. | Same exact targeted command after edits: exit `0`, `+3`; all tests passed. |
| `test/shared/presentation_state/app_presentation_state_view_test.dart` | `flutter test --no-pub test/shared/presentation_state/app_presentation_state_view_test.dart --reporter expanded`: exit `1`, `+0 -2`; both cases hit the missing-`AppThemeTokens` null check under bare `MaterialApp`. | Same exact targeted command after edits: exit `0`, `+2`; all tests passed. |

Aggregate authorized evidence moved from `0/7` passing to `7/7` passing.

## 6. Scope and invariant verification

Bounded static assertions established:

- no `conversationAccessProvider` override was added;
- no `ConversationAccessSnapshot.authoritative`, authoritative `ProductConnectionEvidence`, or authoritative `MessagingConsentEvidence` was added;
- the changed Chat test retains `legacyPeer` and proves that identity alone leaves protected content and actions closed;
- no production theme fallback was added;
- no tracked dependency or lockfile change was produced;
- before adding this report, tracked diff contained exactly the three authorized test files.

Preserved invariants include:

- `Match != Connection != Conversation != Relationship`
- `STATE VOCABULARY != AUTHORITY`
- `ROUTE IDENTITY != CONSENT`
- `UNKNOWN != ABSENT`
- `LOCAL TOOLING BLOCKER != PRODUCT DEFECT`
- private Conversation != default Match/ranking/training data

## 7. Diff and blocked-target status

- `git diff --check`: `PASS` after the test edits.
- Remaining blocked F01-F07 target: `NONE`.
- Product-source change required: `NO`.
- Full analyzer: not run and not required by T05A.
- Emulator/ADB: not run.

Final candidate scope verification must contain exactly the three test files in section 2 plus this result artifact.

## 8. Explicitly untouched findings and exclusions

F08-F35 remain exactly as the accepted T04 `UNRESOLVED` register; they were not executed for repair, changed, reclassified, or guessed. Analyzer findings A01-A21 were not changed or silenced. In particular, this task did not touch logging/data-minimization findings, deprecated RTC APIs, or deprecated semantics matchers.

No backend/API/database/service, legal/data-rights, compatibility, Phase-2, private-data, telemetry, Safety Operations, Sandbox, DEP13, B12, M2, or M3 work was performed. No global Flutter/Dart/Gradle/Java/network/proxy/certificate/Browser/model/notification configuration was changed.

## 9. Final classification

`DETERMINISTIC FLUTTER TEST DEBT REPAIRED — F01-F07 TARGETED EVIDENCE GREEN — NO PRODUCT SOURCE OR AUTHORITY SEMANTICS CHANGED — READY FOR INDEPENDENT REVIEW`
