# EliteSync V2｜Owner EDGE-D1 方案A：父评论撤回/隐藏后的独立回复有条件保留

日期：2026-11-19（Asia/Singapore）  
治理分支：`governance/home-matching-product-freeze-20261117`  
状态：`OWNER_EDGE_D1_OPTION_A_CONCEPT_ACCEPTED / PRECISE_REPLY_TREE_DETAILS_OPEN / ALL_RUNTIME_QA_NOT_RUN / DESIGN_ONLY / CODEX_NOT_AUTHORIZED / A6_MEETING_DEFERRED`

## 1. Owner具名接受与范围

网页GPT顾问基于[DESIGN-AUDIT-03](../workflow/V2_STATIC_COMMENT_EXCEPTION_AUDIT_03_20261119.md)12项异常场景静态审阅，单独呈交`EDGE-D1`父评论撤回或被作品作者隐藏后，第三方独立回复是否继续展示的两种方案。方案A（推荐）为“**有条件保留**”：仅在父评论上下文不会泄密、作品与回复均有当前合法阅读权、回复自身原受众/其它条件有效且可独立阅读时，用不暴露父评论内容、身份、原因的中性结构占位保留合法独立回复；如无法核实则保守折叠/隐藏受影响讨论分支，但不删除回复原始数据。方案B为严格整体折叠。

Owner随后明确回复：

> 好的我选**EDGE-D1方案A**

本决定只确认**上述展示原则的概念方向**。不是对DESIGN-AUDIT-03整篇、EDGE-D2、具体UI样式或现有运行时行为的一揽子批准。

## 2. OWNER_CONFIRMED：有条件保留回复的最小合同

1. **前提**：父评论被评论作者主动撤回（NEW-PC-01）或被作品作者从自己作品中隐藏（NEW-PC-02）时，父评论受保护正文、媒体、可识别身份及隐藏原因不得因回复、引用、通知或中性占位被间接外显。
2. **独立回复**：其他用户合法发表的回复不因父评论展示变化而自动丧失原始数据权利或被物理删除。若当前作品读权、该回复自身原有受众、Block/账号/其它现行条件、回复仍有效，以及上下文安全性**同时可核实**，可以保持其作品内合法展示。
3. **中性占位**：为维持回复树可读性，可在不暴露父评论内容、作者、撤回/隐藏原因、隐藏主体或其它敏感关系的前提下使用中性结构提示；该提示本身也必须通过“不泄密”约束，并非强制显示。
4. **fail-closed**：任何必要权限或上下文不可核实、回复文本或引用本身会泄漏不允许展示的父评论信息时，先折叠/隐藏受影响讨论分支的作品内展示，**不**因此删除第三方回复原始记录或合法独立安全/申诉材料。
5. **权限不会自动扩大**：作品日后重新开放、父评论重新获得显示资格或用户重新成为好友，并不自动赋予历史回复新的阅读受众；必须重新核对当前作品读权与回复原受众、Block及其它有效条件。
6. **权威结果与UNKNOWN**：实际隐藏/撤回状态、受众与可读版本须以有效权威事实为准。写入结果UNKNOWN时先按O09有权只读核查，不能自动重放高影响操作、假成功或借旧缓存复活受限讨论。

## 3. 明确保留的OPEN（非本次批准）

- 具体评论树/多层嵌套折叠规则、占位精确文案、回复与引用断链策略、翻页排序/历史/通知的布局；
- 回复是否可以在别处独立查看、父评论恢复后如何重新关联、不同主体先后隐藏/撤回的版本冲突及恢复操作；
- 作者隐藏原因对哪些角色可见、评论者通知/申诉的渠道与状态，即独立`EDGE-D2`；它仍`ADVISOR_PROPOSAL / OWNER_REVIEW_PENDING`；
- 真实评论/媒体/通知受众、持久化与合法保留、第三方权利的适用法律、服务端权威查询/幂等、跨设备缓存和动态QA证据；
- 任何数据库字段、enum、API、真实编辑/安全审核系统或运行时PASS。

## 4. 与已确认规则一致性

保留[NEW-PC-01](OWNER_V2_NEW_PC01_COMMENT_AUTHOR_WITHDRAWAL_OPTION_A_DIRECTION_ACCEPTANCE_20261119.md)评论作者撤回本人评论展示、[NEW-PC-02](OWNER_V2_NEW_PC02_AUTHOR_CONTROL_THIRD_PARTY_COMMENT_DISPLAY_DIRECTION_ACCEPTANCE_20261119.md)作品作者隐藏第三方评论、[HIS-D1/D2](OWNER_V2_HIS_D1_D2_HISTORICAL_ACCESS_AND_SNAPSHOTS_20261119.md)原受众与现权交集、[OBJ-D1](OWNER_V2_OBJ_D1_POST_TAKEDOWN_THIRD_PARTY_COMMENTS_ACCEPTANCE_20261119.md)作者撤下作品不代第三方永久删除、[RET-D1/D2](OWNER_V2_RET_D1_D2_REVOCATION_DELETION_CONCEPT_ACCEPTANCE_20261119.md)撤权/删除受理/完成分离和[O09](OWNER_V2_O09_CROSS_DEVICE_AUTH_UNKNOWN_ACCEPTANCE_20261119.md)UNKNOWN门禁。不能把“可能继续显示合法独立回复”解释为允许泄密或自动授予新的评论许可。

## 5. 授权与风险保持

本次没有Codex工程审核/开发授权或A6正式UI会议授权：`DESIGN_ONLY / CODEX_NOT_AUTHORIZED / A6_MEETING_DEFERRED`。不读改APP/API/Web/DB，不运行设备/模拟器/APK，不合main、不发布、不接真实供应商。

DESIGN-AUDIT-01/02的静态部分结论不改判，DESIGN-AUDIT-03仍仅`SCOPED_STATIC_REVIEW_COMPLETE`；F-01`READABILITY_PARTIAL`、G01–G10新增运行时全部`NOT_RUN`、历史`10.1.18-dev / 1011804`及UI-AUDIT-01的`UNKNOWN/NOT_RUN`、真实身份核验/Push未接入与43原PNG `PENDING_BINARY_UPLOAD`均不变。治理分支不证明Owner本地工程树同步。
