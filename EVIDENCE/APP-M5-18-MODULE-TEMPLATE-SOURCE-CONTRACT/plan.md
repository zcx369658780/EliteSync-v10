# APP-M5-18｜module模板来源候选

2026-09-30；DOCS-ONLY CANDIDATE / WORK LEVEL 2 REVIEW PENDING。八模板来源已核；library模板group/namespace与project version、主要manifest及ephemeral settings配置访问建立静态事实。完整artifact/POM/插件注册与运行隔离仍未闭合，M5/隔离构建NOT_READY；不渲染、不构建、不解除settings/v1全拒绝。

入口D:\EliteSync-v10，main HEAD cf8bfaa4a03b8c9a682105617b185141904413be；assignee 01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad，当前ISSUED。167条既有工作区状态保留。只新增本plan，不改源码/authority/旧证据，无Git写操作。

## 定位与两轮预算

根定位复用M5-13保存回执：project.dart:865、869、896、900分别引用module/android/host_app_common、host_app_ephemeral、library_new_embedding、gradle；保存template.dart:29–35以Cache.flutterRoot/packages/flutter_tools/templates/name构造根。本次未重读project/template SDK源码。

第一轮一次批量目录清单1/1耗尽：四根全部存在，合计31项（目录与普通文件合计），退出0；无reparse分支、缺目录、项数/8KiB输出超限或截断。仅枚举相对路径、文件长度/类型，不读内容，不访问父目录或其它SDK根。第二轮一次批量内容/hash 1/1耗尽：从实际清单选准确8个允许名称普通模板文件，各一次内存读取/hash；每项均小于16KiB，总正文低于24KiB，状态/hash先完整输出，退出0、无失败/截断。两轮合计2/2关闭，所有旧预算保持。

以下路径以D:/flutter/packages/flutter_tools/templates/module/android/为根，行号为本次定点完整回显；没有实际模板渲染或占位变量求值。

| 所选模板 | 字节 | SHA256 |
| --- | --- | --- |
| host_app_common/app.tmpl/build.gradle.tmpl | 1180 | CCBB46F69277C26C2BC4527444E11E3E47E48ABE67639731E29A85886732E337 |
| host_app_common/app.tmpl/src/main/AndroidManifest.xml.tmpl | 2054 | A6F6F1F9689165C47B9F34F75087C74093B602826462BA5D2CCD73F118262FB5 |
| host_app_ephemeral/settings.gradle.tmpl | 954 | 3AE62F733A788ECEED03CCBAD2ED6F57CAEB0FDE2242EFC85CCD845B50F674FE |
| library_new_embedding/Flutter.tmpl/build.gradle.tmpl | 1286 | C22E7D39B005F39B43DCA5E4C5602817EB978D4FAF143D64BB2CA0A6748B1AB3 |
| library_new_embedding/Flutter.tmpl/src/main/AndroidManifest.xml.tmpl | 655 | 3DBB9D6AC5A9E66622C9FE93817C0DD050DD007879B2B84C2B44C11C71BFB696 |
| gradle/build.gradle.tmpl | 396 | E4F6682C474670D552B8B4A9141FBB1EAD450A6238BFE027B8F08296F58AACE9 |
| gradle/settings.gradle.tmpl | 38 | 63204A4CAE78EF4B81D682E555D71A227EE36EF699EB614B473358F3C7FE9E43 |
| gradle/gradle.properties.tmpl | 140 | 1888DF8F168EB770CA0F540B7BF84091E6B31B0D5AC55E4DE518590B8F7ED8E5 |

## 清单存在与内容覆盖分别记录

四根中的普通文件共16项，另15项为目录，合计31。除上述8个已读文件，其余8项仅清单存在，不读内容：host_app_common下MainActivity.java.tmpl（151字节）、launch_background.xml（446）、ic_launcher.png（544）、styles.xml（380）；library_new_embedding下include_flutter.groovy.copy.tmpl（1618）、settings.gradle.copy.tmpl（175）、Flutter.tmpl/flutter.iml.copy.tmpl（1378）；gradle/src/main/AndroidManifest.xml.tmpl（119）。未读gradle manifest虽名称允许，但最多8文件预算已用，不能续读；copy.tmpl等名称本就不在允许内容名称域。长度与存在不证明语义、生成结果或完整闭包。

## 模板根到目标的映射限制

project.dart保存来源857–929说明四根均向ephemeralDirectory，即module/.android渲染：先library_new_embedding与gradle，再在无editable android时加入host_app_common/host_app_ephemeral。顺序意味着settings可能被后续模板覆盖；保存Template.render:213默认overwriteExisting=true，但完整同路径替换算法未覆盖，不能仅从多个源settings文件推定最终每项精确字节。

保存template.dart:68–74注释说明.tmpl文件/目录用于模板展开；源app.tmpl与Flutter.tmpl对应预期app/Flutter目标，候选目标包括.android/app/build.gradle、.android/Flutter/build.gradle、.android/settings.gradle、.android/build.gradle、.android/gradle.properties及各manifest。这里是模板映射的拟议目标材料，不是已生成文件。目录/后缀/变量替换实现全链未核，不能复制源路径就声称实际渲染一致。

project.dart:914–929给androidIdentifier来自manifest.androidPackage或com.example.<appName> fallback、projectName来自appName，并提供AGP/Kotlin/Gradle/SDK占位变量。本文不读取真实manifest配置或求值，任何占位变量均不当作真实值。受控生成不能沿用fallback到普通项目身份，应另审固定synthetic值。

## 八模板逐文件事实

host_app_common/app.tmpl/build.gradle.tmpl:1–3使用managed标识与application插件；6、15设置{{androidIdentifier}}.host namespace/applicationId；7、16–17为SDK占位，10–11 Java17。18–19固定Android versionCode=1/versionName=1.0，不是Maven版本。22–30包含profile与release，release复用debug签名；34只设置该app项目buildDir为rootProject.projectDir/../build/host。36依赖: flutter项目，37 fileTree libs jars，38–39固定appcompat1.0.2/constraintlayout1.1.3。这不是已接受独立synthetic host源码，也不是debug-only模板。

其manifest:3使用identifier.host package，9有INTERNET；12–13label/icon变量或资源；15–25 exported singleTop MainActivity与launcher；29–31 embedding2；38–43 PROCESS_TEXT queries。没有本模板源码上的allowBackup=false、synthetic开关、固定/home或Activity deep-link false保证。不能把它直接当M5-12受审host替代品，实际合并manifest与插件仍另审。

host_app_ephemeral/settings.gradle.tmpl:4–10读取local.properties/flutter.sdk；12 includeBuild SDK Gradle目录；14–18 google/mavenCentral/gradlePluginPortal；22 Flutter loader1.0.0、23 AGP module版本占位、24 Kotlin占位。27 include :app，29 rootProject.name=android_generated，30–31 evaluate settingsDir/include_flutter.groovy。这个被求值脚本精确basename已定位，清单对应library_new_embedding/include_flutter.groovy.copy.tmpl，但其内容不在允许域，所以: flutter具体projectDir与插件include仍UNRESOLVED。不因basename存在扩大读取权限。

library_new_embedding/Flutter.tmpl/build.gradle.tmpl:3–6 application为library与Flutter Gradle插件；8–14从buildscript.sourceFile.parentFile.parentFile的local.properties条件读取。16–24 Android versionCode/name缺省1/1.0；26 group={{androidIdentifier}}，27 project.version=1.0。30 namespace同identifier，31–32/40–41 SDK/NDK来自flutter插件值而非这份模板独立常量；35–36 Java17；42–43为Android defaultConfig版本。48–50 flutter.source=../..。模板没有显式artifactId或Flutter项目name/buildDir，不借Gradle惯例补定。

library manifest:3 identifier package，5 INTERNET；7 application merge；9–10 flutterProjectType=module、14–15 embedding2。不能据synthetic Dart开关推定合并层移除INTERNET或插件副作用。两主要manifest都带INTERNET是源码事实，权限取舍/实际无网络仍须受控生成与运行门。

gradle/build.gradle.tmpl:3–8为allprojects加google/mavenCentral；10–11 apply library/kotlin-android；14 namespace变量，15/17–18 SDK占位。没有buildDir/group/version覆盖。gradle/settings.gradle.tmpl:1 rootProject.name={{projectName}}，与ephemeral后续android_generated区分。gradle.properties.tmpl:1 JVM内存/Metaspace/CodeCache与HeapDumpOnOutOfMemoryError配置，2 AndroidX=true。这是官方模板源码配置，不是读取真实properties；潜在heap dump落点与敏感残留仍未证，不能复制为已审隔离配置。

## 与发布链/recipe的对照

M5-16脚本跳过root.name==gradle，非plugin路径找: flutter并把除flutter/app外子项目作插件集合。ephemeral模板确实给root android_generated和:app，但: flutter及各插件如何通过include_flutter.groovy/loader引入仍缺内容，不能把模板名写成实际任务图已证。

library模板显式group={{androidIdentifier}}、project.version=1.0；M5-16 configureProject再去-SNAPSHOT并可由buildNumber覆盖。这补齐project版本提案的具体模板基值，但实际pub.groupId/pub.artifactId/pub.version是否以其默认绑定、Flutter插件是否自定义publication、plugin项目自己的group/version和POM依赖映射没有明确来源。M5-15仍必须显式输入base_group/base_artifact/publication_name，不自动推导artifact=flutter或pub.name=debug。

app versionName1.0、library Android flutterVersionName、library project.version1.0是三个不同承载，不能互换。唯一input-id可作buildNumber是设计，不证明全部插件同版本或POM闭包。outputDir/outputs/repo规则已核，但当前唯一显式buildDir只出现在host app模板，不能声称module/root/plugin中间目录全部封闭。

## 唯一建议下一事实增量源码切片

在准确已有两文件扩展：apps/android_synthetic_demo/tools/aar_material_functions.py与test_aar_material_functions.py。新增纯内存library_identity_fragment(*, android_identifier: str) -> str：验证严格ASCII点分Java包名域（每段ASCII字母/下划线开头，后续字母数字/下划线；拒绝关键词与不合法段），固定独立com.elitesync.syntheticdemo，生成仅来自library模板26–30的确定性片段：group=<受控标识>、version=1.0、android namespace=<同标识>。不渲染完整模板、不生成文件，不加SDK路径、插件、repo或权限，不改变settings/v1，也不声称片段可以单独构建。源码注释引用本轮模板hash/行。

接口显式叫fragment，返回字符串而非完整工程。唯一输入必须准确synthetic ID，通用合法包名并不授权用于该片段；必要通用词法校验仅作为内部helper。固定version1.0是模板基值材料，不是产物/POM承诺；buildNumber版本覆盖继续交已有recipe，不让此函数重写publication。该切片为受控生成器准备审查得见的最小身份材料，避免整模板照搬应用权限与自动配置行为。

正例固定预期字节/换行、group/namespace一致、version基值；负例错误类型/空、普通应用ID、fallback com.example、大小写漂移、引号/换行/Groovy插值/分隔符、空段、Unicode、关键词及非法首字符。固定片段不能包含INTERNET、settings/includeBuild/local.properties或执行命令。建议一次两文件实现、一次纯标准库目标测试、一次两文件静态审查；精确进程/时限/上限由Work另立新task，本次不运行算法或测试。复杂生成器/完整模板替换及权限隔离须另审。

## 未解门与停止状态

未读copy脚本、loader/Flutter Gradle插件/registrant/Java资源、实际模板替换覆盖行为、Dart/assets/plugins输入与dependency闭包；实际Maven默认artifact/publication/POM及root/module/plugin buildDir；SDK/engine/Gradle/JDK/Android身份、配置/父环境/网络与OS隔离、heap dump/签名/权限/数据门均未闭合。存在与hash不证明生成/构建可用。

无模板渲染/算法/测试/SDK工具/文件复制/目标生成/构建/ADB/安装/下载/UAC；未读其它SDK/cache/config/env/home/真实properties、旧仓库、真实数据/备份/密钥/DB/SSH/API。唯一plan停独立Work LEVEL2审查，不自接受/创建后继。M5/隔离构建NOT_READY，真实账号/Conversation/G08/G11/恢复保护门与所有旧预算保持。
