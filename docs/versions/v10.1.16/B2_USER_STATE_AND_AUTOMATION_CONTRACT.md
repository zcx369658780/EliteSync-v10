# v10.1.16 B2 用户状态与自动化合同

## 1. 用户状态中心：统一读取，不制造第二套真相

用户状态中心是一个账号私有的聚合读模型。它汇总现有权威事实，帮助用户理解“我目前处于什么状态、系统正在做什么、下一步需要我做什么”。

它不是新的用户主表，也不是把所有业务状态复制到一张可独立修改的宽表。

### 1.1 首批状态域与候选权威来源

Codex开工时必须重新核对本地固定源码与数据库，不得仅凭下表假定路径/合同未变化。

| 状态域 | 当前权威来源/服务 | 状态中心允许展示 |
|---|---|---|
| 账号状态 | users、账号安全/账户状态服务 | 账号是否可用、必要恢复提示 |
| 基础资料 | users、ProfileController/ProfileReadinessService | 已完成/缺失项、下一步动作；不公开私密原文 |
| 生活方式探索 | lifestyle_discoveries、LifestyleDiscoveryService | not_started/in_progress/skipped/completed、版本/修订/完成时间；不返回原始答案集合 |
| 匹配准备 | ProfileReadinessService | matching_eligibility、原因码、next_action_code |
| 慢约参与 | matching_participations、SlowDatingService | NOT_ENROLLED/ACTIVE/PAUSED/EXITED、revision、generation |
| 当前轮次 | dating_rounds、dating_round_user_states、MatchRoundProjectionService | 本人轮次状态、下一步动作，不暴露其他候选人或内部评分 |
| 自动化授权/任务 | 本版新增的授权与执行合同 | 授权状态、任务状态、最近执行/下次执行、可解释原因 |
| 用户隐私与分享 | 现有隐私/展示授权合同 | 仅展示状态摘要，不返回字段私密值 |
| 通知偏好 | 现有NotificationPreferences合同 | 必要的用户可控通知状态 |

OS位置/相机/麦克风/照片/通知运行时权限由Android设备本地管理，不把系统权限状态当作后端用户授权，不上传系统权限明细作为账号画像。

### 1.2 聚合读模型合同

- 首选按请求实时聚合现有权威服务；只有证据证明性能必要时才建立物化投影/缓存。
- 若缓存/物化，必须有来源revision、更新时间、失效/重建策略；不得在来源变化后继续展示旧状态为当前状态。
- 返回`generated_at`、每个状态域的source_revision或source_updated_at、稳定的状态码和`next_actions`。
- 只允许当前认证用户读取自己的状态；严格账号隔离。
- 不返回原始生活方式答案、精确出生资料、真实身份凭证、私聊、peer私密字段、Safety/Moderation内部案卷、内部匹配分数或其他用户状态。
- 状态中心是只读的；用户意图必须走对应业务命令/授权接口，不允许直接PATCH聚合快照。
- 不改变现有ProfileReadiness、LifestyleDiscovery、SlowDating、MatchRound的权威判断和错误码语义。

## 2. 自动化授权合同

自动化是用户授权的窄范围委托，不是通用代理权限。

每个自动化授权至少应能回答：
- 谁授权；
- 授权的具体scope_key；
- 授权说明/策略版本；
- ACTIVE/PAUSED/REVOKED/EXPIRED状态；
- granted_at、paused_at、revoked_at、expires_at；
- 当前revision；
- 最近执行状态与下一次计划动作。

规则：
1. 默认关闭；不得将历史用户或现有数据批量迁移为自动化已授权。
2. 每个scope单独授权，不用一个“全部自动化”总开关授权未来未知行为。
3. 授权文案必须说清自动执行什么、不执行什么、如何暂停/撤销。
4. 支持pause、resume、revoke和expiry；到期或策略版本发生重大变化时不继续执行旧授权。
5. 若无既有明确的时间到期政策，不擅自发明强制周期；`expires_at`可为空表示持续至用户暂停/撤销或授权策略版本失效，并在UI中明确说明。
6. 授权只代表所列scope，不代表对外分享、消息同意、Connection、Relationship或其他不可逆行为。

## 3. 自动化执行合同

本版只支持代码中明确白名单的任务类型，不支持用户自定义代码、任意URL、任意命令或开放式Agent执行。

任务执行记录至少包含：
- automation_key / scope_key；
- user_id；
- idempotency_key / correlation_id；
- authorization_revision；
- state；
- attempt_count / max_attempts；
- available_at / started_at / finished_at；
- lease_owner / fencing_token / lease_expires_at（如采用并发worker）；
- result_code / error_code / safe_summary；
- reconciliation状态。

任务状态至少区分QUEUED、RUNNING、SUCCEEDED、SKIPPED、FAILED、UNKNOWN/RECONCILIATION_REQUIRED、CANCELLED、EXPIRED。

可靠性：
- 相同用户、scope和业务周期只能产生一个有效执行；
- 有界重试与退避；不能无限重试；
- 如果worker在副作用之后崩溃或结果未知，先按幂等键/业务事实核对，再决定是否重试；不得盲目重复非幂等副作用；
- pause/revoke后尚未执行的任务取消；正在执行的任务在提交副作用前再次检查授权revision；
- 所有自动化动作有最小审计，且用户能看懂系统做了什么/为什么跳过；
- 账号删除遵循既有AccountClosure合同清理/保留；不得新增隐蔽长期留存。

优先使用现有Laravel Scheduler/Jobs/DB队列和本机部署，不引入Redis、第三方队列、云调度或付费服务，除非源码审计证明现有能力无法满足；如需新基础设施，停止该子项并提交证据，不擅自引入。

## 4. 首个自动化试点：每周慢约会持续参与

当前代码已存在：
- `matching_participations`：user_id为主键，状态包含NOT_ENROLLED/ACTIVE/PAUSED/EXITED，具有generation/revision/intent/opted_in_at；
- `SlowDatingService::participate`：明确opt_in/pause/exit，opt_in检查Lifestyle Discovery完成及ProfileReadiness；
- `ProfileReadinessService::eligibleUsersQuery`：检查匹配资格、慢约参与ACTIVE、Lifestyle Discovery完成及未决proposal slot；
- `MatchingRunService`：冻结候选、执行和finalize时重新检查当前资格；
- `MatchingRoundService::prepare`和`AdminMatchingController`：轮次准备/管理仍由获准运营流程执行；
- `app:matching:execute-pending --once`：受保护的匹配执行消费者，受配置开关控制；
- `routes/console.php`当前只有账户关闭任务的每分钟调度。

### 4.1 允许的自动化范围

- 用户明确授权“持续参与后续每周慢约会”后，系统可在未来已有的匹配轮次中自动维持/协调用户参与状态；
- 使用现有`matching_participations`和既有资格合同，避免重复状态；
- 每轮仍重新检查Lifestyle Discovery、ProfileReadiness、账号状态、参与状态、proposal slot及其他既有资格；
- 没有当前开放轮次时显示等待下一轮，不自行创建轮次；
- 资格不足时显示具体原因并跳过，不绕过条件、不伪造完成；
- 用户可暂停或撤销未来自动参与；现有proposal和参与暂停/退出语义必须保持，不能因关闭自动化而暗中接受、拒绝或撤回当前proposal。

### 4.2 既有ACTIVE状态的迁移规则

Codex必须审查当前`SlowDatingJourneyPage`的实际授权文案与服务端合同：
- 如果现有明确opt_in已经清楚告知用户“持续参与后续轮次”，可以将其作为现有持续参与授权的权威来源并复用；
- 如果当前文案只表示单次报名或范围不清，不得把历史ACTIVE用户静默迁移成新的周期自动化授权；必须新增清晰的单独授权，默认OFF；
- 不得只因数据库state为ACTIVE就推断用户已授权任何超出原合同的自动化。

### 4.3 绝对禁止自动执行

自动化不得：
- 创建/排期新的dating_rounds；
- 调用管理员轮次prepare、execution-request、retry、reveal或close；
- 启动/绕过`matching.foundation.execution_enabled`保护；
- 自动触发匹配算法或冻结候选；
- 自动接受/拒绝候选；
- 自动建立Connection、Messaging Consent、Conversation或Relationship；
- 自动向peer发送消息或分享资料。

匹配轮次执行及揭晓仍按现有获准运营流程，不在B2自动化授权范围。

## 5. UI范围

- 在现有Me/Progress/慢约会页面中增加最小状态摘要和自动化授权入口；
- 展示授权scope、当前状态、最近一次执行/跳过原因、下次计划时间（若存在）；
- 支持明确授权、暂停、恢复、撤销；
- 不新增底部导航，不重排四入口，不重做全局信息架构；这些属于B3。
- 不以更多提醒、打卡或频繁打开APP作为目标。
