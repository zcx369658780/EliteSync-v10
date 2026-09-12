# EliteSync v10｜Android Studio Emulator Home First-Frame Visual & Accessibility Review Result｜v0.1

Status: `PUBLISHED RESULT CANDIDATE — STATIC ACCEPTED-EVIDENCE REVIEW ONLY — AWAITING INDEPENDENT ACCEPTANCE`

Date: 2026-09-12 (Asia/Shanghai).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Authority and review boundary

- Fresh-fetched required `main`: `5d5a1d0f824494a598cc10dd35c706f89c1502e4` — exact match.
- FIRST handoff: `docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`.
- FIRST blob: `3aa2ead4cf1084b202b67856075c26ab80b0c9a2` — exact match and read first.
- Task: `docs/architecture/ELITESYNC_V10_ANDROID_STUDIO_EMULATOR_HOME_FIRST_FRAME_VISUAL_ACCESSIBILITY_REVIEW_TASK_V0_1.md`.
- Task blob: `7488d3fb3f2ca3d1c2696748881c8ab22d8e8f46` — exact match.
- Accepted first-frame baseline acceptance: `docs/architecture/ELITESYNC_V10_ANDROID_STUDIO_EMULATOR_FIRST_FRAME_BASELINE_ACCEPTANCE_V0_1.md`.
- Acceptance blob: `4dd40d18ae30682ae09d053f7f75a24d4d8302a2`.
- Accepted first-frame candidate: `5adcb2cbca7377c9b6598adccbc0bfa92097a760`.
- Dedicated review worktree: `D:\EliteSync-v10-emulator-home-first-frame-visual-accessibility-review-v0-1`.
- Dedicated review branch: `review/android-studio-emulator-home-first-frame-visual-accessibility-review-v0-1`.

This was a static review of four accepted files only. No emulator/app interaction or runtime query was performed.

## 2. Exact accepted-evidence gate

Sole evidence root:

`C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-Emulator-FirstFrame-a8dd19155ce3459fa470257e92eb3c70`

| Evidence | Verified SHA-256 | Dimensions / structure | Gate |
|---|---|---|---|
| `initial-first-frame.png` | `6A7314CF559197F4D1CD680CE7ACB18B196FEB17F72BFCF5087317FB405324D9` | `1080×2400` px | PASS |
| `initial-first-frame.xml` | `C3B0C97B9DF56DE4D1331D7B0BF9528895ECD22B05CEA704D1D4EBF67643F3CD` | 19 nodes | PASS |
| `post-home-tab.png` | `95A1D55F49808E5E0556E4AF6F25B95DAB50A3B7C78619AD60E4E9EC7385FE5D` | `1080×2400` px | PASS |
| `post-home-tab.xml` | `C3B0C97B9DF56DE4D1331D7B0BF9528895ECD22B05CEA704D1D4EBF67643F3CD` | 19 nodes | PASS |

The PNG dimensions were read directly from each PNG IHDR header without rewriting either image. Both XML files were parsed read-only and are byte-identical.

## 3. Visible rendering findings

Supported observations for the accepted `1080×2400` viewport:

- title `首页`, subtitle `从这里查看慢约进展。`, button label `查看慢约进展`, and all five bottom-navigation labels are visibly legible in the captures;
- no visible text is clipped, ellipsized, truncated, or cut off by a viewport edge;
- no visible app-level element overlaps another app-level element;
- the title/subtitle card and progress-button card remain fully within the viewport;
- the bottom-navigation container, icons, labels, and selected-state highlight remain fully visible above the system gesture area;
- the selected Home item is visibly distinguished by a light-blue pill background and blue icon, while the other four items use the unselected gray treatment;
- no visible app-level cutoff or edge collision is supported by the captures.

These are capture-specific visual observations. They do not establish behavior at another viewport, font scale, display scale, locale, theme, or assistive-technology configuration.

No normative color-contrast ratio was measured from the accepted artifacts, so standards-level contrast compliance is not claimed.

## 4. Semantic/accessibility matrix

The hierarchy uses empty `text` attributes for the listed app elements and exposes their labels through `content-desc`. Absence from `text` is not by itself classified as inaccessible because the relevant labels are present in `content-desc`.

| Visible item | Visible text | Hierarchy `text` | `content-desc` | Clickable | Hierarchy selected | Pixel bounds | Visible clipping/overlap | Concern classification |
|---|---|---|---|---|---|---|---|---|
| title `首页` | YES | absent | shared node: `首页\n从这里查看慢约进展。` | YES, shared full-screen node | `false` | shared `[0,0][1080,2400]` | none observed | `SUPPORTED FINDING` — title/subtitle semantics are attached to a full-viewport clickable/focusable node |
| subtitle `从这里查看慢约进展。` | YES | absent | shared node: `首页\n从这里查看慢约进展。` | YES, shared full-screen node | `false` | shared `[0,0][1080,2400]` | none observed | `SUPPORTED FINDING` — same full-viewport clickable/focusable node |
| button `查看慢约进展` | YES | absent | `查看慢约进展` | YES | `false` | `[108,428][972,554]` | none observed | `NO SUPPORTED ISSUE OBSERVED` |
| bottom `首页` | YES | absent | `首页` | YES | `false` | `[60,2198][252,2295]` | none observed | `SUPPORTED FINDING` — visually selected but hierarchy selected state is `false` |
| bottom `发现` | YES | absent | `发现` | YES | `false` | `[252,2198][444,2295]` | none observed | `NO SUPPORTED ISSUE OBSERVED` for captured label/state |
| bottom `匹配` | YES | absent | `匹配` | YES | `false` | `[444,2198][636,2295]` | none observed | `NO SUPPORTED ISSUE OBSERVED` for captured label/state |
| bottom `消息` | YES | absent | `消息` | YES | `false` | `[636,2198][828,2295]` | none observed | `NO SUPPORTED ISSUE OBSERVED` for captured label/state |
| bottom `我的` | YES | absent | `我的` | YES | `false` | `[828,2198][1020,2295]` | none observed | `NO SUPPORTED ISSUE OBSERVED` for captured label/state |

The title and subtitle are not represented as separately bounded hierarchy nodes, so their individual semantic bounds, roles, and traversal granularity are `NOT DETERMINABLE` from the accepted hierarchy.

The screenshot visibly establishes Home as selected, while both accepted hierarchies record `selected=false` for the Home node. The two evidence forms therefore differ on selected-state exposure; this is not silently reconciled.

## 5. Clickable-node pixel geometry

Seven clickable nodes are represented. All are enabled and focusable. None has zero or negative area.

| Clickable node label | Bounds | Width | Height | Area | Geometry finding |
|---|---:|---:|---:|---:|---|
| shared Home title/subtitle node | `[0,0][1080,2400]` | 1080 px | 2400 px | 2,592,000 px² | touches every viewport edge and geometrically overlaps every specific clickable control |
| `查看慢约进展` | `[108,428][972,554]` | 864 px | 126 px | 108,864 px² | non-degenerate; visible button is contained by the region |
| `首页` | `[60,2198][252,2295]` | 192 px | 97 px | 18,624 px² | non-degenerate; visible icon/label is contained by the region |
| `发现` | `[252,2198][444,2295]` | 192 px | 97 px | 18,624 px² | non-degenerate; visible icon/label is contained by the region |
| `匹配` | `[444,2198][636,2295]` | 192 px | 97 px | 18,624 px² | non-degenerate; visible icon/label is contained by the region |
| `消息` | `[636,2198][828,2295]` | 192 px | 97 px | 18,624 px² | non-degenerate; visible icon/label is contained by the region |
| `我的` | `[828,2198][1020,2295]` | 192 px | 97 px | 18,624 px² | non-degenerate; visible icon/label is contained by the region |

The five bottom-navigation targets are contiguous at their horizontal boundaries and do not overlap one another. The button does not overlap the bottom targets. The shared full-screen node contains the title/subtitle label but its region is much larger than the visible title/subtitle card and geometrically overlaps the button and all five bottom targets.

The accepted evidence contains no display-density value. Therefore minimum-touch-target and all other px-to-dp compliance conclusions are:

`NOT DETERMINABLE FROM ACCEPTED EVIDENCE — DISPLAY DENSITY NOT ESTABLISHED`

Actual screen-reader traversal order, activation behavior, spoken output, focus movement, and interaction conflict caused by the overlapping region are also not determinable from a static hierarchy alone.

## 6. Initial/post visual stability

- The initial and post hierarchy files are byte-identical.
- A read-only RGB pixel comparison found 949 differing pixels, all within bounding box `(116,15)–(919,47)` in the system status-bar area.
- The entire image region at `y≥100` was pixel-identical.
- Visual review found the accepted clock change from 11:47 to 11:48 and status-indicator variation, but no app-content difference.

Result:

`APP-LEVEL FIRST-FRAME VISUAL STATE STABLE UNDER ACCEPTED OBSERVATIONAL HOME TAP`

This conclusion is limited to the two accepted captures and does not establish determinism across launches, devices, configurations, or later app states.

## 7. Source-actionable findings

Two concrete findings justify one later bounded source-locator/review task:

1. `HOME-SEM-SELECTED-01`: the visually selected bottom `首页` item is uniquely identifiable at `[60,2198][252,2295]`, but its hierarchy `selected` field is `false` in both accepted XML files. A later source review should locate how the Home navigation item exposes selected semantics.
2. `HOME-SEM-FULLSCREEN-CLICK-01`: the unique hierarchy node labeled `首页\n从这里查看慢约进展。` is clickable/focusable with full-viewport bounds `[0,0][1080,2400]`, overlapping every specific clickable region. A later source review should locate why the Home content semantics are merged into a full-screen actionable node and determine whether that is intended.

Both findings are directly supported by accepted evidence and identify exact labels/regions. Neither finding proves actual assistive-technology failure, hit-test conflict, or user harm; those runtime behaviors were not exercised.

## 8. Exact next recommended bounded task

After fresh independent acceptance, recommend exactly one read-only Home source-locator/semantics review task. It should use only the exact anchors `首页`, `从这里查看慢约进展。`, and `查看慢约进展` to uniquely locate the Home surface and bottom-navigation semantics responsible for `HOME-SEM-SELECTED-01` and `HOME-SEM-FULLSCREEN-CLICK-01`, determine whether the captured hierarchy fields follow from the source configuration, and propose a bounded remediation contract if warranted.

That future task must not modify source, interact with the emulator, inspect destinations, access private/backend/participant data, acquire dependencies, perform broad source archaeology, or claim remediation before independent acceptance. This result does not publish or authorize that task.

## 9. Negative attestations and preserved boundaries

This review did not:

- interact with the emulator or app;
- run `adb`, `uiautomator`, screenshot capture, or logcat;
- query display density;
- read or modify implementation/test/build source;
- rebuild, install, run pub/Gradle, or acquire SDK/dependencies;
- log in, enter data, inspect private storage, access Backend/Database/PUI behavior, or inspect participant/private Conversation data;
- read README/FD02, perform broad QA or broad archaeology, create a Windows Sandbox, or run DEP13.

Remain unchanged:

`FAILED_START_RESULT_NOT_CAPTURED`

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

Accepted B R4 share-success fact remains valid. Sandbox DEP13 remains unresolved and blocked. Emulator UI evidence remains a separate local development/test evidence class.

## 10. Final classification

`HOME FIRST-FRAME VISUAL/ACCESSIBILITY REVIEW COMPLETE — SOURCE-ACTIONABLE FINDING(S) ESTABLISHED — AWAITING INDEPENDENT ACCEPTANCE`

Stop boundary: publish this single result candidate only; do not self-accept, merge, perform source-level work, publish a successor task, interact with the emulator, create a Windows Sandbox, or run DEP13.
