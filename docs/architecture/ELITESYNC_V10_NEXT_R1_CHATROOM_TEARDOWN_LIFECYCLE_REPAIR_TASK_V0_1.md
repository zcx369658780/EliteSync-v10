# EliteSync v10｜NEXT-R1 ChatRoom Teardown Lifecycle Repair Task｜v0.1

Status: `OWNER-AUTHORIZED REPAIR TASK — CHATROOM TEARDOWN LIFECYCLE ONLY — PRESERVE CONVERSATION AUTHORITY SEMANTICS`

Repository: `zcx369658780/EliteSync-v10`

Owner authorization basis: Owner approved the accepted T05-B repair order and authorized R1 first.

Fresh task-publication base:

`4b72dab8cb636cd3dd758a729a6d83bf82c2867a`

Accepted T05-B evidence:

`docs/architecture/ELITESYNC_V10_REMAINING_FLUTTER_FAILURE_EVIDENCE_CAPTURE_RESULT_V0_1.md`

Accepted T05-B acceptance:

`docs/architecture/ELITESYNC_V10_REMAINING_FLUTTER_FAILURE_EVIDENCE_CAPTURE_ACCEPTANCE_V0_1.md`

## 1. Objective

Repair only the shared ChatRoom teardown lifecycle defect underlying current failures C02-C20.

Accepted current root cause:

- `_AuthorizedChatRoomPageState.dispose()` invokes draft persistence;
- draft persistence evaluates send capability through `ref.read(...)` after widget deactivation;
- Riverpod rejects using `ref` when the widget is unmounted/deactivated;
- nineteen current ChatRoom tests fail through this shared teardown path.

The repair must make teardown/draft persistence lifecycle-safe without weakening, bypassing, synthesizing, or reinterpreting Product Conversation authority.

## 2. Required fresh-start gate

Before substantive work:

1. `git fetch origin`.
2. Verify fresh `origin/main`.
3. Read `AGENTS.md` FIRST.
4. Read in order:
   - `docs/architecture/ELITESYNC_V10_MVP_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260913_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_REMAINING_FLUTTER_FAILURE_EVIDENCE_CAPTURE_RESULT_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_REMAINING_FLUTTER_FAILURE_EVIDENCE_CAPTURE_ACCEPTANCE_V0_1.md`
   - this task sheet.
5. If `origin/main` differs from `4b72dab8cb636cd3dd758a729a6d83bf82c2867a`, inspect intervening commits before proceeding. Stop if they materially alter the ChatRoom root cause, Conversation authority semantics, or R1 scope.

No broad repository audit is authorized.

## 3. Binding Conversation invariants

Preserve exactly:

- `Match != Connection != Conversation != Relationship`;
- `ROUTE IDENTITY != CONSENT`;
- `STATE VOCABULARY != AUTHORITY`;
- `UNKNOWN != ABSENT`;
- Product Conversation remains fail-closed unless both authoritative `CN_ACTIVE` and separate authoritative mutual messaging-consent evidence exist;
- `eligibleMatch`, `legacyPeer`, route identity, peer identity, existing rows, unread counts, cached data, or transport state do not create read/send authority;
- private Conversation is not default Match/ranking/training data.

Do not "fix" R1 by making Conversation access more permissive.

## 4. Exact repair scope

Primary authorized product-source file:

`apps/flutter_elitesync_module/lib/features/chat/presentation/pages/chat_room_page.dart`

A narrowly adjacent test-source change is allowed only if required to add/strengthen a regression assertion for the repaired teardown behavior in:

`apps/flutter_elitesync_module/test/features/chat/presentation/pages/chat_room_page_test.dart`

Do not modify any other product or test source unless the exact lifecycle-safe fix is impossible within these two files. If another path is genuinely required, stop and report the required scope expansion instead of editing it.

## 5. Repair requirement

The implementation must remove the invalid teardown-time dependency on live `WidgetRef`/`BuildContext` access.

Acceptable design direction includes preserving the already-authorized send/draft eligibility state while the widget is mounted, then using lifecycle-safe captured state during `dispose()`.

The exact code shape is left to the executor, but the repair must satisfy all of the following:

1. `dispose()` must not call `ref.read`, `ref.watch`, or any equivalent provider read requiring an active mounted widget context.
2. Draft persistence during teardown must remain bounded by the same product-authorized send/draft conditions as before; do not persist or send protected content merely because teardown occurs.
3. The repair must not trigger network send, message mutation, Connection mutation, messaging-consent mutation, or any new authority transition during `dispose()`.
4. No optimistic or synthetic Conversation authority may be introduced.
5. Existing non-teardown behavior must remain unchanged unless an exact lifecycle necessity requires a local refactor.
6. If the safest result is to skip teardown persistence when current authoritative conditions cannot be safely known, preserve fail-closed semantics and document that behavior; do not guess authority.

## 6. Explicit exclusions

Do NOT:

- modify Connection or messaging-consent contracts/providers;
- broaden Conversation read/send authority;
- add local fake consent/authority booleans;
- change Match, Connection, Relationship, notification, Home, privacy, or data-rights semantics;
- repair C01 or C21-C28;
- repair C26 notification composition;
- modify onboarding/settings stale expectations;
- repair analyzer findings A01-A21;
- add/change dependencies or lockfile;
- modify backend/API/database/service code;
- perform legal/data-rights work;
- resume compatibility cleanup or Phase 2;
- resume Sandbox/DEP13/B12/M2/M3;
- change global Flutter/Dart/Gradle/Java/network/proxy/certificate/Browser/model/notification configuration;
- inspect private participant/Conversation runtime data;
- perform telemetry/Safety Operations.

## 7. Verification

Use the smallest verification needed to prove R1.

Required minimum:

1. restore the already-declared package graph only if absent, using the task-authorized locked graph;
2. run the targeted ChatRoom test file:
   `flutter test --no-pub test/features/chat/presentation/pages/chat_room_page_test.dart --reporter expanded`
   (if package graph had to be restored first, ensure `--no-pub` is used for verification);
3. establish that the prior shared teardown `StateError` is absent;
4. report exact passing/failing counts for this file;
5. if any test in the same file remains non-green for a different cause, preserve that evidence instead of widening the repair;
6. run `git diff --check`.

Do not run the full Flutter suite or full analyzer in R1 unless the targeted file cannot establish whether the shared teardown defect is gone. If broader execution appears necessary, stop and report why.

## 8. Required result artifact

Create exactly one result artifact:

`docs/architecture/ELITESYNC_V10_CHATROOM_TEARDOWN_LIFECYCLE_REPAIR_RESULT_V0_1.md`

It must record:

- fresh base and branch;
- exact source/test files changed;
- root cause before repair;
- exact lifecycle-safe repair mechanism;
- proof that Conversation authority semantics were preserved;
- targeted pre/post evidence if available;
- targeted final test count;
- whether the original teardown `StateError` remains anywhere in the targeted run;
- dependency/lockfile disposition;
- diff/scope verification;
- explicitly untouched C01/C21-C28 and analyzer findings;
- final classification.

## 9. Git boundary

Work on a fresh bounded repair branch from the verified main authority.

Recommended branch:

`repair/next-r1-chatroom-teardown-lifecycle-v0-1`

Candidate may contain only:

- the authorized ChatRoom product-source repair;
- optional narrowly necessary ChatRoom regression-test change;
- the required R1 result artifact.

Recommended commit message:

`fix: make ChatRoom teardown lifecycle-safe`

Publish the candidate branch/commit for independent review.

Do not merge or self-accept.

## 10. Completion classification

Successful completion should end substantially as:

`CHATROOM TEARDOWN LIFECYCLE REPAIRED — C02-C20 SHARED RIVERPOD DISPOSE FAILURE REMOVED — CONVERSATION AUTHORITY SEMANTICS PRESERVED — READY FOR INDEPENDENT REVIEW`

If lifecycle-safe repair requires changing Conversation authority semantics, stop instead of proceeding.
