# BE-01｜Messaging Consent / Conversation live gate 后端持久化映射

状态：Work 派发任务；`docs-only`，LEVEL 2。仅为下一段本地 synthetic/dev-test 后端实现确定技术边界，不授权代码、真实账号、生产数据库或迁移。

## 来源与顺序

Owner 于 2026-09-27 要求按 EliteSync-v10 当前交付计划优先推进软件和后端，待后端修改后再考虑从现有加密备份回填账号信息；账号范围在逐对象结构核对后再决定。`docs/architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md` 的 M2→M3 顺序是历史计划输入，以 `CURRENT.md` 和本地接受记录更新：R18-R1 Product Connection synthetic/dev-test persistence/application 已接受，APP-INT-01～05 本地主循环已接受，真实 auth/session、writer、生产 backend 与 DB 仍未建立。备份未证明可恢复，真实改库和账号回填仍停在独立门。

## 唯一结果与允许范围

只写 `EVIDENCE/BE-01-MESSAGING-CONSENT-PERSISTENCE-MAPPING/plan.md`。先只读核对根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地工作流技能，以及下列固定来源：

- `docs/architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md`（历史排程，以当前状态覆盖）；
- `docs/architecture/ELITESYNC_V10_IP_13I_R18_R1_PRODUCT_CONNECTION_APPLICATION_BINDING_ORDER_CORRECTION_ACCEPTANCE_V0_1.md`；
- `docs/architecture/ELITESYNC_V10_BACKEND_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_TECHNICAL_DESIGN_V0_1.md` 与同名 `_ACCEPTANCE_V0_1.md`；
- `services/backend-laravel/app/Domain/MessagingConsentConversationLiveGateEvaluator.php` 及其同名 Unit test；
- `services/backend-laravel/app/Domain/ProductConnectionPersistenceApplicationAdapter.php` 及其同名 Unit test，作为已接受开发态结构对照，不能借权；
- `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`、`SqliteInMemoryLogicalPersistenceAdapter.php`、`PersistenceBoundaryApplicationInterfaceIntegrationContract.php` 与 `services/backend-laravel/tests/Unit/ProductConnectionPersistenceFamilyTest.php`。

若固定来源不足，可在 `plan.md` 明确指出精确缺口与所需补读路径，先停，不作全仓搜索或自行扩大读取。既有未提交和未跟踪内容全部保留。不得访问旧 `D:\EliteSync`、GitHub、`.env`、真实备份、私钥、业务行或日志。

## 需要回答的问题

1. 在当前 R18-R1 已接受的开发态持久化／应用层后，BA-05 的**独立** Messaging Consent 权威证据应如何作为最小下一片进入现有逻辑持久化边界？明确复用或新增 family 的理由，严禁把 Product Connection 的 `CN_ACTIVE` 直接当作 `MC_ACTIVE`。
2. 固定 MC aggregate/context/两参与者/用途、请求者和接收者、当前 source-local revision、幂等身份、终态新身份、撤回/撤销和 correction/supersession 的输入输出与失败停点。跨 Connection、过期、不新鲜、冲突、乱序、重放、缺失或 `UNKNOWN` 均 fail closed。
3. 分开定义持久化记录、派生 live-read/live-send 投影、当前有效权限与传输结果；send 必须在提交时复核独立 CN 与 MC 两输入。历史 Conversation 读取、保留/删除/导出、消息正文、Safety、真实身份、Token/离线凭据不在本任务内。
4. 给出一个**后继可执行的最小代码任务**：精确允许源码/测试路径、先后步骤、定向测试与负向用例、失败回退和 Work LEVEL 2 审查证据。若现有接口无法承载，标为 `NOT_READY` 并指出需要先接受的设计；不得直接增 endpoint、migration、生产 writer 或 Flutter 接线。

最多两轮本地静态核对；记录实际读取和 `NOT_RUN`。不运行 PHPUnit、Composer、Artisan、Docker、SSH、DB、UAC、备份、解密、恢复或构建；不提交、拉取或推送。作者交付后停在 Work 独立 LEVEL 2 审查，不自接受、不派发实现。此任务不重置 AUTH-152/153 的任何预算。
