# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-34-LOCAL-SYNTHETIC-SETUP-DIAGNOSIS`

Risk Level: `LEVEL 2`（AUTH-33 虚构 SQL setup 失败的本机分步诊断；Work 独立审查）

Status: `ISSUED — NOT STARTED`

Assignee: `Codex`。只交付一次虚构数据分步诊断与受限回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

AUTH-33 当次固定容器隔离声明通过，但 `mariadb-admin ping` 后合并的虚构 setup SQL 返回失败，具体原因未知；dump/restore 未执行，旧预算已耗尽。本任务**只定位虚构 setup 的最早失败阶段**，不重跑 dump/restore。所有数据、凭据、schema 与表均是任务固定的虚构值，不接触真实数据库或备份。

## Exact local execution and output

- 预检本机 Docker context、daemon、固定本地 `mariadb:10.11` 镜像和唯一容器名 `elitesync-auth34-setup-probe` 空闲；任一失败即停。不启动 Docker Desktop、不拉取镜像或换 context。
- 最多一次启动固定容器，`--pull never`、`--network none`、无端口/宿主 bind/命名卷，数据/运行/临时目录仅用三个固定 tmpfs。只读加载 AUTH-32 已接受解析器并核对哈希；检查 ID/名称、网络、PortBindings、Binds、HostConfig.Tmpfs 及 Mounts，与 AUTH-33 同等 fail-closed 边界。隔离任一不通过即停。
- 隔离通过后，仅按固定顺序各最多一次执行：真正认证连接的 `SELECT 1`（不能以 `mariadb-admin ping` 代替认证证据）、创建虚构 schema、创建固定虚构表、插入三行固定虚构记录。每步成功只记录 `PASS`，失败只记录阶段及安全分类 `AUTH_OR_CONNECTION`、`SQL_REJECTED`、`TIMEOUT` 或 `OTHER/UNKNOWN`；分类无法可靠判断保持 `UNKNOWN`，不得保存/显示原始 stderr、SQL 行、密码或容器日志。最早失败后不继续、不换语法/凭据、不重试。
- 不论成功失败，只对本任务确实创建的容器按 ID 精确清理最多一次，按名称只读核对不存在；所有权不明则不删并报 `CLEANUP_UNRESOLVED`。不得操作其他容器/卷/镜像或 broad prune。总执行含清理不超过 120 秒。只输出固定阶段、最早失败、调用次数、清理结果。

## Allowed candidate and stop

只允许新增 `EVIDENCE/AUTH-34-LOCAL-SYNTHETIC-SETUP-DIAGNOSIS/run.ps1` 与同目录 `summary.md`。先静态检查，再执行脚本最多 1 次；任何失败不修订后重跑。若四步均 PASS，也只说明虚构 SQL 分步可执行，不证明 AUTH-33 合并命令为何失败或 dump/restore 可用。后继仍需另立任务。

启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能及 AUTH-32/33 记录，核对 `main`、HEAD、工作区。派发前检查点 `c2a0d1506b8793c20577e97ac826665e4a7a0b0d`；当前 HEAD 应为仅下达本任务的检查点，父提交须为基线。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。不符即停。

`git diff --check` 最多 1 次，新文件另作只读尾随空白检查。不得访问旧 `D:\EliteSync`、浏览器、SSH、云 API、真实 DB、备份目录、真实凭据/密钥、账号/Token/消息/媒体或业务数据；不下载软件、不 dump/restore、不真实备份/传输/改库。Codex 不修改控制文件、不提交、不制作 bundle、不推送、不自接受或派发后继。
