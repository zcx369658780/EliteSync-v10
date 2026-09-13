# EliteSync v10｜ChatRoom Teardown Lifecycle Repair Acceptance｜v0.1

Status: `ACCEPTED — CHATROOM TEARDOWN LIFECYCLE REPAIR VERIFIED — C02-C20 REMOVED — CONVERSATION AUTHORITY SEMANTICS PRESERVED`

Date: 2026-09-13 (Asia/Singapore)

Accepted candidate:

`df1a504dedc8ba0a554ab803f1fba9542163c4be`

Accepted result blob:

`8c52d38ef8078768bfc0771c873bf0075b452816`

Accepted artifact:

`docs/architecture/ELITESYNC_V10_CHATROOM_TEARDOWN_LIFECYCLE_REPAIR_RESULT_V0_1.md`

## 1. Independent acceptance

The R1 candidate is accepted for its authorized purpose.

The actual product-source change is narrowly limited to removing the teardown-time `_persistDraftNow()` call from `_AuthorizedChatRoomPageState.dispose()`.

This directly removes the accepted T05-B root cause in which teardown-time draft persistence evaluated `_canSend` through Riverpod `ref` after widget deactivation.

## 2. Evidence

Targeted ChatRoom evidence moved from:

- RED: `+3 -19`;
- GREEN: `+22 -0`.

The shared Riverpod teardown `StateError` is reduced from 19 occurrences to zero in the authorized targeted test file.

No ChatRoom test source was modified to obtain the green result.

## 3. Authority-semantic preservation

The repair is accepted as lifecycle safety rather than a product-authority change.

It does not change:

- `conversationAccessProvider`;
- Product Connection evidence;
- mutual messaging consent;
- ConversationAccessGate;
- `_canSend`;
- `_persistDraftNow()` authorization checks while mounted;
- read/send authority;
- Connection, Conversation, or Relationship lifecycle semantics.

No cached or synthesized authority was introduced for teardown. When authority can no longer be safely evaluated during disposal, the code does not guess or persist under an unverified grant.

Preserve:

- `Match != Connection != Conversation != Relationship`;
- `ROUTE IDENTITY != CONSENT`;
- `STATE VOCABULARY != AUTHORITY`;
- `UNKNOWN != ABSENT`;
- private Conversation != default Match/ranking/training data.

## 4. Scope

Accepted scope is exactly:

- `apps/flutter_elitesync_module/lib/features/chat/presentation/pages/chat_room_page.dart`;
- the required R1 result artifact.

No dependency, lockfile, test source, global configuration, backend/legal/compatibility/Phase-2/Sandbox work is accepted or authorized by this record.

## 5. Next repair boundary

The next recommended bounded repair remains R2 for C26 notification feedback composition.

R2 must preserve the already accepted APP-T12-B01 boundaries:

- StatusAuthor access remains fail-closed without audience authority;
- payload identity does not create audience authority;
- route identity does not create consent;
- no author/profile-like read occurs before authority;
- failed-open feedback must not be implemented by weakening privacy gates or marking the notification read.

## 6. Final classification

`R1 ACCEPTED — CHATROOM TEARDOWN LIFECYCLE REPAIRED — C02-C20 TARGETED EVIDENCE GREEN — CONVERSATION AUTHORITY SEMANTICS PRESERVED`
