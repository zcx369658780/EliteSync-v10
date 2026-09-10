# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 B12-SRC Nine Direct Coordinate Source/Object Contract Task v0.2

Status: `TASK AUTHORIZED — SUPERSEDES V0.1 AFTER REMOTE-READ BOUNDARY VIOLATION — READ-ONLY PUBLIC SOURCE/OBJECT CONTRACT RESEARCH — NO ACQUISITION — NO GRADLE/M3 — NO M2`

Date: 2026-09-10

Repository: `zcx369658780/EliteSync-v10`

## 1. Supersession and incident disposition

This task supersedes B12-SRC v0.1 task commit:

`2cd9cc19a3a5732b2ce2dfa912f2719948a540b2`

The v0.1 execution attempt stopped after an explicit remote-read boundary violation involving:

`kotlin-gradle-plugin-idea-2.1.0-test-fixtures.jar`

Observed incident facts supplied by the stopped executor:

- test-fixtures JAR: `HEAD` only;
- its `.sha256`, `.sha1`, `.md5`, `.asc` sidecars: read-only requests;
- JAR body: `NOT_READ`;
- artifact/metadata persistence: `NOT_RUN`;
- no result candidate was created;
- no repository main mutation occurred.

The incident must not be reused as accepted source/object-contract evidence.

Do not resume or execute v0.1 again.

`V0.1 INCIDENT != CONTRACT EVIDENCE`

`V0.1 TASK != CURRENT EXECUTION AUTHORITY`

## 2. Purpose

Establish an exact, bounded public-source/object contract for the nine Kotlin 2.1.0 direct dependency coordinates whose fixed guest Gradle local state was accepted by B12-PRE as `ABSENT = 9/9`.

This task is documentary/research authority only. It does not authorize artifact acquisition, persistence, cache fill, local Maven repository creation, Gradle execution, M3, AAR probing, or M2.

The goal is to establish production-resolution object inventories and integrity facts for later atomic B12 scope review while explicitly excluding test-only and unrelated classifier objects.

## 3. Mandatory repository startup gate

Fresh-fetch GitHub `main` first.

Require exact current durable authority:

`0303ce52caaa3f89190f5a6c38bd66a942afb7fb`

Require exact tree:

`d311ed6c14c92be0d432a5eec8e9df0d56cf096d`

Read FIRST:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_B12_PRE_NINE_DIRECT_DEPENDENCY_LOCAL_STATE_REVIEW_ACCEPTANCE_V0_1.md`

Require FIRST blob:

`2dd5878f693bf5f49cf59ebe6595e566a5a8d425`

Also preserve the prior handoff/FIRST chain already accepted, including fixed transition FIRST blob:

`18485c95262051e43892436fb52413132c5ee626`

Conversation text/memory is context only and is not execution authority.

If any required identity gate fails, stop before public-source research.

## 4. Preserved accepted evidence

Do not reopen B10, B11, or B12-PRE absent contradictory fresh evidence.

Accepted facts include:

- primary coordinate: `org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0`;
- Maven Central / `repo.maven.apache.org` is the sole currently proven acquisition authority for the primary coordinate;
- manual fabrication/mutation of Gradle native `modules-2` cache metadata is rejected;
- preferred later exposure mechanism remains task-owned staging/local Maven repository;
- B12-PRE established all nine coordinates below as `ABSENT` in the fixed guest Gradle local state;
- primary-only B12 is not a proven atomic classpath input set;
- B12 remains NOT AUTHORIZED.

## 5. Exact nine coordinates

Research only these coordinates at version `2.1.0`:

1. `org.jetbrains.kotlin:kotlin-gradle-plugins-bom:2.1.0`
2. `org.jetbrains.kotlin:kotlin-gradle-plugin-api:2.1.0`
3. `org.jetbrains.kotlin:kotlin-gradle-plugin-model:2.1.0`
4. `org.jetbrains.kotlin:kotlin-gradle-plugin-idea:2.1.0`
5. `org.jetbrains.kotlin:kotlin-gradle-plugin-idea-proto:2.1.0`
6. `org.jetbrains.kotlin:kotlin-klib-commonizer-api:2.1.0`
7. `org.jetbrains.kotlin:kotlin-build-statistics:2.1.0`
8. `org.jetbrains.kotlin:kotlin-util-klib-metadata:2.1.0`
9. `org.jetbrains.kotlin:kotlin-compiler-runner:2.1.0`

Do not add newly discovered coordinates to the research scope.

## 6. Allowed remote authority

Use only exact Maven Central resources under:

`https://repo.maven.apache.org/maven2/`

for the nine exact group/artifact/version coordinates above.

No repository browsing, wildcard listing, recursive crawling, search-engine discovery, Google Maven probing, mirror probing, alternate repository probing, or package-manager execution is authorized.

## 7. Production-object allowlist

Remote requests are allowed only for exact objects derived from one of the nine authorized coordinates and belonging to the following allowlist:

1. `<artifact>-2.1.0.pom`
2. `<artifact>-2.1.0.module`
3. base production artifact `<artifact>-2.1.0.jar` when applicable
4. exact non-test Gradle plugin/API compatibility variant JARs directly referenced by that coordinate's own `.module` metadata, but only when the filename does not match any denylist rule in §8
5. exact `.sha1`, `.md5`, `.asc` sidecars for an allowlisted object
6. exact `.sha256` sidecar for an allowlisted object only to determine published presence/absence

A filename being referenced by `.module` metadata is necessary but not sufficient for remote-read authorization. It must also pass the denylist below.

Do not generate or probe candidate filenames by classifier guessing.

Do not use HEAD/GET/sidecar requests to test an object unless the exact object is already allowlisted by these rules.

## 8. Explicit test/unrelated classifier denylist

The following are explicitly outside remote-read authority even if referenced by own metadata:

- any filename containing `test-fixtures`;
- any filename containing `tests` or `test` as a classifier component;
- test fixture variants/components;
- test artifacts of any packaging;
- sources artifacts;
- javadoc artifacts;
- samples/examples artifacts;
- unrelated classifiers not required for normal production Gradle classpath resolution;
- any object whose production relevance cannot be established from the authorized coordinate's own POM/`.module` metadata without executing Gradle.

For denied objects:

`REGISTER NAME/METADATA REFERENCE ONLY — REMOTE OBJECT READ NOT AUTHORIZED`

Do not issue HEAD, GET, sidecar, checksum, signature, or existence-probe requests for denied objects.

If a denied filename is encountered in already-authorized POM/`.module` metadata, record it textually as:

`EXCLUDED TEST/UNRELATED CLASSIFIER — REMOTE OBJECT NOT READ`

and continue with remaining allowlisted objects.

## 9. Read-only / no-persistence rule

Public-source responses may be read transiently for documentary analysis.

Do not intentionally persist Maven artifact or metadata bytes into repository worktrees, guest state, Gradle cache, task-owned staging, local Maven layout, temp acquisition directories, or durable package caches.

The result document may record textual facts, exact allowed URLs, HTTP status, Content-Length/observed byte length, hashes computed in memory from transient responses, and metadata-derived dependency/object facts.

`PUBLIC SOURCE READ != ACQUISITION`

`IN-MEMORY HASH != CACHE FILL`

## 10. Required per-coordinate contract

For each exact coordinate, record:

1. exact Maven Central coordinate base URL;
2. exact POM URL and HTTP result;
3. exact `.module` URL and HTTP result;
4. whether the POM contains the Gradle-metadata publication marker when observable;
5. base production JAR applicability/presence and exact URL when applicable;
6. exact allowlisted non-test variant artifact filenames directly referenced by own `.module` metadata;
7. exact denied test/unrelated filenames referenced by own metadata, recorded without remote object reads;
8. observed Length for each allowlisted object that would be part of a later acquisition inventory;
9. SHA-256 of exact transient bytes when feasible;
10. published `.sha1` / `.md5` / `.asc` sidecar presence for allowlisted objects where relevant;
11. published `.sha256` sidecar presence/absence for allowlisted objects;
12. exact dependency edges declared directly by own POM and/or `.module` metadata, without following those edges;
13. packaging/type semantics relevant to deciding whether a production JAR is expected.

Do not infer an object is required solely because a similarly named object exists for another coordinate.

## 11. New dependency edges — registration only

If any of the nine coordinates declares dependencies beyond the already known ten-coordinate set (primary + these nine), record each newly observed edge exactly as:

`DISCOVERED EDGE — NOT CHECKED — NOT AUTHORIZED FOR SOURCE READ OR ACQUISITION`

Record group, artifact, explicit version/version-constraint, source coordinate, and whether it came from POM or `.module` metadata.

Do not fetch the new coordinate.
Do not check its local cache state.
Do not resolve version ranges dynamically.
Do not inspect its POM, `.module`, JAR, repository path, or sidecars.

## 12. Exact object inventory output

Produce a coordinate-by-coordinate object inventory suitable for later B12 scope design.

Each inventory row must distinguish:

- `REQUIRED/REFERENCED PRODUCTION OBJECT`
- `PUBLISHED BUT NOT ESTABLISHED AS REQUIRED`
- `EXCLUDED TEST/UNRELATED CLASSIFIER — REMOTE OBJECT NOT READ`
- `NOT APPLICABLE`
- `NOT PUBLISHED / HTTP NON-200`
- `NOT DETERMINABLE WITHIN AUTHORIZED SCOPE`

Do not convert the inventory into acquisition authority.

If production variant selection cannot be proven without executing Gradle, preserve all allowlisted non-test variants referenced by own metadata as candidate production objects and classify exact selection as unresolved rather than running Gradle.

## 13. Incident evidence quarantine

Do not reuse HTTP results, sidecar contents, checksum values, or existence facts obtained during the stopped v0.1 access to:

`kotlin-gradle-plugin-idea-2.1.0-test-fixtures.jar`

or its sidecars.

The only durable fact from that stopped attempt relevant here is that the v0.1 boundary was violated and execution stopped.

No incident-derived test-object value may appear in the contract inventory except the textual incident disposition.

## 14. Primary coordinate boundary

Do not re-download/re-research the primary coordinate contract established by B11 except to cite its accepted repository evidence.

The primary coordinate is not one of the nine public-source targets of this task.

## 15. Explicit prohibitions

No artifact acquisition/persistence.
No guest Maven/network activity.
No Sandbox dependency download.
No Gradle/gradlew.
No dependency resolution execution.
No Flutter/Dart.
No M3.
No AAR probe.
No M1 retry.
No M2.
No local Maven repository creation.
No staging repository creation.
No Gradle native-cache write/fabrication/mutation.
No transitive-coordinate source reads.
No denied test/unrelated object remote reads, including HEAD.
No repository-wide/directory-wide/host-wide search or enumeration.
No README read.
FD02 remains excluded.
No default `git status`.
No protected staged/index inspection.
No automatic helper agents.
No product implementation.
No LC-03 / LC-04 / Phase 36.

## 16. Required result artifact

Create exactly one bounded result document on a fresh review branch whose sole parent is the verified durable `main` authority.

Recommended result path:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_B12_SRC_NINE_DIRECT_COORDINATE_SOURCE_OBJECT_CONTRACT_RESULT_V0_2.md`

The result must contain:

- repository/FIRST gates;
- v0.1 supersession/incident disposition;
- exact nine-coordinate source table;
- per-coordinate allowlisted production-object inventories;
- denied test/unrelated metadata references without remote object reads;
- Length + SHA-256 evidence where established for allowlisted objects;
- exact direct dependency-edge registry;
- newly discovered out-of-scope edges, if any;
- explicit unresolved facts;
- explicit NOT_RUN/NOT_ACQUIRED list;
- a bounded recommendation for the next decision only.

## 17. Final classification

Use one of these as applicable:

`NINE-DIRECT-COORDINATE PRODUCTION SOURCE/OBJECT CONTRACT ESTABLISHED — READY FOR ATOMIC B12 SCOPE REVIEW`

or

`ATOMIC B12 SCOPE REVIEW BLOCKED — NINE-DIRECT-COORDINATE PRODUCTION SOURCE/OBJECT CONTRACT INCOMPLETE`

If an earlier mandatory gate or remote-read boundary fails, use an exact blocker and stop immediately.

## 18. Candidate governance and stop rule

Create the result only on a fresh review branch from verified current `main`.

The executor must not self-accept.
Do not modify `main`.
Do not perform acceptance in the same task.
Do not execute B12 after completing this contract.

After publishing the result candidate, stop and report exactly:

- review branch;
- candidate commit;
- sole parent;
- candidate tree;
- result path;
- result blob;
- result file SHA-256 if available;
- final classification;
- count of newly discovered out-of-scope dependency edges;
- count of metadata-referenced denied test/unrelated objects that were recorded without remote object reads.

`B12-SRC V0.2 COMPLETION != B12 ACQUISITION AUTHORITY`

`SOURCE/OBJECT INVENTORY != DOWNLOAD AUTHORITY`

`DISCOVERED TRANSITIVE EDGE != AUTHORIZED TRANSITIVE SCOPE`

`METADATA REFERENCE != REMOTE OBJECT READ AUTHORITY`