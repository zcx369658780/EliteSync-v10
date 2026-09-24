# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-17-ALIYUN-DB-BACKUP-HOST-READINESS`

Risk Level: `LEVEL 2`（未来数据库备份的服务器工具与空间只读事实；Work 独立审查）

Status: `WORK LEVEL 2 ACCEPTED`

Assignee: `Codex`。仅交付一次受限主机事实回执，停在 Work LEVEL 2 独立验收门。

## Authority and objective

AUTH-14/16 已确认部署目录当次 CLI 迁移账本及固定结构投影；MySQL driver 已报告，但目标数据库实例、数据范围、备份工具、可用空间、恢复目标和备份可恢复性仍 `UNKNOWN`。Owner 要求未来若修改阿里云后端 DB 结构，必须先备份并校验可恢复；允许仅将现有管理员创建的测试账号信息受控导出本地用于恢复，禁止上传到阿里云以外其他地方。本任务只核对**阿里云主机上**的备份工具与现有 `/var/backups` 目录是否可作为候选，不访问 DB、不创建备份、不导出数据。

先核对本地 `main`、HEAD、工作区，读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能及 AUTH-10/14/16 接受记录。只有本任务仍为 `ISSUED` 且派发匹配才执行。

## Exact one-shot remote read

仅用 `root@101.133.161.203`、`C:\Users\zcxve\.ssh\CodexKey.pem` 和已有 `known_hosts`；本地只检查私钥、主机密钥文件存在，不读取内容。SSH 进程调用 **最多 1 次**，`BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`，禁用密码和键盘交互、不分配 PTY；外部等待上限 **20 秒**，stdout/stderr 合计上限 **16 KiB**。唯一远端命令为 `command -v mysqldump && mysqldump --version && df -Pk /var/backups && test -d /var/backups && test -w /var/backups && printf 'AUTH17_OK\n'`。这里的 `test -w` 只核对权限位，不创建文件；`/var/backups` 仅为候选路径，不授权以后在那里写入。不得改用其他目录、工具或命令；任一环节失败即停，不重试。

原始 stdout/stderr 仅在本地进程内接收，不保存或全文显示。只有退出 0、stderr 为空、出现唯一固定标记 `AUTH17_OK` 且其余行能安全解析时，才记录 `mysqldump` 是否存在及**版本号**、`/var/backups` 是否存在/当前用户可写、`df` 报告的可用 KiB；不报告设备名、挂载点、完整工具路径或其他原始文本。非零退出、超时、超限、标记缺失、格式/敏感值歧义均只报告安全错误类别，其他结果保持 `UNKNOWN`。可用空间不是数据库大小或完整备份可存放证明；工具存在不是备份/恢复能力证明。

## Scope, verification and stop

唯一允许新增 `EVIDENCE/AUTH-17-ALIYUN-DB-BACKUP-HOST-READINESS/summary.md`。本地只读范围限控制文件、AUTH-10/14/16 已接受记录及 Git 状态。无需产品测试或构建；`git diff --check` 最多 **1 次**，新文档另作只读尾随空白检查。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。

不得读取 `.env`、私钥内容、连接串、DB schema/行、账号、Token、日志或媒体；不得运行 DB 命令、备份、导出、恢复、迁移、HTTP/API、设备或部署操作。AUTH-16 的 SSH 预算不重置。不访问旧 `D:\EliteSync`，不 pull/push GitHub。Codex 不自接受、提交、备份或派发后继；Work LEVEL 2 独立 ACCEPT/REJECT。实际数据库备份、隔离恢复演练、账号导出或结构变更须另立精确任务及 Owner 高风险门。
