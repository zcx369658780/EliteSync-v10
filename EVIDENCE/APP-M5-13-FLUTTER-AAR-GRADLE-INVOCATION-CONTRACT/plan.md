# APP-M5-13｜AAR生成与Gradle调用入口合同候选

2026-09-30；DOCS-ONLY CANDIDATE / WORK LEVEL 2 REVIEW PENDING。结论：同一次 Flutter AAR 调用内生成 tooling 后进入 Gradle，当前不能在该 CLI 调用中证明一个可审查、可暂停的生成后运行前边界。隔离构建与 M5 均 NOT_READY。本文不给 GO 命令，不解除 synthetic host settings 的全拒绝或 v1 合同的 NOT_READY。

唯一实时仓库 D:\EliteSync-v10，main HEAD cf8bfaa4a03b8c9a682105617b185141904413be；当前 assignee 01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad。入口实核162条工作区状态，全部保留。本次只新增本 plan，不改源码、配置、SDK、authority，不提交或同步 Git。

## 来源与预算

第一轮1/2在旧执行会话已耗用；本会话仅复用 work-first-round-source-receipt.txt，未重读或重哈希四个第一轮SDK文件。Work记录同次原始命令退出0、stdout60386字符、保存回执SHA256 6BB9EAA5DC94BFFAA9D93E5F00C95C81CFB80B65F1C2D655D167365A65BD412C；本文引用该记录，没有重新计算回执哈希。完整当次stdout不等于完整文件内容：回执中 gradle.dart 197–203、776–786、804–858 等关键源码行没有出现，不能用相邻行填补事实。

第二轮仅一次批量读取/文件内筛选/哈希，准确六文件均由第一轮可见 import 直接确定，没有模板目录枚举、SDK全局搜索或索引。源码读取命令退出0，但工具显示原始输出25014 tokens、返回内容截断。因此以下只使用实际可见片段；两处哈希和若干实现段未完整回显，标 UNKNOWN/UNRESOLVED，不扩预算恢复。第二轮1/1耗尽，合计2/2耗尽。此限制是本候选的明确证据缺口，不是读取失败或允许重跑。

所有第二轮路径以 D:/flutter/packages/flutter_tools/lib/src/ 为根：

| 第二轮文件 | 第一轮直接引用位置 | 本轮可见SHA256 |
| --- | --- | --- |
| build_info.dart | android/gradle.dart:26 | AF123D66AB4325F8D4F7819853653AC0808D09E33287B1DEA41204DAA54D8BE8 |
| cache.dart | android/gradle.dart:27 | EB6D9F130287F48DF8C176E346FFA4E7AD00E2686464409277900044E19332FC |
| template.dart | project.dart:30 | UNKNOWN：计算调用已发生，输出截断，本文不能准确转录 |
| android/java.dart | android/gradle.dart:37 | UNKNOWN：计算调用已发生，输出截断，本文不能准确转录 |
| base/process.dart | android/gradle.dart:22 | 3F29425E8048FA7878C2AADF7F482441952ADBE47FCB238F98F3CB39558EBC04 |
| flutter_plugins.dart | project.dart:26 | FF221DFBA4790A328798F10056B24853E7C9FD1694C9869FE1B61415C53E12F3 |

第一轮四文件哈希只转录已有回执：

| 文件（同一src根） | SHA256 |
| --- | --- |
| commands/build_aar.dart | 3B5C49E3A8DE1C3C5FEA4A385484DB37C4799ED3B480FA8F265F99BB5F8CBDEB |
| android/gradle.dart | CAB8B82F27CFA0FCBA61E3502683D067EC583CDFC728A63B63C74E8837D6E2FD |
| android/gradle_utils.dart | 6E4EC13CA9668FABAFA84AA18A36DFFD7F4C739B627E615F18CFFDBF2D6DDFCC |
| project.dart | 4ADA296DD17049F84724993CB0126131127D02DAAC61074924772D3F3013A4A4 |

哈希仅证明对应读字节身份，不证明SDK/engine/工具版本、依赖存在或构建可用。SDK未使用图谱，新索引不在本任务范围；直接按固定文件读取。

## 已建立的调用边界

1. commands/build_aar.dart:30–40 定义 debug/profile/release 三个flag，默认都true；43–48调用 build-number/output/pub/Dart define 的选项注册。124–130明确build-number缺省1.0。132–143固定 target为lib/main.dart，并逐个启用mode形成AndroidBuildInfo；139把target作为forcedTargetFile传入getBuildInfo。150–157调用androidBuilder.buildAar，传入generateTooling回调、output与buildNumber。
2. android/gradle.dart:188–212 中 buildAar 对每个mode先 await generateTooling，再 await buildGradleAar。这是同次连续调用，不是运行前审查停点。输出根的196行只显示开始构造，197–203未见；不能凭历史路径补定缺省输出根。
3. project.dart:364–380 的 regeneratePlatformSpecificTooling 转向 ensureReadyForPlatformSpecificTooling；401–426依次refreshPluginsList、Android tooling及injectPlugins。857–878在module且需要重生时调用_regenerateLibrary、必要时生成host_app_common/host_app_ephemeral，然后updateLocalProperties。880–885按pubspec时间或tools stamp判断重生；893–904先递归删除ephemeralDirectory，再渲染library_new_embedding与gradle模板，并injectGradleWrapperIfNeeded。906–929调用Template.fromName与render，输入包括包名、AGP/Kotlin/Gradle/SDK版本。不能在原模块执行此流程。
4. project.dart:526–539选择hostAppGradleRoot：有editable android时取android，否则module取.android；因此不能把cwd或最终repo隔离等同全部中间目录隔离，staging必须拒绝未知editable android。
5. android/gradle_utils.dart:228–245 getExecutable先inject wrapper，再选hostAppGradleRoot中的平台gradlew，并makeExecutable；248–258从cache gradle_wrapper复制缺失文件。273–279展示生成的wrapper分发URL指向services.gradle.org。wrapper不是固定分发直接入口，缺文件时已有写入/潜在下载后续链。
6. android/gradle.dart:791–798可见嵌套命令前缀为wrapper、-I=$initScript、-Pflutter-root、-Poutput-dir、-Pis-plugin、-PbuildNumber；800–803有verbose选项。859–866以hostAppGradleRoot为cwd、allowReentrantFlutter=true、_java?.environment调用_processUtils.run。804–858完整参数追加段缺失，不能发布准确完整argv或宣称offline/缓存/home参数存在。

## 五项问题的事实与未解项

### CLI选项、target与生成时点

debug/no-profile/no-release对应可否定flag的注册形态已见，独立请求应只启用debug；output/build-number/pub/define注册调用已见。build-number缺省值和固定lib/main.dart已建立。选项注册 helper 的实际声明、--no-pub的运行前verify行为及CLI完整解析链未在可见材料中闭合；不能把选项名存在提升为受控可运行命令。

build aar 的verify阶段明确不在该override中重生tooling（build_aar.dart:111），但runCommand随后明确传入生成回调；生成后立即进入buildGradleAar。当前读取未发现可证明的公共CLI分步停点；这不证明全SDK绝无该入口，仅表示本有界来源不能支持它。不得将project私有_regenerateLibrary/Template.render包装成Flutter已开放CLI。

### 可控生成与分步设计

SDK内部在函数上区分生成与构建，CLI当前证据没有提供用户可插入校验的分步接口。生成器模板集合逻辑名称已确定：module/android/library_new_embedding、module/android/gradle、host_app_common、host_app_ephemeral；本轮未建立它们的准确逐文件模板闭包。template.dart回显受截断，不能从目录惯例猜子文件。

建议未来独立受控生成器从经审逐文件常量/模板材料生成自己的module Android包装层，再经纯校验冻结receipt，最后由另行授权的启动器直接调用固定Gradle分发。它不能调用Flutter CLI生成、调用SDK私有函数、改SDK或复用原.android。目前缺模板内容/插件注册/Flutter Gradle插件接线及完整argv，所以只能先做下文纯校验切片，不能现在写生成器并声称可用。

### 分发、init、Java与环境

第一轮gradle.dart:787–790显示flutter_tools/gradle/aar_init_script.gradle后缀，但构造根的776–786缺失。本文不据惯例拼绝对路径、不读取该脚本；init script准确定位、发布行为均UNRESOLVED。

Java第二轮可见android/java.dart:226–261：依次看config jdk-dir、Android Studio javaPath、JAVA_HOME，再fallback PATH；154–160提供JAVA_HOME及在父PATH前加入Java目录。169–172的版本获取会启动java --version。源码事实说明仅设JAVA_HOME不能证明选择固定JDK，也不能证明无子进程或配置读取。base/process.dart:348–356的run默认timeoutRetries=0；484–489/538–542调用processManager并经_environment处理。_environment完整实现与processManager父环境继承未完整可见，故隔离/完整重试链UNRESOLVED，不能由局部默认0宣称整条构建无重试。

固定分发直接运行必须由自有启动器实现；不能给Flutter wrapper路径套别名假称等价。该启动器未来须拒绝wrapper、父环境注入及未知init/config，使用空白名单环境、固定Java、独立user.home/Gradle用户home与project cache，并验证实际系统/网络隔离。当前没有这种已验证实现。

### define、输出与产物身份

build_info.dart:365–376 toGradleConfig含-Pdart-defines编码及其它构建参数；1095–1096 encodeDartDefines将各define编码后用逗号连接。编码器定义未在可见输出中完整显示，不能仅凭函数名补定其字节算法；是否/何处在AAR argv实际追加toGradleConfig同样位于缺失段，仍待闭合。固定target和参数传递不证明最终AAR确含synthetic入口。

output作为-Poutput-dir传入已见，最终repo子目录、debug AAR/POM GAV、buildNumber怎样进入发布坐标、插件伴随发布及中间buildDir均未由已读init/模板证明。M5-10的module/build/host/outputs/repo与拟议GAV继续作为设计，不在此升级为本机真实输出事实。真实输出/GAV/POM关系UNRESOLVED；禁止据移动目录、文件名或坐标判断输入身份。

未来staging需封闭module/.android、editable android排除、.dart_tool、build、插件构建根、输出repo、生成registrant/metadata/local.properties及settings/include脚本；每个准确生成文件路径与内容必须先有模板来源，不把上述目录集合当完整逐文件清单。

### cache、插件、依赖与自动准备

已见getExecutable读取cache中的gradle_wrapper并补文件；project tooling会判断tools stamp并写local.properties、重生.android及插件注册。cache.dart可见DevelopmentArtifact android_gen_snapshot/android_maven/universal分类与FLUTTER_STORAGE_BASE_URL镜像读取说明；updateAll/download具体触发段受回显截断，且CLI preflight调用链未读齐，不能列成已验证完整下载触发清单。

flutter_plugins.dart:1164–1172 refreshPluginsList调用findPlugins并排序；1246–1254 injectPlugins有平台与release参数；1043–1052创建插件链接依赖已生成metadata。依赖解析根、注册内容和平台副作用未完整闭合。不能从--no-pub推断插件元数据不读不写，或从--offline推断全部工具/配置脚本无网络。

在任何未来子进程前，缺少冻结材料、准确版本/hash、输入闭包、模板/插件/工具配置来源、环境/网络隔离证明时，应由自有纯校验器拒绝，绝不调用SDK“补齐”。本任务未读取任何cache工件、真实properties、凭据或依赖内容。

## 唯一建议下一软件切片

建议另立LEVEL 2任务，仅新增 apps/android_synthetic_demo/tools/validate_aar_preflight.py 与其准确单测试文件 apps/android_synthetic_demo/tools/test_validate_aar_preflight.py。不改现有settings、v1 validator/build-contract或host源码。接口validate_receipt(document: dict) -> list[str]只接收内存对象；不得读文件、环境、配置、SDK、缓存或启动子进程。

校验固定schema、debug-only、target=lib/main.dart、synthetic=true、原仓库禁止输出、wrapper禁止、未知argv禁止、材料每条source/target/hash与经审精确清单一致，并独立检查completeInputClosure、templateClosure、gradleInvocationClosure、dependencyClosure、isolationReviewed门。任何门缺失/UNKNOWN/UNRESOLVED均拒绝；返回错误列表而不生成可执行命令。命令闭包目前未定，首版本所有executionReady请求必须拒绝，不能用placeholder模拟通过。

负向用例应覆盖：缺/false synthetic、profile/release/混合、target漂移、缺闭包、未知文件/插件、冲突define、wrapper、未知init、输出逃逸/原模块目录、未知工具hash、父环境注入字段、伪GAV身份及用离线标志替代隔离。仅内存数据，验证不得读宿主路径或写staging。建议新预算为一次有界写入、一次纯Python目标测试、一次准确两文件静态审查；这是建议，当前不执行、不设新预算。接受仍须独立Work LEVEL 2，且不放行运行。

生成器/启动器实现须待调用/模板/发布链来源另行闭合；不在当前切片假造支持Flutter CLI的分步入口。

## 后续必须先补齐的材料与门

完整Dart输入逐文件清单：pubspec.yaml/lock、lib/main.dart到demo/bootstrap/router/依赖的实际源码闭包、准确assets/config/fonts等资源及声明与引用的对应关系。完整plugins输入逐文件清单：每个package源码版本/hash、package_config隔离映射、插件metadata/registrant、Android native源与manifest/provider/resource/Gradle依赖、传递依赖和native产物。旧少量入口读取不能替代这些清单。

工具与依赖材料：SDK/engine/Flutter Gradle插件准确身份与模板闭包；固定Gradle/JDK/Android组件；AGP/Kotlin、embedding/engine、插件及传递Maven/Pub材料的版本/hash/POM与离线解析闭包；分发init.d/自动配置读取规则、Java选择/父环境与嵌套命令；真实AAR/POM/GAV及签名/合并manifest/权限验证。现均未形成完整可执行receipt。

SDK缺行、第二轮输出截断与未读取init/template闭包是精确来源停点。后续来源恢复/新只读任务须由Work决定准确来源与新授权，不由本候选重置本任务2/2预算。OS/网络隔离、配置解析、依赖准备、AAR构建、host构建、安装及首帧均NOT_CHECKED；构建与M5保持NOT_READY。

M5-10 DOCS-ONLY ACCEPT、M5-11原REJECT、M5-12修正后九文件SOURCE-ONLY ACCEPT分别保留；39/39旧合同PASS不复跑，不升级为Android行为证明。真实账号/Conversation/G08/G11/备份恢复回填/UAC及全部旧预算不变。未运行Flutter/Gradle/ADB/JVM/编译/测试，不复制、下载、安装或访问真实数据/生产/API/DB/SSH。交付本唯一plan，停独立Work LEVEL 2审查，不自接受、不创建后继。
