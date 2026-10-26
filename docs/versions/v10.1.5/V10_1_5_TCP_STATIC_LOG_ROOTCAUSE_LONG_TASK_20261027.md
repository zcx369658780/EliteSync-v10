# EliteSync v10.1.5｜TCP构建停止：源码与既有LOCAL_ONLY日志联合只读根因诊断

状态：OWNER_APPROVED_READ_ONLY_DIAGNOSIS / READY_FOR_MANUAL_CODEX_DISPATCH / ZERO_REAL_BUILD_BUDGET / NO_SOURCE_FIX / NO_DEVICE_RUN / GATE2_NOT_AUTHORIZED

日期：2026-10-27（Asia/Singapore）
Owner：方向与不可逆决策最终authority
执行者：Codex（Owner手动派发后）
独立Reviewer：Astra

## 0. 目标与授权

Owner已同意先检查程序和历史日志，不再陷入“调整监控—试构建—再次失败”的循环。本任务**只有静态源代码审查、已保留原证的只读提取、时间线重建与有界根因判断**。既有真实构建预算 **1/1已消耗，剩余0**；本任务不是新构建授权、不是版本开发、不改产品main、不启动v10.1.6。

期望回答：
1. 92.375秒构建窗口末尾，非loopback TCP state5连接是否确实由本任务Gradle进程树中的同一进程实例拥有？
2. 若归属成立，历史日志能够把它定位到哪个Gradle/Flutter AAR阶段，是否能指向具体任务/插件？
3. 是已有观察器的PID复用/归属缺陷、明确的构建组件网络行为，还是证据不足？提出最小后续方案，**不实施、不重跑**。

## 1. 先恢复最新权威状态

仓库：`zcx369658780/EliteSync-v10`

开工重新只读获取：live main/Root、`docs/workflow/ACTIVE_STATE.md`、冻结 `docs/versions/v10.1.5/plan.md`、本任务单、最近候选 `cfddecc944a043b1d85361a954a692be0dd4ce23`、最新 `IMPLEMENTATION_REPORT.md`、`artifact_manifest.json`，以及既有Astra UDP分类独立验收。

开工时的参考身份（**须实时回读，不视为不可变HEAD**）：
- main `4df2e7f0f36cc7b80258faa73e80dad682cff6c5` / Root `03b0ecfcc360e38a462539dd50690c64b663a21e`。
- 交付候选 `cfddecc944a043b1d85361a954a692be0dd4ce23`；Parent `12d4e284feea609935eab12c973f5fd2efbc2992`；Root `a0bdf4a3cec27a21293abad9a35f11981b0d5c48`。
- 真正的执行源码 `12d4e284feea609935eab12c973f5fd2efbc2992`，Parent `7674b5e60a219cb76aba387dd2cee85cae67bd0a`。
- 报告Blob `71e039051ba0c6205f496444bc466d71f11a6fff`；Manifest Blob `d91a50d3653ef6304b4f45e53ddb4a242dbce284`；冻结plan Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`。
- 源码 apps Tree `cea01309fa9da5f99ccc9829654c6ec279c8c343` / services Tree `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`；已接受产品v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。

任务已执行且交付，**不要重复派发原单次构建任务单或重置claim/ledger**。先校验受保护历史根、既有日志索引和原文件SHA256，不改任何历史证据。

## 2. 已知事实和初步静态发现（待本地原证独立核实）

根据Github报告与Manifest，唯一真实构建于Gradle进程启动后92.375秒触发 `NON_LOOPBACK_TCP_ENDPOINT_OBSERVED`，进入口exit90、Gradle子进程exit1；734个采样，记录UDP行4478条（**采样行，不是报文数**），最终强停止为某Java PID拥有的IPv4 TCP state5 endpoint；不上传具体远端IP。既有摘要显示 `downloadLogObserved=false`，这仅表示未匹配下载日志规则，不证明没有外联/下载。Kotlin DSL与嵌套Flutter AAR阶段已开始，但**尚无证据将TCP事件排他绑定到具体插件**。没有新APK。

Astra当前直接GitHub静态审查发现：
- `apps/android/scripts/windows_build_observer.py` 的 `Observer.known` 会累积子进程PID；后续采样凭PID匹配socket，未看到进程创建时间/实例身份检验或旧PID淘汰。存在理论PID复用误归属风险，**不能仅凭此宣称本次确有PID复用**。
- `GetExtendedTcpTable` 的TCP行原结构含本地/远端地址端口、状态和owner PID，但当前脚本日志仅保留pid、remote、state等派生字段；**历史未采集字段不能在事后恢复**。
- Microsoft TCP state5（`MIB_TCP_STATE_ESTAB`）表示已建立连接，并不自动证明下载或具体应用payload。Gradle `--offline`约束依赖解析，不能推断一切构建插件绝对不联网；本机daemon通信还可能使用本地socket。

上述只是静态发现与解释，不能取代本地原始进程/构建日志的核验。

## 3. 本地既有原证：只读、保持私密

使用最近交付已有的LOCAL_ONLY根标签 `v1015-single-offline-build-20261026`，以该候选Manifest的 `localEvidenceIndex` 和 `final-readback.json` 定位实际文件；**不得猜测绝对路径、重新生成文件、重跑任务或覆盖旧Hash**。

只读取既存文件的原始字节并校验Manifest SHA256：
- `ordinary-debug-run/process-network-private.jsonl`（如实际索引标签不同，以原索引为准）：采样单调时间、pid/parent/image/imagePath、TCP/UDP分类及stopReason。
- 对应 `ordinary-debug-run/stdout.txt`、`stderr.txt`、`result.json`、`process.json`、`invocation.json` 和已有独立停机/PID终末回执。
- 构建前后身份、预检/缓存/清单及相应只读工具transcript。
- 必要的**旧**UDP停止原证作为对照，仅按各自候选/Hash标记，不拼接为本次运行。

这些原始日志可能包含用户名、完整路径、网络地址、设备标识、凭据等，禁止原文上传公开GitHub或ChatGPT Project；本地诊断可依据日志，远端仅发布脱敏聚合事实、路径标签及SHA256。没有既存日志就报告 `RAW_EVIDENCE_NOT_ACCESSIBLE`，不得重现/补造。

## 4. 必做的只读分析

### A. 时间线

从已有JSONL按采样单调时间重建：root Popen/首次样本、嵌套AAR启动迹象、最后一次正常样本、TCP state5样本、保护stop及进程退出。结合既有stdout/stderr能提供的任务阶段信息，计算有共同时间基准的时序；若日志没有逐行统一时间戳，不得猜测准确的任务—socket毫秒对应关系。记录采样间隔/窗口缺口及观察器漏采边界。

### B. TCP连接进程身份

在TCP触发样本直接查：socket owner PID、同一采样内process列表是否有相同PID、imagePath、parent链是否真正连到本次root、是否能证明目标进程在触发时存活。跨先后样本核对PID的父进程/路径变化、退出现象和重用迹象。

仅依赖PID且无创建时间时，应把“同一进程实例”定为 `INSTANCE_IDENTITY_NOT_PROVEN`；不能因为进程名叫java.exe就声称归属已证明。若已有记录具备创建时间可比对，才提升证据等级。**不要通过新的系统进程查询冒充历史时点证明。**

精确远端地址、端口和私人路径保持LOCAL_ONLY。对外只允许脱敏类别（loopback / RFC1918 / public-or-other / unknown）、TCP state5、PID是否成功关联及证据Hash。注意本次observer可能根本没有保留remotePort；未采集时标 `REMOTE_PORT_NOT_CAPTURED`。

### C. Gradle和网络机制归因

只读核对 `offline_debug.py`、`windows_build_observer.py`、`apps/android/app/build.gradle.kts`、`offline_debug.init.gradle`、已存在的Gradle日志，分析：
- 外层 `:app:assembleDebug`、嵌套Flutter AAR、Gradle daemon/client和任务java进程之间的身份关系；
- 是否存在显式下载/访问URL的日志、插件调用或出站阶段，是否只是默认Gradle本地daemon/loopback IPC；
- 已记录的`--offline`、Wrapper绕过、Dokka/Javadoc路径与网络行为间的实际证据关系。

不得把“任务执行阶段接近TCP事件”当作“该插件发起连接”。不能仅凭下载日志未匹配就判断绝对无网络。

### D. 逐项排除与结论等级

输出至少四类独立结论：`PID_REUSE_MISATTRIBUTION`、`GRADLE_PLUGIN_OR_TOOL_NETWORK_BEHAVIOR`、`OTHER_OBSERVED_CONNECTION`、`ROOT_CAUSE_NOT_PROVEN`。每项标注 SUPPORTED / CONTRADICTED / POSSIBLE / UNVERIFIED，并列原证的局部标签、采样序号/时间和Hash。

不允许“很可能正常”替代证据。若目标PID与来源关系、远端端口或事件阶段缺失，明确写 `ROOT_CAUSE_NOT_PROVEN`，然后提出最小下一次**可选**观测增强方案，但**不实施、也不授权再启动一次真实构建**。

## 5. 绝对禁止与预算

本任务零构建、零设备、零服务、零新真实网络观察预算：
- 不执行Gradle、Gradle Wrapper、Flutter/AAR/Kotlin编译、Python构建入口、任何APK生成或安装。
- 不运行当前Windows网络观察器进行新现场取样；不启用抓包/ETW/Procmon、系统策略/防火墙修改、管理员提权、VPN改动或工具下载。
- 不运行Android手机、RTC、ADB服务、Docker/DB/API或Gate 2；不调用Writer/Serializer、不使用Bypass、不改执行策略。
- 不修复/修改产品源码、构建入口、监控器或测试；只读旧源码与证据，必要时在**全新任务拥有**的诊断目录写入脱敏报告，不覆盖原始文件。
- 不修改、清理、重命名、reset或stash旧树/refs、原SQL/APK、7,941,328字节Gradle下载partial、保护根或LOCAL_ONLY原证。
- 不创建生产服务、Push/真实用户集成或付费依赖；不合并产品main、不启动v10.1.6。
- 任务未获得新的构建授权。原 `1/1` 预算已耗尽且不可复活。

## 6. 集中交付与Astra验收

交付仅限**一份有界只读根因诊断结果文档**，可在 `docs/versions/v10.1.5/TCP_OFFLINE_BUILD_READONLY_ROOTCAUSE_REPORT_20261027.md` 新建，另保留必要的最小脱敏索引。不要改写已有`IMPLEMENTATION_REPORT.md`/Manifest原证；如需状态同步，优先更新独立文档分支上的 `ACTIVE_STATE.md` 并保留前版，不能对main做产品集成。

报告必须包括：实时身份、LOCAL_ONLY原件Hash匹配、事件时间线、进程父子链/实例身份证据、TCP状态与来源分类、Gradle阶段有界映射、假设比较、可见信息缺口、最小修复/增强选项与Owner新授权依赖、保护对象/预算状态。每个结论明确分离 `ASTRA_DIRECT_GITHUB`、`CODEX_REPORTED_LOCAL_READ_ONLY`、`LOCAL_ONLY_RAW` 和外部技术文档。

若实际本地日志无法访问，报告静态判断与缺口即可，绝不虚构已核查原始日志。非作者复核是只读，不得声称其运行过构建或设备。

Codex在已授权只读范围内完成全部核验后，一次性普通non-force发布文档候选并完成远端Commit/Parent/Root/Blob/原字节回读，停止等待Astra。不得自行创造后继任务/构建预算。

最终保持：
`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ACTUAL_BUILD_NOT_COMPLETED / SINGLE_REAL_BUILD_BUDGET_EXHAUSTED_1_OF_1 / GATE2_NOT_AUTHORIZED`。
