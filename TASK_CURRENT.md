# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-26-LOCAL-RESTORE-HOST-READINESS`

Risk Level: `LEVEL 2`（本机隔离恢复环境准备的受限只读事实；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。只交付固定事实回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

Owner 于 2026-09-24 决定：完整数据库备份加密保存到自己的电脑或本地磁盘，恢复演练优先在其电脑上的独立环境进行，先核验能否安全隔离并恢复。加密、备份完成日起 30 天保留、改库前先备份并验证可恢复继续有效。AUTH-25 是决定本地演练地点前的 docs-only 历史方案；不得据其云内恢复方向创建资源。本任务只核验本机少量恢复运行工具的命令存在性和 C:/D: 可用空间，**不证明隔离、可恢复或可存放真实数据**。

## Exact local read-only budget

在 PowerShell 中一次性、按固定顺序检查以下五项，只把白名单值写入证据：`docker_cli`、`podman_cli`、`wsl_cli` 各为 `present`/`absent`/`UNKNOWN`；`C_free_bytes` 和 `D_free_bytes` 各为非负整数或 `UNKNOWN`。命令存在性使用 `Get-Command`，仅取存在布尔值，不记录可执行路径、版本或帮助内容。磁盘可用空间使用 `Get-PSDrive` 的 `Free` 字段，仅取字节数，不枚举目录、卷标签、文件、其他盘或设备序列号。每项最多一次查询；单项异常记 `UNKNOWN`，不换方法、不重试。不运行 docker、podman、wsl 本身，不启停守护进程、虚拟机或容器，不安装软件，不读取镜像/发行版/容器清单。进程内的原始对象不落盘或显示，仅输出固定五项摘要。

## Allowed candidate and stop

唯一允许新增 `EVIDENCE/AUTH-26-LOCAL-RESTORE-HOST-READINESS/summary.md`。记录本地 `main`/HEAD/工作区前置、五项固定结果、查询是否异常、执行预算及边界：CLI 存在不等于服务可用、隔离成立或可以恢复；磁盘 Free 不等于已授权目标或可容纳加密备份/恢复临时文件。列出后继合成数据隔离验证前需确认的目标目录、权限、自动同步、容器/VM 可用性、网络断开方式、清理责任；不得对真实数据库下结论。

启动前读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能、AUTH-24/25 接受记录。派发前已接受基线 `390749cc8e6ccfa41b0913aaadc6f977467e03bc`；当前 HEAD 应为仅记录 Owner 新决定并下达本任务的检查点，父提交须为该基线。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。若任务状态、拓扑或工作区不符即停，不自行修复。

`git diff --check` 最多 1 次，新文档另作只读尾随空白检查；无产品测试或构建。不访问旧 `D:\EliteSync`、浏览器、SSH、云 API、数据库、备份目录、凭据、密钥、账号/Token/消息/媒体或业务数据行。不创建文件/容器/VM、不备份、不传输、不恢复、不删除、不改库。Codex 不修改控制文件、不提交、不制作 bundle、不推送、不自接受或派发后继。
