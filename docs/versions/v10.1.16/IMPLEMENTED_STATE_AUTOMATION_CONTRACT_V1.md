# v10.1.16 状态与自动化已实现合同 V1

依据原 B2 合同与提交 `00cec7843911bb3341304c004059de0a91e12f16` 的源码。本文固定实现形态，运行结论按[实施报告](IMPLEMENTATION_REPORT.md)和[证据摘要](EVIDENCE_SUMMARY_20261115.json)分别记录。

## API 契约

三个入口均要求当前认证用户和有效账号。状态响应设为 `Cache-Control: private, no-store`。

| 方法与路径 | 行为与响应 |
|---|---|
| `GET /api/v1/user-state` | 不接受 query 参数。返回 `contract_version=user_state_v1`、当前 `subject_user_id`、`generated_at`、`domains` 和 `next_actions`。授权域从 `AutomationAuthorizationService::read()` 取得。 |
| `GET /api/v1/automations` | 返回当前用户的授权状态、scope、policy/consent 版本、授权 revision 和时间、最近任务摘要及 `next_planned_at`。没有授权记录时 `code=OFF`。 |
| `PUT /api/v1/automations/{scope}` | 只接受 `weekly_slow_dating_participation`。请求字段为 `action`、`expected_revision`、`policy_version`、`consent_version`、`request_key` 和授权 `grant` 时可选的 `expires_at`。动作限 `grant`、`pause`、`resume`、`revoke`。成功返回与 GET automations 相同形状的当前读取结果。 |

请求必须带当前配置版本。未知字段或策略/同意版本不匹配返回校验错误，scope 不匹配返回 not found。revision 不匹配、request key 被不同请求内容重用、或动作与当前状态不适用时拒绝命令。`request_key` 必须为 UUID。相同用户、相同 UUID 且请求 hash 相同的重放返回当前授权读取状态，不保存或重放最初响应快照。相同 UUID 配不同 hash 返回冲突。

`expected_revision` 以授权当前 revision 作 CAS。无记录按 revision 0 处理。命令 hash 包含动作、expected revision、policy/consent 版本与 expires_at。授权记录、命令收据和审计在数据库事务里更新。

## 授权生命周期

- 无授权行时有效状态为 `OFF`。没有从已有 `matching_participations.ACTIVE` 状态迁移或推断自动化授权。
- 授权 scope 目前只有 `weekly_slow_dating_participation`，代码与数据库按每用户每 scope 唯一。
- `grant` 和 `resume` 都重新检查 Lifestyle Discovery 已完成以及 `ProfileReadinessService` 资格。`grant` 仅能从 `OFF`、`REVOKED`、`EXPIRED` 创建或重授，`resume` 只接受 `PAUSED`。
- 无明确期限时 `expires_at=null`，有效期显示为持续到用户暂停/撤销或策略版本变化。grant 可提交未来 expires_at。过期时间到达、policy version 或 consent version 与当前配置不匹配时，ACTIVE/PAUSED 的有效状态计算为 `EXPIRED`。
- `effectiveState()` 计算出过期不等同于持久化状态已更新。每分钟 scheduler 检查后才把授权状态写成 `EXPIRED`、取消待执行任务、暂停业务参与并记审计。
- `pause`、`revoke` 会取消用户尚未终结的 QUEUED、RUNNING、UNKNOWN 任务并增加 fencing token。若业务参与当前为 ACTIVE，授权服务还会经现有慢约命令将其置为 PAUSED。这个动作不自动接受、拒绝或撤回 proposal。
- 人工慢约 `pause` 会将授权置为 PAUSED，人工 `exit` 会将授权置为 REVOKED 并取消任务。人工重新 `opt_in` 清除业务参与上的自动化授权绑定，授权记录本身不由这条路径自动重新激活。

授权状态包括 `OFF`、`ACTIVE`、`PAUSED`、`REVOKED`、`EXPIRED`。授权记录保存 `revision`、policy/consent version、grant/pause/revoke/expiry 时间及 scheduler 的 `last_checked_at`。配置版本为 `weekly_participation_v1` 和 `weekly_consent_v1`。

## 单 scope 任务模型

每用户、scope、业务周期最多一条任务。当前周期 key 是开放轮次的 `round:{round_key}`，没有轮次时使用 `waiting:{authorization_revision}`。唯一键约束为 `(user_id, scope_key, cycle_key)`，`idempotency_key` 为用户、scope、cycle 的 SHA-256，任务另有 UUID `correlation_id`。

任务记录保存授权 revision、轮次、资格条件 fingerprint、状态、attempt 次数与上限、可运行/开始/结束时间、lease owner、fencing token、lease 到期时间、result/error code 和 reconciliation 标记。状态路径使用 `QUEUED`、`RUNNING`、`SUCCEEDED`、`SKIPPED`、`FAILED`、`UNKNOWN`、`CANCELLED`、`EXPIRED`。reconciliation 会使用 `NONE`、`REQUIRED`、`CONFIRMED`、`NO_EFFECT_CONFIRMED`。

对同一周期，若现存任务为 RUNNING、UNKNOWN 或 QUEUED，scheduler 不重复排队。旧任务为终态且授权 revision 改变时，会复用该周期任务行并重新置为 QUEUED，attempt 清零、清空执行时间和 lease、刷新条件及授权 revision，并递增 fencing token。相同授权 revision 下，SKIPPED 任务仅在条件 fingerprint 改变时重排。幂等键与 correlation id 在复用任务行时保持原值。

## 锁、lease 与 fencing

写路径遵循用户锁优先的协调顺序。

1. 授权命令先锁当前问卷/资格协调锁，再由 `JourneyStore::users()` 按 user id 锁用户行，然后锁该用户授权行和 request command 行。
2. scheduler 排期也先取资格协调锁，再锁用户、授权行和对应 cycle task 行。
3. worker claim 先无锁定位候选任务，再开启事务并按顺序锁用户、任务行。claim 将任务置为 RUNNING 或 UNKNOWN，指定 lease owner，递增 fencing token，并设 lease 到期时间。
4. effect 执行先锁资格协调锁，再锁用户、授权、任务；确认 claim 的 fencing token、owner 和未过期 lease 后才继续。effect 收据检查在任务锁之后。
5. 完成阶段锁用户和任务，并再次核验 lease/fencing 与 effect 收据，才把任务置为 SUCCEEDED。

过期 RUNNING lease 可被重新 claim。重新 claim 增加 fencing token，旧 worker 持有的 token 因而失效。claim 从 UNKNOWN 恢复时保持 UNKNOWN 并设置 reconciliation required，不把未知结果当成新执行成功。

## Effect、UNKNOWN 与有限重试

慢约参与更新与 `automation_effects` 收据写入同一数据库事务。重试前先按 task id 和 authorization revision 检查收据。找到收据就依据当前 participation generation 做效果核对并完成为 SUCCEEDED，不重复执行参与命令。

没有收据时，UNKNOWN 先核对授权有效状态及 revision，再把原子事务收据缺失记录为 NO_EFFECT_CONFIRMED 并安排有限重试。重新执行副作用前仍须核对账号、当前轮次、Lifestyle Discovery、ProfileReadiness 和 proposal slot。尝试上限为 3，配置退避间隔 `[30, 120]` 秒。最多两次确认无 effect 后重试，达到上限转 FAILED，result code 为 `RETRY_EXHAUSTED`。不能在未核对业务事实时盲目重放。

命令和任务错误不得把异常文本、SQL、私密资料或凭据写进面向用户的摘要。`AutomationAuthorizationService::read()` 会直接返回 task 的 `error_code` 字段。当前已见 worker 在结果不确定时写固定码 `EXECUTION_UNCERTAIN`，授权变更使用固定 result code `AUTHORIZATION_CHANGED`。该字段必须严格限制为经审查的安全白名单码，禁止原样存储或返回 Throwable 内容。数据库列是普通字符串，没有数据库层白名单约束，因此应用写入边界仍需保持固定安全码。

## 用户可见状态与原因码

当前授权读取返回 `code`、scope、policy/consent 版本、授权 `source_revision` 与 `source_updated_at`、授权时间、`duration_code`、最近任务摘要和下次排期。最近任务摘要含 id、state、result_code、error_code、attempt_count、max_attempts、reconciliation 和 updated_at。scope 是单一固定白名单。实现当前按用户读取最近任务和最早 queued 时间，查询没有显式添加 `scope_key` 过滤。因为当前仅支持一个 scope，返回仍限于现行模型；增加第二个 scope 前必须收紧查询条件。

任务可解释结果码包括 `ACCOUNT_UNAVAILABLE`、`NO_OPEN_ROUND`、`ROUND_NOT_OPEN`、`EXISTING_PROPOSAL`、`LIFESTYLE_INCOMPLETE`、ProfileReadiness 返回的稳定资格原因码、`PARTICIPATION_COORDINATED`、`RECONCILED_EFFECT`、`RECONCILED_EFFECT_SOURCE_CHANGED`、`AUTHORIZATION_CHANGED` 和 `RETRY_EXHAUSTED`。这些是状态/原因码，不代表执行已在生产或设备验证。UI 应将已知码映射为用户可懂说明，未知码使用通用失败提示，不能展示原始异常。

## 业务边界

自动化只维护用户对未来每周慢约参与的明确委托。它复用 `matching_participations` 中的 state、revision、generation 和授权引用，并在每轮 worker 执行前重新核对用户资格和当前 proposal slot。没有开放轮次时任务记录 `NO_OPEN_ROUND`。只有既有轮次处于准备状态且没有 active run 时，worker 才可能继续参与协调。

代码不创建或排期 `dating_rounds`，不调用管理员 prepare、execution-request、retry、reveal、close，不启动 `app:matching:execute-pending --once`，不触发匹配算法或冻结候选，不接受/拒绝 proposal，不建立 Connection、Messaging Consent、Conversation 或 Relationship，也不向 peer 发消息或分享资料。

已到期 proposal 有一项明确边界。worker 在资格满足且处于开放准备轮次时调用 `SlowDatingService::reconcileOwnProposalDeadlines()`，按既有 expiry 时间清理自然到期 proposal。此路径只执行原期限协调，不代替用户作出接受、拒绝或撤回决定。状态 GET 走单独纯读 summary，过期时只返回待协调标记，不执行这项写入。

## 账号删除与隐私

既有 `AccountClosure::erasePrivateData()` 按用户清除 `automation_audits`、`automation_commands`、`automation_effects`、`automation_tasks` 和 `automation_authorizations`。授权表和任务表也有用户外键级联删除。迁移运行与原有账号安全回归见实施报告，新表真实擦除专项为 NOT_RUN。

状态与授权读取只查询当前认证用户。状态 API 禁止 query 参数，并使用 private/no-store。统一状态不得带出 Lifestyle 原始答案、derived preferences 或题库、`matching_participations.intent`、peer 私密信息、内部匹配评分、私聊、安全案卷、身份凭证或 OS 运行时权限详情。隐私域只显示请求开关、版本及共享字段数量，不返回 `self_profile` 或逐字段资料值。

## 源码索引

- 原合同 `docs/versions/v10.1.16/B2_USER_STATE_AND_AUTOMATION_CONTRACT.md`
- API `services/backend-laravel/app/Http/Controllers/Api/V1/UserAutomationController.php` 与 `services/backend-laravel/routes/api.php`
- 聚合 `services/backend-laravel/app/Services/UserStateService.php`
- 授权 `services/backend-laravel/app/Services/AutomationAuthorizationService.php`
- 任务执行 `services/backend-laravel/app/Services/AutomationService.php`
- 模式 `services/backend-laravel/database/migrations/2026_11_15_220000_create_user_automation.php`
- 配置与调度 `services/backend-laravel/config/user_automation.php`、`services/backend-laravel/routes/console.php`
- 账号清理 `services/backend-laravel/app/Services/Accounts/AccountClosure.php`
- 隐私响应头 `services/backend-laravel/app/Http/Middleware/JourneyPrivateResponse.php`
