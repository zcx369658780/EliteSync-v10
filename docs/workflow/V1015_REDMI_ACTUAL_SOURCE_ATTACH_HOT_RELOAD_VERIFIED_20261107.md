# v10.1.5 Redmi真机源码attach与修改/还原热重载已实际验证｜2026-11-07

**ACTUAL_PHONE_SOURCE_ATTACH_EDIT_RELOAD_RESTORE_VERIFIED / SOURCE_AND_RUNTIME_RESTORED / G2_FALSE**

Owner明确授权“对手机上的EliteSync v10 app进行操作从而调试”，绑定此前已资格化并安装已验源码Debug APK的个人Redmi K80 Ultra。此同机同APP普通调试授权继续保留；不据此扩大真实账号/数据、其他APP/文件、手机安全设置、外部服务/费用/发布权限。旧APK/AAR、后端和其他一次合同/claim/STOP不退款、不复用。

## 本次实际结果

独立范围`v1015-redmi-source-debug-hot-reload-20261107-case01`，一次Activity启动、一次源码attach、两次计划内热重载。手机目标包`com.elitesync.v1015dev`的base.apk SHA256再次核对为**974ef00c5803c87acee457d6010648f4b1fb0868fecc966e61e3ad363017a4dc**；没有APK/AAR重编或重装。构建源码c5e2dc34、apps树b673913保持。

先从目标APP进程日志发现带认证的VM服务地址，再仅建立一条精确USB调试forward；没有API/WS reverse、没有启动后端。使用当前Flutter工具源码派生的私有离线attach入口，传入V1015/V1014两个true define、指定设备和包名；上下文Cache.updateAll禁止更新，attach禁pub/缓存刷新/无线发现/平台再生成，版本检查和DevTools/DDS关闭。SDK源码与snapshot未作手工修改，不升级/接受新许可或改系统网络。

取得登录页面自身Widget树后，只在稳定开发副本将标题临时改为带“源码热重载验证”的标记。第一次`app.restart(fullRestart=false)`返回code0/“Reloaded 1 of 2980 libraries”，运行中Widget树确认出现标记；恢复原始源文件字节后，第二次同样返回code0，Widget树确认标记消失并恢复原标题。三份快照main isolate相同，前后APP PID相同；不是重启、静态源码回读或仅发送重载命令。

手机上的源码Debug/热重载工程路线因此实际接通。证据覆盖APP启动、attach、真实源码修改与还原进入运行树；没有截图/完整视觉验收，也没有登录、产品API/数据库、媒体/通知/真实Push或完整G2结果。

## 资源、检查与收尾

一次fresh启动资源观测：可用14191MiB、工作卷空闲351386345472字节，均为本次历史值，不能用于下次启动。宿主55.017秒、root/controller0；Job峰2260230144字节，约2.105GiB，硬限4GiB/64进程，600秒宿主/720秒整体/45秒收尾/2GiB采样边界。不是整机物理内存上限或未来所有输入保证。

机器协议detach返回true；宿主退出、Job收尾，精确匹配设备/宿主端口/设备端口后移除本会话forward（exit0），未改其他映射、手机设置或权限。源文件hash恢复**fd65da5925fe51427bded51d1ed0c8fbf09f5e7bb3d1df8b5863b9746315d003**，运行态恢复另经Widget树确认，全部冻结输入pins回读一致；产品工作区没有临时marker。观察器ADB命令12条，不包含Flutter工具内部ADB命令，不把12写成总设备命令数。

前置检查分别记录：无SDK/设备协议fixture PASS；运行清理/端口/URL纯测试8项PASS；私有离线帮助入口前两次因遗漏本版必需构造参数编译失败，原文保存，按当前SDK完整构造参数修正后第三次help exit0。它们不是手机成功或新APK构建。实际手机attach只执行1次，没有自动重试。非作者Codex发现的两项P2（非本会话forward误删风险、收尾累计超45秒）已修正，静态及实际原证复核无新可行动P1/P2；不称外部独立验收。

## 接续边界与原证

稳定源码根继续使用`v1015-source-debug-workspace`，不重新物化SDK或恢复旧构建额度。私有入口/控制程序与驱动保存在本节点根，后续同类源码调试可据此派生独立记录，不覆盖本次已完成原证；本工程能力不新增产品验收门。

LOCAL_ONLY原证根名`v1015-redmi-source-debug-hot-reload-20261107-case01`。先读`verified-phone-hot-reload-private.json`、`runtime-cleanup-private.json`、`non-author-runtime-review-private.json`及最终本地/Git回执。机器协议、带认证VM地址、设备标识、Widget树、SDK派生入口和二进制均不上传GitHub。保护ledger承接17571旧项，仅追加本节点原证，不重扫旧SDK/AVD/Sources。原dirty根/SDK/Pub/DB/备份/旧STOP与无关`%SystemDrive%/`保持。

下一软件收口仍为消息权限完整矩阵/并发、媒体、15/30天加密离线及清理、通知/Push生命周期、合格RTC/AEC及撤权≤5秒、同一最终候选贯通APP/API/MariaDB/Web/重启读回。手机调试操作授权不自动扩大独立后端/外部服务合同。

仍**10 PARTIAL、AC05 OPEN、G2 false、真实Push PENDING**。本次没有真实账号操作、其他APP/个人文件读取、后端/DB、VM/云、媒体或真实Push运行；旧VM teardown UNKNOWN。不合main、不发布、不启v10.1.6。
