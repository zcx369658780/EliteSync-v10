# EliteSync-v10 当前工作流

更新：2026-11-17。当前处于产品架构设计讨论阶段，不是Codex实施阶段。

## 当前权威产品决策

Owner已冻结截至2026-11-17的Home与Matching规则，详见：
[Owner产品设计冻结记录](../decisions/OWNER_HOME_MATCHING_PRODUCT_RULES_20261117.md)。

该文件区分`OWNER_CONFIRMED`、`ADVISOR_PROPOSAL`、`OPEN`和`EXISTING_BASELINE`，是本轮后续「我的」页面讨论的产品设计基线。旧版已接受文件保留为历史权威，不被静默覆盖；未来完整V2架构合同应显式处理与旧Home/Discover目标的差异。

## UI-AUDIT-01审计结果

UI-AUDIT-01已完成并获GPT顾问具名范围接受：`ACCEPTED_IN_NAMED_SCOPE_WITH_RECORDED_LIMITS`。

- 固定候选：`10.1.18-dev / 1011804`，包名`com.elitesync.v1018dev`，源码`1afa6940c37bc1b40aa3d05ea46fb47002f6455c`，工程交付`0442335733555b38970131af7d5327a84e3dcb33`。
- 审计最终提交：`1d8b485bf4f314d42431bb62a293a3fef9e9c8af`。
- 证据：36张去敏模拟器截图、16条主要功能逻辑链、14项UI/交互问题。
- [审计报告](ui-current-state-audit-20261116/UI_CURRENT_STATE_AUDIT.md) · [截图manifest](ui-current-state-audit-20261116/SCREENSHOT_MANIFEST.json) · [顾问独立审阅](ui-current-state-audit-20261116/ADVISOR_REVIEW_20261116.md)。

审计建立的是事实基线，不是全部业务功能的端到端验收。所有NOT_RUN、UNKNOWN和NOT_TRACED继续保留。

## 当前讨论主题：我的 Me 页面

下一步与Owner讨论：
1. 个人资料如何分组：私密身份、出生资料、匹配输入、展示资料；
2. Lifestyle与MBTI如何展示和修改；
3. 星盘、八字、紫微等特色工具如何组织；
4. 好友与Buddy如何归属；
5. 隐私、身份核验、授权和自动化如何组织；
6. 通知、账号及安全设置如何归属；
7. 哪些字段可复用，哪些需要独立用途授权。

Personal Data Hub目前是顾问提出的概念方案，尚未被Owner确认为最终数据架构；讨论Me页面时需要进一步确认。用户资料页面不能把私密身份、匹配输入和对外展示合并成一个无差别的公开Profile。

## 设计与实施门禁

- 视觉方向：构成主义为主的二次元卡通画风。
- 讨论图：低分辨率设定图/低保真方向稿优先。
- 首页和匹配规则按Owner冻结记录保留；尚未明确的评论默认值、历史评论可见性、身份供应商、具体资料模型等仍为OPEN。
- 四个一级入口和核心旅程讨论完成后，再形成完整V2产品架构合同和设计样例。
- **当前不创建Codex实现任务，不修改产品代码、API/Web、数据库schema或业务数据。**
- 未获得Owner单独授权前，不启动全局UI重构、B4、阶段C、main集成、正式发布或真实运营。

## 持续有效的产品与权限边界

Match、Connection、Messaging Consent、Conversation、Relationship保持独立；Buddy独立于恋爱匹配。减少操作步骤不等于自动分享资料、自动接受候选、自动授予消息同意或自动确立正式关系。真实身份供应商、真实Push、支付、生产数据、main集成、正式发布和真实运营仍需独立授权。历史UNKNOWN、NOT_RUN、FAIL与已接受范围不因本次设计冻结而改写。

Owner负责产品方向和保留决定；本地Codex负责日常执行；网页GPT顾问负责战略讨论及按Owner要求审阅成果。
