# BE-11｜本地旧消息路由与双输入 live gate 缺口审计

状态：`ISSUED — DOCS-ONLY`。风险 LEVEL 3（私密会话/消息的真实路由与已接受 live gate）。派发 Codex 会话 `01a0ddd0-bab2-7673-bf5b-03dbfbc066e4`；唯一交付本目录 `plan.md`，交付后停 Work 独立 LEVEL 3 审查。

## 固定来源与范围

先核对 `D:\EliteSync-v10`、本地 `main`/HEAD、dirty 工作区与 `TASK_CURRENT.md`。只读根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`、`.agents/skills/elitesync-local-workflow/SKILL.md` 及以下精确文件：

- `services/backend-laravel/routes/api.php`
- `services/backend-laravel/app/Http/Controllers/Api/V1/MessageController.php`
- `services/backend-laravel/app/Http/Controllers/Api/V1/ConversationController.php`
- `services/backend-laravel/app/Services/ConversationCapabilityService.php`
- `services/backend-laravel/app/Services/ConversationAtomicSendService.php`
- `services/backend-laravel/app/Services/ConversationDomainService.php`
- `services/backend-laravel/tests/Feature/MessageApiTest.php`
- `services/backend-laravel/tests/Feature/ConversationCapabilityFoundationTest.php`
- `docs/architecture/ELITESYNC_V10_BACKEND_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md`
- `docs/architecture/ELITESYNC_V10_CONVERSATION_DATA_RIGHTS_DECISION_CLOSURE_OWNER_ACCEPTANCE_V0_1.md`
- `EVIDENCE/BE-09-MESSAGING-LIVE-GATE-APPLICATION-CONTRACT/work-review.md`
- `EVIDENCE/BE-10-SYNTHETIC-LIVE-GATE-USE-POINT/work-review.md`

只允许新增/修改 `EVIDENCE/BE-11-LEGACY-MESSAGING-ROUTE-LIVE-GATE-AUDIT/plan.md`。固定来源不足时逐项写 `UNKNOWN/NOT_CHECKED`，不扩展搜索、读取其他仓库或把索引/历史摘要当最新代码证明。

## 唯一结果

1. 对 `/messages` 读、发、已读标记及 `/conversations` 列表/详情/创建、`/conversation-peers/{peerUserId}` 做路由→控制器→能力/服务→私密数据构造或写入点的精确矩阵。区分 route 已注册、代码路径可达、真实运行/部署未知；不声称线上暴露或真实账号受影响。
2. 将旧 `DatingMatch`/`Conversation`/block 判断与已接受的当次 `CN_ACTIVE` + 独立 `MC_ACTIVE`、participant/audience/purpose/currentness/revision/freshness/context 绑定逐项比较。明确哪些入口在私密内容构造、读回、标记已读、发送提交和通知之前缺少可信双输入；不要把 BE-10 synthetic sentinel 当真实门。
3. 给出最小**后继代码任务候选**：在可信来源不存在时的 fail-closed 停点、精确影响文件与路由、保留既有非私密行为的界限、负向用例、定向测试、回退和兼容风险。仅建议，不在本任务改路由、配置、服务或测试，不执行任何真实消息。
4. 标明仍需独立合同的来源签发/获取、auth/session、原子提交与历史内容访问；任何修复候选不得以 `DatingMatch`、已有会话、缓存或旧测试通过代替 `MC_ACTIVE`。只读旧代码事实、已接受设计和拟议修复要分开。

## 预算与停点

最多两轮固定来源静态核对；只运行精确文件存在性、有限源码读取/字符串搜索、`git diff --check` 与交付文件哈希。`plan.md` 记录实际核对轮数、关键路径/方法、文件差异、`NOT_RUN`。不跑 PHPUnit、Composer、Artisan、DB、SSH、云、生产 API、真实消息/媒体、备份/解密/恢复，不提交、拉取或推送。保留全部无关 modified/untracked；旧 AUTH/BE 预算不重置。作者只交候选，停 Work LEVEL 3 ACCEPT/REJECT；不自接受或启动后继。真实路由代码变更、生产部署及真实数据操作均未授权。
