# EliteSync v10｜Android Studio Emulator Home Semantics Source-Locator Review Acceptance｜v0.1

Status: `ACCEPTED — HOME SEMANTICS SOURCE OWNERSHIP LOCATED — TWO BOUNDED REMEDIATION CONTRACTS AUTHORABLE — NEXT BOUNDED IMPLEMENTATION AUTHORIZED — SANDBOX DEP13 REMAINS UNRESOLVED`

Date: 2026-09-12 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Independent acceptance authority

Acceptance-base `main`:

`f1f24c72f0a91cf39eb82478ea4f5f92e57b5ec1`

Accepted candidate:

- branch: `review/android-studio-emulator-home-semantics-source-locator-review-v0-1`
- commit: `81577e3e1b900b5a70e732e4aefc7bd4c180c7a1`
- sole parent: `f1f24c72f0a91cf39eb82478ea4f5f92e57b5ec1`
- tree: `3cf0646cd42cff430d2acc5f49ec523098dfb622`
- result path: `docs/architecture/ELITESYNC_V10_ANDROID_STUDIO_EMULATOR_HOME_SEMANTICS_SOURCE_LOCATOR_REVIEW_RESULT_V0_1.md`
- result blob: `dddd1627ceabff8c8300fb266c3b6b6120ad803c`
- reported blob SHA-256: `BA3D6098F8DFA2E0966028C828E0CE7FD1C8D90CD71F18E6824562620A12714B`

FIRST handoff remains:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`

required blob:

`3aa2ead4cf1084b202b67856075c26ab80b0c9a2`

## 2. Independent source verification

The accepted result's source ownership chain was independently checked against exact current-authority files.

Verified identities:

- `apps/flutter_elitesync_module/lib/features/home/presentation/pages/home_page.dart`
  - blob `6787ac9e56e3eaec87a98a9e901184c426d5b2db`
  - uniquely owns `首页`, `从这里查看慢约进展。`, and `查看慢约进展` in the current Home surface.
- `apps/flutter_elitesync_module/lib/app/router/app_shell.dart`
  - blob `2f1d4933fd4fb928afed77f98e84d7cb6021dbf8`
  - exposes `HomePage`, owns current navigation index, passes that index to `FloatingDockBottomBar`, and uses `Scaffold(extendBody: true)`.
- `apps/flutter_elitesync_module/lib/design_system/components/brand/floating_dock_bottom_bar.dart`
  - blob `edd3b5fb05ac254a1c7227b53a93a4eeae19a046`
  - `_DockItem.selected` controls visible icon/color/background/shadow/font-weight state, while the `InkWell`/child tree does not explicitly expose selected semantics.
- `apps/flutter_elitesync_module/lib/design_system/components/layout/browse_scaffold.dart`
  - blob `1498dc40aca04e87b002128be4f66d6233b4dcd3`
  - outermost `GestureDetector` uses `HitTestBehavior.translucent`, has a non-null `onTap`, and wraps the full Home content subtree.

The source ownership is therefore sufficiently unique for bounded remediation.

## 3. Accepted causal classifications

### `HOME-SEM-SELECTED-01`

Accepted classification:

`SOURCE CAUSE ESTABLISHED`

The source explicitly maintains a visual `selected` state but does not explicitly expose the same selected state through a coherent navigation-item semantics node. This directly explains the accepted source/capture mismatch without making any unsupported TalkBack speech/focus claim.

### `HOME-SEM-FULLSCREEN-CLICK-01`

Accepted classification:

`SOURCE CONTRIBUTION ESTABLISHED BUT RUNTIME PROJECTION NOT FULLY PROVEN`

The full-body utility `GestureDetector` and extended-body shell are a concrete source contribution and change surface consistent with the captured full-viewport actionable node. Exact Flutter semantics merging/bounds projection remains a runtime/framework fact to be validated after remediation rather than treated as fully source-proven.

## 4. Accepted remediation contracts

### A. Bottom-navigation selected semantics

Authorized change surface:

`apps/flutter_elitesync_module/lib/design_system/components/brand/floating_dock_bottom_bar.dart`

Required outcome:

- each dock item exposes one coherent semantics node containing its label and selected state;
- the item where `i == currentIndex` exposes selected true;
- other items expose selected false;
- routing, tap behavior, active/inactive icons, visible labels, colors, pill background, shadow, dimensions, item order, and Home visual appearance remain unchanged.

### B. Full-screen utility gesture semantics

Authorized change surface:

`apps/flutter_elitesync_module/lib/design_system/components/layout/browse_scaffold.dart`

Required outcome:

- preserve background tap-to-unfocus behavior and needed translucent hit-testing behavior;
- prevent that utility gesture from exposing one full-screen clickable/focusable semantics node that merges the Home title/subtitle;
- preserve Home layout, safe-area/padding, colors, title/subtitle/button rendering, button action, floating dock, and `Scaffold.extendBody` visual behavior.

The implementer may choose the smallest framework-supported implementation satisfying these outcomes. This acceptance does not preselect exact patch syntax.

## 5. Implementation and validation authority

One bounded remediation implementation task may now be published automatically.

Implementation authority is limited to:

- the two authorized source files above;
- directly focused Flutter test files needed to prove only these two semantic outcomes;
- no unrelated source refactor.

Validation may include:

1. focused local Flutter widget/semantics tests using already-installed/local dependencies only;
2. one offline Flutter AAR + Android debug APK rebuild if required to install the changed app;
3. install onto the existing authorized `elitesync_api36` AVD only;
4. Home-only cold launch / screenshot / hierarchy capture;
5. verify visually selected Home is represented as selected in hierarchy while the other four items are not selected;
6. verify the prior full-viewport Home-content clickable/focusable node is absent while Home title/subtitle/progress button remain meaningfully represented;
7. verify no visual regression on the Home first frame and target PID remains alive with bounded fatal diagnostics.

No navigation to `发现`, `匹配`, `消息`, `我的`, or `查看慢约进展` destination is authorized for this remediation validation.

## 6. Preserved boundaries

No Backend/Database/PUI behavior, login/private data, participant workflows, telemetry/analytics, production behavior, README/FD02, broad source archaeology, dependency acquisition, or broad QA is authorized.

Remain unchanged:

`FAILED_START_RESULT_NOT_CAPTURED`

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

Accepted B R4 share-success fact remains valid. Sandbox DEP13 remains unresolved and blocked. Emulator evidence remains a separate local development/test evidence class.

Preserve D-02 durable UNKNOWN, U-14 exclusion, U-12 exact-scope rules, `TP-SOURCE-CLASS-01`, `TP-TARGET-01`, Backend/Database/PUI boundaries, README exhausted, FD02 excluded, protected-index boundary, accepted legal/Safety/no-processing boundaries, and no LC-03/LC-04/Phase36 authority unless separately reauthorized.

B12 remains NOT AUTHORIZED. M2 remains separate and NOT automatically authorized.

## 7. Acceptance result

`ACCEPT — HOME SEMANTICS SOURCE OWNERSHIP UNIQUELY LOCATED — HOME-SEM-SELECTED-01 SOURCE CAUSE ESTABLISHED — HOME-SEM-FULLSCREEN-CLICK-01 SOURCE CONTRIBUTION ESTABLISHED — TWO BOUNDED REMEDIATION CONTRACTS AUTHORABLE — PUBLISH BOUNDED IMPLEMENTATION TASK`
