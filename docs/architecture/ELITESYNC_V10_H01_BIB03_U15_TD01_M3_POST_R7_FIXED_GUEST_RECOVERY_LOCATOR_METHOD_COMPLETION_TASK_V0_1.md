# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 Fixed-Guest Recovery Locator/Method Completion Task v0.1

Status: `TASK AUTHORIZED — RECOVERY CONTRACT COMPLETION ONLY — NO SANDBOX CREATION — NO DEP13 PROBES — NO ACQUISITION — NO GRADLE/M3 — NO M2`

Date: 2026-09-11

Repository: `zcx369658780/EliteSync-v10`

## 1. Purpose

Close the remaining fixed-guest recovery locator/method gaps using current project facts supplied by Owner after a bounded Codex fact-finding pass, and determine whether a fully parameterized, fail-closed recovery execution task can now be authored without invention.

This task does not create, launch, stop, close, reset, kill, share, materialize, or access any Sandbox. It does not resume DEP13. It does not perform Maven/source research, acquisition, Gradle/M3, AAR probing, or M2.

`CONTRACT COMPLETION != RECOVERY EXECUTION AUTHORITY`

## 2. Mandatory repository startup gate

Fresh-fetch GitHub `main` first and require:

- commit: `32b595f747e03f0164a209543d28499398a02520`
- tree: `940dc6603fcd3cf52ad55757eb1b891c98ecfaa3`

Read FIRST:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_FIXED_GUEST_RECOVERY_CONTRACT_REVIEW_ACCEPTANCE_V0_1.md`

Require FIRST blob:

`04014bf9887e8838b7963f2e38e7fd11145d9edb`

Preserve fixed transition FIRST blob:

`18485c95262051e43892436fb52413132c5ee626`

If any repository/FIRST identity mismatches, stop before substantive review.

## 3. Owner-supplied current facts now authorized for review

The Owner supplies the following bounded current-project facts from a read-only Codex fact-finding pass. These facts are inputs to this governance task and must be validated for internal consistency; they are not recovery execution authority by themselves.

### 3.1 Current Sandbox control facts

- `wsb.exe`: `C:/Users/zcxve/AppData/Local/Microsoft/WindowsApps/wsb.exe`
- CLI version: `0.8.107.0`
- accepted creation semantics: `wsb start --raw --config '<Configuration><Networking>Disable</Networking></Configuration>'`
- inline XML configuration is used; no independent `.wsb` file is required by the current accepted project record
- new Sandbox ID comes from `wsb start --raw` output
- uniqueness contract: pre-start `wsb list --raw` returns zero; post-start list returns exactly one applicable running Sandbox whose ID equals the newly returned ID
- no project-owned launcher wrapper is currently established

This task must parameterize the exact PowerShell quoting/argument contract without executing it.

### 3.2 Current exact host source locators

Treat these as Owner-supplied current source candidates, subject to the identity checks in §3.5:

1. Flutter/toolchain: `D:/flutter`
2. Android SDK: `C:/Users/zcxve/AppData/Local/Android/Sdk`
3. JDK: `C:/Program Files/Eclipse Adoptium/jdk-17.0.18.8-hotspot`
4. Git: `C:/Program Files/Git`
5. Pub cache: `C:/Users/zcxve/AppData/Local/Pub/Cache`
6. Gradle root: `D:/GradleHome`
7. Fixed module source: `D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/input-r6-r1/apps/flutter_elitesync_module`

The current project has established `D:/GradleHome/caches` and `D:/GradleHome/wrapper/dists` under the Gradle root.

### 3.3 Current M3A target roots

The replacement guest contract must target exactly:

- Flutter: `C:/M3A/tools/flutter`
- Android SDK: `C:/M3A/tools/android`
- JDK: `C:/M3A/tools/jdk`
- Git: `C:/M3A/tools/git`
- Pub cache: `C:/M3A/cache/pub`
- Gradle user home: `C:/M3A/cache/gradle`
- fixed module: `C:/M3A/work/apps/flutter_elitesync_module`
- writable transport/evidence root: `C:/M3A/transport`

### 3.4 Existing materialization facts to convert into a complete parameterized map

The currently established A7 six-class mapping uses read-only `wsb share` and guest-local materialization:

- Android SDK -> `C:/M3A/source/a7/android` -> `C:/M3A/tools/android`
- JDK -> `C:/M3A/source/a7/jdk` -> `C:/M3A/tools/jdk`
- Git -> `C:/M3A/source/a7/git` -> `C:/M3A/tools/git`
- Pub cache -> `C:/M3A/source/a7/pub` -> `C:/M3A/cache/pub`
- `D:/GradleHome` -> `C:/M3A/source/a7/gradle` -> `C:/M3A/cache/gradle`
- fixed module -> `C:/M3A/source/a7/module` -> `C:/M3A/work/apps/flutter_elitesync_module`

Share template:

`wsb share --id <SandboxId> --host-path <host> --sandbox-path <guest-source> --raw`

No `--allow-write` is used for source shares.

Materialization contract for A7 classes:

`robocopy <source> <destination> /E /COPY:DAT /DCOPY:DAT /R:0 /W:0 /XJ /NFL /NDL /NP /NJH`

Robocopy exit `0..7` = success. Sources must exist first. Destinations must initially not exist.

Flutter is only partially established historically. This task must define the missing current Flutter mapping as a parameterized contract using:

- host: `D:/flutter`
- proposed guest source seed: `C:/M3A/source/flutter`
- final target: `C:/M3A/tools/flutter`
- source share read-only
- guest-local copy must be defined exactly and consistently with the fail-closed target-empty rule; prefer the same robocopy contract as the six A7 classes unless accepted evidence gives a reason not to

Do not execute or test the map.

### 3.5 Current bounded identity baselines

Preserve and use the following current checks as verification inputs:

- Dart SHA-256: `44328B98B6BF981D8307F72EF38ACBB37B8067394916953CAA48B8B444525152`; Dart SDK `3.11.5 stable`
- Flutter-tools pubspec: Length `2946`; SHA-256 `6E31FF00AC4441294B60F20A71DCE2777CC80EB33663E6621DAE38C2391DB0EA`
- Flutter-tools snapshot: Length `43747920`; SHA-256 `E494C265BA9C38A6A5679842703D3041DF0D2D86C83BFC55DF56C3BD0DF8E808`
- Android `adb.exe` SHA-256: `7035CF5EC7F99F7B5662A9F5395F9DCCFC3B6FE42583D0B9550124A0C3496606`
- Android `sdkmanager.bat` SHA-256: `11D021F90186F7FCC0B2D97623348C9C857109636B29D70FA1B804A4D603F5E7`
- JDK `java.exe` SHA-256: `5369CF92FC590944793E47CC9C9FEF7955CE1A68DE22BA22023CDD3513E87C2B`; Temurin/OpenJDK `17.0.18+8`
- Git `git.exe` SHA-256: `DA240FE9BC24895B3E04150A4990B8A6FF329ECABCD8F19684C2CC310DA5EF3F`; `git version 2.53.0.windows.1`
- fixed module: files `527`; directories `301`; bytes `3234145`; reparse points `0`; TSV Length `69676`; TSV SHA-256 `4F869B12B5F466E35326966272F13BEA6EBABC69A631200E26F8F8E3D382DD2E`; `pubspec.yaml` Length `1984`; SHA-256 `ECBC74EF27D949712532409EADC6BE0928EA56C9CBC603EB0C80FBE0CEC7E6BC`
- Pub cache root exists; no package enumeration is authorized
- Gradle root/caches/wrapper dists exist; no Gradle execution or dependency-resolution inspection is authorized

Do not conflate the 527-file fixed-module source manifest with the separate accepted protected-module manifest from earlier B-series evidence.

## 4. Required contract-completion decisions

The review must produce one exact, executable-in-principle contract for all items below without running it.

### Q1 — Exact launcher/controller contract

Define an exact parameterized PowerShell form for:

1. pre-start `wsb list --raw` requiring zero applicable running Sandboxes;
2. `wsb start --raw --config <inline XML>` with networking disabled;
3. capture of the returned new Sandbox ID;
4. post-start `wsb list --raw` requiring exactly one applicable running Sandbox whose ID equals the captured ID;
5. fail-closed behavior for zero/multiple/mismatch states.

The contract must specify exact quoting/escaping strategy and receipt fields. Do not execute it.

### Q2 — Complete read-only share map

Define the literal seven source shares for Flutter + six established A7 source classes. Every source share is read-only.

Define a separate writable task-owned host evidence/transport share. Its exact host root must be generated under a task-owned fresh path beneath:

`C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-<attempt-id>`

and mapped to:

`C:/M3A/transport`

The contract must require the host evidence root to be absent before task creation, created only by the future recovery task, and never overlap any source root.

### Q3 — Complete materialization order

Define exact order:

1. verify all seven source locators/identity gates before any source share/materialization;
2. create/start/capture/uniqueness-bind Sandbox;
3. establish writable transport/evidence share;
4. establish seven read-only source shares;
5. establish `guest.started` binding;
6. materialize Flutter;
7. materialize Android SDK;
8. materialize JDK;
9. materialize Git;
10. materialize Pub cache;
11. materialize Gradle root;
12. materialize fixed module;
13. verify all fixed M3A roots and bounded identities;
14. emit terminal recovery result/summary receipt;
15. do not run DEP13 in the same execution.

For every materialization target, require target absence before copy. Define robocopy success as exit `0..7`; any other exit is failure. Require `/XJ` and no source writes.

### Q4 — Exact recovery write allowlist

The future recovery task may write only:

- task-owned host evidence root `C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-<attempt-id>`;
- guest `C:/M3A/transport`;
- guest `C:/M3A/tools/flutter`;
- guest `C:/M3A/tools/android`;
- guest `C:/M3A/tools/jdk`;
- guest `C:/M3A/tools/git`;
- guest `C:/M3A/cache/pub`;
- guest `C:/M3A/cache/gradle`;
- guest `C:/M3A/work/apps/flutter_elitesync_module`;
- guest runtime-temp roots only if the completion review defines their exact names under `C:/M3A/runtime/<attempt-id>/...`.

All host source roots, `D:/EliteSync-v10`, Git index/staged state, historical evidence roots, and any Owner-existing Sandbox are write-forbidden.

No Gradle native metadata may be manually fabricated or edited.

### Q5 — Exact sentinel / receipt contract

Define exact task-owned host receipt paths under the attempt root, including at minimum:

- `launcher.json`
- `guest.started.json`
- `share-results.json`
- `materialization-results.json`
- `identity-results.json`
- `recovery-result.json`
- `recovery-summary.json`

Define required atomic binding fields:

- schema
- attempt_id
- nonce
- sandbox_id
- launcher_started_utc
- launcher/controller PID or explicit `NOT_APPLICABLE` if `wsb start` does not expose a stable launcher PID
- source locator identities
- share modes/results
- materialization exits/results
- guest root identities
- network-not-used assertion/evidence
- terminal classification

`guest.started.json` must bind `attempt_id + nonce + sandbox_id` before any materialization starts. A guest result lacking that exact binding is not attributable to the recovery execution.

Define terminal success as all shares/materializations/identity gates passing. No DEP13 is run in this task.

### Q6 — Quarantine / cleanup contract

Adopt the conservative current-project rule:

- if a newly created task-owned Sandbox fails any gate, preserve evidence and leave the Sandbox running;
- do not create a second Sandbox;
- do not call `CloseMainWindow`, kill, reset, close, or `wsb stop` in the recovery execution task;
- report the exact new Sandbox ID and terminal blocker;
- never act on any Owner-existing Sandbox;
- never delete or reuse historical evidence;
- task-owned host attempt root remains preserved after success or failure;
- later disposal/cleanup requires a separately authorized task.

This contract intentionally favors evidence preservation over automatic cleanup.

## 5. Required output

Create exactly one bounded result document on a fresh review branch whose sole parent is verified current `main`.

Recommended result path:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_FIXED_GUEST_RECOVERY_LOCATOR_METHOD_COMPLETION_RESULT_V0_1.md`

The result must contain:

1. repository/FIRST gates;
2. owner-supplied current fact inventory;
3. exact launcher/controller contract;
4. exact seven-source read-only share map plus one writable evidence share;
5. exact materialization ordering and copy contract;
6. exact recovery write allowlist;
7. exact sentinel/receipt schemas and binding rules;
8. quarantine/cleanup contract;
9. unresolved facts, if any;
10. readiness classification;
11. explicit NOT_RUN / NOT_AUTHORIZED section;
12. one safest next bounded task recommendation.

## 6. Readiness classification

Use one:

`RECOVERY EXECUTION CONTRACT COMPLETE — READY FOR BOUNDED RECOVERY EXECUTION TASK`

or

`RECOVERY EXECUTION CONTRACT STILL BLOCKED — SPECIFIC CONTRACT ELEMENTS UNRESOLVED`

Do not create or execute the downstream recovery task in the same execution.

## 7. Explicit prohibitions

No Sandbox create/start/stop/close/reset/kill/share/materialize/access.
No runtime `wsb` execution.
No DEP13 probes.
No host-wide/drive-wide/repository-wide discovery.
No Maven/source research.
No network acquisition/package fill.
No artifact acquisition/persistence beyond result documentation.
No Gradle/gradlew/dependency resolution.
No M3/AAR/M1/M2.
No product implementation/LC-03/LC-04/Phase36.
No README read. FD02 remains excluded.
No default `git status` or protected staged/index inspection.
No automatic helper agents.

## 8. Candidate governance and stop rule

Executor must not self-accept or modify `main`.
After publishing the single bounded candidate, stop and report:

- review branch
- candidate commit
- sole parent
- candidate tree
- result path
- result blob
- result SHA-256 if available
- final classification
- unresolved contract-element count

`CONTRACT COMPLETE != SANDBOX RECOVERY EXECUTION AUTHORITY`
