# BE-09｜synthetic Messaging live gate application 合同

状态：`ISSUED — DOCS-ONLY`。风险 LEVEL 2（保护性读发使用点与双输入权限边界）。派发给最新合资格 Codex 执行会话 `01a0ddd0-bab2-7673-bf5b-03dbfbc066e4`；唯一交付为同目录 `plan.md`，完成后停在 Work 独立 LEVEL 2 审查。

## 来源与范围

先核对 `D:\EliteSync-v10` 本地 `main`、HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`、工作区状态和 `TASK_CURRENT.md`。只读来源限根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow 技能、当前交付计划、BE-05/06/08 的 `plan.md` 或 `work-review.md`（不存在的精确文件记缺失，不搜替代）、以下三个源码及相应两个 Unit test：

- `services/backend-laravel/app/Domain/MessagingConsentConversationLiveGateEvaluator.php`
- `services/backend-laravel/app/Domain/MessagingConsentPersistenceApplicationAdapter.php`
- `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`
- `services/backend-laravel/tests/Unit/MessagingConsentConversationLiveGateEvaluatorTest.php`
- `services/backend-laravel/tests/Unit/MessagingConsentPersistenceApplicationAdapterTest.php`
- `docs/architecture/ELITESYNC_V10_BACKEND_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_TECHNICAL_DESIGN_V0_1.md` 及其 `...ACCEPTANCE_V0_1.md`
- `docs/architecture/ELITESYNC_V10_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_IMPLEMENTATION_PLAN_V0_1.md` 及其 `...ACCEPTANCE_V0_1.md`
- `docs/architecture/ELITESYNC_V10_CONVERSATION_DATA_RIGHTS_DECISION_CLOSURE_OWNER_ACCEPTANCE_V0_1.md`

本任务只为**与真实账号、生产 DB、消息正文隔离的 synthetic/dev-test 后端**确定下一代码切片；不设计新的产品生命周期、真实 MC writer、auth/session、HTTP endpoint、持久迁移或真实消息发送。BE-08 的 `correlation_usable` 和 repository 读回是非权威关联，不能作为 `MC_ACTIVE` 来源；调用方自报的 audience/owner/revision 也不证明真实来源可信。

## 唯一交付内容

1. 对照上述接受文件与实际公开方法，写出 live-read 和 live-send **分别**需要的当前 CN 来源、相应 purpose 的当前 MC 来源、Connection/consent identity、双方参与者、方向、受众、revision、currentness/freshness 与失效输入。列出每个来源的 owner 与信任等级；不把 projection/cache/旧会话当来源。缺少的来源签发者或真实认证机制明确 `NOT_READY`，不可虚构。
2. 画出最小应用调用顺序：每次 live-read 前重新取得两输入；每次提交 live-send 时重新取得两输入；调用现有 `evaluateLiveGates(...)` 并只让**对应 purpose 当次结果**控制当次虚构动作。说明私密内容构造必须发生在 read gate 后、草稿/发送必须发生在 send gate 后。区分展示用派生投影、授权来源及保护性使用点；旧状态、超时、不可比、缺失、撤销、修正、错误 audience/participant/purpose 均拒绝。
3. 判断下一段**最小代码任务**是否已有足够的 synthetic 输入/输出边界。若可实施，固定单一候选应用接口、精确源码/Unit test 路径、输入输出字段、拒绝矩阵、一次测试预算与回退边界；以无真实 I/O 的测试动作证明 gate 对调用顺序的保护，不能仅包装 evaluator 然后宣称消息读写完成。若现有源码尚无可信可控的 synthetic 动作或时间点，明确 `NOT_READY` 和最小缺口，不增设未经审查的 message store。
4. 将 BE-06 所列 `MC_TRANSITION` 持久化与本 live gate 使用点明确拆开：当前 repository 只接受 `MC_TRANSITION=UNKNOWN`，不得把 evaluator 的 `ADMISSIBLE/REJECTED` 直接写入，也不能靠存储成功获取权限。说明是否需要先做独立 provenance 合同，不能擅自合包。
5. 给出有限的正负测试矩阵，至少覆盖 CN/MC 各自缺失或非 active、read/send purpose 互换、跨 context/participant/audience、旧 revision、撤销后重入、失效依赖、send 提交前状态变化、私密内容过早构造、传输歧义；证据与失败结果仅限 synthetic。报告精确 `NOT_RUN`，不称 production backend 或真实账号可用。

## 预算与停点

最多两轮上述固定来源静态核对；仅写 `plan.md`，保存输入文件摘要、检查轮数和候选差异。不得运行 PHPUnit/Composer/Artisan、容器、构建、浏览器、DB、备份/密钥、SSH/云/生产接口；不得读 `.env`、业务行、真实密码哈希、旧 `D:\EliteSync`。不修改产品代码、现有证据或任务状态，不 commit/pull/push，不重用 BE-07/08 或 AUTH-152～155 的预算。交付后停 Work 独立 LEVEL 2 审查；作者不自接受、不启动下一代码任务。回退是保留 BE-08 已接受的非权限当前态关联，标记后继 `NOT_READY`。
