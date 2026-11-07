# v10.1.5 默认依赖缺口越过，case04插件类型类路径STOP及修正候选｜2026-11-07

**CASE04_STOP_SPENT_1_REMAINING_0 / CANONICAL_JAR_ERROR_NOT_RECURRED / PLUGIN_TYPE_CLASSPATH_FIX_STATIC / NO_APK / G2_FALSE**

Owner明确答复“批准完整默认 JAR 候选运行一次”。本次只运行新范围`v1015-source-debug-host-20261107-case04`一次，源码HEAD `537afb088ec6f252a4155c20fea59edd8444fda4`、apps树`628795cf5fca95b4fb602695a295c0e987839eb4`；不把新授权恢复到旧case01–03。

## 实际结果

复用稳定目录、SDK复制0次；完整输入67506文件/7029564398字节，旧Kotlin仓库54项替换为新57项，外部共49710项且路径唯一。准备236.266秒。仅由现有launch做一次完整fresh核验，没有提前重复preflight或资源轮询；fresh可用13615MiB，工作卷空闲331976482816字节。

完整launch约186.419秒；SDK54.495秒，Gradle53秒，Flutter插件4项任务均up-to-date。root1/controller32、Job记账峰1212264448字节（约1.130GiB）；控制PID41488事后观察不存在。该峰只代表失败配置阶段，不是完整源码构建内存结论。

此前默认JAR错误未再出现，配置已到原生`flutter_plugin_android_lifecycle-2.0.35`；其`android/build.gradle.kts:28`的`flutter.compileSdkVersion`报Unresolved reference。生成访问器直接注明`com.flutter.gradle.FlutterExtension is not available`，将`flutter`类型降为`Any`。这支持插件脚本类型类路径问题，不是APP编译通过，也不能据此宣称全部离线依赖闭合。

**case04已耗1、余0，STOP保留，无重试。** case01–03封存文件hash复核一致；原AAR/host各1/0不改。未进Dart/APP编译、无新APK；安装/运行/attach/热重载NOT_RUN。

## 已完成修正与限制

仅显式source-debug路径选择新`build-source-debug.gradle.kts`。该根脚本保持AGP8.11.1/KGP2.2.20，并以`apply false`声明Flutter插件，使其类型可由共同父classloader提供给原生插件。默认根脚本、settings入口、AAR/project互斥、业务defines、bootstrap与插件原件保持。

根脚本选择断言在旧源码RED，修正后8个Groovy配置场景PASS；现有私有AAR renderer 10项Python通过。非作者Codex复核未发现可行动P1/P2，非外部独立验收。fixture只证明配置选择，**实际Gradle类加载/访问器重新生成及修正后完整构建NOT_RETESTED**。

产品修正及私有`next-candidate`两文件已保存，稳定开发目录尚未应用该修正；没有case05、后继合同或新claim。未来若另获一次明确额度，须将这两文件纳入稳定副本及新清单，复用完整Kotlin库和门户保留init；旧合同/nonce/claim/STOP不回写。保持Job4GiB、启动5120MiB、串行、64进程/SDK1800秒/host2100秒/收尾45秒/工作8GiB/输出2GiB采样、离线、不升级或新许可、不改系统网络、不重试。

LOCAL_ONLY原证根名`v1015-source-debug-runtime-20261107-canonical-complete-candidate`，先读`verified-case04-stop-proof-private.json`、`case04-stopped-scope-seal-private.json`及最终本地/Git回执。保存了实际生成访问器与相关插件脚本副本；原SDK/Pub插件源码不改，私有原证与二进制不上GitHub。旧17402项保护ledger承接并仅追加本节点新原证，不重扫旧SDK/AVD/全部Sources。

仍**10 PARTIAL、AC05 OPEN、G2 false、真实Push PENDING**。无设备、后端/DB、VM、云、媒体或真实Push运行；旧VM teardown UNKNOWN。不合main、不发布、不启v10.1.6；原dirty根/SDK/DB/备份/STOP与无关`%SystemDrive%/`保留。
