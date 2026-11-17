# EliteSync-v10 CURRENT_WORKFLOW — 2026-11-17 产品设计状态

**当前模式：Owner与GPT顾问产品架构讨论；Codex未获新产品开发授权。**

## 一、权威与已存文件

1. **当前完整Owner决策入口**：[Owner下一代产品决策总冻结 V1.0](../decisions/OWNER_NEXTGEN_PRODUCT_DECISIONS_CONSOLIDATED_20261117.md)。
2. 首轮历史决定：[Home与Matching首轮冻结](../decisions/OWNER_HOME_MATCHING_PRODUCT_RULES_20261117.md)。
3. 端到端候选：[V2注册到聊天完整用户旅程 V0.1](../product/ELITESYNC_V2_REGISTER_TO_CHAT_USER_JOURNEY_DRAFT_20261117.md)，标记`ADVISOR_PROPOSAL / OWNER_REVIEW_PENDING`。
4. 固定1011804基线：[UI-AUDIT-01审计](ui-current-state-audit-20261116/UI_CURRENT_STATE_AUDIT.md)与[顾问审阅](ui-current-state-audit-20261116/ADVISOR_REVIEW_20261116.md)。36截图/16逻辑链/14问题，接受仅在具名审计范围内成立；NOT_RUN、UNKNOWN保持原记录。
5. v10.1.17、v10.1.18既有Owner接受记录继续有效；未合main，未发布。

## 二、当前讨论目标

依据`OWNER_CONFIRMED`冻结的Home、Matching、Me、Messages规则，逐段审阅完整用户旅程：
- 访客公开官方内容；
- 账号注册/登录；
- 首次可跳过Lifestyle；
- 登录后内容浏览、发布与评论；
- 用户主动进入匹配准备，补缺失Lifestyle与匹配资料；
- 真实身份核验（目前供应商未接入，不允许假成功）；
- 星盘可选自动计算，不作为Match门禁；
- 自主报名或独立自动参与授权；
- 匹配轮次/候选本人决定；
- 独立Connection、Messaging Consent后进入合法Conversation；
- 通知待处理优先，普通提醒按时间排列，通知回流二次权限验证。

用户操作减负不取消个人数据用途授权、展示受众、匹配/连接/消息/关系独立决定。Personal Data Hub、匹配页面五模块、Me具体布局、历史评论受众与通知细则仍为提案或OPEN；不能将建议写成Owner已确认。

## 三、工作流与技术限制

- Owner：最终产品方向、不可逆变化、版本实施、真实供应商及正式发布的authority。
- 本地Codex：正常有授权任务时的工程执行与自验；当前**停止产品实现**。
- 网页GPT顾问：战略、逻辑、设计讨论与独立审查；不作为本地日常消息总线。
- 此阶段只可提交经Owner要求的设计和治理文档；不修改APP/API/Web、数据库schema/业务数据、不运行设备/模拟器、不发起真实身份/Push服务、不合main、不构建发布。
- 不将远端治理文档分支视为已同步到Owner本地工程根；本地同步由Owner后续授权/安排。
- 完成V2正式合同和低分辨率构成主义+二次元设计稿后，再请求Owner明确授权Codex实施。不得提前拆工程任务。

## 四、长期业务边界

Match、Connection、Messaging Consent、Conversation、Relationship继续独立；Buddy与恋爱匹配独立。当前1011804没有完整`PUBLIC_AUTHENTICATED`用户作品或真实身份核验供应商能力。B4/阶段C/真实Push/正式内测与发布仍未授权。原测试缺口、动态盘失败层UNKNOWN及UI-AUDIT-01未验证链条保留。
