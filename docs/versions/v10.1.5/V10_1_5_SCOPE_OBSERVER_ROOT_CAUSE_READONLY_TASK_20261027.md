# EliteSync v10.1.5｜G 阻断后的 owned init scope + observer image-path 定点根因调查

**状态：OWNER_APPROVED_BOUNDED_READONLY_ROOTCAUSE / TASK_PUBLISHED_FOR_OWNER_MANUAL_DISPATCH / ZERO_GRADLE / ZERO_PRODUCT_REPAIR / ZERO_RUNTIME_RETRY / NO_MAIN_PRODUCT_INTEGRATION**

日期：2026-10-27（Asia/Singapore）

Owner：产品/重大不可逆决定 authority；本任务及下述受控工具链维护方向已明确授权。  
Astra：Project Lead、Independent Reviewer、Planner、Orchestrator、Current-state Manager；本任务完成后独立审查证据、决定建议，不自动放行Gate或创建不必要的后继任务。  
Codex：Owner在本地 ChatGPT Desktop / GPT Work → Codex 工作流**手动派发本任务单**后才执行；发布不等于派发或运行。

## 0. 本任务唯一目标与硬边界

在 **不再次启动任何 Gradle/Flutter构建或设备/网络实验、不修复产品源码、不运行已失败的G或被G阻断的A** 的前提下，用现有LOCAL_ONLY原始证据、已提交的项目自有源码和必要的定向静态检查回答两个问题：

1. 为什么真实G命令已带 `-PelitesyncOwnedAarInit=v10.1.5-ordinary-r1-runtime`，`settings.gradle` / `dev.flutter.flutter-plugin-loader` 场景却触发 `OWNED_AAR_INIT_REJECTED: explicit ordinary R1 scope required`？区分不同Gradle invocation / included-build / settings/plugin-management 上下文中的属性实际可见性与推断；不能在未见证据时钉死单一根因。
2. `OBSERVER_OR_LAUNCH_FAILURE:OSError:PROCESS_INSTANCE_PATH_UNREADABLE` 由哪个只读/身份核验路径、哪个异常分支触发？该对象是否能通过具名日志与实例身份关联？保留无法判断PID复用、普通退出、访问拒绝或网络行为的UNKNOWN。论证观察器**继续fail-closed**的必要性与可能的最小安全修复候选；不能先改监测使运行继续。

同时判断是否有**具名Gradle缓存损坏/工具版本不兼容**的实际正面证据；不要只因为配置失败或异常便归罪缓存、下载或盲升级。

本任务成功终点是 `BOUNDED_ROOTCAUSE_EVIDENCE_DELIVERED`，不是 `G_PASS`、`AAR_POM_PASS`、`BUILD_SUCCEEDED` 或 `AC05_CLOSED`。根因无法证实也算完成，只要证据边界清楚并给出可执行但**未执行**的下一步最小方案。

## 1. Fresh authority：先核，发现冲突停相关事项

- 仓库 `zcx369658780/EliteSync-v10`；执行前刷新GitHub main、Root、当前正式任务、ACTIVE_STATE、本次Astra fd0接受及交接分支的两份原件。**main的ACTIVE_STATE旧正文来自2026-10-25，读取时先看2026-10-27新前置状态，不用老“v10.1.5未启动”覆盖交接。**
- 初始参考 live main `4df2e7f0f36cc7b80258faa73e80dad682cff6c5` / Root `03b0ecfcc360e38a462539dd50690c64b663a21e`；下一次文档发布将推进main，执行时重新GET，不拿此SHA硬对当前main。
- 正式fd0候选 `fd0da9cce87c5eb84aec96dd11ea37aecd7aefff` / 唯一Parent `da5ce628a499c97e916e780e2cf795353745c147` / Root `b1f6fd9de8083f017e342fe82149874a66ff815a`；apps `e6bff4bc8e359e6afe80c02f25212ee8b6195eab` / services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`，属于**未接受的产品候选**，不合main。
- 已接受产品v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- 冻结 v10.1.5 plan Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`；先前G/A正式任务 Blob `129efb748bb5a22921e756f2f829a627ceae6880`；fd0报告 Blob `e6f0a1f96b5d52993dfce5f31ad9456ba4d06e80`、索引 Blob `38b20500d0e42218976a9f675607b7a5b259a7b1`。
- Astra最新fd0独立复核：`astra/v10.1.5-fd0-ga-bounded-review-20261027:docs/versions/v10.1.5/FD0_GA_CONTROLLED_VERIFICATION_ASTRA_REVIEW_20261027.md`，Blob `31c711e29bb32dad1e6d30c82dd08cd0b3526c32`；审查分支HEAD截至本任务准备时 `bcd20e9bf30aba97f7e35ac7278fe8bdc1c95028`。其裁决仅 `FD0DA9CC_BOUNDED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS`。
- 先前方案一源级接受 Blob `1a39ba1ab5df7c69a0f6143b4734ba56b31cf134`、源提交 `50d79396195ed8b4b86c218584ab59864ad600be`。
- 同一2026-10-27交接分支 `handoff/v1015-20261027` 的完整交接及状态分别Blob `079f4c22a3d2080af676cd630b445d6a627e877d` / `dba1b6c2cd3b85887cbcd296fb9f65b3869a1b5f`；勿误把本次2026-10-27文档审查分支当main。

## 2. 精确读取范围与证据分类

在已有本地项目、任务隔离快照和既存证据位置上**只读**访问：
- 方案一 tracked init `apps/android/scripts/owned_flutter_aar_init/aar_runtime.init.gradle` 的首部scope guard及被删的两处Javadoc请求；`owned_aar_init.py` 与来源/补丁/License；`apps/android/app/build.gradle.kts` 普通R1内层命令组装、scope属性和`-I`顺序。
- 本次G执行器的LOCAL_ONLY原始 `controlled_runner.py`、`test_controlled_runner.py`、`G.claim.json`、`G.command-private.json`、`G.result.json`、`G/stderr.txt`、`G/stdout.txt`、`G/process-network-private.jsonl`、`G/invocation-private.json` 及已具名衍生摘要。依据fd0索引对每份读取的内容重新验证其SHA256与字节数，若缺失/不符按证据缺口停止对应断言，不改写原证。
- Flutter模块 `.android/settings.gradle`、相关plugin-loader included build/settings实际来源，只定位到已具名源码和Flutter SDK固定版本的相关代码；必要时只读查看与错误堆栈直接有关的局部源码，禁止全盘无目标扫描。
- 新库存 `100453` 项的既有inventory/审计结果和关键缓存版本声明仅作针对性定位；不要重做47 MB全量库存普查，不对100453项再次全面Hash。检查仓库/本地报告中版本与损坏迹象；静态查看受控范围内元数据/zip校验字段可以，但不为证明完整性强行下载或解压重写。
- LOCAL_ONLY权限、进程实例、IP/socket原始日志只在本地读；GitHub仅发布脱敏、最小必要的证据摘要和SHA/Blob/代码定位。PID、用户名、详细路径、socket原始行、令牌、SQL、私聊、旧APK以及其他私人原证不能出GitHub。

使用证据分层：`ASTRA_DIRECT_GITHUB_STATIC`（已有前验收）；`CODEX_REPORTED_LOCAL_ONLY`（本任务实际只读执行与Hash）；`INFERRED_HYPOTHESIS`；`NOT_PROVEN`。非作者静态复核若有，只限任务内差异/解释，不冒充运行。

## 3. Scope门禁：只读工作步骤和应交付问题

1. 对照报告的原始G参数数组/工作目录、claim内实际命令hash、Gradle stderr中真实 `settings.gradle:22` 堆栈；确认错误发生在何时、哪个Gradle对象/构建配置级别，哪些字段原证确实可用。
2. 读 `gradle.startParameter.projectProperties['elitesyncOwnedAarInit']` 与 `-PelitesyncOwnedAarInit` 拼写、命令顺序、属性可见性；区分主build、Flutter loader 的settings/pluginManagement、included/composite build或Gradle创建的额外初始化上下文。
3. 对照项目自有init是如何被Gradle初始化脚本加载与传播的；列出**至少两种有证据的竞争解释**（如附属构建属性传播／参数解析或脚本执行上下文），逐项注明支持的原始行、缺失证据、能否在未来无需真实网络/无需再次消耗旧G预算下最小验证。
4. 不补称存在已选中Dokka任务；G `selectedTasks=[]` 是配置未完成，`DOKKA_TASK_SELECTED=NOT_PROVEN`。区分注册任务、dry-run选择和真实执行。

## 4. Observer image-path：只读工作步骤和应交付问题

1. 在**实际G runner源码**找出产生 `PROCESS_INSTANCE_PATH_UNREADABLE` 的路径（包括进程实例创建时间/可执行映像路径/父链核对所用的API或函数、异常捕获及failure marker）；按源码行/Hash和原G样本定位。
2. 说明抛出时哪一段观测未被最终写盘，已有36个样本和原私密索引哪些字段可用于或不足以用于唯一实例身份；不能用PID alone决定退出/PID重用。
3. 将 `UNREADABLE` 可能性分开：进程正常结束竞态、权限拒绝、进程保护机制、Windows API和路径重定向/非原子采样、实现bug；每项给证据与`UNKNOWN`，不能无证选一个单因。
4. 检查Job kill-on-close、根进程停止、A gate=false及原始日志的历史报告，保持严格fail-closed。可以提出静态验证的最小改进候选，如可靠区分API层错误或加强异常前记录；**不得在本任务修改runner以放宽强停，也不得运行真实进程模拟**。
5. UDP endpoint不证明已发送数据报；36样本内无非loopback TCP强停不等于绝对无网络，不抹去历史TCP/Dokka尚未证明的归因。

## 5. Owner新授权的缓存与工具链维护政策（条件授权，不是立即执行令）

Owner于2026-10-27明确补充：**确有Gradle缓存问题时，允许尝试受控删除、可信来源重新下载；确有其他软件版本兼容或损坏问题时，授权Astra发布Codex更新任务。新版本通过实际可回退验证后，允许有界卸载/清理旧版本以降低磁盘占用。**

解释如下：
- 本轮**纯只读诊断**：新增授权**不赋予本任务**下载、删缓存、安装升级、卸载、真实Gradle启动或构建许可。本任务可以直接提出`CACHE_CORRUPTION_EVIDENCE`（有具名证据）/ `CACHE_CORRUPTION_NOT_PROVEN`；`TOOLCHAIN_VERSION_CONFLICT_EVIDENCE` / `TOOLCHAIN_VERSION_CONFLICT_NOT_PROVEN`，以及可行升级或修复路线、预估空间与风险。
- 未来经具名证据确定必须清理/重下载时，Astra可在Owner此**受控维护方向授权**内发布独立**明确路径、版本、回滚及硬盘预算**的Codex任务。新版本必须先进行项目隔离验证、输入/输出Hash和兼容性比对；新版的安装不等于已可删除旧版。
- 清理仅限**已识别、非共享依赖且无历史证据身份的缓存、工具旧版本或验证后确定可安全删除的旧安装**。在删除前核对所有项目对旧版本/缓存的引用、Owner其它项目共用情况、重建来源与磁盘可用空间；跨项目共享依赖不明则保留并标BLOCKED。除已知可安全回收的任务自有临时副本外，不作全盘目录删除。
- 明确禁止把**已受保护的2026-10-26 Gradle下载partial（7,941,328字节；SHA256 `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`）、旧claim、ledger、日志、SQL/APK、历史证据、旧refs/dirty根**视作普通可清理Gradle缓存。此类保护原证除非Owner对具体对象另行明确决定，不删除、不改名、不覆盖。
- 可信下载不得默认更改系统代理、VPN、防火墙或执行策略；需满足安全来源、版本/签名/hash、网络范围和已授权费用零新增。若下载/更新需要系统级提权、安全保护变更、真实费用、不可回退的全局操作或会触及其它项目，则保留方案并暂停请求具名Owner授权；原“不下载”仅对前一**已冻结任务**及当前纯只读任务有效，不能反向禁止未来Owner已批准的限定维护任务。
- **维护许可不等于构建额度许可**：旧完整APK 1/1、G 1/1仍耗尽；A仍因G gate=false不得执行。即使重装Gradle或刷新缓存，也不得借此重跑旧G、A、APK、Gate2，或通过换目录、清ledger、重置claim避预算。

## 6. 任务预算与保护合同

本任务全部运行预算：**Gradle 0次、Flutter CLI build 0次、AAR/POM 0次、外层APK 0次、device/ADB/RTC 0次、Gate2 0次、真实Push/数据库/云端/生产0次、网络下载0次、修改软件源/共享SDK/全局缓存0次、系统更新/卸载0次**。仅可执行带作用域的现有文件只读/Hash核验及简单静态解析；不得启动受审工程子进程进行“轻量复现”。必要辅助脚本仅在全新任务自有隔离outbox写入并记录Hash，不修改项目源码。

本任务开工与收尾仅对**具名历史受保护范围**做不破坏性验证；旧 `26784`份具名文件、五根、近期108项和525 refs是前次Codex报告范围，不能假装本任务已复算全部。若范围大，沿用上一次seal索引定向核查旧partial与claim、输入及交付原件关键指纹。保留所有LOCAL_ONLY证据、下载partial、旧账本、原始失败及已消耗预算；不进行 `git clean/reset/stash/prune/force` 或清空下载目录。

继续保留：
`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ACTUAL_BUILD_NOT_COMPLETED / GRAPH_NOT_PROVEN / AAR_POM_RUNTIME_NOT_PROVEN / ROOT_CAUSE_NOT_PROVEN / EDGE_NOT_PROVEN / DOKKA_TCP_CAUSALITY_NOT_PROVEN / DOKKA_TASK_SELECTED_NOT_PROVEN / REAL_PUSH_PROVIDER_PENDING / GATE2_NOT_AUTHORIZED / PRODUCT_MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED`。
真实AEC、最后可闻波形、native handle完整普查、真实15/30天经过和物理30天清理不能因本研究关闭。

## 7. 单次交付/停止条件

Codex只在收到Owner手动派发后执行本任务，在同一v10.1.5下集中形成一份**脱敏Markdown根因审查报告**和必要的最小证据索引；原本地日志与辅助脚本留在LOCAL_ONLY。报告至少交付：
- G命令含scope但settings/plugin-loader拒绝的实证链/竞争假设/尚缺字段；
- Observer出现 `PROCESS_INSTANCE_PATH_UNREADABLE` 的实际源码路径、触发与证据缺口；
- 保守停止与Budget G=1/1、A=0/1 gated、旧APK=1/1、Gate2未授权的复核；
- `CACHE_CORRUPTION_NOT_PROVEN` 或具名证据，以及有无真实软件版本冲突；仅在有证据时列精确受控修复/清理/更新候选，不建议盲目全量重新下载；
- 每个建议给优先级、要改的文件/路径、需要的**新授权类别**（源码修复、缓存刷新、受控Gradle图验证、软件升级等）、预估磁盘占用、回滚路径、是否涉及共享/保护范围；
- `PROVEN/NOT_PROVEN/HYPOTHESIS` 分级及若证据不足时的单一最小下一步。

采用普通非强制文档候选（既有仓库工作流可用时），显式给出candidate Commit、唯一Parent、Root、apps/services Tree及报告Blob/实际读回；**不得假设能在本地GitHub之间同步的私有材料自动出现在远端**。保持产品main不动、仅脱敏结果归档；任务被系统权限、保护文件冲突或证据缺失阻断时如实报告。

**完成后STOP，等待Astra独立验收和Owner已给的后续维护授权在具体范围内受控使用；不自动修复、Gradle重试、更新软件、清理缓存、建后继任务、合并产品或启动v10.1.6。**
