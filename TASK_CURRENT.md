# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-35-LOCAL-SYNTHETIC-AUTH-READINESS-PROBE`

Risk Level: `LEVEL 2`（本机虚构 MariaDB 认证与就绪阶段探针；Work 独立审查）

Status: `WORK LEVEL 2 REJECTED — PREFLIGHT FACT RECEIPT ACCEPTED`

Assignee: `Codex`。只交付本任务的一次受限虚构容器探针和回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

Work 验收：本次 daemon 预检为 `DAEMON_UNREACHABLE`，未启动容器或执行认证探针；AUTH-35 目标 LEVEL 2 REJECT，仅接受受限失败回执，见 `EVIDENCE/AUTH-35-LOCAL-SYNTHETIC-AUTH-READINESS-PROBE/summary.md`。一次预算已耗尽，不得据此重试；下一步须另立本机服务启动/复核任务。

## Authority and objective

Owner 在 AUTH-34 验收后要求继续推进，先前“本次任务后暂停”已解除。AUTH-34 的一次虚构运行首次认证 `SELECT 1` 返回 `AUTH_OR_CONNECTION`，原始错误未保留；不能区分认证拒绝与连接尚未就绪，也不能推断 AUTH-33 合并 setup 的原因。AUTH-34 预算已耗尽。本任务用**新的一个**本机隔离虚构容器，在固定时间点观察同一认证 `SELECT 1` 是否转为成功，并只提取 MariaDB 固定数字错误码。它不创建 schema、表或行，不运行 dump/restore，不接触真实数据库或备份。

## Exact local execution and output

- 预检本机 Docker context、daemon、固定本地 `mariadb:10.11` 镜像与唯一容器名 `elitesync-auth35-auth-probe` 空闲；任一失败即停。不启动 Docker Desktop、不拉取镜像或换 context。只读加载 AUTH-32 已接受 `parse_mounts.ps1` 并核对 SHA-256 `AA11EA742604C2EA9B76EF81EA8C4CD19E678D1C4E368AD421EB38D66F20D974`。
- 最多一次启动固定容器：`--pull never`、`--network none`、无端口/宿主 bind/命名卷，数据、运行和临时目录仅用 `/var/lib/mysql`、`/run/mysqld`、`/tmp` 三个 tmpfs；使用与真实项目无关的固定虚构 root 密码。启动后先核对本次容器 ID/名称、NetworkMode、PortBindings、Binds、HostConfig.Tmpfs 与经 AUTH-32 解析器处理的 Mounts；与 AUTH-34 同等 fail-closed，任一不符即停。
- 仅在隔离声明全部通过后，以**和 AUTH-34 相同的** `docker exec -e MYSQL_PWD=... <container> mariadb -uroot --batch --skip-column-names -e 'SELECT 1;'` 形式，在启动后约 20、40、60 秒各最多执行一次；前一次成功则不执行后续探针。不得用 `mariadb-admin ping` 代替认证，不改密码、协议或客户端选项。只将输出严格等于 `1` 且退出 0 判为成功。失败时在内存中解析 stderr 中单个 `ERROR <数字>`；只允许记录错误码 `1045`、`2002`、`2003`、`2013` 或 `UNRECOGNIZED/UNKNOWN`，不得记录原始 stderr/stdout 或任何环境变量。若错误码无法唯一、安全解析，立即停止后续探针。持续失败只说明该虚构容器在这些时间点的观察，不能推断真实 DB。
- 最后可只读 inspect 本次容器的固定 `State.Running`/`State.ExitCode`/`State.Restarting` 投影各最多一次；不读取日志。无论成功失败，仅对本任务确实创建且归属可验证的容器按 ID 精确清理最多一次，按名称只读核对不存在。归属不明不删除并报 `CLEANUP_UNRESOLVED`；不得触碰其他容器/卷/镜像或 broad prune。总执行含清理不超过 120 秒。回执仅列固定阶段、最多三个探针的结果/安全码、调用账本、耗时与清理状态。

## Allowed candidate and stop

只允许新增 `EVIDENCE/AUTH-35-LOCAL-SYNTHETIC-AUTH-READINESS-PROBE/run.ps1` 与同目录 `summary.md`；不得修改 AUTH-32～34 或控制文件。先静态解析与安全边界检查，满足后脚本最多执行 1 次。任何失败不修改脚本重跑；若出现未能按 ID 清理或归属不明，记录为清理风险并停止。Work 独立审查代码、调用账本与安全分类；作者测试不构成接受。AUTH-35 的任何结果均不证明 AUTH-33 原因、虚构 dump/restore、真实数据库身份或真实备份可恢复；后继需另立任务。

启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能及 AUTH-32～34 记录；核对 `D:\EliteSync-v10`、`main`、HEAD、工作区。派发前接受检查点 `04c64c28206ad6fd32a8763ebd858bf36a5e4704`；当前 HEAD 应为仅下达本任务的检查点，父提交须为该基线。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。前置不符即停。

`git diff --check` 最多 1 次，新文件另作只读尾随空白检查。不得访问旧 `D:\EliteSync`、浏览器、SSH、云 API、真实 DB、备份目录、真实凭据/密钥、账号/Token/消息/媒体或业务数据；不下载软件、不运行任何写 SQL、不 dump/restore、不真实备份/传输/改库。Codex 不提交、不制作 bundle、不推送、不自接受或派发后继。
