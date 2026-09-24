# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-41-LOCAL-SYNTHETIC-TABLE-RESOURCE-PROBE`

Risk Level: `LEVEL 2`（本机隔离虚构建表失败的资源与安全错误投影；Work 独立审查）

Status: `WORK LEVEL 2 REJECTED — ZERO-FREE-SPACE FACT RECEIPT ACCEPTED`

Assignee: `Codex`。只交付一次虚构容器的固定诊断与受限回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

Work 验收：作者一次运行报告建表前虚构容器 `/var/lib/mysql` tmpfs `size=131072`、`used=131072`、`available=0` KiB，建表失败，后续错误类别和 State 投影未完成；AUTH-41 完整诊断目标 LEVEL 2 REJECT，仅接受受限数值与清理回执，见 `EVIDENCE/AUTH-41-LOCAL-SYNTHETIC-TABLE-RESOURCE-PROBE/summary.md`。不能断言空间是唯一根因；一次运行预算耗尽，后继须新任务。

## Authority and objective

AUTH-39/40 两次虚构运行都在原源表创建处失败；AUTH-40 的窄白名单输出为 `UNRECOGNIZED/UNKNOWN`，未能判断 SQL 语法、空间、权限、进程退出或其他原因。旧预算均耗尽。本任务**新授权一个**无网络虚构容器，只在同一原建表命令前后读取 `/var/lib/mysql` 的 tmpfs 剩余 KiB、该命令的退出码与安全错误投影，并观察容器固定状态字段。不插入数据、不执行 dump/restore，不接触真实数据库或备份。

## Exact execution boundary

- 预检 Docker context 本机、daemon 可达、固定本地 `mariadb:10.11` 镜像存在且唯一容器名 `elitesync-auth41-table-resource` 空闲；任一不符即停。不启动 Docker Desktop、不拉取镜像或换 context。只读核对 AUTH-32 `parse_mounts.ps1` SHA-256 `AA11EA742604C2EA9B76EF81EA8C4CD19E678D1C4E368AD421EB38D66F20D974` 后加载。
- 最多一次启动固定容器，`--pull never`、`--network none`、无端口/宿主 bind/命名卷，数据/运行/临时目录仅用 `/var/lib/mysql`、`/run/mysqld`、`/tmp` 三个 tmpfs；容器初始化密码只用本任务虚构值。先核对本次 ID/名称、NetworkMode、PortBindings、Binds、HostConfig.Tmpfs 与经 AUTH-32 解析后的 Mounts，任何未知或不符即停。不得启动截图中的旧容器或任何项目服务。
- 隔离通过后等待至本次容器启动至少 45 秒，以无密码本机 socket `mariadb -uroot` 各最多一次执行 `SELECT 1`、`CREATE DATABASE auth41_source`；任一失败即停。随后以 `docker exec` 对 `/var/lib/mysql` 运行固定 `df -Pk` 一次，只解析目标挂载的整数 `size_kib`、`used_kib`、`available_kib`，不保存原始行；解析不唯一即停止建表。执行与 AUTH-39 原命令等价的 `CREATE TABLE sample_items (id INT PRIMARY KEY, label VARCHAR(32) NOT NULL, amount INT NOT NULL);` 最多一次。成功即记录并停止诊断；失败可再只读执行同一 `df -Pk` 一次，并对本次容器 inspect 固定 `State.Running`、`State.ExitCode`、`State.OOMKilled` 投影一次，任何异常保持 UNKNOWN。
- 失败时仅在进程内存解析命令退出码（仅 0～255 的整数）、唯一 MariaDB `ERROR <数字>` 的数字码（1～65535，未唯一解析则 UNKNOWN），以及 stderr 是否匹配固定类别 `ENOSPC/NO_SPACE`、`READ_ONLY_FS`、`PERMISSION_DENIED`、`SQL_SYNTAX`、`OTHER/UNKNOWN`；多类别或不能可靠匹配则 UNKNOWN。不得保存或显示原始 stdout/stderr、容器日志/inspect、路径全文、SQL 输出、密码、环境变量、进程参数或容器 ID。不得修改 SQL、tmpfs 大小、认证方式或脚本后重跑。
- 无论结果，仅对本任务确实创建且归属可验证的容器按 ID 精确清理最多一次，再按固定名称只读核对不存在；归属不明不删除并报 `CLEANUP_UNRESOLVED`。不得操作其他容器/卷/镜像或 broad prune。总运行含清理不超过 150 秒。

## Candidate, verification and stop

只允许新增 `EVIDENCE/AUTH-41-LOCAL-SYNTHETIC-TABLE-RESOURCE-PROBE/run.ps1` 与同目录 `summary.md`；不得修改 AUTH-32～40 或控制文件。先 PowerShell 静态解析和安全边界检查，满足后脚本最多执行 1 次；任何失败不修改后重跑、不手动补命令。摘要列各阶段 PASS/FAIL/NOT_CHECKED、固定整数投影或 UNKNOWN、安全错误类别、调用次数、耗时和清理结果。即使定位某类资源问题，也不能据此修改真实服务端或宣称虚构/真实备份可恢复。Work 独立审查，作者结果不自接受；后继须新任务。

启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能及 AUTH-32～40 回执；核对 `D:\EliteSync-v10`、`main`、HEAD、工作区。派发前接受检查点 `38702e41635efb229c6aa9806469f5be86788651`；当前 HEAD 应为仅下达本任务的检查点，父提交须为该基线。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。前置不符即停。

`git diff --check` 最多 1 次，新文件另作只读尾随空白检查。不得访问旧 `D:\EliteSync`、浏览器、SSH、云 API、真实 DB、备份目录、真实凭据/密钥、账号/Token/消息/媒体或业务数据；不下载软件、不真实备份/传输/改库。Codex 不提交、不制作 bundle、不推送、不自接受或派发后继。
