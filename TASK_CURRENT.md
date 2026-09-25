# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-53-SERVER-OPENSSL-CAPABILITY-RECHECK`

Risk Level: `LEVEL 2`（真实服务器一次只读工具能力复核；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。仅交付一次有界 SSH 静态观察候选及受限回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。不得派给此前过长的 Codex 会话；使用新的、能核对本地状态的执行会话。

## Authority and objective

AUTH-51 的一次预算已耗尽，服务器 OpenSSL 版本与 AES-256-GCM 是否列出仍 `UNKNOWN`。AUTH-52 本地纯解析预检获 Work LEVEL 2 ACCEPT，但不能保证将来远端输出采集完整。Owner 已授权继续，要求 SSH 连接问题及时反馈。本任务只核对当次服务器工具层版本、`cms -help` 命令退出码和算法列表；不测试 CMS 加解密或真实备份。32GB U 盘与 Owner 密码此阶段均不需要。

## Exact execution boundary

- 启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、`.agents/skills/elitesync-local-workflow/SKILL.md`、AUTH-51 与 AUTH-52 验收；核对 `D:\EliteSync-v10` 本地 `main`、HEAD、工作区。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。若任务状态或派发不匹配，停止。
- 只允许向既有目标 `root@101.133.161.203` 发起 **1 次** SSH 连接，私钥仅为 `C:\Users\zcxve\.ssh\CodexKey.pem`，使用既有 `known_hosts`、`BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`。禁止换用户、换密钥、降低主机校验、重试或用浏览器/CloudShell 补跑。连接失败即停止，在本会话及时报告，不推测根因。
- 远端仅运行一段固定无副作用 shell 查询：`command -v openssl` 的布尔结果、`openssl version`、`openssl cms -help` 的退出码及 `openssl list -cipher-algorithms`。各子命令至多一次。不得运行加解密、密钥生成、文件写入、服务重启、数据库、Laravel 或云 API 命令。
- 调用前本地静态检查固定命令、结果分帧与异常处理；版本及算法列表使用已接受的 AUTH-52 解析器。SSH stdout/stderr 只在本机进程内有上限地完整读取；每个原始字段超过 65536 字符、采集超限/截断、分帧缺失或混乱、退出码异常、解析格式不符时，将受影响能力记为 `UNKNOWN` 并停止，不把部分输出当 `NOT_LISTED`。不得保存或显示原始输出、完整帮助文本、路径、环境变量、凭据或服务器文件内容。只保存脱敏版本 token、`LISTED/NOT_LISTED/UNKNOWN`、各命令退出码、连接预算和首个失败阶段。`NOT_LISTED` 仅表示该次完整采集的可解析列表未列出，不等于服务器不支持。
- 只允许新增 `EVIDENCE/AUTH-53-SERVER-OPENSSL-CAPABILITY-RECHECK/run.py`、`test_run.py`、`summary.md`。本地虚构分帧/截断测试最多 2 次；SSH 严格 1/1 次；`git diff --check` 最多 1 次，新文件另做只读尾随空白检查。不得修改已接受的 AUTH-52 解析器、产品源码、旧证据或控制文件。

## Stop and review

报告分阶段 `PASS/FAIL/NOT_CHECKED`，严格区分已观察事实与 `UNKNOWN`。工具可解析、命令退出 0、列表列出都不能证明服务器 CMS AES-256-GCM 端到端可用、与本机密文互通或真实备份/恢复能力。SSH 异常立即向 Owner 反馈；无论结果如何，连接预算耗尽后不得追加探测。

不得访问旧 `D:\EliteSync`、本机真实备份/密钥目录内容、真实 DB、账号、Token、消息或媒体；不读写 U 盘、不要求 Owner 输入密码、不制作密钥、备份或恢复。Codex 不提交、制作 bundle、推送、自接受或派发后继。真实密钥、传输、备份、解密、恢复、清理、改库与生产部署各需独立任务权限。
