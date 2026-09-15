# EliteSync v10｜NEXT IP-11C Candidate Target-Family Declaration Read Task｜v0.1

Status: `OWNER-DELEGATED BOUNDED GOVERNANCE AUTHORIZED — READ-ONLY DECLARATION DISAMBIGUATION ONLY — NO TECHNOLOGY SELECTION — NO IMPLEMENTATION AUTHORITY`

Date: 2026-09-15 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `829d58d7ee87617307cce0c25be370ad50ec3446`

## 1. Purpose

Disambiguate the three IP-11B accepted candidate target-family locators by reading only a literal allowlist of minimum declaration/source-entry/test-entry files under those exact families.

This task may establish repository-declared technology, dependency, source-entry, test-entry and tool-version facts. It must not select a technology, acquire dependencies, run toolchains, build, test, execute code, inspect caches/artifacts, or authorize implementation.

## 2. Accepted candidate families

Only these three target-family roots are in scope:

- `apps/android/`
- `apps/flutter_elitesync_module/`
- `services/backend-laravel/`

Do not inspect any other repository root, sibling family, historical repository, generated/build/cache directory, or inferred path.

## 3. Exact literal read allowlist

### A. `apps/android/`

Probe/read only these exact paths if present:

1. `apps/android/settings.gradle`
2. `apps/android/settings.gradle.kts`
3. `apps/android/build.gradle`
4. `apps/android/build.gradle.kts`
5. `apps/android/app/build.gradle`
6. `apps/android/app/build.gradle.kts`
7. `apps/android/gradle.properties`
8. `apps/android/gradle/wrapper/gradle-wrapper.properties`
9. `apps/android/app/src/main/AndroidManifest.xml`
10. `apps/android/app/src/main/java/`
11. `apps/android/app/src/main/kotlin/`
12. `apps/android/app/src/test/`
13. `apps/android/app/src/androidTest/`

Directory locators 10–13 may be classified as present/absent only. Do not recursively enumerate or read source/test files inside them.

### B. `apps/flutter_elitesync_module/`

Probe/read only these exact paths if present:

14. `apps/flutter_elitesync_module/pubspec.yaml`
15. `apps/flutter_elitesync_module/pubspec.lock`
16. `apps/flutter_elitesync_module/analysis_options.yaml`
17. `apps/flutter_elitesync_module/.metadata`
18. `apps/flutter_elitesync_module/.fvmrc`
19. `apps/flutter_elitesync_module/.fvm/fvm_config.json`
20. `apps/flutter_elitesync_module/lib/main.dart`
21. `apps/flutter_elitesync_module/lib/app.dart`
22. `apps/flutter_elitesync_module/test/widget_test.dart`
23. `apps/flutter_elitesync_module/integration_test/`

Path 23 may be classified as present/absent only. Do not recursively enumerate or read files inside it.

### C. `services/backend-laravel/`

Probe/read only these exact paths if present:

24. `services/backend-laravel/composer.json`
25. `services/backend-laravel/composer.lock`
26. `services/backend-laravel/artisan`
27. `services/backend-laravel/phpunit.xml`
28. `services/backend-laravel/phpunit.xml.dist`
29. `services/backend-laravel/.env.example`
30. `services/backend-laravel/routes/api.php`
31. `services/backend-laravel/routes/web.php`
32. `services/backend-laravel/app/`
33. `services/backend-laravel/tests/`

Paths 32–33 may be classified as present/absent only. Do not recursively enumerate or read source/test files inside them.

## 4. Allowed facts to extract

From files that exist, extract only declaration-level facts necessary for target-family disambiguation:

- declared project/framework/language/tool identity;
- declared SDK/runtime/language version constraints;
- declared dependency names/version constraints;
- locked dependency presence/version facts where directly present;
- declared Gradle/plugin/Android SDK versions;
- declared Flutter/Dart SDK constraints;
- declared PHP/Laravel/PHPUnit constraints;
- declared source entrypoint locator;
- declared test-entry/test-root locator;
- explicit workspace/module names;
- explicit package/application identifiers where needed only to distinguish families;
- conflicts or ambiguity between declarations.

Do not extract business/domain implementation logic, routes/controllers/models/widgets/services, private data, secrets or production configuration.

For `.env.example`, only identify declared variable names/categories if needed to establish runtime/tooling shape; do not infer or reproduce secrets or production values.

## 5. Required distinctions

Preserve exactly:

`CANDIDATE LOCATOR != DECLARED TECHNOLOGY`

`DECLARED TECHNOLOGY != ACCEPTED TECHNOLOGY SELECTION`

`DEPENDENCY DECLARED != DEPENDENCY RESOLVED`

`LOCKFILE PRESENT != DEPENDENCY AVAILABLE`

`TOOL VERSION DECLARED != TOOL AVAILABLE`

`SOURCE ENTRY DECLARED != SOURCE BUILDS`

`TEST ENTRY DECLARED != TEST PASSES`

`MANIFEST DECLARATION != IMPLEMENTATION AUTHORITY`

## 6. Prohibited actions

Do not:

- recursively enumerate any family;
- repository-wide search;
- grep/ripgrep/find for alternative files;
- inspect files outside the exact allowlist;
- read implementation source beyond `lib/main.dart`, `lib/app.dart`, `routes/api.php`, or `routes/web.php` when those exact files are present;
- inspect Android Java/Kotlin source contents;
- inspect Laravel `app/` or `tests/` contents;
- inspect Flutter integration-test contents;
- invoke Flutter, Dart, Gradle, Java, Kotlin, PHP, Composer, Node, Python or backend runtimes;
- acquire/resolve/install dependencies;
- use network for dependency or tooling probes;
- build, test, run, migrate, generate, emulate or deploy;
- inspect package caches, build artifacts or generated outputs;
- access Sandbox, DEP13 or B12;
- reopen M1/M2/M3.

Required governance Git fetch/publication is outside the declaration-read probe.

## 7. Required family comparison

For each family, produce one declaration summary with:

- locator status;
- manifest/declaration files present/absent;
- declared technology/framework/language;
- declared version constraints;
- declared dependencies/lock presence;
- declared source entrypoint/root;
- declared test entry/root;
- declaration conflicts/ambiguities;
- what remains `NOT_CHECKED` / `NOT_RUN`.

Then compare the three families without selecting one.

## 8. Terminal outcome

End with exactly one:

### Outcome A
`ONE COHERENT DECLARED IMPLEMENTATION TARGET FAMILY IS DOMINANT / OTHERS ARE SUPPORTING OR EMBEDDED — READY FOR SEPARATE TECHNOLOGY-SELECTION REVIEW`

Use only if declarations explicitly establish one primary coherent target family and the others are clearly subordinate/supporting.

### Outcome B
`MULTIPLE INDEPENDENT DECLARED IMPLEMENTATION TARGET FAMILIES REMAIN — TECHNOLOGY/SLICE SELECTION DECISION REQUIRED`

Use if two or more independently executable target families remain plausible.

### Outcome C
`DECLARATION EVIDENCE INSUFFICIENT OR CONFLICTING — TARGET FAMILY STILL UNRESOLVED`

Use if the literal allowlist cannot establish enough facts or declarations conflict materially.

Do not select technology or an implementation slice under any outcome.

## 9. High-density validation

Include at least 150 independently checkable validation rows.

Report:

`PASS = N / RETAINED_UNKNOWN = N / BLOCKED = N`

List every retained unknown and blocker.

## 10. Execution facts

Preserve:

- `TOOL_AVAILABILITY = NOT_CHECKED`
- `DEPENDENCY_RESOLUTION = NOT_CHECKED`
- `BUILD = NOT_RUN`
- `TEST = NOT_RUN`
- `RUNTIME = NOT_RUN`
- `CACHE_ARTIFACT_STATE = NOT_CHECKED`
- M1 = exhausted
- M2 = deferred
- M3 = blocked
- DEP13/B12 = unauthorized/unestablished

## 11. Exact output and stop boundary

Create exactly:

`docs/architecture/ELITESYNC_V10_IP_11C_CANDIDATE_TARGET_FAMILY_DECLARATION_READ_RESULT_V0_1.md`

Recommended branch:

`review/next-ip-11c-candidate-target-family-declaration-read-v0-1`

Publish only that result file. Report branch/candidate/sole parent/tree/blob/scope and `git diff --check`, then STOP.

Do not self-accept, choose technology, acquire dependencies, run tools, implement, or start a successor task.
