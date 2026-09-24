# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-27-LOCAL-DOCKER-ISOLATION-PREFLIGHT`

Risk Level: `LEVEL 2`（本地隔离恢复运行端点的受限只读事实；Work 独立审查）

Status: `WORK LEVEL 2 ACCEPTED`

Assignee: `Codex`。只交付受限只读事实回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

Owner 已选择完整数据库备份加密保存在自己的电脑或本地磁盘，恢复演练优先用电脑上的独立环境，先核验安全隔离与恢复能力。AUTH-26 仅确认本机 PowerShell 能解析 Docker/WSL 命令，不证明 Docker 守护进程、镜像或隔离可用。本任务只核对当前 Docker 上下文是否指向**本机**、本机 daemon 是否可读和固定 MariaDB 10.11 镜像是否已有本地副本；不运行容器或下载镜像。

## Exact read-only budget and parsing

1. `docker context inspect` 最多 **1 次**，只在进程内读取当前端点并将其归类为 `local_named_pipe`、`local_unix_socket`、`remote_or_other` 或 `UNKNOWN`；不记录原始端点、用户名、主机名、路径或证书内容。若非可确认的本机端点，后两项均为 `NOT_CHECKED` 并立即停止 Docker 查询。
2. 仅当第 1 项为确认的本机端点，`docker info` 最多 **1 次**，只记录 daemon 是否可达 `yes`/`no`/`UNKNOWN`；不输出/保存服务器详情。失败不启动 Docker Desktop、不重试、不换 context，镜像项为 `NOT_CHECKED`。
3. 仅当本机 daemon 可达，`docker image inspect mariadb:10.11` 最多 **1 次**，只记录该精确标签的本地镜像 `present`/`absent`/`UNKNOWN`。不列出其他镜像、容器、卷、网络或用户文件，不使用 registry 网络，也不拉取/构建/运行镜像。

任何命令异常或输出无法安全归类即记 `UNKNOWN` 并停止依赖项；只将固定三项归类和调用次数写入证据，不保存原始 stdout/stderr。若需要更广泛工具或不同镜像，另立任务，不能在本任务更换。

## Allowed candidate and stop

唯一允许新增 `EVIDENCE/AUTH-27-LOCAL-DOCKER-ISOLATION-PREFLIGHT/summary.md`。说明查询时点、固定结果、实际调用次数与未执行项；强调即使 daemon 可达且镜像在本地，也**不证明**网络隔离、数据保护、MariaDB 版本兼容、备份可恢复或 Owner 本地目标安全。仅建议下一个虚构数据隔离演练所需的独立授权与负向用例，不运行演练。

启动前读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能和 AUTH-25/26 接受记录；核对 `main`、HEAD 与工作区。派发前已接受基线为 `94def2ed3d49829d205af039e3d076c4c51311f8`；当前 HEAD 应为仅下达本任务的检查点，其父提交须为该基线。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。拓扑、任务状态或工作区不符即停，不自行修复。

`git diff --check` 最多 1 次，新文档另作只读尾随空白检查；无产品测试或构建。不访问旧 `D:\EliteSync`、浏览器、SSH、云 API、数据库、备份目录、凭据、密钥、账号/Token/消息/媒体或业务数据行。不创建、启动或删除容器/VM/卷/镜像，不备份、不传输、不恢复、不改库。Codex 不修改控制文件、不提交、不制作 bundle、不推送、不自接受或派发后继。
