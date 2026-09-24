# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-12-MIGRATION-STATUS-PARSER-PREFLIGHT`

Risk Level: `LEVEL 2`（远端数据库元数据读取方法的本地预检；Work 独立审查）

Status: `WORK LEVEL 2 ACCEPTED`

Assignee: `Codex`。仅交付本地解析预检候选，停在 Work LEVEL 2 独立验收门。

## Authority and objective

AUTH-11 获 Work LEVEL 2 事实回执 ACCEPT，但其一次 SSH 的 `migrate:status` stdout 未通过安全格式解析；四条目标迁移及总数仍 `UNKNOWN`，原预算已耗尽。Work 对本地 Laravel `StatusCommand.php` 的静态检查见 `EVIDENCE/AUTH-11-DEPLOYED-MIGRATION-STATUS-READONLY/summary.md`。Owner 的未来改库前数据库备份、可恢复校验及仅限管理员创建测试账号本地导出授权继续有效；本任务不接触远端或真实 DB。

先核对本地 `main`、HEAD、工作区，读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能、AUTH-10/11 已接受记录。只有本任务仍为 `ISSUED` 且派发匹配才执行。

目标：只依据当前本地 Laravel `vendor/laravel/framework/src/Illuminate/Database/Console/Migrations/StatusCommand.php`、直接调用的双栏输出组件源码和 `php artisan migrate:status --help`，解释 CLI 行结构、ANSI/宽度/空行/批次号可能如何影响严格解析；提出**下一次若另行授权**的安全输出策略与本地解析接受条件。给出纯虚构迁移名的最小正反例，特别说明无法从 AUTH-11 未保存的 stdout 追溯具体失败原因。若从本地源码仍无法构造稳健解析，应明确建议换一种经另行审查的只读元数据接口，不得假装已有现场结论。

## Scope, verification and stop

唯一允许新增 `EVIDENCE/AUTH-12-MIGRATION-STATUS-PARSER-PREFLIGHT/spec.md`。可只读精确的项目控制文件、AUTH-10/11、上述 Laravel vendor 源码及其直接调用的 Console 输出组件；只定位必要直接依赖，不做全仓泛搜。无需运行数据库命令、产品测试或构建；`php artisan migrate:status --help` 最多 **1 次**，`git diff --check` 最多 **1 次**，新文档另作只读尾随空白检查。若需验证解析，可使用文档中的虚构静态字符串，不读取真实 stdout。

**不得 SSH、HTTP/API、读取 .env/凭据/日志/数据库行、访问设备或执行任何远端命令**；不读取、备份、导出、恢复或修改真实 DB。AUTH-11 的 SSH 预算不重置。不要输出或保存 AUTH-11 原始 stdout/stderr；不要推断四条迁移状态。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`；不访问旧 `D:\EliteSync`，不 pull/push GitHub。Codex 只交付候选，不自接受、提交、备份或派发后继；Work LEVEL 2 独立 ACCEPT/REJECT。任何再次读取服务器需另一张写明目标、命令、预算和停点的任务。
