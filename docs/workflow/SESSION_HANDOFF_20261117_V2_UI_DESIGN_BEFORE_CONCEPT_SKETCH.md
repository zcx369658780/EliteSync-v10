# EliteSync-v10 顾问会话交接｜V2产品规则冻结后，低保真设定图开工前

日期：2026-11-17（北京时间）  
会话状态：`HANDOFF_READY / PRODUCT_DECISIONS_FROZEN / UI_CONCEPT_DESIGN_NEXT / CODEX_NOT_AUTHORIZED`  
仓库：`zcx369658780/EliteSync-v10`  
当前治理分支：`governance/home-matching-product-freeze-20261117`  
上一设计起点提交：`4d327eb1903520ea0ac6ac8c0d127ecf2b080fa0`（此次交接前的原则冻结点）  
当前权威：下列决策与UI审计文件；本交接仅导航当前状态，不替代其完整内容。

## 1. 新会话首读（不递归历史）

从GitHub连接读取当前治理分支**最新HEAD**；优先只读以下文件，必要时扩展：

1. `AGENTS.md`：仅当前治理相关片段。
2. `docs/workflow/ACTIVE_STATE.md`：**只读顶部最新CURRENT ENTRY，遇历史快照/分隔线停止**。
3. `docs/workflow/CURRENT_WORKFLOW.md`：当前设计讨论/实施禁止边界。
4. `docs/decisions/OWNER_NEXTGEN_PRODUCT_DECISIONS_CONSOLIDATED_20261117.md`：Home/Matching/Me/Messages及UI-PRINCIPLE-01和UI-CONCEPT-01完整Owner决定，注意Owner确认与顾问建议区别。
5. `docs/decisions/OWNER_JOURNEY_INTERACTION_DECISIONS_20261117.md`：注册后一次可跳过探索及连续但独立的Connection与Messaging Consent。
6. `docs/product/ELITESYNC_V2_REGISTER_TO_CHAT_USER_JOURNEY_V0_2.md`：完整用户旅程、页面用途检查、D/I/N/A/W操作成本。
7. `docs/workflow/ui-current-state-audit-20261116/UI_CURRENT_STATE_AUDIT.md`：需要确认真实1011804页面/业务逻辑时才按相关章节读取；`SCREENSHOT_MANIFEST.json`及S01-S36截图按需查看。

完整新产品设计不需要重读旧版全部文档或各历史handoff；需要核实旧合同再按实际问题定向追读。

## 2. Authority与工作流

- Owner：用户本人，最终产品方向、重要不可逆、实机/服务、版本启动/交付、正式发布的authority。
- 本地Codex：在明确授权的任务中负责工程执行、自验与本地日常开发。**当前无产品实现授权，不要派单或要求启动Codex**。
- 网页GPT顾问：产品战略、逻辑与UI设计讨论、必要独立审阅。当前可根据Owner下一步请求制作低保真概念图，但不得将其解释为工程实施授权。
- GitHub作为已授权治理分支的文档及证据备份，不取代Owner本地工作树；不据此推断已同步到本地，也不写main。
- 本会话仅做了治理/产品设计文档写入；没有改变APP/API/Web、数据库schema或内容，未触碰Owner手机/模拟器。
- B4运行时AI、阶段C、真实实名供应商、真实Push、支付、内测、运营、main集成、正式发布仍未授权。

## 3. 1011804固定工程事实（不要说成V2目标已实现）

- v10.1.17及v10.1.18已经获得Owner具名范围的整版接受，原NOT_RUN/UNKNOWN保留。
- 固定审计候选：`10.1.18-dev / 1011804`，applicationId `com.elitesync.v1018dev`。
- 1011804产品源码提交：`1afa6940c37bc1b40aa3d05ea46fb47002f6455c`；固定工程交付：`0442335733555b38970131af7d5327a84e3dcb33`。
- APK SHA256：`eaacc050f7e6fae7bc980c6a766bf1a08ba1cb723bdad6571c821a72e552ba5a`。
- UI-AUDIT-01分支 `codex/ui-current-state-audit-20261116` 最终交付：`1d8b485bf4f314d42431bb62a293a3fef9e9c8af`。36张去敏720×1280模拟器截图，16条当前功能逻辑链，14项UI问题/建议；GPT顾问`ACCEPTED_IN_NAMED_SCOPE_WITH_RECORDED_LIMITS`。
- 当前APP Home主要是状态卡而非内容首页，社区发布表单先于浏览，匹配/Connection及正式关系页面技术术语多、私密/匹配/展示/出生资料分散、通知卡动作密集；部分表现需下一代重构。
- 当前后端用户作品只支持`SELF/FRIENDS`受众；未来`PUBLIC_AUTHENTICATED`用户作品和访客公开官方内容域属新增目标能力。
- **实人核验真实供应商尚未接入**，目标真实匹配门禁不能在1011804上假装可用。
- 动态星盘在审计中不可用，失败层UNKNOWN；新注册完整链、动态切题时序、部分写操作、真实Push/通知回流、系统级TalkBack等依历史报告继续NOT_RUN。

## 4. 最新Owner已确认的V2产品方向

### Home

- 四个一级入口：`首页 / 匹配 / 消息 / 我的`。
- Home双频道`精选 / 好友`，默认精选。精选有官方精选/专题以及**独立的用户公开作品区域**。
- 官方公开精选/专题正文允许未登录访客只读；用户公开作品**仅有效已登录账号**可见；好友动态只在现有SELF/FRIENDS/好友+Block权限内读。
- 访客在APP所有位置都不能提交留言、评论、点赞、收藏、举报、反馈或其他互动。
- 官方专题采用平台问题引导的B类讨论；普通精选点赞/收藏，指定专题按类型开放评论。
- 用户新作品默认仅好友；作者可选SELF/FRIENDS/站内登录公开，并独立设置评论所有合格用户/仅好友/关闭。具体评论默认值仍OPEN。
- 公开作品或评论不建立全局公开用户Profile，也不授予好友、Connection、消息许可或私聊。

### Matching

- 注册阶段Lifestyle可跳过；正式真实匹配参与之前**必须完成五场景Lifestyle**。
- 正式真实匹配参与之前**必须通过真实实人核验**；供应商尚未接入时不得显示成功或绕过门禁。
- 一次性报名只作用于当前指定轮次；持续自动参与**独立授权，默认OFF**，可暂停/恢复/撤销；不自动接受候选。
- MBTI独立可选，不能替代Lifestyle。星盘有充分资料及用途授权时自动计算，但不作为Match资格门槛；缺出生时刻/地点不推测。
- 提案接受、Connection、Messaging Consent、Conversation、Relationship保持独立，双方分别作出自己的决定。

### Me

- 顶部以个人资料卡为主；MBTI/星盘/八字/紫微统一归入自我探索中心；好友/Buddy统一归于社交与内容的导航分组，业务独立。
- 社交形象、匹配形象默认复用主头像/昵称，各自展示权限独立、支持单独覆盖。
- 更新主头像/主昵称自动更新使用默认值的**本人个人预览**；对外匹配展示仍遵守既有有效受众、发布版本及必要发布确认，不自动扩大公开。
- Personal Data Hub及具体Me四/五区卡片布局为顾问方案，尚非Owner批准的数据库模型或固定UI结构。

### Messages

- `聊天 / 通知`双频道，默认聊天；二者未读**独立计数**。
- 通知**当前有效待处理事项优先**，普通通知按时间排列；已读与待办不是同一状态。
- 通知只是业务入口，点击后重验当前受众和许可，不代替用户执行匹配、好友或Buddy决定；真实Push未接入。

### 完整旅程两项Owner确认

- **注册成功后自动展示一次可跳过的Lifestyle欢迎页**；跳过可正常浏览允许内容，后续真实Match前须补完。
- **从匹配提案到Connection再到Messaging Consent的体验连续引导**，但各阶段仍由双方在有效业务上下文中**分别明确决定**；双方许可生效后才能进入Conversation。

## 5. 用户体验最高优先级

Owner原话：“用户能够第一时间明白页面的用途，并且用最少的操作完成所需目标。”

- **一眼看懂页面目的 → 立即看到合法主操作 → 最少导航/重复输入 → 必需授权保持独立**。
- 用户可见UI避免长篇AI/工程文案、内部UUID、revision、CN_ACTIVE、MC_ACTIVE等。
- 最小化不必要点击/跨页，不能删真实核验、提案决定、连接/消息许可、公开授权等必要动作。
- 未来操作成本用`D`必要业务决定、`I`用户输入、`N`无谓导航、`A`自动工作、`W`外部等待分别评估；V0.2所述四项是具名理想场景本人核心决定，**不是注册到聊天全部只需四次点击**，也不是1011804实测成绩。
- 首屏文字对比、字号、选中态、底部安全区和减少动态效果必须被设计时考虑。

## 6. 首批视觉设定任务——Owner已认可优先顺序

**下一会话第一项产品工作**：制作并讨论三张**低分辨率、低保真构成主义+二次元卡通设定图**，而非高保真写实iOS/玻璃拟态成品图：

1. 首次Lifestyle探索：场景插画、可跳过、清晰选择、选中态文字可读。
2. 内容首页：首页以精选/好友及官方专题、登录后用户公开作品为主，匹配辅助入口降权。
3. 匹配准备：用视觉化缺失事项和一个明确主操作代替长表单；身份供应商未接入的状态真实呈现。

建议先以同一套构成主义几何色块、低刺激配色、动画风角色/场景统一三张画面。Owner过去希望有“水中倒影/进入页面幻化重组”感，可作为**非写实的几何转场**方向后续研究，不能重新使用写实水光和玻璃拟态。**这三页具体方案尚未生成或批准**。如果新会话用户明确要求开始出图，可直接使用图像生成，不必再重复询问已决定事项。

建议设定图配短说明：一眼用途、主操作、次操作、需要/复用数据、权限边界、返回和错误状态。

## 7. 尚未决策与实施边界

继续OPEN：
- 用户新作品评论策略默认值、历史FRIENDS评论扩公开时是否跟随。
- 官方编辑/审核/内容复核，访客是否可以**阅读**官方专题评论（不能提交已确定）。
- 身份供应商/核验字段/重试及申诉；Personal Data Hub数据归属与schema。
- 匹配首页具体模块布局，Me详细卡片布局、通知标读时机与普通通知合并规则。
- 首次欢迎“仅一次”的账号跨设备记录策略、具体动效和QA门槛。
- 图片素材、配色、字体与最终UI布局，非写实水中倒影转场是否实际应用。
- 当前1011804动态盘失败层UNKNOWN，Owner原手机Buddy确切原因UNKNOWN；历史NOT_RUN仍未变成PASS。

**此次交接不是开发授权**。不要交给Codex任务单，不修改产品代码、不构建APK、不合main、不发布。GitHub治理分支不等于Owner本地已同步。

## 8. 交接Prompt（可复制）

> 请接续EliteSync-v10重置项目的网页GPT产品顾问会话。上一会话因长期产品设计讨论已交接，Owner已要求将当前结论保存至GitHub。请先从`zcx369658780/EliteSync-v10`治理分支`governance/home-matching-product-freeze-20261117`最新HEAD读取`AGENTS.md`当前治理片段、`docs/workflow/ACTIVE_STATE.md`顶部当前入口、`docs/workflow/CURRENT_WORKFLOW.md`、`docs/decisions/OWNER_NEXTGEN_PRODUCT_DECISIONS_CONSOLIDATED_20261117.md`、`docs/decisions/OWNER_JOURNEY_INTERACTION_DECISIONS_20261117.md`、`docs/product/ELITESYNC_V2_REGISTER_TO_CHAT_USER_JOURNEY_V0_2.md`以及本交接文件，必要时按需读取UI-AUDIT-01审计和截图，不递归旧handoff。尊重Owner确认/顾问建议/未决事项的区分。现处于产品设计阶段，无Codex实施授权，不改APP/API/DB、不运行模拟器、不合main、不发布。下一阶段请从首次Lifestyle探索、内容首页、匹配准备三个页面的**低分辨率构成主义+二次元卡通低保真设定图**入手，并依据“第一眼看懂用途、最少操作完成目标”逐个讨论，禁止以写实水面、玻璃拟态或高保真商业成品图替代。保持首页内容权限、匹配门禁、独立Connection/Messaging Consent及Me形象受众的已冻结规则。完成讨论后再决定是否进入其他页面，未经Owner授权不派Codex开发任务。
