# v10.1.5｜项目artifact变体定点纠正与单次离线解析

2026-10-23，UTC+08:00。**VARIANT_FIX_BOUNDED / OFFLINE_RESOLUTION_FIRST_BLOCKER / NO_APK**。

一份有据LOCAL_ONLY init修正、唯一隔离Gradle fixture **1/1 exit0、11项PASS**完成。正式解析 **1/1 exit1、19.056721秒**；第一项 :flutter:debugCompileClasspath 已按 java-api / android-classes-jar 进入真正 Configuration.resolve()，随后Gradle IdentityTransform因本地派生 libs.jar 不存在而失败。**BEGIN1 / OK0 / 29 NOT_RUN**。原多artifact歧义本次未打印，不代表所有变体问题或30配置已通过。首阻断后停止，没有生成替代文件、构建AAR/APK或重试。

## D0：权威、连续身份与具名保护

任务单Blob **6d5450e7b5748803f5829f4f59995332d8caeaa0**；最新Astra独立审查Blob **808f8cda0ded459811384c9c63db9a4fe0b8b935**。ACTIVE_STATE和固定原报告/Manifest已读取核验：原报告Blob 1b39ce901faa27826143ca151b370ff91e75987c、原Manifest e83f2f6992530dfa63a37fbd32fda6467b4d46a4。

开工live main **989644e487cac023003ce3d73eed4f7a6a728b1f**，Root 09defd2ce92d39b26596b43585294cbeee8c64a5，仍为v10.1.4接受产品 apps 3468a3dd97da7accfda2539a0f8d8f68931a6110 / services 0cb1f9d19659291a462488b3686fd0a07a6698ac，没有覆盖未接受v10.1.5。

连续起点及本次唯一Parent **9e3333151125deb9985e86324811c1737a4fa90d**，原Root 34b72d5916edc2e928f28187c760a05eb64e83c6、其sole Parent d45c0fae755fb97e1df9cbdc875965725a88d969。固定产品source 1522466faf798b719ccff281de7584f043946437；apps 785822ca072943c5bfefa3ccc37ede01c2af5164、services 1e1e20bb3500bedb1a521e5f2ddeece915d09424、跟踪app构建Blob bdb8e241d3e0defd1793c90b5f730c2facd7433d均不改。

原stderr 102148B / SHA256 78894d70ca6600fde5a94f9f2f375411a82d487e57d521fdf69b659382e09ec2、stdout 2620B / SHA256 3c2daa4368a821a9f779c0736dbe6ffc969f3696fe1728dccda8bd75ef617bea和旧init、runner、私密env、所有失败原证保持。前轮50键环境、38项安全fixture、HOST及25项fixture作为已审历史证据，**本轮均未重跑或重新采样环境**。历史actual Hash及差异键的UNKNOWN不倒填。

D0初始清单311140项，继承此前Hash与当前未变size/mtime **289349项**，对新增/元数据差异及新补列前证 **21791项实际Hash**；不是重新全量Hash或全盘扫描。复用已核隔离工程/Gradle home，未再复制7.3GB SDK。终检另核实并补列1件既有归档，最终311141项，见D3。503旧refs（包含原502）、五历史根、153既有Windows长路径warning，SQL/APK/备份/未提交成果/未授权part及原cache/日志按具名范围保留。

## D1：真实属性合同与唯一修正

旧stderr是首个compile配置的一次错误，含14插件相同secondary artifact歧义；不是14个配置已运行。consumer要求library、compile-time、Android target、AGP8.11.1/debug/androidJvm，缺少artifactType约束；它没有证明任何候选类型天然正确。

以固定本地AGP8.11.1 JAR字节码核定，而非从错误列表任选：AndroidArtifacts.CLASSES_JAR字串为 android-classes-jar；PublishingSpecs把LIBRARY绑定到其Companion$3，分别发布：
- api(COMPILE_LIBRARY_CLASSES_JAR, CLASSES_JAR)；
- runtime(RUNTIME_LIBRARY_CLASSES_JAR, CLASSES_JAR)。

ComponentImpl.compileClasspath明确消费 COMPILE_CLASSPATH / CLASSES_JAR；VerifyLibraryClassesTask分别消费 RUNTIME_CLASSPATH / CLASSES_JAR。ConsumedConfigType的compile关联API_ELEMENTS、runtime关联RUNTIME_ELEMENTS。**类型字符串相同不等于payload或依赖图相同**：compile保留java-api、compile产物；runtime保留java-runtime、runtime产物和runtimeOnly/传递关系。这里验证classpath class artifact，不声称已验证APK资源/JNI打包或RTC。

现存connectivity_plus 7.3.1脚本apply com.android.library，其buildscript有8.12.1声明；这是保留源码里的声明，不能冒称本进程实际已升级。原运行属性与本任务冻结合同为8.11.1，未改版本、SDK或插件源码。

Gradle官方概念区分图变体与artifact集选择。在线current为9.8.2，仅作概念参考；版本化网页工具不可读后，实际核了本机冻结8.14的 artifact_resolution.html 和 ArtifactView.java。默认文件解析使用Configuration属性，严格文件解析会传播失败；没有使用会重选图变体的withVariantReselection。参考：[官方概念文档](https://docs.gradle.org/current/userguide/artifact_resolution.html)。

**唯一方案**在本任务init副本加入一份严格policy：只在原15模块的debugCompileClasspath/debugRuntimeClasspath追加明确artifactType=android-classes-jar，断言对应usage、可解析和transitive，断言其它原属性不变；原调用委托该policy后仍真实调用 config.resolve()。返回文件必须存在、非空、可读并实际打开，否则拒绝，不能用路径集合当真实文件PASS。没有lenient、graph-only替换、关闭传递依赖、任取首候选、跳插件或改独立LocalProject源码。

原init其余正文、exact io.flutter三GAV过滤、仓库receiver、15×2顺序与首异常停止不变。新init SHA256 **2e97394f0dffd7818058e587cda8eaf0ec5ff747198d6a60e9872b14b96e1a6f**；policy SHA256 **bfb7633a037f84e7e7c41060563841add01648387ecafbd34a7e7d8e142e5c58**。正式argv仅-I路径指向新副本，其余cwd/三flags/四iceDiag参数/目标平台/离线参数原样；原43输入pins保留，增加新init Hash。50键sealed env原字节保留，canonical Hash **78b730a3ddbdfda3a908138fc67a0352ba80bb9d0bb14ad4c0e684309c64db52**；ANDROID_PREFS_ROOT无任何大小写键，ANDROID_USER_HOME归属不变，仍将同一已验证字典直接传Popen。

唯一隔离Gradle8.14 fixture **6.043156秒、exit0**，只有自有合成producer/consumer和已生成的测试JAR，没有APP插件或本产品依赖。11项验证包括：旧compile/runtime歧义复现；修正后compile精确2个实文件、runtime精确3个实文件且runtimeOnly/传递关系保留；usage不合并；错误type、不同AGP、缺失GAV、缺文件、关闭传递、越界配置均拒绝。fixture与正式init使用相同policy字节。合成fixture不是产品30配置PASS。

一次非作者GPT-6.1 Sol/high静态预检在正式预算前确认上述依据、差分和负例，冻结7份入口/回执Hash。非作者没有执行fixture或Gradle。

## D2：唯一正式解析与新首阻断

可信本地Gradle8.14 bin SHA256 af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab；Flutter3.41.7 / Dart3.11.5 / engine 59aa584fdf100e6c78c785d8a5b565d1de4b48ab / AGP8.11.1 / Kotlin2.2.20 / JDK17.0.18.8不变。相关进程0、61锁只读独占检查PASS、APK0。

唯一真实目标 resolvePinnedDebugInputs，保留 --offline --no-daemon --console=plain --max-workers=2 -Ptarget-platform=android-x64,android-arm64，不用Wrapper/refresh/continue。BEGIN与选择标记各1，真实 config.resolve()进入后，stderr打印：
1. Failed to transform libs.jar，目标artifactType=android-classes-jar；
2. Execution failed for IdentityTransform；
3. File/directory does not exist。

缺失文件仅公布任务相对路径：**project/apps/flutter_elitesync_module/.android/Flutter/build/intermediates/flutter/debug/libs.jar**。这是本地派生输入缺失，未观察缺失Maven GAV，不归因为SDK损坏或官方二进制缺失。IdentityTransform是transform名称，不是已打印异常类；最深已打印事实是文件不存在，异常类 **NOT_PRINTED**，未追加stacktrace。该artifact节点显示java-runtime不表示debugRuntimeClasspath已执行；本配置选择标记仍为java-api。Gradle本身在resolve中先失败，policy的postResolve文件检查尚未到达。

原8类候选多选文案本次未出现；这支持进入了新首阻断，**不证明所有14插件变体已全面解决或其余29配置可成功**。未生成libs.jar占位/替代文件，没有自动AAR/APK或补依赖。

stdout **1478B** / SHA256 **4a9525b5564cdddaafd6cbcbb68981befbba5f641f16b3b0d9ab91bf2658b21b**；stderr **1202B** / SHA256 **bcd399d4c0a4dce460278fe29c69ab0b90311b2e57d00be491a167609ad75258**。完整原字节及新daemon留LOCAL_ONLY，旧日志未覆写。

| 配置 | 状态 |
|---|---|
| :flutter:debugCompileClasspath | FAILED_FIRST |
| :flutter:debugRuntimeClasspath | NOT_RUN |
| :connectivity_plus:debugCompileClasspath | NOT_RUN |
| :connectivity_plus:debugRuntimeClasspath | NOT_RUN |
| :device_info_plus:debugCompileClasspath | NOT_RUN |
| :device_info_plus:debugRuntimeClasspath | NOT_RUN |
| :flutter_plugin_android_lifecycle:debugCompileClasspath | NOT_RUN |
| :flutter_plugin_android_lifecycle:debugRuntimeClasspath | NOT_RUN |
| :flutter_secure_storage:debugCompileClasspath | NOT_RUN |
| :flutter_secure_storage:debugRuntimeClasspath | NOT_RUN |
| :flutter_webrtc:debugCompileClasspath | NOT_RUN |
| :flutter_webrtc:debugRuntimeClasspath | NOT_RUN |
| :image_picker_android:debugCompileClasspath | NOT_RUN |
| :image_picker_android:debugRuntimeClasspath | NOT_RUN |
| :jni:debugCompileClasspath | NOT_RUN |
| :jni:debugRuntimeClasspath | NOT_RUN |
| :jni_flutter:debugCompileClasspath | NOT_RUN |
| :jni_flutter:debugRuntimeClasspath | NOT_RUN |
| :livekit_client:debugCompileClasspath | NOT_RUN |
| :livekit_client:debugRuntimeClasspath | NOT_RUN |
| :package_info_plus:debugCompileClasspath | NOT_RUN |
| :package_info_plus:debugRuntimeClasspath | NOT_RUN |
| :permission_handler_android:debugCompileClasspath | NOT_RUN |
| :permission_handler_android:debugRuntimeClasspath | NOT_RUN |
| :shared_preferences_android:debugCompileClasspath | NOT_RUN |
| :shared_preferences_android:debugRuntimeClasspath | NOT_RUN |
| :url_launcher_android:debugCompileClasspath | NOT_RUN |
| :url_launcher_android:debugRuntimeClasspath | NOT_RUN |
| :video_player_android:debugCompileClasspath | NOT_RUN |
| :video_player_android:debugRuntimeClasspath | NOT_RUN |

## D3：保护、复核与集中交付

终检先对311140项比较size/mtime，变化项及8份关键旧原证共 **33项实际Hash**。初版因一份旧daemon归档未列入新的top-level补充清单而分类FAIL，原退出与保护回执保留。随后只读核对：它与原具名运行回执、固定Git Manifest e83f2f6992530dfa63a37fbd32fda6467b4d46a4中的bytes/SHA256完全一致，mtime早于本轮baseline；将这 **1项既存原证**补列并Hash核实。没有改旧文件、忽略漂移或重跑全量保护/Gradle。最终311141项具名保护PASS，不伪称初版一次通过或全量内容重Hash。

不可变漂移0、丢失0、实际历史新增0；五历史根、503旧refs、153旧warning保持。获准复用runtime有 **6项缓存元数据变化、7项派生更新、176项新增**，fixture自有 **208件文件**另列；direct modules-2 raw工件新增0。所有变化/新增清单和Hash留LOCAL_ONLY，不称零写入或全盘/运行数据库/真机逐byte验收。相关24组Process/User/Machine环境摘要一致、归属工具进程0、global kill0。

同一次非作者复核继续核D2原始计数/首错、D3保护分类与公开生成逻辑，严重/必须项0，支持受限候选交付。未运行脚本/Gradle、未独立复算全量Hash；最终文档实体、Git发布和远端回读由主代理负责。Git对象/公开文本可独立核；本机字节码检查、fixture、Popen绑定、Gradle与保护为 **CODEX_REPORTED_LOCAL_ONLY**，不冒称Astra本机运行或JVM环境独立回读。

仅新建分支 codex/v10.1.5-ice-variant-selection-scoped-fix-single-resolve，从唯一Parent新增本报告和 ice_variant_selection_scoped_fix_and_single_resolve_manifest.json。普通non-force发布后回读Commit/sole Parent/Root/两Blob、完整apps/services Tree及raw文档字节；最终固定身份留发布后回执及交付消息，避免自引用。ACTIVE_STATE、旧报告、apps/services不改，不合main。

**VARIANT_FIX_BOUNDED / OFFLINE_RESOLUTION_FIRST_BLOCKER / NO_APK / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_PRODUCT_MAIN_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW**。

本任务停止，不修复缺失派生文件、不重置1/1预算、不构建AAR/APK，不自行派后续。
