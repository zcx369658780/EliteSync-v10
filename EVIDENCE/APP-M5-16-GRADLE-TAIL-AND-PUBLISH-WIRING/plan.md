# APP-M5-16｜参数尾部与发布接线候选

2026-09-30；DOCS-ONLY CANDIDATE / WORK LEVEL 2 REVIEW PENDING。补齐toGradleConfig方法结束及发布脚本尾部的静态规则；未执行任务图、生成POM或构建。M5/隔离构建仍NOT_READY，settings/v1全拒绝保持。

入口：D:\EliteSync-v10，main HEAD cf8bfaa4a03b8c9a682105617b185141904413be；当前ISSUED assignee 01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad。165条既有工作区状态保留。唯一新增本plan，不改M5-15已接受源码或其它authority/证据，不做Git写操作。

## 新预算与来源

一次新批量1/1耗尽；准确两文件各一次读入内存、由该内存字节一次SHA256，仅回显指定新尾部。退出0，输出完整、无工具截断或输出失败；正文预检UTF-8长度不超过11264字节并预留状态空间，总stdout在12KiB预算内。没有搜索、索引、枚举、扩读或重读。旧M5-15静态/测试各1/1、M5-14 1/1、M5-13 2/2均保持关闭。

| 准确源文件 | 新覆盖 | SHA256 |
| --- | --- | --- |
| D:/flutter/packages/flutter_tools/lib/src/build_info.dart | 377–430，方法结束385已见 | AF123D66AB4325F8D4F7819853653AC0808D09E33287B1DEA41204DAA54D8BE8 |
| D:/flutter/packages/flutter_tools/gradle/aar_init_script.gradle | 121–191，脚本结束190已见 | B6B870954405C5D52AFEA183BB51B3220100C234401142D8C1BF3E2410CEE2C2 |

前缀仅复用M5-14 plan与M5-13保存回执，不再读SDK旧段。哈希证明源字节身份，不证明工具可用或版本兼容。

## toGradleConfig完整方法的静态参数规则

365–376旧回执与377–385新段合起来，方法参数顺序已闭合：

| 次序 | 参数 | 添加条件 |
| --- | --- | --- |
| 1 | -Pdart-defines=<逐项编码列表> | dartDefines非空 |
| 2 | -Pdart-obfuscation=<bool> | 总是 |
| 3 | -Pfrontend-server-starter-path=<值> | frontendServerStarterPath非null |
| 4 | -Pextra-front-end-options=<逗号连接> | extraFrontEndOptions非空 |
| 5 | -Pextra-gen-snapshot-options=<逗号连接> | extraGenSnapshotOptions非空 |
| 6 | -Psplit-debug-info=<值> | splitDebugInfoPath非null |
| 7 | -Ptrack-widget-creation=<bool> | 总是，377 |
| 8 | -Ptree-shake-icons=<bool> | 总是，378 |
| 9 | -Pperformance-measurement-file=<值> | performanceMeasurementFile非null，379–380 |
| 10 | -Pcode-size-directory=<值> | codeSizeDirectory非null，381 |
| 11 | 对每项androidProjectArgs追加-P<原项> | 保持列表顺序，382 |
| 12 | --project-cache-dir=<值> | androidGradleProjectCacheDir非null，383 |

方法没有对androidProjectArgs做保留键过滤、编码、去重或冲突检测。这是新风险入口事实，不能把自有synthetic define函数视为整条参数注入已受控。method尾部本身未证明各BuildInfo字段默认值；trackWidgetCreation/treeShakeIcons/daemon/cache及额外参数的CLI生成默认仍须来源，不能自行宣称默认false或没有额外项。

AndroidBuildInfo构造函数391–398明确默认targetArchs为armeabi_v7a、arm64_v8a、x86_64，splitPerAbi=false。此为构造函数默认事实，不覆盖CLI可能显式传入的架构。BuildMode debug注释416–417说明JIT、asserts与VM service，并不保证完全无网络或无调试副作用。

与M5-14已核gradle.dart:791–856串接后，AAR调用数组的静态结构可完整描述为：wrapper、init、flutter-root、output-dir、is-plugin、buildNumber；verbose或-q；条件no-daemon；条件target；上述完整BuildInfo参数序列；local-engine分支或target-platform；最后aarTask。仍不是可执行命令：本轮没有核定全部具体字段值、wrapper/工具身份、自动配置/环境、local engine与CLI preflight。本任务不实际构造或执行算法。

固定synthetic设计建议显式赋值：只接受单一true define，obfuscation=false，track-widget-creation/tree-shake-icons作为经审明确bool，不取未知默认；禁止frontend/snapshot/split/performance/code-size与任何androidProjectArgs；project-cache-dir要求准确的词法受控相对根。禁止项是自有切片的收窄规格，不冒充SDK原有拒绝规则。

## 发布接线的准确规则

afterProject前缀来自M5-14脚本117–120。121–148补齐：无android属性时return；android.publishing.singleVariants.size()!=0也return；否则为每个buildType配置singleVariant。有productFlavors时用productFlavor.name + buildType.name.capitalize()，无flavor时直接buildType.name；每个variant带sourcesJar与javadocJar。147对所有buildTypes执行，不是只配debug。已有singleVariants非空时保持项目自己的配置，因此不能推断这条分支总能创造所需debug组件。

projectsEvaluated:150–190：

- 151断言rootProject有is-plugin；若true，153断言root有output-dir，155调用configureProject(rootProject, root的output-dir)，156直接return。
- 若非plugin且rootProject.name==gradle，158–160跳过。注释提到android_generated，但代码只检查跳过名，没有正向校验root一定叫android_generated。
- 163在直接root subprojects中find名字flutter的模块；164断言非null、165断言有output-dir；166用该模块属性调用configureProject。
- 169–171把除flutter/app外所有直接子项目收集为modulePlugins，不是依据已核plugin元数据、包名白名单或android属性筛选。
- 176–177对集合每项调用configurePlugin，使用moduleProject的output-dir。旧前缀72–78中configurePlugin遇无android属性会return；但本尾部178–187仍随后遍历模块libraryVariants、查module与plugin的assembleAar<variant.capitalize()>任务并建立dependsOn，没有在这里按android属性跳过任务查找。未知/非Android子项目或缺匹配任务可能导致失败；静态代码不能证明当前子项目集合符合条件。
- 178–187使用模块所有libraryVariants，不仅debug；分别tasks.named(...).get()并断言任务存在，module任务dependsOn插件任务。175注释解释模块POM将依赖插件Maven artifact，但没有给POM实际值、依赖坐标或任务运行证明。

没有本尾部afterEvaluate钩子；可见钩子是afterProject和projectsEvaluated，不能补造其它时点。脚本整体113–115对allprojects应用maven-publish，前缀27–31配置非all组件，88–106创建组件任务/publication及finalizedBy publish，这些都只是静态配置/任务依赖规则，实际Gradle/AGP组件时点与最终任务图尚未执行。

输出关系现在闭合到调用者：plugin root采用root output-dir；module与其候选插件采用module output-dir；configureProject在旧36行把各自发布repo设置为该outputDir/outputs/repo。脚本未在这条已覆盖完整发布链设置rootProject.buildDir，也未说明上层outputDirectory缺省值；因此不能推定中间目录与最终repo同根。root/module属性继承规则及模板定义尚待来源。

## M5-15 recipe契合与限制

未发现需要修改已接受M5-15源码的合同错误：artifact_id后缀继续来自显式publication_name，task名来自debug component_name，两个名字不能自动等同。本轮variant配置涉及buildType/flavor/component来源，不建立publication.name必然等于某个模板默认名字的承诺。

project版本提案规则仍是前缀21–25：先去-SNAPSHOT，再buildNumber覆盖。configureProject现在已看到在root或module/插件中的调用时点，但仍没有自定义pub.version或模板project group/name/version定义；不能由接线闭合提升为实际POM版本已绑定。M5-15 record中的publication_binding_verified=False正确保留。

repository_relative_path表达词法output_root/outputs/repo，与脚本发布路径后缀吻合。recipe刻意不产生file URI、宿主绝对路径或做文件检查；这是材料接口域收窄，不是完整Gradle发布器。runtime_ready=False必须保留。

完整模板默认group/artifact/version、Flutter Gradle插件产生组件/publication的实际规则仍没有来源。当前新尾部没有给这些模板文件的准确路径，所以不猜路径、不列拟议SDK模板子文件作为已定位来源；后续若需要，须另立授权从已有project.dart模板逻辑名与Template.fromName来源准确定位逐文件闭包。

## 唯一建议下一薄软件切片

仅在已有两准确Python文件扩展纯材料能力：

- apps/android_synthetic_demo/tools/aar_material_functions.py
- apps/android_synthetic_demo/tools/test_aar_material_functions.py

新增keyword-only synthetic_build_info_arguments(track_widget_creation: bool, tree_shake_icons: bool, project_cache_relative_path: str) -> tuple[str, ...]。使用已接受synthetic_define_argument，固定obfuscation=false，按SDK顺序产生准确五字段材料：dart-defines、dart-obfuscation、track-widget-creation、tree-shake-icons、project-cache-dir。两个bool严格bool；cache仅复用已审canonical POSIX相对路径字符域，返回词法材料，不读取宿主、不resolve。

它专门表示收窄后的BuildInfo参数片段，不表示完整AAR调用；不接受通用extra参数、androidProjectArgs、override字典或未知默认，不生成shell字符串/可执行命令。不改变publication recipe的binding标记、settings/v1或完整argv门。其事实增量是完整BuildInfo尾部顺序、两个常驻bool与缓存字段材料，不是重复runtimeReady拒绝器。

负例/规则验证：严格bool拒绝整数/字符串/None；cache空/绝对/drive/UNC/反斜线/冒号/空段/./../尾分隔符/未知字符；固定单一true define；参数顺序与小写true/false；四种bool组合的独立固定预期；无extra/projectArg接口、无环境/文件/进程访问。测试期望须固定来自上表与已接受编码向量，不仅调用实现回算。新函数不声称封闭插件、所有Gradle属性或CLI自动注入。

建议新预算：一次两文件实现、一次有界纯标准库目标测试、一次准确两文件静态检查；具体进程/时限/双流上限由Work新task固定。本任务仅给建议，不运行算法、不测试、不派发后继。

## 未解门与终止状态

源码结构上的BuildInfo参数方法与发布脚本接线现已闭合；具体CLI默认/上层outputDirectory、模板/插件输入、默认GAV/pub.version/POM实际绑定、实际组件/variants/子项目与发布任务图未闭合。SDK/engine/Gradle/JDK/Android材料身份、Maven/Pub闭包、wrapper下载、自动配置/父环境/重试/OS网络隔离仍未证。AAR/host构建、签名、安装、首帧与实际数据边界均NOT_CHECKED。

本次无算法执行/测试/Flutter/Gradle/JVM/ADB/复制/下载/模板生成/安装/UAC，无其它SDK/cache/config/home/真实properties/旧仓库/备份/密钥/DB/SSH/API访问。真实账号、Conversation、G08/G11与恢复回填保护门及旧预算保持。唯一plan后停独立Work LEVEL 2审查，不自接受、不创建后继；M5/隔离构建仍NOT_READY。
