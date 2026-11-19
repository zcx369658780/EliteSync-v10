# EliteSync V2｜Owner CMT-T1 方案A：SELF→FRIENDS评论策略切换

日期：2026-11-19（Asia/Singapore）  
治理分支：`governance/home-matching-product-freeze-20261117`  
状态：`OWNER_CMT_T1_OPTION_A_CONCEPT_ACCEPTED / TRANSITION_IMPLEMENTATION_OPEN / DESIGN_ONLY / CODEX_NOT_AUTHORIZED`

## 1. Owner明确接受

网页GPT顾问展示[SELF / FRIENDS作品受众与评论权限联动V0.1](../product/ELITESYNC_V2_SELF_FRIENDS_COMMENT_AUDIENCE_TRANSITIONS_V0_1_20261119.md)，单独询问CMT-T1推荐方案A：作者主动将SELF作品改为FRIENDS，若先前OFF仅来自SELF系统默认且作者未明确关闭评论，则在发布前可见性摘要**明确推荐并展示FRIENDS_ONLY**，由作者确认；若作者曾显式OFF则保留；无法区分则保守保留OFF并提示作者可手动开启好友评论。

Owner明确回复：

> 我认可**CMT-T1**  方案A，请继续

因此**CMT-T1方案A在上述具名范围获Owner概念认可**。它不是允许跨过受众授权静默开放他人阅读或评论，也不是现有后端已经有“隐式/显式OFF”标记的实现证明。

## 2. CMT-T1 具体规则

- **作品正文阅读权始终优先**：`SELF`只有本人可读；`FRIENDS`是本人和当前仍有权好友可读。只有作者明确确认`SELF→FRIENDS`这一作品受众扩大后，才可能合法让好友查看/评论。
- `SELF`下评论默认`OFF`只针对仅自己可见作品。普通新作品默认仍为`FRIENDS + FRIENDS_ONLY`，有权好友可以评论，陌生人默认不能评论；不得改成全局默认OFF。
- 从SELF主动改为FRIENDS时，如果`OFF`仅是系统SELF隐式默认，**且作者未曾显式关闭评论**：发布前两行简洁影响摘要显示“作品好友可见、评论推荐仅好友”，`FRIENDS_ONLY`可作为建议设置，由作者明确确认本次受众与将采用的评论设置；不得未告知就拓展评论受众。
- 作者此前**主动明确选择OFF**时必须尊重这一选择，保持`OFF`；可在摘要中提示“好友能看但暂不能评论，可主动开启仅好友评论”，不替作者取消OFF。
- 若未来实际数据/服务无法判别OFF是隐式默认还是用户明确关闭，**fail-closed**：维持`OFF`并提示由作者主动开启`FRIENDS_ONLY`，不得猜测或静默覆盖。
- 当前身份、作品版本、受众、双向好友/Block及服务端读写门禁持续有效；不是“好友即必定可评论”，无正文阅读权者不能评论；访客不可读用户作品或互动。
- 写入结果`UNKNOWN`先只读查询权威状态，不自动重发或假成功；受众变化前按S15-D1向作者显示影响并明确确认。

## 3. 不因本决定自动确定的细则（OPEN）

- `FRIENDS→SELF→FRIENDS`反复切换后，历史评论及附件/引用在当前好友关系变化时能否重新展示，以及原评论作者的合法阅读范围如何绑定；
- `OFF`隐式默认/显式选择的实际记录、迁移、版本冲突及旧客户端兼容；当前不指定数据库新列或后端enum；
- `SELF`下本人自评、笔记与评论区域UI是否单独设计；
- 评论历史删除/合法留存期限、缓存/媒体链接、安全证据与第三方参与者许可；
- 真实APP、服务端数据门禁和跨设备回流能力尚未验证，不能凭概念接受标PASS。

## 4. 后续与停工边界

下一步网页GPT顾问可提出[历史评论、旧发布快照与用途撤回的权限收束草案](../product/ELITESYNC_V2_HISTORY_RESURFACING_AND_REVOKED_SNAPSHOTS_V0_1_20261119.md)，该草案为`ADVISOR_PROPOSAL / OWNER_REVIEW_PENDING`，新条款不因为CMT-T1接受而自动获批。

`DESIGN_ONLY / CODEX_NOT_AUTHORIZED / A6_MEETING_DEFERRED`继续有效：不改APP/API/Web/数据库、不运行设备或模拟器、不构建APK、不合main、不发布，不接入真实供应商。旧`10.1.18-dev / 1011804`的NOT_RUN/UNKNOWN不改判，真实身份核验与真实Push未接入，43份原PNG远端仍PENDING_BINARY_UPLOAD。
