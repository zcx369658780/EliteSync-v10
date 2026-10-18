# EliteSync-v10 产品功能现状对照与后续候选矩阵｜Codex只读综合任务单

**2026-10-19 — OWNER_APPROVED_RESEARCH_TASK / MANUAL_DISPATCH_PENDING / NO_NEXT_VERSION_PLAN / READ_ONLY_PRODUCT_AUDIT**

## 1. 任务目的与边界

Owner已同意先建立产品功能候选矩阵，再结合公开市场资料讨论未来路线图。此任务仅为**只读研究与对照**，不是版本规划、产品决定、实现任务、整版验收或发布授权。

本次要把三类来源放在一份可审阅报告中：
1. 旧EliteSync仓库的历史竞品研究结论与证据等级；
2. EliteSync-v10当前真实代码、已接受版本、恢复台账、已交付/未接受候选与验收证据；
3. 从上述对照中形成的待讨论产品候选。

Owner和Astra稍后会另行使用公开搜索引擎研究2026年10月仍有效的市场资料，并决定是否进入下一版本规划。**本任务不做新的网络竞品搜索、不启动竞品APP、不重复真机截图拆解，不冻结任何下一版本。**

## 2. 固定权威与起始状态

当前项目：`zcx369658780/EliteSync-v10`。

开始时先核验实时main、工作树HEAD/status/index、接受源码对象和并发变化。不得依赖旧记忆或历史main SHA覆盖现有状态。

优先读取：
- `AGENTS.md`
- `PRODUCT_DECISIONS.md`
- `CURRENT_STATE.md`
- `DOC_INDEX_CURRENT.md`
- `docs/workflow/CURRENT_WORKFLOW.md`
- `docs/architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md`
- `docs/architecture/RESTORATION_CAPABILITY_MATRIX.md`
- v10.0.6～v10.0.11各版正式acceptance/integration与必要结果报告
- v10.1.0 `plan.md`、`IMPLEMENTATION_REPORT.md`、`DEV_ACCESS_AND_FILING_DEFER_CONTINUATION_RESULT.md`、`DEV_ACCESS_AND_FILING_DEFER_CONTINUATION_ACCEPTANCE.md`
- 旧仓研究报告的当前附件版本：`ELITESYNC_LEGACY_COMPETITOR_RESEARCH_INVENTORY_FOR_V10_20261019.md`

已知旧仓根为 `D:\EliteSync`；当前项目根为 `D:\EliteSync-v10`。附件研究报告可能不在本地工作树：先在明确的 `D:\ProjectTemp` 与 `D:\EliteSync` 范围内按完整文件名做有限只读定位。若没有该文件，继续使用旧仓具名源文档和已提交历史报告；在交付中说明未读到附件副本，不得扫描整盘或从其他项目的记忆/缓存补猜。

旧仓报告给出的具名重点：
- `docs/reference/SOUL_INTEGRATED_UI_FUNCTION_REPORT.md`
- `docs/reference/CECE_RESEARCH_MASTER_CURRENT.md`
- `docs/visual_reference/8.0_d0_competitors/manifest.md`
- `docs/governance/ELITESYNC_9_1A_A1_CECE_SOUL_SCREENSHOT_FIRST_COMPETITOR_PRODUCT_INVENTORY_2026_08_13.md`
- `docs/governance/ELITESYNC_9_1A_A1_CECE_SOUL_SCREENSHOT_FIRST_COMPETITOR_PRODUCT_INVENTORY_ACCEPTANCE_2026_08_13.md`
- `docs/governance/ELITESYNC_9_1A_A1_SOCIAL_APP_FUNCTION_TAXONOMY_AND_USER_JOURNEYS_2026_08_13.md`
- `docs/governance/ELITESYNC_9_1A_A2_TARGET_PRODUCT_MAP_AND_COHERENT_USER_JOURNEYS_2026_08_13.md`
- `docs/governance/ELITESYNC_9_1A_A1_COMPETITOR_EVIDENCE_MANIFEST_2026_08_13.md`

这些历史竞品材料属于证据输入，不自动成为v10目标或授权。

## 3. 只读要求与禁止事项

- 不修改产品源码、测试、配置、依赖、数据库、服务或APP。
- 不执行数据库写入、部署、服务启停、构建、安装或设备操作。
- 不操作竞品APP，不新采截图、不访问竞品API、不抓包、不反编译、不读私有数据，不执行关注/消息/匹配/支付/发布等用户影响动作。
- 不改写旧研究原件，不把历史接受记录重新标为今日接受。
- 不把v10.1.0未接受候选当成main产品；必须区分已接受并合main的源码与分支候选。
- 不把“入口可见”写成“功能已实现”，不把代码存在写成业务链已验收，不把旧研究推断写成竞品直接证据。
- 不上传原始截图、私聊、个人资料、数据库或LOCAL_ONLY证据；报告只引用文件路径、hash、提交、AC和可公开安全的结论。
- 不执行Git add/commit/push/merge/reset/clean/prune；除最终报告在专用文档候选分支的正常交付外，所有工作只读。不得将报告合入main或启动下一版本。

## 4. 任务A：恢复最初v10路线图的完成度口径

用当前生效的v10路线图及恢复台账为主，不把旧M0–M6历史编号当作当前版本顺序。报告需简洁重述：
- 两项核心目标：实际可用APP＋后端/数据库及选定原版主要功能；独立Web管理后台。
- 原五个功能包v10.0.6～v10.0.10及后来D6顺序调整。
- v10.0.6～v10.0.11各版实际接受范围。
- v10.1.0目前整版PARTIAL/NOT_ACCEPTED、AC-10.1-08 PARTIAL、R1只在限定范围接受。
- 未完成的原版主要能力：Buddy/Social、其他原版媒体/地图/系统Push/必要设置、获准历史数据/附件、完整APP与Web管理端联合验收及其他恢复台账具名项。
- 已接受动态盘、匹配/连接/消息、RTC/媒体、管理员/云端试点等各自范围及限制。

每项必须标为：
`ACCEPTED_AND_IN_MAIN` / `ACCEPTED_CANDIDATE_NOT_IN_MAIN` / `IMPLEMENTED_BUT_NOT_FULLY_ACCEPTED` / `PARTIAL` / `NOT_RESTORED` / `UNKNOWN`。
给出直接证据（commit/tree/path/AC/report）。不得仅凭旧路线图文字断言现状。

## 5. 任务B：真实v10当前实现盘点

只读检查v10当前代码与已接受证据，按以下领域逐项对照：
1. 账户、首次使用、身份和Profile；
2. 关系意图、偏好、资料可见范围；
3. 慢约会问卷、eligibility、round/等待/匹配结果/恢复；
4. Discover/社区/Feed/话题/搜索/内容创建与互动；
5. Buddy/搭子、活动、圈子、群组、陪伴；
6. Match后Connection、Messaging Consent、关系推进；
7. Messages、文字、图片、短视频、语音、视频、历史、失败/重试；
8. 玄学与个人参考：MBTI、星座、八字、紫微、西占、本命扩展、行运、回归、关系盘；
9. AI表达建议、破冰、关系解释及其设置/隐私边界；
10. 通知、站内通知、系统Push、地图/附近；
11. 安全与信任：举报、拉黑、禁用、撤权、账号退出、删除/恢复；
12. Settings、隐私、同意与会话管理；
13. Web管理后台：用户、审核、举报、匹配运营、问卷、权限和审计；
14. 部署、云端环境、历史数据/附件恢复、安装包/签名/升级链。

每个领域必须分别给出：
- 当前用户可见入口；
- 真实前端实现位置；
- API/后端业务实现；
- 数据表/迁移/持久化；
- 测试类型及是否真实端到端；
- 正式接受版本和对应AC；
- 当前状态与证据层级；
- 已知失败、观察和未运行项目；
- 是否已在main，还是只在候选分支；
- 判断置信度与需要进一步核验的未知。

使用 `SOURCE_PRESENT`、`UI_ENTRY_ONLY`、`UNIT_TESTED`、`INTEGRATION_TESTED`、`REAL_E2E_REPORTED`、`ACCEPTED`、`PARTIAL`、`NOT_RUN` 等清晰标签。一个功能可有多个标签，禁止只给单一绿/红结论。

## 6. 任务C：对照旧竞品证据

以旧报告中的证据等级为准：
- SCREENSHOT_VISIBLE
- SCREENSHOT_JOURNEY_OBSERVED
- ENTRY_VISIBLE_ONLY
- HISTORICAL_REFERENCE
- MODEL_INFERENCE
- ACCEPTED_RESEARCH_CONCLUSION
- NOT_OBSERVED
- PRIVACY_EXCLUDED
- UNKNOWN

不得把历史截图称为2026年10月的最新产品事实。不得将DeepSeek/Claude/Codex推断升级为直接观察；不得把竞品入口可见写成真实业务完成。对每个候选功能，给出具体竞品来源、观察日期、页面/路径、证据等级和未验证边界。

重点比较Soul的公开表达/Feed/搜索/Planet匹配入口/聊天/个人展示，测测的个人档案/星盘/关系解释/AI与真人服务分层，以及Bumble/Tinder/探探/陌陌等稀疏样本的身份验证、安全提示、暂停/退出、附近/通知入口。稀疏证据必须标UNKNOWN，不能补齐成完整功能矩阵。

## 7. 任务D：形成产品功能候选矩阵（不是新路线图）

为每个候选同时给出以下维度：
- 用户问题/场景；
- 历史竞品证据；
- v10现状（引用代码/AC）；
- 差距类型：`EXISTING_COMPLETE` / `EXISTING_INCOMPLETE` / `RESTORE_OLD_CAPABILITY` / `NEW_CAPABILITY` / `OPTIONAL` / `NOT_RECOMMENDED_TO_COPY` / `UNKNOWN_NEEDS_AUDIT`；
- 讨论分类：`CORE_SOCIAL_DATING_CANDIDATE` / `ELITESYNC_DIFFERENTIATOR_CANDIDATE` / `OPTIONAL_EXPERIENCE_CANDIDATE` / `NOT_RECOMMENDED_TO_COPY` / `REQUIRES_OWNER_PRODUCT_DECISION` / `V10_CURRENT_IMPLEMENTATION_NEEDS_SEPARATE_CHECK`；
- 复杂度粗分（低/中/高，不承诺工期）；
- 主要隐私/安全/运营/许可/科学风险；
- 前置依赖；
- 不确定性及下一步需要什么证据；
- 是否可能进入未来功能包讨论，但不得给出最终优先级或版本号。

至少覆盖：
- 核心慢约会生命周期；
- 社区与表达；
- 兴趣/话题发现；
- 搭子/共同活动；
- 匹配后低压破冰与关系推进；
- AI解释与表达建议；
- MBTI/星座/八字/紫微/星盘作为可选差异化；
- 可靠媒体通信；
- 关系退出、隐私、安全、举报/拉黑/申诉；
- 通知、暂停、稍后与恢复；
- 个人反思/留存；
- 会员/虚拟经济/真人服务市场；
- 独立Web管理后台与运营工具；
- 历史数据/附件恢复；
- 正式签名/分发与部署。

## 8. 会议讨论清单

从矩阵中选出10–15项最值得Owner与Astra讨论的产品候选，不按实施优先级排序。每项列：
- 用户问题；
- 竞品证据；
- v10当前证据；
- 为什么值得讨论；
- 主要取舍；
- 隐私/安全/运营风险；
- 复杂度；
- 尚缺证据；
- 需要Owner回答的产品问题。

必须明确三项高层问题：
1. 搭子是慢约会的辅助场景，还是独立社交入口？
2. 社区做到什么程度才能帮助相互了解，而不变成无限Feed/Soul式内容中心？
3. AI与玄学嵌入匹配、Profile、Messages的程度如何平衡差异化与dating-first主线？

这份清单仅用于讨论，不等于Owner已批准。

## 9. 交付文件与候选流程

唯一报告建议路径：
`docs/research/V10_PRODUCT_FUNCTION_GAP_AND_CANDIDATE_MATRIX_20261019.md`

报告需包含：
1. 摘要与来源边界；
2. 最初v10路线图完成度；
3. 当前v10真实实现矩阵；
4. 历史竞品证据矩阵；
5. v10缺口与候选功能矩阵；
6. 10–15项Owner讨论清单；
7. UNKNOWN/冲突/未验证项；
8. 来源索引与证据等级说明；
9. 本次实际读取范围与未读取范围。

在专用候选分支 `codex/v10-product-gap-matrix-20261019` 上只新增这一个报告，基于实时main安全建支，普通non-force push并回读Commit/Tree/Blob。**不合main、不改当前路线图/恢复台账/产品决定、不新增下一版本计划、不修改源码。**

若本地v10或旧仓dirty状态有变化，保持只读。报告需明确旧仓报告附件是否找到、是否直接读到旧截图像素或仅读历史文字/manifest、当前源码审阅范围、各证据层级及所有UNKNOWN。

完成出口：
`PRODUCT_GAP_MATRIX_CANDIDATE_DELIVERED / AWAITING_ASTRA_REVIEW / NO_NEXT_VERSION_PLAN`

Codex不得自行接受报告、设定新版本编号、宣布实施优先级或开始开发。Owner/Astra将之后结合公开搜索结果另行讨论与定路线。
