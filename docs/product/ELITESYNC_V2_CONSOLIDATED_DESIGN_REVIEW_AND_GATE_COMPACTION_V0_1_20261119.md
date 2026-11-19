# EliteSync V2｜评论/内容治理概念收口与顾问审阅门禁合并 V0.1

日期：2026-11-19（Asia/Singapore）  
状态：`ADVISOR_CONSOLIDATION / REVIEW_CADENCE_OWNER_FEEDBACK / NO_BULK_OWNER_APPROVAL / DESIGN_ONLY / CODEX_NOT_AUTHORIZED / A6_MEETING_DEFERRED`  
目标：遵照Owner“**不要把门禁拆的太散，我们需要加快速度**”的明确流程反馈，在网页顾问的设计阶段减少“一个例外→一份审批→下一例外”的重复节奏。**合并审阅批次不合并独立用户决定、合法权限、工程证据或Owner最终权威。**

## 1. 本轮概念决定已经足够，停止逐个重复提问

| 已接受的具名规则 | 只冻结确切已接受范围 | 未来仍需证据/细节 |
|---|---|---|
| [NEW-PC-01](../decisions/OWNER_V2_NEW_PC01_COMMENT_AUTHOR_WITHDRAWAL_OPTION_A_DIRECTION_ACCEPTANCE_20261119.md) | 评论作者撤回本人评论当前对外展示；不自动删除原件/他人回复 | 恢复、旧媒体、幂等与申诉 |
| [NEW-PC-02](../decisions/OWNER_V2_NEW_PC02_AUTHOR_CONTROL_THIRD_PARTY_COMMENT_DISPLAY_DIRECTION_ACCEPTANCE_20261119.md) | 作品作者管理本人作品中第三方评论展示；无第三方原件删除权 | 管理权限边界、冲突、反滥用 |
| [NEW-PC-03](../decisions/OWNER_V2_NEW_PC03_INITIAL_OBJECT_LEVEL_DELETION_REQUEST_ENTRY_OPTION_A_ACCEPTANCE_20261119.md) | 首期优先规划本人作品/本人评论对象级删除请求入口；受理/完成依真实结果 | 法域、期限、请求API、副本和账号级权利 |
| [EDGE-D1](../decisions/OWNER_V2_EDGE_D1_CONDITIONAL_INDEPENDENT_REPLIES_AFTER_PARENT_HIDDEN_ACCEPTANCE_20261119.md) | 父评论失去展示资格后，第三方独立回复可在自身有权且无泄密时继续展示；否则折叠 | 复杂多层树、引用与历史受众实现 |
| [EDGE-D2](../decisions/OWNER_V2_EDGE_D2_MINIMAL_COMMENT_STATUS_AND_REVIEW_OPTION_A_ACCEPTANCE_20261119.md) | 有权且不泄密时评论者可见最小中性状态，复核仅在真合法渠道存在时可达；不强制Push | 申诉处理主体、通知、后台真实接口 |

继续遵守CMT-T1、HIS-D1/D2、OBJ-D1、RET-D1/D2、O06/O08/O09、S15等独立Owner原规则；不将本表、顾问草案或流程节奏反馈当成“整包Owner批准”。当前**评论/删除核心产品方向概念已收口**，但完整可执行产品合同、工程和法规证据没有关闭。

## 2. 与DESIGN-AUDIT-03十二个异常场景的批量处理

按[第三轮静态审阅](../workflow/V2_STATIC_COMMENT_EXCEPTION_AUDIT_03_20261119.md)中的EX-01–EX-12合并为三种处理层：

### A：已具名确定的安全下限（不用再次逐项请Owner决定）

- EX-01/02：EDGE-D1有条件保留回复，无法确认独立合法读权或无泄密保证就折叠；不因此物理删除原件。
- EX-03/04：评论作者撤回与作品作者隐藏独立生效；其中一方解除自身限制不自动恢复另一方已撤回的内容。
- EX-05/07：历史评论/回复读权交集；切号、Block、旧缓存/深链不能反向授权。
- EX-08/09：展示撤回、对象级删除请求受理、指定范围删除完成及第三方权利分开。
- EX-10/11：合法必要安全记录不因展示控制自动消失；高影响UNKNOWN先有权只读查权威结果，不能自动重放。
- EX-06的最低要求：旧通知/媒体/引用不能泄密；中性状态须以EDGE-D2的合法条件为前提，不暗示主动推送。

这些为已有Owner原则的**组合解释**，并非宣称完整12项操作都已经过运行时审计或具备新UI。

### B：可由顾问合并出稿的精确UX候选（不拆成十余个新Owner门禁）

以下统一放进**下一份合并设计规格草案**，而非每项单独送Owner签字：
1. 作品作者隐藏、评论者撤回、两者并存或恢复时的状态与返回路径；
2. 旧通知/引用/媒体预览、父评论和独立回复的中性文案与折叠布局；
3. 评论者自身历史页的状态说明、存在合法复核渠道时如何展示；
4. 删除请求不可用、受理UNKNOWN、完成范围不明时的可理解文本；
5. 字体放大/读屏/离线/Back、低密度交互与安全空态的目标规则。

这些仍`ADVISOR_PROPOSAL / PRECISE_UI_OPEN`，可在一轮**合并审阅**中提交Owner；在Owner确认前不能默认为新业务权利、运营流程或已实现。

### C：按证据类型保留，不再向Owner要求“概念同意”来解锁

- `LEGAL_OR_EXTERNAL_FACT_OPEN`：第三方原件/附件权利、必要保留、真实复核渠道、法域与合同、真实Push/核验供应商。
- `ENGINEERING_EVIDENCE_REQUIRED`：实际评论树/原受众记录、缓存/媒体签名、权限/Block与设备传播、受理/删除API、请求幂等、可核验回执和本地工作树身份。
- `ASSET_PENDING / RUNTIME_NOT_RUN`：43份原始PNG的真实远端二进制、旧UI-AUDIT-01 UNKNOWN/NOT_RUN、G01–G10新增动态全部NOT_RUN。

外部证据或工程授权的缺失不能因“加快速度”直接变成PASS，也不允许用模拟回执声称真实核验。

## 3. 后续一次性交付的顾问批次（建议，不是新工程计划）

| 批次 | 网页GPT可自行推进的静态设计工作 | 对Owner只收集什么 | 非本次授权 |
|---|---|---|---|
| **BATCH-CONTENT** 当前收束 | 整合NEW-PC-01/02/03、EDGE-D1/D2、12异常安全默认、未来缺证据清单；产出一份合并UX状态矩阵和有限文案候选 | 仅对超出现有Owner原则的**实质产品权利取舍**，集中一次审阅；一般文案/布局不反复审批 | 不得因此认定任何评论/删除接口已实现 |
| **BATCH-OTHER-DESIGN** 后续顾问阶段 | 同一份交付覆盖首页/资料授权/匹配与通知剩余静态OPEN，继续沿用已接受S01–S16、O04/O05/O07等 | 若有真正新增跨域产品范围取舍，按一个集中短表给Owner选择；没有则只报告收束与证据缺口 | 不启动正式A6会议、不重复冻结全部16屏 |
| **EVIDENCE-HANDOFF** 等未来条件 | 将真实供应商/法域/源码/设备/资产缺口聚为可审阅一份门禁表和候选证据清单 | Owner未来明确决定是否分别授权供应商选择、工程读取/实施、A6会议与发布等不同权限 | **现阶段不下Codex任务、不运行测试、不合main、不发布** |

**加速准则**：
- 已批准规则不重复审；同类异常合成一张矩阵、一轮报告。
- 安全默认能由既有规则推出的，顾问直接写入有来源的静态文档，不反复征询。
- 真正新增用户权利、跨用途授权、数据外传/永久删除合同、付费供应商、工程/正式会议/发布仍保留Owner独立决定；允许在**一条消息中并列提出几个清楚的独立选择**，但不得“整包默认批准”或把不同用户授权合并。
- 法律与运行时事实不能由产品文字代替；没有证据就`OPEN/UNKNOWN/NOT_RUN`。
- 路线分批与本文件中的UX建议都是`ADVISOR_PROPOSAL`；Owner本轮确认的是**减少碎片化审批的工作方式诉求**，非逐项批准所有未来草案。

## 4. 当前总结和剩余少量Owner决策

- `OWNER_CONFIRMED`：NEW-PC-01/02/03、EDGE-D1/D2的上述具名方向。
- `ADVISOR_PROPOSAL / OPEN`：详细恢复、评论历史/引用、申诉与通知状态、对象级删除界面与账户级范围、内容相关精确布局/文案。
- `DEFERRED`（顾问建议）：NEW-PC-04向既有候选主动发布新匹配形象、NEW-PC-05正式官方转载纳入首期。沿用已接受O05-X A与O11安全默认，不申请本轮新的Owner选择。
- `NOT_AUTHORIZED / NOT_RUN`：Codex V2工程、A6正式UI会议、真实Push/核验供应商、动态G01–G10、API/DB、原43 PNG远端真实性核查。

本轮最有效的下一动作不是再做EDGE-D3/D4逐项审批，而是由网页GPT**自主完成BATCH-CONTENT合并精确UX静态稿**，将无法从已接受规则推导的少量实质权利问题集中呈现；不触发工程。顾问批次不是新技术/数据/发布授权。

**停止：`DESIGN_ONLY / CODEX_NOT_AUTHORIZED / A6_MEETING_DEFERRED`。**
