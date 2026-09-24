# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-39-LOCAL-SYNTHETIC-SAME-CONTAINER-RESTORE`

Risk Level: `LEVEL 2`（本机单个隔离虚构容器内的小样本 dump/restore；Work 独立审查）

Status: `WORK LEVEL 2 REJECTED — TABLE FAILURE FACT RECEIPT ACCEPTED`

Assignee: `Codex`。只交付本任务的一次虚构数据候选与受限回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

Work 验收：一次虚构运行在源表创建返回 `SOURCE_TABLE_FAILED`，插入、dump、导入、内容校验均未执行；AUTH-39 完整目标 LEVEL 2 REJECT，仅接受受限失败与清理回执，见 `EVIDENCE/AUTH-39-LOCAL-SYNTHETIC-SAME-CONTAINER-RESTORE/summary.md`。具体建表错误未知，旧预算耗尽，后继须另立任务。

## Authority and objective

AUTH-38 的一次本机虚构观察：同一虚构密码通过环境变量和客户端参数均得安全码 `1045`，不传密码的本机 socket `SELECT 1` 成功；这不建立真实 DB 认证规则，旧预算已耗尽。本任务**新授权一个**隔离虚构容器，以该容器内不传密码的本机 socket 方式完成三行虚构数据的同容器 dump/restore 并核对内容。它仅检查本地镜像与工具链能否处理极小的虚构样本，不是独立目标恢复、真实备份或真实数据库权限证明。

## Exact execution boundary

- 预检当前 Docker context 本机、daemon 可达、固定本地 `mariadb:10.11` 镜像存在、唯一容器名 `elitesync-auth39-synthetic-restore` 空闲；任一不符即停。不启动 Docker Desktop、不拉取镜像或换 context。只读核对 AUTH-32 `parse_mounts.ps1` SHA-256 `AA11EA742604C2EA9B76EF81EA8C4CD19E678D1C4E368AD421EB38D66F20D974` 后加载。
- 最多一次启动固定容器，`--pull never`、`--network none`、无端口/宿主 bind/命名卷，数据、运行、临时目录只用 `/var/lib/mysql`、`/run/mysqld`、`/tmp` 三个 tmpfs；容器初始化密码仅为本任务虚构值，不在摘要显示。先核对本次 ID/名称、NetworkMode、PortBindings、Binds、HostConfig.Tmpfs 与经 AUTH-32 解析后的 Mounts；任一安全字段未知或不符即停。不要启动截图中的旧容器或任何项目服务。
- 隔离全部 PASS 后等待至容器启动至少 45 秒，使用容器内 `mariadb -uroot`、无 `MYSQL_PWD` 和无密码参数的本机 socket 连接，仅执行一次 `SELECT 1`；失败即停，不尝试真实凭据或其他连接方式。通过后依次各最多一次：创建固定虚构源 schema、固定简单表、插入三行固定虚构记录；用容器内 `mariadb-dump --no-defaults -uroot` 仅导出该虚构表到容器 `/tmp` 的固定文件；创建第二个虚构目标 schema；从该文件导入目标；核对精确行数与固定内容。每一步失败立即停止，不改语法/参数后重试。不得使用宿主路径、`docker cp` 或其他数据传输。
- dump、虚构 SQL、输出和密码只留在本次容器 tmpfs 或进程内存，不保存或显示原始 stdout/stderr、容器日志/inspect、dump 内容、行内容、密码或容器 ID；回执只写各阶段 PASS/FAIL/NOT_CHECKED、固定计数或布尔、最早失败、调用次数、耗时与清理状态。无论结果，只对本任务确实创建且归属可验证的唯一容器按 ID 精确清理最多一次，并按名称只读核对不存在；所有权不明不删除，报 `CLEANUP_UNRESOLVED`。不得操作其他容器/卷/镜像或 broad prune。总运行含清理不超过 180 秒。

## Candidate, verification and stop

只允许新增 `EVIDENCE/AUTH-39-LOCAL-SYNTHETIC-SAME-CONTAINER-RESTORE/run.ps1` 与同目录 `summary.md`；不得修改 AUTH-32～38 或控制文件。先 PowerShell 静态解析和安全边界检查，满足后脚本最多执行 1 次；任何失败不修改后重跑，也不手动补步骤。Work 独立审查脚本、执行账本、负向停止与精确清理；作者结果不自接受。即使全部 PASS，也只证明这个虚构样本在**同一容器**能导入第二 schema，不证明独立容器恢复、加密本地备份可恢复、真实数据库身份/结构、生产就绪或发布权限；后继需另立任务。

启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能及 AUTH-32～38 回执；核对 `D:\EliteSync-v10`、`main`、HEAD、工作区。派发前接受检查点 `80096abab5ddbadc3a3eeb63a392d739476bde8b`；当前 HEAD 应为仅下达本任务的检查点，父提交须为该基线。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。前置不符即停。

`git diff --check` 最多 1 次，新文件另作只读尾随空白检查。不得访问旧 `D:\EliteSync`、浏览器、SSH、云 API、真实 DB、备份目录、真实凭据/密钥、账号/Token/消息/媒体或业务数据；不下载软件、不真实备份/传输/改库。Codex 不提交、不制作 bundle、不推送、不自接受或派发后继。
