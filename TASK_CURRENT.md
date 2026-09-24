# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-20-DEPLOYED-DB-TARGET-SIZE-READ`

Risk Level: `LEVEL 2`（部署目录当前 DB 目标与规模一次只读元数据观察；Work 独立审查）

Status: `WORK LEVEL 2 ACCEPTED`

Assignee: `Codex`。仅交付一次受限事实回执，停在 Work LEVEL 2 独立验收门。

## Authority and objective

AUTH-19 固定只读目标/规模探针及虚构检查已获 Work LEVEL 2 ACCEPT；AUTH-17 的工具/空间事实与 AUTH-18 的备份/恢复方案不证明实际数据库大小、服务端版本或备份可行。Owner 对完整备份存放及期限仍待决定。本任务只用**新的一次** SSH 对部署目录当前 Laravel DB 连接读取固定聚合元数据，不读取业务表或账号行，不备份、导出、恢复或改库。

先核对本地 `main`、HEAD、工作区，读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能和 AUTH-17/18/19 接受记录。只有本任务仍为 `ISSUED` 且派发匹配才执行。先确认已接受探针 `EVIDENCE/AUTH-19-DB-TARGET-SIZE-PROBE-PREFLIGHT/target_probe.php` 的本地 SHA-256 **精确等于** `22D97E89DAD575B1AC0778D298329644489F9BE3771253F8A7AB62D472038DDE`，并运行其虚构 adapter 测试 **1 次**；哈希或测试失败即停，不连远端。

## Exact remote budget and handling

仅用 `root@101.133.161.203`、`C:\Users\zcxve\.ssh\CodexKey.pem` 与既有 `known_hosts`；本地只检查私钥和主机密钥文件是否存在，不读取内容。SSH 进程 **最多 1 次**，`BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`，禁用密码和键盘交互、不分配 PTY；外部等待上限 **30 秒**，stdout/stderr 合计上限 **64 KiB**。唯一远端命令为 `cd /opt/elitesync/services/backend-laravel && php -d display_errors=0 -d log_errors=0`，stdin 仅送入上述已接受探针的原始文件字节；不得复制为远端文件、改脚本或追加探测。

原始 stdout/stderr 仅在本地进程内接收，不显示或持久化。只有退出 0、stderr 为空、stdout 为单行严格 UTF-8 JSON、完整符合 AUTH-19 固定键/类型/白名单且无重复或额外键时，才可记录 DB 家族与规范化版本、SHA-256 目标指纹、当次 `information_schema.tables` 表数和估算字节数。若 `ok=false`，只报告安全错误类别；超时、超限、非零退出、stderr 非空、JSON/形状不符或歧义均停止且所有目标值为 `UNKNOWN`。不得临时放宽解析、输出原始库名/主机名或发第二次 SSH。指纹仅供未来同一探针重复比较，不能证明 Web worker 同库；估算字节数不是 dump 大小或完整备份可存放证明。

## Scope, verification and stop

唯一允许新增 `EVIDENCE/AUTH-20-DEPLOYED-DB-TARGET-SIZE-READ/summary.md`。本地只读范围限控制文件、AUTH-17/18/19 接受记录、固定探针/虚构测试及 Git 状态。除前述虚构测试 **1 次**，无需产品测试或构建；`git diff --check` 最多 **1 次**，新文档另作只读尾随空白检查。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。

不得读取 `.env`、私钥内容、实际配置值、账号/Token/日志/媒体或其他业务数据行；不运行 HTTP/API、设备、数据库写入、备份、导出、恢复、迁移或部署。AUTH-17 的 SSH 预算不重置。不访问旧 `D:\EliteSync`，不 pull/push GitHub。Codex 不自接受、提交、备份或派发后继；Work LEVEL 2 独立 ACCEPT/REJECT。未来备份、恢复演练或改库须另立精确任务和 Owner 高风险门。
