# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-43-LOCAL-EXPANDED-TMPFS-AUTH-PROBE`

Risk Level: `LEVEL 2`（扩大 tmpfs 的本机虚构容器密码认证与空间只读探针；Work 独立审查）

Status: `WORK LEVEL 2 ACCEPTED — SYNTHETIC PASSWORD AUTH FACT ONLY`

Assignee: `Codex`。只交付一次虚构容器只读认证候选与回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

Work 验收：512 MiB 数据 tmpfs 的本机虚构容器报告可用 `372552 KiB`，虚构密码环境变量与初始化值匹配，首次 `SELECT 1` PASS，容器按 ID 清理 PASS；作为受限观察获 LEVEL 2 ACCEPT，见 `EVIDENCE/AUTH-43-LOCAL-EXPANDED-TMPFS-AUTH-PROBE/summary.md`。未写 SQL 或运行 dump/restore，旧预算耗尽，后继须新任务。

## Authority and objective

AUTH-41 的 128 MiB 数据 tmpfs 在建表前报告剩余 0 KiB。AUTH-42 改用 512 MiB 后，无密码 socket `SELECT 1` 返回 `1045`，空间门和写入均未运行；这不能说明扩大空间后的密码方式是否可用。两项旧预算已耗尽。本任务**新授权一个**隔离虚构容器，在同样 512 MiB 数据 tmpfs 下只读核对固定虚构初始化密码是否传入，并比较该密码通过 `MYSQL_PWD` 环境变量与显式客户端参数的 `SELECT 1` 结果，同时读取 `/var/lib/mysql` 的固定剩余空间投影。不得写 SQL 或运行 dump/restore。

## Exact execution boundary

- 预检 Docker context 本机、daemon 可达、固定本地 `mariadb:10.11` 镜像存在且唯一容器名 `elitesync-auth43-expanded-auth` 空闲；任一不符即停。不启动 Docker Desktop、不拉取镜像或换 context。只读核对 AUTH-32 `parse_mounts.ps1` SHA-256 `AA11EA742604C2EA9B76EF81EA8C4CD19E678D1C4E368AD421EB38D66F20D974` 后加载。
- 最多一次启动固定容器，`--pull never`、`--network none`、无端口/宿主 bind/命名卷，三处 tmpfs 精确为 `/var/lib/mysql:rw,nosuid,noexec,size=512m`、`/run/mysqld:rw,nosuid,size=16m`、`/tmp:rw,nosuid,size=64m`；初始化密码只用本任务固定虚构值。先核对本次 ID/名称、NetworkMode、PortBindings、Binds、HostConfig.Tmpfs 的目标和大小、经 AUTH-32 解析的 Mounts，并在内存中比较本次容器 `Config.Env` 的 `MARIADB_ROOT_PASSWORD` 是否与该虚构值精确一致，仅记录布尔，不显示/保存环境变量原文；任一安全字段未知或不符即停。不启动截图中的旧容器或项目服务。
- 隔离全部 PASS 后等待到容器启动至少 45 秒，只读运行固定 `df -Pk /var/lib/mysql` 一次，严格解析本目标 `size_kib/used_kib/available_kib`；解析异常保持 UNKNOWN 并停止认证。接着用同一虚构密码以 `docker exec -e MYSQL_PWD=... mariadb -uroot --batch --skip-column-names -e 'SELECT 1;'` 最多一次；若退出 0 且 stdout 严格为 `1`，记 PASS 并停止。只有失败且安全数字码唯一为 `1045` 时，才以 `mariadb -uroot --password=<同一虚构密码> --batch --skip-column-names -e 'SELECT 1;'` 最多一次，不传 `MYSQL_PWD`；其他错误或 UNKNOWN 均不再试。第二次结果无论如何立即结束认证。不得用无密码连接、改协议/凭据/选项或执行写 SQL。
- 错误只在内存提取唯一 MariaDB `ERROR <数字>`，记录 1～65535 的数字或 UNKNOWN，以及 0～255 的退出码或 UNKNOWN；不得保存/显示原始 stdout/stderr、密码、环境变量/进程参数、Docker inspect/log、SQL 输出或容器 ID。无论结果，只对本次确实创建且归属可验证的容器按 ID 精确清理最多一次，再按固定名称只读核对不存在；归属不明不删除，报 `CLEANUP_UNRESOLVED`。不操作其他容器/卷/镜像或 broad prune。总运行含清理不超过 150 秒。

## Candidate, verification and stop

只允许新增 `EVIDENCE/AUTH-43-LOCAL-EXPANDED-TMPFS-AUTH-PROBE/run.ps1` 与同目录 `summary.md`；不得修改 AUTH-32～42 或控制文件。先 PowerShell 静态解析和安全边界检查，满足后脚本最多执行 1 次；任何失败不修改后重跑、不手动补命令。摘要列隔离布尔、tmpfs 整数、两种认证 PASS/FAIL/NOT_CHECKED 与安全码、调用次数、耗时、清理结果。即使 PASS，也只说明此虚构容器在该时点的密码认证，不证明真实 DB、写 SQL、dump/restore 或本地备份可恢复。Work 独立审查，作者不自接受；后继须新任务。

启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能及 AUTH-32～42 回执；核对 `D:\EliteSync-v10`、`main`、HEAD、工作区。派发前接受检查点 `f2ae6f108d3a0e166341f28885b0f4c012e94586`；当前 HEAD 应为仅下达本任务的检查点，父提交须为该基线。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。前置不符即停。

`git diff --check` 最多 1 次，新文件另作只读尾随空白检查。不得访问旧 `D:\EliteSync`、浏览器、SSH、云 API、真实 DB、备份目录、真实凭据/密钥、账号/Token/消息/媒体或业务数据；不下载软件、不真实备份/传输/改库。Codex 不提交、不制作 bundle、不推送、不自接受或派发后继。
