# EliteSync V2｜BATCH-OTHER-DESIGN：跨首页、匹配、资料/形象、消息通知的一轮合并静态设计审阅 V0.1

日期：2026-11-19（Asia/Singapore）  
审阅基准治理分支：`governance/home-matching-product-freeze-20261117`，首读HEAD：`e3a39b78a2725f7d6586e32482f72813ccee1356`。  
状态：`ADVISOR_SINGLE_PASS_STATIC_REVIEW_COMPLETE / OWNER_CONCEPT_TRACEABLE / DETAILS_AND_EVIDENCE_OPEN / ALL_NEW_RUNTIME_NOT_RUN / DESIGN_ONLY / CODEX_NOT_AUTHORIZED / A6_MEETING_DEFERRED`

## 0. 目的、依据与边界

遵照Owner最新工作方式要求“不要把门禁拆的太散，我们需要加快速度”，对**首页与内容、Lifestyle/匹配/Connection/消息许可、资料用途/形象发布、消息与通知**四个领域进行一轮合并静态梳理，减少旧草案中的过期“待Owner确认”和后续逐项追问。

本轮按需核对以下**具名Owner文件原文**：
- [J-01/J-02首次Lifestyle及连续关系引导](../decisions/OWNER_JOURNEY_INTERACTION_DECISIONS_20261117.md)；
- [S02-D1/S03-S04-D2](../decisions/OWNER_V2_S02_D1_S03_S04_D2_ACCEPTANCE_20261119.md)、[S05-D1/S07-S08-D2](../decisions/OWNER_V2_S05_D1_S07_S08_D2_ACCEPTANCE_20261119.md)、[S09-D1/S11-D2](../decisions/OWNER_V2_S09_D1_S11_D2_ACCEPTANCE_20261119.md)；
- [O04/O05及O05-X A](../decisions/OWNER_V2_O04_O05_DATA_REUSE_AVATAR_PUBLICATION_20261119.md)、[DATA-D1/D2](../decisions/OWNER_V2_DATA_D1_D2_PURPOSE_REUSE_CORRECTION_PUBLICATION_ACCEPTANCE_20261119.md)、[O06-R2/R3、O07-R2](../decisions/OWNER_V2_O06_R2_R3_O07_R2_ACCEPTANCE_20261119.md)、[O09](../decisions/OWNER_V2_O09_CROSS_DEVICE_AUTH_UNKNOWN_ACCEPTANCE_20261119.md)、[O10/O12](../decisions/OWNER_V2_O10_O12_LOW_DENSITY_ACCESSIBILITY_CONCEPT_ACCEPTANCE_20261119.md)、[O11](../decisions/OWNER_V2_O11_EDITORIAL_REPOST_SORT_CONCEPT_ACCEPTANCE_20261119.md)；
- [S01–S16四批总览](ELITESYNC_V2_S01_S16_FOUR_BATCH_CONSOLIDATION_AND_OPEN_GATES_V0_1_20261119.md)、[P0三分流](ELITESYNC_V2_P0_OPEN_TRIAGE_PRODUCT_EXTERNAL_ENGINEERING_V0_1_20261119.md)、[剩余Owner真正决策审计](ELITESYNC_V2_REMAINING_TRUE_OWNER_PRODUCT_DECISIONS_TRIAGE_V0_1_20261119.md)、[内容评论合并批次](ELITESYNC_V2_BATCH_CONTENT_SINGLE_PASS_UX_STATE_DRAFT_V0_1_20261119.md)和[合并审阅规则](ELITESYNC_V2_CONSOLIDATED_DESIGN_REVIEW_AND_GATE_COMPACTION_V0_1_20261119.md)。

**只做GitHub文本文档静态对照**，没有打开或运行APP/API/Web/DB、设备/模拟器、APK、真实供应商，也没有做动态权限测试。本文中的“界面状态”“可用操作”是`ADVISOR_UX_CANDIDATE`或具名Owner已明确的目标边界，不是当前运行行为的证明。所有尚无实证的工程/法律事实保留`OPEN / UNKNOWN / NOT_RUN`。

## 1. 分域静态审计结论

| 领域与对应屏 | 现行`OWNER_CONFIRMED`或既有业务基线 | 仍`ADVISOR_PROPOSAL / OPEN`，不要冒称已批 | 原则层结论 |
|---|---|---|---|
| 首页/精选/好友 S03–S04、官方S16 | 访客只读明确开放的官方正文；已登录仅当前合法受众/Block允许的用户作品；首页两频道，来源清楚；安全空态不得泄漏账号或关系；编辑推荐不等于访客可读的正式转载；非参与度最大化排序（S03/S04-D2、O11） | 精确卡片、专题互动/编辑审核角色、排序字段、媒体/搜索/直链真实隔离、独立转载合同及生效版本 | `DESIGN_ALIGNED_IN_REVIEWED_SCOPE / EVIDENCE_OPEN` |
| 首次Lifestyle S01–S02 | 注册后显示一次可跳过的首次欢迎；正式真实匹配前必须完成五场景；图文三选一，点选后仅确切保存成功才自动下一题；失败/UNKNOWN停题（J-01、S02-D1） | “仅一次”跨端存储与迁移、正式题库素材/版本、改选冲突、进度恢复的工程合同 | `OWNER_FLOW_CONFIRMED / IMPLEMENTATION_NOT_RUN` |
| 匹配准备/关系 S05–S08 | 当前可补任务优先；真实身份供应商未接入不可正式真实报名；匹配提案、双方Connection、双方Messaging Consent与Conversation/Relationship分别有独立权威与决定，连续导航不越过必要同意（J-02、S05-D1、S07/S08-D2） | 资格字段映射、供应商回执和有效期、真实报名、设备/双人联测、过期/冲突/拒绝文案与具体屏数 | `DESIGN_RULES_ALIGNED / G01_EXTERNAL_OPEN / RUNTIME_NOT_RUN` |
| 我的/事实/具名用途 S06/S10/S12 | 单一权威事实来源，已有有效用途可复用，缺新具名用途仅必要字段独立申请，拒绝不阻断其它合法功能；撤销后不能继续无权使用；受影响派生结果待核查不得作为已验证结果新发布（O04、DATA-D1/D2、O07） | 真实来源/字段与用途许可版本、法定处理依据、依赖图/计算/历史留存、账户/跨端真实合同 | `OWNER_SEMANTICS_CONFIRMED / DATA_EVIDENCE_OPEN` |
| 本人预览/形象发布 S11 | 本人主形象预览与社交/匹配已发布快照独立；发布前摘要说明差异、受众与影响并需本人独立确认；O05-X A新匹配形象只给未来有权新候选，旧候选不自动升级（O05、S11-D2） | 真实发布回执与旧版身份、Block/撤销时效、社交形象其它默认受众、向旧候选独立新版分享（NEW-PC-04，建议延期） | `OWNER_VERSION_BOUNDARY_CONFIRMED / G06_ENGINEERING_OPEN` |
| 消息/站内通知 S09与S13/S14 | 通知已读≠待办完成；真实有效截止期待办优先；普通通知按实际时间；只有仍合法才显示最小失效历史；处理完成/取消后优先安全返回当前账号通知频道；UNKNOWN只读检查不盲重发（O06、S09-D1、O09） | 真正的Push/许可/投递回执、去重聚合、旧通知保留、恢复位置与Back、跨端Block/账号/媒体缓存一致性 | `OWNER_NOTIFICATION_BOUNDARY_CONFIRMED / EXTERNAL_AND_ENGINEERING_OPEN` |

**一致性结论**：在所列具名Owner文本范围，未发现需要推翻既有业务原则的直接逻辑冲突；这不是对16屏全部具体UI、法域、软件权限、用户体验及交互次数的总体验收。

## 2. 跨领域单次UX静态规格草案（候选，不新增Owner微型审批）

下表只说明页面应表达的状态/安全默认，不推断后台能力。凡出现“重读、查询、显示、打开”等建议，均以**实际存在的合法能力和当前权威资格**为前提。

| ID / 用户所处状态 | 合法主操作/可见信息（已定边界或顾问候选） | 必须阻断与恢复 |
|---|---|---|
| X01 访客首页 | 读取明确开放的官方正文；没有可读内容则显示安全空态和合法入口 | 禁止用户作品/评论/缩略图/作者身份泄露，不以半遮卡片做登录诱导 |
| X02 登录首页受众未知、断网、Block或切号 | 当前身份合法的无敏感空态；可安全重读或返回 | 不从前账号/旧缓存填充好友作品、媒体或关系线索 |
| X03 首次Lifestyle欢迎/跳过 | 可开始五场景或跳过进入内容首页；真实匹配资格保持未满足 | 不把欢迎页跳过等同于已完成真实资格或星盘成为硬门槛 |
| X04 Lifestyle题目已点选但未权威确认保存 | 保持当前题、区分选择中/保存中/失败/UNKNOWN；有权时查真实保存结果 | 未确认不能自动进下一题、重复提交或标进度完成 |
| X05 Match准备中本人仍有可补项 | 突出当前合法可补的一个任务，其他资格仍可查；保存后重新核资格 | 不捆绑星盘/MBTI等可选用途、不自动报名或授持续匹配权 |
| X06 真实身份核验服务未接入 | 明示外部核验当前不可用，允许准备其它可合法完成事项 | 正式真实报名/假核验通过/真实候选成功链不可用 |
| X07 将来合法提案→Connection→Messaging Consent | 连续显示当前合法下一步、双方各自决定与等待/退出 | 任一方拒绝/失效/Block/未知时停止推进；聊天不能自动建立正式Relationship |
| X08 匹配字段已知但缺当前用途许可 | 简述具名目的、必要字段、许可范围与拒绝/返回；合法获准才复用 | 不因一次填报自动授权其它工具或对外外显 |
| X09 更正事实造成某派生结果真正受影响 | 仅标依赖且待核查的结果“需要核查”；其它合法独立功能继续 | 未验证结果不得向新受众冒称有效，不能自动重算或重发布 |
| X10 修改本人主头像/昵称预览 | 更新使用默认形象的本人预览；独立覆盖字段不自动改变 | 预览保存≠社交或匹配对外发布 |
| X11 准备对外发布社交/匹配形象 | 发布前简述版本变化、受众、目标场景；本人独立确认 | UNKNOWN不显示已发布；新匹配版不得默认扩散至既有候选 |
| X12 当前有权处理待办通知 | 真实有效截止期的待办优先；进入通知业务详情后独立决定，返回当前账号通知上下文 | 已读不等于已处理；旧通知不得一键越权接受 |
| X13 通知业务失效、账号或Block变化 | 有权且不泄密时可显示最小结束状态，否则隐藏并回合法频道/首页 | 不泄露旧身份、昵称、关联关系或已经失效的操作 |
| X14 写入超时、回执丢失或跨设备冲突 | 稳定说明UNKNOWN，有权先查询权威结果；不能核实时安全返回 | 不根据动画、其它设备缓存或请求超时推断成功/失败，不自动高影响重发 |
| X15 低密度/无障碍未来目标 | 一屏一目的、一个突出合法主操作，必要拒绝/撤回/返回可见；未来逐项D/I/N/A/W及读屏/大字/减少动效 | 动画不能代替保存回执；没有实机QA不报PASS |

本表不代表新增15个业务枚举或15条独立Owner授权。X01–X15属于**合并静态UX候选**，不是可直接执行的Codex任务书。

## 3. P0/产品取舍三分流，专门防重复审批

### A. 已获具名Owner原则：不重新索要确认
首页访客/登录分域、安全空态；Lifestyle点选后确认保存才进题；匹配准备可补任务优先、独立双方授权；资料已获用途合法复用/新用途最小许可；外显版本影响摘要与O05-X A；已读≠待办完成、通知安全回流、失效不泄密；O09 UNKNOWN只读核验；O10/O12低密度、未来无障碍验证原则。评论域NEW-PC-01/02/03、EDGE-D1/D2已具名接受。

### B. 未来需要Owner产品/范围选择，但**本轮无需逐条审批**（采用既有安全默认）
- `NEW-PC-04`：是否给既有匹配候选主动新版分享。建议首期不追加，继续O05-X A（旧候选不自动更新）；这是一项**顾问延期建议**，不是Owner对首期排除能力的正式批准。
- `NEW-PC-05`：正式访客可读官方转载是否属于首期。建议官方原创与受控编辑推荐先行，真正正式转载等独立素材/用途/版本授权及合法运营机制；延期同样仅为顾问建议。
- 官方编辑权限、推荐排序/聚合、通知“一键全部已读”、历史状态保存时间、精确UI文案/布局、匹配倒计时、反馈附件大小及跨进程草稿：原则上归`P1/P2_DESIGN_DETAIL`，不以这些开放点要求Owner现在连续开微型决策。
- 如出现要**新增**匹配资格、自动同意、外显受众、跨用途许可或真正的不可逆数据操作，必须另交Owner明确决定，不能从本稿默认推出。

### C. 当前没有证据，不能用Owner概念批准替代
| 门禁 | 当前真实缺口及安全默认 | 以后解锁所需依据（不是现在的测试指令） |
|---|---|---|
| `G01_EXTERNAL`真实Match | 实人核验供应商未接入，正式真实报名禁用 | 实际供应商合法协议/回执、费用及适用身份资格、真实注册到匹配端到端证据 |
| `G02/G03`首页与内容 | 登录用户公开内容域和历史媒体/受众真实权限证据未核；访客不看站内用户作品 | APP/API/DB、深链/搜索/媒体签发与历史受众真实核查 |
| `G04/G05/G06`来源/用途/派生/快照 | 真实字段来源、用途许可版本、依赖图、发布结果与失权时效未核 | 合法依据、现行数据模型、真实权威回执与版本依赖及具体发布/撤销测试 |
| `G07/G08/G09`删除/失权/Push | 删除受理与备份/缓存、跨设备幂等/读权、真实设备Push都缺新证据 | 外部法域/第三方权利、授权后工程端到端、真实Push供应商/设备授权 |
| `G10`可用性与资产 | 43原始PNG远端仍按现行文档为`PENDING_BINARY_UPLOAD`，未重新逐份核验；全部新动态QA未执行 | 原二进制真实SHA/固定回读，未来正式A6及实机D/I/N/A/W/无障碍分别验证 |

注：`G01_EXTERNAL`是分类说明，不是新运行枚举；本报告不声称每一项需要相同优先级或当前已经有可用接口。

## 4. 静态设计阶段的总收束与下一步建议

**本批结果：`BATCH_OTHER_DESIGN_STATIC_SCOPE_COMPLETE / NEW_OWNER_CHOICE_NOT_IMMEDIATELY_REQUIRED / DETAILED_UX_CANDIDATES_OPEN / EXTERNAL_AND_ENGINEERING_GATES_OPEN`。**

与既有[BATCH-CONTENT](ELITESYNC_V2_BATCH_CONTENT_SINGLE_PASS_UX_STATE_DRAFT_V0_1_20261119.md)结合，可称**当前Owner接受的V2主要产品方向具备可追溯的静态整理材料**；不应称`V2_DESIGN_FULLY_FROZEN`、`ENGINEERING_READY`或`RUNTIME_PASS`。

建议下一步不是再拆四批大量微决策，而是把这两份批次的**已确认产品方向、建议UI状态与未来缺证据项**压缩成一张`V2_CONCEPT_REVIEW_CLOSURE_AND_EVIDENCE_HANDOFF`导航表，供Owner快速判断是否继续深化纯静态设计，或**以后明确单独**授权受限的本地Codex差距评估。当前不创建设备/工程验收工单，不开启A6。

## 5. 停止与固定旧证据

`DESIGN_ONLY / CODEX_NOT_AUTHORIZED / A6_MEETING_DEFERRED`持续。旧软件基线`10.1.18-dev / 1011804`与UI-AUDIT-01原`NOT_RUN/UNKNOWN`保持；G01–G10所有新增动态QA继续`NOT_RUN`，真实身份核验与真实Push尚未接入；F-01旧待审快照的`READABILITY_PARTIAL`未关闭，原43 PNG远端仍`PENDING_BINARY_UPLOAD`，GitHub治理分支不等于本地实际代码同步。不得据此派Codex新V2工程、修改APP/API/Web/DB、启动设备或模拟器、构建APK、合main、发布或采购/接入真实供应商。
