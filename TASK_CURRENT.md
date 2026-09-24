# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-44-LOCAL-SYNTHETIC-SAME-CONTAINER-RESTORE`

Risk Level: `LEVEL 2`（本机隔离虚构数据库写入与同容器恢复；Work 独立审查）

Status: `WORK LEVEL 2 ACCEPTED — SYNTHETIC SAME-CONTAINER RESTORE FACT ONLY`

Assignee: `Codex`。只交付候选与一次运行回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

Work 验收：三行虚构样本在新建隔离容器的源 schema 经容器 `/tmp` tmpfs 内 dump 导入目标 schema，并报告固定内容一致、按 ID 清理 PASS；仅此受限观察获 LEVEL 2 ACCEPT，见 `EVIDENCE/AUTH-44-LOCAL-SYNTHETIC-SAME-CONTAINER-RESTORE/summary.md`。未证明独立环境恢复或真实备份可恢复，旧一次预算耗尽。

## Authority and objective

AUTH-43 已接受的受限观察是：512 MiB 数据 tmpfs 可用 372552 KiB，固定虚构密码经 `MYSQL_PWD` 首次 `SELECT 1` 成功；未建表或恢复。旧预算已耗尽。本任务新授权**一个新的**本机隔离虚构容器，以相同 tmpfs 和密码方式，验证三行虚构样本在**同一个容器内**导出、导入到独立目标 schema 后是否一致。它不是独立环境恢复或真实备份证明。不启动任何旧容器或项目服务。

## Exact execution boundary

- 启动前核对 `D:\EliteSync-v10`、本地 `main`、HEAD 与工作区；当前 HEAD 应为仅下达本任务的检查点，父提交精确为 `7e1e511c2606d89fb68f88fbd5935c6c83ed8f94`。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。阅读项目入口、产品决定、风险门、本地工作流技能及 AUTH-32、AUTH-39～43 回执；不得重用旧预算。
- 预检 Docker context 为本机、daemon 可达、固定本地 `mariadb:10.11` 标签存在、唯一容器名 `elitesync-auth44-synthetic-restore` 空闲。只读核对 AUTH-32 `parse_mounts.ps1` SHA-256 `AA11EA742604C2EA9B76EF81EA8C4CD19E678D1C4E368AD421EB38D66F20D974` 后加载。任一不符即停；不启动 Docker Desktop、不拉取镜像、不换 context。
- 最多一次启动固定容器：`--pull never --network none`，无端口、宿主 bind 或命名卷，tmpfs 精确为 `/var/lib/mysql:rw,nosuid,noexec,size=512m`、`/run/mysqld:rw,nosuid,size=16m`、`/tmp:rw,nosuid,size=64m`。初始化密码为本任务固定虚构值 `Auth44_Synthetic_Only_2026`，只在内存中比较 `Config.Env` 是否匹配并记录布尔；不显示/保存环境变量原文。核对本次 ID/名称、网络、端口、Binds、三个 tmpfs 目标和大小及经 AUTH-32 解析的 Mounts；任一安全字段 UNKNOWN 或不符即停。
- 隔离 PASS 后等待容器启动至少 45 秒。固定 `df -Pk /var/lib/mysql` 一次，严格解析目标整数；可用低于 131072 KiB 或无法解析即停。以同一虚构密码通过 `docker exec -e MYSQL_PWD=...` 做一次 `SELECT 1`；只有退出 0 且 stdout 严格为 `1` 才继续。不得换认证方式、密码或连接协议。
- 后续按固定顺序，每步最多一次且失败即停：创建虚构源 schema `auth44_source`；创建唯一表 `sample_rows (id INT PRIMARY KEY, label VARCHAR(16) NOT NULL)`；插入固定三行 `(1,'alpha'),(2,'beta'),(3,'gamma')`；源端只读核对精确计数 3 和按 id 排序的固定行内容；在容器**内存中**使用 `mariadb-dump` 仅导出源 schema 的表结构与三行数据；创建虚构目标 schema `auth44_target`；把 dump 仅在本次容器内部导入目标 schema；目标端核对计数 3 与固定三行内容，并比较源/目标一致。不得将 dump、SQL 行内容或原始命令输出写入宿主文件、Git 或回执；可记录阶段布尔、固定整数和安全错误码。若容器内导入需流式传递，只允许本次容器的 stdin/内存，不经宿主持久文件。不得使用或显示 `--password=...` 参数。
- 输出中只记录每阶段 `PASS/FAIL/NOT_CHECKED`、调用次数、`df` 三个整数、行数和相等布尔、首个失败类别、0～255 退出码或 `UNKNOWN`、唯一 MariaDB `ERROR` 数字码或 `UNKNOWN`、耗时及清理结果。不得保存原始 stdout/stderr、Docker inspect/log、密码、完整环境变量/进程参数、容器 ID 或 dump 内容。
- 无论成功失败，只对本次确实创建且归属可验证的容器按 ID 精确清理最多一次，再按固定名称只读核对不存在。归属不明不删除，报告 `CLEANUP_UNRESOLVED`；不碰其他容器、卷或镜像，不 broad prune。总运行含清理不超过 210 秒。

## Candidate, verification and stop

只允许新增 `EVIDENCE/AUTH-44-LOCAL-SYNTHETIC-SAME-CONTAINER-RESTORE/run.ps1` 和同目录 `summary.md`；不得修改旧任务、源码或控制文件。先做 PowerShell 静态解析及安全边界检查，满足后脚本最多运行 **1 次**；任何失败不得修改后重跑、手动补步骤或重启旧容器。`git diff --check` 最多 1 次；新文件另做只读尾随空白检查。摘要记录精确实际阶段、未运行步骤、预算、结果和限制。Codex 不提交、制作 bundle、推送、自接受或派发后继。

不得访问旧 `D:\EliteSync`、浏览器、SSH、云 API、真实 DB、备份目录、真实凭据/密钥、账号/Token/消息/媒体或业务数据；不下载软件、不做真实备份、传输、恢复或改库。即使同容器虚构 PASS，真实数据库身份、完整加密备份和本地独立环境恢复仍待单独授权与验证。
