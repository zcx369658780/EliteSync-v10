# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-14-DEPLOYED-MIGRATION-STATUS-STRICT-READ`

Risk Level: `LEVEL 2`（部署目录数据库迁移账本一次只读观察；Work 独立审查）

Status: `WORK LEVEL 2 ACCEPTED`

Assignee: `Codex`。仅交付一次受限事实回执，停在 Work LEVEL 2 独立验收门。

## Authority and objective

AUTH-11 的一次 `migrate:status` stdout 未通过安全解析，四条迁移状态仍 `UNKNOWN`；其 SSH 预算已耗尽。AUTH-12 输出边界合同和 AUTH-13 本地严格解析器已获 Work LEVEL 2 ACCEPT，解析器 12 项合成测试独立通过。本任务是**新下达的一次**只读观察，不是 AUTH-11 重试授权或其预算重置。Owner 要求未来若修改阿里云后端数据库结构，必须先备份并核验可恢复；仅允许管理员创建的现有测试账号信息受控本地导出，不上传到阿里云以外其他地方。本任务不备份、导出、恢复或改库。

先核对本地 `main`、HEAD、工作区，读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能与 AUTH-11～13 接受记录。只有本任务仍为 `ISSUED` 且派发匹配才执行。先在本地核对 AUTH-13 解析器文件存在并对**纯虚构输入**运行定向测试一次；测试失败即停，不连远端。

目标：仅报告本次部署目录 CLI 迁移视图中四条精确迁移名 `0001_01_01_000000_create_users_table`、`2026_03_11_144705_create_personal_access_tokens_table`、`2026_03_23_200000_add_synthetic_flags_to_users_table`、`2026_04_09_120000_add_account_layer_fields_to_users_table` 的 `Ran/Pending`，以及迁移总数/已运行/待运行数。只有完整输出通过 AUTH-13 原样解析器、stderr 为空、进程退出 0 时才可披露这些值；否则全部 `UNKNOWN`，只报安全错误类别。不得临时修改解析器、宽松匹配、显示原始输出或发第二次 SSH。

## Exact remote budget and data handling

仅用 `root@101.133.161.203`、`C:\Users\zcxve\.ssh\CodexKey.pem` 及现有 `known_hosts`；本地只检查二者是否存在，不读取内容。SSH 进程 **最多 1 次**，`BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`，禁用密码与键盘交互，不分配 PTY；外部等待上限 **30 秒**，stdout/stderr 合计内存接收上限 **128 KiB**。唯一远端命令为 `cd /opt/elitesync/services/backend-laravel && php artisan migrate:status --no-interaction --no-ansi`。不更换命令、路径、用户、密钥或主机；不追加 `--database`、`--pending`、SQL、配置读取、备份或服务操作。

原始 stdout/stderr 只在本地进程内传给已接受的 `EVIDENCE/AUTH-13-MIGRATION-STATUS-SAFE-PARSER/migration_status_parser.py`，不得打印、持久化、入日志或普通证据；本地工具调用输出只能是进程状态、字节数、安全类别及完整解析后的四目标与汇总。超时、超限、非零退出、非空 stderr、坏编码、解析拒绝、四目标缺失或其他歧义即停。解析成功只证明本次 CLI 所选连接的迁移账本视图，不证明实际 schema、账号范围、Web worker 配置、备份或生产行为。

## Scope, verification and stop

唯一允许新增 `EVIDENCE/AUTH-14-DEPLOYED-MIGRATION-STATUS-STRICT-READ/summary.md`。本地只读范围限控制文件、AUTH-11～13 接受证据、解析器/测试及四条精确迁移文件。除前述合成测试 **1 次**，无需产品测试或构建；`git diff --check` 最多 **1 次**，新文档另作只读尾随空白检查。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。

不得读取 `.env`、私钥内容、实际配置值、账号行、Token、日志或用户/媒体数据；不运行 HTTP/API、设备操作或真实数据库写入。不得备份、导出、恢复或迁移；不得访问旧 `D:\EliteSync`，不 pull/push GitHub。Codex 不自接受、提交、备份或派发后继；Work LEVEL 2 独立 ACCEPT/REJECT。未来任何数据库备份、恢复演练或结构变更另立精确任务及 Owner 高风险门。
