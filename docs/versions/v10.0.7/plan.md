# EliteSync-v10｜v10.0.7 正式冻结计划｜真实用户主循环与可核验本地能力

2026-10-15。**FROZEN_PLAN / OWNER_MANUAL_DISPATCH_REQUIRED / IMPLEMENTATION_NOT_STARTED**。

本版由Astra根据Owner批准的“原APP主要功能恢复＋独立Web管理面板、全部主要功能内测前完成”目标，以及Codex已完成的K08与版前可行性报告冻结。冻结的是本版功能结果、最小必要环境授权、明确排除及**AC-07-01～AC-07-08**，不以工作量或后续缺口改写。仅发布计划**不启动Codex、APP、服务或数据库**；Owner手动将本计划固定Git提交/Blob与“执行v10.0.7”交付Codex，才在本版范围内一次授权第4节受控开发操作。

## 1. 权威、固定基线与证据口径

- 唯一仓库：zcx369658780/EliteSync-v10。
- **本版实施代码起点**：K08实际远端main **0989812c141ce892915b67c14e9291d34e3c7053**，Tree **c2dd89f3a0726bff6cd18fb8fe0008c2f347aadf**。实际产品集成锚点 **78aba03a68cb5dcc0302ea7e9c20ff783f5169d5**，Tree **c027d70c37b353d3e37c3570b23f673c1033dd0f**。之后的计划/状态纯文档提交不自动变成新产品代码起点。
- [v10.0.6独立验收](../v10.0.6/acceptance.md)仍为ACCEPT WITH OBSERVATIONS；[K08登记](../v10.0.6/integration.md)已记录GitHub代码集成与本地接续。Astra GitHub复查三个Tree中的apps、services子Tree完全相同，且K08后main仅更新文档。本版不得重开旧验收。
- 版前来源：[Codex可行性报告](FEASIBILITY_RECOMMENDATION.md)，其Git Blob **eb0177230f6f485938af25ba735fe2d3561d6516**；[原草案](PLAN_PROPOSAL_V0_1.md)，Blob **bd549ec08b806e3c5dbf06a6e72db8f850c83c11**；[唯一恢复台账](../../architecture/RESTORATION_CAPABILITY_MATRIX.md)。可行性报告是具名本地源码调查与建议，不是对应功能实际运行PASS。旧D:/EliteSync的题库及算法Blob为Codex报告的来源身份，不等于Astra直接访问Windows。
- 复用原专用工作树 C:/Users/zcxve/.codex/worktrees/elitesync-main-be0636e/EliteSync-v10，Codex可在安全接续该基线后创建本版分支、连续提交，允许同版跨Android/Flutter/Laravel/迁移/任务/媒体/测试修改，不强制新worktree、单提交或全历史重验。实际工作树HEAD必须在实施前核对，不用旧CLEAN快照限制正常开发。
- Owner仍保留产品方向、超范围/第三方付费及不可逆风险的最终决定；Astra负责冻结和独立终验；Codex在派发后自主执行与集中交付；不恢复Work/dot自动监控或逐步骤审批。

## 2. 本版真正需要恢复的用户主链

**既有Android宿主→从最终源码新构建Flutter AAR/debug APK→真实Laravel→独立持久MariaDB**。不得另造Hello World或两套独立mock。

1. **账户、资料、真实问卷**：在0.6真实登录与城市链基础上，恢复完整资料修改、问卷题目加载、答卷、续答与持久读回；原“保存并重算”入口保留，未恢复的计算不允许冒充成功。直接复用具名旧题库五份结构/固定Blob，按现有seeder的题目ID、category、权重和recommended_bank及active规则做明确去重、版本和开放集合登记；research/重复题不能因为文件存在自动变为面向用户的必答题。最少有一个真实APP完整有效答卷流程。原五项因题库缺失产生的PHP测试错误属于本版恢复依赖，应修复相应源并重验，旧失败原文保留。
2. **真实匹配、消费与发布**：在本版隔离库创建具名虚构开发账号，其中至少两个满足实际资格/偏好/题目条件，另有无资格与禁用/阻断对照。不得重seed/改变0.6的三个验收账号，也不得全局关闭生产的synthetic排除；若需参与匹配，用account_type=test/generation_version=v10.0.7等开发标识并在**独立本地库**按现行资格规则配置。实际prepare→claim/execute/finalize→reveal→APP current/history/理由读回，覆盖零题、未发布、重复执行、失败可恢复与不合格账户。匹配结果只是匹配状态，**不自动产生Connection或聊天许可**。
3. **独立Connection和Messaging Consent**：复用已有Product Connection/MC状态转移与use-point语义，但不得把evaluateSynthetic/本地投影冒充在线权威。补齐真实身份、双方参与者、expected revision、事务持久writer/current reader、纠正/撤销/终止与失效传播，APP显示可操作双方独立选择。先双方明确建立Connection，再双方另行完成消息同意；任何一个旧Match like、Relationship event、UI按钮或客户端自报状态都不授予读发。
4. **合法文字聊天＋本地图片附件**：在**具名v10.0.7本地开发配置**里，七条原先受DenyUnverifiedMessagingLiveAccess保护的HTTP路径，只有在服务端可信当前Connection及相应消息同意成立时才能按功能开放；不能直接移除鉴权或全局关闭中间件。生产/未配置环境仍默认fail closed。真实双方APP身份完成会话列表、发送/读取、未读/已读、重复请求幂等、重启读回；图片从APP实际上传→本地媒体存储/处理→消息附件→收件人授权读取，不把单纯upload成功算闭环。blocked、disabled、未获双方同意、stale、撤销、非参与者、旧token和旧附件请求均失败且无越权读写。HTTP定期拉取可以作为本版正式消息传输实现，不能声称已交付WebSocket；保留既有其它消息/RTC逻辑保护。
5. **本地算法与解释**：八字使用现有依锁的6tail/lunar-php本地真实计算，记录输入、版本、时区/位置及fallback并展示可核验结果；选择至少一组有效样例与时间/位置缺失反例。恢复已有可选MBTI Lite测评的API、attempt/结果持久化与APP展示，**保持MBTI及人格不参与匹配排序**，不把简短测评声明成客观心理诊断。复用有证据的规则解释；未验证的紫微seed、西占legacy估计和standard_stub不能充当可靠完整排盘或自动匹配真值，不得暗中提高其core权重。出生资料完整保存若算法未运行，应如实呈现局部成功/待恢复状态，不声称全部星盘重算成功。
6. **已有动态、站内通知与设置**：真实APP发布/读取/修改/删除或支持的状态交互，经HTTP及DB持久化；拒绝非作者越权变更和错误后mock回退伪成功。匹配/合法消息的站内通知按现有事件语义真实生成、读取、标记已读/未读持久化；已支持的本地设置重进仍生效，未支持的服务端Push/同步明确标识，不用本地开关冒充OS推送。

既有0.6 Web管理员禁用应作为本版权限回归：开发账号被禁用后不得继续匹配、连接或读取/发送消息及下载附件；另一正常对照账号继续可用。不得扩成v10.0.8整套后台模块建设。

## 3. 本版暂不实施但明确保留的功能

Astra批准的是**功能实施顺序调整，不是永久删减**；这些均在恢复台账保留具名状态，并须在完整软件内测前解决其真实恢复/Owner明确排除选择：

- **RTC语音/视频通话**：现有LiveKit客户端/Token代码不足以证实双端媒体传输；需实际SFU、第二端和可能的许可证/费用决策。计划在**v10.0.8及后续用户恢复子工作包**中与后台建设并行统筹，必要时增加一个完整功能版本，不以v10.0.9联合验证名义跳过真实恢复。v10.0.7不购买或启动SFU，也不把token签发写成通话完成。
- **完整紫微排盘及西占宫位/合盘/行运/返照**：紫微当前默认seed/fixture未校验，iztro需具名准确性/许可核验；西占高精度旧Python Kerykeion服务及Swiss相关依赖存在明确blocked_default许可门。v10.0.7不安装/开启被阻止的运行依赖，不以local研究模式绕过商业授权，也不以随机seed或错误宫位冒充完整算法。后续应给出经批准的实际计算引擎、算法oracle/输入签名、时间/地理源与许可证路线；若需费用/真实外部服务，Owner单项决定。
- **搭子/Buddy/Social真业务**：当前及已核旧页以mock/静态为主，未证明原版存在完整线上双端实现；不把占位页算“已恢复”。继续具名追踪其它已实现来源；若经核明确属于全新实现，由Owner在后续包确认范围，不因旧MVP Later标签静默丢失真实原版能力。
- **实时WebSocket、视频/语音附件、系统Push、地图供应商、真实SMS、全后台功能**：不在本版AC。已有明确原版能力依恢复台账进入后续功能工作包，未确认实现来源则标UNKNOWN，不报告PASS。本版允许出生地手工坐标输入，不代表地图搜索恢复。

v10.0.8独立Web管理目标仍有效，用户侧欠缺能力不得被默默排挤到内测以后。v10.0.9全端联合验证、v10.0.10软件/算法/操作说明及必要新功能迭代仍按实际进度安排，版本数量不是运营发布日期。

## 4. Owner手动派发后一次生效的受控环境与修改授权

- **开发树/工具**：复用已集成K08专用源与Flutter3.41.7/Dart3.11.5/JDK17/Gradle8.14/AGP8.11.1/Kotlin2.2.20/Android36与36.1及Laravel现有lock依赖。可下载正常构建所缺的**现有锁定**可信包并启动已有Docker Desktop和本地模拟器；不composer update、整体升级SDK/JDK/Flutter或全局代理，不擅自安装系统级服务/UAC。
- **数据库与账号**：新建专用MariaDB10.11恢复库 **elitesync_v1007_dev**，独立容器 **elitesync-v1007-db** 和持久volume **elitesync-v1007-db-data**，默认宿主仅 **127.0.0.1:43317**；若被无关进程占用，选另一可用loopback端口并在manifest记录一致配置，不动端口占有者。不得更改/重seed/删除原0.6库、容器或验收volume。仅新建具名、虚构的0.7开发账户与题目/媒体/聊天数据，专用配置与凭据LOCAL_ONLY，迁移/seed应防误库与幂等并支持本版实际重启无重seed验收。
- **本地服务与任务**：可复用Laravel loopback8000及现有仅内部转发PHP8001，按需启动和停止具名本地MatchingRun consumer、媒体处理worker及必要队列；任务失败/锁争抢/重试由Codex范围内修复。若8000/8001被占用，记录并统一切换到空闲loopback端口；不得杀无关进程。开发业务HTTP/数据库写入及新media本地磁盘权限属于本版授权，不等于外网服务授权。
- **APP/设备**：当前源码构建新Flutter AAR与debug APK，在具名Android36.1 x86_64 AVD经**明确serial**的ADB reverse访问本地Laravel；可新建第二个专用AVD或严格隔离两账号APP会话来证明不同用户实际读发（不能用两端mock），必须检查现有设备归属，不wipe其它AVD。允许开发图片fixture从明确本地沙盒选择及截图；原0.6 APK只作为历史证据。非开发正式默认URL、鉴权与全局明文流量不得放宽。
- **已核原版题库来源**：仅允许具名读取/复用Codex在FEASIBILITY_RECOMMENDATION附表列出的旧仓五个问卷内容JSON及相关原业务实现。保留原文件与来源Blob身份，迁入本版开发源时记录重复题/开放集合/编码与导入结果；不读取历史SQL gzip/VHDX、旧用户内容、私聊或其它项目文件，不批量考古。
- **媒体/会话**：本版独立、不可公网访问的media目录、DB表及必要worker，可写入虚构图片测试数据；不上传真实个人照片/录音/第三方token，不发外部通知。对已授权聊天的读发/附件download落实服务器使用点检查，日志脱敏；不解冻旧生产私信或修改v10.0.6原证。
- **严格排除**：原3306、历史真实数据库/SQL/VHDX/生产SSH/API、真实用户/密码/个人信息、商业SDK/高精度西占被许可门阻止的默认运行依赖、LiveKit新服务/真实第三方付费、外部地图/Push/SMS、新系统级安装/提权、资产删除和生产发布。碰到需要这些资源的**具体单项**仅暂停相应能力并报告，其他无风险功能继续；不得把排除转换为全局零网络零数据库禁令。

允许同版本修改相关Flutter/Android/Laravel、数据库迁移、鉴权/领域live写入、配置、必要开发脚本与自动测试。安全改变仅在新0.7隔离本地环境下以**可信身份＋当前状态＋使用点**开启有权者业务；生产及未授权环境保持fail-closed，不删除BE-12七路由拒绝历史记录或放行旁路旧API。

## 5. 冻结AC-07-01～AC-07-08（均为必需）

| AC | 必须实际成立的结果 |
|---|---|
| **AC-07-01 固定来源与独立环境** | 候选从固定代码起点可追溯，最终commit/tree及模块diff明确；新0.7独立DB/container/volume/media目录、实际loopback服务和开发虚构账号经核验。问卷源明确列具名旧Blob/导入去重结果，0.6验收卷、原dirty根和备份未覆盖。真实APP/HTTP/数据库而非mock。 |
| **AC-07-02 账户/完整资料/真实问卷** | 最终AAR/APK安装的原APP经真实登录/完整资料保存、题库实际显示、有效答卷与继续填写、服务器验证、答案/attempt版本持久读回；重进、重登和Laravel/MariaDB重启后同账号一致。无效题目/答案、他人资料、禁用账号拒绝；原0.6城市/禁用路径不回退。原五项题库缺失PHP错误有针对性有效修复/重验，旧失败留档。 |
| **AC-07-03 实际匹配任务与APP结果** | 开发合格账号完成真实questionnaire-readiness→prepare/claim/execute/finalize→reveal→APP current/history/reason同一Match记录；实际执行并保留任务/异常/重试输出。零题/无资格/禁用/未发布不得冒结果；重复执行不产生无效重复。匹配不自动建立Connection或消息许可，未验证玄学seed不作为权威排序输入。 |
| **AC-07-04 独立Connection/消息同意** | 两名具名用户在原APP实际请求、接受、拒绝/撤回，当前Connection与Messaging Consent由服务端持久化并支持expected revision、重复/过期/错参与者拒绝；两阶段不是一键自动同意。单边Match意愿、失效/closed/revoked/UNKNOWN、block或disabled状态不能获取live读发；重启后状态仍正确。 |
| **AC-07-05 合法文本/图片消息与保护** | 双方真实APP身份通过受保护HTTP完成文本发送/列表/未读/已读及服务端数据库重读；至少一张本版虚构图片经upload→处理/状态确认→消息关联→合法对方下载成功，重启后仍有效。原七条私信路由逐条核有权成功与无权拒绝，客户端缓存不绕过后台；撤销、block、非参与者、禁用和旧会话不能读发/下载，失败无越权写入。不能用绕过中间件的单测或两端mock代替。 |
| **AC-07-06 MBTI/八字与规则解释** | APP用户完成可选MBTI实际测评/结果、API与attempt持久一致，重登可读，排序权重仍为0；八字真实引擎对有效输入计算并保存/展示、用实际已知案例及错误/跨时区边界核结果与provenance。匹配/资料解释明确数据来源、版本、降级和未恢复能力；不将紫微seed、西占估计或未校验输出写成完整排盘/核心匹配事实。 |
| **AC-07-07 动态/站内通知/设置** | APP状态发布/读回及至少支持的点赞、删除/举报或同类真实已有交互经服务端/DB持久；作者/非作者、失败/重试和重启正反例齐全。实际匹配/有权消息触发站内通知并支持未读/已读持久化。已有本地设置操作重进有效且实际作用范围明确；无系统Push、地图或后台同步不伪称成功，不静默mock替换远端失败。 |
| **AC-07-08 最终交付与独立验收** | 源码生成的最终Flutter AAR/debug APK与hash/构建参数/版本/地址/设备可追溯；相关PHP/Flutter/构建及真实双账号APP、服务/数据库/必要worker重启的命令、原始安全stdout/stderr/exit、操作截图和失败修复留证，最终分析不能只凭exit0声称无lint。安全GitHub候选含报告/manifest/关键证据及本版恢复台账，物理包若仅Windows本地明确LOCAL_ONLY。Astra独立按固定8项AC终裁；未验完整旧功能/RTC/全紫微西占/生产等标NOT_RUN，不能自称全部APP完成或自行合并main/启动0.8。 |

任何关键真实链未交付，不可用增加synthetic/Widget/curl测试数或把NOT_RUN写为PASS补足。Codex如遇普通失败在版本内修复重测；需要新费用、许可、额外系统权限或产品目标删减则报告最小具体阻塞，同时继续其它无风险工作。不得事后改写本计划或AC；本版原目标内缺陷集中返修，新功能/纯优化另列。

## 6. 实施与交付方式

Codex在一次派发后按依赖顺序自主实施：新0.7隔离DB/问卷题库与账号→资料/问卷→任务真实匹配与APP→Connection/MC持久writer/权限→七私信路由合法读发与图片→MBTI/八字/解释→状态/站内通知/本地设置→最终APP/DB联合重启、测试和证据封存。顺序可以交错，非微步骤审批。

交付固定候选commit/tree、产品构建源码锚点与模块diff、当前源码AAR/APK本地路径及物理hash、专用环境启动说明（不得提交密钥）、具名账号/MatchingRun/Connection/consent/message/media/status/notification DB读回与两侧实际APP截图、权限正反例、测试真实exit/stdout/stderr及失败修复、恢复台账。大型包及私密原证保持LOCAL_ONLY，发布安全索引；没有访问的本机事实不能让Astra冒充已读取。

Codex普通non-force推送**独立候选**并集中回报 **V10.0.7 CANDIDATE DELIVERED — AWAITING ASTRA FINAL ACCEPTANCE** 后停止；不自动合并main、不启动v10.0.8、不发布生产。Astra作最终独立验收和复盘，再按现行K08另行记录GitHub集成/本地接续/目标运行。**Owner手动派发本固定计划才代表授权执行**。

**终点：V10.0.7 FROZEN PLAN — EIGHT AC — OWNER DISPATCH PENDING。**
