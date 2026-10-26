# EliteSync v10.1.5｜TCP endpoint归因与条件式单次离线构建｜授权任务单

状态：DELEGATED_OWNER_AUTHORITY_FOR_ROUTINE_BUILD / READ_ONLY_ATTRIBUTION_FIRST / CONDITIONAL_ONE_REAL_BUILD_MAX / NO_GATE2_AUTHORIZATION / NO_PRODUCT_MAIN_INTEGRATION

日期：2026-10-27（Asia/Singapore）
最终Owner：用户
本任务授权签发者：Astra（依Owner本次明确授予的同类低风险离线Debug构建授权委托）
执行者：Codex，仅在Owner/Astra手动派发本任务后执行
独立验收：Astra

## 0. Owner长期授权与本任务边界

Owner于2026-10-27明确授权：对于与本项目近期离线Android Debug构建相同性质、无需新增费用且无明显风险的构建授权，Astra今后可代Owner签发，不必每次再询问Owner。该授权仅适用于本项目、已有本地工具/依赖缓存、普通Debug构建、已冻结代码/任务范围、单次尝试和可审计保护的情形。

授权委托不等于无限授权。以下事项仍需Owner另行明确决定或授权：
- 新费用、付费工具、下载新工具/依赖、外部服务、生产服务、真实Push、真实用户；
- Gate 2、Writer/Serializer、Bypass或任何历史已耗尽预算；
- 产品main合并、发布、版本升级到v10.1.6、不可逆数据操作、历史备份/refs/SQL/APK/LOCAL_ONLY清理；
- 修改系统防火墙、代理、网络策略、全局环境、管理员权限或共享工具；
- 不明网络目的地、无法归因的非loopback TCP、其他明显风险、授权范围外变更；
- 任何需要改变产品方向、冻结合同或保护边界的决定。

本次授权委托只覆盖“先只读归因、条件满足后最多一次本地离线Debug构建”。它不授权忽略未知网络信号，也不授权自动重试。每次实际构建均需独立的任务记录、预算claim、输入/缓存Hash和结果回读；失败后预算即耗尽。

## 1. 本次起点与状态恢复

仓库：`zcx369658780/EliteSync-v10`

本任务从最新候选 `cfddecc944a043b1d85361a954a692be0dd4ce23` 延续；开工时必须fresh读取live main、候选/源码Commit/Parent/Root、完整apps/services Tree、最新报告/Manifest、冻结计划、上次构建任务和Astra复核记录。不得把历史SHA视为实时HEAD，不得reset/amend/force-push。

已知前次唯一构建：
- 源码Commit：`12d4e284feea609935eab12c973f5fd2efbc2992`
- 候选：`cfddecc944a043b1d85361a954a692be0dd4ce23`
- 冻结计划Blob：`7d3466b3be67135dc641cfee7c7faef78937ba03`
- 构建预算1/1已耗尽，entry exit90、Gradle child exit1，未生成APK，无安装，无重试。
- 强停止：观察到任务Java进程拥有非loopback TCP endpoint/state5。远端地址和原始socket日志保存在LOCAL_ONLY证据中。该观察不证明payload或下载，但在目的地未归因前也不应假设无风险。
- 前次入口/Gradle日志、734次采样、UDP行数、原始停止证据及7,941,328字节旧Gradle partial与Hash必须原样保留。

产品接受基线仍为v10.1.4：apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`，services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`。v10.1.5仍为 `PARTIAL_NOT_ACCEPTED / AC05_OPEN / ACTUAL_BUILD_NOT_COMPLETED`。

## 2. 第一阶段：只读归因，不启动构建

使用原任务的LOCAL_ONLY原始进程/socket采样、命令/进程树记录、Gradle stdout/stderr和时间戳进行本地只读分析。不得把原始IP、端口、设备标识、凭据或未脱敏日志上传到GitHub；公开交付仅包含经脱敏的分类、证据Hash与必要的归因理由。

至少回答：
1. 非loopback TCP endpoint属于哪个任务PID/映像及其父子进程链；endpoint是由本次Gradle/Java子树创建，还是仅被错误关联到任务。
2. 本地原始记录中是否有可核验的远端地址/端口、socket state、首次/最后出现时间及同一PID的进程创建/退出时间。
3. 能否通过已有日志、已提交构建配置和原有工具的静态行为，解释它是哪个已批准的内部组件/本地服务通信，还是目的地/用途仍未知。
4. 是否有独立证据证明发生了实际payload/下载；仅socket endpoint/state不够。
5. 之前的采样器是否可能把嵌套Gradle、daemon、IPC或其他子进程的endpoint误归因；说明可证明的范围和无法证明的部分。

禁止主动连接该远端、ping/扫描、反向解析、探测端口、访问服务、重跑观察器、重放构建、抓取新的网络包或读取与本任务无关的秘密。不得为了归因改变系统设置或安装工具。

## 3. 条件式构建授权判定

Astra已按Owner委托签发本任务的条件式单次构建授权，但只有同时满足以下所有条件才可执行唯一一次真实构建：

A. 远端endpoint归因到已存在、已批准、无需新增网络/费用的本地开发组件，且归因证据足够明确；或有同等强度的独立证据证明此前“非loopback TCP”是观察器/进程归属错误而非未知通信。
B. 不需要连接未知/未批准的外部目的地，不需要修改网络/防火墙/代理/系统策略。
C. 所有已存在本地工具、Gradle 8.14、缓存、依赖、构建定义和Manifest Hash预检通过；无新下载、无依赖解析需求。
D. 隔离测试与静态检查先通过，预算guard/任务Blob/源码Hash均绑定当前任务。
E. 新任务自己的单次claim可独占创建，且没有该任务已启动过真实构建的记录。

**若任何条件不满足、证据有歧义或endpoint仍未知：不得启动构建。** 将结果报告为 `BLOCKED_UNKNOWN_NONLOOPBACK_TCP_ENDPOINT`，只交付只读归因结论并停止，不能因为Owner授权了“类似低风险构建”就把未知网络风险视为已接受。

若条件全部满足，最多启动一次普通 `:app:assembleDebug`，直接调用已验证的本地Gradle 8.14，使用已核验的缓存与offline参数，不调用Gradle Wrapper，不允许下载fallback。UDP endpoint可以按前次接受语义作为未知目的地观察记录，但不声称发包/未发包；任何下载日志、非loopback TCP（除非在任务前以独立证据明确归因为本地已批准组件且规则已静态验证）、观察器失效、Hash/缓存/工具不匹配仍立即停止。不得临时添加白名单或放宽停止条件以使构建通过。

构建启动预算严格为1。失败或停止后不重试、不换目录/入口、不删除claim、不通过重启恢复预算。

## 4. 若进入构建阶段，执行顺序

1. 完成只读归因报告并记录条件A-E逐项判定。
2. 运行隔离测试和静态检查；任何失败都先在无真实构建环境修复并重测。
3. Fresh验证任务Blob、源码/工具/缓存/依赖清单Hash与新任务预算claim。
4. 独占创建本任务的预算标记，再启动唯一一次真实构建。
5. 记录入口/Gradle退出码、命令、stdout/stderr Hash、观察记录Hash、停止原因、进程终态和APK结果。
6. 只有构建exit0、APK确实生成且Hash可读回，才可报告实际构建通过。安装回取只在新APK存在且原授权设备可用时执行一次；不扩展UI/RTC旅程。
7. 若构建失败，保留证据并停止。不得第二次启动。
8. 集中更新报告和Manifest，普通non-force发布候选，完成远端Commit/Parent/Root、完整apps/services Tree、文档Blob与原字节回读。
9. 候选交付后停止等待Astra集中验收。

## 5. 保护边界

- 不修改APP Dart、LiveKit vendor、后端、token/consent、WebSocket Upgrade或冻结产品计划；除非只读归因发现需要超出范围的修复，此时停止并报告Owner。
- 不运行Gate 2，不调用Writer/Serializer，不使用Bypass；所有Gate 2新启动必须为0。
- 不接入真实Push、生产服务或真实用户；不产生新费用。
- 不下载任何工具/依赖，不修改全局网络/防火墙/代理/执行策略/环境变量/共享工具。
- 不删除或覆盖旧Gradle partial、历史失败、原始LOCAL_ONLY进程/socket日志、APK、SQL、旧refs、备份或历史根。
- 只读归因未达到安全条件时，不能以隔离测试通过替代真实构建前置条件。

## 6. 集中交付和状态

报告/Manifest必须区分：
- 原始非loopback TCP endpoint事实；
- 归因结论与置信边界；
- 是否有独立payload/download证据；
- 是否达到条件A-E；
- 本任务真实构建启动数（0或1）、预算剩余数、是否生成APK；
- 测试、静态检查、工具/缓存Hash、文档/代码Blob与保护对象核验；
- Codex执行报告、远端源码证据、LOCAL_ONLY原证和非作者审查的边界。

无论结果如何，整版状态继续为 `V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN`；实际构建未成功时保持 `ACTUAL_BUILD_NOT_COMPLETED`。不合并产品main、不启动v10.1.6。后续构建授权可由Astra在本规则范围内自行签发，但不得重复使用已耗预算。

## 7. 派发

本任务单记录Astra依据Owner长期委托签发的条件式单次授权。Owner不需要再批准普通步骤，但Codex必须先完成只读归因并严格遵循条件A-E。任务文档写入不代表Codex已开始；仅在本任务被手动派发后执行。
