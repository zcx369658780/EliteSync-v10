# APP-M5-07｜synthetic bootstrap端点策略与MainActivity接线

ISSUED；LEVEL 2（环境/端点边界），Codex `01a0ef77-af94-75e2-8726-87c04e082018` Sol/medium，交付后停Work独立审查。

唯一仓库D:\EliteSync-v10，main HEAD cf8bfaa4a03b8c9a682105617b185141904413be。先读根五文件/local-workflow、APP-M5-05 plan/review、M5-06 review。保留全部既有修改。仅允许改：
- apps/android/app/build.gradle.kts，输入SHA256 4D3A83B8940BBE5F14223350FC444C3F2A854E52A2416E525CD2D25ECD686ED3。
- apps/android/app/src/main/java/com/elitesync/MainActivity.kt，输入SHA256 4432C60E723FF2C0E5955A50A94E9A8A050DA5472BEB9CDF714E68AE24440FF9。
仅允许新增：apps/android/app/src/main/java/com/elitesync/BootstrapEndpointPolicy.kt、apps/android/app/src/test/java/com/elitesync/BootstrapEndpointPolicyJvmTest.kt、本目录summary.md及out/policy-tests.jar。其余源码/Gradle/properties/settings/Flutter/依赖不改。两新增源码不存在才开始；哈希或路径冲突则停。

固定实现：纯Kotlin、无Android/Flutter依赖的BootstrapEndpointPolicy，拥有明确synthetic/debug输入和API/WS Intent、文件输入；synthetic=true时require debug=true，固定返回 http://127.0.0.1:8080/ 与 ws://127.0.0.1:8080/ ，忽略任何外部API/WS（不解析、连接或信任它们）。synthetic且非debug须失败，不回退prod。普通模式保留原firstNonBlank的Intent trim优先、再文件trim、全缺省空串语义。不给synthetic发明真实服务或网络权限。

MainActivity的getBootstrap须在读取bootstrap文件之前判断synthetic，synthetic不读取文件API/WS，并调用实际policy；普通路径仍按原Intent/file顺序。其它initialRoute/version/debug字段、clearBootstrap和普通行为保留。ensureBootstrapDefaults在synthetic下强制覆写Intent API/WS为同一固定值（含onNewIntent）；普通缺省逻辑保持。新policy不能只在测试里被用。

app/build.gradle.kts仅在defaultConfig声明默认false的boolean BuildConfig.ELITESYNC_SYNTHETIC_DEMO；本任务**没有启用属性或传true到Dart的授权**，不改syncFlutterAar/依赖/变体/端点常量/签名。真实启用仍须后继标记、debug门、AAR身份和应用数据隔离一起审查。本候选只建立准备好的运行时端点策略；不得声称当前synthetic APK或完整host安全。

JVM测试为standalone main，无JUnit或下载依赖，直接调用prod policy。至少覆盖synthetic的恶意非loopback Intent/文件值、空值/拼错值、首次/新参数等价、非debugsynthetic失败以及普通优先/trim/文件fallback/空值行为；每类不同意义的case报告计数。验证MainActivity实际接线及分支顺序静态审查；不要将纯policy测试当Android生命周期或整host编译证明。

固定现成工具（只读这些路径，不运行Gradle/wrapper）：Java=C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot\bin\java.exe；Compiler lib=C:\Users\zcxve\.gradle\wrapper\dists\gradle-8.14-all\5vwl8burbouivoo2kromnbp2p\gradle-8.14\lib。先确认java.exe、kotlin-compiler-embeddable-2.0.21.jar、kotlin-stdlib-2.0.21.jar存在并固定哈希；不找其它工具链、不读配置/凭据。编译仅一次：Java用lib/* classpath执行org.jetbrains.kotlin.cli.jvm.K2JVMCompiler，-no-stdlib -no-reflect -classpath该stdlib jar -jvm-target 17，将policy与测试这两份源码编译到本目录out/policy-tests.jar。编译通过才Java以该jar+stdlib运行测试main一次。各硬时限120秒、stdout/stderr各64KiB限额；启动/编译/测试失败或超时立即停，不重跑、不扩大编译路径。不执行Gradle配置、Android编译或设备。不引入测试依赖，不写超出这些路径的工件。

summary记录输入/输出哈希、最小diff、默认false与未闭合AAR门、编译/test命令退出/计数/时间/截断、静态接线和空白检查（git diff --check目标两文件一次；新增文件检查空白一次）、预算与未证项。编辑+编译/测试预算均有界；作者不自接受/下发后继/改authority。无properties、真实数据/备份/密钥/SSH/网络/UAC、旧D:\EliteSync或Git提交/pull/push。M5运行保持NOT_READY，G08/G11/真实Conversation/恢复回填门不变，所有旧预算不重置。

