# EliteSync v10｜Post-R7 Module IDE Metadata Classification + Recreation Gate Review Task v0.1

Status: `PUBLISHED TASK SHEET — READ-ONLY CLASSIFICATION ONLY — NO RECREATION — NO PUB — NO M3 — NO M2`

## 1. Authority and goal

Current accepted main must be `e1bee0ff0fb8d0c89c7f0a5f45e92755e94b7116`.

B5 correctly stopped because five exact `templates/module/common` destinations were absent before recreation:

- `.idea/libraries/Dart_SDK.xml`
- `.idea/modules.xml`
- `.idea/workspace.xml`
- `flutter_elitesync_module_android.iml`
- `flutter_elitesync_module.iml`

This task determines only whether those five paths are generated/IDE metadata that may be safely created by Flutter's supported existing-module recreation flow, and whether the B5 protected gate may be narrowed to product-authored/root files without allowing unintended product mutation.

No file creation, recreation, pub, M3, Gradle resolution, AAR probe, M2, product implementation, or network access is authorized.

## 2. FIRST and exact inputs

1. Fresh-fetch `main`; if it is not exactly `e1bee0ff0fb8d0c89c7f0a5f45e92755e94b7116`, STOP `MAIN AUTHORITY CHANGED`.
2. FIRST read blob `18485c95262051e43892436fb52413132c5ee626`.
3. Read this task.
4. Read B5 result blob `ef5e49d60c0b066a3bee15d72a8a3054052eb710`.
5. Read B4 result blob `24693a27360cc2fbf09bbd152c022e55511dc0ce`.

## 3. Authorized local read scope

Fixed Flutter root:
`C:/M3A/tools/flutter`

Fixed Flutter-tools root:
`C:/M3A/tools/flutter/packages/flutter_tools`

Fixed guest module root:
`C:/M3A/work/apps/flutter_elitesync_module`

Read/search only the exact template and create/render sources needed to classify the five paths:

- `packages/flutter_tools/templates/module/common/**`
- `packages/flutter_tools/lib/src/commands/create.dart`
- `packages/flutter_tools/lib/src/commands/create_base.dart`
- `packages/flutter_tools/lib/src/template.dart`
- exact `.gitignore` template/source referenced by module/common if needed

One-hop follow is allowed only from an explicitly referenced exact local file.

Do not search the rest of the Flutter SDK.

## 4. Required classification questions

For each of the five missing paths, establish from fixed Flutter-tools source/template evidence:

1. exact template source path;
2. whether Flutter itself generates the destination during module creation/recreation;
3. whether the destination is IDE/project metadata rather than application/product source;
4. whether it is expected to be disposable/recreatable;
5. whether the module `.gitignore` or template policy excludes/ignores it, if applicable;
6. whether creation of that path can affect runtime/product behavior independently of generated project metadata.

Do not infer from filename alone.

## 5. Narrowed protected-state question

Determine whether a future recreation task may safely:

- allow creation/modification of only the five classified IDE/generated paths plus already accepted generated state (`.android/**`, `.ios/**`, `.dart_tool/**`, `.flutter-plugins-dependencies`, `pubspec.lock` only where Flutter pub legitimately updates it);
- continue protecting product-authored/root files including `.metadata`, `analysis_options.yaml`, `lib/**`, `test/**`, `assets/**` if present, `pubspec.yaml`, `README.md`, `.gitignore`;
- prohibit `--overwrite`;
- require before/after protected manifest equality for all protected paths.

If any of the five paths cannot be proven generated/disposable IDE metadata, identify it exactly and classify the gate as not safe to narrow.

## 6. Output classification

If all five are proven generated/disposable IDE metadata and a narrowed protected gate is supported, classify exactly:

`B5 PRODUCT ROOT GATE MAY BE NARROWED — FIVE MISSING PATHS ARE GENERATED IDE METADATA — READY FOR B7 RECREATION TASK`

If not all five can be proven, classify exactly:

`B5 PRODUCT ROOT GATE CANNOT YET BE NARROWED`

Do not execute recreation.

## 7. Boundaries

Do not modify any guest or host file.
Do not run Flutter/Dart pub.
Do not run `flutter create` or any regeneration.
Do not run M3, Gradle resolution, AAR probe, M2, or network/package fill.
Do not inspect default index/protected staged state and do not run default `git status`.

## 8. Result

Create only:
`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_MODULE_IDE_METADATA_CLASSIFICATION_AND_RECREATION_GATE_REVIEW_RESULT_V0_1.md`

Record exact files/templates inspected, per-path classification, narrowed protected-state decision, final classification, and all NOT_RUN items.

Candidate sole parent must be this task commit. Then STOP.
Do not self-accept or update `main`.