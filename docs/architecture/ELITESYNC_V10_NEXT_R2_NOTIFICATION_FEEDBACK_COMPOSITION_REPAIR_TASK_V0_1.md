# EliteSync v10｜NEXT-R2 Notification Feedback Composition Repair Task｜v0.1

Status: `OWNER-AUTHORIZED BOUNDED REPAIR TASK — C26 ONLY — B01 PRIVACY GATE MUST REMAIN FAIL-CLOSED`

Repository: `zcx369658780/EliteSync-v10`

Owner-authorized sequence: `R1 -> R2 -> R3 -> R4`.

Accepted R1 candidate:

`df1a504dedc8ba0a554ab803f1fba9542163c4be`

R1 acceptance commit before this task:

`dd39fd7283eca64e675a878d77dce2a440b3d8bf`

Accepted T05-B evidence:

`docs/architecture/ELITESYNC_V10_REMAINING_FLUTTER_FAILURE_EVIDENCE_CAPTURE_RESULT_V0_1.md`

## 1. Objective

Repair only current failure C26:

`status author notification fails closed without using payload identity`

The accepted root cause is a notification feedback composition defect:

- the StatusAuthor action correctly remains fail-closed;
- no author route is built;
- no payload identity is granted authority;
- no mark-read succeeds;
- but `AppFeedback.showInfo(...)` attempts `ScaffoldMessenger.showSnackBar` when there is no descendant Material `Scaffold` available to present it.

The repair must make the fail-closed feedback presentation valid without weakening any APP-T12-B01 or notification-privacy boundary.

## 2. Required fresh-start gate

Before substantive work:

1. `git fetch origin`.
2. Verify fresh `origin/main`.
3. Read `AGENTS.md` FIRST.
4. Read, in order:
   - `docs/architecture/ELITESYNC_V10_MVP_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260913_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_REMAINING_FLUTTER_FAILURE_EVIDENCE_CAPTURE_RESULT_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_REMAINING_FLUTTER_FAILURE_EVIDENCE_CAPTURE_ACCEPTANCE_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_CHATROOM_TEARDOWN_LIFECYCLE_REPAIR_ACCEPTANCE_V0_1.md`
   - this task sheet.
5. If `origin/main` differs from `dd39fd7283eca64e675a878d77dce2a440b3d8bf`, inspect intervening commits before proceeding. If they materially alter notification composition, APP-T12-B01, or C26 evidence, stop and report the conflict.

No broad repository audit is authorized.

## 3. Binding privacy and authority boundaries

Preserve exactly:

- `ROUTE IDENTITY != CONSENT`;
- `UNKNOWN != ABSENT`;
- `STATE VOCABULARY != AUTHORITY`;
- notification payload identity != audience authority;
- direct route identity != audience authority;
- generic/privacy-minimal notification presentation remains the default;
- APP-T12-B01 remains `CLOSED`.

For `status_author` specifically, the repaired behavior must still:

- fail closed when audience authority is not established;
- not read payload `user_id`/`name` as authority;
- not navigate to StatusAuthor/profile-like content;
- not trigger author/profile-like provider reads;
- not mark the notification read through a falsely successful open;
- not introduce local consent booleans, fake audience grants, or route-token authority.

## 4. Exact defect in scope

Accepted C26 signature:

`ScaffoldMessenger.showSnackBar was called, but there are currently no descendant Scaffolds to present to.`

Current evidence points to:

- `AppFeedback._show` / `AppFeedback.showInfo`;
- `NotificationCenterPage._openNotification` for `status_author`;
- notification route composition;
- `BrowseScaffold` not providing a Material `Scaffold` at the failing seam.

The task may inspect the minimum directly related files required to determine the smallest safe ownership/composition fix.

## 5. Authorized repair surface

Prefer the smallest repair that fixes C26 without changing unrelated presentation architecture.

Allowed source changes are restricted to the directly implicated notification feedback-composition seam, such as:

- `apps/flutter_elitesync_module/lib/features/notification/presentation/pages/notification_center_page.dart`;
- `apps/flutter_elitesync_module/lib/core/ui/app_feedback.dart` or its actual current path if directly implicated;
- the directly owning scaffold/composition file only if necessary;
- `apps/flutter_elitesync_module/test/features/notification/presentation/pages/notification_center_page_test.dart` only for a narrowly necessary regression assertion, not to weaken expectations.

Do not broaden changes outside the minimum directly implicated seam.

## 6. Repair requirements

The repair must establish all of the following:

1. C26 no longer throws the missing-descendant-Scaffold assertion.
2. The user receives neutral fail-closed feedback substantially equivalent to the accepted message that access authority is not established.
3. `authorRouteBuilt` remains false (or equivalent no-navigation evidence remains true).
4. No payload-derived author/private content is shown.
5. Notification remains unread when the protected action did not successfully open.
6. No profile-like/provider read is introduced before audience authority.
7. No fake authority or consent is added.

Do not solve the defect by:

- navigating anyway;
- marking the item read before successful protected open;
- suppressing the feedback assertion without giving valid feedback;
- exposing raw payload title/name/user ID;
- adding a globally public Profile assumption;
- treating unknown authority as absent user/data.

## 7. Verification boundary

Use targeted TDD/evidence for the notification test surface only.

At minimum run the exact C26 test, or the smallest notification test file that contains it, before and after repair.

If practical within the bounded file, also confirm the existing APP-T12-B01 no-navigation/no-payload-authority assertions remain green.

Do not run the full Flutter suite or full analyzer in this task.

If `.dart_tool/package_config.json` is absent in the fresh bounded worktree, one `flutter pub get --enforce-lockfile` is allowed solely to restore the already-declared locked package graph. Dependency declarations and lockfile must remain unchanged.

## 8. Explicit exclusions

Do NOT:

- repair C01;
- repair C21-C25, C27, or C28;
- revisit R1/ChatRoom;
- repair analyzer A01-A21;
- weaken notification privacy or B01 access gates;
- perform backend/API/database/service work;
- perform legal/data-rights work;
- remove compatibility debt;
- start Phase 2;
- inspect private participant/Profile/Conversation data;
- perform telemetry/Safety Operations;
- resume Sandbox/DEP13/B12/M2/M3;
- change global Flutter/Dart/Gradle/Java/network/proxy/certificate/Browser/model/notification configuration.

## 9. Required result artifact

Create exactly one result artifact:

`docs/architecture/ELITESYNC_V10_NOTIFICATION_FEEDBACK_COMPOSITION_REPAIR_RESULT_V0_1.md`

It must record:

- exact changed files;
- pre-repair failure signature;
- selected repair ownership and why;
- proof that APP-T12-B01 privacy/authority behavior remains unchanged;
- targeted RED/GREEN evidence;
- dependency/lockfile disposition;
- `git diff --check`;
- explicit untouched C01/R3/R4/analyzer items;
- final classification.

## 10. Git boundary

Work on a fresh bounded branch from verified `main`.

Recommended branch:

`repair/next-r2-notification-feedback-composition-v0-1`

Commit only the minimal authorized source/test changes plus the result artifact.

Recommended commit message:

`fix: repair notification fail-closed feedback composition`

Publish the candidate branch/commit for independent review.

Do not merge or self-accept.

## 11. Completion classification

Successful completion should end substantially as:

`NOTIFICATION FAIL-CLOSED FEEDBACK COMPOSITION REPAIRED — C26 GREEN — APP-T12-B01 PRIVACY/AUTHORITY BOUNDARIES PRESERVED — READY FOR INDEPENDENT REVIEW`

Stop after publishing the repair candidate.
