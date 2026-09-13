# EliteSync v10｜ChatRoom Teardown Lifecycle Repair Result｜v0.1

Status: `CHATROOM TEARDOWN LIFECYCLE REPAIRED — C02-C20 SHARED RIVERPOD DISPOSE FAILURE REMOVED — CONVERSATION AUTHORITY SEMANTICS PRESERVED — READY FOR INDEPENDENT REVIEW`

Date: `2026-09-13`

Repository: `zcx369658780/EliteSync-v10`

## 1. Fresh authority and bounded branch

- Fresh-fetched `origin/main`: `fdeb8136088c8067cbf6e87b383092243b7f92a2`.
- Bound task-publication commit: `fdeb8136088c8067cbf6e87b383092243b7f92a2`.
- Task blob: `ed607e6188abb979e0adb546ddbaeaae13c11743`.
- Task-named fresh publication base: `4b72dab8cb636cd3dd758a729a6d83bf82c2867a`.
- The sole intervening commit is `fdeb8136088c8067cbf6e87b383092243b7f92a2`, which adds only the R1 task sheet and does not alter ChatRoom source, tests, Conversation authority, or R1 scope.
- Accepted T05-B evidence candidate: `9f05818ea844c5cbf2f03199580de86bb7a300bd`.
- Bounded branch: `repair/next-r1-chatroom-teardown-lifecycle-v0-1`.
- Bounded worktree: `D:\EliteSync-v10-next-r1-20260913`.

`AGENTS.md` was read first after the fresh fetch. The MVP closeout handoff, accepted T05-B result, accepted T05-B acceptance, and this task sheet were then read in the required order.

## 2. Exact files changed

Product source:

- `apps/flutter_elitesync_module/lib/features/chat/presentation/pages/chat_room_page.dart`

Required result artifact:

- `docs/architecture/ELITESYNC_V10_CHATROOM_TEARDOWN_LIFECYCLE_REPAIR_RESULT_V0_1.md`

`apps/flutter_elitesync_module/test/features/chat/presentation/pages/chat_room_page_test.dart` was not changed. Its existing 19 failing widget cases already formed direct RED regression coverage for the shared defect; adding or weakening test expectations was unnecessary.

No other product or test source was changed.

## 3. Root cause before repair

The accepted T05-B root cause reproduced exactly in the bounded worktree:

1. `_AuthorizedChatRoomPageState.dispose()` called `_persistDraftNow()`.
2. `_persistDraftNow()` evaluated `_canSend`.
3. `_canSend` called `ref.read(conversationAccessProvider)` after the `ConsumerState` had been deactivated.
4. Riverpod raised:

```text
Bad state: Using "ref" when a widget is about to or has been unmounted is unsafe.
```

The relevant pre-repair stack was:

```text
_AuthorizedChatRoomPageState._canSend          chat_room_page.dart:122:28
_AuthorizedChatRoomPageState._persistDraftNow chat_room_page.dart:185:10
_AuthorizedChatRoomPageState.dispose           chat_room_page.dart:161:5
```

All C02-C20 failures shared this teardown path.

## 4. Lifecycle-safe repair mechanism

The repair removes the teardown call to `_persistDraftNow()`.

Draft persistence remains available only through the existing mounted-widget debounce path:

- `_onDraftChanged()` cancels the prior timer;
- it schedules `_persistDraftNow()` after `220ms` while the widget is active;
- `_persistDraftNow()` still checks the live authoritative `_canSend` gate before any local draft write or removal.

During `dispose()` the pending debounce is cancelled, realtime synchronization is stopped, and controllers are disposed. No provider read and no draft persistence is attempted after deactivation.

This intentionally chooses the task-authorized fail-closed behavior: if the current Conversation authority cannot be safely read at teardown, the last sub-220ms draft change is not persisted. The repair does not cache or guess potentially revoked authority and does not introduce any local consent/authority boolean.

## 5. Conversation authority preservation

The repair does not change:

- `conversationAccessProvider`;
- `ConversationAccessSnapshot`;
- `ConversationAccessGate`;
- Product Connection evidence;
- mutual messaging-consent evidence;
- `_canAccessConversation` or `_canSend`;
- the `_persistDraftNow()` authorization check;
- any read/send, Connection, consent, lifecycle, or mutation transition.

Static post-repair assertions establish:

- `dispose()` contains no `ref.read`, `ref.watch`, `ref.listen`, or equivalent provider access;
- `dispose()` does not call `_persistDraftNow()`;
- `ChatRoomPage` still watches `conversationAccessProvider` and passes its snapshot into `ConversationAccessGate`;
- `_persistDraftNow()` still returns immediately when `_canSend` is false;
- no network send or product mutation was added to teardown.

Preserved invariants:

- `Match != Connection != Conversation != Relationship`;
- `ROUTE IDENTITY != CONSENT`;
- `STATE VOCABULARY != AUTHORITY`;
- `UNKNOWN != ABSENT`;
- Product Conversation remains fail-closed unless authoritative `CN_ACTIVE` and separate authoritative mutual messaging consent are both established;
- route, peer, legacy, cache, row, unread, or transport identity creates no read/send authority;
- private Conversation is not default Match/ranking/training data.

## 6. Targeted RED/GREEN evidence

Exact required command before and after the source repair:

`flutter test --no-pub test/features/chat/presentation/pages/chat_room_page_test.dart --reporter expanded`

| Point | Exit | Passing | Failing | Shared teardown `StateError` |
|---|---:|---:|---:|---:|
| Pre-repair RED | `1` | `3` | `19` | present in all 19 C02-C20 cases |
| Post-repair GREEN | `0` | `22` | `0` | absent (`0`) |

The final targeted output ended with `+22: All tests passed!`.

No other ChatRoom failure remained for a different cause. The full Flutter suite and analyzer were not run because the exact task-authorized ChatRoom file established removal of the shared defect.

## 7. Package graph and dependency disposition

`.dart_tool/package_config.json` was absent in the fresh bounded worktree. The task-authorized locked restoration was run once:

`flutter pub get --enforce-lockfile`

Outcome: exit `0`; package graph restored with `170` packages.

Tracked dependency inputs remained byte-identical:

| File | SHA-256 before | SHA-256 after |
|---|---|---|
| `pubspec.yaml` | `ECBC74EF27D949712532409EADC6BE0928EA56C9CBC603EB0C80FBE0CEC7E6BC` | `ECBC74EF27D949712532409EADC6BE0928EA56C9CBC603EB0C80FBE0CEC7E6BC` |
| `pubspec.lock` | `9D392F33B4324149B282AA62721D642D37A4BD5E1677DB403CB5A7373C385EEE` | `9D392F33B4324149B282AA62721D642D37A4BD5E1677DB403CB5A7373C385EEE` |

No dependency or lockfile was added or changed.

## 8. Diff and scope verification

- `git diff --check`: `PASS`.
- Candidate scope is limited to the ChatRoom source repair and this required result artifact.
- Test source is unchanged.
- No authority/consent contract or provider is changed.
- No generated source or global configuration is changed.

## 9. Explicitly untouched findings and exclusions

This repair does not address:

- C01 canonical Match test synchronization;
- C21-C25 onboarding stale expectations;
- C26 notification feedback composition;
- C27 privacy-sanitized notification-title expectation;
- C28 Settings replay stale expectation;
- analyzer findings A01-A21.

It performs no backend/API/database/service work, legal/data-rights work, compatibility cleanup, Phase-2 work, emulator/ADB execution, private-data access, telemetry/Safety operation, Sandbox/DEP13/B12/M2/M3 work, or global Flutter/Dart/Gradle/Java/network/proxy/certificate/Browser/model/notification configuration change.

## 10. Stop boundary

Stop after publishing this repair candidate. Do not merge, self-accept, repair another current failure, run the full suite/analyzer, or start a successor task.

## 11. Final classification

`CHATROOM TEARDOWN LIFECYCLE REPAIRED — C02-C20 SHARED RIVERPOD DISPOSE FAILURE REMOVED — CONVERSATION AUTHORITY SEMANTICS PRESERVED — READY FOR INDEPENDENT REVIEW`
