# BE-02｜Messaging Consent 独立派生记录合同

状态：Work 派发给最新合资格 Codex 执行会话 `01a0ddd0-bab2-7673-bf5b-03dbfbc066e4`；`docs-only`，LEVEL 2。唯一交付为本目录 `plan.md`。BE-01 仅接受边界映射，不能据此开始代码实现。

## 固定来源与允许动作

先只读核对根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 `elitesync-local-workflow`、BE-01 的 `task.md`、`plan.md`、`work-review.md`，以及下列固定设计/代码：

- `docs/architecture/ELITESYNC_V10_BACKEND_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_TECHNICAL_DESIGN_V0_1.md` 和 `ELITESYNC_V10_BACKEND_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md`；
- `services/backend-laravel/app/Domain/MessagingConsentConversationLiveGateEvaluator.php` 与 `services/backend-laravel/tests/Unit/MessagingConsentConversationLiveGateEvaluatorTest.php`；
- `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`、`SqliteInMemoryLogicalPersistenceAdapter.php`、`PersistenceBoundaryApplicationInterfaceIntegrationContract.php`；
- `services/backend-laravel/app/Domain/ProductConnectionPersistenceApplicationAdapter.php` 和 `services/backend-laravel/tests/Unit/ProductConnectionPersistenceFamilyTest.php`，仅供结构对照，不借用 CN 权威。

若上述精确路径不存在或来源不足，在 `plan.md` 写清缺口并停；不得全仓搜索、扩大读取或自行修改源码。唯一允许新增/修改的文件是本目录 `plan.md`；保留全部现有 modified/untracked 内容。

## 唯一结果要固定的合同

1. 定义 **synthetic/dev-test 派生记录** 的独立 MC family：稳定 record/intent/consent identity，精确 typed payload 与必需/禁止字段，来源携带的 outcome、scope、actor/role、requester/recipient、恰两名参与者、当前 CN aggregate/context、read/send purpose、MC source-local lineage/revision/currentness/freshness。明确这类记录不是 MC 权威 writer，也不自行授予 live read/send。
2. 给出来源记录、transition intent、纠错/替代、撤销、终态新 identity 的关联与存储/读回规则；区分 exact duplicate、changed-input reuse、同 revision 冲突、不可比 lineage、乱序和重放。不能按写入或到达顺序决定当前 MC 状态。逐项说明缺失或 `UNKNOWN` 时的 fail-closed 结果，不发明真实来源或跨 CN/MC 全局 revision。
3. 定义与现有 repository 和 evaluator 的**最小接口映射**：哪些为输入、哪些为派生投影、哪些仅为传输观察；如何精确读回和失效；当前有效权限须在使用点另取独立 CN 与 MC 权威证据，send 提交时重核。分别保持 live-read/live-send，不能借离线缓存或历史 Conversation 权限。
4. 列出可据此派发的最小 synthetic/dev-test 代码切片、精确写入路径、定向测试与负向用例、失败回退及 Work LEVEL 2 审查证据。若设计仍缺必需的真实来源/合同，请明确 `NOT_READY` 和所需决定；不可把未建立的生产 writer 或身份源写成既成事实。

最多两轮本地静态核对；记录实际读取、文件 SHA-256、差异与 `NOT_RUN`。不运行 PHPUnit、Composer、Artisan、Docker、构建、SSH、DB、UAC、真实备份、解密或恢复；不访问旧 `D:\EliteSync`、GitHub、`.env`、私钥、业务行或日志，不提交/pull/push。作者交付后停在 Work 独立 LEVEL 2 审查，不自接受、不派发代码。BE-01 的 2/2 和 AUTH-152/153 各自预算均不重置。
