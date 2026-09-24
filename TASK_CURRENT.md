# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-23-ALIYUN-BACKUP-HOST-CLIENT-READ`

Risk Level: `LEVEL 2`（阿里云服务器一次只读工具存在性观察；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。仅交付受限事实回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

Owner 选择优先核验阿里云私有 OSS 与受管密钥的可用性，并按阿里云内独立隔离恢复目标、恢复后清理演练副本及完整备份自完成日起 30 天保留的方向设计。AUTH-22 仅是 docs-only 准备决策包。本任务只观察当前部署主机是否存在 `ossutil`、`aliyun`、`openssl` 三个命令，为后继可用性核验缩小工具路线；**命令存在与否均不证明 OSS/KMS 资源、权限、加密或隔离恢复可用**。不调用云 API，不读取凭据或配置。

先核对本地 `main`、HEAD、工作区，读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能及 AUTH-17/18/20/22 接受记录。只有本任务为 `ISSUED` 且派发匹配才执行。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。

## Exact remote budget and output

仅使用 `root@101.133.161.203`、`C:\Users\zcxve\.ssh\CodexKey.pem` 和既有 `known_hosts`；本地只检查私钥和主机密钥文件存在，不读取内容。SSH 进程**最多 1 次**，`BatchMode=yes`、`IdentitiesOnly=yes`、`StrictHostKeyChecking=yes`、`ConnectTimeout=8`，禁用密码和键盘交互、不分配 PTY；外部等待上限 **30 秒**，stdout/stderr 合计上限 **8 KiB**。唯一远端命令须对三个固定命令名逐一使用 `command -v` 并仅输出以下固定三行、固定顺序，每个值为 `present` 或 `absent`：`ossutil=...`、`aliyun=...`、`openssl=...`。不得运行这三个工具本身，不得读取版本、路径、环境变量、云配置、bucket、key、数据库、文件清单或业务数据。

只有 SSH 退出 0、stderr 为空且 stdout 严格为上述三行时，才记录三个存在性布尔值；任何认证/网络/超时、输出异常、超限或非零退出均记录为 `UNKNOWN`，不得换用户、密钥、命令、主机或重试。原始 stdout/stderr 仅在本地进程内接收；只把固定白名单结果写入证据，不保存或显示原始输出。此预算与 AUTH-17/20 的旧 SSH 预算分离，旧预算不重置。

## Allowed candidate and stop

唯一允许新增 `EVIDENCE/AUTH-23-ALIYUN-BACKUP-HOST-CLIENT-READ/summary.md`。记录精确预检、一次 SSH 的退出/大小/解析状态及固定三项结果或 `UNKNOWN`，并明确本观察不能证明实际 OSS/KMS 访问、私有 bucket、密钥权限、备份上传、30 天生命周期或隔离恢复。`git diff --check` 最多 **1 次**，新文档另作只读尾随空白检查；无需产品测试或构建。

不得读取 `.env`、私钥内容、真实配置值、账号/Token/日志/媒体或业务数据行；不运行 HTTP/API、云 API、数据库操作、备份、导出、恢复、migration、部署或 GitHub pull/push。不访问旧 `D:\EliteSync`。Codex 不自接受、提交、备份或派发后继；Work LEVEL 2 独立审查事实回执。若后继需实际核验 OSS/KMS 账户资源与权限，必须另立具体任务及输出白名单。
