# APP-M5-14｜AAR参数、编码与发布来源合同候选

2026-09-30；DOCS-ONLY CANDIDATE / WORK LEVEL 2 REVIEW PENDING。准确补齐AAR调用参数追加段、define编码定义及发布函数规则；完整BuildInfo参数尾部、module模板和发布脚本后续接线仍UNRESOLVED。M5与隔离构建NOT_READY。以下为静态来源与后继接口设计，不是GO命令。

仓库D:\EliteSync-v10，main HEAD cf8bfaa4a03b8c9a682105617b185141904413be；Assignee 01a0f0b9-40a0-79a1-ab65-ebeaad09d9ad。入口163条非忽略工作区状态保留。本任务只新增本plan，不改M5-13作者plan、authority、源码或SDK，不提交/同步Git。

## 一次新来源预算

新批量预算1/1已耗尽。三文件各一次ReadAllBytes，再由该内存字节计算一次SHA256、解码并定点回显；无SDK重读、搜索、索引或源码执行。命令退出0，三个READ_OK/hash先完整输出，工具无截断；正文采用保守12000字节预算（为状态预留1024字节），未回显段有明确标记。未保存另一结果文件，唯一交付本plan。旧M5-13预算2/2已关闭，本次不重置它。

| 准确文件 | SHA256 | 实际可见范围 |
| --- | --- | --- |
| D:/flutter/packages/flutter_tools/lib/src/android/gradle.dart | CAB8B82F27CFA0FCBA61E3502683D067EC583CDFC728A63B63C74E8837D6E2FD | 770–870全部 |
| D:/flutter/packages/flutter_tools/lib/src/build_info.dart | AF123D66AB4325F8D4F7819853653AC0808D09E33287B1DEA41204DAA54D8BE8 | 1080–1110全部 |
| D:/flutter/packages/flutter_tools/gradle/aar_init_script.gradle | B6B870954405C5D52AFEA183BB51B3220100C234401142D8C1BF3E2410CEE2C2 | 1–120；脚本共191行，121–160因总输出上限未回显，161以后不在选段内 |

第三文件路径由本新task明确授权；本轮gradle.dart:783–790也独立建立flutterRoot/packages/flutter_tools/gradle/aar_init_script.gradle的构造关系。未读取缓存工件/真实properties/配置/其它模板。只读复用M5-13已保存第二轮回执中build_info.dart:365–376与base/process.dart:348–356，未重跑SDK。

## 一次debug AAR的源码参数序列

已建立调用位置：gradle.dart:779–798、799–813、821–856、861–866。以下按数组顺序列出参数，而非可复制shell命令。占位字段必须来自未来已审输入，不代表本机已存在材料。

| 顺序 | 源码实际规则 | 固定debug设计取值/限制 |
| --- | --- | --- |
| 1 | _gradleUtils.getExecutable(project) | SDK实际选择wrapper；不能写成固定分发直接入口 |
| 2 | -I=$initScript | flutterRoot/packages/flutter_tools/gradle/aar_init_script.gradle |
| 3 | -Pflutter-root=$flutterRoot | 源码使用Cache.flutterRoot的绝对路径；D:/flutter是任务固定来源，未验证运行配置 |
| 4 | -Poutput-dir=${outputDirectory.path} | 使用上层传入输出根，不能等同module中间buildDir |
| 5 | -Pis-plugin=${manifest.isPlugin} | 已核上层仅module允许构建（775–776），未来冻结module输入应核定false |
| 6 | -PbuildNumber=$buildNumber | 上层缺省1.0；设计使用唯一input-id，但本任务不构造ID |
| 7 | verbose时--full-stacktrace、--info、-Pverbose=true，否则-q | 设计nonverbose，只-q |
| 8 | !buildInfo.androidGradleDaemon时--no-daemon | 设计明确false；CLI默认daemon值未核定，不当默认事实 |
| 9 | target非空时-Ptarget=$target | 上层build_aar固定lib/main.dart，M5-13来源132–143 |
| 10 | addAll(buildInfo.toGradleConfig()) | 此调用813行已闭合；完整列表仍有下述缺尾限制 |
| 11 | 非local engine且targetArchs非空：-Ptarget-platform=各platformName逗号连接 | 首切片固定android-arm,android-arm64,android-x64；作为上层默认架构来源的设计输入 |
| 12 | aarTask | getAarTaskFor(debug BuildInfo)，M5-13 gradle.dart:131–132的assembleAar前缀；发布脚本88–89按组件首字母大写形成assembleAarDebug。实际任务存在性未验证 |

localEngineInfo非null时还会创建local engine repo，添加local-engine-repo/build-mode/out/host-out、复制repo到输出目录并用local engine推导target-platform（821–848）。未来普通SDK设计必须拒绝local engine输入，不能省略该分支后宣称所有SDK调用无复制。当前未调用它。

BuildInfo.toGradleConfig已见前缀（保存回执365–376）：非空defines加-Pdart-defines；总有-Pdart-obfuscation；非null frontendServerStarterPath、非空extraFrontEndOptions/extraGenSnapshotOptions、非null splitDebugInfoPath分别追加对应-P参数。376以后未在保存回执显示，本任务不扩读。因此完整实际argv清单只能用有来源的BuildInfo.toGradleConfig(buildInfo)符号槽表示；不能声称仅以上两项就覆盖全部参数。未来固定false obfuscation、禁额外frontend/snapshot/split参数是受控设计，尚须核定完整尾部再实现可执行argv。

进程调用cwd=project.android.hostAppGradleRoot.path，allowReentrantFlutter=true，environment=_java?.environment。无timeout/maxRetries参数传入该run调用（861–866）；保存回执run声明默认timeoutRetries=0，但整个工具启动/底层进程/Gradle重试未闭合。无--offline、--gradle-user-home、--project-cache-dir或固定分发覆盖出现在本轮AAR调用追加段；不能自行把设计参数说成Flutter已添加。

M5-13已有来源：getExecutable先注入wrapper；Java选择按Flutter配置jdk-dir、Android Studio、JAVA_HOME再PATH，Java环境带父PATH。底层_environment与父环境继承、wrapper下载/全局init/Gradle自动配置及完整重试链仍未闭合。未来固定分发直启、环境白名单、固定user.home/缓存和网络封闭需要独立启动器与验证，不由这张docs接受授权。

## define编码的纯函数规则

build_info.dart:1081定义utf8.encoder.fuse(base64.encoder)，1095–1096对每个输入String分别转换，再用ASCII逗号连接。不先拼接明文，不排序、不去重、不修剪、不做Unicode规范化。UTF-8编码文本，标准Base64编码字节；这是Dart转换器的源码组合，非本机算法试跑。Base64条目内没有逗号，原文逗号也被编码；标准Base64允许+、/和末尾=，不能擅自改URL-safe/去padding。decode完整实现不在1080–1110覆盖范围，不据此建立容错解码合同。

单一合成输入准确为列表["ELITESYNC_SYNTHETIC_DEMO=true"]；输出表达式为Base64(UTF8("ELITESYNC_SYNTHETIC_DEMO=true"))，单项无逗号分隔，Gradle槽为-Pdart-defines=<该结果>。本任务按禁止算法执行要求未计算字面值，也未跑编码测试。单一true输入约束来自产品隔离设计；SDK编码函数本身不会拒绝重复键、false或额外defines。

未来纯函数encode_dart_defines(values: tuple[str, ...]) -> str应保持顺序与逐项编码；另一个材料函数只接受准确synthetic单项，不替SDK猜默认值。通用函数可支持空列表返回空字符串；生产该-P字段的接口在空列表时应省略字段，符合toGradleConfig:368。Unicode异常输入的跨语言等价性未核，首切片明确拒绝孤立surrogate，而非假称全部Dart String行为已复制。

## 发布函数的实际规则与缺口

aar_init_script.gradle:9–15要求Android library；21将project.version中的-SNAPSHOT去除；23–25在buildNumber属性存在时把project.version覆盖成该值。27–31为每个非all组件调用addAarTask。33–39设置Maven URL=file://${outputDir}/outputs/repo。因此最终发布路径是传入outputDir下outputs/repo，而不是仅outputDir；rootProject.buildDir与outputDir默认的关系不在可见接线段，仍UNRESOLVED。不得把M5-10历史拟议module/build/host路径写成此轮已证事实。

87–106中组件名capitalize得到variantName、任务assembleAar<Variant>。只有准确任务名存在于startParameter.taskNames时才创建该组件publication；groupId沿用pub.groupId，artifactId改为pub.artifactId + "_" + pub.name，version沿用pub.version，from component，并finalizedBy publish。这不是任意项目名都固定flutter_debug。module模板/project默认group与artifact、publication默认值如何绑定project.version、全部publish任务图仍需准确来源；已读函数没有提供com.elitesync.syntheticdemo这个group。

POM通过MavenPublication/from component及publish产生，依赖来自组件元数据；脚本1–4说明产物包括AAR/POM，但未显式给出依赖重写/完整POM闭包。不能宣称pubspec所有依赖自动正确进入POM或复制AAR即可重发布。

41–69的插件分支：is-plugin转换false立即return；true则读取FLUTTER_STORAGE_BASE_URL或默认storage.googleapis.com、engine.realm与engine.stamp的缓存文本，增加远程Maven源以及io.flutter:flutter_embedding_release:1.0.0-<engineVersion> compileOnly、transitive=false。即使顶层debug，也不能从此分支推断embedding一定debug。72–78 configurePlugin对无android属性的插件跳过，其余调用configureProject。113–115对所有项目apply maven-publish；117–120只有afterProject开头，121以后未回显。哪些module/插件项目在何时得到outputDir、variants、version/property与任务依赖链，仍未建立。函数定义存在不证明实际所有插件发布接线或只发布debug。

拟议优先直接使用冻结input-id作buildNumber版本：源码允许属性覆盖project.version，但唯一版本只隔离同一坐标的版本，不建立源码/字节身份，也不改变group/artifact。接受前须核定模板group/artifact和插件同版本传播、版本字符合法性、每项POM闭包与产物hash。暂不采用com.elitesync.syntheticdemo:flutter_debug作为已支持坐标。

如果最终必须改变group/artifact，须独立经审重发布过程：保持AAR字节、重建并验证POM坐标和所有依赖映射、逐项验原始与目标GAV/byte/hash/文件清单，拒绝悬空或跨共享repo依赖。该过程不是移动目录；本轮不生成、不复制、不重发布任何材料。

## 唯一建议下一具体软件切片

在已接受SOURCE-ONLY根新增准确两文件：

- apps/android_synthetic_demo/tools/aar_material_functions.py
- apps/android_synthetic_demo/tools/test_aar_material_functions.py

不改既有v1 validator/build-contract/settings，不增加另一executionReady拒绝器。此切片产生可独立核验的内存参数与坐标材料，完全不访问文件/环境/SDK/cache，不启动进程、不写模板或staging。

具体接口：encode_dart_defines(tuple[str,...]) -> str执行逐项UTF8/Base64/逗号规则；synthetic_define_argument() -> str生成准确单项-Pdart-defines字段；publication_recipe(base_group, base_artifact, component_name, base_version, build_number, output_root) -> immutable record，包含按上述代码的artifact后缀、版本处理、repository路径表达式、准确组件任务名及来源引用。base_group/base_artifact必须作为已审显式输入，不推断项目默认值；输出字段标注从组件/POM仍需验证，不伪造POM依赖。限定组件debug、禁止all/profile/release和空/不合法输入，保持字符串处理纯函数，不用resolve/stat确认路径。

暂不在此切片生产完整可执行argv：BuildInfo尾部与publish接线尚缺。可返回已证argv字段的有序材料记录，明确complete=false及未知槽名称；不能输出shell字符串或启动器。待独立来源闭合后再扩为全argv/生成器，不让半清单被当作可执行命令。

新规则测试建议：ASCII/Unicode/原文逗号与等号、多项顺序、空列表、标准Base64 padding、单一synthetic输入；重复/额外synthetic define由固定材料接口拒绝；孤立surrogate；debug后缀/task命名；-SNAPSHOT替换与buildNumber覆盖次序；缺group/artifact、非法组件/version、含分隔符或路径逃逸的纯字符串拒绝；outputRoot到outputs/repo映射。测试预期须来自独立固定向量或手工已审例子，不仅做函数自身roundtrip。首版本recipe输入限经过审查的字符/路径域，不声称覆盖全部Groovy字符串或所有Maven版本语法。

建议预算：一次准确两文件实现，一次纯标准库目标测试进程，一次两文件静态/无宿主访问审查；具体时限与输出上限由Work新task规定。此处仅建议，没有执行算法或新增预算。交付后独立LEVEL 2审查；不解除settings全拒绝，也不升级为运行就绪。

## 保持未解的门

准确未覆盖：BuildInfo.toGradleConfig 376以后；发布脚本121–191；module/Gradle模板逐文件闭包及实际buildDir/group/artifact/variant；完整Dart/assets/plugins源码输入、隔离package映射与原生注册；engine/tool/Gradle/JDK/Android身份与Maven/Pub依赖材料；自动配置/父环境/网络/系统隔离、完整子进程与重试；实际AAR/POM/GAV/hash/签名/合并manifest/权限与设备身份。

本轮无Flutter/Gradle/Python算法验证/JVM/编译/测试/ADB，无复制、模板落盘、下载或安装，无真实properties/cache工件/用户配置/备份/密钥/DB/SSH/API/UAC/旧仓库访问。M5-13接受与旧预算原样；真实账号/Conversation/G08/G11/恢复回填门不变。交付唯一plan，停独立Work LEVEL 2审查，不自接受、不创建后继。M5与隔离构建仍NOT_READY。
