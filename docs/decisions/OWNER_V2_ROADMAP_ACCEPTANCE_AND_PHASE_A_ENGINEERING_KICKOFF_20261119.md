# EliteSync V2｜Owner接受集中工程路线图并授权启动阶段A

日期：2026-11-19（Asia/Singapore）  
治理分支：`governance/home-matching-product-freeze-20261117`  
状态：`OWNER_ROADMAP_V0_1_ACCEPTED / PHASE_A_ENGINEERING_AUTHORIZED / PHASE_B_C_D_NOT_YET_STARTED / A6_MEETING_DEFERRED / NO_PRODUCTION_RELEASE_AUTHORITY`

## 1. Owner原文与准确授权解释

网页GPT顾问提交并固定[EliteSync V2 S1-A后四阶段+三并行依赖线集中工程路线图V0.1](../product/ELITESYNC_V2_POST_S1_CONSOLIDATED_ENGINEERING_ROADMAP_V0_1_20261119.md)后，明确表示：“下一轮只需要您集中审定这份路线图的总体方向。获得认可后，再单独决定是否授权本地Codex启动阶段A，不再拆分大量零碎审批。”

Owner直接回复：

> 你好，上述路线图审阅完毕，我认为非常完善，并且授权你开始执行。

这既是对**四阶段、三并行依赖路线图总体方向的明确采纳**，也是对**立即推进第一阶段A工程实施**的明确授权。不得把此回复降级成“只同意继续写规划”。同时本轮并未要求立即跳过A的验收去实施B/C/D，也未批准厂商接入/采购、正式A6会议、数据处理不可逆决定、生产发布或main合并。

**权威分层**：
- `OWNER_ROADMAP_V0_1_ACCEPTED`：四阶段A→B→C→D与E1/E2/E3并行依赖被接受为当前总体路线图；细节允许Codex在既有具名Owner产品合同范围内自治拆分优化，重大新增用户权利由Owner决定。
- `PHASE_A_ENGINEERING_AUTHORIZED`：当前已有EliteSync本地Codex项目会话可启动阶段A的APP/API及必要安全持久化实现、隔离的自动化测试和工程自验；此处不是S1已结束的一次性只读权限的延长，而是**新的独立工程实施授权**。
- `PHASE_B_C_D_PLANNED_NOT_YET_STARTED`：后续阶段纳入总体方向，但先按A成果集中评审再排实施，不以“执行路线图”默示越过权限/数据/合法依据。
- `EXTERNAL_OR_HIGH_IMPACT_STILL_RESERVED`：实际身份/Push供应商联络、采购和生产接入；真实个人数据迁移、删除/备份不可逆操作、发布与main合并；正式A6 UI会议及真机/模拟器测试仍须相应新的明确Owner授权。

## 2. 阶段A工程授权范围与Owner安全约束

按照已接受[阶段A路线图](../product/ELITESYNC_V2_POST_S1_CONSOLIDATED_ENGINEERING_ROADMAP_V0_1_20261119.md)和[S1-A限定验收](../workflow/V2_S1A_READ_ONLY_GAP_AUDIT_ADVISOR_ACCEPTANCE_20261119.md)，阶段A作为**一个合并工程批次**，其能力范围：

- **A1 正式身份/Match门禁**：本地合成TEST_ONLY身份不可充当真实用户身份供应商凭证；真实供应商未集成时，真实报名、持续自动参与、正式候选/轮次及正式Relationship实人依赖的正向路径必须安全阻断；保留合法Lifestyle与独立社交路径。不实际接入供应商。
- **A2 匹配形象旧候选版本**：新发布只给未来合法新候选；对仍合法旧候选读取其绑定的授权旧版本，而非自动读当前发布；若旧版不可恢复/当前失权则保守隐藏而不是伪造或泄露。不未经授权导出敏感资料。
- **A3 UNKNOWN先核验**：移除Lifestyle pending自动重放的越界路径；高影响写入结果UNKNOWN须用当前有权、真实权威只读结果/请求事实核对，无法确认保持UNKNOWN，不自动重新发送；已有幂等键与版本判定要保留但不能替代核实。
- **A4 脆弱路径保守阻断**：受众历史不明确、旧缓存/深链、媒体权限无法证明时维持fail-closed；阶段A禁止提前开放新PUBLIC域、真实Match成功链或伪造任何外部资格。

**可执行活动**：只在Owner实际指定的本地工程中，安全建立独立工作分支、修改APP/API/必要安全schema及其迁移**定义**、编写/运行自动化单元与隔离集成测试、进行本地工程自验与生成脱敏阶段证据；不在生产或真实个人数据上执行迁移。Codex日常任务拆分、依赖排序、提交组织由其自治，避免十次微审批。

**工作树身份先决条件**：历史S1审计唯一根为`D:\EliteSync-v10-product-v1015-20261101`，S1分支`codex/ui-current-state-audit-20261116`、HEAD`1d8b485bf4f314d42431bb62a293a3fef9e9c8af`是**以前的静态快照，不自动视为当前开发根/HEAD**。现有Codex必须先只读核对实际工程根、仓库身份、未提交变更与已有工作分支，确保不覆盖另一工作树`D:\EliteSync-v10`（历史main含大量未提交/未跟踪条目）。如工作树有冲突或不安全的未跟踪文件，停止危险操作并向Owner报告，不重置、清理或盲切换；允许在指定安全目录内由Codex自行建立隔离开发分支或独立worktree，但不得未经识别迁移其它脏工作树。

## 3. 阶段A禁止边界

- 不采购、联系、激活真实身份核验/Push/RTC供应商，不调用生产API、不传真实证件/用户隐私数据；身份`TEST_ONLY`始终不能替代生产合法凭据。
- 不运行生产/共享数据库迁移、不可逆批量数据清理或真实用户数据写操作；隔离临时测试数据库允许，但须确保非生产、无真实用户数据，确保可追溯。
- 不调用真机、模拟器或生产发布渠道；本阶段允许隔离单元/组件与本地集成测试，但**设备/模拟器联测另授权**。
- 不召开正式A6 UI会议，不合并main、不上线、不直接对外可用，不做NEW-PC-04/05新功能，也不提前变更阶段B/C的用户公开受众与真实对象删除。
- 不修改原`D:\EliteSync-v10`脏main工作树；不把GitHub治理分支作为本地实际开发分支或采用其作为已运行代码身份证据。
- 不输出密钥、真实用户资料、身份证、私聊或其它私密日志。GitHub可作为**脱敏备份/文档回读**，不是派单中心；本地Codex负责日常版本与状态，Owner终验。

## 4. 一次性启动与阶段性验收

下一步由网页GPT顾问在**本治理分支**准备[阶段A合并工程启动任务单](../versions/v2/V2_PHASE_A_SECURITY_BASELINE_CONSOLIDATED_EXECUTION_BRIEF_20261119.md)及[现有Codex会话启动Prompt](../workflow/V2_PHASE_A_CODEX_EXISTING_SESSION_KICKOFF_PROMPT_20261119.md)。顾问保存文档后由Owner转交**原有**本地Codex会话；网页GPT没有直接操作Windows Codex，不能声称已开始源码修复。

阶段A结果须按以下一包汇报：身份与当前实际工程分支/HEAD/工作树、实现范围与具名Owner合同索引、源码/迁移定义与版本diff、自动化测试的真实命令/结果/环境、正常与拒绝及UNKNOWN/旧版回流等反例、开放的外部/法律及设备证据、可回滚性/风险、后续阶段建议；结论区分`PASS/FAIL/PARTIAL/UNKNOWN/NOT_RUN`，不得将静态或test_only结果提升为生产准入。

完成阶段A后提交一次综合验收给Owner/网页顾问。阶段B–D按已接受的路线图保留计划，可在一次里程碑验收时决定转入，不要求每一个小功能都独立请Owner批准。任何真实外部依赖与正式发布仍须独立有证据与授权。

## 5. 未改变的历史状态

- S1-A `ACCEPTED_WITH_RESERVATIONS / CLOSED_AT_REPORT`，不能当作本轮新的工程证明。
- 当前阶段A新工程任务状态为`AUTHORIZED / HANDOFF_PENDING`，**尚无工程实现结果**；G01–G10新增动态历史`NOT_RUN`，待真实执行后按准确范围更新，不能预判全项PASS。
- 历史`10.1.18-dev / 1011804`、UI-AUDIT-01 `UNKNOWN/NOT_RUN`、真实核验与Push尚未集成、43原PNG `PENDING_BINARY_UPLOAD`、F-01 `READABILITY_PARTIAL`继续保留。
