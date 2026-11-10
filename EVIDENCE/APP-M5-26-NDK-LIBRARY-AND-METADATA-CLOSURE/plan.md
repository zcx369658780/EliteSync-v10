# APP-M5-26｜NDK、library 与 metadata 来源候选

2026-09-30；DOCS-ONLY CANDIDATE / WORK LEVEL 2 REVIEW PENDING。一次四源读取完成，预算1/1关闭。新增可见事实：forceNdkDownload 通过配置 CMake 触发 AGP 相关流程；非 app 分支要求 root project 有 host app；metadata bridge 反射调用已应用的 native loader。PluginHandler 两个目标方法体和完整 registrant/外部任务链仍未覆盖。M5/隔离构建 NOT_READY。

## 入口与一次回执

`D:\EliteSync-v10`，main HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；会话 `01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad`。CURRENT/TASK_CURRENT 指定 M5-26 ISSUED，与派发一致；175条入口 dirty/untracked 保留。沿用 local-workflow、M5-23 四正文合同与 M5-25 plan。M5-25 work-review 为独立 LEVEL2 ACCEPT/CLOSED DOCS-ONLY，旧3/3预算关闭。

唯一专业读取：同次工具 chunk `9af71f`，exit0，墙钟0.2352056秒。四个准确文件依次检查存在、普通文件/非reparse、长度≤256KiB，各完整读取一次入内存、先输出hash并核对预期；全部匹配。无目录枚举、定位复跑、其它源追读。选段逐行打印前累计 UTF-8；正文计数23400 bytes，末尾回执和CRLF增量仍低于32KiB，未触发输出门，无工具截断。

| 准确文件（根 D:/flutter/packages/flutter_tools/gradle/src/main/kotlin/） | bytes | SHA256 | 实际语义回显 |
| --- | ---: | --- | --- |
| FlutterPlugin.kt | 42405 | 1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313 | addFlutterTasks完整349–533；library及configurePlugins调用另有重复摘录，非重复读取 |
| FlutterPluginUtils.kt | 35995 | E0EB454157E67127B7677D697E924EB6B0556C8A4E51405045BC5E7F77798FD0 | forceNdkDownload完整593–637及尾部注解638–640 |
| plugins/PluginHandler.kt | 13311 | 3B22349766754AFD7CCEA99549782FA6A20CBBF291FB277A31E6B46758B67857 | 两目标均 METHOD_UNRESOLVED COUNT=0，未回显方法体 |
| NativePluginLoaderReflectionBridge.kt | 2045 | DC2BADC34BF1525DF6A3BC221C29025E94DDE76DFCE0F43340D6344339B30D5E | 全文1–58 |

选段限制：摘录器按同缩进 fun 声明匹配 `configurePluginDependencies`、`addEmbeddingDependencyToPlugin`，均没有匹配；这不证明源中方法不存在，也不证明没有接线。原文件读取成功但未显示该语义，保持 UNRESOLVED，不修复摘录器、不补读或重跑。Flutter 的 addFlutterDeps 实现、完整 registrant 与外部task实现亦未被本次摘录覆盖。输出未满不能作为追加读取授权。

## NDK：配置动作已核，下载执行未证

Utils:593–603 从 Android extension 检查 `externalNativeBuild.cmake.path != null`；已有路径则返回。无路径时606–608将路径设为 SDK下 `packages/flutter_tools/gradle/src/main/scripts/CMakeLists.txt`。620–625将 buildStagingDirectory 设为项目 layout.buildDirectory 的 `../.cxx`；630–635为每个 buildType 添加 `-Wno-dev`、`--no-warn-unused-cli` 和 `-DCMAKE_BUILD_TYPE=<name>`。

完整body没有直接下载进程或网络调用；其可证行为是修改 Android/CMake 配置，注释说明意图为促使 AGP 下载 NDK。实际 AGP 下载触发阶段、缺失材料时行为、SDK写入位置、网络访问、CMake/NDK可用性仍未核定，不能以注释称本机发生下载。getAndroidExtension实现未在本次回显，相关外部AGP实现未追读；CMakeLists.txt只是准确引用，不读取其内容。

映射四正文：显式 ndkVersion 没有排除这段配置。按 renderer Flutter buildDirectory 为 bundle/outputs/flutter 的设计，`../.cxx`词法意图落在 bundle/outputs/.cxx，而非该project输出子目录；实际路径解析、AGP写入和跨项目冲突仍未运行证明。未来输出合同必须包含该staging路径并审查所有插件项目的相同/邻接路径，不能仅核 module/plugin buildDirectory。提前设置 CMake 路径是否可作为方案需另审，不自动用它绕过行为。

## library：host 拓扑前置条件与任务接线

FlutterPlugin:349–365 在 state.failure 不为空时返回，否则调用 Java/KGP版本任务注册；只有 isFlutterAppProject 分支另注册 print variants/app links 任务，随后读取 targetPlatforms。该分类helper、任务选择helper与targetPlatforms实现未在本次回显；不能由函数名推断完整规则。

366–454为 app 分支：applicationVariants.configureEach，shouldConfigureFlutterTask 决定是否继续；调用 addFlutterDeps，processResources.dependsOn(copyFlutterAssetsTask)。407–435注册 assembleTask.doLast，执行时才复制APK到 buildDirectory/outputs/flutter-apk，并据ABI/flavor/buildMode改名；不是本任务已复制。442–447配置 main jniLibs源为 buildDirectory/../native_assets/android/jniLibs/lib。448–452在配置调用中 configurePlugins及低SDK/NDK检查，而非包在该doLast内。

455–468非app/library路径按 root project 的 `flutter.hostAppProjectName` 属性取host名字，否则默认 `app`；findProject并 check非空。469–526注册 host app.afterEvaluate，取得 LibraryExtension、libraryVariants 和 host AbstractAppExtension/applicationVariants。483–485按host assembleTask筛选；506–510比较两边 buildModeFor结果；511–515按匹配variant调用 addFlutterDeps；518–523查找host merge<Variant>Assets任务、要求非空并设dependsOn。527–531的 configurePlugins/低SDK及NDK检查在回调外的配置调用中；若此前host check失败，该调用不可达。

四正文 settings 仅 include flutter 与人工插件，不 include app，也没有定义 flutter.hostAppProjectName；root build只有输出/publication属性，Flutter build应用com.android.library。因此若进入可见非app/library分支，默认host check是明确静态前置条件缺口。实际 isFlutterAppProject 分支分类、apply前置仓库/engine失败的先后顺序未运行，不能声称它是本机首异常。独立 bundle/host 逻辑目录不等于当前root里存在可配置的host项目；简单增加属性也不能代替该项目的真实Extension与任务。

debug/profile：本轮仅证明按host任务与buildModeFor进行匹配，注释列profile/debuggable/release规则但helper body未新增核定。M5-25已见profile创建；renderer beforeVariants/debug和singleVariant publishing不证明所有profile任务或插件工作被禁用。addFlutterDeps未回显，registrant生成、FlutterTask参数/进程启动、完整asset路径与发布任务仍 UNRESOLVED。本次没有实际执行回调或任务。

## metadata 与插件依赖边界

Bridge:23–37 从 ExtraPropertiesExtension 取 `nativePluginLoader`，反射找名为 `getPlugins` 的member并以 flutterProjectRoot调用、转换List；42–55同样取loader，找 `dependenciesMetadata` member并调用、转换Map。正文没有JSON读取、路径拼接或metadata文件写入；不能据此推断没有文件访问，因为实际逻辑委托给loader。准确相对引用为 `../scripts/native_plugin_loader.gradle.kts`（21、40），超出本轮四源，不追读；此前M5-25已核apply此脚本的入口，本次只是补齐反射路由。

M5-25已核 PluginHandler list/metadata缓存、dependencyGraph List门、project依赖与embedding调用片段，本轮未新增两目标方法体。完整configurePluginDependencies接线、embedding坐标/版本/配置选择仍 UNRESOLVED；不从旧开头、类型转换或类名推定GAV/POM。省略settings loader不移除apply native loader及bridge链；人工metadata schema不证明该loader实际收到人工材料或不会读取真实metadata。

## 合并后的实质后继建议

建议Work将下一步收敛为一张“受控 module 配置方案修订合同”任务，而非新增恒定记录或逐行拒绝器：先用新的精确源码选段补齐两个未回显 PluginHandler body、isFlutterAppProject/addFlutterDeps及必要直接调用，再对一个明确的 standalone library/AAR 路径核定host要求、registrant/外部任务和metadata输入。随后把仓库注入处置、SDK/config/engine材料、NDK/CMake/staging、native-assets及host拓扑合并成一份可审方案，决定四正文哪些行可修正、哪些应由外部输入与系统隔离合同承担。

明确修订对象：settings 的项目拓扑需满足所选library路径；root/Flutter输出合同需覆盖 `.cxx` 等邻接输出；Flutter/plugin依赖正文是否保留implementation须待完整Api/embedding接线来源；SDK/CMake/engine/metadata、included-build依赖与下载隔离属于精确外部材料和系统前置条件。仓库动态添加与FAIL_ON_PROJECT_REPOS的旧静态冲突保持，不能直接删gate或增加远端仓库解决。本报告不自定仓库策略、不改renderer、不新增host/bundle、不发布后继。

## 终止事实

新专业预算1/1耗尽，旧预算保持关闭。唯一新增本plan；没有SDK/renderer/authority/旧证据写入，无算法/测试/Gradle/Flutter/JVM/ADB/构建/安装/启动/UAC、配置/cache/env/home/真实properties/json/metadata/engine/插件材料读取、下载复制、SDK外搜索索引、旧D:\EliteSync/真实数据/备份密钥/DB/SSH/API或Git提交/pull/push。

停Work独立LEVEL2 ACCEPT/REJECT，不自接受或后继。M5/隔离构建NOT_READY，settings/v1全拒绝、loader/runtime false；权限合并、输入闭包、真实账号/Conversation/恢复和系统隔离保护门不变。
