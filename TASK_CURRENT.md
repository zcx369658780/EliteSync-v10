# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-45-LOCAL-SYNTHETIC-SEPARATE-CONTAINER-RESTORE`

Risk Level: `LEVEL 2`（本机虚构跨容器内存转移与独立目标恢复；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。只交付候选与一次顺序演练回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

AUTH-44 的受限 ACCEPT 只证明三行虚构样本在同一容器的两个 schema 间导出/导入，未证明源容器消失后能在另一容器恢复。本任务新授权一次**两个新建容器的顺序虚构演练**：源容器中建立并核对固定三行，只在宿主进程内存中暂存不超过 256 KiB 的 dump；按 ID 清理并核对源容器不存在后，才启动目标容器，将内存 dump 通过目标 `docker exec -i` 的 stdin 导入独立 schema 并核对固定内容。不得创建宿主 dump 文件、命名卷或真实备份。

## Exact execution boundary

- 启动前阅读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能与 AUTH-32、AUTH-43～44 回执；核对 `D:\EliteSync-v10`、本地 `main`、HEAD、工作区。当前 HEAD 应为只下达本任务的检查点，其父提交须精确为 `27c2d86d5c164d309352f51255905697d3702a8f`。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`，旧预算不得重用。
- 预检 Docker context 本机、daemon 可达、本地固定 `mariadb:10.11` 镜像标签存在，两个唯一名称 `elitesync-auth45-source` 与 `elitesync-auth45-target` 都空闲；任一不符即停。只读核对 AUTH-32 `parse_mounts.ps1` SHA-256 `AA11EA742604C2EA9B76EF81EA8C4CD19E678D1C4E368AD421EB38D66F20D974` 后加载。不启动 Docker Desktop、旧容器或项目服务，不拉取镜像、换 context。
- 最多顺序启动源和目标各 **1** 个固定虚构容器；每个都用 `--pull never --network none`、无端口/宿主 bind/命名卷，tmpfs 精确为 `/var/lib/mysql:rw,nosuid,noexec,size=512m`、`/run/mysqld:rw,nosuid,size=16m`、`/tmp:rw,nosuid,size=64m`。初始化密码分别用任务固定虚构值 `Auth45_Source_Only_2026`、`Auth45_Target_Only_2026`，绝不读取真实凭据。各容器在任何数据库动作前分别核对本次 ID/名称/nonce 标签、密码环境变量精确匹配布尔、NetworkMode、PortBindings、Binds、HostConfig.Tmpfs 目标与大小及 AUTH-32 解析的 Mounts；未知或不符即停，不触碰另一容器。
- 每个容器启动至少 45 秒后各执行固定 `df -Pk /var/lib/mysql` 最多 1 次，严格解析本目标三个整数；可用低于 131072 KiB 或 UNKNOWN 即停。各自仅以本容器对应虚构密码经 `docker exec -e MYSQL_PWD=... mariadb` 运行 `SELECT 1` 最多 1 次，退出 0 且 stdout 严格为 `1` 才继续；不换认证方式、密码或连接协议。
- 源阶段每步最多 1 次、失败即停：创建 `auth45_source` schema；创建唯一表 `sample_rows (id INT PRIMARY KEY, label VARCHAR(16) NOT NULL)`；插入固定 `(1,'alpha'),(2,'beta'),(3,'gamma')`；只读核对计数 3 与按 id 排序的精确内容；`mariadb-dump --no-defaults` 仅导出该表，捕获 stdout **仅在宿主进程内存**，严格要求退出 0、非空且 UTF-8 字节数不超过 262144。原始 dump 不显示、不保存、不写宿主或容器文件。源容器随后必须按本次 ID 清理并按固定名称核对不存在；只有清理 PASS 才可启动目标。
- 目标阶段每步最多 1 次、失败即停：新目标通过相同隔离、空间和认证门；创建 `auth45_target` schema；仅将内存 dump 经 `docker exec -i -e MYSQL_PWD=...` 的 stdin 输入 `mariadb -uroot auth45_target`，不得经 shell 重定向、宿主/容器文件或网络；核对精确计数 3、固定内容与源记录的一致布尔。不得导入真实数据或向源容器回写。
- 输出仅保存每阶段 `PASS/FAIL/NOT_CHECKED`、调用次数、两个容器的空间整数、dump 字节数、计数及内容相等布尔、首个失败类别、0～255 退出码或 `UNKNOWN`、唯一 MariaDB `ERROR` 数字码或 `UNKNOWN`、总耗时与分别的清理状态。不得保存/显示原始 stdout/stderr、SQL 行内容、dump、Docker inspect/log、容器 ID、密码或完整环境变量/进程参数。内存 dump 在目标导入完成或失败时释放，不写任何持久介质。
- 每个容器只在本次确实创建且归属可验证时按自身 ID 精确清理最多 1 次，再按固定名称只读核对不存在；所有失败路径先清理已创建容器，归属不明不删除并记 `CLEANUP_UNRESOLVED`。不得碰其他容器、卷、镜像或 broad prune。整个一次性演练含清理不超过 **300 秒**；超时即停止新动作，仍尝试有界清理。

## Candidate, verification and stop

只允许新增 `EVIDENCE/AUTH-45-LOCAL-SYNTHETIC-SEPARATE-CONTAINER-RESTORE/run.ps1` 和同目录 `summary.md`；不得修改旧任务、源码或控制文件。先做 PowerShell 静态解析与安全边界检查，满足后脚本最多运行 **1 次**。任何失败不得修改后重跑、手动补步骤或重新启动容器。`git diff --check` 最多 1 次；新文件另做只读尾随空白检查。摘要列实际阶段、失败和未运行步骤、预算、清理与限制。Codex 不提交、制作 bundle、推送、自接受或派发后继。

不得访问旧 `D:\EliteSync`、浏览器、SSH、云 API、真实 DB、备份目录、真实凭据/密钥、账号/Token/消息/媒体或业务数据；不下载软件、不做真实备份、传输、恢复或改库。即使跨容器虚构 PASS，也不证明真实数据库身份、完整加密持久备份、真实数据兼容、生产或发布就绪。真实改库前备份与可恢复验证仍是单独的受保护门。
