# v10.1.16任务书：统一用户状态与后台自动化中心

日期：2026-11-15（北京时间）  
状态：`OWNER_AUTHORIZED — V3.0_PHASE_B2`

## 一、固定任务身份

- 仓库：`zcx369658780/EliteSync-v10`
- 任务分支：`codex/v10.1.16-user-state-automation-center-20261115`
- 唯一父基线：`b981796e68ca512beeed2a18b40aeb8b09e26bc2`
- v10.1.15 Owner接受/授权提交：`59b1967568b49fa0d009bb2892d9d8fb5730b253`
- 当前Owner决定提交：`b981796e68ca512beeed2a18b40aeb8b09e26bc2`
- B1产品源码/题库/美术资产：`2123496a4d347220e17b84eeec4df9d9f9455399`
- B1候选：`10.1.15-dev / 1011501`
- 路线图：`docs/architecture/ELITESYNC_V10_PRODUCT_ROADMAP_V3_0.md`
- 当前授权补充：`docs/architecture/ELITESYNC_V10_PRODUCT_ROADMAP_V3_0_ADDENDUM_20261115_PHASE_B2_AUTHORIZATION.md`

建议候选：`10.1.16-dev / 1011601`，必须先核versionCode是否占用；若占用顺延。

## 二、开工前强制同步路线图和开发思路

Codex不得从旧B1 prompt、旧V2.0未来规划或一般“自动化平台”思路直接开始编码。必须先完成：

1. 核对本地稳定工程根、origin、分支、HEAD、status、index、数据库、AVD、私有配置和本地证据。
2. 只读本地`AGENTS.md`、`docs/workflow/ACTIVE_STATE.md`当前首块、`docs/workflow/CURRENT_WORKFLOW.md`。
3. 从本任务分支固定父基线同步并逐Blob核验：
   - V3.0路线图；
   - V3.0阶段B2补充决定；
   - v10.1.15 Owner接受记录、顾问验收和R1复核；
   - 本版task_order、plan、DEVELOPMENT_ALIGNMENT、B2_USER_STATE_AND_AUTOMATION_CONTRACT、CODEX_START_PROMPT；
   - 更新后的AGENTS、ACTIVE_STATE、CURRENT_WORKFLOW。
4. 保护本地dirty/index、数据库、AVD、凭据和原始证据；不盲pull/reset/rebase/stash/clean/prune，不force push。
5. 逐份核对Git Blob SHA和本地文件内容，记录`LOCAL_DOCS_SYNCED`或逐项`PENDING_LOCAL_SYNC`。
6. 产品源码修改前必须创建`docs/versions/v10.1.16/ROADMAP_ALIGNMENT_ACK.md`，逐项确认B2边界、状态来源不重复、自动化默认关闭、现有慢约参与合同、管理员匹配执行边界、B3/B4/C未授权、Owner实机验收延后。未完成不得编码。

## 三、唯一目标

形成一个统一、可靠、可解释的用户状态中心和有限自动化中心，让系统自动完成用户已经明确授权的准备、状态协调、资格检查、任务整理和后台执行，减少重复输入和重复确认。

本版不是全局UI重构，不建设任意任务Agent，不自动操作关系决策。

## 四、七项验收标准

### AC16-01 权威状态来源盘点与统一合同

- 盘点账号、基础资料、Lifestyle Discovery、ProfileReadiness、慢约参与、当前轮次/提案、隐私/分享授权、通知偏好和自动化状态的权威来源；
- 形成`USER_STATE_SOURCE_MAP_V1.md`，记录字段、来源表/服务、读取路径、revision/freshness、隐私级别、触发更新方式；
- 明确区分权威源、派生投影和用户命令；禁止创建重复可写的用户状态真相；
- 说明哪些数据不进入统一状态视图：原始生活方式答案集合、精确出生资料、真实身份凭证、私聊、peer私密信息、Safety/Moderation内部案卷、内部匹配分数、OS运行时权限细节；
- 如发现现有状态接口已经满足部分需求，复用并补缺，不重复建设。

### AC16-02 统一用户状态只读API

- 为当前认证账号提供一个聚合状态读取入口（具体路径遵循现有API约定）；
- 返回账号/资料摘要、Lifestyle Discovery进度、匹配准备状态、慢约参与状态、当前轮次/本人提案摘要、授权与自动化任务状态及可执行的下一步动作；
- 每个状态域提供稳定code、必要revision/source_updated_at和`generated_at`；
- 以现有服务为权威：ProfileReadinessService、LifestyleDiscoveryService、SlowDatingService、MatchRoundProjectionService等；不得重新实现另一套资格判断；
- 默认实时聚合。若确有性能理由使用缓存/物化，必须有source revision、失效和重建机制；
- 严格账号隔离、private/no-store；不得返回其他用户、peer或内部安全数据；
- 只读状态接口不能修改资料、授权、匹配参与或关系状态。

### AC16-03 自动化授权生命周期

- 建立scope级授权合同，默认关闭；
- 至少支持ACTIVE、PAUSED、REVOKED、EXPIRED；
- 保存授权scope、policy/consent版本、revision、granted_at、paused_at、revoked_at、expires_at；
- 允许用户暂停、恢复、撤销；撤销后不得创建新的scope任务；
- 支持到期与授权策略版本失效；若当前没有明确的强制时间期限，不得擅自发明短周期，允许持续至用户暂停/撤销或策略版本变化，并明确展示；
- 不得把历史用户、旧的ACTIVE参与状态或既有设置静默迁移成超出原授权范围的新自动化；
- 不将Android系统权限、隐私分享授权和后台自动化授权混为一谈。

### AC16-04 有限、可靠、可审计的自动化执行

- 建立代码白名单任务类型和持久执行记录；
- 支持幂等键、相关ID、有限重试/退避、执行状态、失败原因、未知结果核对、暂停/撤销、到期、最小审计；
- 对并发worker使用锁/lease/fencing，避免重复执行；
- 如果任务在副作用之后结果未知，必须先核对当前业务事实，不得盲目重试；
- 任务执行前再次检查授权revision和用户当前资格；
- 使用现有Laravel Scheduler/Jobs/DB队列，先验证当前部署配置；不接Redis、第三方队列、云任务平台或付费服务；
- 不支持用户任意命令、URL、脚本或开放式Agent执行；
- 只实现本版明确的白名单自动化，不为“通用性”提前建设大型workflow平台。

### AC16-05 每周慢约会持续参与自动化试点

- 审计现有`matching_participations`、`SlowDatingService::participate`及APP授权文案；
- 若当前明确opt_in已表达持续参与后续每周轮次，复用其权威状态并补充清晰展示/自动化审计，不新建重复授权状态；
- 若当前范围不清，新增`weekly_slow_dating_participation`单独授权，默认OFF，用户明确选择一次后才允许后续自动参与；
- 用户完成Lifestyle Discovery和现有ProfileReadiness资格检查后才允许启用；
- 每轮仍按当前服务端资格和proposal状态重新核验；不合格时记录SKIPPED及原因，不绕过门禁；
- 用户暂停/撤销后停止未来自动参与；当前proposal按现有规则处理，不自动接受/拒绝/撤回；
- 无开放轮次时显示等待下一轮，不自动创建轮次；
- 自动化不得调用管理员轮次prepare、execution-request、retry、reveal、close，不得启动受保护的matching run consumer，不得自动触发匹配算法；
- 不自动建立Connection、Messaging Consent、Conversation或Relationship，不发送消息，不公开资料。

### AC16-06 APP最小状态与自动化入口

- 在现有Me/Progress/慢约会页面中加入最小状态概览和自动化设置；
- 用户能理解“当前状态、系统正在做什么、为什么跳过、下一步要做什么”；
- 可查看每项授权scope、当前状态、最近执行结果、下次计划（若存在）；
- 可明确授权、暂停、恢复和撤销；
- 不增加底部导航，不重排Home/Progress/Messages/Me，不实施B3全局UI减法重构；
- 不增加打卡、连续签到、无意义确认或频繁推送。

### AC16-07 集成、可靠性验证与集中交付

- 双虚构账号状态隔离、状态源更新后聚合视图同步；
- 原始答案、出生资料、私聊、peer和安全案卷不泄漏；
- 自动化默认OFF、一次授权、pause/resume/revoke/expiry、旧账号不被静默授权；
- scheduler重复运行、并发worker、worker崩溃、超时UNKNOWN、幂等重试、撤销竞态；
- 每周参与：已授权/未授权/暂停/过期/资格不足/无开放轮次/现有proposal等具名场景；
- 普通社区、Buddy、消息、Connection及Relationship不受B2授权误影响；
- 既有admin matching round和protected execution合同保持不变；
- PHP/API/DB、Flutter/Widget、Dart分析和模拟器真实APP链按受影响范围验证；
- 构建1011601或核占用后顺延候选，记录源码/API/Web身份、APK SHA256、签名和安装身份；
- 交付实施报告、manifest、去敏证据、状态来源图、自动化合同、运行/恢复说明和已知限制。

## 五、明确不做

- 不实施B3全局低操作成本UI/导航重构；
- 不开发B4运行时AI关系解释，不将用户资料或私聊发送外部模型；
- 不接真实身份核验、征信、芝麻信用、蚂蚁积分、Push、支付或新供应商；
- 不改变匹配算法、候选排序、dating_rounds管理员控制、matching_runs受保护执行、Connection/Messaging Consent/Conversation/Relationship状态机；
- 不自动接受匹配、自动连接、自动同意消息或正式关系；
- 不操作Owner手机；整体Owner实机验收延后至B1+B2+B3完成；
- 不使用真实用户或生产数据，不合main、不发布、不开展真实内测/运营。

## 六、交付与停止

完成七项AC的具名范围工程交付，固定提交并同源远端回读后停止，等待独立顾问验收。B3/B4/阶段C不自动启动。
