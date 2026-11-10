# EliteSync v10｜Android Studio Emulator Home Semantics Bounded Remediation Implementation Task｜v0.1

Status: `PUBLISHED TASK SHEET — OWNER-BOUNDED HOME SEMANTICS IMPLEMENTATION — TWO ACCEPTED FINDINGS ONLY — FOCUSED TESTS + HOME-ONLY EMULATOR VALIDATION — SANDBOX DEP13 REMAINS UNRESOLVED`

Date: 2026-09-12 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Publication authority

Publication-base `main`:

`7537c5a87f1dffb70c695d3bd0df0b3fbd918ed1`

FIRST handoff:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`

required blob:

`3aa2ead4cf1084b202b67856075c26ab80b0c9a2`

Accepted source-locator/remediation acceptance:

`docs/architecture/ELITESYNC_V10_ANDROID_STUDIO_EMULATOR_HOME_SEMANTICS_SOURCE_LOCATOR_REVIEW_ACCEPTANCE_V0_1.md`

Accepted source-locator candidate/result:

- candidate commit: `81577e3e1b900b5a70e732e4aefc7bd4c180c7a1`
- result blob: `dddd1627ceabff8c8300fb266c3b6b6120ad803c`
- findings: `HOME-SEM-SELECTED-01`, `HOME-SEM-FULLSCREEN-CLICK-01`

This task is the explicit bounded implementation authority for those two findings only. It does not authorize broad implementation.

## 2. Sole objective

Implement the smallest framework-supported remediation that satisfies both accepted contracts:

1. expose coherent bottom-navigation label + selected semantics so Home selected state follows `currentIndex`;
2. preserve `BrowseScaffold` background tap-to-unfocus behavior while preventing that utility gesture from producing a full-screen clickable/focusable semantics node that merges Home title/subtitle.

Then prove both outcomes with focused tests and one Home-only emulator validation.

## 3. Startup authority gate

Activation prompt MUST provide:

- `REQUIRED_MAIN` = commit publishing this task;
- `REQUIRED_TASK_BLOB` = exact blob of this task.

Startup sequence:

1. fresh-fetch remote `main`;
2. require `main == REQUIRED_MAIN`, else `STOP — MAIN_AUTHORITY_CHANGED`;
3. read FIRST and require blob `3aa2ead4cf1084b202b67856075c26ab80b0c9a2`;
4. read this task and require `REQUIRED_TASK_BLOB`;
5. read the source-locator/remediation acceptance named in §1;
6. read the accepted source-locator result only as needed for the exact contract;
7. do not use conversation/project memory as execution authority.

No default `git status`; do not inspect protected staged/index state.

## 4. Exact source identity gates

Before editing, require these current-main source blobs exactly:

### Dock renderer

Path:

`apps/flutter_elitesync_module/lib/design_system/components/brand/floating_dock_bottom_bar.dart`

Required pre-change blob:

`edd3b5fb05ac254a1c7227b53a93a4eeae19a046`

### BrowseScaffold

Path:

`apps/flutter_elitesync_module/lib/design_system/components/layout/browse_scaffold.dart`

Required pre-change blob:

`1498dc40aca04e87b002128be4f66d6233b4dcd3`

Context-only ownership files may be read but MUST NOT be modified:

- `apps/flutter_elitesync_module/lib/app/router/app_shell.dart` blob `2f1d4933fd4fb928afed77f98e84d7cb6021dbf8`
- `apps/flutter_elitesync_module/lib/features/home/presentation/pages/home_page.dart` blob `6787ac9e56e3eaec87a98a9e901184c426d5b2db`

If either editable source blob differs, stop with:

`HOME_SEMANTICS_IMPLEMENTATION_SOURCE_IDENTITY_CHANGED`

Do not port the patch onto changed source by inference.

## 5. Authorized implementation scope

Implementation changes are allowed only in these two product source files:

1. `apps/flutter_elitesync_module/lib/design_system/components/brand/floating_dock_bottom_bar.dart`
2. `apps/flutter_elitesync_module/lib/design_system/components/layout/browse_scaffold.dart`

Directly focused tests may be added or modified only under the Flutter module's test tree and only for the two exact semantics contracts. Preferred dedicated paths are:

- `apps/flutter_elitesync_module/test/design_system/components/floating_dock_bottom_bar_semantics_test.dart`
- `apps/flutter_elitesync_module/test/design_system/components/browse_scaffold_semantics_test.dart`

If an already-existing directly matching test file is discovered by exact component name while opening the test tree entry needed for these tests, it may be modified instead of creating the preferred file. Do not broaden into unrelated tests.

No other product source file may be modified.

## 6. Contract A — `HOME-SEM-SELECTED-01`

Required outcome:

- each dock item exposes one coherent accessibility semantics node carrying its visible label and selected state;
- item `i == currentIndex` exposes selected true;
- all other items expose selected false;
- avoid duplicate spoken labels caused by both an outer explicit semantics node and unexcluded descendant semantics;
- preserve exactly the existing routing callback and one-tap behavior;
- preserve icons, labels, colors, pill background, shadow, dimensions, order, animation, and visual selected treatment.

The smallest appropriate Flutter semantics construct should be used. Do not redesign the dock.

Focused test must establish at least:

- five item labels remain discoverable;
- exactly the expected current item is semantically selected;
- changing `currentIndex` changes the semantic selected item without changing item count/order;
- tap callback behavior for a representative item remains intact.

## 7. Contract B — `HOME-SEM-FULLSCREEN-CLICK-01`

Required outcome:

- preserve the existing background tap utility that unfocuses a focused child;
- preserve `HitTestBehavior.translucent` or demonstrably equivalent current hit-test behavior needed for background taps;
- prevent the utility gesture itself from contributing a clickable/focusable full-body semantics action/node;
- preserve child semantics so Home title/subtitle and button semantics remain available through their actual child widgets;
- do not alter layout, safe area, padding, colors, Home content, or button action.

The smallest appropriate Flutter gesture/semantics configuration should be used. Do not remove background tap-to-unfocus behavior as a workaround.

Focused test must establish at least:

- a focused child is still unfocused by an appropriate background tap;
- BrowseScaffold's utility gesture does not expose an independent full-surface tap semantics action;
- representative child semantics remain present.

## 8. Local test/build rules

All validation must use already-installed/local tool state.

Authorized before emulator validation:

1. run only the directly focused Flutter test files for Contract A and Contract B;
2. if needed for test package state, `flutter pub get --offline` is authorized only inside `apps/flutter_elitesync_module`;
3. no network dependency acquisition;
4. if any command attempts or requires network acquisition, stop with `HOME_SEMANTICS_LOCAL_DEPENDENCY_STATE_INSUFFICIENT`.

Do not run broad/full-suite tests merely for completeness.

## 9. Bounded offline build/install authority

If focused tests pass, one bounded changed-app build/install path is authorized using the previously established local route:

1. Flutter release AAR build, offline/local-only;
2. Android host debug APK build, offline/local-only, preserving the existing C2 local build define/ABI path used by the accepted emulator route;
3. compute new APK SHA-256;
4. use only existing AVD `elitesync_api36` / API 36 / Android 16 / x86_64;
5. if it is not running, start exactly that existing AVD once; do not create/edit/reset/wipe it;
6. install the newly built debug APK once;
7. do not navigate to any destination beyond Home.

No SDK/system-image/dependency download is authorized.

## 10. Home-only post-change runtime validation

After install:

1. force-stop only `com.elitesync` if needed for a clean Home cold launch;
2. launch exactly `com.elitesync/.MainActivity` once;
3. wait a short deterministic stabilization window;
4. verify PID alive and MainActivity top-resumed;
5. capture exactly one post-remediation Home screenshot;
6. capture exactly one post-remediation Home UI hierarchy;
7. collect bounded target-PID fatal diagnostics;
8. perform no destination navigation and no additional UI interaction unless one single background tap on non-control empty Home space is strictly required to validate focus-dismissal after arranging a non-private local focus state through the focused widget test instead; prefer no runtime tap.

Required runtime checks from the hierarchy/screenshot:

### Contract A runtime check

- Home remains visibly selected with the same visual treatment;
- hierarchy exposes Home selected true;
- `发现`, `匹配`, `消息`, `我的` expose selected false;
- labels remain present;
- no duplicate navigation-item semantics nodes are introduced.

### Contract B runtime check

- no clickable/focusable node labeled with the Home title/subtitle spans the full `1080x2400` viewport;
- Home title/subtitle remain represented meaningfully in hierarchy;
- progress button remains represented as its own actionable node;
- no visible Home first-frame clipping/overlap/regression compared with the accepted baseline at the same viewport.

Do not claim TalkBack speech/traversal behavior beyond captured hierarchy evidence.

## 11. Prohibited actions

Do NOT:

- modify `app_shell.dart`, `home_page.dart`, routes, feature/business logic, providers, Backend/Database/PUI code, production configuration, or unrelated design-system source;
- navigate to `发现`, `匹配`, `消息`, `我的`, or `查看慢约进展` destination;
- log in, enter private/user/participant data, inspect private app storage, inspect private Conversation data, or configure telemetry/analytics;
- perform broad QA;
- run broad repo searches/history/non-main branches;
- read README;
- inspect FD02;
- download dependencies, SDK components, or system images;
- create a Windows Sandbox;
- run DEP13, B12, M2, M3 acquisition work, or unrelated implementation.

## 12. Required candidate result

Publish exactly one result artifact on the dedicated implementation review branch:

`docs/architecture/ELITESYNC_V10_ANDROID_STUDIO_EMULATOR_HOME_SEMANTICS_BOUNDED_REMEDIATION_IMPLEMENTATION_RESULT_V0_1.md`

The candidate commit may contain only:

- the two authorized product source files if changed;
- directly focused test file(s) authorized by §5;
- the result artifact above.

The result must record:

- main/FIRST/task/acceptance identities;
- pre/post blobs for each changed product source file;
- exact implementation approach for each accepted finding;
- exact focused test paths/commands/results;
- offline build commands/results and new APK SHA-256 if runtime validation reached that stage;
- emulator/AVD/device identity used;
- post-remediation screenshot/hierarchy paths and SHA-256 values;
- Contract A semantic validation result;
- Contract B semantic validation result;
- visual/PID/fatal regression result;
- all stop/failure facts if a gate fails;
- explicit negative attestations for login/private data/destination navigation/dependency acquisition/broad QA/Sandbox/DEP13.

Final classification exactly one of:

`HOME SEMANTICS BOUNDED REMEDIATION IMPLEMENTED AND VALIDATED — READY FOR INDEPENDENT ACCEPTANCE`

or

`HOME SEMANTICS BOUNDED REMEDIATION IMPLEMENTED — VALIDATION INCOMPLETE/FAILED — AWAITING INDEPENDENT ACCEPTANCE`

or

`HOME SEMANTICS BOUNDED REMEDIATION NOT IMPLEMENTED — PRECONDITION/LOCAL-STATE GATE FAILED — AWAITING INDEPENDENT ACCEPTANCE`

## 13. Stop rule

Stop immediately after publishing exactly one candidate commit.

Do not self-accept, merge, broaden implementation, publish the next task, run destination feature checks, create a Sandbox, or run DEP13.

## 14. Preserved boundaries

Remain unchanged:

`FAILED_START_RESULT_NOT_CAPTURED`

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

Accepted B R4 share-success fact remains valid. Sandbox DEP13 remains unresolved and blocked. Emulator evidence remains a separate local development/test evidence class.

Preserve D-02 durable UNKNOWN, U-14 exclusion, U-12 exact-scope rules, `TP-SOURCE-CLASS-01`, `TP-TARGET-01`, Backend/Database/PUI boundaries, README exhausted, FD02 excluded, protected-index boundary, accepted legal/Safety/no-processing boundaries, and no LC-03/LC-04/Phase36 authority unless separately reauthorized.

B12 remains NOT AUTHORIZED. M2 remains separate and NOT automatically authorized.

## 15. End state

`ACCEPTED SOURCE CAUSE -> TWO-SURFACE BOUNDED REMEDIATION`

`BOUNDED REMEDIATION != BROAD IMPLEMENTATION`

`FOCUSED SEMANTICS TESTS + HOME-ONLY CAPTURE != BROAD QA`

`EMULATOR EVIDENCE != SANDBOX DEP13 EVIDENCE`
