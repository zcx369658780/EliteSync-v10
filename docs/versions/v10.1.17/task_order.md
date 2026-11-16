# v10.1.17任务书：全APP低操作成本重构与功能整合

日期：2026-11-16（北京时间）  
状态：`OWNER_AUTHORIZED — V3.0_PHASE_B3`

## 一、固定任务身份

- 仓库：`zcx369658780/EliteSync-v10`
- 任务分支：`codex/v10.1.17-low-operation-cost-journey-integration-20261116`
- 唯一父基线：`99a05c6f6d509c0607d8bff0d63b122d5cc84eec`
- v10.1.16最终顾问治理提交：`99a05c6f6d509c0607d8bff0d63b122d5cc84eec`
- v10.1.16 Owner接受及B3授权决定：`docs/decisions/OWNER_V10_1_16_ACCEPTANCE_AND_V10_1_17_B3_AUTHORIZATION_20261116.md`
- V3.0路线图：`docs/architecture/ELITESYNC_V10_PRODUCT_ROADMAP_V3_0.md`
- B3补充决定：`docs/architecture/ELITESYNC_V10_PRODUCT_ROADMAP_V3_0_ADDENDUM_20261116_PHASE_B3_AUTHORIZATION.md`
- 建议候选：`10.1.17-dev / 1011701`，必须先核验versionCode、applicationId及候选包名是否占用；不得覆盖/升级安装v10.1.16候选。

## 二、开工前强制同步路线图与开发思路

Codex不得直接按旧页面结构逐页换皮，也不得从一般社交APP模板推导功能。必须先完成：

1. 核本地稳定工程根、origin、branch、HEAD、dirty/index、数据库、AVD、私有配置、测试账号和原始证据。
2. 只读本地`AGENTS.md`、`ACTIVE_STATE.md`当前首块和`CURRENT_WORKFLOW.md`。
3. 从本任务分支固定父基线逐Git Blob同步并核验：
   - V3.0路线图；
   - B1/B2历史授权与B3补充决定；
   - v10.1.15 Owner接受记录；
   - v10.1.16 Owner接受记录、第二轮顾问验收、R1关闭记录、实施报告和manifest；
   - 本版task_order、plan、DEVELOPMENT_ALIGNMENT、B3_LOW_OPERATION_COST_PRODUCT_CONTRACT和CODEX_START_PROMPT；
   - 更新后的AGENTS、ACTIVE_STATE、CURRENT_WORKFLOW。
4. 保护dirty/index、数据库、AVD、凭据、测试语料、媒体和原始证据；不盲pull/reset/rebase/stash/clean/prune，不force push。
5. 逐份记录Git Blob SHA与本地内容，形成`LOCAL_DOCS_SYNCED`或逐项`PENDING_LOCAL_SYNC`。
6. 在产品源码修改前，完成下述三份审计文件和`ROADMAP_ALIGNMENT_ACK.md`：
   - `CURRENT_JOURNEY_INVENTORY.md`：现有页面、路由、功能入口、重复入口、状态来源和权限门；
   - `B3_OPERATION_COST_BASELINE.md`：九项代表旅程的步骤、跳转、重复输入、确认、恢复成本；
   - `TARGET_INFORMATION_ARCHITECTURE_V1.md`：目标四入口、规范入口、旧路由兼容和状态来源；
   - `ROADMAP_ALIGNMENT_ACK.md`：确认B3边界、低操作成本目标、必要确认不得移除、B4/C未授权和Owner整体实机验收延后。
7. 以上文件可在本地审计后一次性提交为本版B3审计基线；不需要等待Owner逐页审批，Owner已授权B3。完成前不得修改产品源码。

## 三、唯一目标

把EliteSync从“功能分散、多个页面反复寻找状态和入口”的APP，重构为以用户目标为中心、低操作成本、状态一致、已授权事项由系统完成的关系决策辅助产品。

不是增加功能数量，不是做普通社交平台，不是以DAU/停留时长为目标。

## 四、八项验收标准

### AC17-01 现有旅程与操作成本审计

- 盘点四个底部入口及所有相关路由、页面、权限门和业务服务；
- 盘点Home、Progress、Messages、Me、SlowDatingJourney、UserState、Lifestyle Discovery、Buddy、Community、Match、Connection、Notification和特色工具；
- 明确重复入口、重复表单、重复状态展示、跨模块往返、无意义确认及低风险草稿恢复问题；
- 建立九项代表旅程的操作成本基线；
- 形成CURRENT_JOURNEY_INVENTORY、B3_OPERATION_COST_BASELINE和TARGET_INFORMATION_ARCHITECTURE；
- 明确每个状态域的权威来源，禁止重复建立状态真相。

### AC17-02 统一信息架构与导航

- 以用户目标重组Home / Progress / Messages / Me；
- 默认保留四个底部主入口，不新增第五个底部入口；
- 如果审计证明现有四入口标签或次级结构需要调整，可在四入口框架内优化；
- 统一规范入口，减少同一功能在多个页面重复出现；
- 旧deep link、通知跳转、外部路由和现有权限redirect必须兼容或安全重定向；
- 不因隐藏重复入口而删除仍有效的能力。

### AC17-03 Home：首页一眼理解状态与下一步

- 首页首屏优先显示本人当前状态和最重要的下一步；
- 复用B2`/api/v1/user-state`及`next_actions`；
- 客户端只映射已存在稳定code到文案/路由，不创建新的资格/匹配/关系判断；
- 一个明确的主动作，其他事项按次要或可选入口展示；
- 社区、Buddy和可选活动为有限独立入口，不把首页变成默认无限Feed；
- 未知、过期、等待对方、系统处理中、需要本人决定必须清晰区分。

### AC17-04 Progress：整合关系旅程

- 将资料准备、Lifestyle Discovery、匹配输入、每周参与/自动化、当前轮次、提案、Connection、Messaging Consent、Conversation和正式关系组织为可理解的本人旅程；
- 各业务状态仍独立，明确显示来源和本人下一步；
- 不把Match/Connection/Consent/Conversation/Relationship压成一个单一状态；
- 用户只在需要本人决定时看到清晰动作；已授权后台任务显示系统正在处理/等待；
- B2状态中心与自动化设置保留一个规范页面入口，不在Progress/Me/Journey维护多份状态；
- Buddy作为独立体验，不纳入恋爱匹配旅程。

### AC17-05 Messages：降低沟通入口成本

- 优化会话列表、会话入口和通知可达性；
- 通知若并入消息入口，必须与聊天会话分开分类、分开计数和处理已读；
- 保留ConversationAccessGate、消息同意、Connection、block、隐私、账号切换、私有缓存和媒体授权合同；
- 不自动创建会话、不自动发消息、不代替双方授予消息同意；
- 不为提高打开频率增加Push、未读焦虑或连续互动机制。

### AC17-06 Me：个人资料、偏好、隐私和工具整合

- 个人资料、匹配输入、Lifestyle Discovery、展示资料、隐私/分享、账号安全和可选工具按用户目的组织；
- 减少重复资料入口和重复输入；
- B2状态中心/自动化控制从Me、Progress、Journey等处收敛为一个规范页面，其他页面只提供上下文链接；
- MBTI、星盘、八字等保持自愿、非诊断、非匹配硬筛选；
- 私密资料和公开展示分离，所有分享继续逐项授权。

### AC17-07 低操作成本交互与权限一致性

- 复用B1偏好和B2权威状态，适当预填已有数据；用户能查看、修改和纠正；
- 普通导航、查看、草稿保存及可恢复低风险操作不增加无意义确认；
- 重要表单减少重复填写；草稿恢复沿用现有账号隔离、安全存储和命令幂等合同；
- 保留隐私分享、身份、匹配接受、消息同意、Connection、正式关系、删除/退出等必要明确行动；
- OS位置、照片、相机、麦克风和通知权限按用途触发，不首次一次性请求；
- 不以点击数最少为唯一指标，兼顾可理解性、可撤销性和用户自主权；
- 视觉方向保持冻结，不改写实/高刺激风格，不为装饰生成新美术素材。

### AC17-08 联合验证与集中交付

- 对九项代表旅程做前后操作成本对比；
- 至少6/9个旅程减少至少一个不必要页面跳转、重复输入或确认；至少4/9个旅程总操作动作减少20%或以上；
- 任何高风险流程不得为了减少步骤而移除必要授权/确认；未达标项记录原因；
- 双虚构账号切换、状态隔离、deep link、通知跳转和冷启动恢复；
- Home/Progress状态与B2 API权威状态一致，不能展示过期/合成状态为真实事实；
- Match/Connection/Messaging Consent/Conversation/Relationship边界回归；
- Buddy、社区、消息、媒体、隐私和特色工具代表流程回归；
- Widget、Dart分析、受影响PHP/API测试按实际改动范围执行；
- 候选1011701身份、包名、签名、APK SHA256和模拟器安装身份核对；
- 交付实施报告、manifest、操作成本对比、路由/功能地图、去敏证据、已知限制和Owner整体实机检查包。

## 五、明确不做

- 不做B4运行时AI偏好解释/关系辅助；
- 不把私聊、出生资料、身份资料或安全案卷发送给外部模型；
- 不改变匹配算法、候选排序、ProfileReadiness/LifestyleDiscovery/SlowDating权威判断；
- 不合并Match、Connection、Messaging Consent、Conversation和Relationship状态机；
- 不自动接受匹配、自动分享、不自动发送消息、不自动确立关系；
- 不把Buddy并入恋爱匹配，不把社区变成无限Feed/短视频推荐平台；
- 不接身份核验、征信、芝麻信用、蚂蚁积分、真实Push、支付或新供应商；
- 不修改Owner手机，不要求Owner中间版本实机验收；
- 不使用真实用户/生产数据，不合main、不正式发布、不开展真实内测/运营；
- 不自动启动B4或阶段C。

## 六、交付与停止

完成八项AC的具名范围工程交付，固定提交并完成同源远端回读后停止，等待GPT顾问独立验收。Owner整体手机实机验收安排在B1+B2+B3完成后。B4/阶段C不自动启动。
