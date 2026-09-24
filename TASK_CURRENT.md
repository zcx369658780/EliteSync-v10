# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-38-LOCAL-SYNTHETIC-ROOT-AUTH-MODE-DIAGNOSIS`

Risk Level: `LEVEL 2`（本机隔离虚构 MariaDB root 只读认证方式诊断；Work 独立审查）

Status: `WORK LEVEL 2 ACCEPTED — SYNTHETIC AUTH MODE FACT ONLY`

Assignee: `Codex`。只交付一次受限虚构容器候选与回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

Work 验收：本机虚构容器中两种带虚构密码的 `SELECT 1` 均返回安全码 `1045`，不传密码的本机 socket 方式 PASS，作者报告按 ID 清理 PASS；作为受限观察获 LEVEL 2 ACCEPT，见 `EVIDENCE/AUTH-38-LOCAL-SYNTHETIC-ROOT-AUTH-MODE-DIAGNOSIS/summary.md`。具体认证配置原因、虚构 dump/restore 与真实数据库恢复能力未证明。本次运行预算已耗尽，后继须另立任务。

## Authority and objective

AUTH-37 的冻结脚本在同一个虚构容器约 20/40/60 秒用 `MYSQL_PWD` 传递虚构密码执行 `SELECT 1`，三次都返回安全码 `1045`；原因仍未知，旧预算耗尽。本任务**新授权一个**隔离虚构容器，使用相同的固定虚构密码与只读 `SELECT 1`，按序比较环境变量、显式客户端密码参数和无密码本机 socket 连接。它只定位本机镜像/客户端的认证方式现象，不推断真实服务端认证配置，不创建业务 schema/行、不运行 dump/restore。

## Exact execution boundary

- 预检 Docker context 为本机、daemon 可达、固定本地 `mariadb:10.11` 镜像存在且唯一容器名 `elitesync-auth38-auth-modes` 空闲；任一不符即停。不启动 Docker Desktop、不拉取镜像或换 context。只读核对 AUTH-32 `parse_mounts.ps1` SHA-256 `AA11EA742604C2EA9B76EF81EA8C4CD19E678D1C4E368AD421EB38D66F20D974` 后加载。
- 最多一次启动固定容器，`--pull never`、`--network none`、无端口/宿主 bind/命名卷，数据/运行/临时目录只用 `/var/lib/mysql`、`/run/mysqld`、`/tmp` 三个 tmpfs；使用只属于本任务的固定虚构 root 密码。先核对本次 ID/名称、NetworkMode、PortBindings、Binds、HostConfig.Tmpfs 与解析后的 Mounts，要求与 AUTH-34/35 同等级 fail-closed；不通过即停。不要启动截图中的旧容器或任何项目服务。
- 隔离通过后等待到本次容器启动后至少 45 秒，再按顺序各最多一次运行以下**仅读** SQL：① `docker exec -e MYSQL_PWD=<虚构密码> <本次容器> mariadb -uroot --batch --skip-column-names -e 'SELECT 1;'`；若 ① 成功即停止认证步骤；若安全码唯一为 `1045`，② 使用同一密码的 `mariadb -uroot --password=<虚构密码> --batch --skip-column-names -e 'SELECT 1;'`，且不传 `MYSQL_PWD`；若 ② 也唯一为 `1045`，③ 不传密码环境变量或参数，使用 `mariadb -uroot --batch --skip-column-names -e 'SELECT 1;'`。任一步未知错误、连接错误、超时或非 `1045` 均停止后续认证步骤。只将退出 0 且 stdout 严格为 `1` 判为 PASS。
- 失败仅在内存解析单个 MariaDB `ERROR <数字>`；回执只允许白名单码 `1045`、`2002`、`2003`、`2013`、`UNRECOGNIZED/UNKNOWN`，不得保存或显示原始 stdout/stderr、密码、环境变量、进程参数、容器 inspect/log、SQL 内容或容器 ID。无论结果，仅对本任务确实创建且归属可验证的容器按 ID 精确清理最多一次，再按固定名称只读核对不存在；归属不明不删除并报 `CLEANUP_UNRESOLVED`。总执行含清理不超过 120 秒，不操作其他容器/卷/镜像或 broad prune。

## Candidate, verification and stop

只允许新增 `EVIDENCE/AUTH-38-LOCAL-SYNTHETIC-ROOT-AUTH-MODE-DIAGNOSIS/run.ps1` 与同目录 `summary.md`；不得修改 AUTH-32～37 或控制文件。先做 PowerShell 静态解析与安全边界检查，满足后脚本最多执行 1 次；任何失败不修改后重跑，不手动补探针。摘要列每步 PASS/FAIL/NOT_CHECKED、安全码、调用次数、耗时、隔离声明和清理结果。若任一方式成功，只说明该虚构镜像这次只读认证可用；不证明 AUTH-33 合并 setup 原因、dump/restore、真实 DB 身份或真实备份可恢复。Work 独立审查，作者结果不自接受。

启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能及 AUTH-32～37 回执；核对 `D:\EliteSync-v10`、`main`、HEAD、工作区。派发前接受检查点 `c20d430a2184eed10a39e7cdc5eac34a6fe46701`；当前 HEAD 应为仅下达本任务的检查点，父提交须为该基线。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。前置不符即停。

`git diff --check` 最多 1 次，新文件另作只读尾随空白检查。不得访问旧 `D:\EliteSync`、浏览器、SSH、云 API、真实 DB、备份目录、真实凭据/密钥、账号/Token/消息/媒体或业务数据；不下载软件、不写 SQL、不 dump/restore、不真实备份/传输/改库。Codex 不提交、不制作 bundle、不推送、不自接受或派发后继。
