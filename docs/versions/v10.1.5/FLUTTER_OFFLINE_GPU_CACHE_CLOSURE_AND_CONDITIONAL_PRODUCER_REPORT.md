# v10.1.5｜Flutter离线GPU缓存来源、独立包Stage与条件式producer报告

2026-10-23，UTC+08:00。**OFFLINE_FLUTTER_CLI_CLOSURE_NOT_PROVEN / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN / NO_APK**，另附 **ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN**。

可信本地flutter_gpu已找到并通过有界来源核验：同版同engine原SDK缓存的 **34文件 / 162666B** 逐字节匹配固定framework Git Blob，另有5份真实必要版本元数据原样复制到**本轮独立包组件Stage**。但是**任务子进程可靠外联拒绝保证未建立并验证**，新Stage也只是39文件组件、不是完整可运行SDK，不能称CLI离线闭包PASS。本轮DAG不重跑，producer **0/1**、正式解析 **0/1**、30配置全NOT_RUN；没有新libs.jar、AAR或APK。

## D0：固定权威、连续候选与最短本地来源检查

完整读取任务Blob **9e6e4a16c5d3d8d05f9701c601901f897e58f424**、最新Astra复审Blob **5210b59f3ef9edb5299c95ccb7fa0a755f167da3**、live main ACTIVE_STATE及前轮固定报告 **fd3d6c6646f9f174ff5d0df52cc7e538817475fb** / Manifest **51bec69ca8f6958cb0679795561c4444b9bb9ef7**、前轮任务 **7e29ca75ed3d12d72108be45e00ca5ff7597bc82**。任务与审查raw字节核Git Blob，未新开整仓考古。

开工main **83c16824df948bc6a7a5786d9e3a7d12b55b763e** / Root **07d1e78b75667ac037f7614a2935a656ccef1d80**，仍是v10.1.4接受产品apps **3468a3dd97da7accfda2539a0f8d8f68931a6110** / services **0cb1f9d19659291a462488b3686fd0a07a6698ac**。连续起点及本候选sole Parent **df2bf34302fd65d0f69c0ea34a269eba03dc6a67**，其唯一Parent **8861c30464893f11968465fee365e5e5471fa773**，原Root **1781dbbacf0f2314786cadbe853660353787f4c5**。完整候选apps **785822ca072943c5bfefa3ccc37ede01c2af5164** / services **1e1e20bb3500bedb1a521e5f2ddeece915d09424**在入口直接与GitHub完整path/mode/type/object map比对（1133 / 791 entries），不拿main产品覆盖候选。固定产品source **1522466faf798b719ccff281de7584f043946437**及app Gradle Blob **bdb8e241d3e0defd1793c90b5f730c2facd7433d**不改。

只检查历史stage.py/复制回执已登记的**原SDK、旧Stage、当前执行Stage三个根**，每根定点看bin/cache/pkg/flutter_gpu、packages/flutter_gpu、engine/src/flutter/lib/gpu；另对已登记Pub hosted目录做flutter_gpu名称匹配。三个SDK版本均为Flutter3.41.7、engine **59aa584fdf100e6c78c785d8a5b565d1de4b48ab**。两个旧Stage均缺包，Pub匹配0；原SDK的cache package及对应engine源码目录各有34文件。没有全盘搜索、Git clone、新SDK或网络包获取。

原SDK本地Git HEAD **cc0734ac716fbb8b90f3f9db8020958b1553afa7**，origin为官方Flutter仓库；engine/src/flutter/lib/gpu具名路径clean。包pubspec声明name:flutter_gpu，真实lib/gpu.dart与lib/src源存在，包自身未声明独立发行版本；SDK归属由framework/engine和固定Git对象证明。

初版核验脚本错误要求cache与checkout的raw、case-sensitive文件表完全相同，assert exit1，发生在任何复制前；原脚本/工具失败回执与纠正证据均保留。后续有界逐文件说明差异：checkout有CRLF，以及两份BUILD.gn名字的大小写差异。v2先拒绝casefold碰撞，做完整Windows路径映射，再把**全部34份cache原字节直接与固定Git Blob比对**；checkout只在内存做CRLF比较，没有改写任何源文件。不是把任意内容差异忽略掉，也未替换其它版本。

## D1：真实包组件已复制，完整CLI离线安全门仍未通过

仅用实际文件copy2复制34份原缓存文件，保留其真实名字/字节，逐文件核大小、SHA256与Git Blob；共 **162666B**。文件清单摘要SHA256 **417491e869a583b46e6c4782656d47ac5fd13a07ba89b2a9775127a28e23696c**。另将flutter.version.json、engine.stamp、engine-dart-sdk.stamp、flutter_sdk.stamp、engine.version共5份**原件metadata**逐字节复制，没有人工生成stamp或占位目录。新Stage相对 **sdk-stage/flutter/bin/cache/pkg/flutter_gpu** 可追溯到同版原SDKcache。无链接复制；检查范围是已枚举源/复制文件及三条具名祖先链，不宣称整个SDK零链接审计。

这只证明 **LOCAL_PACKAGE_SOURCE_VERIFIED / PACKAGE_COMPONENT_STAGED**，不是完整SDK READY、不是新认证的官方archive或publisher签名，也不代表新Stage已被producer消费。新Stage只有39文件，不含完整launcher/工具/全部cache。未再次复制7.3GB SDK；旧SDK、旧Pub/Maven cache和两个旧Stage不补、不覆盖，旧执行Stage的flutter_gpu缺口仍原样。

50键sealed env原字节及canonical SHA256 **78b730a3ddbdfda3a908138fc67a0352ba80bb9d0bb14ad4c0e684309c64db52**保持；ANDROID_PREFS_ROOT任何大小写键不存在，ANDROID_USER_HOME归属及所有关键路径保持。核47份固定工具/输入pins。既有计划FlutterTask与cwd仍指向**旧执行Stage**；没有把新包的存在偷换为旧Stage已完整，也没有暗中重绑SDK或生成工程路径。

本轮已回读并匹配控制流引用的具名源码Hash。静态控制流和其限制如下（源码Hash称谓均指**继承冻结的旧执行Stage源码**，新39文件Stage不包含那些CLI源码）：

1. Windows flutter.bat/shared.bat先处理bootstrap与engine/Dart stamp、snapshot、工具pubspec时序；某些失配分支具有SDK更新或pub upgrade入口。既有Hash/早前audit可继承，但本轮没有通过启动CLI来证明全部分支封闭。
2. FlutterCommand缓存验证先查universal、再查平台requiredArtifacts；AssembleCommand没有对应offline选项时cache offline默认false。BaseFlutterTaskHelper不把Gradle offline转给Flutter CLI。FlutterSdk要求sky_engine/flutter_gpu，缺项可到updateInner的package zip获取入口。file URI配置不是整个子进程树外联拒绝机制。
3. PubDependencies缓存条目在package_config无效或根缺失时可能pub.get；正常assemble的pub/平台regeneration由shouldRunPub条件约束，未使用usesPubOption则提前返回。不能把这个局部条件写成所有Pub/bootstrap获取分支关闭。
4. native hooks是嵌套动作边界；继承事实中仅objective_c build hook且Android先返回。Windows下iOS USB更新有非macOS早退，不把它们的目录缺失宣称为Android必要下载。
5. 既有真实DAG只证明compile→pack和任务属性，不证明内部Flutter CLI无外联。当前**可靠任务子进程/子进程树外联拒绝guard尚未建立或验证**，没有网络抓包或网络拒绝测试。故按任务D1.3停止，而非把配置意图写NO_NETWORK保证。

没有实际运行producer，不能说网络请求发生、下载失败或SDK损坏，也不能推断缺包必定是实际执行的第一个异常。源包问题已有正向进展，但完整可运行独立SDK/路径绑定、真正cache readiness及可靠子进程fail-closed机制仍未完成。没有以改Flutter源码、全局代理/防火墙/hosts、删cache检查或手造stamp来绕过门禁。

### ICE诊断合同

继承已验DAG实际 **targetPath=lib/main.dart、dartDefines=null**。外层三flags的argv存在不证明嵌套FlutterTask已消费test-only defines，本轮保持 **ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN**；不改跟踪build脚本或注入新业务开关。即使后续有标准Debug JNI Jar，也只可能在来源/ABI/结构另验通过后用于classpath实体可用性核验，不等于ICE诊断入口/defines或真机媒体功能通过。此处没有新Jar或正式解析结果，不能预先放行。

## D2与D3：实际预算均未使用

| 分层 | 本轮结果 |
|---|---|
| 本地包来源与逐文件验证 | PASS，34文件162666B |
| 本轮独立Stage | 仅34包文件＋5真实metadata；非完整SDK |
| CLI离线安全闭包 | NOT_PROVEN，guard未建立验证 |
| 原已通过DAG重跑 | 0 |
| 真producer | 0/1，NOT_RUN |
| 新libs.jar来源/Hash/CRC/内容/ABI | NOT_RUN，没有本轮产物 |
| 真resolvePinnedDebugInputs | 0/1；Configuration.resolve调用0 |
| BEGIN / OK / NOT_RUN | 0 / 0 / 30 |
| 额外AAR、宿主APK、设备/ADB、RTC/SFU、DB/API | NOT_RUN |

完整30配置NOT_RUN表见Manifest，无本轮首失败配置。沿用严格init **2e97394f0dffd7818058e587cda8eaf0ec5ff747198d6a60e9872b14b96e1a6f** / policy **bfb7633a037f84e7e7c41060563841add01648387ecafbd34a7e7d8e142e5c58**，不重新设计解析语义。Gradle8.14 bin **af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab**、Flutter3.41.7/Dart3.11.5、固定engine、JDK17.0.18.8/AGP8.11.1/Kotlin2.2.20保持，无工具启动探针/升级。

## D4：具名保护、非作者复核与唯一交付

本轮当前关键原件选取 **864份**（源包/版本、固定工具、旧完整失败与私密env、SQL/APK/part/备份、前轮任务原证等）实际Hash；源包和已读版本metadata另有复制前记录，2份额外metadata在copy前后核字节。选择性保护基线在授权包复制之后形成，没有把它冒充整个操作之前的全套审计；复制动作仅向新任务根写文件。继承87357旧影响范围的保护上下文，不重复全历史或整SDK审计。

终检对同一864份全部重Hash，漂移0、丢失0；39份新Stage文件 **163391B** 与源清单逐项一致。源包原件、原SDK具名Git HEAD/branch/index、两个旧Stage保持；506旧refs、五历史根dirty/index/HEAD及旧153 warning保持。范围外为历史保护回执继承和无写授权，不声称本轮全盘逐byte回验。没有新Gradle daemon或运行cache写入；Process/User/Machine相关24组环境摘要保持、归属工具进程0、global kill0。

同一次非作者有界复核核来源/CRLF及case映射、独立组件Stage、未通过的CLI安全门、诊断合同、保护和公开逻辑，支持阻断交付，**不支持运行门PASS**；没有运行脚本/Gradle/Flutter、没有改文件、没有替代Astra终验。原机器路径、SDK package真实文件、完整env/日志/SQL/APK保持LOCAL_ONLY；公开只给脱敏类别、相对路径、Git身份/Hash及计数，不上传包或二进制。

以 **df2bf34302fd65d0f69c0ea34a269eba03dc6a67** 为sole Parent新分支 **codex/v10.1.5-flutter-offline-gpu-cache-closure-conditional-producer**，仅新增本报告和flutter_offline_gpu_cache_closure_and_conditional_producer_manifest.json。作者/提交者 **zcx369658780 <zcxvegeta@126.com>**。普通non-force发布后完整回读Commit/Parent/Root、两docs Blob/原字节与完整产品双Tree；最终固定身份放发布后回执和Owner交付，避免自引用。ACTIVE_STATE、旧文档、产品源码/构建脚本及main不改。

**OFFLINE_FLUTTER_CLI_CLOSURE_NOT_PROVEN / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN / NO_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW**。

本轮停止，等待Astra独立验收及Owner决定；不自动建立新系统/网络权限、不重绑或改旧Stage、不启动producer/解析、APK/RTC或后继任务。
