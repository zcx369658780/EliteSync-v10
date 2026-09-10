# EliteSync v10｜Post-R7 Kotlin Gradle Plugin 2.1.0 Source Acquisition + Cache-Fill Contract Task v0.1

Status: `PUBLISHED TASK SHEET — READ-ONLY ACQUISITION/CACHE-FILL CONTRACT REVIEW — NO DOWNLOAD — NO CACHE FILL — NO GRADLE — NO M3 — NO M2`

## 1. Authority and goal

Current accepted main must be `c66d4dabb44f512cf6d8d9dfb8c03b3d317c5e9e`.

Accepted B10 established an exact local Gradle cache miss for:

`org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0`

The fixed guest Gradle cache lacks the exact version artifact directory, POM, JAR, and applicable coordinate descriptor/module metadata. This task does not download or fill anything. Its sole purpose is to establish one exact Owner-reviewable source-acquisition and cache-fill contract for a later execution task, bounded to this coordinate and its directly required resolution metadata/artifacts.

No Gradle execution, M3, AAR probe, M2, product implementation, network download, cache mutation, or package fill is authorized.

## 2. FIRST and exact inputs

1. Fresh-fetch `main`; if it is not exactly `c66d4dabb44f512cf6d8d9dfb8c03b3d317c5e9e`, STOP `MAIN AUTHORITY CHANGED`.
2. FIRST read blob `18485c95262051e43892436fb52413132c5ee626`.
3. Read this task.
4. Read accepted B10 result blob `cb31b77d3cdb64c4d0d47446aab81808e6418876`.
5. Read accepted B9 result blob `8b49fec7c642dec47ef7f8c844162cbe9aa60218` only for the exact observed remote resources and current Gradle/M3 context.

Do not perform repository-wide, host-wide, whole-cache, or whole-Flutter-SDK search.

## 3. Exact coordinate and observed repositories

Only this Maven coordinate is in scope:

`org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0`

Observed B9/B10 repository chain:

- `google()`
- `mavenCentral()`

Observed exact POM resources:

- `https://dl.google.com/dl/android/maven2/org/jetbrains/kotlin/kotlin-gradle-plugin/2.1.0/kotlin-gradle-plugin-2.1.0.pom`
- `https://repo.maven.apache.org/maven2/org/jetbrains/kotlin/kotlin-gradle-plugin/2.1.0/kotlin-gradle-plugin-2.1.0.pom`

This task must determine the exact canonical source set needed for later acquisition. Do not expand to neighboring versions or unrelated Kotlin artifacts unless an exact descriptor for this coordinate directly references them and they are required to make this coordinate resolvable.

## 4. Read-only source-contract research

Using only public Maven repository metadata/resources and authoritative repository behavior, determine for the exact coordinate:

- exact POM URL(s);
- exact JAR URL(s);
- Gradle module metadata URL(s) if published/applicable;
- checksum resources if published (`.sha256`, `.sha1`, etc.);
- whether Google Maven and Maven Central publish byte-identical or repository-specific copies;
- which repository should be the preferred acquisition authority for this coordinate;
- whether the POM declares direct dependencies that must also be present for classpath resolution.

Do not download artifacts in this task. Metadata/content reads may be used only to establish the contract and expected object identities; do not persist them into the project or Gradle cache.

If external web access is unavailable in the execution environment, classify `SOURCE_ACQUISITION_CONTRACT_NOT_PROVEN` rather than guessing.

## 5. Required exact object inventory

Produce an exact object inventory for a later cache-fill task. At minimum address:

- `kotlin-gradle-plugin-2.1.0.pom`
- `kotlin-gradle-plugin-2.1.0.jar`
- `kotlin-gradle-plugin-2.1.0.module` if published/applicable
- any exact checksum file used for verification
- any Gradle metadata/descriptor state that cannot be reconstructed by simply placing files under `files-2.1`

For each object record:

- canonical URL;
- expected filename;
- expected byte length if determinable without acquisition;
- expected SHA-256 if determinable from authoritative metadata;
- whether it is mandatory or optional for later Gradle resolution;
- exact target role in the cache-fill plan.

Do not invent hash values. If authoritative SHA-256 is not available without acquisition, mark `TO_BE_CAPTURED_DURING_AUTHORIZED_ACQUISITION`.

## 6. Gradle cache-fill mechanism review

Determine the safest bounded mechanism for a later execution task. Compare only these bounded options:

1. acquire exact repository artifacts to an external task-owned staging directory, verify hashes, then use a narrowly scoped local Maven repository and point only the isolated B12/B13 test to it;
2. populate Gradle's native cache structures for this exact coordinate;
3. use another Gradle-supported local repository mechanism that avoids fabricating opaque Gradle metadata.

Prefer a mechanism that does not manually forge Gradle binary metadata/cache internals.

The result must state whether direct mutation of `C:/M3A/cache/gradle/caches/modules-2/**` is safe/supported. If not, explicitly reject manual cache-internal fabrication and propose a task-owned local Maven repository/staging approach instead.

## 7. Transitive dependency boundary

Read the exact POM/module metadata for `kotlin-gradle-plugin:2.1.0` only enough to identify its direct runtime/classpath dependencies.

Do not automatically authorize acquisition of those dependencies.

Classify each direct dependency as:

- already locally present in fixed guest Gradle cache — if this can be proven by exact coordinate-derived checks only;
- missing/unknown — requiring a separate bounded follow-on decision;
- not required for the initial exact Kotlin plugin acquisition contract.

Do not enumerate unrelated cache entries.

## 8. Proposed later execution contract

If a safe exact source-acquisition path is established, propose a later task with all of:

- exact allowed remote hosts/domains;
- exact allowed coordinate and object URLs;
- exact task-owned staging directory outside repository/module/SDK/cache source roots;
- exact verification requirements (Length + SHA-256 captured immediately after acquisition);
- no wildcard/bulk Maven synchronization;
- no neighboring version/group acquisition;
- no Gradle execution during acquisition;
- no M3 during acquisition;
- no direct mutation of product-authored state;
- exact mechanism to expose the acquired artifacts to a later isolated Gradle/M3 run.

Do not execute the proposal.

## 9. Final classification

If an exact, bounded, non-forged acquisition/cache-fill contract is established:

`KOTLIN-GRADLE-PLUGIN 2.1.0 SOURCE-ACQUISITION CONTRACT ESTABLISHED — READY FOR OWNER-AUTHORIZED B12 ACQUISITION`

If the artifact source set is proven but safe cache injection/exposure is not:

`KOTLIN-GRADLE-PLUGIN 2.1.0 SOURCE SET ESTABLISHED — CACHE-FILL MECHANISM NOT YET PROVEN`

If source identity or required object set cannot be proven:

`KOTLIN-GRADLE-PLUGIN 2.1.0 SOURCE-ACQUISITION CONTRACT NOT PROVEN`

## 10. Explicit prohibitions

Do not run Flutter/Dart pub.
Do not run `flutter create`.
Do not delete/recreate `.android`.
Do not run Gradle/gradlew.
Do not run M3 or AAR probe.
Do not download/save/cache/fill any Maven artifact.
Do not mutate `C:/M3A/cache/gradle`.
Do not run M2 or product implementation.
Do not inspect default index/protected staged state and do not run default `git status`.

## 11. Result and stop

Create only:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_KOTLIN_PLUGIN_SOURCE_ACQUISITION_AND_CACHE_FILL_CONTRACT_RESULT_V0_1.md`

Record:

- authority;
- exact coordinate;
- authoritative repository/source URLs;
- exact object inventory;
- checksums/identity availability;
- direct dependency inventory;
- cache-fill mechanism decision;
- exact proposed B12 acquisition contract;
- final classification;
- all NOT_RUN / NOT_MODIFIED items.

Candidate sole parent must be this B11 task commit. Then STOP.
Do not self-accept or update `main`.