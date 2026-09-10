# EliteSync v10｜Post-R7 Module Android Generation Contract Review Result v0.1

Status: `PROPOSED — AWAITING FRESH INDEPENDENT REVIEW — GENERATION CONTRACT ESTABLISHED — NO GENERATION — NO M3 — NO AAR PROBE — NO M2`

日期：2026-09-10（Asia/Shanghai）。

## 1. 最终结论

固定 guest Flutter-tools 源码证明：普通 `flutter pub get` 不负责生成 module 的 `.android`。`BuildAarCommand` 不在 verify 阶段自行 regeneration，而是把 generation callback 交给 Android builder；该 callback 在 `--no-pub` 时必定直接返回。对 module，`AndroidProject.existsSync()` 无条件以 `parent.isModule` 为真，因此正常 `build aar` 的 callback 能把 Android 纳入 regeneration；B2 的 `--no-pub` 正是绕过该 prepare 的决定性开关。B2 随后在 `.android` 不存在时进入 Gradle 并失败，与源码合约一致。

对一个已有 module，Flutter 支持的修复入口是 `flutter create` 对现有项目的 recreation 路径。必须保留默认 `--pub`，并用 `--offline` 将 pub 限定为既有 cache；`--no-pub` 会同时跳过随后明确调用的 `ensureReadyForPlatformSpecificTooling(...)`，不能生成 `.android`。module recreation 会请求 Android 和 iOS 两个平台，因此预期写入不只 `.android/**`，还包括 `.ios/**` 及 module-level generated dependency/plugin state。

只要 B5 在执行前证明所有 `templates/module/common` 的 product/root destinations 已存在、禁止 `--overwrite`，并以非生成区 manifest 做前后哨兵，就可以把写范围限定为 guest-local generated state；若任一 product/root destination 缺失，则必须在执行前停止。当前 B4 没有执行这些 B5 precondition checks，也没有运行 proposal。

最终分类：

`MODULE_DOT_ANDROID_GENERATION_CONTRACT_ESTABLISHED — READY FOR B5 EXECUTION TASK`

该结论只授权 fresh 独立审查，不授权 B5、generation、M3、AAR probe 或 M2。

## 2. Authority 与 Sandbox observation

- fresh-fetch GitHub `main`=`7818c554d9547ecfd851b9dcc25a56a3a4d71720`，精确匹配。
- FIRST blob=`18485c95262051e43892436fb52413132c5ee626`，已首先完整读取并匹配。
- B4 task commit=`920bfacafb40ae7b981c65a5340357efe9f0504c`；task blob=`3c224fb59f5c7d58305abd43a8c8e73390d9c63b`。
- accepted B3 result blob=`e7e6be75cb778f737e47e47077beb47d79793375`，已读。
- accepted B2 result blob=`071b8b5cab38c6dc9121d3e4bf36d469f0010849`，已读。
- WSB CLI=`0.8.107.0`。
- observed running Sandbox count=`1`；唯一 ID=`0087a898-5221-41df-a33d-65045ffea69a`。
- Sandbox create/stop/close/reset/kill=`NOT_RUN`。
- Flutter root=`C:\M3A\tools\flutter`；Flutter-tools root=`C:\M3A\tools\flutter\packages\flutter_tools`；module root=`C:\M3A\work\apps\flutter_elitesync_module`。
- repository-wide search、host-wide search、default index/protected staged-state inspection、default `git status`=`NOT_RUN`。

## 3. Bounded source inspection

限定 textual search 只覆盖任务授权的五个 areas，terms 只使用 task allowlist：

- searched file count=`132`；match count=`1069`。
- 完整 searched-file 与 match inventory 记录于 `b4-bounded-search.json`。
- 读取并用于结论的授权文件／符号：
  - `lib/src/commands/build.dart`：`BuildCommand` 注册 `BuildAarCommand`。
  - `lib/src/commands/build_aar.dart`：`BuildAarCommand`、`validateCommand()`、`regeneratePlatformSpecificToolingDuringVerify`、`runCommand()`。
  - `lib/src/commands/create.dart`：`CreateCommand`、`_getProjectType()`、`runCommand()`、`_generateModule()`。
  - `lib/src/commands/create_base.dart`：`addPubOptions()`、`shouldCallPubGet`、`offline`、`determineTemplateType()`、`renderTemplate()`。
  - `lib/src/project.dart`：`FlutterProject.regeneratePlatformSpecificTooling()`、`ensureReadyForPlatformSpecificTooling()`、`AndroidProject.ensureReadyForPlatformSpecificTooling()`、`_shouldRegenerateFromTemplate()`、`_regenerateLibrary()`、`_overwriteFromTemplate()`。
  - `lib/src/flutter_project_metadata.dart`：`FlutterTemplateType.module`、`FlutterProjectMetadata.projectType` parsing。
  - `lib/src/template.dart`：`Template.render()` 的 existing-file skip / overwrite contract。
  - `templates/module/README.md`、`templates/module/common/.metadata.tmpl`、`templates/module/common/pubspec.yaml.tmpl`、`templates/module/android/gradle/build.gradle.tmpl`、`templates/module/android/host_app_ephemeral/settings.gradle.tmpl`、`templates/module/android/host_app_common/app.tmpl/build.gradle.tmpl`、`templates/module/android/library_new_embedding/Flutter.tmpl/build.gradle.tmpl`。

按授权文件的显式 imports／symbols 做了以下 one-hop follow，并记录为全部 followed files：

- `lib/src/runner/flutter_command.dart`：`shouldRunPub`、`verifyThenRunCommand()`、`regeneratePlatformSpecificToolingDuringVerify`、`regeneratePlatformSpecificToolingIfApplicable()`。
- `lib/src/android/android_builder.dart`：`AndroidBuilder.buildAar(...)` required `generateTooling` callback contract；该文件是 abstract interface，没有继续搜索未显式定位的 concrete implementation。
- `lib/src/flutter_manifest.dart`：`appName`、`usesAndroidX`、`isModule`、`androidPackage`。
- `lib/src/flutter_plugins.dart`：`refreshPluginsList()`、`injectPlugins()`、generated registrants 和 `.flutter-plugins-dependencies`。
- `lib/src/xcode_project.dart`：`IosProject.ensureReadyForPlatformSpecificTooling()`、`_regenerateModuleFromTemplateIfNeeded()`、`.ios` destinations。

没有搜索 Flutter SDK 的其他区域；没有读取 module application source 或技术语义。

## 4. `build aar` exact code contract

1. `BuildAarCommand` 通过 `usesPubOption()` 提供 `--pub/--no-pub`，并在 `validateCommand()` 要求 `project.manifest.isModule`。
2. 一般 `FlutterCommand.verifyThenRunCommand()` 在 `shouldRunPub` 时先执行 pub；默认还调用 `regeneratePlatformSpecificToolingIfApplicable(...)`。
3. `BuildAarCommand.regeneratePlatformSpecificToolingDuringVerify => false`，所以 build-aar verify 不走默认 regeneration。
4. `BuildAarCommand.runCommand()` 将 `regeneratePlatformSpecificToolingIfApplicable` 作为 `generateTooling` callback 传给 `androidBuilder.buildAar(...)`。
5. callback 的第一项逻辑是 `if (!shouldRunPub) return;`；只有 `shouldRunPub=true` 时才调用 `project.regeneratePlatformSpecificTooling(...)`。
6. `FlutterProject.regeneratePlatformSpecificTooling()` 对 `android.existsSync()` 为真的项目请求 Android regeneration。`AndroidProject.existsSync()` 返回 `parent.isModule || editable android exists`，所以 module 即使尚无 `.android` 也会被选入；其 `ephemeralDirectory` 是 module root 下 `.android`。B2 使用 `--no-pub`，使 callback 在该 selection 前必定 no-op；Gradle 下游看到不存在的 build 是预期结果。

结论：正常 `build aar` 具有 module Android regeneration callback，但会继续进入 AAR/Gradle build，不是只做 generation 的窄执行命令；`build aar --no-pub` 则要求所需 `.android` 已被先行建立。未运行 `build aar`。

## 5. Exact generation mechanism

### 5.1 Existing-module recreation

`CreateCommand` 明确说明：对已存在项目运行时会 repair/recreate missing files。其 exact sequence 为：

1. `_getProjectType()` 读取 `.metadata` 并由 `determineTemplateType()` 得到 `module`；显式 `--template=module` 必须与检测结果一致。
2. `_generateModule()` 将 `templates/module/common` 渲染到 module root。
3. 未传 `--overwrite` 时，`Template.render()` 对每个已经存在的 destination 执行 `existing - skipped`，不删除、不重写。
4. `shouldCallPubGet=true` 时，`CreateCommand` 调用 `pub.get(... offline: offline)`。
5. pub 成功后，create 自身另行调用 `project.ensureReadyForPlatformSpecificTooling(androidPlatform: true, iosPlatform: true, ...)`。因此 generation 是 create 的显式 post-pub prepare，不是 pub 的职责。
6. Android prepare 在 `_shouldRegenerateFromTemplate()` 为真时先递归删除 guest module `.android`，再从 `module/android/library_new_embedding` 与 `module/android/gradle` 重建，并注入 Gradle wrapper；若没有 editable `android/`，还渲染 `host_app_common` 与 `host_app_ephemeral`。
7. iOS prepare 同理对 module `.ios` 做 managed regeneration；create 的 module branch 固定 `includeIos=true` 与 `includeAndroid=true`，所以 `.ios` 被明确牵涉。
8. `refreshPluginsList()` / `injectPlugins()` 写 generated plugin metadata、registrants 和 platform-specific generated locations。

### 5.2 `--no-pub` 与 ordinary pub

- `create --no-pub`：`shouldCallPubGet=false`，包住 post-pub `ensureReadyForPlatformSpecificTooling(...)` 的整个分支被跳过，不能生成 `.android`。
- ordinary `flutter pub get`：只解析／写 package state；源码中真正的 platform prepare 是 create 或 Flutter command regeneration 明确额外调用。B3 的 offline pub exit `0` 后四个 `.android` sentinels 仍全 false，正好印证此分工。
- `flutter create --template=module`：对新 module 会创建 common root files，再通过 pub + prepare 建立 ephemeral platform projects；对当前已有 module，正确使用方式是 recreation with no overwrite，而不是创建另一个 module 或手工复制 templates。

## 6. Required module metadata

只读取了源码证明必要的两个 current module metadata files：

| exact file | relevant field/value | Flutter-tools use | Length | SHA-256 |
| --- | --- | --- | ---: | --- |
| `C:\M3A\work\apps\flutter_elitesync_module\.metadata` | `project_type: module`；`version.revision: 2c9eb20739dfec95e2c74bd3dfa4601b0a8a36aa`；`version.channel: stable` | create 的 `determineTemplateType()` / requested-template consistency gate | 322 | `642A4F86346D736DA5DE3CEB2CC8F53FBD845C2081D45712B998FE3E99F12FA2` |
| `C:\M3A\work\apps\flutter_elitesync_module\pubspec.yaml` | `name: flutter_elitesync_module`；`flutter.module.androidX: true`；`androidPackage: com.elitesync.flutter_elitesync_module`；`iosBundleIdentifier: com.elitesync.flutterElitesyncModule` | `FlutterManifest.isModule`、template `projectName`、AndroidX、Android/iOS identifiers | 1984 | `ECBC74EF27D949712532409EADC6BE0928EA56C9CBC603EB0C80FBE0CEC7E6BC` |

Observed metadata 足以判定 existing project 是 module，并提供 Android/iOS template context。未读取 `lib/**`、tests、assets 或其他 module contents。

## 7. Exact write scope and boundedness

### 7.1 Expected generated writes

- Android ephemeral project：`C:\M3A\work\apps\flutter_elitesync_module\.android\**`，包括至少：
  - `.android\settings.gradle`
  - `.android\build.gradle`
  - `.android\Flutter\build.gradle`
  - `.android\gradle\wrapper\gradle-wrapper.properties`
  - generated local properties、host app、wrapper 与 plugin registrant files。
- iOS ephemeral project：`C:\M3A\work\apps\flutter_elitesync_module\.ios\**`，包括 generated library/host/plugin files。
- dependency/plugin generated state：module root 的 `.dart_tool\**`、`pubspec.lock`、`.flutter-plugins-dependencies`，以及 `.android/.ios` 内的 plugin registrants/symlinks。它们必须与 product-authored files 分开记录。

### 7.2 Product/root template destinations

`_generateModule()` 还会尝试 repair 以下 `templates/module/common` destinations：

`.gitignore`、`.idea/libraries/Dart_SDK.xml`、`.idea/modules.xml`、`.idea/workspace.xml`、`.metadata`、`analysis_options.yaml`、`lib/main.dart`、`flutter_elitesync_module_android.iml`、`flutter_elitesync_module.iml`、`pubspec.yaml`、`README.md`、`test/widget_test.dart`。

这些不是本任务可任意改写的 `.android/.ios` ephemeral scope。由于 `Template.render()` 在不传 `--overwrite` 时只跳过“已经存在”的 destination，B5 必须在启动 command 前逐一证明上述 exact destinations 已存在；任一缺失都必须先停止，不能运行 create。B4 未检查这些 module files，因此没有声称该 precondition 当前已 PASS。

在该 precondition PASS、禁止 `--overwrite`、并将 generated allowlist 与其余 module tree 分离做前后 manifest 的条件下，command 可被限定为只改变 guest-local ephemeral/generated paths；host fixed module source不受影响，因为 action 只针对已经 materialized 的 guest copy。

## 8. Offline feasibility

- create 的 `addPubOptions()` 明确提供 `--offline`，并把该值传给 `pub.get(... offline: offline)`；帮助文本说明 offline 模式要求 dependencies 已存在于 pub cache。
- accepted B2 已证明 Flutter-tools local package_config context PASS，`coverage=1.15.0`、`code_builder=4.11.1` 均绑定 guest Pub cache；accepted B3 又证明当前 module 的 direct-snapshot `pub get --offline` exit=`0`。
- guest active adapter count=`0`、default route count=`0`；proposal 不允许 network/download/package fill。
- 因此同一 fixed module、fixed pubspec 与 guest Pub cache 下，generation action 具有 offline/no-package-fill 可行性。B5 仍须 fail closed：offline pub 非零、URL/socket/DNS/connection diagnostic、cache/source identity drift 任一出现即停止，不尝试联网或补包。

## 9. Exact B5 command proposal（未执行）

### 9.1 Executable / args / cwd

- executable：`C:\M3A\tools\flutter\bin\cache\dart-sdk\bin\dart.exe`
- complete args：`--packages="C:\M3A\tools\flutter\packages\flutter_tools\.dart_tool\package_config.json" "C:\M3A\tools\flutter\bin\cache\flutter_tools.snapshot" --no-version-check create --template=module --offline .`
- cwd：`C:\M3A\work\apps\flutter_elitesync_module`
- 明确不传：`--overwrite`、`--no-pub`。
- invocation budget：B5 最多一次；B4 invocation count=`0`。

### 9.2 Guest-local environment roots

- `FLUTTER_ROOT=C:\M3A\tools\flutter`
- `PUB_CACHE=C:\M3A\cache\pub`
- `ANDROID_HOME=C:\M3A\tools\android`
- `ANDROID_SDK_ROOT=C:\M3A\tools\android`
- `JAVA_HOME=C:\M3A\tools\jdk`
- Git PATH root=`C:\M3A\tools\git\cmd`
- `GRADLE_USER_HOME=C:\M3A\cache\gradle`
- principal=`NT AUTHORITY\SYSTEM`；Windows PowerShell=`5.1.26100.9444`；process/effective execution policy=`RemoteSigned`。

### 9.3 Mandatory preconditions

1. fresh authority、FIRST、B5 task、唯一 preserved Sandbox ID 与全部 fixed tool/cache/module identities匹配；adapter/default route counts 都为 `0`。
2. `.metadata` 与 `pubspec.yaml` 必须分别匹配本结果的 exact SHA-256，并重新确认 module fields。
3. Flutter-tools package_config 的 `coverage` / `code_builder` local roots、Flutter snapshot SHA-256 与 B2 identity保持一致。
4. 上述 12 个 common-template destinations 全部存在；任一缺失立即停止，不执行 create。
5. 不得存在 editable `android/` 或 `ios/` 对 bounded output 产生歧义；若存在，按 B5 明确 blocker 停止。
6. 生成 pre-command manifests：
   - generated allowlist：`.android/**`、`.ios/**`、`.dart_tool/**`、`.flutter-plugins-dependencies`、`pubspec.lock`；
   - protected remainder：module tree 排除上述 generated allowlist 后的 relative path + length + SHA-256 ordinal manifest。
7. 记录四个 fixed `.android` Gradle sentinels 的 pre-state；不得 broad repair、手工 template copy 或 `gradlew init`。

### 9.4 Mandatory post-generation sentinels

1. process exit=`0`，且没有 genuine URL/socket/DNS/connection failure diagnostic；不得 retry。
2. `.android\settings.gradle` 或 `.android\settings.gradle.kts` 至少一个存在；`.android\build.gradle` 或 `.android\build.gradle.kts` 至少一个存在；同时 `.android\Flutter\build.gradle` 与 Gradle wrapper properties 存在。
3. 记录 `.android/**` 与 `.ios/**` 的 bounded relative path/length/SHA-256 manifests，以及 `.dart_tool`、lockfile、plugin metadata 的变更分类。
4. protected remainder manifest 必须与 pre-command manifest逐项完全一致；特别是 `.metadata`、`pubspec.yaml`、`lib/**`、tests、assets 与其他 product-authored files 不得改变。
5. Flutter snapshot、SDK/cache roots、adapter/default route state保持不变；不运行 M3、Gradle resolution 或 AAR probe。

## 10. Explicit NOT_RUN

- Flutter pub / Dart pub / Flutter-tools pub=`NOT_RUN`。
- `flutter create` / project regeneration / `.android` or `.ios` generation=`NOT_RUN`；proposal invocation count=`0`。
- `.android` create/modify/delete=`NOT_RUN`；manual template copy / `gradlew init`=`NOT_RUN`。
- direct-snapshot M3=`NOT_RUN`。
- Gradle resolution=`NOT_RUN`。
- AAR probe=`NOT_RUN` / `NOT_CHECKED`。
- M2=`NOT_RUN`。
- network/download/package fill=`NOT_RUN`。
- product implementation=`NOT_RUN`。
- host/guest Flutter SDK、module、SDK/cache roots、host sources modification=`NOT_RUN`。
- self-accept、acceptance commit、`main` update=`NOT_RUN`。

## 11. Evidence

Task-owned evidence root：

`C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-M3A-ca1bcb9c89504e2ba4a5a347d16fc940\b4`

| artifact | Length | SHA-256 |
| --- | ---: | --- |
| `M3A-B4-BoundedSearch.ps1` | 1828 | `9E03B9845733FE79BE4671ECD9E37F7BA24A6EB6A318AC16FFC78FA472F0F916` |
| `b4-bounded-search.json` | 363968 | `580DFCFE7CB7C1453ECABE566A45809F2664C1A9768E10242E7BE165CE2C1C4F` |
| `M3A-B4-ExtractSlices.ps1` | 2634 | `1595E9C98804F0B4EFD6285DC3EDCEDEDCB93B6EDC054B94C5BB41B0F470F6A3` |
| `b4-source-slices.json` | 187727 | `05E7429BF9715B4835EED9AD39EF7BBEC84DB617407654C2B579CD9633194BF5` |
| `M3A-B4-OneHopAndMetadata.ps1` | 4597 | `7E470DFDE690F8221E4B85A5332B3F736E298BAEE1BF73B481F2AABD8A132BB2` |
| `b4-one-hop-and-metadata.json` | 216858 | `D21E265C233F232459A64BD8D7357C4DB0014A30A3D2BAEF57C266C2A154A41F` |

本候选只记录 B4 read-only contract review，等待 fresh 独立 ACCEPT/REJECT。执行者不自我接受、不更新 `main`、不执行 B5/M3/M2。
