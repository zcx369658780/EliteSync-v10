# 当前入口 2026-11-17：四一级入口Owner决策已汇总，注册到聊天的端到端旅程进入设计审阅

**`NEXTGEN_OWNER_DECISIONS_CONSOLIDATED / REGISTER_TO_CHAT_DRAFT_FOR_OWNER / DESIGN_ONLY / CODEX_NOT_AUTHORIZED`**

## 1. 当前权威文件

- [Owner下一代产品决策总冻结 V1.0](../decisions/OWNER_NEXTGEN_PRODUCT_DECISIONS_CONSOLIDATED_20261117.md)：覆盖Home/Matching/Me/Messages、社交内容权限、实名门槛、星盘非硬门槛、个人形象及通知待办优先；区分Owner确认、既有合同、顾问建议和OPEN。
- [Home与Matching首轮冻结](../decisions/OWNER_HOME_MATCHING_PRODUCT_RULES_20261117.md)：保留为历史冻结首版。
- [注册到聊天完整旅程草案 V0.1](../product/ELITESYNC_V2_REGISTER_TO_CHAT_USER_JOURNEY_DRAFT_20261117.md)：顾问方案，尚待Owner逐段审阅与批准。
- [UI-AUDIT-01现场审计](ui-current-state-audit-20261116/UI_CURRENT_STATE_AUDIT.md)与[顾问复核](ui-current-state-audit-20261116/ADVISOR_REVIEW_20261116.md)：基线`10.1.18-dev / 1011804`，36张去敏截图、16条现有逻辑链、14项问题。审计已获顾问具名范围接受，原NOT_RUN/UNKNOWN继续保留。

## 2. 最新Owner确认点

- Home：「精选/好友」双频道；官方精选访客可读、用户公开作品仅有效登录用户可读；新作品默认FRIENDS，作者选择评论范围；访客在任何地方不提交互动/反馈。
- Matching：注册可跳过Lifestyle但真实匹配前必须完成；正式真实匹配必须实人核验；星盘授权且资料充足时自动生成、非Match硬门槛；普通报名与持续参与独立授权。
- Me：顶部个人资料卡；MBTI与星盘/八字/紫微归于统一自我探索；好友与Buddy在社交与内容分组但业务独立。社交/匹配形象默认复用主头像昵称、独立可覆盖与授权；主形象变化自动更新本人默认预览，对外匹配展示仍由原发布版本/受众决定。
- Messages：聊天与通知双频道，默认聊天，未读独立计算；**当前有效待处理事项优先、普通通知按时间排列**。
- 视觉：构成主义为主的二次元卡通，低分辨率低保真设定稿优先，非写实的水中倒影/几何重组转场作为待设计概念。

## 3. 当前工作与严格边界

- Owner已请求统一设计`注册 → Lifestyle → 内容社区 → 用户主动匹配 → 实人及资料准备 → 报名 → 本轮提案 → Connection → Messaging Consent → Conversation`的未来流程。
- 旅程文件仅为`ADVISOR_PROPOSAL`，包括未决门禁UI、数据复用/授权细节、返回路径、异常处理和待审问题；不能被当作当前1011804已经跑通的能力。
- 当前没有授权Codex开发任务，不运行模拟器、不改APP/API/Web、schema/数据、不构建APK、不合main、不发布；B4与阶段C、真实身份供应商、真实Push均未授权。
- Owner/顾问当前专注产品逻辑与低保真设计，未来形成V2正式合同后再由Owner另行决定实施。

---

## 上一入口历史快照（只供追溯，2026-11-17；当前以顶部入口为准）

# 当前入口 2026-11-17：Home与Matching产品规则已冻结，继续讨论Me页面

**`HOME_MATCHING_DECISIONS_FROZEN / DESIGN_DISCUSSION_ONLY / NO_CODE_AUTHORIZATION`**

## 一、最新产品决策冻结

- Owner决策文件：[OWNER_HOME_MATCHING_PRODUCT_RULES_20261117.md](../decisions/OWNER_HOME_MATCHING_PRODUCT_RULES_20261117.md)。
- 治理分支：`governance/home-matching-product-freeze-20261117`。
- 基线：`404fae033584baa870af0a2c214044f8f969531b`。
- 本文件记录Owner截至2026-11-17已确认的首页、内容权限、匹配准入、实人认证、星盘、Lifestyle和自动参与规则；同时把顾问建议与未决细节明确分开。
- 历史UI-AUDIT-01报告及顾问审阅仍有效，见[审计报告](ui-current-state-audit-20261116/UI_CURRENT_STATE_AUDIT.md)和[顾问审阅](ui-current-state-audit-20261116/ADVISOR_REVIEW_20261116.md)。

## 二、已冻结的Owner决定摘要

### Home
- 四个一级入口保持：首页、匹配、消息、我的。
- 首页双频道：精选、好友；默认精选。
- 精选包含官方精选/专题，以及独立的用户公开作品区域。
- 官方精选允许访客阅读；官方专题按内容类型开放评论，采用问题引导式讨论。
- 用户公开作品只允许已登录且账号状态有效的用户浏览；访客不可访问。
- 好友动态按现有SELF/FRIENDS及有效好友权限读取。
- 新用户发布作品默认FRIENDS；作者可选择SELF、FRIENDS或站内公开。
- 用户作品评论策略可为ALL_ELIGIBLE、FRIENDS_ONLY或OFF。
- 访客在APP任何地方均不能留言、评论、点赞、收藏、举报或提交其他互动/反馈。

### Matching
- 注册时Lifestyle可以跳过；进入真实匹配参与前必须完成五场景Lifestyle。
- 正式参与真实匹配前必须通过真实实人认证；供应商未接入前不可假装核验成功或开放真实匹配。
- 普通报名只针对当前轮次，不开启持续自动参与。
- 自动参与独立授权、默认关闭，可暂停/恢复/撤销。
- 星盘有足够出生资料且获用途授权时自动生成，但不是匹配硬门槛。
- MBTI独立可选，不替代Lifestyle。
- Match、Connection、Messaging Consent、Conversation、Relationship继续独立。

### 视觉
- 构成主义为主的二次元卡通画风。
- 讨论阶段使用低分辨率设定图/低保真方向稿。

## 三、当前工作状态

- UI-AUDIT-01已完成并获顾问具名范围接受：`ACCEPTED_IN_NAMED_SCOPE_WITH_RECORDED_LIMITS`。
- 当前工作进入产品设计讨论阶段；下一主题为「我的」页面及个人资料/工具/权限信息架构。
- Personal Data Hub、匹配页五模块、用户评论默认值、部分评论历史可见性等仍按决策文件标记为顾问建议或OPEN，不能视为Owner已确认。
- **当前没有授权Codex执行产品实现的任务。**
- 不修改产品源码、API/Web、数据库schema或业务数据；不构建APK、不启动模拟器；不合main、不发布。
- B4、阶段C、真实身份供应商接入、真实Push、支付、真实运营及正式发布仍需独立授权。

---

## 历史入口快照（2026-11-16；仅供追溯，已由上方2026-11-17入口更新）


以下保留本次审计授权时的入口原文。

# 当前入口 2026-11-16 v10.1.17/v10.1.18 Owner接受，UI现状审计已授权

**`V10117_OWNER_ACCEPTED / V10118_OWNER_ACCEPTED / UI_AUDIT_01_AUTHORIZED / AUDIT_ONLY / NO_PRODUCT_CODE_CHANGE`**。

## 一、最近版本接受

### v10.1.17 — B3全APP低操作成本与功能整合

- Owner接受记录：[OWNER_ACCEPTANCE_20261116.md](../versions/v10.1.17/OWNER_ACCEPTANCE_20261116.md)
- 顾问结论：`ACCEPTED_IN_NAMED_SCOPE_WITH_RECORDED_LIMITS`，R1/R2均NOT_REQUIRED。
- 固定工程交付：`93cb9e4db01ed5262d100f5982b5e01bf4799015`
- APP源码：`1953582093d3469a48cd7275864309cb09eb0e53`
- 候选：`10.1.17-dev / 1011703`
- Owner接受不改变TalkBack/真实设备矩阵NOT_RUN、Buddy原手机原因UNKNOWN、B1模型身份UNKNOWN、B2历史数据库探测UNKNOWN及十二项历史基线测试失败等限制。

### v10.1.18 — UI表达与交互一致性收口

- Owner接受记录：[OWNER_ACCEPTANCE_20261116.md](../versions/v10.1.18/OWNER_ACCEPTANCE_20261116.md)
- 顾问结论：`ACCEPTED_IN_NAMED_SCOPE_WITH_RECORDED_LIMITS`，AC18-01至AC18-08接受，R1/R2均NOT_REQUIRED。
- 固定工程交付：`0442335733555b38970131af7d5327a84e3dcb33`
- APP源码：`1afa6940c37bc1b40aa3d05ea46fb47002f6455c`
- 候选：`10.1.18-dev / 1011804`
- applicationId：`com.elitesync.v1018dev`
- APK SHA256：`eaacc050f7e6fae7bc980c6a766bf1a08ba1cb723bdad6571c821a72e552ba5a`
- Buddy原手机问题原因UNKNOWN；Owner手机复验、系统级TalkBack和真实Push仍NOT_RUN；B1/B2历史UNKNOWN继续保留。

## 二、当前授权任务：UI-AUDIT-01

- 任务分支：`codex/ui-current-state-audit-20261116`
- 分支起点：`d940f72f5768fcbead552059fbc084958d18ec14`
- 任务书：[UI_CURRENT_STATE_AUDIT_TASK_20261116.md](UI_CURRENT_STATE_AUDIT_TASK_20261116.md)
- Codex启动指令：[UI_CURRENT_STATE_AUDIT_START_PROMPT_20261116.txt](UI_CURRENT_STATE_AUDIT_START_PROMPT_20261116.txt)
- 固定截图对象：`10.1.18-dev / 1011804`

交付目标：
1. 使用Android模拟器采集主要页面真实截图；
2. 形成主要页面/路由清单；
3. 梳理至少12条当前功能逻辑链，尽可能追踪APP→API→后端→持久化及权限；
4. 将Owner目标流程与当前真实实现对照；
5. 标记重复输入、冗余跳转、入口难发现、授权/确认与可简化步骤；
6. 提供去敏截图副本、manifest和审计报告供顾问审阅。

**严格边界：** 只审计，不修改产品代码、API/Web、数据库schema、业务配置、导航、按钮行为或versionCode；只用虚构QA账号和模拟器，不操作Owner手机；原始截图留本机，上传副本先去敏；不合main、不发布、不启动B4或阶段C。

## 三、后续UI方向（尚未授权实施）

Owner已明确后续视觉基调为**构成主义为主的二次元卡通画风**。设计讨论阶段优先使用低分辨率设定图/低保真方向稿；此前写实摄影、水面写实反光及玻璃拟态稿不作为接受方向。审计完成后，Owner与顾问先讨论并确认信息架构、功能逻辑简化及视觉基调，再单独授权Codex实施全局UI重构。

## 五、UI-AUDIT-01 顾问独立审阅

- 顾问结论：`ACCEPTED_IN_NAMED_SCOPE_WITH_RECORDED_LIMITS`。
- 审阅报告：[ADVISOR_REVIEW_20261116.md](ui-current-state-audit-20261116/ADVISOR_REVIEW_20261116.md)。
- 审计固定提交：`1d8b485bf4f314d42431bb62a293a3fef9e9c8af`；证据payload：`fd2a0aa7037567f4c368d4bed5bd5e0f420b89d0`。
- 36张截图、16条逻辑链、14项问题在具名范围内接受；所有NOT_RUN、UNKNOWN和NOT_TRACED继续保留。
- 顾问直接复核了代表性截图及完整报告/manifest，未在本会话重新运行ADB、数据库快照、Owner本机SSH fetch或私有原始日志。
- 主要产品差距：Home状态优先而社区二级；社区页面发布表单先于内容；匹配页状态堆叠；基础/匹配/展示/出生资料分散；正式关系手填对象编号；动态星盘失败层UNKNOWN。
- Owner仍需决定社区公开浏览范围、Lifestyle与MBTI关系、实名字段与出生资料来源/授权、星盘是否属于匹配必需条件，以及目标首页内容组织。
- 全局UI实施仍未授权。视觉方向继续为构成主义为主的二次元卡通画风，讨论用图采用低分辨率设定图/低保真方向稿。
- 当前等待Owner与顾问敲定目标信息架构和操作逻辑；未获单独授权前，Codex不得开始UI实施。

## 六、持续保留

- B4运行时AI及阶段C外部身份/信用/Push/支付/发行仍未授权；
- main集成、正式发布、真实内测、收费和运营NOT_RUN；
- Buddy原手机原因、B1图像模型精确身份、B2首次数据库探测历史原因等UNKNOWN继续保留；
- Owner手机复验、系统级TalkBack、真实Push等NOT_RUN继续保留；
- 不将顾问验收、Owner接受、工程自验、main集成和正式发布混为一谈。


