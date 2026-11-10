# BE-10｜synthetic live gate 使用点与提交时复核

状态：`ISSUED — CODE`。风险 LEVEL 2（双输入保护性使用点；仅 synthetic/dev-test、无真实 I/O）。派发最新合资格 Codex 会话 `01a0ddd0-bab2-7673-bf5b-03dbfbc066e4`；交付后停 Work 独立 LEVEL 2 审查。

## 权威、允许路径与交付

先核对 `D:\EliteSync-v10` 本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`、`TASK_CURRENT.md` 当前状态及脏工作区。固定来源为根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`、本地 workflow/runtime-slice 技能、BE-09 `plan.md`/`work-review.md`、BE-08 `work-review.md`、`MessagingConsentConversationLiveGateEvaluator.php` 与其 Unit test、`MessagingConsentPersistenceApplicationAdapter.php` 与其 Unit test。不得自行搜索旧仓库或其他来源扩大范围；固定来源缺口记 `NOT_READY`。

唯一允许新增/修改：

1. `services/backend-laravel/app/Domain/MessagingConsentSyntheticLiveGateUsePoint.php`
2. `services/backend-laravel/tests/Unit/MessagingConsentSyntheticLiveGateUsePointTest.php`
3. `EVIDENCE/BE-10-SYNTHETIC-LIVE-GATE-USE-POINT/summary.md`

现有 BE-05/08 代码、evaluator、应用边界、Composer、数据库与其他文件一律不改。仅用 PHP 数组/进程内存构造虚构证据和动作计数，不接文件、网络、消息存储或真实账号；不新增 HTTP route、migration、auth/session、writer。所有返回值须明确 `synthetic_only=true`、`message_sent=false`、`conversation_content_read=false`，不得返回真实权限 token 或生产授权语义。

## 最小行为

- 实现两个明确分开的调用入口：`attemptReadSynthetic(...)` 在任何私密 sentinel 生成前，从**进程内 synthetic snapshot provider**当次取 CN 与 read-purpose MC，调用现有六参数 `evaluateLiveGates(...)`，仅当 `live_read_allowed === true` 才生成一次无业务内容的 read sentinel；send 结果不得借用。`attemptSendSynthetic(...)` 在该入口代表的提交点重新取 CN 与 send-purpose MC，独立调用 evaluator，仅当 `live_send_allowed === true` 才生成一次 send sentinel；先前 read/send 结果、BE-08 关联投影不得用于放行。若提供 read/send 另一 purpose 的 evaluator 参数，也只能作为独立虚构输入，不能使目标 purpose 的缺失变为许可。
- Provider 必须是文件内或新类内明确定义的**纯内存测试端口**，只保存虚构快照并暴露调用次数；不得接受可调用任意 I/O 的 callback/closure、真实 repository/transport 或预构造的私密 payload。实现者可用 `final` 小类或受限数组值对象，但所有选择须能在 Unit test 中观察取证、求值、sentinel 顺序。若在这三个路径内无法同时保证无外部 I/O 和时序可测试，停止为 `NOT_READY`，不要用任意 callback 绕过。
- 精确绑定 context：Connection identity、两名参与者、目标 audience、read/send 独立 consent identity 与 purpose。缺失、类型错、跨 context/participant/audience、非当前/非 fresh、revision 失效、CN/MC 非 active、来源错误/超时或两次取证间变化时 fail closed，目标 sentinel 计数 0。不同 purpose 可以有独立结果，不能以 read 成功暗示 send 成功。不要实现实际 consent transition、消息正文、历史访问或持久化。
- 任何结构化结果仅含 synthetic 状态、目标动作是否产生 sentinel、调用/计数、受限 reason；不得把 evaluator 内部的 `source_authority=false` 改写成 true。`MC_TRANSITION` 持久化不在本任务范围。

## 定向验证预算与停点

允许对上述两份新 PHP 文件各运行 `php -l` **一次**。允许对新 Unit test、现有 evaluator Unit test、现有 BE-08 adapter Unit test 各首跑 **一次**；只有首跑失败的**同一文件**可在修复后复跑一次，不能扩大到完整套件。测试须覆盖同 context 的 read/send 正例、CN/MC 分别缺失/非 active、read/send purpose 互换、audience/参与者错配、旧 revision、失效、read 后 send 提交前 MC 或 CN 变化、提前 sentinel 被拒、provider 取证次数和对应动作计数。旧 BE-07/08 测试预算不重置。

交付 `summary.md` 记录精确差异、文件 SHA-256、每项实际验证与计数、失败/未运行、`synthetic_only` 限制和回退（移除本次新增切片但保留 BE-08 已接受状态）；不自接受、不执行后继。若测试失败且新预算耗尽，保留候选与失败回执停审，不自动重跑。不得运行 Composer/Artisan、真实 DB、容器、备份/解密/恢复、SSH/云/生产系统、Git commit/pull/push；不读 `.env`、真实账号、密码哈希值、业务行或旧 `D:\EliteSync`。
