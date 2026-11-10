# APP-M5-21｜插件loader来源候选

2026-09-30；DOCS-ONLY CANDIDATE / WORK LEVEL 2 REVIEW PENDING。官方入口到native metadata筛选与插件目录/输出绑定的源码链已定位。实际metadata、插件目录、项目图/POM和运行隔离未读取或验证；loader_binding_verified/runtime_ready保持false，M5/隔离构建NOT_READY。

入口D:\EliteSync-v10，main HEAD cf8bfaa4a03b8c9a682105617b185141904413be；当前ISSUED assignee 01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad。170条既有状态保留，唯一新增本plan，无其它源码/authority/旧证据或Git写操作。

## 两轮实际来源预算

第一轮一次准确读取/hash module_plugin_loader.gradle，2057字节，SHA256 169B243692655EF740AAB29795E4C4202A7B43B9A5E53EF713DA307211145913；全文1–49回显，退出0、无缺失/超限/截断。入口由M5-19 include脚本28明确引用，不重读旧模板。

该第一源10–11以buildscript.sourceFile.parentFile + src/main/scripts/native_plugin_loader.gradle.kts构造apply路径，属于第一轮直接静态字面量引用。第二轮仅一次批量读取其中1文件：D:/flutter/packages/flutter_tools/gradle/src/main/scripts/native_plugin_loader.gradle.kts，6843字节，SHA256 AAC04DBD690B5358B0690E200E4381E0089A3E9B04987C57D676D17EF86B4A20；全文1–156回显，退出0、无超限/截断。没有按import包名猜路径、搜索或追第二跳。第一文件根D:/flutter/packages/flutter_tools/gradle/。

每文件一次内存读取/hash，正文分别预检15500/23500 UTF-8字节并预留状态空间，均符合16/24KiB stdout预算及32KiB文件上限。两轮各1/1耗尽，共2/2关闭；第二轮最多2文件是上限，不是另剩可用轮次。全部旧预算保持。只读官方源码，没有解析实际JSON、读取插件目录或执行脚本/算法。

## 入口接线与隐式访问

module_plugin_loader.gradle:10–11求脚本根并apply native loader；13由:flutter.projectDir的两级父目录求moduleProjectRoot；15调用nativePluginLoader.getPlugins(moduleProjectRoot)。与M5-19:flutter绑定moduleRoot/.android/Flutter静态一致，但没有验证实际根/链接/目录存在或不同调用上下文。

16–20遍历所返回插件：pluginDirectory=new File(androidPlugin.path as String, "android")，断言exists，include :<name>，设置同名projectDir为该目录。没有在这些行限制插件名字符、保留:flutter/:app、同名重复、路径是否在staging或是否链接逃逸；exists不证明是普通目录/安全源码。重复/冲突最终行为依赖Gradle，源码本段未显式拒绝，不猜结果。

23取得:flutter项目父目录绝对路径（静态预期module/.android）；24–35在projectsLoaded→root beforeEvaluate为name在nativePlugins.name中的subproject配置输出：该父目录/plugins_build_output/<subproject.name>。缺目录时mkdirs，再设subproject.layout.buildDirectory。这是配置阶段写入入口，不是纯声明，不能只隔离最终repo。

36–39读取binding.variables.mainModuleName，非null/nonempty时写root ext.mainModuleName；不是读取OS环境变量。41–46 root afterEvaluate让每个非flutter subproject evaluationDependsOn(':flutter')，包含app及其它项目，不能称只插件。入口无显式网络调用，但apply/项目评估会进入外部插件配置代码，不能因此声称无网络。

## native元数据规则

native_plugin_loader.gradle.kts:16–17定义native_build与模块根下.flutter-plugins-dependencies；155注册extra.nativePluginLoader实例。

getDependenciesMetadata:135–151：实例缓存parsedFlutterPluginsDependencies非null时直接返回，不按本次root重查；否则构造模块目录下文件，存在时readText并JsonSlurper.parseText，要求顶层Map，缓存并返回；不存在返回null。不存在不是失败关闭，而是上层空列表。缓存是内存实例状态，本轮没有读取实际SDK缓存工件。不同root复用同一实例的行为仅据缓存条件说明，不宣称实际发生。

getPlugins:33–68：metadata null返回空列表；plugins必须Map；android缺失/null返回空列表，否则必须List。逐项必须Map；name/path必须String、dependencies必须List、dev_dependency必须Boolean。即使native_build=false，53–56其它结构检查也先执行。dependencies的List元素类型没有在这里逐项检查；dev_dependency被要求类型正确，但没有按true排除。60对native_build使用as? Boolean ?: true，缺失/null/非Boolean都默认true；明确false才跳过native build。61–65按原列表顺序保留原Map，68返回列表副本，未见深层冻结/去重/依赖图校验。注释展示dependencyGraph，但该方法没有用它筛选或建立依赖闭包。

格式/缺字段错误多处check/error消息含原Map或meta。未来处理实际内容若失败不应把SDK整段异常材料直接公开；本轮仅读官方固定源码，未产生真实插件错误或敏感内容。源码要求类型不代表名称/路径/哈希/源码行为安全。

被提及的ReflectionBridge注释路径与flutter_plugins.dart注释是第二跳，仅记录存在引用，不读取。JsonSlurper import不能转换为猜测源码路径。实际JSON/所有plugin原生源/Gradle脚本/manifest/依赖均未读。

## 与发布及纯拓扑对照

M5-16发布集合为所有非flutter/app直接subproject，并非只nativePlugins。本loader按metadata返回的native列表include名字，但不阻止其它settings/loader引入项目，也不证明一个插件不会叫flutter/app。因此不能把实际modulePlugins集合等同metadata列表或严格allowlist。

M5-20 excluded_plugin_candidate_names准确只是发布脚本候选筛选，:flutter仍发布模块。此轮来源允许描述插件projectDir=metadata path/android与输出module/.android/plugins_build_output/name，但真实列表与路径/目录合法性未知，不能更新既有record的loader_binding_verified/runtime_ready。app目录仍未得显式绑定。

项目group/artifact/version、自定义publication与POM依赖映射、组件/task存在、metadata生成刷新/完整输入和依赖材料、自动配置/父环境/工具身份/OS网络隔离仍未闭合。静态源码能读不证明实际项目图、发布链或生产可用。

## 唯一下一薄软件切片

建议准确扩展已有apps/android_synthetic_demo/tools/aar_material_functions.py与test_aar_material_functions.py，新增纯内存synthetic_plugin_materials(*, metadata: dict, approved_plugin_paths: tuple[tuple[str,str],...], module_relative_root: str) -> tuple[frozen PluginMaterial,...]。输入只人工构造的内存对象，不接文件路径/JSON文本，不解析JSON或访问宿主。输出每项name、project_name=:name、project_relative_dir=approved path/android、build_output_relative_dir=moduleRelativeRoot/.android/plugins_build_output/name、dependencies tuple、dev_dependency bool；loader_binding_verified/runtime_ready保持false。

SDK事实与自有收窄必须分开：metadata严格dict、plugins严格dict、android严格list且显式存在；每项name/path/dependencies/dev_dependency/native_build必需。native_build严格bool（拒绝SDK默认true的缺失/错类型）；dependencies严格list[str]；name收窄ASCII字母数字下划线安全域且拒绝app/flutter及重复；path必须等于人工approved tuple中的精确词法相对路径，复用canonical路径helper，禁止绝对/逃逸/真实缓存映射；不能从SDK原允许绝对path声称这是原规则。

approved entries明确固定到新task给定虚构插件名/路径清单（例如sample_alpha→materials/sample_alpha、sample_beta→materials/sample_beta）；函数本身可接批准tuple但调用测试只用这些fixture，不用真实插件名字/目录。拒绝重复批准name/path、unknown插件、保留名、交叉路径、未知字段/缺字段。native_build=false记录仍作结构校验但不产生native material，保序；dev_dependency=true保留，符合debug loader未排除它的事实。dependencies不得重复/自指/未知名，全部引用必须存在于fixture声明集；对false条目依赖语义需在新task明确限定，可收窄为native返回项仅依赖返回native项并拒绝循环，属于准备材料合同，非SDK原算法。

正例两虚构插件含依赖边、false native条目、true dev条目、固定路径/输出大小写/顺序；负例缺metadata平台、列表/类型错误、native缺失错类型、依赖元素错类型、重复/保留/unknown name、approved冲突、路径不匹配/逃逸、悬空/自指/循环、未知字段、frozen与无宿主访问。不把单纯路径校验或flags false当真实插件审核。

建议新预算一次两文件实现、一次纯标准库目标测试（保留原22方法回归）、一次两文件静态检查；精确fixture/schema/依赖规则、硬时限与双流上限由Work新task固定。本任务不给实现或测试权限，不生成settings、启动器、POM/argv/工程，不创建后继。

## 终止状态

新来源2/2耗尽；全部旧预算保持关闭。无实际metadata/json/properties/插件目录/env/cache/home/旧仓库/真实数据/备份密钥/DB/SSH/API读取；无算法/SDK工具/测试/Groovy/Gradle/Flutter/JVM/ADB/构建安装/复制下载/目标生成/UAC/Git写。唯一plan停Work独立LEVEL2审查，不自接受/后继。M5/隔离构建NOT_READY，真实账号/Conversation/G08/G11/恢复保护门保持。
