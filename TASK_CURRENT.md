# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-09-SYNTHETIC-LOGIN-ANCHOR-TRANSITION`

Risk Level: `LEVEL 2`（认证计时锚的隔离纯判定；Work 独立审查）

Status: `WORK LEVEL 2 ACCEPT — SYNTHETIC CANDIDATE ONLY`

Assignee: `Codex`。隔离 synthetic/dev-test 候选及定向测试已获 Work 独立接受；见 `EVIDENCE/AUTH-09-SYNTHETIC-LOGIN-ANCHOR-TRANSITION/summary.md`。当前无活动 Codex 执行单；真实来源、持久化与客户端接线未建立。

## Authority and objective

Owner 已接受 `PRODUCT_DECISIONS.md` 最后两项；`EVIDENCE/AUTH-08-TRUSTED-LOGIN-ANCHOR-OFFLINE-CREDENTIAL-CONTRACT/contract.md` 获 Work LEVEL 2 ACCEPT。第一片只验证事件语义：服务端确认的成功交互登录才可形成或更新同账户、设备的 `T0`；refresh、register、启动、缓存恢复及 Token 更换均不得更新 `T0`；旧、重放、乱序、跨账户/设备事件不得覆盖当前锚。真实身份来源、事件签名、设备绑定、可靠时间、持久化和离线凭据仍未建立。

先核对本地 `main`、HEAD、工作区，读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能、AUTH-08 合同及 AUTH-07 静态缺口。只有本任务仍为 `ISSUED` 且派发匹配才执行。

在 backend Domain 新增**隔离纯判定**：输入全由调用方显式声明，输出只表示是否可形成候选 `T0` 及拒绝原因；不得命名或暴露为真实 authentication/authorization grant。已确认交互登录的调用方声明须同时包含账户、设备、可比较的严格递增事件顺序、`T0` 时间及来源确认；缺任一项拒绝。已有锚时，只有同账户/设备、严格更新顺序且时间不倒退的候选可替换；refresh/register/restore/token-rotation 无论是否有新 token 均保持原锚。未知、冲突或无效输入 fail-closed，不自行读取系统时间、不把 Token `created_at` 当 `T0`。纯判定器不签发回执、不开放离线读取或在线发送。

## Scope and verification

仅允许新增 `services/backend-laravel/app/Domain/SyntheticLoginAnchorTransitionEvaluator.php`、`services/backend-laravel/tests/Unit/SyntheticLoginAnchorTransitionEvaluatorTest.php`、`EVIDENCE/AUTH-09-SYNTHETIC-LOGIN-ANCHOR-TRANSITION/summary.md`。可只读相邻纯判定器及测试风格，不改 `AuthController`、routes、Sanctum、User、DB、Flutter、CACHE-06 或现有合同。测试至少覆盖首个确认登录、refresh/register/restore 不重锚、严格更新、重放/乱序、账户/设备不匹配、缺来源确认/顺序/时间与时间倒退；同时证明结果只是候选，不含读发 grant。最多运行 **2 次**精确新测试文件，**1 次**源码/测试语法或静态检查，**1 次** `git diff --check`；新文件另作尾随空白检查。失败记录并在预算内修正，不扩大测试或运行服务。

不连接服务器、不使用 SSH、HTTP/API、DB、设备或真实数据；不读 `.env`、私钥、实际 Token、日志、用户/媒体内容；不访问旧 `D:\EliteSync`，不 pull/push GitHub。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。Codex 不自接受、不提交、不备份、不推送、不派发后继。Work LEVEL 2 独立 ACCEPT/REJECT；本任务不建立真实 `T0` 来源、15/30 天期限执行或生产认证。
