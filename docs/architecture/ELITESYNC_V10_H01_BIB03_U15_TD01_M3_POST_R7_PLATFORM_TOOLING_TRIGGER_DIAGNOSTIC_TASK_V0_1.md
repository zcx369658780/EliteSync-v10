# EliteSync v10｜Post-R7 Platform Tooling Trigger Diagnostic Task v0.1

Status: `PUBLISHED TASK SHEET — READ-ONLY CONTROL-FLOW DIAGNOSTIC — NO RECREATION — NO PUB — NO M3 — NO M2`

## 1. Authority and goal

Current accepted main must be `396eae8ceb1441b332c14063f8a898495dba8ca8`.

Accepted B7 established that exactly one supported existing-module recreation exited 0, created only the five B6-classified IDE metadata files, preserved all protected non-generated state byte-for-byte, but generated none of the four authorized `.android` Gradle sentinels. Therefore the remaining question is not recreation safety; it is why the fixed Flutter-tools control flow did not reach or did not perform Android platform tooling generation for this existing module.

This task is READ-ONLY. Its sole goal is to identify the exact control-flow condition, project/platform state, or regeneration predicate that explains the B7 observed behavior and to produce one exact next-command/action proposal for a later execution task.

No recreation, pub, generation, M3, Gradle resolution, AAR probe, M2, product implementation, or network access is authorized.

## 2. FIRST and exact inputs

1. Fresh-fetch `main`; if it is not exactly `396eae8ceb1441b332c14063f8a898495dba8ca8`, STOP `MAIN AUTHORITY CHANGED`.
2. FIRST read blob `18485c95262051e43892436fb52413132c5ee626`.
3. Read this task.
4. Read accepted B7 result blob `14445a7b4c0928c4ffb67943aa1ac9e8ebceb130`.
5. Read accepted B4 result blob `24693a27360cc2fbf09bbd152c022e55511dc0ce` only for prior generation-contract claims.
6. Read accepted B6 result blob `755b2073389fe0f908dfe110b7b40d416f470ac1` only for narrowed generated-state classification.

Do not perform repository-wide, host-wide, alternate-module, or whole-Flutter-SDK search.

## 3. Fixed local roots

Preserved Sandbox ID:
`0087a898-5221-41df-a33d-65045ffea69a`

Flutter root:
`C:/M3A/tools/flutter`

Flutter-tools root:
`C:/M3A/tools/flutter/packages/flutter_tools`

Guest module root:
`C:/M3A/work/apps/flutter_elitesync_module`

Fresh-observe that exactly one Sandbox remains running and it is the fixed ID. Do not create, stop, close, reset, kill, share, or materialize anything.

## 4. Authorized Flutter-tools read scope

Read only the exact implementation files needed to trace the existing-module `create` control flow and Android regeneration predicates:

- `packages/flutter_tools/lib/src/commands/create.dart`
- `packages/flutter_tools/lib/src/commands/create_base.dart`
- `packages/flutter_tools/lib/src/runner/flutter_command.dart`
- `packages/flutter_tools/lib/src/project.dart`
- `packages/flutter_tools/lib/src/flutter_project_metadata.dart`
- `packages/flutter_tools/lib/src/flutter_manifest.dart`
- `packages/flutter_tools/lib/src/template.dart`
- `packages/flutter_tools/lib/src/flutter_plugins.dart`
- `packages/flutter_tools/lib/src/xcode_project.dart` only if required to distinguish Android/iOS platform selection

One-hop follow is allowed only when one of these exact files explicitly references another exact local implementation symbol/file needed to resolve a control-flow condition. Record each followed file. Do not search other Flutter SDK directories.

## 5. Required control-flow reconstruction

Reconstruct the exact branch actually applicable to the B7 command:

`create --template=module --offline .`

At minimum establish, from source:

1. how `CreateCommand.runCommand()` determines existing project type;
2. how requested template `module` is reconciled with `.metadata` project type;
3. whether `_generateModule()` alone is sufficient to produce the B7 stdout observed (`Wrote 5 files` + pub), or whether a later platform-tooling branch should always follow;
4. exact condition guarding `pub.get(...)`;
5. exact condition guarding any call to `ensureReadyForPlatformSpecificTooling(...)` or equivalent;
6. exact values passed for `androidPlatform` / `iosPlatform` / platform list;
7. whether host platform, requested platforms, `platforms` option defaults, existing `.android`/`android` state, project metadata, or any other predicate can suppress Android generation;
8. whether the command's successful return can occur after common template render + pub without platform tooling preparation, and under exactly what condition.

Do not rely on prior B4 interpretation if current source shows a narrower or different condition.

## 6. Exact current module metadata/state reads

Read only the exact current module files/fields required by the control-flow predicates identified above.

At minimum, if used by source logic, inspect only relevant fields from:

- `C:/M3A/work/apps/flutter_elitesync_module/.metadata`
- `C:/M3A/work/apps/flutter_elitesync_module/pubspec.yaml`

And exact existence/state predicates only for:

- `C:/M3A/work/apps/flutter_elitesync_module/android`
- `C:/M3A/work/apps/flutter_elitesync_module/.android`
- `C:/M3A/work/apps/flutter_elitesync_module/ios`
- `C:/M3A/work/apps/flutter_elitesync_module/.ios`
- the five B6 IDE metadata files

Do not broadly enumerate these directories unless a specific source predicate requires one exact child path. Do not inspect `lib/**`, tests, assets, or product implementation.

## 7. Reconcile source contract with B7 observation

B7 observed exactly:

- recreation exit 0;
- stdout created only five IDE metadata files;
- pub dependency resolution succeeded;
- protected state remained byte-identical;
- `.android/settings.gradle`, `.android/settings.gradle.kts`, `.android/build.gradle`, `.android/build.gradle.kts` all remained absent;
- M3 was not run.

Explain which exact source branch makes this observation possible.

The result must identify one of the following, or a narrower source-proven equivalent:

- `PLATFORM_SELECTION_EXCLUDES_ANDROID`
- `PLATFORM_TOOLING_PREPARE_BRANCH_NOT_REACHED`
- `ANDROID_REGENERATION_PREDICATE_FALSE`
- `ANDROID_REGENERATION_TARGET_DIFFERENT_FROM_EXPECTED_SENTINELS`
- `CURRENT_SOURCE_BEHAVIOR_DIFFERS_FROM_B4_CONTRACT`
- another exact code-backed classification

Do not infer a failure category without source evidence.

## 8. Exact next action proposal

If the cause is proven, provide one exact bounded proposal for a future B9 execution task, but do not execute it.

The proposal must specify:

- exact executable;
- full command/argument shape or exact internal supported action;
- cwd;
- environment roots;
- whether pub must be enabled/disabled;
- whether `--platforms=android` or another platform selector is required and source-supported;
- exact generated paths expected;
- protected-state pre/post gate;
- exact `.android` Gradle sentinels to verify;
- whether a conditional single direct-snapshot M3 may follow.

If no supported bounded action can be proven, classify the blocker instead and do not invent a command.

## 9. Final classification

If the exact skip/suppression cause and a supported bounded next action are both established, classify:

`MODULE_ANDROID_PLATFORM_TOOLING_TRIGGER CAUSE ESTABLISHED — READY FOR B9 EXECUTION TASK`

If cause is established but no safe supported next action is proven:

`MODULE_ANDROID_PLATFORM_TOOLING_TRIGGER CAUSE ESTABLISHED — EXECUTION PATH NOT YET AUTHORIZED`

If the source budget cannot prove the cause:

`MODULE_ANDROID_PLATFORM_TOOLING_TRIGGER CAUSE NOT PROVEN`

## 10. Explicit prohibitions

Do not run Flutter/Dart pub.
Do not run `flutter create` or any recreation/regeneration command.
Do not create/modify/delete `.android`, `.ios`, IDE metadata, `.dart_tool`, lockfiles, or product files.
Do not run M3, Gradle resolution, AAR probe, M2, network/download/package fill, or product implementation.
Do not inspect default index/protected staged state and do not run default `git status`.

## 11. Result and stop

Create only:
`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_PLATFORM_TOOLING_TRIGGER_DIAGNOSTIC_RESULT_V0_1.md`

Record:

- authority and Sandbox observation;
- exact source files/symbols inspected;
- any one-hop files followed;
- exact current metadata/state values read;
- reconstructed create/platform-tooling control flow;
- reconciliation with B7 observed stdout/state;
- exact cause classification;
- exact proposed B9 action if supported;
- all NOT_RUN / NOT_MODIFIED items.

Candidate sole parent must be this B8 task commit. Then STOP.
Do not self-accept or update `main`.