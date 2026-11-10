# v10.1.5 真正源码Debug APK已产出并核验｜2026-11-07

**ACTUAL_SOURCE_DEBUG_APK_VERIFIED / CASE05_COMPLETED_SPENT_1_REMAINING_0 / DEVICE_ATTACH_HOT_RELOAD_NOT_RUN / G2_FALSE**

Owner明确答复“批准插件类型修正候选运行一次”。新范围`v1015-source-debug-host-20261107-case05`仅执行一次，构建源码`c5e2dc34694aad6d0fb5b9f3c85abf0500dd5c03`，apps树`b673913a4ff0ff1a8bfc83ca98951ff1556a2f23`。

## 真实构建结果

两份已审阅源码候选按hash核对，保存稳定副本旧原文后应用；SDK复制0次。输入74111文件/7643328091字节，外部49710项直接承接且唯一。准备233.500秒，唯一launch完整fresh调用666.219秒（含SDK与核验/收集）；没有提前重复preflight或轮询资源自动启动。fresh可用14254MiB、工作卷空闲355748028416字节；这些是本次历史观测，不能用于未来启动。

SDK215.276秒，Gradle3m34s，345任务（340执行/5 up-to-date），root/controller均0。Job记账峰3933507584字节，约3.663GiB，低于4GiB限制；不是整机物理内存占用，也不是未来所有输入保证。控制PID81404事后观察不存在。

`:flutter:compileFlutterBuildDebug`实际执行，原生lifecycle等插件完成Kotlin/Java编译，实际越过case04的FlutterExtension类型不可见问题。独立源码根脚本的插件父classpath修正在本次固定输入下获得真实构建支持；默认AAR→APK路线继续保留。准备与完整launch时间分列，未做本机分阶段profiling，不将推测当瓶颈实测，也未降低冻结输入核验。

## 已验交付

LOCAL_ONLY文件`v1015-source-debug-runtime-20261107-plugin-types-candidate/delivery/EliteSync-10.1.5-source-arm64-debug.apk`，123292162字节。

- SHA256：`974ef00c5803c87acee457d6010648f4b1fb0868fecc966e61e3ad363017a4dc`
- 身份：`com.elitesync.v1015dev / 10.1.5-dev / 1010501 / arm64-v8a / debuggable / Android Debug签名`。
- 完整ZIP、版本、签名和ABI通过；JIT `kernel_blob.bin`存在（91344144字节），AOT `libapp.so`及Vulkan验证层缺失。
- APK的`libflutter.so`与已验官方当前引擎Debug JAR的program headers及所有PT_LOAD代码字节一致；不要求剥离前后整个ELF文件hash相同。

这证明真正源码Debug产包，不再是Debug宿主消费Release AAR。**安装、运行、attach、热重载仍NOT_RUN；不等于设备调试已经接通或G2通过。** 非作者Codex窄复核支持构建与校验结论，无可行动P1/P2，非外部独立验收。前序8场景/10项静态检查保留为前一节点证据，本轮没有重跑。

## 范围与下一步

case05已完成、已耗1余0，不重试、不恢复额度；case01–04 STOP封存hash复核一致，原AAR/host各1/0不改。Job4GiB、启动5120MiB、串行、64进程/SDK1800秒/host2100秒/收尾45秒/工作8GiB/输出2GiB采样、离线、不改系统网络、不升级/新许可保持。本轮没有下载新依赖。

下一步是绑定合格USB测试设备，另定安装/启动/attach与热重载具体范围；本次授权不包含设备动作，FD02继续排除。已经询问待选手机型号、用途及真实数据保留要求，没有执行ADB、设备安装/APP运行、后端/DB、云、VM、媒体或真实Push。旧VM teardown UNKNOWN。

私有入口先读`verified-case05-source-debug-build-proof-private.json`、`verified-source-debug-apk-private.json`、`case05-completed-scope-seal-private.json`及最终本地/Git回执；稳定开发目录仍为`v1015-source-debug-workspace`，交付副本另存冻结。旧17453项保护ledger承接，仅追加本次原证，不重扫旧SDK/AVD/全部Sources。原dirty根/SDK/Pub原件/DB/备份/全部STOP与无关`%SystemDrive%/`保护。

仍**10 PARTIAL、AC05 OPEN、G2 false、真实Push PENDING**。设备调试工程进展不是v10.1.5整版接受；消息权限矩阵/并发、媒体、离线15/30天与清理、通知/Push、合格RTC及同源集中验收仍须完成。不合main、不发布、不启v10.1.6；二进制、私有原证、许可和凭据不上GitHub。
