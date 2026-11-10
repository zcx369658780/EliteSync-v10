# APP-M5-25｜Flutter Gradle 插件配置期来源候选

2026-09-30；DOCS-ONLY CANDIDATE / WORK LEVEL 2 REVIEW PENDING。三轮源码预算已耗尽；本报告不执行插件，也不证明配置成功。当前四正文的 `FAIL_ON_PROJECT_REPOS` 与 FlutterPlugin 在 apply 中添加项目 Maven 仓库存在明确静态冲突。M5/隔离构建仍 NOT_READY。

入口 `D:\EliteSync-v10`，main HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，执行会话 `01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad`。恢复时核对 CURRENT/TASK_CURRENT 仍指定本任务 ISSUED；174 条既有 dirty/untracked 保留。唯一新增本 plan，不修改 renderer、authority 或旧证据。M5-24 Work 独立 ACCEPT/CLOSED SOURCE-ONLY；其静态/测试各 1/1 和静态双流监控限制保持，不补跑。

## 三轮同次来源与预算

三轮均已在本执行会话完成，各一次、exit 0。恢复后只整理既有回执，不重读 SDK。每轮主动累计 UTF-8 输出上限 32KiB，状态/hash 先输出；第三轮各来源还有选段门。读取完整文件不等于语义完整回显，也不等于调用图闭合。

| 轮次 | 同次工具 chunk | 实际范围与结果 | 消耗 |
| --- | --- | --- | --- |
| 1 | 519878 | 准确 build.gradle.kts 存在/非链接门通过，2798 bytes，全文读取/hash及回显；唯一 implementationClass | 1/1 |
| 2 | 777693 | 准确 gradle/src/main/kotlin，根非 reparse、不跟链接；深度≤8、普通 .kt≤64、累计≤1MiB 门通过。实际20文件、157012 bytes，唯一 FlutterPlugin 及两个直接 helper 定位 | 1/1 |
| 3 | 42d8f4 | 实现及两个直接引用、inventory 唯一匹配 helper，各语义读取/hash一次；每文件≤256KiB。实现/Utils/Handler 选段门分别14000/10000/7500 bytes | 1/1 |

第三轮三个来源均出现 `SELECTED_LINES_UNEMITTED_CAP`：主动选段未全部回显，不是工具截断或源读取失败。本文仅据已回显行陈述语义；不以未回显内容补事实。第二轮其余文件的定位读取不建立实现语义。专业来源总预算 3/3 关闭，无失败、修复、重试或扩大目录。

准确源码根：`D:/flutter/packages/flutter_tools/gradle/`。

| 相对该根的文件 | bytes | SHA256 | 已回显定位/语义行 |
| --- | ---: | --- | --- |
| build.gradle.kts | 2798 | 8D83640366F1F78C9DB70F771D0C6E4A9C0D9E4858AA6EEE30891E86FED323B1 | 全文；26–27 实现注册、31–32 settings loader注册 |
| src/main/kotlin/FlutterPlugin.kt | 42405 | 1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313 | 类34；直接引用14–15；apply46起及下表选段 |
| src/main/kotlin/FlutterPluginUtils.kt | 35995 | E0EB454157E67127B7677D697E924EB6B0556C8A4E51405045BC5E7F77798FD0 | object28；下表选段 |
| src/main/kotlin/plugins/PluginHandler.kt | 13311 | 3B22349766754AFD7CCEA99549782FA6A20CBBF291FB277A31E6B46758B67857 | class28；下表选段 |

注册事实：`dev.flutter.flutter-gradle-plugin` → `com.flutter.gradle.FlutterPlugin`；settings loader → `com.flutter.gradle.FlutterAppPluginLoaderPlugin`。build.gradle.kts:7–11 声明 java-gradle-plugin/groovy/kotlin-dsl、Kotlin JVM 1.9.20；14–15 group/version 为 dev.flutter.plugin/1.0.0；37–48 Java/Kotlin target11；54–65 annotation1.9.1、Kotlin Gradle plugin1.8.0、serialization-json1.4.0、compileOnly AGP8.11.1。本文件没有仓库声明；不能由此断言整个 included build 无仓库或依赖已准备，亦不证明与 renderer Kotlin2.2.20/Java17 的兼容。

## 触发阶段、访问与四正文影响

以下都是源码可见动作或注册条件；实际访问/写入/进程启动次数均未执行测量。源码中的 System.getenv 仅作为文本读取，本任务未调用它读取环境。

| 阶段与来源 | 可见事实 | 对四正文的具体影响与限制 |
| --- | --- | --- |
| apply，FlutterPlugin:54–65、320–330；Utils:113–124 | SDK 定位涉及 FLUTTER_ROOT；resolveFlutterSdkProperty 先经 helper 尝试 parent/local.properties，存在则 UTF-8 load，再按 project flutter.sdk、properties、env fallback 选择；校验 SDK 目录 | includeBuild 路径不自动提供 flutter.sdk。Flutter 项目 parent 是 module/.android；即使显式 project property，仍有先检查/可能读取其 local.properties 的步骤，不能声称 -P 消除配置访问 |
| apply，FlutterPlugin:67–85；Utils:200–201 | local-engine 由 project property 存在判断；非 local-engine 分支读 bin/cache/engine.stamp；另有 engine.realm 读取 | 四正文未声明这些 engine 材料或身份闭包；不证明本机存在/可用。local-engine 分支不是已批准绕过方案 |
| apply，FlutterPlugin:87–101 | 读取 FLUTTER_STORAGE_BASE_URL/default host；local-engine 分支可取 repo property；rootProject.allprojects 内添加 repositories.maven | 与 settings 的 FAIL_ON_PROJECT_REPOS 明确静态冲突：设置层 local Maven 声明不能阻止插件尝试添加项目仓库。源码添加动作已证，实际 Gradle 异常/首失败阶段未运行核定 |
| apply，FlutterPlugin:103–116、118–134 | apply SDK native_plugin_loader.gradle.kts；创建 FlutterExtension；读取 rootProject/local.properties、versionCode/name 默认1/1.0；调用 addFlutterTasks | 省略 settings loader 未消除 native loader 入口；root build 未封闭配置文件访问。addFlutterTasks 是配置调用，不等于 Flutter 构建已执行 |
| apply/检查，FlutterPlugin:206–229 | 确定 SDK bin/flutter(.bat)；调用 DependencyVersionChecker，包含 skip property/异常警告路径 | 外部工具路径与版本检查入口可见；该 checker 实现未语义读取，不能证明版本兼容或完整访问行为；确定路径不等于启动进程 |
| apply，FlutterPlugin:249–253、284、303–314 | 创建 profile build type/initWith debug；调用 forceNdkDownload；逐 buildType 调用 addFlutterDependencies→Utils | renderer debug 选择不证明插件不会创建 profile/注册相关工作。显式 ndkVersion 不证明无下载；forceNdkDownload 方法体未回显，实际下载及精确触发规则 UNRESOLVED |
| 任务注册，FlutterPlugin:332–355 | 注册 generateLockfiles；其 doLast 内才 Exec gradlew，针对各 subproject 执行 dependencies --write-locks；另注册 Java/KGP 版本任务 | 存在潜在子进程与 lock 写入入口，但本次仅读源码，未运行 doLast。四正文输出目录赋值不封闭 lock、子进程或 included-build 输出 |
| variant/任务配置，FlutterPlugin:370–388；Utils:243–249、278–302 | 可见 applicationVariants.configureEach/asset任务调用片段；任务选择涉及 startParameter.taskNames，Flutter source 经 project.file 解析，target 可取 project property/extension/默认 lib/main.dart | flutter.source ../.. 的解析入口已核；library variant 的完整处理、output/asset/registrant 任务图及完整选择条件未回显，不能证明只 debug 或所有写入都在 outputs |
| helper及回调，Utils:317–334、375–385、499起、588–596 | addApiDependencies 开头、local-engine 限制片段、afterEvaluate SDK/NDK 比较片段；forceNdkDownload 注释/签名 | 完整依赖配置和 NDK body 未回显；注释与函数名不能证明实际行为或下载发生 |
| metadata 入口，PluginHandler:48–74、77–100 | getPluginList/getPluginDependencies 经 NativePluginLoaderReflectionBridge 与 Flutter source 取列表/metadata并缓存；dependencyGraph 必须 List；configurePlugins 调两个配置方法；另有 dev_dependency=false 过滤方法 | bridge 未追读，metadata准确访问/写入路径与生成规则 UNRESOLVED；configurePlugins 在完整入口链中的调用时点未回显。内存缓存不能证明无文件读取 |
| plugin接线回调，PluginHandler:121–158、162–170 | 按 name 找子项目，不存在 return；创建 plugin FlutterExtension；module afterEvaluate 按 buildType 加 nameApi project依赖，dev仅release排除；plugin afterEvaluate 做 SDK比较并调用 embedding依赖方法 | renderer 显式 implementation 与动态 Api 接线存在潜在重复/语义差异，完整调用/配置/POM未证。embedding方法仅开头可见；不能断言产物实际包含或排除哪个插件 |

四正文逐项结论：settings 的仓库冲突是首个明确静态问题，includedBuild 的依赖/缓存/output仍未闭合；root build 的 module/plugin 输出重定向不覆盖所有 SDK/子进程输出；Flutter/build.gradle 的 SDK定位、engine/config访问、profile/NDK/metadata/依赖回调仍需控制；manifest 的权限 remove/allowBackup 指令未因本次源码阅读获得合并或运行证明。真实权限、debug实际生效、registrant完整生成、插件组件与隔离均 UNRESOLVED。

## 有来源的精确前置条件与后续建议

当前不修改已接受 renderer。其四正文仍是人工纯字节材料；若未来进入配置，至少先独立审查以下前置条件：

1. **仓库策略闭合**：FlutterPlugin:87–101 的项目 Maven 注入必须与 FAIL_ON_PROJECT_REPOS 一起处置。当前方案预期遇到仓库策略失败，不能宣称 local-Maven-only 配置可用。下一方案须保留禁止未审远端依赖的边界，明确受控 SDK/插件材料如何消除或约束该注入，分别核定 included-build 和项目仓库。简单删 gate、加远端仓库或设置 host 字符串不构成已证明修正。
2. **SDK/config来源闭合**：未来准确调用合同应明确 project flutter.sdk 指向受审 bundle SDK 材料，并审查 module/.android/local.properties 的存在/读取策略和 root local.properties 访问；不能仅依赖 includeBuild，不能以 -P 证明文件读取消失。四正文范围能否增加 SDK property、其相对值在插件中的解析方式，需新任务来源核定后再修正。
3. **engine、NDK、metadata与任务链闭合**：非local-engine的 stamp/realm、native loader/bridge、插件依赖和 NDK 调用必须分别核定允许材料、读取/写入边界及调用阶段。included-build 依赖来源与完整外部进程/输出闭包也须明确。任何构建仍需新的隔离与运行授权，不由本 plan 或 renderer ACCEPT 放行。

最小下一来源建议（未发布、未执行）：在新精确预算中读取本轮已定位 `FlutterPluginUtils.kt` 的 forceNdkDownload 完整 body 及必要直接调用片段；补 `FlutterPlugin.kt` 已未回显的 library/task/registrant 配置段和 configurePlugins 调用点；对第二轮已定位的 NativePluginLoaderReflectionBridge/DependencyVersionChecker，先从同次 inventory 恢复准确路径，再由 Work 明定允许源，不按类名猜路径。若回执不能给唯一 locator，保持 UNKNOWN，不搜索扩树。included-build 仓库/依赖来源另需精确任务，本轮 build.gradle.kts 无仓库不足以闭合该问题。

未回显 helper、配置/metadata/engine内容和实际材料状态均不从历史或实现常识推断。本报告提供阻塞与最小来源建议，不新增恒定record/拒绝器，也不派发后继。

## 终止事实

无算法/测试/Gradle/Flutter/JVM/ADB/构建/安装/启动/UAC；无配置/cache/env/home/真实properties/metadata/json/插件材料/engine数据读取，无下载/复制/生成bundle、SDK写入、SDK外搜索/索引、旧 D:\EliteSync、真实数据/备份/密钥/DB/SSH/API 或 Git提交/pull/push。仅本任务三轮公开 SDK 源码读取和本地 authority/已保存证据阅读；专业预算3/3关闭，旧预算不重置。

唯一 plan 交付停 Work 独立 LEVEL 2 ACCEPT/REJECT；作者不自接受、不改 authority、不后继。M5/隔离构建 NOT_READY，settings/v1 全拒绝、loader/runtime false、真实账号/Conversation/恢复保护门保持。
