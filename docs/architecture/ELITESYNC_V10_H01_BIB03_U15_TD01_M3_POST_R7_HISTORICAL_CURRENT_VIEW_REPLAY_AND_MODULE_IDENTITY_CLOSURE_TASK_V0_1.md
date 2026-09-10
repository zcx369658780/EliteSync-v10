# EliteSync v10｜Post-R7 Historical Current-View Replay + Module Identity Closure Task v0.1

Status: `PUBLISHED TASK SHEET — EXACT HISTORICAL CURRENT-VIEW ONLY — NO MATERIALIZATION — NO B — NO M3 — NO M2`

## 1. Authority and goal

Current accepted main must be `094343ee334b0691dc14e24b4539d0222c2e21cc`.

A5 was correctly blocked because no exact historical per-file manifest/current-view path was authorized. This task closes only that gap by authorizing the exact R6-R4-R2 historical current-view object and frozen helper already named by the R6-R4-R2 task.

No repository-wide search, host search, materialization, pub, Gradle resolution, M3, AAR probe, M2, or product implementation is authorized.

## 2. FIRST and exact inputs

1. Fresh-fetch `main`; if it is not exactly `094343ee334b0691dc14e24b4539d0222c2e21cc`, STOP `MAIN AUTHORITY CHANGED`.
2. FIRST read blob `18485c95262051e43892436fb52413132c5ee626`.
3. Read this task.
4. Read A5 result blob `b03b2af6398ef63b6c4ed7e360b4a492191dc54f`.
5. Read R6-R4-R2 task commit `f0272d3985799a3778f5e45cb55eb3c362b92f60` and result blob `03720d5499fca33f837abedd79871c740a0906bf` only for the frozen current-view contract.

## 3. Exact historical objects now authorized

Fixed workspace root:
`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008`

Historical R6-R4-R2 observable root:
`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/evidence/resume-r4/r6r4r2-observable`

Exact historical expected TSV:
`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/evidence/resume-r4/r6r4r2-observable/expected-module-current.tsv`

Exact frozen helper candidate:
`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/evidence/resume-r4/r6r4r2-observable/current-view-r6r4r2.ps1`

Authorized current fixed source:
`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/input-r6-r1/apps/flutter_elitesync_module`

Historical expected TSV properties from accepted R6-R4-R2 evidence:
- records/files = 527
- directories = 301
- total bytes = 3234145
- reparse = 0
- TSV length = 69676
- TSV SHA-256 = `4F869B12B5F466E35326966272F13BEA6EBABC69A631200E26F8F8E3D382DD2E`

Historical TSV contract:
`relative_path<TAB>length<TAB>SHA256`, relative path normalized to `/`, deterministic ordering, UTF-8 without BOM, LF line endings.

## 4. Replay procedure

1. Read-only verify the exact historical expected TSV exists, Length=69676 and SHA-256=`4F869B12B5F466E35326966272F13BEA6EBABC69A631200E26F8F8E3D382DD2E`.
2. If the exact frozen helper exists, hash it and compare to the accepted R6-R4-R2 helper identity if available from the result. If helper identity cannot be proven, do not modify it and do not search for another helper; implement only the already frozen TSV contract in a task-owned script.
3. Perform exactly one bounded recursive current-view enumeration of the authorized current fixed source.
4. Generate a task-owned current TSV under a new task-owned evidence root using exactly the historical TSV contract above.
5. Record current structure counts, TSV Length and SHA-256.
6. Compare historical expected TSV and current TSV by Length + SHA-256 first.

If Length and SHA match exactly, classify:
`FIXED_MODULE IDENTITY ESTABLISHED — HISTORICAL_CURRENT_VIEW_EXACT_MATCH`

Do not perform per-file diff after an exact match.

If Length/SHA differ, compare only these two exact TSV files line-by-line. Record:
- differing record count
- first at most 10 relative paths
- historical/current length
- historical/current SHA

Do not output file contents.

Then classify:
`ACTUAL_FILE_IDENTITY_DIFFERENCE_LOCALIZED`

## 5. Boundaries

Do not access `D:/EliteSync-v10/apps/flutter_elitesync_module` as an alternate source.
Do not search historical directories.
Do not modify the historical expected TSV, helper, current source, or any host SDK/cache.
Do not enter the Sandbox, create share, materialize, or execute tools there. `wsb list --raw` may be used once only as observational evidence; Sandbox state does not gate this host-only task.
Do not run Flutter/Dart pub, Flutter-tools pub, coverage/code_builder diagnosis, Gradle resolution, M3, AAR probe, M2, network/download/install, or product implementation.
Do not inspect default index/protected staged state and do not run default `git status`.

## 6. Result and stop

Create only:
`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_HISTORICAL_CURRENT_VIEW_REPLAY_AND_MODULE_IDENTITY_CLOSURE_RESULT_V0_1.md`

Result must record exact historical TSV identity, replay contract, current TSV identity, comparison result, final classification, observational Sandbox state, and all NOT_RUN items.

Candidate sole parent must be this task commit. Then STOP.
Do not self-accept, update `main`, materialize, or execute B.