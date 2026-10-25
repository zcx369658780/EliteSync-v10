# EliteSync v10.1.5｜构建离线保护与 APP RTC 清理｜小范围集中任务单

状态：OWNER_REQUESTED_FOCUSED_TASK / READY_FOR_MANUAL_CODEX_DISPATCH / SAME_VERSION_ONLY / NO_GATE2_AUTHORIZATION / NO_PRODUCT_MAIN_INTEGRATION

日期：2026-10-25（Asia/Singapore）
Owner：最终产品方向与不可逆决策 authority
执行者：Codex，仅在 Owner 手动派发后执行
独立验收：Astra

## 0. 任务目的与范围

这是Owner在R1交付后明确要求的小范围后续任务，仅覆盖两项：
1. Android构建入口的Gradle离线/无意下载保护。
2. APP侧RTC清理残余警告的复现、归因和最小修复。

它不是v10.1.6，不是整版返修重开，不是新的全面RTC/AEC计划，也不是产品main集成。不得扩展成通用构建系统重构或LiveKit SDK重写。

R1候选 `d45cd08f939f6dfc6b4efe2420f4a117efc99e68` 已有界接受，整版仍 `V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN`。R1源码Commit `e7cbbe6030b033c5c9244c599bd42fcff312a8c6` 的重复call-scoped leave等待修复保留，不回退、不重复重做已通过的22+27项检查。

## 1. 开工前恢复实时状态

仓库：`zcx369658780/EliteSync-v10`

开工时fresh读取：`ACTIVE_STATE.md`、冻结 `plan.md`、本任务单、最新 `IMPLEMENTATION_REPORT.md` 与 `artifact_manifest.json`、R1候选及Astra R1有界复核记录。核验live main/Root、R1候选Commit/Parent/Root、源码Commit/Tree、报告和Manifest Blob、工作树与分支。不得将历史SHA当作实时HEAD，不得reset/覆盖/强推。

冻结计划Blob仍为 `7d3466b3be67135dc641cfee7c7faef78937ba03`。已接受产品基线仍为v10.1.4：apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`，services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`。只在已授权的本地连续工作树与同版本候选链工作，不合并产品main。

## 2. 工作流 A：阻止 Gradle Wrapper 意外下载

### 已知事实

R1首次APK构建的内层Gradle Wrapper在外层标记offline的情况下仍尝试下载Gradle。任务进程被终止，7,941,328字节partial及SHA256 `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4` 保留。修正后Codex在本轮ignored构建副本内直接调用已有Gradle 8.14，构建exit0；这证明修正后的单次构建可用，不证明仓库有可重复的受控入口或进程树绝对无网络。

### 要求

1. 调查现有Android/Flutter构建入口与Wrapper配置，定位为什么离线意图没有阻止Wrapper bootstrap下载。
2. 新增或修正一个项目拥有、可复用、fail-closed的本地离线debug构建入口；优先沿用仓库已有脚本组织方式。不改全局Gradle/Java/Flutter安装，不改系统网络或安全策略。
3. 入口必须先解析并验证显式提供的本地Gradle 8.14可执行入口/运行时；校验版本和运行时身份（如SHA256由调用方明确传入或与任务记录绑定）。若工具缺失、Hash不匹配、依赖缓存不完整或参数不安全，必须在启动构建前失败，不得退回Wrapper或联网下载。
4. 直接调用已验证的本地Gradle，不调用会bootstrap下载的Wrapper。启用Gradle offline依赖解析、关闭JVM/工具链自动下载，并固定普通debug build参数；不得启用ICE诊断或retention probe。
5. 记录入口、参数、Gradle版本/Hash、依赖预检、进程树身份、stdout/stderr Hash、退出码、APK Hash和安装回取Hash（若本次实际构建/安装）。
6. 在当前获准环境中实际运行一次入口。证明Wrapper bootstrap路径未被调用；监测任务拥有进程树是否尝试网络访问。若发现下载或联网尝试，立即停止自有构建进程树、保留partial和日志，标记失败，不重复无监督重试。
7. `--offline` 本身不等于“全进程树无网络”。只有可审计的进程/网络观测支持时才报告相应结论。若现有工具无法证明绝对无网络，明确报告边界，禁止夸大。
8. 保留R1首次下载偏差与partial原证，不删除、不覆盖、不改写成成功。

### 验收条件

- 本地工具可用且依赖齐备时，项目自有入口完成一次普通debug build，exit0，APK Hash可复核。
- 工具或依赖不满足时，入口在任何构建子进程启动前fail-closed。
- 入口本身不调用Gradle Wrapper，不存在隐式下载fallback。
- 不修改全局配置、系统网络策略、共享工具或已接受产品源码。
- 新失败与旧偏差均保留；不能以“构建成功”掩盖首次下载尝试。

## 3. 工作流 B：APP侧 RTC 清理残余警告

### 已知事实与限制

R1修复了重复带callId的leave在Room分离后提前返回的问题。R1新call的指定native/lifecycle端点保守停止上界为0.90625秒；AEC和最后可闻波形仍未证明。

R1报告仍记录限定采样窗口内camera close code4/5警告6次、trackDispose-null警告5次。此前历史证据中也有过SDK PCM清理ConcurrentModificationError；不得把不同候选/不同call的旧事件拼接成当前R1新失败，也不得把它们隐去。

本任务只调查APP侧RTC清理顺序、重复dispose/close和事件归属。不得修改LiveKit vendor SDK、后端、token、consent、WebSocket Upgrade、AEC配置或冻结产品合同；若证据显示必须越界，停止该子项并报告Owner，不自行扩大授权。

### 要求

1. 从R1源码与报告开始，定位APP的renderer cancel、Room disconnect、Room.dispose、leave completion和新join barrier的调用顺序。
2. 使用现有授权Android测试机、原有合成PC对端和受控测试服务，在新call上取得同PID、同call的前置基线与结束后日志。先确认媒体确实建立（四方向RTP计数增长；必要时视频decode增长），再执行UI挂断或撤权后的清理。
3. 分别记录PeerConnection CLOSED、AudioRecord/AudioTrack stop done、camera release、renderer cancel、Room.disconnect、Room.dispose和leave完成事件。区分事件未出现、事件出现但返回失败、重复关闭警告和仅旧日志。
4. 重点归因camera close code4/5与trackDispose-null：核验是否由APP重复发起关闭、旧Room迟到回调、正常幂等关闭或SDK/native层行为导致。不能仅凭计数认定是缺陷。
5. 检查重复leave/new join barrier是否仍可能提前返回或跨call污染。复用R1已有两例RED→GREEN和22+27项检查；仅在新代码改变或新增测试能暴露风险时重跑受影响的定向测试。
6. 若发现可证明的APP-owned缺陷，在APP源码和测试中做最小修复并先新增能复现问题的测试，再修复后重测。保留原始RED、stderr、退出码与Hash。
7. 若警告来自正常的幂等native关闭、上游SDK或平台语义而非APP bug，不得为追求零日志而吞异常、屏蔽警告或更改vendor SDK；提供源码/日志依据并将其标为观察项。
8. 不把指定native/lifecycle端点5秒内可见等同于最后可闻波形停止、AEC通过、全native handle清点或所有平台资源释放。
9. 不采集或上传私人语音、原始PCM、私人图库、短信、通讯录、Bearer/JWT或未经脱敏的设备日志。原始设备证据保持LOCAL_ONLY，只发布最小脱敏摘要及Hash。

### 验收条件

- APP侧警告有明确归因，且同call、同PID的事件序列可审计。
- 如存在APP-owned缺陷，新增回归先RED后GREEN，受影响测试与Dart分析通过。
- 如无可证明的APP缺陷，报告不改源码的理由，不把警告伪装为PASS。
- 重复leave修复仍通过；清理失败不会被误报为成功，也不会在旧Room teardown完成前开启新join。
- AEC、最后可闻波形和完整native handle census继续按证据标记，不自动关闭AC05。

## 4. 环境、费用与资产保护

- 只使用原有授权本地代码树、已安装的开发工具、原授权Android测试机、合成账号/媒体及现有受控测试服务。
- 不读取/上传私人设备内容、凭据、原始SQL/APK/日志；敏感原件保持LOCAL_ONLY。
- 不清理历史备份、旧refs、旧候选、审阅分支、SQL、APK、partial下载、原始失败或LOCAL_ONLY证据。
- 不修改全局环境变量、系统安全策略、网络防火墙、共享Gradle/Flutter/Java工具；项目自有脚本与任务拥有的ignored构建副本除外。
- 不接入真实Push Provider、生产服务、真实用户或外部付费资源。
- 任务结束后检查自有构建/测试进程、手机APP进程、call/session/token、测试服务、端口和ADB reverse；恢复任务开始时的受控状态。保留APK安装、容器/volume和所有保护资产。

## 5. 集中交付与停止

集中更新同一份 `IMPLEMENTATION_REPORT.md` 和一个 `artifact_manifest.json`，必要时更新状态入口；不得改冻结计划或覆盖历史章节/原始失败。

交付应绑定实时main/Root、源码与候选Commit/Parent/Root、apps/services Tree、报告/Manifest Blob、变更文件Hash、测试命令与退出码、stdout/stderr Hash、APK build/install Hash、AC-01～11状态、证据来源分类、资源恢复和保护对象核验。

Gradle偏差必须分别记录首次下载尝试与后续修正构建，不得合并成一次无失败构建。APP警告必须记录归因和证据边界；不同call/不同APK的证据不得拼接。只做有界非作者复核，不得声称审阅者执行了本地测试或设备操作。

发布一个普通non-force同版本候选并完成远端Commit/Parent/Root/Blob/原字节回读。候选交付后停止，等待Astra集中独立验收。

最终保持 `V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN`，除非后续有充分证据且Astra独立改变裁决。禁止自动合并产品main、启动v10.1.6、创建无关微任务、启动未授权Gate 2、接入真实Push/生产服务、产生未经授权费用或清理历史证据。

## 6. 派发方式

本文件仅为待Owner手动派发的正式小范围任务单。写入文档不等于派发任务。Owner手动将本任务单完整交给Codex后才开始执行。Codex在上述范围内自主完成调查、实现、测试、普通失败修复和集中交付；Astra在新候选发布后集中独立验收。