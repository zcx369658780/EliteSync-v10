# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-16-DEPLOYED-FIXED-SCHEMA-METADATA-READ`

Risk Level: `LEVEL 2`（目标服务器数据库固定结构元数据一次只读观察；Work 独立审查）

Status: `WORK LEVEL 2 ACCEPTED`

Assignee: `Codex`。仅交付受限事实回执，停在 Work LEVEL 2 独立验收门。

## Authority and objective

AUTH-14 的部署目录 CLI 迁移账本视图显示四条目标 `Ran`、57/57 已运行，但不证明实际 schema；AUTH-15 的本地固定范围元数据探针和虚构 adapter 测试已获 Work LEVEL 2 ACCEPT。Owner 要求未来若修改阿里云后端数据库结构，必须先备份并校验可恢复；仅允许现有管理员创建的测试账号信息受控导出本地供恢复，禁止上传到阿里云以外其他地方。本任务只用**新的一次** SSH 读取固定表/字段/单列唯一索引的存在性，不备份、导出、恢复或改库，也不读取账号行。

先核对本地 `main`、HEAD、工作区，读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能和 AUTH-14/15 接受记录。只有本任务仍为 `ISSUED` 且派发匹配才执行。先确认已接受探针 `EVIDENCE/AUTH-15-DB-SCHEMA-METADATA-PROBE-PREFLIGHT/metadata_probe.php` 的本地 SHA-256 **精确等于** `E290D5126EE59CFFEB752E75987DB6D5A2BE6D81A8F91F37AE6BD9EB82235E82`，并运行其虚构 adapter 测试 **1 次**；哈希或测试失败即停，不连远端。

## Exact remote budget and data handling

仅用 `root@101.133.161.203`、`C:\Users\zcxve\.ssh\CodexKey.pem` 和已有 `known_hosts`；本地只检查私钥、主机密钥文件是否存在，不读取内容。SSH 进程 **最多 1 次**，使用 `BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`，禁用密码和键盘交互、不分配 PTY；外部等待上限 **30 秒**，stdout/stderr 合计上限 **64 KiB**。唯一远端命令为 `cd /opt/elitesync/services/backend-laravel && php -d display_errors=0 -d log_errors=0`，其 stdin 仅是上述已接受的精确 PHP 文件字节；不得复制/上传为远端文件，不附加任何命令或参数，不改脚本。

本地进程内接收输出，不显示或持久化原始 stdout/stderr。只有退出 0、stderr 空、stdout 是单行严格 UTF-8 JSON、完整符合 AUTH-15 探针固定键/布尔/白名单 driver 形状且无额外字段时，才可报告 driver 与固定 `users`、`personal_access_tokens`、`migrations` 三表、指定字段和两个单列唯一索引的布尔投影。若 `ok=false`，只报告安全错误类别；超时、超限、非零退出、stderr 非空、JSON/形状不符或任何歧义均停并全部标 `UNKNOWN`，不重试、不宽松解析、不输出原文。`schema_complete` **仅指这些固定检查项全部存在**，不能写作完整 schema。框架 bootstrap 可能按其配置连接 DB；本任务不读取 `.env` 或输出配置值。即使成功，这只是当次 CLI 配置下的固定结构投影，不证明 Web worker 连接同库或备份可恢复。

## Scope, verification and stop

唯一允许新增 `EVIDENCE/AUTH-16-DEPLOYED-FIXED-SCHEMA-METADATA-READ/summary.md`。本地只读范围限控制文件、AUTH-14/15 接受证据、固定探针/虚构测试及四条精确迁移文件；无其他探测。除前述虚构测试 **1 次**，无需产品测试或构建。`git diff --check` 最多 **1 次**；新文档另作只读尾随空白检查。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。

不得读取账号、Token、日志、媒体或其他业务数据行，不运行 HTTP/API、设备、真实数据库写入、备份、导出、恢复或迁移；不读取私钥内容或实际配置值。AUTH-14 的 SSH 预算不重置。不访问旧 `D:\EliteSync`，不 pull/push GitHub。Codex 不自接受、提交、备份或派发后继；Work LEVEL 2 独立 ACCEPT/REJECT。未来备份、恢复演练或结构变更另立精确任务和 Owner 高风险门。
