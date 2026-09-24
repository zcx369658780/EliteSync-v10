# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-33-LOCAL-SYNTHETIC-RESTORE-REPLAY`

Risk Level: `LEVEL 2`（修正隔离字段解析后的本机虚构恢复一次验证；Work 独立审查）

Status: `WORK LEVEL 2 REJECTED — PARTIAL FACT RECEIPT ACCEPTED`

Assignee: `Codex`。只交付本机虚构数据候选与一次执行回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

Owner 选择完整备份加密存到自己的电脑/本地磁盘，恢复演练优先本机独立环境。AUTH-30 的一次演练未越过隔离检查；AUTH-31 的 Mounts 定点诊断因 PowerShell 空数组赋值解析失败；AUTH-32 纯解析器及 14 个虚构用例已获 Work LEVEL 2 ACCEPT。旧任务运行预算不重置。本任务是**新的一次**本机虚构 dump/restore 验证，使用已接受解析器，不接触真实 DB 或备份。

## Exact execution boundary

- 只在本机 Docker context、daemon 可达、精确本地 `mariadb:10.11` 镜像存在且唯一容器名 `elitesync-auth33-synthetic-restore` 空闲时启动；任一不符即停。不拉取镜像、换 context 或启动 Docker Desktop。
- 唯一容器启动最多 1 次，固定 `--pull never`、`--network none`、无端口/宿主 bind/命名卷；数据、运行、临时目录只用三个 tmpfs 目标 `/var/lib/mysql`、`/run/mysqld`、`/tmp`。只用与项目/真实用户无关的虚构密码、schema、表和固定少量行。
- 先核对容器 ID/名称、NetworkMode=none、PortBindings/Binds 为空、HostConfig.Tmpfs 三目标精确匹配，再调用 AUTH-32 的 `Parse-Mounts` 对原始内存对象解析。若 Mounts 为 null/空，只在解析成功且 count=0、上述其他隔离字段全 PASS 时允许继续；若非空，须 `parse_ok=true`、各挂载类型仅 tmpfs、目标仅在固定三项内。任何 volume/bind/额外目标、解析异常或安全字段未知即停。记录 Mounts 数量和固定谓词，不保存原始 inspect。
- 隔离声明全部 PASS 后，才在**同一个本机临时容器**中建立虚构源 schema/表/行，dump 至容器内 tmpfs，导入第二个虚构 schema，核对固定行数与内容摘要。此验证只说明合成小数据的同容器 dump/restore，不证明独立目标恢复或真实备份可恢复。
- 不论成功失败，仅对本任务确实创建的唯一容器按 ID 精确清理最多 1 次，随后按名称只读核对不存在；所有权不明则不删除并报 `CLEANUP_UNRESOLVED`。不得清理其他容器/卷/镜像或使用 prune。每个阶段最多 1 次，不重试；总执行/清理上限 120 秒。只输出阶段、最早失败、固定计数/布尔、调用次数及清理状态，不保存 dump、日志、SQL 行、密码或原始 stdout/stderr。

## Allowed candidate and stop

只允许新增 `EVIDENCE/AUTH-33-LOCAL-SYNTHETIC-RESTORE-REPLAY/run.ps1` 与同目录 `summary.md`。脚本可只读加载 AUTH-32 已接受的 `parse_mounts.ps1`，不得修改旧脚本/证据。先做静态解析和安全边界检查，若不满足则不运行；若满足，脚本最多执行 1 次。回执逐阶段列 PASS/FAIL/NOT_CHECKED、调用账本和实际清理结果。失败不得修后重跑，也不得把容器声明、虚构 PASS 说成真实数据可恢复。

启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能及 AUTH-30/31/32 记录；核对 `main`、HEAD、工作区。派发前接受检查点 `be03285e2291766dd74c3df70169afb928662342`；当前 HEAD 应为仅下达本任务的检查点，父提交须为该基线。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。前置不符即停。

`git diff --check` 最多 1 次，新文件另作只读尾随空白检查。不访问旧 `D:\EliteSync`、浏览器、SSH、云 API、真实数据库、备份目录、凭据、密钥或业务数据；不安装软件、不拉取镜像、不真实备份/传输/改库。Codex 不修改控制文件、不提交、不制作 bundle、不推送、不自接受或派发后继。真实数据仍须独立 Owner 高风险门。
