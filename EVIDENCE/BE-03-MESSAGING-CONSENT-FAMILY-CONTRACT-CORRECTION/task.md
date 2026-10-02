# BE-03｜MC 派生记录合同精确修订

状态：Work 派发给最新合资格 Codex 执行会话 `01a0ddd0-bab2-7673-bf5b-03dbfbc066e4`；LEVEL 2、`docs-only`。唯一结果为本目录 `plan.md`。BE-02 `plan.md` 经 Work 独立 REJECT，不能直接作代码授权；本任务是新的有界修订，不重置 BE-02 的 2/2。

只读固定来源：根 `AGENTS.md`、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 `elitesync-local-workflow`，BE-01 `plan.md`/`work-review.md`、BE-02 `task.md`/`plan.md`/`work-review.md`，以及 `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`、`InMemoryLogicalPersistenceRepositoryContract.php`、`MessagingConsentConversationLiveGateEvaluator.php` 和其同名 Unit test。无需重读其他历史文档；若精确来源不足，仅在结果中列缺口并停，不作全仓搜索。

只修三处：

1. 把 BE-02 的严格 bindings 与 revision 字段改成真实 Common Authority 键名和类型，区分派生 owner/actor 与来源 actor；给出可实现的精确 payload/record 形状。
2. 分开定义 `source_condition` 枚举与 `currentness/freshness` bool/null 的保守映射，逐项说明缺失、`UNKNOWN`、不新鲜、冲突、不可比和失效怎样 fail closed。不得因存储或投影成功产生 `PRESENT/true`。
3. 把 `MC_CURRENT_STATE` 与真实现有 evaluator 接口逐一对应：若只能从来源携带的 state evidence 构造脱敏当前态记录，明确其非权威性质以及 transition/gate evaluator 实际何时可调用；不可声称不存在的 `evaluateCurrent`。指出修订后 repository-only synthetic/dev-test 切片是否 `READY`，以及仍未建立的真实 MC writer/使用点权限门。

其余 BE-02 语义只有在与上述修订相容时才可保留；交付一份自洽、独立可读的合同，不能要求实现者拼接互相矛盾的两份文档。只允许新增/修改本目录 `plan.md`，保留既有工作区。最多一轮固定来源静态核对，记录实际读取、差异、SHA-256 和 `NOT_RUN`。不得改源码、运行测试/构建、接触 `.env`、真实账号、DB、备份、密钥、SSH、GitHub 或旧 `D:\EliteSync`；不提交/pull/push。作者交付后停 Work LEVEL 2 独立审查，不自接受或派发实现。
