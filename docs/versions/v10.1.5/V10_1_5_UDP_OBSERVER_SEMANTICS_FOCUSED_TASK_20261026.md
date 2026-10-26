# EliteSync v10.1.5｜UDP观察器证据语义与回归测试｜窄范围任务单

状态：OWNER_APPROVED_FOCUSED_TASK / READY_FOR_MANUAL_CODEX_DISPATCH / TESTS_AND_STATIC_REVIEW_ONLY / NO_REAL_BUILD_RERUN / NO_GATE2_AUTHORIZATION

日期：2026-10-26（Asia/Singapore）
Owner：最终产品方向与不可逆决策 authority
执行者：Codex，仅在 Owner 手动派发后执行
独立验收：Astra

## 0. 任务目标

本任务只修正构建观察器对UDP endpoint的证据分类，并增加相应回归测试。不得重新执行完整离线构建、不得生成或安装APK，也不得把本任务扩大成Gradle构建修复或RTC修复。

当前候选：`825344124313c4d88690983809a6fb95a05551f4`
当前源码：`02fac2b20da52e56b373f6ae8ae2da838fd51901`
当前源码Parent：`d45cd08f939f6dfc6b4efe2420f4a117efc99e68`
冻结计划Blob：`7d3466b3be67135dc641cfee7c7faef78937ba03`

前次唯一真实构建因为观察到任务进程的UDP endpoint而停止，入口exit90、Gradle子进程exit1、没有新APK，且未到达嵌套AAR阶段。原始观察、退出码、日志Hash和原R1下载partial必须保留。此前任务明确要求保护触发后不重试；本窄任务不授予新的真实构建授权。

## 1. 开工前恢复状态

重新读取：
- `docs/workflow/ACTIVE_STATE.md`
- `docs/versions/v10.1.5/plan.md`
- 最新 `IMPLEMENTATION_REPORT.md` 与 `artifact_manifest.json`
- 本任务单
- 候选 `825344124313c4d88690983809a6fb95a05551f4` 的源码、差异与Astra复核记录 `BUILD_APP_CLEANUP_ASTRA_REVIEW_20261026.md`。

重新核验live main、Root、候选Commit/Parent/Root、源码Tree、报告/Manifest Blob和任务分支。不得把历史SHA视为实时HEAD，不得reset、覆盖、强推或改动产品main。

产品接受基线仍为v10.1.4：apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`，services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`。冻结计划不变。

## 2. 根因与必须修正的证据语义

当前 `apps/android/scripts/windows_build_observer.py` 使用Windows `GetExtendedUdpTable` 读取由进程PID拥有的UDP endpoint。该API数据结构只提供本地地址/端口和PID，不包含远端目的地址，也不证明该endpoint在采样时发送过数据报。

当前 `apps/android/scripts/offline_debug.py` 将任何观察到的任务UDP endpoint都归类为 `NETWORK_ATTEMPT_OBSERVED` 并停止。停止行为可以继续作为保守的fail-closed策略，但分类名称超出了底层观测能够支持的事实。

要求将“endpoint存在”“观察到有足够证据支持的出站尝试”“发现下载日志”和“观察器失效”分成不同状态。建议采用以下明确语义（可使用更合适的等价名称，但不得降低事实精度）：

- `UDP_ENDPOINT_OBSERVED_REMOTE_UNAVAILABLE`：采样到由任务PID拥有的UDP endpoint；目的地址/端口未知，未证明实际发包。
- `NON_LOOPBACK_TCP_ENDPOINT_OBSERVED`：采样到非loopback TCP远端endpoint；该状态只描述采样到的socket/连接状态，不自动宣称数据已发出。
- `DOWNLOAD_ATTEMPT_OBSERVED`：日志明确包含匹配当前识别规则的下载尝试。
- `OBSERVER_FAILED`：进程/网络表无法可靠读取、任务根PID消失或观察器异常，无法继续证明保护条件。
- `None`或明确的安全状态：没有发现以上可观测信号；不得把“未观察到”描述成“绝对无网络”。

本任务中，UDP endpoint仍然必须触发保守停止，不得因为改名就允许构建继续。TCP endpoint的处理也必须保守且语义准确；不得把仅有socket行的证据泛化成已证实的数据传输。只有具备独立、可审计的实际出站流量证据时，才可使用“outbound attempt observed”一类标签。本任务不要求引入新的ETW、抓包驱动、管理员权限、系统防火墙、全局策略或网络工具。

## 3. 实现与测试范围

仅允许修改下列项目自有路径，且仅限完成本任务所需的最小差异：
- `apps/android/scripts/offline_debug.py`
- `apps/android/scripts/windows_build_observer.py`（仅当有必要调整返回字段/文档）
- `apps/android/scripts/test_offline_debug.py`
- `apps/android/scripts/README.md`（如状态名称需要同步）

不得修改 `apps/android/app/build.gradle.kts`、APP Dart、LiveKit vendor、后端、token/consent、WebSocket Upgrade、冻结计划或其他功能代码。若发现必须超出上述范围，停止该项并报告Owner。

优先把endpoint/日志到停止原因的分类抽取成纯函数，使其能在不启动任何子进程、不访问网络、不运行Gradle的情况下测试。至少增加并通过以下测试：

1. UDP endpoint，`remote=None`：分类为UDP endpoint目的不可见；不得报告已证实发包。
2. 非loopback TCP endpoint：分类准确且不把单一socket观测写成已证实payload传输。
3. loopback TCP IPC：遵循当前设计的loopback策略，不误判为外部网络。
4. 明确匹配的下载日志：仍触发下载保护。
5. 没有endpoint或下载日志：仅表示当前采样未观察到信号，不宣称绝对无网络。
6. 观察器读取失败/根进程不可观察：fail-closed，不能返回安全通过。
7. endpoint触发保护后仍保持停止，不允许自动重试或跳过保护。
8. 既有缺缓存/错误Manifest预检仍在构建进程启动前拒绝。

运行本地Python单元测试 `python apps/android/scripts/test_offline_debug.py`，并执行必要的静态检查。该命令不得触发Gradle、Flutter、Android SDK、APK构建、安装、设备操作或网络访问。若测试框架可能执行真实入口，先核验测试隔离方式并将真实 `execute`/subprocess/observer完全mock；不满足此条件时停止并报告，不要为了通过测试而调用真实构建。

## 4. 明确禁止

- 不得重新运行 `offline_debug.py` 的真实构建入口。
- 不得调用Gradle/Wrapper、Flutter build、AAR任务、Kotlin DSL编译或任何APK生成/安装。
- 不得启动Android设备测试、RTC通话或受控服务。
- 不得重新触发网络观察器的真实构建流程。
- 不得尝试下载Gradle、依赖、工具或外部资源。
- 不得删除、重命名或覆盖前次UDP观察记录、stderr/stdout、原R1 7,941,328字节partial及Hash。
- 不得修改系统网络策略、防火墙、环境变量、共享Gradle/Java/Flutter工具或管理员设置。
- 不得使用Gate 2、Bypass、Writer或Serializer；Gate 2本任务启动数必须为0。
- 不得合并产品main、启动v10.1.6、接入真实Push/生产服务、产生未经授权费用或清理历史备份、旧refs、SQL、APK、LOCAL_ONLY证据。

## 5. 集中交付

完成后集中交付一个普通non-force文档/代码候选，更新同一份 `IMPLEMENTATION_REPORT.md` 与一个 `artifact_manifest.json`；不得改冻结计划或覆盖历史章节。

报告必须列明：
- 实时main/Root、源码Commit/Parent/Root、候选Commit/Parent/Root、apps/services Tree及报告/Manifest Blob；
- 每个变更文件的Git Blob和SHA256；
- 单元测试命令、退出码、stdout/stderr Hash；
- 每个测试实际运行的是纯函数/mock，明确证明没有启动真实构建/设备/网络；
- UDP endpoint与真实出站尝试的语义差异；
- 之前真实构建停止的事实与原始证据身份；
- 本任务未执行任何真实构建、APK生成/安装、设备运行、Gradle/Flutter或网络访问；
- 保护资产与历史refs未变的核验范围；
- 非作者复核的准确范围，不得声称审阅者运行本地测试。

任务交付后停止，等待Astra集中独立验收。当前真实构建仍未完成，不能因为分类修正或单元测试通过而把构建验收标成PASS。

最终状态继续为 `V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN`，并且构建任务保持 `ACTUAL_BUILD_NOT_COMPLETED`，直到另有Owner明确授权与充分证据。

## 6. 派发方式

本文件只是待Owner手动派发的窄范围任务单。文档写入不等于派发。Owner手动将本任务单交给Codex后，Codex仅执行本文件授权的分类修正、单元测试和静态检查；完成后交付并停止。不得自行请求或推定真实构建重跑授权。
