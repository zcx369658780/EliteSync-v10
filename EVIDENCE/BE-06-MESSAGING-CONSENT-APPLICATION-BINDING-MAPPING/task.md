# BE-06｜MC application binding 最小后继映射

状态：Work 派发给最新合资格 Codex 执行会话 `01a0ddd0-bab2-7673-bf5b-03dbfbc066e4`；LEVEL 2、`docs-only`。唯一结果为本目录 `plan.md`。BE-05 已独立接受的仅是 synthetic/dev-test repository-only family；真实 MC writer 与 live permission 仍 `NOT_READY`。

只读固定来源：根 `AGENTS.md`、`CURRENT.md` 当前入口、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 `elitesync-local-workflow`，BE-03 `plan.md`/`work-review.md`、BE-05 `task.md`/`summary.md`/`work-review.md`，BA-05 `docs/architecture/ELITESYNC_V10_BACKEND_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md`，以及 `services/backend-laravel/app/Domain/` 下的 `MessagingConsentConversationLiveGateEvaluator.php`、`InMemoryLogicalPersistenceRepositoryContract.php`、`SqliteInMemoryLogicalPersistenceAdapter.php`、`PersistenceBoundaryApplicationInterfaceIntegrationContract.php`、`ProductConnectionPersistenceApplicationAdapter.php` 和各同名 Unit test。若同名 test 不存在，记录精确缺口，不扩大全仓搜索。

结果需回答：

1. 从 BE-05 的非权威 MC 当前态记录到下一段 application adapter，固定 synthetic 输入、source-carried 证据、intent、store/readback、返回值和失败停点；`UNKNOWN`/冲突/不可比/失效不产生 live grant。
2. 明确 `evaluateTransition`、`evaluateLiveGates` 和 repository 的真实接口顺序。当前 repository 只接受 `MC_TRANSITION=UNKNOWN`；若要持久化 evaluator 的 `ADMISSIBLE/REJECTED`，必须提出独立的 provenance 绑定与更改合同，不能在本任务把它默认为已支持。优先给出不需改变真实 writer 的最小可执行代码切片；如不安全，标 `NOT_READY`。
3. 分开 live-read/live-send 及双输入 CN/MC 的使用点复核，说明 Product Connection adapter 只能做结构对照，不能借 `CN_ACTIVE` 或 MC 投影当作来源权威。离线/历史 Conversation、消息正文、真实身份/token、endpoint、migration、生产 DB、Flutter 接线和账号回填均不在本任务。
4. 给出后继代码任务的精确可写路径、定向正负测试、失败回退和 Work LEVEL 2 审查证据，或列出仍缺的精确设计/来源门。

唯一可新增/修改路径为本目录 `plan.md`。最多两轮固定来源静态核对，报告已读/差异/SHA-256/`NOT_RUN`；不运行 PHPUnit、Composer、Artisan、Docker、构建、DB、SSH、备份/解密/恢复或 UAC。不访问旧 `D:\EliteSync`、GitHub、`.env`、真实账号、私钥、业务行或日志，不提交/pull/push。保留所有既有 modified/untracked。作者交付后停 Work LEVEL 2 独立审查，不自接受、不派发后继代码；BE-04/05 和 AUTH-152/153 的预算不重置。
