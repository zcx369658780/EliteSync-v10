# APP-M5-27｜AAR配置入口与依赖接线候选

2026-09-30；DOCS-ONLY CANDIDATE / WORK LEVEL 2 REVIEW PENDING。两轮新预算2/2关闭。源码明确区分 `is-plugin` 的存在与布尔值：init script按值选择module/plugin发布，而 addFlutterDeps按存在判断AAR；当前apply及已核addFlutterTasks没有据此绕过library的host检查。现有四正文不能据此宣称standalone AAR配置闭合，不新增app或放宽仓库门掩盖阻塞。M5/隔离构建NOT_READY。

## 授权与一次性来源

唯一仓库 `D:\EliteSync-v10`，main HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；Codex `01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad`。CURRENT/TASK_CURRENT/task顶部为新Work `01a0f173-9add-7070-b57a-7660f75f5c40` 恢复ISSUED并明确派发；旧PAUSED是历史。入口177条dirty/untracked保留，仅新增本plan。沿用local-workflow；M5-26独立ACCEPT/CLOSED DOCS-ONLY、plan hash `A0315719C54142EF462E12F4F1FEC7D5CA1705508A82E12A6B908097059C702A` 和旧1/1关闭；所有更早预算不重置。

读取前从本地M5-14及M5-16 plan核定一致locator `D:/flutter/packages/flutter_tools/gradle/aar_init_script.gradle` 及hash B6B870954405C5D52AFEA183BB51B3220100C234401142D8C1BF3E2410CEE2C2，不据聊天猜路径。M5-23四正文、M5-25/26已核片段只引用已保存结果，不运行旧验证。

| 新轮次 | 同次工具chunk | 实际结果 | 消耗 |
| --- | --- | --- | --- |
| 1 | 41a840 | 两源各一次完整读取；Handler全文1–261，Utils三个最小方法及相邻注释；exit0，0.2841168秒，末状态前UTF-8 16960 bytes | 1/1 |
| 2 | 85a218 | 两源各一次完整读取；init全文1–191优先，Plugin apply和addFlutterDeps所有非注释非空白行；exit0，0.2740056秒，末状态前UTF-8 30546 bytes | 1/1 |

两轮均先检查存在、普通非reparse文件、长度≤256KiB；读取入内存再核长度/hash，四hash均匹配。打印前主动累计UTF-8，上限32500 bytes，为32KiB留末状态空间；实际全部输出均低于32KiB，无输出门遗漏、无工具截断、无失败/重试/修复。第二轮明确省略空白与独占行注释，保留所选两个body所有非注释语句、原行号、条件和返回；没有重复输出M5-26的addFlutterTasks。

| 准确公开源码 | bytes | SHA256 | 新回显语义 |
| --- | ---: | --- | --- |
| D:/flutter/packages/flutter_tools/gradle/src/main/kotlin/plugins/PluginHandler.kt | 13311 | 3B22349766754AFD7CCEA99549782FA6A20CBBF291FB277A31E6B46758B67857 | 全文1–261；含companion内两方法，解除M5-26摘录缺口 |
| D:/flutter/packages/flutter_tools/gradle/src/main/kotlin/FlutterPluginUtils.kt | 35995 | E0EB454157E67127B7677D697E924EB6B0556C8A4E51405045BC5E7F77798FD0 | shouldConfigureFlutterTask243–268；buildModeFor359–366；isFlutterAppProject641 |
| D:/flutter/packages/flutter_tools/gradle/src/main/kotlin/FlutterPlugin.kt | 42405 | 1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313 | apply46–306；addFlutterDeps568–811，非注释body完整 |
| D:/flutter/packages/flutter_tools/gradle/aar_init_script.gradle | 7483 | B6B870954405C5D52AFEA183BB51B3220100C234401142D8C1BF3E2410CEE2C2 | 全文1–191 |

完整文件读取不等于全调用图核定；超出四源的helper/AGP/FlutterTask实现不追读，本机材料、文件存在与运行均未由hash证明。

## AAR入口、属性与host可达性

Utils:641的app分类是 `project.extensions.findByType(AbstractAppExtension::class.java) != null`，不是按is-plugin、root名或任务名。四正文采用com.android.library，设计对象应进入非app路径；实际AGP实例与时序未执行验证。

Plugin apply:46–306完整body中50–52只有app分类时注册lockfile生成任务；54–132进行SDK定位、engine读、项目Maven注入、native loader应用、FlutterExtension及root local.properties读取；134无条件调用addFlutterTasks。apply没有is-plugin条件或提前return跳过该调用。后续ABI/deferred组件配置、版本checker、profile创建、forceNdkDownload及embedding调用不是一个AAR专用早退分支。

M5-26已核addFlutterTasks:349–533：state.failure非空才先返回；若isFlutterAppProject为真则处理app并return；否则455–468查root属性flutter.hostAppProjectName，缺省app并要求findProject非空。library host.afterEvaluate在470–526，configurePlugins在527–531的回调外调用。该body没有is-plugin早退，init全文也没有创建app、改写分类或替换addFlutterTasks的代码。

因此，在前置配置未失败、分类为library且进入此已核链时，host check可达；四正文没有app子项目/host属性，对默认host没有提供项目。仓库/SDK/engine等更早失败可能使之不可达，不能称实际首异常；但传 `is-plugin=false` 或以root ext声明false并不从源码建立绕过host的能力。M5-26局部事实现已合并到apply可达条件，不能只根据“官方AAR”名称假定standalone路径存在。

不同属性语义必须保持：

| 使用点 | 条件 | false的含义 |
| --- | --- | --- |
| init:151–156 | root必须有is-plugin；值toBoolean决定plugin-root或module发布 | false选择module发布，查:flutter，不代表属性缺失 |
| init:41–69 | project.property(is-plugin).toBoolean | false跳过plugin发布函数里的远端repo/compileOnly release embedding分支；不取消FlutterPlugin本身repo注入 |
| Plugin:632、647–648 | project.hasProperty(is-plugin)作为isBuildingAar | 即使false，只要project可见该属性，按AAR处理并使isUsedAsSubproject为false；该点不负责跳过host |

renderer的root ext is-plugin/output-dir/buildNumber与子project可见性不可自动当作完整调用证明；init要求root is-plugin及module output-dir，addFlutterDeps要求project属性存在。未来应在显式受审调用合同固定module模式false及准确作用域，不依赖未核继承来宣称可执行。M5-14已保存Flutter调用追加-Pis-plugin/-Poutput-dir/-PbuildNumber/-Pflutter-root和init来源，这里引用其结构，不生成或运行argv。

## init介入与发布接线

init:113–115在项目评估前对allprojects apply maven-publish；117–148 afterProject遇非Android或已有singleVariants即返回，否则按所有buildTypes/flavors配singleVariant及sources/javadoc。renderer singleVariant(debug)可能使本module跳过该自动扩展，但插件项目是否已有配置和variants没有运行证明。

150–190 projectsEvaluated才检查root is-plugin：true配置root并return；false跳过root名gradle，否则在rootProject.subprojects中查找flutter、要求module output-dir并configureProject。rootProject.subprojects中其它除flutter/app的项目被当modulePlugins，configurePlugin后按module所有libraryVariants绑定对应assembleAar任务。不存在plugin任务或variant不匹配会遇named/get/assert边界，脚本不是仅debug图。此回调无法从源码被当作在Plugin apply的134之前改变host逻辑。

configureProject:9–39要求android.libraryVariants，去-SNAPSHOT再以buildNumber覆盖version，对非all组件addAarTask；发布repo为outputDir/outputs/repo。87–106创建assembleAar<Component.capitalize()>任务，仅当startParameter.taskNames含准确无前缀taskName才创建对应MavenPublication并finalizedBy publish；artifact后缀为pub.name，from component。合格任务命名/组件/pub.version/POM实际值仍未运行核定，不能把最终publish约束等同单一debug文件。

true的configureProject分支45–69读取host env与SDK engine.realm/stamp，再加项目远端Maven、compileOnly release embedding、transitive=false。false的module及插件项目是否均看到false必须由property作用域合同核定；不会因本函数不加repo而消除FlutterPlugin:97–101的allprojects注入。

## 完整插件依赖与embedding接线

Handler:48–89通过Bridge取list并缓存，configurePlugins先逐插件configurePluginProject，再逐插件configurePluginDependencies。63–74另有dependencyGraph取值/cache方法；本文件configurePluginDependencies用pluginObject.dependencies，不把dependencyGraph缓存等同此接线的输入。Bridge/native loader实际读取仍只引用M5-26，真实metadata未读。

116–160按name找project，找不到return；创建FlutterExtension。module.afterEvaluate按buildType名称在非dev或名称不为release时加 `<buildType>Api` project依赖。plugin.afterEvaluate比较compileSdk字符串并警告，再按module每个buildType调用embedding函数。renderer显式implementation与这里Api路径是两份声明，不再假定仅有implementation，是否实际去重/POM如何表达仍未证。

162–208：buildModeFor先profile名称、再debuggable、否则release；supportsBuildMode为false或plugin缺android则return。plugin如isBuiltAsApp则复制所有buildTypes；否则创建缺失的兼容buildType，仅复制debuggable/minifyEnabled。最后调用addApiDependencies(pluginProject, buildType.name, `io.flutter:flutter_embedding_<flutterBuildMode>:<engineVersion>`)。engineVersion在本轮apply:67–75为非local-engine `1.0.0-<stamp>` 或local-engine `+`，实际stamp材料与resolved版本未知。supportsBuildMode/isBuiltAsApp/addApiDependencies完整实现不在本次选段，故只证明传入坐标表达式及调用，不能断言最终配置或解析工件。

226–258按plugin name找project，逐module buildType：release buildMode且dev_dependency为true则跳过；dependencies必须List，每项必须String，空项或找不到依赖project则跳过；每项注册plugin.afterEvaluate向implementation加dependencyProject。它没有按buildType命名该implementation，也没有跨循环去重；可能重复注册/声明的实际结果未运行核定。人工schema/图校验不替代运行metadata输入、真实插件build.gradle/组件、GAV和POM闭包。

## Flutter任务注册、参数、输入输出

Utils:243–268只有单一且含assemble的CLI任务名才进一步筛选：去冒号前缀，assemble/精确assembleTask名称，或两边同Release/Debug/Profile后缀返回true，其余false；多任务或不含assemble则true。此helper不足以证明所有其它发布/任务均受debug隔离。359–366的buildModeFor规则已核，不能由debug名称推断任何任意buildType的模式。

Plugin addFlutterDeps:576–605读取filesystem roots/scheme、frontend/snapshot/split/performance/code-size、dartDefines等project属性；trackWidgetCreation缺省true、obfuscation/treeShake/deferred缺省false、validateDeferredComponents缺省true。607–629有ABI split修改outputs分支。632按is-plugin存在判断AAR；647–648只有packageAssets/cleanPackageAssets均存在且非AAR才是isUsedAsSubproject。

650–701形成variant buildMode/flavor与compile任务名（toCamelCase及FLUTTER_BUILD_PREFIX未展开），register FlutterTask，配置SDK/可执行文件、minSDK、localEngine值、target/verbose、filesystem、defines等参数；sourceDir取getFlutterSourceDirectory，intermediateDir在项目buildDirectory的 `<INTERMEDIATES_DIR>/flutter/<variant>/`。702立即get provider可导致任务配置实现被取用，不等于TaskAction执行。FlutterTask body不在四源，完整进程argv、输出/缓存/重试/registrant行为未证。

703–741注册packJniLibs Jar、依赖compileTask，libs.jar位于相同intermediate目录；从各ABI intermediate收集*.so改名入lib/abi，另从 `FlutterSourceDirectory/build/native_assets/android/jniLibs/lib/<abi>`收集native assets。这个source/build读取根与app分支 buildDirectory/../native_assets表达不同，不能只凭root输出重定向声称一切位于outputs。

742–790注册Copy、依赖compileTask，with其assets，用户读写权限配置；isUsedAsSubproject才绑packageAssets及cleanPackageAssets并into outputs，其余仍依赖variant mergeAssets/clean任务、设置mustRunAfter、into mergeAssets.outputDir；非subproject分支再给processResources设dependsOn。795–809对compressAssets、bundleAar和bundleLocalLintAar存在的任务加Copy依赖，缺任务捕获UnknownTaskException并忽略。以上均为配置/注册与依赖关系，没有实际复制、打包或Flutter进程执行。

所选完整apply/addFlutterDeps及Handler/init中没有新增可见registrant生成调用；不能据此称系统不生成registrant，因为FlutterTask/native loader/其它超范围helper可能承担该行为。准确调用locator为 `FlutterTask::class.java` 的tasks.register（670）、compileTask.assets（748）、getFlutterSourceDirectory/getFlutterTarget等方法；其实现准确文件未由本次授权建立，不猜路径或扩读。完整registrant调用点仍UNRESOLVED。

## 合并配置修订提案与实质停点

本轮没有来源支持只修改四正文便得到无需host的standalone AAR路径。可推进的SOURCE-ONLY方案应先由Work审查一个统一的受控module配置合同，并把以下拟改对象与外部前置条件一起固定；下表是提案，不是已实施修复或官方兼容结论。

| 对象 | 未来受审修订/调用合同 | 当前保留的阻塞 |
| --- | --- | --- |
| settings + plugin应用 | 选择有来源的standalone AAR入口；若需受控SDK适配，精确审查其变更，而非凭本plan修改SDK。当前include:flutter/人工插件不能被新增app冒充修复 | apply→library host仍可达；没有四正文内已证绕过点 |
| root/Flutter properties | 固定module `is-plugin=false`、output-dir=publication根、buildNumber=输入ID及明确project作用域；flutter.sdk与init的flutter-root须指同一受审SDK；init必须成为调用合同的一部分 | ext继承、SDK relative解析/配置访问与真实identity需核定；属性不取消host/repo门 |
| Flutter dependencies | 后续可提出移除与Handler重复的显式implementation，按已证Api/implementation边审查合成图，保留必要材料而非自动改正文 | metadata真实输入、helper最终configuration及POM效果未证；未确定删除后的完整等价性 |
| variants/publication | module debug选择与singleVariant应与插件variants、准确assembleAarDebug请求、init发布与插件依赖任务共同约束 | profile创建、all buildTypes回调、publish最终图/工件选择未证；不靠任务后缀宣称全链debug |
| 输出合同 | 保留root/Flutter/plugin重定向，同时纳入.cxx、mergeAssets、intermediate/libs.jar、source/build/native_assets、included-build和publication目录 | 源码表达不是实际写入隔离证明；NDK/CMake及FlutterTask真实路径仍需审查 |
| 仓库/依赖材料 | 明确受控SDK/plugin如何处理allprojects Maven注入，独立included-build/项目/publication仓库角色，冻结embedding/AGP/Kotlin/SDK/engine材料 | FAIL_ON_PROJECT_REPOS静态冲突保持；不采用PREFER_SETTINGS、删gate、远端repo或local-engine捷径 |
| 系统/输入 | 固定config/local.properties/metadata/engine读取闭包、允许env、NDK下载隔离、Dart/assets/registrant输入与权限/网络边界 | 无真实材料可用性、TaskAction/进程/OS隔离、manifest合并或设备证明 |

最小实质后继建议：一张合并的“standalone AAR受控SDK入口适配与配置合同”来源/设计任务，优先解决当前无host独立library入口和仓库注入两处结构阻塞，并明确FlutterTask/registrant、Api依赖最终配置、output及材料作用域。未获得相应源码/预算前只做精确来源与可审设计，不增app、不移除检查、不直接实施SDK改写。若Work能从已保存准确来源建立另一条真实standalone入口，可据其合同提出四正文SOURCE-ONLY修订；当前保持UNKNOWN，不能用猜测补齐。此处不发布任务、不扩读、不创建重复record/拒绝器。

## 终止事实

专业两轮各1/1、总2/2关闭，无算法/测试或插件运行；SDK/源码/renderer/authority/旧证据均未修改。无bundle生成、其它源码追读/SDK目录枚举索引、配置/cache/env/home/真实properties/metadata/json/engine/插件材料读取、下载复制、Gradle/Flutter/JVM/ADB/构建安装启动/UAC、旧D:\EliteSync、真实数据/备份密钥/DB/SSH/生产API或Git提交/pull/push。

唯一plan交付停Work独立LEVEL2审查，不自接受、不派后继。新Work本轮不验收/派后继、heartbeat保持暂停的派发约束不由本候选改变。M5/隔离构建NOT_READY，settings/v1全拒绝、loader/runtime false，真实账号/Conversation/恢复及全部受保护门保持。
