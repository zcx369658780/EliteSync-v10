# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-42-LOCAL-SYNTHETIC-EXPANDED-TMPFS-RESTORE`

Risk Level: `LEVEL 2`（扩大本机隔离虚构容器临时空间后的一次同容器小样本恢复；Work 独立审查）

Status: `WORK LEVEL 2 REJECTED — EXPANDED-CONTAINER AUTH FAILURE RECEIPT ACCEPTED`

Assignee: `Codex`。只交付一次虚构数据候选与受限回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

Work 验收：扩大 tmpfs 的本机虚构容器在无密码 socket `SELECT 1` 返回安全码 `1045`，空间门和恢复步骤未执行；AUTH-42 目标 LEVEL 2 REJECT，仅接受受限认证失败与清理回执，见 `EVIDENCE/AUTH-42-LOCAL-SYNTHETIC-EXPANDED-TMPFS-RESTORE/summary.md`。AUTH-38 的不同容器观察不能替代本次认证。旧预算耗尽，后继须新任务。

## Authority and objective

AUTH-41 的一次虚构容器观察报告 `/var/lib/mysql` 128 MiB tmpfs 在原建表前剩余 0 KiB，建表失败；错误类别未完成，不证明空间是唯一原因。旧预算已耗尽。本任务**新授权一个**隔离虚构容器，只把数据 tmpfs 从 128 MiB 提到 512 MiB、`/tmp` 从 32 MiB 提到 64 MiB，保持 AUTH-39 的原建表 SQL 与三行虚构样本，尝试完成同容器第二 schema 的 dump/restore。成功仍只证明该本地虚构样本，不能证明独立目标或真实备份可恢复。

## Exact execution boundary

- 预检 Docker context 本机、daemon 可达、固定本地 `mariadb:10.11` 镜像存在且唯一容器名 `elitesync-auth42-expanded-restore` 空闲；任一不符即停。不启动 Docker Desktop、不拉取镜像或换 context。只读核对 AUTH-32 `parse_mounts.ps1` SHA-256 `AA11EA742604C2EA9B76EF81EA8C4CD19E678D1C4E368AD421EB38D66F20D974` 后加载。
- 最多一次启动固定容器，`--pull never`、`--network none`、无端口/宿主 bind/命名卷，三处仅为 `/var/lib/mysql:rw,nosuid,noexec,size=512m`、`/run/mysqld:rw,nosuid,size=16m`、`/tmp:rw,nosuid,size=64m` 的 tmpfs；只用本任务虚构初始化密码。先核对本次 ID/名称、NetworkMode、PortBindings、Binds、HostConfig.Tmpfs 三目标及上述大小、经 AUTH-32 解析后的 Mounts；任何未知或不符即停。不启动截图中的旧容器或项目服务。
- 隔离通过后等待至容器启动至少 45 秒，用不传密码的本机 socket `mariadb -uroot` 执行一次 `SELECT 1`；失败即停。只读 `df -Pk /var/lib/mysql` 一次，严格解析本目标的 `size_kib/used_kib/available_kib`；若不可用或 `available_kib < 131072` 即停，不运行写 SQL。随后保持 AUTH-39 的原虚构源 schema/表/三行定义，各一步最多一次并失败即停；dump 只到本次容器 `/tmp` 固定文件，创建第二虚构 schema 后从该文件导入，最后只核对固定三行的精确计数与内容布尔。不得使用宿主路径、`docker cp`、真实账号/数据、网络或其他数据传输。
- 原始 stdout/stderr、虚构密码、环境变量、进程参数、容器 inspect/log、dump 与行内容、容器 ID 均不得保存或显示。每个阶段只记录 PASS/FAIL/NOT_CHECKED、固定整数/布尔、退出码 0～255 或 UNKNOWN、唯一安全 MariaDB 数字错误码 1～65535 或 UNKNOWN、最早失败与调用次数；解析失败保持 UNKNOWN，不编造原因。无论结果，仅对本任务确实创建且归属可验证的容器按 ID 精确清理最多一次，按名称只读核对不存在；归属不明不删除并报 `CLEANUP_UNRESOLVED`。不操作其他容器/卷/镜像或 broad prune。总运行含清理不超过 180 秒。

## Candidate, verification and stop

只允许新增 `EVIDENCE/AUTH-42-LOCAL-SYNTHETIC-EXPANDED-TMPFS-RESTORE/run.ps1` 与同目录 `summary.md`；不得修改 AUTH-32～41 或控制文件。先 PowerShell 静态解析及安全边界检查，满足后脚本最多执行 1 次；任何失败不修改后重跑、不手动补步骤。Work 独立审查脚本、账本、隔离门、内容核验与精确清理；作者结果不自接受。若通过，也只说明单容器内两个虚构 schema 的导出/导入；不证明独立容器恢复、加密本地备份可恢复、真实 DB 身份/结构、生产就绪或发布权限。后继须新任务。

启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能及 AUTH-32～41 回执；核对 `D:\EliteSync-v10`、`main`、HEAD、工作区。派发前接受检查点 `028987f7eab96b86d1c91fcee6d23f07bf05b864`；当前 HEAD 应为仅下达本任务的检查点，父提交须为该基线。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。前置不符即停。

`git diff --check` 最多 1 次，新文件另作只读尾随空白检查。不得访问旧 `D:\EliteSync`、浏览器、SSH、云 API、真实 DB、备份目录、真实凭据/密钥、账号/Token/消息/媒体或业务数据；不下载软件、不真实备份/传输/改库。Codex 不提交、不制作 bundle、不推送、不自接受或派发后继。
