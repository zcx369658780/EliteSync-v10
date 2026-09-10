# EliteSync v10｜Post-R7 Platform Tooling Trigger Diagnostic Result v0.1

Status: `EXECUTED RESULT CANDIDATE — READ-ONLY CONTROL-FLOW DIAGNOSTIC — CAUSE ESTABLISHED — NO RECREATION — NO PUB — NO M3 — NO M2`

## 1. Final classification

当前固定 Flutter-tools 源码与 B7 state共同证明：B7 的 Android platform selection没有排除 Android，pub 后 platform-tooling prepare branch也没有被跳过。Android prepare 被调用，但当前 `.android` 已存在，且其 `_shouldRegenerateFromTemplate()` age predicate为 false，因此 `_regenerateLibrary()` 未运行；随后 `hostAppGradleRoot` 不存在，Android prepare直接返回。create command仍可正常 exit `0`。

Exact cause：

`ANDROID_REGENERATION_PREDICATE_FALSE — EXISTING .android NOT OLDER THAN PUBSPEC OR FLUTTER_TOOLS_STAMP`

Final classification：

`MODULE_ANDROID_PLATFORM_TOOLING_TRIGGER CAUSE ESTABLISHED — READY FOR B9 EXECUTION TASK`

该结论只支持一个 fresh、另行授权的 B9 generated-state reset-and-recreation task，不授权本任务删除 `.android`、运行 recreation、M3 或 M2。

## 2. Authority and Sandbox observation

- fresh-fetched GitHub `main`=`396eae8ceb1441b332c14063f8a898495dba8ca8`，与 B8 authority精确一致。
- FIRST blob=`18485c95262051e43892436fb52413132c5ee626`，已首先完整读取并匹配。
- B8 task branch=`task/h01-bib03-u15-td01-m3-post-r7-platform-tooling-trigger-b8-v0-1`。
- B8 task commit=`2f4cfec1315e1d29cd5aaf2b7f22be8768dfdc52`。
- B8 task blob=`d3340f78c21d68a31e0d4ab2f66ea434c6c5a355`。
- accepted B7 result blob=`14445a7b4c0928c4ffb67943aa1ac9e8ebceb130`，已完整读取。
- accepted B4 result blob=`24693a27360cc2fbf09bbd152c022e55511dc0ce`，仅用于 prior generation contract，已完整读取。
- accepted B6 result blob=`755b2073389fe0f908dfe110b7b40d416f470ac1`，仅用于 generated IDE metadata classification，已完整读取。
- initial/final `wsb list --raw` 均为 running count=`1`，唯一 ID=`0087a898-5221-41df-a33d-65045ffea69a`。
- Sandbox create/stop/close/reset/kill/share/materialize=`NOT_RUN`。

## 3. Exact implementation files and symbols inspected

Fixed Flutter-tools root：

`C:\M3A\tools\flutter\packages\flutter_tools`

Directly inspected exact files：

- `lib/src/commands/create.dart`
  - `_getProjectType()` lines 233–275
  - `runCommand()` platform validation/selection lines 321–405
  - `_generateModule()` call/dispatch and generated-file accounting
  - `shouldCallPubGet` branch、`pub.get(...)`、`ensureReadyForPlatformSpecificTooling(...)` lines 536–565
- `lib/src/commands/create_base.dart`
  - `determineTemplateType()`；通过 `FlutterProjectMetadata.projectType` 检测 existing project type
- `lib/src/project.dart`
  - `FlutterProject.ensureReadyForPlatformSpecificTooling(...)`；`androidPlatform=true` 时调用 Android prepare
  - `AndroidProject.ephemeralDirectory`、`_editableHostAppDirectory`、`isModule` lines 536–542
  - `AndroidProject.ensureReadyForPlatformSpecificTooling(...)` lines 857–878
  - `_shouldRegenerateFromTemplate()` lines 880–886
  - `_regenerateLibrary()` lines 893–904
- `lib/src/flutter_project_metadata.dart`
  - `.metadata` key `project_type` 与 `projectType` parsing
- `lib/src/flutter_manifest.dart`
  - `isModule` predicate used by `FlutterProject` / `AndroidProject`

Authorized files not needed and therefore not read for B8 control-flow conclusions：

- `lib/src/runner/flutter_command.dart`
- `lib/src/template.dart`
- `lib/src/flutter_plugins.dart`
- `lib/src/xcode_project.dart`

### One-hop followed files

`project.dart` 的 exact predicate直接引用以下 implementations，因此按 B8 one-hop allowance读取：

- `lib/src/base/file_system.dart`
  - `isOlderThanReference(...)` lines 78–95：entity不存在时 true；reference不存在时 false；两者存在时以 modification time比较，reference比 entity新时 true。
- `lib/src/cache.dart`
  - `isOlderThanToolsStamp(...)` lines 731–736：取 `flutter_tools` stamp，并调用同一 `isOlderThanReference(...)`。

没有继续 one-hop；没有搜索 Flutter SDK其他区域。

## 4. Current exact module metadata/state

Fixed module root：

`C:\M3A\work\apps\flutter_elitesync_module`

只读取 source predicates需要的 exact fields：

### `.metadata`

- `version.revision=2c9eb20739dfec95e2c74bd3dfa4601b0a8a36aa`
- `version.channel=stable`
- `project_type=module`

### `pubspec.yaml`

- `name=flutter_elitesync_module`
- `flutter.module`=`present`
- `flutter.module.androidX=true`
- `flutter.module.androidPackage=com.elitesync.flutter_elitesync_module`
- `flutter.module.iosBundleIdentifier=com.elitesync.flutterElitesyncModule`

只执行任务允许的 exact existence checks：

| exact relative path | exists/type |
| --- | --- |
| `android` | false / no editable Android directory |
| `.android` | true / directory |
| `ios` | false / no editable iOS directory |
| `.ios` | true / directory |
| `.idea/libraries/Dart_SDK.xml` | true / file |
| `.idea/modules.xml` | true / file |
| `.idea/workspace.xml` | true / file |
| `flutter_elitesync_module_android.iml` | true / file |
| `flutter_elitesync_module.iml` | true / file |

未枚举 `android`、`.android`、`ios` 或 `.ios` contents；未读取 `lib/**`、tests、assets或产品实现。

## 5. Exact B7 create control flow

B7 command：

`create --template=module --offline .`

### 5.1 Existing project type detection

1. `_getProjectType(projectDir)`检查 `.metadata` 是否存在。
2. 对存在且非空的 project directory调用 `determineTemplateType()`。
3. `determineTemplateType()`通过 `FlutterProjectMetadata.projectType` 读取 `.metadata` 的 `project_type`。
4. 当前 exact value=`module`，因此 detected type=`FlutterTemplateType.module`。
5. 显式 `--template=module` 解析为同一类型；`create.dart` 只有在 detected/requested type不一致且 `.metadata` 存在时才报错。当前匹配，继续执行。

### 5.2 Platform selection

Current source明确规定：

- `--platforms` 不支持 module/package；若为 module显式传入，command exit=`2`。
- 对 `FlutterTemplateType.module`，源码直接赋值：
  - `includeIos=true`
  - `includeAndroid=true`
  - web/Linux/macOS/Windows/Darwin=`false`

因此：

- host OS defaults不能抑制 Android；
- 当前 `android` / `.android` presence不参与 create command的 `includeAndroid` selection；
- `--platforms=android` 既不需要也不受支持，不能作为 B9 selector。

### 5.3 Common render, pub and platform prepare

1. module dispatch调用 `_generateModule()`，将 `module/common` 渲染到当前 module root。
2. B7 时五个 IDE metadata destinations缺失，其余 protected common destinations已存在且不允许 overwrite，所以 stdout精确出现五个 created entries与 `Wrote 5 files`。
3. `if (shouldCallPubGet)` 同时包围 `pub.get(...)` 和随后的 platform prepare。
4. B7没有传 `--no-pub`，stdout显示 offline dependency resolution成功，故该 branch已进入。
5. pub后仅 `generateFfiPackage` 会跳过 `ensureReadyForPlatformSpecificTooling(...)`；当前 template是 module，不是 FFI package。
6. 调用参数明确为：
   - `androidPlatform=includeAndroid=true`
   - `iosPlatform=includeIos || includeDarwin=true`
   - 其他平台 false
7. `FlutterProject.ensureReadyForPlatformSpecificTooling(...)` 在 `androidPlatform=true` 时 await Android prepare。

因此 `PLATFORM_SELECTION_EXCLUDES_ANDROID` 与 `PLATFORM_TOOLING_PREPARE_BRANCH_NOT_REACHED` 均不符合当前源码/B7 evidence。

### 5.4 Android regeneration predicate

AndroidProject exact state mapping：

- `ephemeralDirectory=parent.directory.childDirectory('.android')`
- `_editableHostAppDirectory=parent.directory.childDirectory('android')`
- `isModule=parent.isModule`

Android prepare只在以下条件为 true 时执行 `_regenerateLibrary()`：

`isModule && _shouldRegenerateFromTemplate()`

其中：

`_shouldRegenerateFromTemplate() = isOlderThanReference(.android, pubspec.yaml) || isOlderThanToolsStamp(.android)`

若 predicate为 true，`_regenerateLibrary()` 会先递归删除 `.android`，再从 `module/android/library_new_embedding` 与 `module/android/gradle` 模板重建，并注入 Gradle wrapper。B4 accepted generation contract证明该路径应产生限定 Gradle sentinels。

当前 `isModule=true`、`.android` 已存在。B7 command exit=`0`，但四个限定 Gradle sentinels全部 absent；若 predicate为 true，awaited regeneration要么生成这些 sentinels，要么异常导致 create nonzero，不可能得到当前组合。因此本次 `_shouldRegenerateFromTemplate()` 必为 false，即两个 age tests均为 false。

predicate为 false后，源码跳过 `_regenerateLibrary()`；随后检查 `hostAppGradleRoot.existsSync()`。当前没有任何限定 settings/build sentinel，Android prepare在该 root不存在时直接 return。这个 return不是 command error，所以 common render + pub成功后，create可以合法 exit=`0` 而不建立 `.android` Gradle build。

## 6. Reconciliation with B7

| B7 observation | current source explanation |
| --- | --- |
| recreation exit=`0` | Android prepare的 `hostAppGradleRoot` absence branch直接 return，不抛错 |
| exactly five IDE files created | `_generateModule()`只补齐五个缺失 common-template destinations；其他 protected files因无 overwrite保持不变 |
| offline dependency resolution succeeded | `shouldCallPubGet=true`，`pub.get(... offline:true)`完成 |
| protected pre/post byte-identical | common protected destinations已存在且无 `--overwrite`；Android branch没有进入 regeneration |
| four `.android` sentinels absent | existing `.android`未满足 age-based regeneration predicate，`_regenerateLibrary()`未运行 |
| M3 not run | B7在 Android sentinel gate按规定停止 |

Exact reconciliation classification：

`ANDROID_REGENERATION_PREDICATE_FALSE`

这是 current-source behavior，并不构成 `CURRENT_SOURCE_BEHAVIOR_DIFFERS_FROM_B4_CONTRACT`；B4识别了 predicate存在，但把已有 module recreation概括为会发生重建，未封闭“`.android` 已存在且 freshness predicate=false”的具体状态。

## 7. One exact proposed B9 action（NOT EXECUTED）

建议 future B9仅授权一个 bounded generated-state reset-and-recreation sequence。其目的不是手工生成任何模板文件，而是把 exact disposable `.android` 置为源码明确识别的“entity不存在”状态，使 `_shouldRegenerateFromTemplate()` 必为 true，然后仍由 Flutter supported create flow完成生成。

### 7.1 Preconditions and protected gate

1. fresh authority、FIRST、accepted B8、唯一 preserved Sandbox和最小 substrate重新通过。
2. 建立与 B7完全相同规则的 protected pre-manifest，排除仅限既定 generated allowlist及 `build/**`。
3. 精确确认 `.android` directory存在且四个 Gradle sentinels仍全部 absent。
4. 五个 B6 IDE files允许存在；禁止修改 host SDK/cache/source。

### 7.2 Exact generated-state trigger

只删除 exact generated/disposable directory：

`C:\M3A\work\apps\flutter_elitesync_module\.android`

建议 controller使用：

- executable=`C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`
- argument shape=`-NoProfile -ExecutionPolicy RemoteSigned -Command "Remove-Item -LiteralPath 'C:\M3A\work\apps\flutter_elitesync_module\.android' -Recurse -Force"`
- deletion count=`1`
- no wildcard、no alternate path、no manual template copy、no retry

该 deletion必须由 B9显式授权；B8未执行。删除后，`isOlderThanReference(entity=.android, ...)` 按源码因 entity不存在而直接返回 true。

### 7.3 Exact supported recreation

- executable=`C:\M3A\tools\flutter\bin\cache\dart-sdk\bin\dart.exe`
- complete args=`--packages="C:\M3A\tools\flutter\packages\flutter_tools\.dart_tool\package_config.json" "C:\M3A\tools\flutter\bin\cache\flutter_tools.snapshot" --no-version-check create --template=module --offline .`
- cwd=`C:\M3A\work\apps\flutter_elitesync_module`
- pub=`ENABLED + OFFLINE`
- `--overwrite`=`PROHIBITED`
- `--no-pub`=`PROHIBITED`
- `--platforms=android`=`NOT_SUPPORTED FOR MODULE / MUST NOT USE`
- recreation count=`1`；no retry

Required environment roots：

- `FLUTTER_ROOT=C:\M3A\tools\flutter`
- `PUB_CACHE=C:\M3A\cache\pub`
- `ANDROID_HOME=C:\M3A\tools\android`
- `ANDROID_SDK_ROOT=C:\M3A\tools\android`
- `JAVA_HOME=C:\M3A\tools\jdk`
- Git PATH root=`C:\M3A\tools\git\cmd`
- `GRADLE_USER_HOME=C:\M3A\cache\gradle`
- Windows/Security baseline PATH only in addition to these fixed tool roots

Expected generated scope：

- `.android/**` recreated by Flutter, including at minimum:
  - `.android/settings.gradle` or `.android/settings.gradle.kts`
  - `.android/build.gradle` or `.android/build.gradle.kts`
  - `.android/Flutter/build.gradle`
  - `.android/gradle/wrapper/gradle-wrapper.properties`
- `.ios/**` may be inspected only as permitted generated state；existing `.ios` need not be reset because Android predicate is independent
- `.dart_tool/**`、`.flutter-plugins-dependencies`、`pubspec.lock` only as legitimate offline pub/plugin generated state
- five B6 IDE files may remain or be generated；no other module path writable

### 7.4 Post gates and conditional M3

1. recreation exit=`0` and no genuine URL/socket/DNS/connection failure diagnostic。
2. protected post-manifest must be byte-for-byte equal to pre-manifest；任一 protected path changed/appeared/disappeared则停止。
3. Android gate必须确认：
   - settings pair至少一个存在；
   - build pair至少一个存在；
   - `.android/Flutter/build.gradle`存在；
   - `.android/gradle/wrapper/gradle-wrapper.properties`存在。
4. Flutter-tools snapshot identity必须保持不变。
5. 只有上述全部通过，B9才可另行授权一次 conditional direct-snapshot M3：
   - executable=`C:\M3A\tools\flutter\bin\cache\dart-sdk\bin\dart.exe`
   - args=`--packages="C:\M3A\tools\flutter\packages\flutter_tools\.dart_tool\package_config.json" "C:\M3A\tools\flutter\bin\cache\flutter_tools.snapshot" --no-version-check build aar --no-debug --no-profile --no-pub`
   - cwd=`C:\M3A\work\apps\flutter_elitesync_module`
   - invocation count最多 `1`；no retry；exact AAR probe仅在 M3 process启动后一次。

该提案不授权单独 Gradle resolution、network/package fill、manual template copy或 M2。

## 8. Explicit NOT_RUN / NOT_MODIFIED

- Flutter pub=`NOT_RUN`
- Dart pub=`NOT_RUN`
- `flutter create` / recreation / regeneration=`NOT_RUN`
- `.android` delete/create/modify=`NOT_RUN`
- `.ios`、IDE metadata、`.dart_tool`、lockfile modification=`NOT_RUN`
- M3=`NOT_RUN`
- Gradle resolution=`NOT_RUN`
- AAR probe=`NOT_RUN / NOT_CHECKED`
- M2=`NOT_RUN`
- network/package fill/download/install=`NOT_RUN`
- product implementation=`NOT_RUN`
- host/guest SDK/cache/source modification=`NOT_RUN`
- Sandbox create/stop/close/reset/kill/share/materialize=`NOT_RUN`
- repository-wide、host-wide、alternate-module、whole-Flutter-SDK search=`NOT_RUN`
- `lib/**`、tests、assets、application implementation read=`NOT_RUN`
- default index/protected staged-state inspection、default `git status`=`NOT_RUN`
- self-accept / acceptance commit / `main` update=`NOT_RUN`
- `CURRENT_CONTEXT`=`NOT_MODIFIED`

本候选只记录 B8 read-only diagnosis与一个 future B9 proposal，等待 fresh independent ACCEPT/REJECT。
