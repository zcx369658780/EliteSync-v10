# EliteSync v10｜TASK_CURRENT

Task ID: `AUTH-31-LOCAL-DOCKER-ISOLATION-MISMATCH-DIAGNOSIS`

Risk Level: `LEVEL 2`（AUTH-30 隔离声明失败的虚构容器定点诊断；Work 独立审查）

Status: `WORK LEVEL 2 REJECTED — PARTIAL FACT RECEIPT ACCEPTED`

Assignee: `Codex`。只交付定点诊断候选与受限回执，停在 Work LEVEL 2 独立 ACCEPT/REJECT 门。

## Authority and objective

AUTH-30 的一次虚构恢复演练在 `ISOLATION_DECLARATION_MISMATCH` 停下，未运行数据库步骤；作者报告本任务容器已精确清理，原始 inspect 未保存。旧运行预算已耗尽。本任务是**新的只检查 Docker 隔离声明字段的诊断**，不重跑 AUTH-30、不开数据库、不做 dump/restore。目的是确定哪一类固定谓词不符，避免盲目放宽隔离要求。

## Exact local scope

- 仅使用本机 Docker context；先只读确认端点本机、daemon 可达、固定 `mariadb:10.11` 本地镜像存在。任一失败即停。不拉取镜像、不启动 Docker Desktop、不换 context。
- 唯一可创建容器名 `elitesync-auth31-isolation-probe`。先确认该名称不存在；已存在即停，不覆盖。最多一次启动 `mariadb:10.11` 的固定 `sleep` 进程，`--pull never`、`--network none`、无端口、无宿主 bind/volume，沿用 AUTH-30 的三个 tmpfs 目标，但**不执行 MariaDB entrypoint**、不传任何密码、SQL 或真实数据。不挂载项目/用户目录。启动/检查/清理总等待上限 90 秒。
- 对本次容器 `docker inspect` 最多 1 次，仅提取并记录固定白名单：ID 与名称匹配、NetworkMode=`none`、PortBindings 为空、Binds 为空、HostConfig.Tmpfs 目标三项匹配、Mounts 数量及各类型是否均为 tmpfs；每项 `true`/`false`/`UNKNOWN`，数量只记非负整数或 `UNKNOWN`。不得保存原始 inspect、端点、镜像元数据、路径或容器日志。若任一必需安全字段（网络、端口、Binds、tmpfs 目标）为 false/UNKNOWN，立即停止，不进入任何功能测试。
- 无论成功失败，仅对**本任务确实创建的同名容器**精确删除最多一次，并只读核对不存在；清理失败报告 `CLEANUP_FAILED`，不操作其他容器、镜像或卷，不用 prune/clean/reset。不可辨认所有权时不删除，报告 `CLEANUP_UNRESOLVED`。

## Allowed candidate and stop

只允许新增 `EVIDENCE/AUTH-31-LOCAL-DOCKER-ISOLATION-MISMATCH-DIAGNOSIS/run.ps1` 与同目录 `summary.md`。脚本须输出固定字段、阶段、最早失败、清理结果与调用次数；先静态解析检查，再执行最多 1 次，不重试。回执说明是否能定位 AUTH-30 原失败；即使本次谓词全通过，也不能反证 AUTH-30 当次环境或证明恢复能力。若可能只是 AUTH-30 对 Docker inspect `Mounts` 的假设过严，应依据本次字段如实归类，不直接改旧证据或重新运行恢复。

启动前读取 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、本任务、`REVIEW_GATE.md`、本地工作流技能及 AUTH-29/30 记录；核对 `main`、HEAD、工作区。派发前接受/失败检查点为 `e1bc29e20840c095017dd5d0c11e954edb3bf896`；当前 HEAD 应为仅下达本任务的检查点，父提交须为该基线。保留无关未跟踪 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/`。不符即停。

`git diff --check` 最多 1 次，新文件另作只读尾随空白检查。不访问旧 `D:\EliteSync`、浏览器、SSH、云 API、真实数据库、备份目录、凭据、密钥或业务数据。不运行 DB、dump/restore、不备份/传输/改库，不下载或安装软件。Codex 不修改控制文件、不提交、不制作 bundle、不推送、不自接受或派发后继。
