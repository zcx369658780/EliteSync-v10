# EliteSync v10.1.5｜TCP构建停止只读根因报告｜Astra独立验收

日期：2026-10-27（Asia/Singapore）

**READONLY_ROOTCAUSE_DIAGNOSIS_ACCEPTED_WITH_LIMITATIONS / ROOT_CAUSE_NOT_PROVEN / INSTANCE_IDENTITY_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ACTUAL_BUILD_NOT_COMPLETED**

## 1. 验收对象与证据等级

验收对象是文档候选 `7abea213feacc52a1e43c6ed58a40c83009c74df` 的单份脱敏报告 `docs/versions/v10.1.5/TCP_OFFLINE_BUILD_READONLY_ROOTCAUSE_REPORT_20261027.md`，Git Blob `72975510872fbe3251caf1b8ddbd687761165d88`。

Astra **直接读取 GitHub** 的候选Commit、唯一Parent、完整递归Root Tree、与Parent的差异、交付报告、原冻结计划、原实施报告/Manifest、Windows观察器和Gradle构建脚本。Astra没有亲自读取Windows LOCAL_ONLY原始JSONL、原Gradle stdout/stderr或本地daemon日志，也没有运行本地分析、Gradle、测试、设备或观察器。因此，以下两级结论必须分开：
- `ASTRA_DIRECT_GITHUB`：远端提交身份、源码静态风险、文档内容、版本冻结/门禁与产品双Tree不变。
- `CODEX_REPORTED_LOCAL_READ_ONLY / LOCAL_ONLY_RAW`：历史原证Hash校验、JSONL 462样本连续性、触发父链、daemon PID/路径与Dokka任务日志、旧资源和保护文件状态。Astra只核对它们与GitHub公开报告的一致性及陈述边界，未独立重算本地原件。

本裁决为**调查报告有界接受**，不是将LOCAL_ONLY的每一项数量/结论提升为Astra亲自观察，也不是构建成功或根因已经识别。

## 2. 实时远端身份

- 本轮live main为 `4df2e7f0f36cc7b80258faa73e80dad682cff6c5` / Root `03b0ecfcc360e38a462539dd50690c64b663a21e`。
- 候选 `7abea213feacc52a1e43c6ed58a40c83009c74df`，唯一Parent `cfddecc944a043b1d85361a954a692be0dd4ce23`，Root `8a7775c97f3161f2f6f54d6499deba584349f307`。
- 候选分支 `codex/v10.1.5-tcp-readonly-rootcause-20261027` 远端HEAD与该候选Commit一致。
- 候选相对Parent仅新增报告一个文件（160行，GitHub compare ahead 1/behind 0）；没有APP、构建脚本、Flutter vendor、后端或旧原证变更。
- 完整递归Root Tree 6622条，未截断。apps `cea01309fa9da5f99ccc9829654c6ec279c8c343`、services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`，同前一候选。
- 原冻结 `plan.md` Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`；原实施报告Blob `71e039051ba0c6205f496444bc466d71f11a6fff`、Manifest Blob `d91a50d3653ef6304b4f45e53ddb4a242dbce284`。
- 已接受产品基线仍是v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。产品main未集成。

## 3. 只读证据的有限判断

### 3.1 TCP及PID身份

报告从既有JSONL取得：TCP_OWNER在#273至#734连续462个采样中出现；触发采样#734的父链为 `TCP_OWNER(java) → P2(java) → P6(cmd) → P11(java) → P1(java) → ROOT(cmd)`。它记录当次样本中完整父链、imagePath与同JDK的可执行字节身份；不是历史known里没有出现在触发快照的“死PID”这一特定版本的误归属。

Astra静态复核 `windows_build_observer.py`：`self.known`集合只增不减，按PID比对socket，缺乏创建时间/实例代际校验；进程Toolhelp快照、imagePath句柄查询与TCP网络表查询并非原子采样。该设计确有理论PID复用与时间竞态风险，但**不能直接证明本次发生了PID复用**。

因此：
- `PID_LEVEL_BUILD_TREE_ASSOCIATION`：Codex历史原证报告有界支持。
- `SAME_PROCESS_INSTANCE`：`NOT_PROVEN`；连续相同PID、父链和imagePath不足以补齐创建时间。
- `PID_REUSE_THIS_RUN`：没有正面证据，不能认定发生。
- 触发时的TCP `state=5` 表示已建立TCP连接，但不证明下载、TLS、具体插件调用或已传输payload。

### 3.2 时间线及网络阶段

报告公开的首次样本#1、触发#734及采样间隔统计是Codex对LOCAL_ONLY JSONL的只读计算，非Astra独立复算。其谨慎区分“采样开始间隔”和“socket实际建立时刻”；没有共享时钟误差界，不把daemon墙钟日志精确减去JSONL单调时钟。

报告在原daemon日志中发现TCP_OWNER自报PID、内层Flutter `.android`构建目录与Dokka生成`connectivity_plus`文档的记录。**这些daemon日志仅本轮新Hash，非原交付既有pin**；证据级别低于旧Manifest已pin的JSONL。Astra没有直接读取本地daemon日志，不能由此确立某个插件启动了TCP连接。

静态源码证实普通R1 `preBuild → syncFlutterAar` 路径使用本地Gradle及 `assembleAarRelease --offline`。项目 `offline_debug.init.gradle` 移除javadoc发布artifact，但并不全面禁用Dokka文档任务。因此，报告称Dokka实际运行与源码机制并不矛盾；这不是本次TCP事件的唯一因果解释。

### 3.3 分类裁决

| 假设 | Astra裁决 |
|---|---|
| 触发样本是历史known中“缺席的死PID”被错误归属 | 报告证据与该特定解释矛盾；Astra未独立验证LOCAL_ONLY原件 |
| 本次PID实际复用 | `POSSIBLE / NOT_PROVEN` |
| 某Gradle插件或Dokka发起TCP | `POSSIBLE / COMPONENT_UNVERIFIED` |
| 非回环TCP state5 endpoint曾被观测 | 前轮Manifest与本轮报告一致；不能证明下载/payload |
| 存在已确认的单一软件缺陷 | `NOT_PROVEN` |
| 总根因 | **`ROOT_CAUSE_NOT_PROVEN`，接受保留** |

本轮没有任何证据允许改成“Dokka导致联网”“Java必然下载依赖”“PID复用已证实”或“可以忽略该TCP连接”。

## 4. 预算、资产保护与技术门禁

上轮单次真实构建预算已耗 `1/1`，本轮没有新的授权或真实构建。Codex报告本轮Gradle/Wrapper/Flutter/AAR/测试/设备/实时观察器/Gate2/Writer/Serializer启动均为0；这属于Codex的执行声明，不是Astra进程级现场监控。

原构建仍 `ACTUAL_BUILD_NOT_COMPLETED`：入口exit90、Gradle exit1，无新APK；首次Gradle下载partial 7,941,328字节和原Hash继续保留。历史证据、SQL/APK、旧refs及LOCAL_ONLY不清理。报告列出的26784具名保护文件、5个历史根和524受保护旧refs状态属于Codex报告的有界核查，不是整盘独立字节审计。

Gate2两次历史启动预算已消费；37案例suite、条件Sandbox SDK、Producer/libs.jar、30项Configuration.resolve仍NOT_RUN。v10.1.5仍 `PARTIAL_NOT_ACCEPTED / AC05_OPEN`；AEC、最后可闻波形、完整native handle、真实15/30天/物理30天清理和真实Push等仍未闭合。

## 5. 最终裁决与后续边界

**`READONLY_ROOTCAUSE_DIAGNOSIS_ACCEPTED_WITH_LIMITATIONS / ROOT_CAUSE_NOT_PROVEN / INSTANCE_IDENTITY_NOT_PROVEN`。**

接受本轮单份脱敏报告的远端交付、清楚披露的证据等级、合理的源码风险识别和不虚构根因的结论。不可将它解读为对本地全部Hash、样本统计或daemon日志的Astra原证复算。

后续若Owner选择推进，优先考虑两条独立方向：一是**只有另获授权**才增强观察器的进程创建时间/非原子采样观测；二是只读检查Flutter AAR的Dokka任务依赖和Javadoc发布artifact的剔除范围。它们都不能直接作为已经解决这次TCP连接的结论。

本次不新增/派发后继任务，不重跑构建，不修改源码、不集成main、不启动v10.1.6、不放宽网络强停止，也不运行Gate2。等待Owner明确下一步。

最终状态：`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ACTUAL_BUILD_NOT_COMPLETED / SINGLE_REAL_BUILD_BUDGET_EXHAUSTED_1_OF_1 / GATE2_NOT_AUTHORIZED`。
