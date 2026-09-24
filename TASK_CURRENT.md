# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-36-LOCAL-DOCKER-STARTUP-RECHECK`

Risk Level: `LEVEL 2`（本机已安装 Docker Desktop 一次启动与服务可达性复核；Work 独立审查）

Status: `WORK LEVEL 2 REJECTED — STARTUP FACT RECEIPT ACCEPTED; OWNER RESTART PENDING`

Assignee: `Codex`。只交付固定本机环境回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

Work 验收：固定程序只启动一次，但等待后的 daemon 仍不可达；AUTH-36 的“恢复可达”目标 LEVEL 2 REJECT，仅接受受限回执，见 `EVIDENCE/AUTH-36-LOCAL-DOCKER-STARTUP-RECHECK/summary.md`。Owner 正亲自重启 Docker；本任务一次预算已耗尽，依赖 daemon 的后继暂缓，待重启完成后重新核验。

## Authority and objective

AUTH-35 的一次虚构认证探针在 `DAEMON_UNREACHABLE` 预检处停止，没有创建容器或观察认证，旧预算已耗尽。AUTH-28 曾证明当时可由已安装 Docker Desktop 启动本机 daemon，但不代表重启应用后的当前状态。本任务只对固定本机程序做一次受限启动与复核，以判断能否另立虚构认证探针任务；不运行容器、不读取镜像/卷/数据，也不重跑 AUTH-35。

## Exact execution and evidence

- 先只读核对当前 Docker context 的 endpoint 为本机命名管道或本机 Unix socket，并查询 daemon 可达性一次；非本机、context 不可解析时立即停止，不更换 context。若 daemon 已可达，记录 `ALREADY_REACHABLE`，不启动程序。
- 若 daemon 不可达，只读确认固定 `C:\Program Files\Docker\Docker\Docker Desktop.exe` 是普通文件，并按固定进程名检查 Docker Desktop 是否已运行一次。文件不存在即停；进程未运行时只允许 `Start-Process -FilePath` 该固定程序 `-WindowStyle Hidden` 一次。进程已运行时不结束、不重启、不再次启动。无论是否执行启动，等待 30 秒一次，然后对同一本机 context 的 daemon 仅复核一次；不可达即停止并报告。不得安装/更新软件、切换账号/设置、接受管理员/登录/协议/UI 提示或使用其他程序路径。
- 总动作不超过 60 秒；仅保存布尔或白名单结果、调用次数和最早失败阶段，不保存原始 Docker 输出、进程参数、环境变量、端点全文或 UI 截图。只允许新增 `EVIDENCE/AUTH-36-LOCAL-DOCKER-STARTUP-RECHECK/summary.md`。无需编写/执行自定义脚本；执行失败不重试，不扩大范围。任何实际容器、镜像、卷、网络、数据库、备份、恢复或应用功能均不在任务范围。

## Preconditions and stop

启动前读 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能及 AUTH-28、AUTH-35 回执；核对 `D:\EliteSync-v10`、`main`、HEAD 和工作区。派发前接受检查点 `4efff1da7d0f4715937e2384abb5c28ec7643830`；当前 HEAD 应为仅下达本任务的检查点，父提交须为该基线。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。不符即停。

`git diff --check` 最多 1 次，新文档另作只读尾随空白检查。不得访问旧 `D:\EliteSync`、浏览器、SSH、云、真实 DB、备份目录、真实凭据/密钥或业务数据；不推送、不提交、不制作 bundle、不自接受或派发后继。可达只证明当次本机 daemon 回应，不证明 AUTH-35 认证、隔离、备份或恢复能力。Codex 停在 Work LEVEL 2 独立验收门。
