# EliteSync V2｜Owner EDGE-D2 方案A：被隐藏评论的最小状态告知与有条件复核

日期：2026-11-19（Asia/Singapore）  
治理分支：`governance/home-matching-product-freeze-20261117`  
状态：`OWNER_EDGE_D2_OPTION_A_CONCEPT_ACCEPTED / IMPLEMENTATION_AND_REVIEW_MECHANISM_OPEN / DESIGN_ONLY / CODEX_NOT_AUTHORIZED / A6_MEETING_DEFERRED`

## 1. Owner具名选择与最新流程反馈

在[DESIGN-AUDIT-03](../workflow/V2_STATIC_COMMENT_EXCEPTION_AUDIT_03_20261119.md)中，顾问提出`EDGE-D2`：作品作者隐藏评论后，评论作者是否可以获知本人评论的展示状态，并在确有合法渠道时获取复核说明。方案A为“**最小状态告知 + 有条件复核**”，方案B为静默处理。随后顾问单独展示两方案，并明确说明推荐A，仅确认有条件的中性告知，不提前批准审核机构、时限、推送或实现。

Owner回复：

> 我认可**EDGE-D2方案A**，请继续。  
> 备注：请不要把门禁拆的太散，我们需要加快速度

因此两项需严格分别解释：
- `OWNER_CONFIRMED`：EDGE-D2方案A的**具名概念方向**已接受，接受范围见下文。
- `OWNER_PROCESS_FEEDBACK`：后续网页GPT顾问应**合并设计审阅批次、减少逐项询问和重复门禁**；此建议并不解除实际安全/合法前置条件，也不批准本地Codex、正式A6会议或工程实施。合并工作法具体边界另见[顾问合并审阅方案](../product/ELITESYNC_V2_CONSOLIDATED_DESIGN_REVIEW_AND_GATE_COMPACTION_V0_1_20261119.md)。

## 2. 方案A接受的最小产品语义

1. **不泄密的中性状态**：仅当评论作者仍有当前合法身份、可访问本人评论相关必要历史上下文，且告知本身不会暴露作品作者、Block/举报者、关系或其它敏感事实时，允许其在有权的本人评论历史或相应合法场景看到最小状态，例如“这条评论当前不在原作品中展示”。这只是候选文案，不预设存在评论历史界面。
2. **不揭示隐藏原因**：不因为状态文字提供“谁隐藏、为何隐藏、是否举报、Block身份”等未获当前合法授权的事实。即使匿名占位可用于推断私密关系，也应停止展示该占位并安全返回。
3. **复核有条件**：只有实际存在、合法且当前有权的请求/复核渠道，才能提供真实可达的入口或说明；不能凭产品原则伪造申诉工单、处理方、受理编号、处理期限或结果。既有安全与必要合法保留不因作品作者隐藏而自动清除。
4. **不强制主动Push**：没有规定必须向评论作者主动设备推送、主动站内通知或自动恢复展示。真实Push尚未接入，不可声称已投递。
5. **区别其它业务动作**：作品作者隐藏他人评论（NEW-PC-02）、评论作者撤回本人评论（NEW-PC-01）、父评论后的合法回复条件保留（EDGE-D1）和删除申请/受理/完成（NEW-PC-03/RET）分别记账；本次不会让被隐藏评论因查看状态而自动重显。
6. **当前权限与权威结果优先**：账号切换、Block、作品撤下、失权、UNKNOWN及历史深链继续遵守HIS/O09；没有合法上下文时必须安全不展示，结果不明时不能假定动作已完成或自动重发。

## 3. 未批准的精确功能（OPEN）

具体评论历史入口、状态枚举、可告知范围、匿名化效果、申诉对象/资格/处理机构、通知与复核状态流程、滥用处置、安全证据保存、跨账号/缓存、真实后台API、授权版本/回执及动态QA，仍`PRODUCT_DETAIL_OPEN / LEGAL_OR_EXTERNAL_FACT_OPEN / ENGINEERING_EVIDENCE_REQUIRED`。本次不确定“自动站内通知/Push”“申诉必受理”“恢复必成功”，也不设法定保存天数。

## 4. 相关Owner决策及停工状态

- [NEW-PC-01](OWNER_V2_NEW_PC01_COMMENT_AUTHOR_WITHDRAWAL_OPTION_A_DIRECTION_ACCEPTANCE_20261119.md)、[NEW-PC-02](OWNER_V2_NEW_PC02_AUTHOR_CONTROL_THIRD_PARTY_COMMENT_DISPLAY_DIRECTION_ACCEPTANCE_20261119.md)、[NEW-PC-03](OWNER_V2_NEW_PC03_INITIAL_OBJECT_LEVEL_DELETION_REQUEST_ENTRY_OPTION_A_ACCEPTANCE_20261119.md)、[EDGE-D1](OWNER_V2_EDGE_D1_CONDITIONAL_INDEPENDENT_REPLIES_AFTER_PARENT_HIDDEN_ACCEPTANCE_20261119.md)维持独立已确认概念方向；HIS-D1、RET-D1/D2、OBJ-D1及O09仍分别生效。
- `DESIGN_ONLY / CODEX_NOT_AUTHORIZED / A6_MEETING_DEFERRED`不变；本次不下达Codex新V2工程任务、不改读运行APP/API/Web/DB、不操作设备/模拟器/APK、不合main或发布、不接真实供应商。
- 原`10.1.18-dev / 1011804`与UI-AUDIT-01的`NOT_RUN/UNKNOWN`、G01–G10新动态`NOT_RUN`、F-01`READABILITY_PARTIAL`、实人核验/Push未接入及43份原PNG`PENDING_BINARY_UPLOAD`继续保留。治理文档不证明本地源码同步。
