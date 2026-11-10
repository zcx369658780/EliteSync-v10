# EliteSync v10｜Post-R7 Module IDE Metadata Classification + Recreation Gate Review Result v0.1

Status: `EXECUTED RESULT CANDIDATE — READ-ONLY CLASSIFICATION ONLY — NO RECREATION — NO PUB — NO M3 — NO M2`

## 1. Authority

- fresh-fetched GitHub `main`=`e1bee0ff0fb8d0c89c7f0a5f45e92755e94b7116`，与本任务固定 authority 精确一致。
- FIRST 文档先读，blob=`18485c95262051e43892436fb52413132c5ee626`，PASS。
- B6 task commit=`ce311b2861ccd51295e56b99ffe414b10459cbdb`；task path=`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_MODULE_IDE_METADATA_CLASSIFICATION_AND_RECREATION_GATE_REVIEW_TASK_V0_1.md`；task blob=`ff83d9812fab4c660e7240b7d9f344694203a938`。
- accepted B5 result blob=`ef5e49d60c0b066a3bee15d72a8a3054052eb710`，已读。
- accepted B4 result blob=`24693a27360cc2fbf09bbd152c022e55511dc0ce`，已读。

本结果只回答 B6 的五路径分类与未来 recreation gate 是否可收窄，不授权或执行 B7。

## 2. Fixed roots and Sandbox observation

- Flutter root=`C:\M3A\tools\flutter`
- Flutter-tools root=`C:\M3A\tools\flutter\packages\flutter_tools`
- guest module root=`C:\M3A\work\apps\flutter_elitesync_module`
- WSB CLI=`0.8.107.0`
- fresh observed running Sandbox count=`1`
- unique running Sandbox ID=`0087a898-5221-41df-a33d-65045ffea69a`

只对该 preserved Sandbox 内的精确白名单文件执行只读内容断言；未创建、share、materialize、stop、close、reset 或 kill Sandbox。Sandbox 中无文件被创建或修改。

## 3. Exact sources inspected

Flutter create/render implementation：

- `C:\M3A\tools\flutter\packages\flutter_tools\lib\src\commands\create.dart`
  - `_generateModule()` lines 657–675：将 `module/common` 渲染到给定 module directory，并传递 `overwrite`。
- `C:\M3A\tools\flutter\packages\flutter_tools\lib\src\commands\create_base.dart`
  - `renderTemplate()` lines 399–420：`overwrite` 默认 `false`，并作为 `overwriteExisting` 传入 `Template.render()`。
- `C:\M3A\tools\flutter\packages\flutter_tools\lib\src\template.dart`
  - lines 68–85：`.tmpl` 输出去除模板扩展名。
  - lines 280–307：输出路径去除 `.tmpl` 并将路径中的 `projectName` 替换为实际项目名。
  - lines 327–350：目标已存在且 `overwriteExisting=false` 时跳过；目标缺失时标记为 created 并递归创建。

Exact module/common templates：

- `C:\M3A\tools\flutter\packages\flutter_tools\templates\module\common\.idea\libraries\Dart_SDK.xml.tmpl`
- `C:\M3A\tools\flutter\packages\flutter_tools\templates\module\common\.idea\modules.xml.tmpl`
- `C:\M3A\tools\flutter\packages\flutter_tools\templates\module\common\.idea\workspace.xml.tmpl`
- `C:\M3A\tools\flutter\packages\flutter_tools\templates\module\common\projectName_android.iml.tmpl`
- `C:\M3A\tools\flutter\packages\flutter_tools\templates\module\common\projectName.iml.tmpl`
- `C:\M3A\tools\flutter\packages\flutter_tools\templates\module\common\.gitignore.tmpl`

One-hop implementation files followed=`NONE`。没有搜索 Flutter SDK 其余范围。

## 4. Common generation and recreation contract

上述 implementation source 共同证明：

1. module create/recreation 调用 `_generateModule()`，其 exact template root 是 `module/common`，destination 是现有 module root；
2. `.tmpl` 后缀从 destination path 去除；路径中的 `projectName` 被替换为当前项目名；
3. 因此五个 exact template 分别映射到本任务五个 exact missing destinations；
4. 不传 `--overwrite` 时，已存在 destination 不会被删除或重写，而缺失 destination 会从模板创建；
5. 因而五个 destination 均是 Flutter 自身的 module/common 模板输出，并且在缺失时可由同一受支持流程重新创建。

这只证明五个路径的生成／重建属性；没有执行 create 或验证一次未来 B7 的实际 post-state。

## 5. Per-path classification

| destination | exact Flutter template | Flutter generates on module create/recreation | IDE/project metadata evidence from template content | disposable/recreatable | `.gitignore` / generated-state evidence | independently changes runtime/product behavior |
| --- | --- | --- | --- | --- | --- | --- |
| `.idea/libraries/Dart_SDK.xml` | `templates/module/common/.idea/libraries/Dart_SDK.xml.tmpl` | YES | XML contains `libraryTable`, library name `Dart SDK`, and `<CLASSES>` library roots；这是 IDE library table/index configuration，不是 Dart product source | YES；缺失时由 `module/common` render 创建 | `.idea/` 在 exact `.gitignore.tmpl` 中被明确忽略 | NO；单独创建只恢复 IDE 的 Dart SDK library/index metadata，不改变受保护应用源码或 manifest |
| `.idea/modules.xml` | `templates/module/common/.idea/modules.xml.tmpl` | YES | XML component=`ProjectModuleManager`，其 module entries只指向 `{{projectName}}.iml` 与 `{{projectName}}_android.iml`；这是 IDE project-to-module registration | YES；缺失时由 `module/common` render 创建 | `.idea/` 被明确忽略 | NO；单独创建只恢复 IDE module registration，不创建或修改运行时代码 |
| `.idea/workspace.xml` | `templates/module/common/.idea/workspace.xml.tmpl` | YES | XML project contains component=`PropertiesComponent`；这是 IDE workspace/property state | YES；缺失时由 `module/common` render 创建 | `.idea/` 被明确忽略 | NO；单独创建只恢复 IDE workspace properties，不改变受保护产品输入 |
| `flutter_elitesync_module_android.iml` | `templates/module/common/projectName_android.iml.tmpl` | YES；`projectName_android.iml.tmpl` 经 path substitution 得到该 destination | XML `<module>` contains `FacetManager`、`NewModuleRootManager`，并声明 `.android` manifest/resources/assets/libs/source/generated folders；这是 Android/IntelliJ module model metadata | YES；缺失时由 `module/common` render 创建 | exact `.gitignore.tmpl` 未发现 `.iml` ignore rule；其 generated-state authority来自 exact Flutter template + create/render contract，而非 ignore rule | NO；单独创建只描述 IDE 如何看待已生成的 `.android` tree，不生成产品实现，也不改变受保护源码或 pubspec |
| `flutter_elitesync_module.iml` | `templates/module/common/projectName.iml.tmpl` | YES；`projectName.iml.tmpl` 经 path substitution 得到该 destination | XML `<module type="JAVA_MODULE">` contains `NewModuleRootManager`，将 `lib`/`test` 标为 IDE source roots并排除 `.dart_tool`/`.idea`/`build`；这是 IntelliJ module model metadata | YES；缺失时由 `module/common` render 创建 | exact `.gitignore.tmpl` 未发现 `.iml` ignore rule；其 generated-state authority来自 exact Flutter template + create/render contract，而非 ignore rule | NO；单独创建只恢复 IDE source-root/index model，不修改这些 source roots中的文件或产品配置 |

五个模板内容均为 XML IDE 配置；没有一个包含 Dart application implementation、asset payload、pubspec dependency declaration、Flutter project metadata authority或 Gradle product build script。故在 B6 所问的“单独创建该路径”边界内，五者均不能独立改变 runtime/product behavior。此结论不把 IDE 行为等同于产品行为，也不放宽其他路径。

## 6. Narrowed future protected-state decision

五个路径全部已证明为 Flutter-generated、disposable/recreatable IDE metadata，因此未来 B7 可考虑把 allowed mutation set 严格限制为：

- `.idea/libraries/Dart_SDK.xml`
- `.idea/modules.xml`
- `.idea/workspace.xml`
- `flutter_elitesync_module_android.iml`
- `flutter_elitesync_module.iml`
- `.android/**`
- `.ios/**`
- `.dart_tool/**`
- `.flutter-plugins-dependencies`
- `pubspec.lock`，仅限 legitimate Flutter pub 实际更新时

以下路径必须继续受保护：

- `.metadata`
- `analysis_options.yaml`
- `pubspec.yaml`
- `README.md`
- `.gitignore`
- `lib/**`
- `test/**`
- `assets/**`（如存在）
- 任一未被明确分类为 generated 的其他 product-authored path

未来 recreation 还必须同时满足：

- `--overwrite` 保持禁止；
- 执行前后对全部 protected paths 建立 manifest，并要求 exact equality；
- mutation 超出上述 allowlist 时 fail closed；
- 本结果只支持创建／修改五个已分类 IDE paths 和已接受 generated state，不支持删除、覆盖或重写 protected paths。

## 7. Final classification

`B5 PRODUCT ROOT GATE MAY BE NARROWED — FIVE MISSING PATHS ARE GENERATED IDE METADATA — READY FOR B7 RECREATION TASK`

这不是 B7、recreation、pub、M3 或 M2 的执行授权。

## 8. Explicit NOT_RUN / NOT_MODIFIED

- Flutter pub=`NOT_RUN`
- Dart pub=`NOT_RUN`
- Flutter-tools pub=`NOT_RUN`
- `flutter create` / regeneration=`NOT_RUN`
- five missing destination creation=`NOT_RUN`
- Gradle resolution=`NOT_RUN`
- M3=`NOT_RUN`
- AAR probe=`NOT_RUN`
- M2=`NOT_RUN`
- network/package fill/download/install=`NOT_RUN`
- product implementation=`NOT_RUN`
- guest file modification=`NOT_RUN`
- host SDK/cache/source modification=`NOT_RUN`
- Sandbox create/share/materialize/stop/close/reset/kill=`NOT_RUN`
- default `git status` / default index inspection=`NOT_RUN`
- self-accept / acceptance commit / `main` update=`NOT_RUN`

本候选只记录 B6 只读分类结果，等待 fresh 独立 ACCEPT/REJECT。
