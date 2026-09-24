# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-11-DEPLOYED-MIGRATION-STATUS-READONLY`

Risk Level: `LEVEL 2`（目标服务器数据库元数据只读观察；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。仅交付本任务的事实回执，停在 Work LEVEL 2 独立验收门。

## Authority and objective

AUTH-10 docs-only 设计已获 Work LEVEL 2 ACCEPT，见 `EVIDENCE/AUTH-10-LOGIN-EVENT-PERSISTENCE-DB-BACKUP-DESIGN/plan.md`。Owner 已授权在未来确需修改阿里云后端数据库结构时先备份并校验可恢复性，并允许仅将管理员创建的现有测试账号信息导出本地供恢复，禁止上传到阿里云以外其他地方。本任务是该前置链的**一次只读迁移账本观察**，不实施备份、导出、恢复或改库，不推定部署库只有测试账号。

先核对本地 `main`、HEAD、工作区，读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能及 AUTH-10 接受记录。只有本任务仍为 `ISSUED` 且派发匹配才执行。

目标：在已知部署目录 `/opt/elitesync/services/backend-laravel` 运行一次 Laravel `migrate:status`，仅报告命令是否成功、迁移账本是否可读，以及本地四个精确迁移名在远端输出中的状态：`0001_01_01_000000_create_users_table`、`2026_03_11_144705_create_personal_access_tokens_table`、`2026_03_23_200000_add_synthetic_flags_to_users_table`、`2026_04_09_120000_add_account_layer_fields_to_users_table`。另记录输出中迁移总数和已运行/待运行数量；这些仅是本次 CLI 连接视图，不证明 Web worker 使用相同配置、实际表结构、备份可用或数据分类。

## Exact remote budget and handling

仅用已由 AUTH-02 证明可认证的 `root@101.133.161.203` 和 `C:\Users\zcxve\.ssh\CodexKey.pem`。先本地检查私钥和既有 `known_hosts` **是否存在**，不读取其内容。SSH 进程调用最多 **1 次**，使用 `BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`，关闭密码和键盘交互，外部等待上限 **30 秒**；不重试、不换用户/密钥/主机。唯一远端命令为：`cd /opt/elitesync/services/backend-laravel && php artisan migrate:status --no-interaction`。远端命令不得追加探测、重定向写文件或执行 `migrate`、`db:show`、SQL、备份、服务管理。

在本地进程内接收 stdout/stderr，原始输出上限 **128 KiB**；超限、超时、非零退出、认证失败、输出无法解析或含意外敏感值即停止，只报告错误类别和可安全披露的事实，不转储原文。正常时只在回执报告上述四条精确迁移名的状态及脱敏汇总；不保存原始 stdout/stderr，不输出数据库名、主机内部地址、用户名、连接串、环境变量、账号或其他迁移清单。任何实际行内容、Token、密码或媒体一律不读取。

## Scope, verification and stop

唯一允许新增 `EVIDENCE/AUTH-11-DEPLOYED-MIGRATION-STATUS-READONLY/summary.md`。本地只读范围为任务控制文件、AUTH-10 接受记录、上述四个精确迁移文件和必要的本地 Laravel `migrate:status --help`；不做全仓泛搜。无需产品测试或构建。`git diff --check` 最多 **1 次**；新文档另作只读尾随空白检查。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。

本任务不得读取 `.env`、私钥内容、实际配置值、账号行、Token、日志或用户/媒体数据；不运行 HTTP/API、设备操作或真实数据库写入；不访问旧 `D:\EliteSync`，不 pull/push GitHub。若一次远端读取失败或出现目标/权限/输出歧义，即停止，不以第二次 SSH 修复。Codex 只交付候选，不自接受、提交、备份或派发后继。Work LEVEL 2 独立 ACCEPT/REJECT；后续任何备份、导出、恢复或 schema 变更另立精确任务和对应 Owner 高风险门。
