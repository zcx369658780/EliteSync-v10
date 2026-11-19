# EliteSync V2｜Owner HIS-D1/HIS-D2 历史评论与旧匹配快照权限决定

日期：2026-11-19（Asia/Singapore）  
状态：`OWNER_HIS_D1_A_HIS_D2_A_CONCEPT_ACCEPTED / HISTORY_RETENTION_AND_DELETE_OPEN / DESIGN_ONLY / CODEX_NOT_AUTHORIZED`  
治理分支：`governance/home-matching-product-freeze-20261117`

## 1. Owner明确接受的范围

网页GPT顾问在[HIS-D1/D2顾问方案V0.1](../product/ELITESYNC_V2_HISTORY_RESURFACING_AND_REVOKED_SNAPSHOTS_V0_1_20261119.md)中建议：
- **HIS-D1方案A**：作品受众先收窄再扩大，旧评论及附件重新可见必须同时满足当前作品读取权与旧评论原有历史受众/其它现行限制；不能可靠核实时隐藏；
- **HIS-D2方案A**：旧匹配形象快照在既有候选仍有权时沿用O05原合法版本；若发生Block、收窄受众或必要用途许可撤销导致失权，隐藏旧敏感快照；原业务入口仍合法且无泄密风险时可展示最小中性状态，否则隐藏入口并安全返回。

Owner明确回复：

> 我接受这两项，请保存到github后继续

据此两项**具名概念产品规则获Owner认可**。不据此推断数据已删除、真实跨设备瞬时清除、保留期限/审计例外已定或任何后端已实现。

## 2. HIS-D1方案A｜历史评论重现的合法条件

1. `FRIENDS → SELF → FRIENDS/PUBLIC_AUTHENTICATED`的受众改变需由作者分别明确确认；`SELF`生效时旧好友不能通过原评论、通知、缓存或媒体直链继续读取作品和受保护附件。
2. 作品重新开放后，**只有**同时满足当前作品正文阅读权限、历史评论原有阅读受众与任何仍适用的具名权限/Block/账号条件、原记录仍合法存在且允许阅读，才能显示该条评论、附件和引用。
3. **原来曾经是好友≠如今仍有权限**；作品升级为`PUBLIC_AUTHENTICATED`也不会自动使不属于原好友评论受众的登录用户看到旧评论。
4. 原评论的受众/版本事实若不能可靠重建，默认隐藏，而不是推断“既然作品公开，旧评论也公开”。作者亦无权替其他评论者扩大原有权限。
5. **显示与保存/删除是两种不同决定**：本条不要求永久保存评论，也不自动删除历史记录。保留期、删除请求、通知/分享/媒体缓存清理与任何法定例外仍OPEN。

## 3. HIS-D2方案A｜既有候选的旧快照与失权后最小状态

1. 仅发布新匹配形象V2：对过去已形成、现今仍合法有权的候选，默认维持对应合法有效的V1展示；不得自动把新V2送给旧候选。V1的实际保留/撤回期限仍另行确定。
2. Block、收窄受众、必要许可撤销或其它有效业务变化**确切导致旧候选失权**后，该候选不能继续读取V1敏感形象、相关媒体、缩略图、深链或旧缓存。
3. 只有原业务入口仍有当前合法访问权，且不会暴露私密关系或Block原因，才能用最小中性文案表达“相关资料当前不可查看”；如果连业务页也无权访问，隐藏受保护入口并安全返回。
4. **隐藏旧快照≠完成服务器删除**；不得承诺全部已同步清理或凭权限变化推断Connection、Messaging Consent、Conversation及Relationship已独立撤销。是否存在合法独立关系及用途仍各依其真实合同。
5. 权威业务状态UNKNOWN则安全占位/只读核验，不假装成功、不自动重放高影响操作；真实传播时限与缓存机制仍须未来工程核实。

## 4. 保留OPEN与接续

本次未确认：历史评论、旧匹配快照、派生结果、通知和反馈附件的具体存储期限、删除请求处理、合法留存/证据例外、对象拥有者与第三方权利、媒体URL签发/失效及可核验删除回执。有关交互建议另见[RET-D1/D2顾问V0.1](../product/ELITESYNC_V2_HISTORY_RETENTION_DELETION_PURPOSE_REVOCATION_V0_1_20261119.md)，不构成Owner已批准的下一轮决定。

继续`DESIGN_ONLY / CODEX_NOT_AUTHORIZED / A6_MEETING_DEFERRED`。不修改APP/API/Web/数据库、不运行设备/模拟器、不构建APK、不合main、不发布。真实身份核验供应商与真实Push未接入、1011804原NOT_RUN/UNKNOWN未变、43份PNG远端仍PENDING_BINARY_UPLOAD；GitHub治理分支文档不代表Owner本地项目已同步。
